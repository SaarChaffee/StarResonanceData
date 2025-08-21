local super = require("ui.ui_subview_base")
local FaceMenuBaseView = class("FaceMenuBaseView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorPaletteHandler = require("ui/component/color_palette/face_color_item_handler")
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local styleItem = require("ui.component.face.style_icon_loop_item")
local unlockItem = require("ui.component.face.face_unlock_loop_item")
local faceRed = require("rednode.face_red")

function FaceMenuBaseView:ctor(parentView, viewConfigKey, assetPath, cacheLv)
  super.ctor(self, viewConfigKey, assetPath, cacheLv, true)
  self.parentView_ = parentView
  self.faceVM_ = Z.VMMgr.GetVM("face")
  self.faceMenuVM_ = Z.VMMgr.GetVM("face_menu")
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.isHideResetBtn_ = false
  self.colorPalette_ = colorPalette.new(self, colorPaletteHandler.new())
end

function FaceMenuBaseView:IsAllowDyeing()
  return true
end

function FaceMenuBaseView:IsAllowColorCopy()
  return true
end

function FaceMenuBaseView:OnColorChange(hsv)
end

function FaceMenuBaseView:ColorStartChangeCB()
  if self.colorAttr_ then
    self.faceVM_.RecordFaceEditorCommand(self.colorAttr_)
  else
    self.faceVM_.RecordFaceEditorListCommand(self.colorAttrList_)
  end
end

function FaceMenuBaseView:OnActive()
  self.parentView_:SetScrollContent(self.uiBinder.Trans)
  self.uiBinder.Trans:SetWidth(Z.IsPCUI and 316 or 424)
  if self:IsAllowDyeing() then
    self.colorPalette_:Init(self.uiBinder.cont_palette, Z.IsPCUI)
    self.colorPalette_:SetColorChangeCB(function(hsv)
      self:OnColorChange(hsv)
    end)
    self.colorPalette_:SetColorStartChangeCB(function()
      self:ColorStartChangeCB()
    end)
    self.colorPalette_:SetColorEndChangeCB(function()
      self.faceVM_.CacheFaceData()
    end)
    self.colorPalette_:SetColorResetCB(function()
      local colorAttr = self.colorAttr_
      if not self.colorAttr_ and self.colorAttrList_ then
        colorAttr = self.colorAttrList_[1]
      end
      if not colorAttr then
        return
      end
      self.faceVM_.ResetToServerData(colorAttr, self.colorAttrIndex_)
      local color = self.faceVM_.GetFaceOptionByAttrType(colorAttr, self.colorAttrIndex_)
      self.colorPalette_:SetServerColor(color)
      self.colorPalette_:ResetSelectHSVWithoutNotify()
    end)
    self.colorPalette_:SetResetBtn(not self.isHideResetBtn_)
  end
  if self:isAllowStyleSelect() then
    self.styleScrollRect_ = loopGridView.new(self, self.uiBinder.node_style.loopscroll_style, styleItem, "face_style_item_tpl", true)
    self.unlockScrollRect_ = loopListView.new(self, self.uiBinder.node_style.loopscroll_unlock, unlockItem, "com_item_square_8")
    self.styleLoopItemData_ = self.faceMenuVM_.GetFaceStyleDataListByAttr(self.styleAttr_, self.styleAttrIndex_)
    self.styleScrollRect_:Init(self.styleLoopItemData_)
    self.unlockScrollRect_:Init({})
    self:refreshFaceIdSelect()
    local faceId = self.faceVM_.GetFaceOptionByAttrType(self.styleAttr_, self.styleAttrIndex_)
    self:OnSelectFaceStyle(faceId)
    if self.uiBinder.btn_unlock then
      self:AddClick(self.uiBinder.btn_unlock, function()
        self:onClickUnlock()
      end)
    end
  end
  self:BindEvents()
end

function FaceMenuBaseView:OnDeActive()
  if self:IsAllowDyeing() then
    self.colorPalette_:UnInit()
  end
  Z.EventMgr:Remove(Z.ConstValue.Face.FaceRefreshMenuView, self.refreshFaceMenuView, self)
  Z.EventMgr:Remove(Z.ConstValue.Face.FaceOptionCanUnlock, self.refreshStyleRed, self)
  if self.styleScrollRect_ then
    self.styleScrollRect_:UnInit()
    self.styleScrollRect_ = nil
  end
  if self.unlockScrollRect_ then
    self.unlockScrollRect_:UnInit()
    self.unlockScrollRect_ = nil
  end
end

function FaceMenuBaseView:InitSlider(commonSlider, type, paramIndex)
  if not type then
    return
  end
  local attrData = self.faceData_.FaceDef.ATTR_TABLE[type]
  paramIndex = paramIndex or 1
  local optionEnum = attrData.OptionList[paramIndex]
  local faceOptionTable = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
  if not faceOptionTable then
    return
  end
  local value = self.faceVM_.GetFaceOptionByAttrType(type, paramIndex)
  local valueMin = -1
  local valueMax = 1
  if faceOptionTable.Range and table.zcount(faceOptionTable.Range) > 0 then
    valueMin = faceOptionTable.Range[1]
    valueMax = faceOptionTable.Range[2]
    value = math.max(valueMin, value)
    value = math.min(valueMax, value)
  end
  local valueProportion = (value - valueMin) / (valueMax - valueMin)
  local showMin = -10
  local showMax = 10
  if faceOptionTable.ShowRang and 0 < table.zcount(faceOptionTable.ShowRang) then
    showMin = faceOptionTable.ShowRang[1]
    showMax = faceOptionTable.ShowRang[2]
  end
  local showValue = valueProportion * (showMax - showMin) + showMin
  commonSlider.slider_sens.maxValue = showMax
  commonSlider.slider_sens.minValue = showMin
  commonSlider.slider_sens:SetValueWithoutNotify(showValue)
  if commonSlider.lab_value then
    commonSlider.lab_value.text = string.format("%d", math.floor(showValue + 0.5))
  end
end

function FaceMenuBaseView:SetFaceAttrValueByShowValue(showValue, attrType, paramIndex)
  if not attrType then
    return
  end
  local attrData = self.faceData_.FaceDef.ATTR_TABLE[attrType]
  paramIndex = paramIndex or 1
  local optionEnum = attrData.OptionList[paramIndex]
  local faceOptionTable = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
  if not faceOptionTable then
    return
  end
  local showMin = -10
  local showMax = 10
  if faceOptionTable.ShowRang and table.zcount(faceOptionTable.ShowRang) > 0 then
    showMin = faceOptionTable.ShowRang[1]
    showMax = faceOptionTable.ShowRang[2]
  end
  local valueProportion = (showValue - showMin) / (showMax - showMin)
  local valueMin = -1
  local valueMax = 1
  if faceOptionTable.Range and 0 < table.zcount(faceOptionTable.Range) then
    valueMin = faceOptionTable.Range[1]
    valueMax = faceOptionTable.Range[2]
  end
  local realValue = (valueMax - valueMin) * valueProportion + valueMin
  self.faceVM_.SetFaceOptionByAttrType(attrType, realValue, paramIndex)
end

function FaceMenuBaseView:OnSliderValueChange(sliderContainer, attrType, value)
  if sliderContainer.lab_value then
    sliderContainer.lab_value.text = string.format("%d", math.floor(value + 0.5))
  end
  self:SetFaceAttrValueByShowValue(value, attrType)
end

function FaceMenuBaseView:OnClickFaceStyle(faceId)
  self.faceVM_.RecordFaceEditorCommand(self.styleAttr_)
  if not self.styleAttr_ then
    return
  end
  self.faceVM_.SetFaceOptionByAttrType(self.styleAttr_, faceId, self.styleAttrIndex_)
  self.faceVM_.CacheFaceData()
end

function FaceMenuBaseView:OnSelectFaceStyle(faceId)
  self:refreshUnlockUIByFaceId(faceId)
end

function FaceMenuBaseView:SelectStyleScrollById(scroll, id)
  scroll:ClearAllSelect()
  for i, styleData in ipairs(scroll.DataList) do
    if styleData.Id == id then
      scroll:MovePanelToItemIndex(i - 1)
      scroll:SelectIndex(i - 1)
      return
    end
  end
end

function FaceMenuBaseView:refreshFaceIdSelect()
  if not self.styleAttr_ then
    return
  end
  local faceId = self.faceVM_.GetFaceOptionByAttrType(self.styleAttr_, self.styleAttrIndex_)
  self:SelectStyleScrollById(self.styleScrollRect_, faceId)
end

function FaceMenuBaseView:isAllowStyleSelect()
  return self.styleAttr_ ~= nil
end

function FaceMenuBaseView:onClickUnlock()
  local faceId = self.faceVM_.GetFaceOptionByAttrType(self.styleAttr_, self.styleAttrIndex_)
  local itemsVM = Z.VMMgr.GetVM("items")
  local dataList = self.faceMenuVM_.GetUnlockItemDataListByFaceId(faceId)
  for _, data in ipairs(dataList) do
    local ownNum = itemsVM.GetItemTotalCount(data.ItemId)
    if ownNum < data.UnlockNum then
      Z.TipsVM.ShowTipsLang(100002)
      return
    end
  end
  local showItemList = {}
  local dataList = self.faceMenuVM_.GetUnlockItemDataListByFaceId(faceId)
  for _, data in ipairs(dataList) do
    local itemData = {
      ItemId = data.ItemId,
      ItemNum = data.UnlockNum
    }
    showItemList[#showItemList + 1] = itemData
  end
  Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("DescFaceUnlockConfirm"), function()
    self:onConfirmUnlockFaceStyle(faceId)
  end, nil, E.DlgPreferencesType.Never, E.DlgPreferencesKeyType.UnlockFaceStyle, showItemList)
end

function FaceMenuBaseView:onConfirmUnlockFaceStyle(faceId)
  self.faceMenuVM_.AsyncUnlockFaceStyle(faceId, self.cancelSource:CreateToken())
end

function FaceMenuBaseView:refreshUnlockUIByFaceId(id, unlock)
  local isUnlocked = self.faceData_:GetFaceStyleItemIsUnlocked(id) or unlock
  self.uiBinder.node_style.Ref:SetVisible(self.uiBinder.node_style.node_unlock, not isUnlocked)
  self.selectedId_ = id
  self:refreshStyleRed()
  if isUnlocked then
    self.unlockScrollRect_:RefreshListView({}, false)
  else
    local dataList = self.faceMenuVM_.GetUnlockItemDataListByFaceId(id)
    self.unlockScrollRect_:RefreshListView(dataList, false)
  end
end

function FaceMenuBaseView:refreshStyleRed()
  if self.uiBinder.node_style and self.uiBinder.node_style.node_unlock_red then
    self.uiBinder.node_style.Ref:SetVisible(self.uiBinder.node_style.node_unlock_red, false)
  end
  if self.selectedId_ and self.selectedId_ > 0 then
    local faceRow = Z.TableMgr.GetRow("FaceTableMgr", self.selectedId_)
    if faceRow then
      local isCheckRed = faceRed.IsShowFaceRedType(faceRow.Type)
      local isUnlocked = self.faceData_:GetFaceStyleItemIsUnlocked(faceRow.Id)
      if isCheckRed and not isUnlocked and 0 < #faceRow.Unlock then
        local isCanUnlock = faceRed.CheckFaceCanUnlock(faceRow.Unlock)
        self.uiBinder.node_style.Ref:SetVisible(self.uiBinder.node_style.node_unlock_red, isCanUnlock)
      end
    end
  end
end

function FaceMenuBaseView:BindEvents()
  if self:isAllowStyleSelect() then
    Z.EventMgr:Add(Z.ConstValue.FaceStyleUnlock, self.onFaceStyleUnlock, self)
  end
  Z.EventMgr:Add(Z.ConstValue.Face.FaceOptionCanUnlock, self.refreshStyleRed, self)
  Z.EventMgr:Add(Z.ConstValue.Face.FaceRefreshMenuView, self.refreshFaceMenuView, self)
end

function FaceMenuBaseView:refreshFaceMenuView()
  if self:isAllowStyleSelect() then
    self:refreshFaceIdSelect()
  end
  local color = self.faceVM_.GetFaceOptionByAttrType(self.colorAttr_, self.colorAttrIndex_)
  self.colorPalette_:RefreshColor(color)
end

function FaceMenuBaseView:onFaceStyleUnlock(faceId)
  local curId = self.faceVM_.GetFaceOptionByAttrType(self.styleAttr_, self.styleAttrIndex_)
  if curId == faceId then
    self:refreshUnlockUIByFaceId(faceId, true)
  end
end

function FaceMenuBaseView:OnRefresh()
end

function FaceMenuBaseView:InitSliderFunc(slider, clickFunc, modelAttr, isDrag)
  slider:AddListener(function(value)
    if not isDrag then
      self.faceVM_.RecordFaceEditorCommand(modelAttr)
      isDrag = true
    end
    clickFunc(value)
  end)
  slider:AddDragEndListener(function(value)
    isDrag = false
    self.faceVM_.CacheFaceData()
  end)
end

return FaceMenuBaseView
