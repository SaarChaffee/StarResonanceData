local UI = Z.UI
local super = require("ui.ui_subview_base")
local Fashion_dyeingView = class("Fashion_dyeingView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorItemHandler = require("ui/component/color_palette/color_palette_handler")
local loopListView = require("ui.component.loop_list_view")
local unlockItem = require("ui.component.fashion.fashion_unlock_loop_item")
local loopGridView = require("ui.component.loop_grid_view")
local recommendItem = require("ui.component.fashion.fashion_recommend_item")
local recommendAreaColorItem = require("ui.component.fashion.fashion_recommend_area_color_item")

function Fashion_dyeingView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "fashion_dyeing_sub", "fashion/fashion_dyeing_sub", UI.ECacheLv.None, true)
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
  if self.fashionVM_.GetFashionIsUnlock(self.fashionId_) then
    local colorChange, colorReset = self:isColorChange()
    if not colorChange then
      Z.TipsVM.ShowTipsLang(120006)
    elseif colorReset then
      local dialogViewData = {
        dlgType = E.DlgType.YesNo,
        labDesc = Lang("DescFashionColorReset"),
        onConfirm = function()
          self.fashionVM_.AsyncSendFashionColor(self.fashionId_, self.cancelSource:CreateToken())
        end
      }
      Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
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
  if self.fashionVM_.GetFashionIsUnlock(self.fashionId_) then
    local colorChange, colorReset = self:isColorChange()
    if not colorChange then
      Z.TipsVM.ShowTipsLang(120006)
    elseif colorReset then
      local dialogViewData = {
        dlgType = E.DlgType.YesNo,
        labDesc = Lang("DescFashionColorReset"),
        onConfirm = function()
          self.fashionVM_.AsyncSendFashionColor(self.fashionId_, self.cancelSource:CreateToken())
        end
      }
      Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
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
  self.isClearOptionList_ = false
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetWidth(Z.IsPCUI and 316 or 424)
  self.colorPalette_:Init(self.uiBinder.cont_palette, Z.IsPCUI)
  self.colorPalette_:SetColorChangeCB(function(hsv)
    self.hsv_ = hsv
    self.fashionVM_.SetFashionColor(self.fashionId_, self.area_, hsv, false, true)
    self:refreshCostData()
    self.colorPalette_:SetResetColorState(false)
    if self.loopAreaRecommend_ then
      self.loopAreaRecommend_:ClearAllSelect()
    end
  end)
  self.colorPalette_:SetColorStartChangeCB(function()
    if not self.isClearOptionList_ then
      self.isClearOptionList_ = true
      self.fashionVM_.ClearOptionList()
    end
    self.fashionVM_.RecordFashionChange(true)
  end)
  self.colorPalette_:SetColorEndChangeCB(function()
    self.fashionVM_.RecordFashionChange(false)
  end)
  self.unlockScrollRect_ = loopListView.new(self, self.uiBinder.loop_unlock, unlockItem, "com_item_square_8", true)
  self.unlockScrollRect_:Init({})
  self:AddAsyncClick(self.uiBinder.btn_unlock, function()
    self:onClickUnlock()
  end)
  self.colorPalette_:SetColorResetCB(function()
    local fashionData = Z.DataMgr.Get("fashion_data")
    local serverColor = fashionData:GetServerFashionColor(self.fashionId_, self.area_)
    self.fashionVM_.SetFashionColor(self.fashionId_, self.area_, serverColor)
    self:refreshPaletteSelect()
    self.fashionVM_.RefreshWearAttr()
    self:refreshCostData()
  end)
  self:BindEvents()
  
  function self.onContainerDataChange_(container, dirtyKeys)
    self:refreshAreaServerColor()
  end
  
  Z.ContainerMgr.CharSerialize.fashion.Watcher:RegWatcher(self.onContainerDataChange_)
  if self.viewData.isPreview then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, true, "ConfirmStaining", self.ConfirmSaveWithCost, false, self)
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
  self:initColorRecommend()
  self:initPaletteColorGroup()
  self:initAreaTog()
  self:initAreaColorRecommend()
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
  self.loopAreaRecommend_:UnInit()
  self.loopAreaRecommend_ = nil
  self:ClearTips()
  Z.ContainerMgr.CharSerialize.fashion.Watcher:UnregWatcher(self.onContainerDataChange_)
  Z.EventMgr:Remove(Z.ConstValue.Fashion.FashionViewRefresh, self.refreshFashion, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, self.refreshFashionCost, self)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, self.refreshFashionCost, self)
  Z.EventMgr:Dispatch(Z.ConstValue.Fashion.FashionSystemShowCustomBtn, false)
end

function Fashion_dyeingView:refreshFashion()
  self.loopAreaRecommend_:ClearAllSelect()
  self:refreshAreaDefaultColor()
  self:refreshCostData()
end

function Fashion_dyeingView:ClearTips()
  if self.sourceTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.sourceTipsId_)
    self.sourceTipsId_ = nil
  end
end

function Fashion_dyeingView:initColorRecommend()
  self.fashionRow_ = Z.TableMgr.GetTable("FashionTableMgr").GetRow(self.fashionId_)
  if not self.fashionRow_ then
    return
  end
  if self.fashionRow_.Recommend and #self.fashionRow_.Recommend > 0 then
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
        self:refreshAreaDefaultColor()
      end
    end)
    self.loop_recommend_ = loopGridView.new(self, self.uiBinder.loop_recommend, recommendItem, "fashion_color_item", true)
    self.loop_recommend_:Init(self.fashionRow_.Recommend)
    self.loop_recommend_:ClearAllSelect()
    self.uiBinder.tog_recommend.isOn = false
    self.uiBinder.tog_recommend.isOn = true
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_color_select, false)
    self:refreshColorState(false)
  end
end

function Fashion_dyeingView:initAreaColorRecommend()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_grid_color, false)
  if not self.colorConfig_ then
    return
  end
  if table.zcount(self.colorConfig_.Recommend) == 0 then
    return
  end
  local colorRecommend = {
    [1] = {}
  }
  for i = 1, #self.colorConfig_.Recommend do
    colorRecommend[#colorRecommend + 1] = self.colorConfig_.Recommend[i]
  end
  self.loopAreaRecommend_ = loopGridView.new(self, self.uiBinder.loop_grid_color, recommendAreaColorItem, "fashion_color_item", true)
  self.loopAreaRecommend_:Init(colorRecommend)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_grid_color, true)
end

function Fashion_dyeingView:OnSelectAreaColor(colorData)
  if table.zcount(colorData) == 0 then
    self.hsv_ = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  else
    self.hsv_ = {
      h = colorData[1],
      s = colorData[2],
      v = colorData[3]
    }
  end
  self.fashionVM_.SetFashionColor(self.fashionId_, self.area_, self.hsv_)
  if table.zcount(colorData) == 0 then
    self.colorPalette_:SetResetColorState(true)
  else
    self:refreshAreaDefaultColor()
  end
  self:refreshCostData()
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

function Fashion_dyeingView:initPaletteColorGroup()
  if not self.fashionRow_ then
    return
  end
  self.colorPalette_:RefreshPaletteByColorGroupId(self.fashionRow_.ColorGroupId)
  self.colorConfig_ = self.colorPalette_:GetColorConfigRow()
  if self.colorConfig_ and self.colorConfig_.Type == E.EHueModifiedMode.Board then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_unlock, true)
  end
end

function Fashion_dyeingView:initAreaTog()
  self.uiBinder.togs_area:ClearAll()
  self.curAreaList_ = {}
  for i = 1, 5 do
    local widget = self.uiBinder[string.zconcat("tog_area", i)]
    self.uiBinder.Ref:SetVisible(widget, false)
    widget:RemoveAllListeners()
    widget.isOn = false
  end
  if not self.fashionRow_ then
    return
  end
  local selectArea, selectWidget
  for i, area in ipairs(self.fashionRow_.ColorPart) do
    local widget = self.uiBinder[string.zconcat("tog_area", i)]
    self.uiBinder.Ref:SetVisible(widget, true)
    widget.group = self.uiBinder.togs_area
    widget:AddListener(function(isOn)
      if isOn then
        self.area_ = area
        self:refreshPaletteSelect()
        if self.loopAreaRecommend_ then
          self.loopAreaRecommend_:ClearAllSelect()
        end
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
  self:refreshPaletteSelect()
end

function Fashion_dyeingView:refreshPaletteSelect()
  local fashionData = Z.DataMgr.Get("fashion_data")
  local modifiedColor = fashionData:GetColor(self.fashionId_)[self.area_]
  local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  self.colorPalette_:SetDefaultColor(defaultColor, true)
  if modifiedColor then
    self.colorPalette_:SelectItemByHSVWithoutNotify(modifiedColor)
    self.colorPalette_:SetResetColorState(false)
  else
    local fashionData = Z.DataMgr.Get("fashion_data")
    local serverColor = fashionData:GetServerFashionColor(self.fashionId_, self.area_)
    if serverColor then
      self.colorPalette_:SelectItemByHSVWithoutNotify(serverColor)
      self.colorPalette_:SetResetColorState(false)
    else
      self.colorPalette_:SelectItemByHSVWithoutNotify(defaultColor)
      self.colorPalette_:SetResetColorState(true)
    end
  end
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
  if not self.fashionRow_ then
    return false
  end
  local colorGroupTable = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(self.fashionRow_.ColorGroupId)
  if not colorGroupTable then
    return false
  end
  local colorChange = false
  local colorReset = true
  local fashionData = Z.DataMgr.Get("fashion_data")
  for _, area in ipairs(self.fashionRow_.ColorPart) do
    local curColor = fashionData:GetColor(self.fashionId_)[area]
    if curColor then
      local serverColor = fashionData:GetServerFashionColor(self.fashionId_, area)
      if not self:isColorEqual(curColor, serverColor) then
        colorChange = true
        local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, area)
        if not self:isColorEqual(curColor, defaultColor) then
          colorReset = false
        end
      end
    end
  end
  return colorChange, colorReset
end

function Fashion_dyeingView:isColorEqual(first, second)
  if not first or not second then
    return false
  end
  if math.abs(first.h - second.h) < 1.0E-4 and 1.0E-4 > math.abs(first.s - second.s) and 1.0E-4 > math.abs(first.v - second.v) then
    return true
  else
    return false
  end
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
  elseif self.fashionRow_ then
    local groupId = self.fashionRow_.ColorGroupId
    local dataList = self.fashionData_:GetUnlockItemDataListByColorGroupIdAndIndex(groupId, colorIndex)
    self.unlockScrollRect_:RefreshListView(dataList, false)
  end
end

function Fashion_dyeingView:onClickUnlock()
  if not self.fashionVM_.GetFashionIsUnlock(self.fashionId_) then
    Z.TipsVM.ShowTipsLang(120012)
    return
  end
  if not self.fashionRow_ then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local groupId = self.fashionRow_.ColorGroupId
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

function Fashion_dyeingView:refreshFashionCost(item)
  local isHave = false
  for i = 1, #self.fashionCostData_ do
    if item.configId == self.fashionCostData_[i].ItemId then
      isHave = true
      break
    end
  end
  if not isHave then
    return
  end
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
  if not self.fashionRow_ then
    return {}
  end
  local colorGroupTable = Z.TableMgr.GetTable("ColorGroupTableMgr").GetRow(self.fashionRow_.ColorGroupId)
  if not colorGroupTable then
    return {}
  end
  local costData = {}
  local svIsHighCost = false
  local svIsCost = false
  self.fashionCostData_ = {}
  for _, area in ipairs(self.fashionRow_.ColorPart) do
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
  for i = 2, #hCostData - 1, 2 do
    local itemId = hCostData[i]
    local itemCount = hCostData[i + 1]
    if not itemCount then
      break
    end
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
end

function Fashion_dyeingView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.FashionColorChange, self.onFashionColorChange, self)
  Z.EventMgr:Add(Z.ConstValue.FashionColorUnlock, self.onFashionColorUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.FashionColorSave, self.onFashionColorSave, self)
  Z.EventMgr:Add(Z.ConstValue.Fashion.FashionViewRefresh, self.refreshFashion, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, self.refreshFashionCost, self)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, self.refreshFashionCost, self)
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

function Fashion_dyeingView:isColorEquals(color1, color2)
  if not color1 or not color2 then
    return
  end
  return color1.h == color2.h and color1.s == color2.s and color1.v == color2.v
end

function Fashion_dyeingView:refreshAreaDefaultColor()
  if not self.area_ then
    return
  end
  local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  self.colorPalette_:SetDefaultColor(defaultColor, true)
  local modifiedColor = self:getModifiedColor()
  local color = modifiedColor or defaultColor
  self.colorPalette_:SelectItemByHSVWithoutNotify(color)
  if not modifiedColor or self:isColorEquals(defaultColor, modifiedColor) then
    self.colorPalette_:SetResetColorState(true)
  else
    self.colorPalette_:SetResetColorState(false)
  end
end

function Fashion_dyeingView:refreshAreaServerColor()
  if not self.area_ then
    return
  end
  local defaultColor = self.fashionVM_.GetFashionDefaultColorByArea(self.fashionId_, self.area_)
  if self.viewData.isPreview then
    self.colorPalette_:SetServerColor(defaultColor, true)
    self.colorPalette_:SetResetColorState(true)
  else
    local fashionData = Z.DataMgr.Get("fashion_data")
    local serverColor = fashionData:GetServerFashionColor(self.fashionId_, self.area_)
    local color = serverColor or defaultColor
    self.colorPalette_:SetServerColor(color, true)
    local modifiedColor = self:getModifiedColor() or serverColor
    if not modifiedColor or self:isColorEquals(defaultColor, modifiedColor) then
      self.colorPalette_:SetResetColorState(true)
    else
      self.colorPalette_:SetResetColorState(false)
    end
  end
end

return Fashion_dyeingView
