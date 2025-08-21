local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_face_shapeView = class("Menu_face_shapeView", super)

function Menu_face_shapeView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_face_shape_sub", "face/face_menu_face_shape_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadFace
  self.isDrag_ = false
end

function Menu_face_shapeView:OnActive()
  super.OnActive(self)
  self:refreshSlider()
  self:InitSliderFunc(self.uiBinder.node_length.slider_sens, function(value)
    self.uiBinder.node_length.lab_value.text = string.format("%d", math.floor(value + 0.5))
    self:SetFaceAttrValueByShowValue(value, Z.ModelAttr.EModelAnimHeadPinchChinLength)
  end, Z.ModelAttr.EModelAnimHeadPinchChinLength, self.lengthSlider_)
end

function Menu_face_shapeView:refreshSlider()
  self:InitSlider(self.uiBinder.node_length, Z.ModelAttr.EModelAnimHeadPinchChinLength)
end

function Menu_face_shapeView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshSlider()
end

function Menu_face_shapeView:OnDeActive()
  super.OnDeActive(self)
end

function Menu_face_shapeView:IsAllowDyeing()
  return false
end

return Menu_face_shapeView
