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
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchNoseUD)
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
  self:InitSlider(self.uiBinder.node_fluctuation, Z.ModelAttr.EModelAnimHeadPinchNoseUD)
end

return Menu_noseView
