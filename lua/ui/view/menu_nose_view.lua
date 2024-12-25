local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_noseView = class("Menu_noseView", super)

function Menu_noseView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_nose_sub", "face/face_menu_nose_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadNose
end

function Menu_noseView:OnActive()
  super.OnActive(self)
  self:refreshSlider()
  self:InitSliderFunc(self.uiBinder.node_fluctuation.slider_sens, function(value)
    self.uiBinder.node_fluctuation.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchNoseUD)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchNoseUD, (value + 10) / 20)
  end, Z.ModelAttr.EModelAnimHeadPinchNoseUD, self.fluctuationSlider_)
end

function Menu_noseView:OnDeActive()
  super.OnDeActive(self)
end

function Menu_noseView:IsAllowDyeing()
  return false
end

function Menu_noseView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshSlider()
end

function Menu_noseView:refreshSlider()
  local value = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchNoseUD) * 2 - 1
  value = self:GetValueInRang(value, Z.ModelAttr.EModelAnimHeadPinchNoseUD)
  self:InitSlider(self.uiBinder.node_fluctuation, value)
end

return Menu_noseView
