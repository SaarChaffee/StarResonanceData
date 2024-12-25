local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_dyeingView = class("Fashion_dyeingView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorItemHandler = require("ui/component/color_palette/color_palette_handler")
local loopListView = require("ui.component.loop_list_view")
local unlockItem = require("ui.component.fashion.fashion_unlock_loop_item")
local loopGridView = require("ui.component.loop_grid_view")
local recommendItem = require("ui.component.fashion.fashion_recommend_item")

function Fashion_dyeingView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_dyeing_sub", "fashion/fashion_dyeing_sub", UI.ECacheLv.None)
  self.parentView_ = parent
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.fashionData_ = Z.DataMgr.Get("fashion_data")
  self.fashionCostData_ = {}
  self.colorPalette_ = colorPalette.new(self, colorItemHandler.new(self))
end

function Fashion_dyeingView:OnSelectColorItem(itemIndex)
  self:refreshUnlockUIByColorItemIndex(itemIndex)
end

function Fashion_dyeingView:GetCurFashionId()
  return self.fashionId_
end

function Fashion_dyeingView:Save()
  if self.fashionVM_.GetFashionUuid(self.fashionId_) then
    if self:isCurColorSameAsServerColor() then
      Z.TipsVM.ShowTipsLang(120006)
    else
      local saveVM = Z.VMMgr.GetVM("fashion_save_tips")
      local lockedAreaList = {}
      local areaColorDict = self.fashionData_:GetColor(self.fashionId_)
      for area, hsv in pairs(areaColorDict) do
        if not saveVM.GetFashionColorIsUnlocked(self.fashionId_, area) then
          table.insert(lockedAreaList, area)
        end
      end
      if 0 < #lockedAreaList then
        local areaStr = saveVM.GetFashionColorAreaStr(self.fashionId_, lockedAreaList)
        Z.TipsVM.ShowTipsLang(120009, {str = areaStr})
      else
        self.fashionVM_.AsyncSendFashionColor(self.fashionId_, self.cancelSource:CreateToken())
      end
    end
  else
    Z.TipsVM.ShowTipsLang(120004)
  end
end

function Fashion_dyeingView:ConfirmSaveWithCost()
  if self.fashionVM_.GetFashionUuid(self.fashionId_) then
    if not self:isColorChange() then
      Z.TipsVM.ShowTipsLang(120006)
    elseif #self.fashionCostData_ > 0 then
      local itemsVM = Z.VMMgr.GetVM("items")
      for _, data in ipairs(self.fashionCostData_) do
        local ownNum = itemsVM.GetItemTotalCount(data.ItemId)
        if ownNum < data.UnlockNum then
          Z.TipsVM.ShowTipsLang(100002)
          self.sourceTipsId_ = Z.TipsVM.OpenSourceTips(data.ItemId, self.uiBinder.node_unlock_ref)
          return
        end
      end
      local showItemList = {}
      for _, data in ipairs(self.fashionCostData_) do
        local itemData = {
          ItemId = data.ItemId,
          ItemNum = data.UnlockNum
        }
        showItemList[#showItemList + 1] = itemData
      end
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFashionUnlockConfirm"), function()
        self.fashionVM_.AsyncSendFashionColor(self.fashionId_, self.cancelSource:CreateToken())
      end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.UnlockFashionColorWithCost, showItemList)
    else
      self.fashionVM_.AsyncSendFashionColor(self.fashionId_, self.cancelSource:CreateToken())
    end
  else
    Z.TipsVM.ShowTipsLang(120004)
  end
end

function Fashion_dyeingView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.colorPalette_:Init(self.uiBinder.cont_palette)
  self.colorPalette_:SetColorChangeCB(function(hsv)
    self.hsv_ = hsv
    self.fashionVM_.SetFashionColor(self.fashionId_, self.area_, hsv)
    self:refreshCostData()
  end)
  self.unlockScrollRect_ = loopListView.new(self, self.uiBinder.loop_unlock, unlockItem, "com_item_square_8")
  self.unlockScrollRect_:Init({})
  self:AddAsyncClick(self.uiBinder.btn_unlock, function()
    self:onClickUnlock()
  end)
  self.colorPalette_:SetColorResetCB(function()
    self.colorPalette_:ResetSelectHSVWithoutNotify()
    self:refreshCostData()
  end)
  self.colorPalette_:SetResetBtn(true)
  self:initColorRecommend()
  self:BindEvents()
  
  function self.onContainerDataChange_(container, dirtyKeys)
    self:refreshAreaServerColor()
  end
  
  Z.ContainerMgr.CharSerialize.fashion.Watcher:RegWatcher(self.onContainerDataChange_)
end

function Fashion_dyeingView:OnRefresh()
  self.fashionId_ = self.viewData.fashionId
  self.area_ = self.viewData.area or 0
  self.hsv_ = {
    h = 0,
    s = 0,
    v = 0
  }
  self.fashionCostData_ = {}
  self:setPaletteColorGroup()
  self:initAreaTog()
  self:refreshCostData()
end

function Fashion_dyeingView:OnDeActive()
  self.colorPalette_:UnInit()
  self.unlockScrollRect_:UnInit()
  if self.loop_recommend_ then
    self.loop_recommend_:UnInit()
    self.loop_recommend_ = nil
  end
  self.fashionId_ = nil
  self.area_ = nil
  self.hsv_ = nil
  self.curAreaList_ = nil
  self:ClearTips()
  Z.ContainerMgr.CharSerialize.fashion.Watcher:UnregWatcher(self.onContainerDataChange_)
end

function Fashion_dyeingView:ClearTips()
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
end

function Fashion_dyeingView:initColorRecommend()
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.viewData.fashionId)
  if not fashionRow then
    return
  end
  if fashionRow.Recommend and #fashionRow.Recommend > 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_color_select, true)
    self.uiBinder.tog_recommend.group = self.uiBinder.togs_select
    self.uiBinder.tog_color_area.group = self.uiBinder.togs_select
    self.uiBinder.tog_recommend:AddListener(function(isOn)
      if isOn then
        self:refreshColorState(true)
        self.loop_recommend_:ClearAllSelect()
      end
    end)
    self.uiBinder.tog_color_area:AddListener(function(isOn)
      if isOn then
        self:refreshColorState(false)
        self:refreshAreaDefaultColor()
      end
    end)
    self.loop_recommend_ = loopGridView.new(self, self.uiBinder.loop_recommend, recommendItem, "fashion_color_item")
    self.loop_recommend_:Init(fashionRow.Recommend)
    self.loop_recommend_:ClearAllSelect()
    self.uiBinder.tog_recommend.isOn = false
    self.uiBinder.tog_recommend.isOn = true
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_color_select, false)
    self:refreshColorState(false)
  end
end

function Fashion_dyeingView:refreshColorState(isColorRecommend)
  self.isShowColorRecommend_ = isColorRecommend
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_color_recommend, isColorRecommend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_color_option, not isColorRecommend)
  self.uiBinder.cont_palette.Ref.UIComp:SetVisible(not isColorRecommend)
end

function Fashion_dyeingView:SetFashionColor(colorInfo)
  for i = 1, #colorInfo do
    local index = colorInfo[i][1]
    if self.curAreaList_[index] then
      local hsv = {
        h = colorInfo[i][2],
        s = colorInfo[i][3],
        v = colorInfo[i][4]
      }
      self.fashionVM_.SetFashionColor(self.fashionId_, index, hsv)
    end
  end
  self:refreshCostData()
end

function Fashion_dyeingView:setPaletteColorGroup()
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if fashionRow then
    local colorConfig = self.colorPalette_:RefreshPaletteByColorGroupId(fashionRow.ColorGroupId, true)
    if colorConfig and colorConfig.Type == E.EHueModifiedMode.Board then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, true)
    end
    self:refreshAreaDefaultColor()
  end
end

function Fashion_dyeingView:initAreaTog()
  self.uiBinder.togs_area:ClearAll()
  self.curAreaList_ = {}
  for i = 1, 4 do
    local widget = self.uiBinder[string.zconcat("tog_area", i)]
    self.uiBinder.Ref:SetVisible(widget, false)
    widget:RemoveAllListeners()
    widget.isOn = false
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if not fashionRow then
    return
  end
  local selectArea, selectWidget
  for i, area in ipairs(fashionRow.ColorPart) do
    local widget = self.uiBinder[string.zconcat("tog_area", i)]
    self.uiBinder.Ref:SetVisible(widget, true)
    widget.group = self.uiBinder.togs_area
    widget:AddListener(function(isOn)
      if isOn then
        self.area_ = area
        self:setPaletteSelect()
      end
    end)
    if self.area_ == area or not selectArea then
      selectArea = area
      selectWidget = widget
    end
    self.curAreaList_[area] = true
  end
  selectWidget.isOn = true
  self.area_ = selectArea
  self:setPaletteSelect()
end

function Fashion_dyeingView:setPaletteSelect()
  self:refreshAreaDefaultColor()
  self:refreshAreaServerColor()
end

function Fashion_dyeingView:getModifiedColor()
  local fashionData = Z.DataMgr.Get("fashion_data")
  local color = fashionData:GetColor(self.fashionId_)[self.area_]
  if color then
    return color
  end
  return fashionData:GetServerFashionColor(self.fashionId_, self.area_)
end

function Fashion_dyeingView:isColorChange()
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if not fashionRow then
    return false
  end
  local colorGroupTable = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
  if not colorGroupTable then
    return false
  end
  local fashionData = Z.DataMgr.Get("fashion_data")
  for _, area in ipairs(fashionRow.ColorPart) do
    local curColor = fashionData:GetColor(self.fashionId_)[area]
    if curColor then
      local serverColor = fashionData:GetServerFashionColor(self.fashionId_, area)
      if serverColor then
        if curColor.h ~= serverColor.h or curColor.s ~= serverColor.s or curColor.v ~= serverColor.v then
          return true
        end
      else
        local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, area)
        if curColor.h ~= defaultColor.h or curColor.s ~= defaultColor.s or curColor.v ~= defaultColor.v then
          return true
        end
      end
    end
  end
  return false
end

function Fashion_dyeingView:isColorSameAsServerColor(area)
  local fashionData = Z.DataMgr.Get("fashion_data")
  local curColor = fashionData:GetColor(self.fashionId_)[area]
  if not curColor then
    return true
  end
  if self.fashionVM_.IsDefaultFashionAreaColor(self.fashionId_, area, curColor) then
    return true
  end
  local serverColor = fashionData:GetServerFashionColor(self.fashionId_, area)
  if not serverColor then
    return false
  end
  return curColor.h == serverColor.h and curColor.s == serverColor.s and curColor.v == serverColor.v
end

function Fashion_dyeingView:refreshUnlockUIByColorItemIndex(itemIndex)
  local colorIndex = itemIndex - 1
  local isUnlocked = self.fashionData_:GetColorIsUnlocked(self.fashionId_, colorIndex)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, not isUnlocked)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, true)
  if isUnlocked then
    self.unlockScrollRect_:RefreshListView({}, false)
  else
    local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
    if fashionRow then
      local groupId = fashionRow.ColorGroupId
      local dataList = self.fashionData_:GetUnlockItemDataListByColorGroupIdAndIndex(groupId, colorIndex)
      self.unlockScrollRect_:RefreshListView(dataList, false)
    end
  end
end

function Fashion_dyeingView:onClickUnlock()
  if not self.fashionVM_.GetFashionUuid(self.fashionId_) then
    Z.TipsVM.ShowTipsLang(120012)
    return
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if not fashionRow then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local groupId = fashionRow.ColorGroupId
  local colorIndex = self.colorPalette_:GetCurColorIndex()
  local dataList = self.fashionData_:GetUnlockItemDataListByColorGroupIdAndIndex(groupId, colorIndex)
  for _, data in ipairs(dataList) do
    local ownNum = itemsVM.GetItemTotalCount(data.ItemId)
    if ownNum < data.UnlockNum then
      Z.TipsVM.ShowTipsLang(100002)
      return
    end
  end
  local showItemList = {}
  for _, data in ipairs(dataList) do
    local itemData = {
      ItemId = data.ItemId,
      ItemNum = data.UnlockNum
    }
    showItemList[#showItemList + 1] = itemData
  end
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFaceUnlockConfirm"), function()
    self:onConfirmUnlockFashionColor(colorIndex)
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.UnlockFashionColor, showItemList)
end

function Fashion_dyeingView:refreshCostData()
  if self.viewData.isPreview then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
    return
  end
  self:calcCostData()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, #self.fashionCostData_ > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, false)
  self.unlockScrollRect_:RefreshListView(self.fashionCostData_, false)
end

local comp = function(left, right)
  local itemTbl = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTblLeft = itemTbl.GetRow(left.ItemId)
  local itemTblRight = itemTbl.GetRow(right.ItemId)
  if itemTblLeft and itemTblRight then
    if itemTblLeft.Quality == itemTblRight.Quality then
      return itemTblLeft.Id < itemTblRight.Id
    else
      return itemTblLeft.Quality > itemTblRight.Quality
    end
  end
  return false
end

function Fashion_dyeingView:calcCostData()
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if not fashionRow then
    return {}
  end
  local colorGroupTable = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(fashionRow.ColorGroupId)
  if not colorGroupTable then
    return {}
  end
  local costData = {}
  local svIsHighCost = false
  local svIsCost = false
  self.fashionCostData_ = {}
  for _, area in ipairs(fashionRow.ColorPart) do
    if not self:isColorSameAsServerColor(area) then
      local fashionData = Z.DataMgr.Get("fashion_data")
      local curColor = fashionData:GetColor(self.fashionId_)[area]
      if curColor then
        self:calcColorHCost(colorGroupTable, curColor, costData)
        svIsHighCost = svIsHighCost or self:isColorSVHighCost(colorGroupTable, curColor)
        svIsCost = true
      end
    end
  end
  if svIsCost then
    local svCostData = {}
    if svIsHighCost then
      svCostData = colorGroupTable.ConsumeHigh
    else
      svCostData = colorGroupTable.ConsumeLow
    end
    for i = 1, #svCostData do
      local itemId = svCostData[i][1]
      local itemCount = svCostData[i][2]
      if costData[itemId] then
        costData[itemId] = itemCount + costData[itemId]
      else
        costData[itemId] = itemCount
      end
    end
  end
  for itemId, itemCount in pairs(costData) do
    local faceUnlockItemData = {}
    faceUnlockItemData.ItemId = itemId
    faceUnlockItemData.UnlockNum = itemCount
    self.fashionCostData_[#self.fashionCostData_ + 1] = faceUnlockItemData
  end
  table.sort(self.fashionCostData_, comp)
  Z.EventMgr:Dispatch(Z.ConstValue.GM.GMFashionViewPrice, svIsHighCost)
end

function Fashion_dyeingView:calcColorHCost(colorGroupTable, color, costData)
  local hCostData = {}
  local hMin = 0
  for i = 1, #colorGroupTable.ConsumeH do
    local hMax = colorGroupTable.ConsumeH[i][1]
    if hMin <= color.h and hMax >= color.h then
      hCostData = colorGroupTable.ConsumeH[i]
      hMin = hMax
    end
  end
  for i = 2, #hCostData - 1 do
    local itemId = hCostData[i]
    local itemCount = hCostData[i + 1]
    if costData[itemId] then
      costData[itemId] = itemCount + costData[itemId]
    else
      costData[itemId] = itemCount
    end
  end
end

function Fashion_dyeingView:isColorSVHighCost(colorGroupTable, color)
  local sCostMin = 0
  local sCostMax = 100
  local vCostMin = 0
  local vCostMax = 100
  if #colorGroupTable.Zone >= 1 and #colorGroupTable.Zone[1] >= 2 then
    sCostMin = colorGroupTable.Zone[1][1]
    sCostMax = colorGroupTable.Zone[1][2]
  end
  if #colorGroupTable.Zone >= 2 and 2 <= #colorGroupTable.Zone[2] then
    vCostMin = colorGroupTable.Zone[2][1]
    vCostMax = colorGroupTable.Zone[2][2]
  end
  if sCostMin <= color.s and sCostMax >= color.s and vCostMin <= color.v and vCostMax >= color.v then
    return false
  else
    return true
  end
end

function Fashion_dyeingView:onConfirmUnlockFashionColor(colorIndex)
  self.fashionVM_.AsyncUnlockFashionColor(self.fashionId_, colorIndex, self.cancelSource:CreateToken())
  Z.DialogViewDataMgr:CloseDialogView()
end

function Fashion_dyeingView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionColorChange, self.onFashionColorChange, self)
  Z.EventMgr:Add(Z.ConstValue.FashionColorUnlock, self.onFashionColorUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.FashionColorSave, self.onFashionColorSave, self)
end

function Fashion_dyeingView:onFashionColorChange()
  if self.isShowColorRecommend_ then
    return
  end
  self:refreshAreaDefaultColor()
  self:calcCostData()
end

function Fashion_dyeingView:onFashionColorUnlock(fashionId, colorIndex)
  if self.fashionId_ == fashionId and self.colorPalette_:GetCurColorIndex() == colorIndex then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
  end
end

function Fashion_dyeingView:onFashionColorSave(fashionId)
  if self.fashionId_ == fashionId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_unlock, false)
  end
  self:refreshCostData()
end

function Fashion_dyeingView:refreshAreaDefaultColor()
  local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  self.colorPalette_:SetDefaultColor(defaultColor, true)
  local modifiedColor = self:getModifiedColor()
  local color = modifiedColor or defaultColor
  self.colorPalette_:SelectItemByHSVWithoutNotify(color)
end

function Fashion_dyeingView:refreshAreaServerColor()
  local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  if self.viewData.isPreview then
    self.colorPalette_:SetServerColor(defaultColor, true)
  else
    local fashionData = Z.DataMgr.Get("fashion_data")
    local serverColor = fashionData:GetServerFashionColor(self.fashionId_, self.area_)
    serverColor = serverColor or defaultColor
    self.colorPalette_:SetServerColor(serverColor, true)
  end
end

return Fashion_dyeingView
