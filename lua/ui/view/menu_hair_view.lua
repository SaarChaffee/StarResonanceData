local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_hairView = class("Menu_hairView", super)

function Menu_hairView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_hair_sub", "face/face_menu_hair_sub", UI.ECacheLv.None)
end

function Menu_hairView:OnActive()
  if self:getIsWholeHair() then
    self.styleAttr_ = Z.ModelAttr.EModelHairWearId
  else
    self.styleAttr_ = Z.ModelAttr.EModelFrontHair
  end
  super.OnActive(self)
  self:initHairTypeTog()
  self:initHairPartTog()
  self:refreshHairGradientRange()
  self:initColor()
  self:onInitRed()
end

function Menu_hairView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHairWhole, self, self.uiBinder.tog_whole.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHairCustom, self, self.uiBinder.tog_custom.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHairCustomFront, self, self.uiBinder.node_front_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHairCustomBack, self, self.uiBinder.node_back_red)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FaceEditorHairCustomDull, self, self.uiBinder.node_dull_red)
end

function Menu_hairView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHairWhole)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHairCustom)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHairCustomFront)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHairCustomBack)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FaceEditorHairCustomDull)
end

function Menu_hairView:refreshStyleScroll(attrType)
  self.styleAttr_ = attrType
  self.styleScrollRect_:RefreshListView(self.faceMenuVM_.GetFaceStyleDataListByAttr(self.styleAttr_), false)
  self:SelectStyleScrollById(self.styleScrollRect_, self.faceVM_.GetFaceOptionByAttrType(self.styleAttr_))
end

function Menu_hairView:initHairTypeTog()
  local isWholeHair = self:getIsWholeHair()
  self.uiBinder.tog_whole.tog_item:RemoveAllListeners()
  self.uiBinder.tog_custom.tog_item:RemoveAllListeners()
  self.uiBinder.tog_whole.tog_item:SetIsOnWithoutCallBack(isWholeHair)
  self.uiBinder.tog_custom.tog_item:SetIsOnWithoutCallBack(not isWholeHair)
  self.uiBinder.tog_whole.tog_item.group = self.uiBinder.togs_hair_type
  self.uiBinder.tog_custom.tog_item.group = self.uiBinder.togs_hair_type
  self.uiBinder.tog_whole.tog_item:AddListener(function(isOn)
    if not self.uiBinder or not self.styleScrollRect_ then
      return
    end
    if isOn then
      self:refreshStyleScroll(Z.ModelAttr.EModelHairWearId)
      Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHairWhole)
    end
  end)
  self.uiBinder.tog_custom.tog_item:AddListener(function(isOn)
    if not self.uiBinder then
      return
    end
    self:refreshPartTogGroupState(isOn)
    if isOn then
      self.uiBinder.tog_front_hair.isOn = true
      Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHairCustom)
    else
      self.uiBinder.togs_part:SetAllTogglesOff()
    end
  end)
  if isWholeHair then
    self:refreshStyleScroll(Z.ModelAttr.EModelHairWearId)
  end
  self:refreshPartTogGroupState(not isWholeHair)
end

function Menu_hairView:initHairPartTog()
  local isWholeHair = self:getIsWholeHair()
  self:refreshPartTogGroupState(not isWholeHair)
  local nameToOption = {
    tog_front_hair = Z.ModelAttr.EModelFrontHair,
    tog_back_hair = Z.ModelAttr.EModelBackHair,
    tog_dull_hair = Z.ModelAttr.EModelDullHair
  }
  for nodeName, attrType in pairs(nameToOption) do
    local togNode = self.uiBinder[nodeName]
    togNode:RemoveAllListeners()
    if isWholeHair then
      togNode:SetIsOnWithoutCallBack(false)
    else
      togNode:SetIsOnWithoutCallBack(attrType == Z.ModelAttr.EModelFrontHair)
    end
    togNode.group = self.uiBinder.togs_part
    togNode:AddListener(function(isOn)
      if isOn then
        self:refreshStyleScroll(attrType)
        self:clickRed()
      end
    end)
  end
  if not isWholeHair then
    self:refreshStyleScroll(Z.ModelAttr.EModelFrontHair)
  end
end

function Menu_hairView:clickRed(attrType)
  if attrType == Z.ModelAttr.EModelFrontHair then
    Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHairCustomFront)
  elseif attrType == Z.ModelAttr.EModelBackHair then
    Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHairCustomBack)
  elseif attrType == Z.ModelAttr.EModelDullHair then
    Z.RedPointMgr.OnClickRedDot(E.RedType.FaceEditorHairCustomDull)
  end
end

function Menu_hairView:getIsWholeHair()
  return self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelHairWearId) > 0
end

function Menu_hairView:refreshPartTogGroupState(isOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.togs_part, isOn)
  self.uiBinder.togs_part.AllowSwitchOff = not isOn
end

function Menu_hairView:refreshHairGradientRange()
  local realRange = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelCHairGradient, self.faceData_.FaceDef.EAttrParamHairGradient.Range)
  realRange = realRange - 1
  local uiValue = self:GetValueInRang(realRange, Z.ModelAttr.EModelCHairGradient, self.faceData_.FaceDef.EAttrParamHairGradient.Range, 1, 0)
  self:InitSlider(self.uiBinder.node_rang, uiValue, 10, 0)
end

function Menu_hairView:setRangValue(value)
  local realValue = self:CheckValueRang(value, Z.ModelAttr.EModelCHairGradient, self.faceData_.FaceDef.EAttrParamHairGradient.Range, 10, 0)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelCHairGradient, realValue / 10 + 1, self.faceData_.FaceDef.EAttrParamHairGradient.Range)
  self.uiBinder.node_rang.lab_value.text = string.format("%d", math.floor(value + 0.5))
end

function Menu_hairView:initColor()
  self.uiBinder.tog_color.group = self.uiBinder.togs_tab
  self.uiBinder.tog_gradual.group = self.uiBinder.togs_tab
  self.uiBinder.tog_highlights.group = self.uiBinder.togs_tab
  self.uiBinder.tog_highlights1.group = self.uiBinder.togs_highlights
  self.uiBinder.tog_highlights2.group = self.uiBinder.togs_highlights
  self:InitSliderFunc(self.uiBinder.node_rang.slider_sens, function(value)
    self:setRangValue(value)
  end, Z.ModelAttr.EModelCHairGradient, self.rangeSlider_)
  self.uiBinder.tog_color:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_rang.Ref, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_open, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_hair_highlights_tab, false)
      self.colorEnum_ = Z.PbEnum("EFaceDataType", "HairColorBase")
      self.colorAttr_ = Z.ModelAttr.EModelCMountHairColor
      self.colorAttrIndex_ = 1
      self.colorOpenEnum_ = nil
      self:refreshHairHighlights()
    end
  end)
  self.uiBinder.tog_gradual:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_rang.Ref, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_open, true)
      self.uiBinder.lab_title.text = Lang("OpenHairGradual")
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_hair_highlights_tab, false)
      self.colorEnum_ = Z.PbEnum("EFaceDataType", "HairGradualColor")
      self.colorAttr_ = Z.ModelAttr.EModelCHairGradient
      self.colorAttrIndex_ = 3
      self.colorOpenEnum_ = Z.PbEnum("EFaceDataType", "HairIsGradual")
      self.uiBinder.node_rang.slider_sens.interactable = self.faceData_:GetFaceOptionValue(self.colorOpenEnum_)
      self:refreshNodeOpen()
      self:refreshHairHighlights()
    end
  end)
  self.uiBinder.tog_highlights:AddListener(function(isOn)
    if isOn then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_rang.Ref, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_open, true)
      self.uiBinder.lab_title.text = Lang("OpenHairHighlights")
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_hair_highlights_tab, true)
      self.colorAttr_ = Z.ModelAttr.EModelCMountHairColor
      if self.uiBinder.tog_highlights1.isOn then
        self:refreshHighlights1(true)
      else
        self.uiBinder.tog_highlights1.isOn = true
      end
    end
  end)
  self.uiBinder.node_open:AddListener(function(isOn)
    self.faceVM_.RecordFaceEditorCommand(self.colorAttr_)
    self.colorPalette_:SetPaletteInteractable(isOn)
    self.uiBinder.node_rang.slider_sens.interactable = isOn
    local curIsOn = self.faceData_:GetFaceOptionValue(self.colorOpenEnum_)
    if curIsOn ~= isOn then
      self.faceData_:SetFaceOptionValue(self.colorOpenEnum_, isOn)
      local attrVM = Z.VMMgr.GetVM("face_attr")
      attrVM.UpdateFaceAttr(self.colorAttr_)
    end
  end)
  self.uiBinder.tog_highlights1:AddListener(function(isOn)
    self:refreshHighlights1(isOn)
  end)
  self.uiBinder.tog_highlights2:AddListener(function(isOn)
    if self.uiBinder.tog_highlights.isOn and isOn then
      self.colorEnum_ = Z.PbEnum("EFaceDataType", "HairTwoHighlightsColor")
      self.colorAttrIndex_ = 3
      self.colorOpenEnum_ = Z.PbEnum("EFaceDataType", "HairTwoIsHighlights")
      self:refreshHairHighlights()
      self:refreshNodeOpen()
    end
  end)
  self.uiBinder.tog_color.isOn = false
  self.uiBinder.tog_color.isOn = true
end

function Menu_hairView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(self.colorAttr_, hsv, self.colorAttrIndex_)
end

function Menu_hairView:OnDeActive()
  self:clearRed()
  super.OnDeActive(self)
end

function Menu_hairView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshHairGradientRange()
  self:refreshNodeOpen()
end

function Menu_hairView:refreshHairHighlights()
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(self.colorEnum_)
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(self.colorAttr_, self.colorAttrIndex_)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_hairView:refreshNodeOpen()
  if not self.colorOpenEnum_ then
    return
  end
  self.uiBinder.node_open:SetIsOnWithoutNotify(self.faceData_:GetFaceOptionValue(self.colorOpenEnum_))
end

function Menu_hairView:refreshHighlights1(isOn)
  if self.uiBinder.tog_highlights.isOn and isOn then
    self.colorEnum_ = Z.PbEnum("EFaceDataType", "HairOneHighlightsColor")
    self.colorAttrIndex_ = 2
    self.colorOpenEnum_ = Z.PbEnum("EFaceDataType", "HairOneIsHighlights")
    self:refreshHairHighlights()
    self:refreshNodeOpen()
  end
end

function Menu_hairView:OnClickFaceStyle(faceId)
  self.faceVM_.RecordFaceEditorListCommand({
    [1] = Z.ModelAttr.EModelFrontHair,
    [2] = Z.ModelAttr.EModelBackHair,
    [3] = Z.ModelAttr.EModelDullHair,
    [4] = Z.ModelAttr.EModelHairWearId
  })
  self.faceVM_.SetFaceOptionByAttrType(self.styleAttr_, faceId)
end

return Menu_hairView
