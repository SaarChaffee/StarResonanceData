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
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchEyeUD)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeUD, self.fluctuationSlider_)
  self:InitSliderFunc(self.uiBinder.node_angle.slider_sens, function(value)
    self.uiBinder.node_angle.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchEyeAngle)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeAngle, self.fluctuationAngleSlider_)
  self:InitSliderFunc(self.uiBinder.node_size.slider_sens, function(value)
    self.uiBinder.node_size.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 1)
  end, Z.ModelAttr.EModelAnimHeadPinchEyeSize, self.pupilSizeSlider_)
  self:InitSliderFunc(self.uiBinder.node_scale.slider_sens, function(value)
    self.uiBinder.node_scale.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 2)
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
  self:InitSlider(self.uiBinder.node_fluctuation, Z.ModelAttr.EModelAnimHeadPinchEyeUD)
  self:InitSlider(self.uiBinder.node_angle, Z.ModelAttr.EModelAnimHeadPinchEyeAngle)
  self:InitSlider(self.uiBinder.node_size, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 1)
  self:InitSlider(self.uiBinder.node_scale, Z.ModelAttr.EModelAnimHeadPinchEyeSize, 2)
end

return Menu_eyeView
