local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_eyeView = class("Menu_eyeView", super)

function Menu_eyeView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_eye_sub", "face/face_menu_eye_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadEye
end

function Menu_eyeView:OnActive()
  super.OnActive(self)
  self:refreshSlider()
  self:InitSliderFunc(self.uiBinder.node_fluctuation.slider_sens, function(value)
    self.uiBinder.node_fluctuation.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchEyeUD)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeUD, (value + 10) / 20)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeUD, self.fluctuationSlider_)
  self:InitSliderFunc(self.uiBinder.node_angle.slider_sens, function(value)
    self.uiBinder.node_angle.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchEyeAngle)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeAngle, (value + 10) / 20)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeAngle, self.fluctuationAngleSlider_)
  self:InitSliderFunc(self.uiBinder.node_size.slider_sens, function(value)
    self.uiBinder.node_size.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 1)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeSize, value / 10, 1)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeSize, self.pupilSizeSlider_)
  self:InitSliderFunc(self.uiBinder.node_scale.slider_sens, function(value)
    self.uiBinder.node_scale.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 2)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeSize, value / 10, 2)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeSize, self.pupilScaleSlider_)
end

function Menu_eyeView:OnDeActive()
  super.OnDeActive(self)
end

function Menu_eyeView:IsAllowDyeing()
  return false
end

function Menu_eyeView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshSlider()
end

function Menu_eyeView:refreshSlider()
  local eyeUDValue = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeUD) * 2 - 1
  eyeUDValue = self:GetValueInRang(eyeUDValue, Z.ModelAttr.EModelAnimHeadPinchEyeUD)
  self:InitSlider(self.uiBinder.node_fluctuation, eyeUDValue)
  local eyeAngle = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeAngle) * 2 - 1
  eyeAngle = self:GetValueInRang(eyeAngle, Z.ModelAttr.EModelAnimHeadPinchEyeAngle)
  self:InitSlider(self.uiBinder.node_angle, eyeAngle)
  local eyeSize = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeSize, 1)
  eyeSize = self:GetValueInRang(eyeSize, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 1)
  self:InitSlider(self.uiBinder.node_size, eyeSize)
  local eyeScale = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchEyeSize, 2)
  eyeScale = self:GetValueInRang(eyeScale, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 2)
  self:InitSlider(self.uiBinder.node_scale, eyeScale)
end

return Menu_eyeView
