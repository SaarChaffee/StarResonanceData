local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_bodyView = class("Menu_bodyView", super)

function Menu_bodyView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_body_sub", "face/face_menu_body_sub", UI.ECacheLv.None)
  self.colorAttr_ = Z.ModelAttr.EModelSkinColor
end

function Menu_bodyView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "SkinColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  self.colorPalette_:SetModelAttr(self.colorAttr_)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(self.colorAttr_)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
  local EModelPinchHeight = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchHeight)
  local heightSliderValue = math.floor(EModelPinchHeight * 10 + 0.5)
  local faceData = Z.DataMgr.Get("face_data")
  faceData:SetCacheHeightSliderValue(heightSliderValue)
  self.parentView_:refreshCameraFocus(heightSliderValue)
  self:refreshFaceSlider()
  self:InitSliderFunc(self.uiBinder.node_height.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self.changeTimer_ = self.timerMgr:StartFrameTimer(function()
      self.parentView_:refreshCameraFocus(value)
    end, 1, 1)
    self.heighterTimer_ = self.timerMgr:StartFrameTimer(function()
      self:OnSliderValueChange(self.uiBinder.node_height, Z.ModelAttr.EModelPinchHeight, value)
    end, 1, 1)
  end, Z.ModelAttr.EModelPinchHeight, self.heightSlider_)
  self:InitSliderFunc(self.uiBinder.node_arm.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_arm, Z.ModelAttr.EModelPinchArmThickness, value)
  end, Z.ModelAttr.EModelPinchArmThickness, self.armSlider_)
  local chestAttr = self.faceData_.Gender == Z.PbEnum("EGender", "GenderMale") and Z.ModelAttr.EModelPinchChestWidth or Z.ModelAttr.EModelPinchFemaleChest
  self:InitSliderFunc(self.uiBinder.node_chest.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_chest, chestAttr, value)
  end, chestAttr, self.chestSlider_)
  self:InitSliderFunc(self.uiBinder.node_waist.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_waist, Z.ModelAttr.EModelPinchWaistFatThin, value)
  end, Z.ModelAttr.EModelPinchWaistFatThin, self.waistSlider_)
  self:InitSliderFunc(self.uiBinder.node_crotch.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_crotch, Z.ModelAttr.EModelPinchCrotchWidth, value)
  end, Z.ModelAttr.EModelPinchCrotchWidth, self.crotchSlider_)
  self:InitSliderFunc(self.uiBinder.node_thigh.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_thigh, Z.ModelAttr.EModelPinchThighThickness, value)
  end, Z.ModelAttr.EModelPinchThighThickness, self.thighSlider_)
  self:InitSliderFunc(self.uiBinder.node_shank.slider_sens, function(value)
    self.parentView_:SetFocus(false)
    self:OnSliderValueChange(self.uiBinder.node_shank, Z.ModelAttr.EModelPinchCalfThickness, value)
  end, Z.ModelAttr.EModelPinchCalfThickness, self.shankSlider_)
end

function Menu_bodyView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(self.colorAttr_, hsv)
end

function Menu_bodyView:OnDeActive()
  super.OnDeActive(self)
  if self.heighterTimer_ then
    self.timerMgr:StopFrameTimer(self.heighterTimer_)
    self.heighterTimer_ = nil
  end
  if self.changeTimer_ then
    self.timerMgr:StopFrameTimer(self.changeTimer_)
    self.changeTimer_ = nil
  end
  self.uiBinder.node_height.slider_sens:ClearAll()
  self.uiBinder.node_arm.slider_sens:ClearAll()
  self.uiBinder.node_chest.slider_sens:ClearAll()
  self.uiBinder.node_waist.slider_sens:ClearAll()
  self.uiBinder.node_crotch.slider_sens:ClearAll()
  self.uiBinder.node_thigh.slider_sens:ClearAll()
  self.uiBinder.node_shank.slider_sens:ClearAll()
end

function Menu_bodyView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshFaceSlider()
end

function Menu_bodyView:refreshFaceSlider()
  self:InitSlider(self.uiBinder.node_height, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchHeight))
  self:InitSlider(self.uiBinder.node_arm, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchArmThickness))
  local chestAttr = self.faceData_.Gender == Z.PbEnum("EGender", "GenderMale") and Z.ModelAttr.EModelPinchChestWidth or Z.ModelAttr.EModelPinchFemaleChest
  self:InitSlider(self.uiBinder.node_chest, self.faceVM_.GetFaceOptionByAttrType(chestAttr))
  self:InitSlider(self.uiBinder.node_waist, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchWaistFatThin))
  self:InitSlider(self.uiBinder.node_crotch, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchCrotchWidth))
  self:InitSlider(self.uiBinder.node_thigh, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchThighThickness))
  self:InitSlider(self.uiBinder.node_shank, self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelPinchCalfThickness))
end

return Menu_bodyView
