local super = require("ui.ui_subview_base")
local FaceMenuBaseView = class("FaceMenuBaseView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorPaletteHandler = require("ui/component/color_palette/face_color_item_handler")
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local styleItem = require("ui.component.face.style_icon_loop_item")
local unlockItem = require("ui.component.face.face_unlock_loop_item")

function FaceMenuBaseView:ctor(parentView, viewConfigKey, assetPath, cacheLv)
  super.ctor(self, viewConfigKey, assetPath, cacheLv)
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
  if self:IsAllowDyeing() then
    self.colorPalette_:Init(self.uiBinder.cont_palette)
    self.colorPalette_:SetColorChangeCB(function(hsv)
      self:OnColorChange(hsv)
    end)
    self.colorPalette_:SetColorStartChangeCB(function()
      self:ColorStartChangeCB()
    end)
    self.colorPalette_:SetColorResetCB(function()
      if not self.colorAttr_ then
        return
      end
      self.faceVM_.ResetToServerData(self.colorAttr_, self.colorAttrIndex_)
      local color = self.faceVM_.GetFaceOptionByAttrType(self.colorAttr_, self.colorAttrIndex_)
      self.colorPalette_:SetServerColor(color)
      self.colorPalette_:ResetSelectHSVWithoutNotify()
    end)
    self.colorPalette_:SetResetBtn(not self.isHideResetBtn_)
  end
  if self:isAllowStyleSelect() then
    self.styleScrollRect_ = loopGridView.new(self, self.uiBinder.node_style.loopscroll_style, styleItem, "face_style_item_tpl")
    self.unlockScrollRect_ = loopListView.new(self, self.uiBinder.node_style.loopscroll_unlock, unlockItem, "com_item_square_8")
    self.styleScrollRect_:Init(self.faceMenuVM_.GetFaceStyleDataListByAttr(self.styleAttr_, self.styleAttrIndex_))
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
  if self.styleScrollRect_ then
    self.styleScrollRect_:UnInit()
    self.styleScrollRect_ = nil
  end
  if self.unlockScrollRect_ then
    self.unlockScrollRect_:UnInit()
    self.unlockScrollRect_ = nil
  end
end

function FaceMenuBaseView:InitSlider(commonSlider, value, max, min, scale)
  local valueMin = -1
  local valueMax = 1
  min = min or 10 * valueMin
  max = max or 10 * valueMax
  commonSlider.slider_sens.maxValue = max
  commonSlider.slider_sens.minValue = min
  self:SetSliderValueWithoutNotify(commonSlider, value, scale)
end

function FaceMenuBaseView:SetSliderValueWithoutNotify(commonSlider, value, scale)
  scale = scale or 10
  value = value * scale
  commonSlider.slider_sens:SetValueWithoutNotify(value)
  if commonSlider.lab_value then
    commonSlider.lab_value.text = string.format("%d", math.floor(value + 0.5))
  end
end

function FaceMenuBaseView:GetValueInRang(value, attrType, paramIndex, max, min)
  if attrType then
    local attrData = self.faceData_.FaceDef.ATTR_TABLE[attrType]
    paramIndex = paramIndex or 1
    local optionEnum = attrData.OptionList[paramIndex]
    local faceOptionTable = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
    if faceOptionTable and faceOptionTable.Range and table.zcount(faceOptionTable.Range) > 0 then
      local valueMin = faceOptionTable.Range[1]
      local valueMax = faceOptionTable.Range[2]
      value = math.max(valueMin, value)
      value = math.min(valueMax, value)
      min = min or -1
      max = max or 1
      value = (value - valueMin) / (valueMax - valueMin) * (max - min) + min
    end
  end
  return value
end

function FaceMenuBaseView:CheckValueRang(value, attrType, paramIndex, max, min)
  if attrType then
    local attrData = self.faceData_.FaceDef.ATTR_TABLE[attrType]
    paramIndex = paramIndex or 1
    local optionEnum = attrData.OptionList[paramIndex]
    local faceOptionTable = Z.TableMgr.GetTable("FaceOptionTableMgr").GetRow(optionEnum)
    if faceOptionTable and faceOptionTable.Range and table.zcount(faceOptionTable.Range) > 0 then
      local valueMin = faceOptionTable.Range[1] * 10
      local valueMax = faceOptionTable.Range[2] * 10
      min = min or -10
      max = max or 10
      value = (valueMax - valueMin) * (value - min) / (max - min) + valueMin
    end
  end
  return value
end

function FaceMenuBaseView:OnSliderValueChange(sliderContainer, attrType, value)
  if sliderContainer.lab_value then
    sliderContainer.lab_value.text = string.format("%d", math.floor(value + 0.5))
  end
  value = self:CheckValueRang(value, attrType)
  self.faceVM_.SetFaceOptionByAttrType(attrType, value / 10)
end

function FaceMenuBaseView:OnClickFaceStyle(faceId)
  self.faceVM_.RecordFaceEditorCommand(self.styleAttr_)
  if not self.styleAttr_ then
    return
  end
  self.faceVM_.SetFaceOptionByAttrType(self.styleAttr_, faceId, self.styleAttrIndex_)
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
  if isUnlocked then
    self.unlockScrollRect_:RefreshListView({}, false)
  else
    local dataList = self.faceMenuVM_.GetUnlockItemDataListByFaceId(id)
    self.unlockScrollRect_:RefreshListView(dataList, false)
  end
end

function FaceMenuBaseView:BindEvents()
  if self:isAllowStyleSelect() then
    Z.EventMgr:Add(Z.ConstValue.FaceStyleUnlock, self.onFaceStyleUnlock, self)
  end
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
  end)
end

return FaceMenuBaseView
