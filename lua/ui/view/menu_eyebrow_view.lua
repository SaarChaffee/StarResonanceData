local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_eyebrowView = class("Menu_eyebrowView", super)

function Menu_eyebrowView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_eyebrow_sub", "face/face_menu_eyebrow_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadBrow
  self.colorAttr_ = Z.ModelAttr.EModelBrowColor
end

function Menu_eyebrowView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "EyebrowColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelBrowColor)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
  self:refreshSlider()
  self:InitSliderFunc(self.uiBinder.node_angle.slider_sens, function(value)
    self.uiBinder.node_angle.lab_value.text = string.format("%d", math.floor(value + 0.5))
    value = self:CheckValueRang(value, Z.ModelAttr.EModelAnimHeadPinchBrowAngle)
    self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchBrowAngle, (value + 10) / 20)
  end, Z.ModelAttr.EModelAnimHeadPinchBrowAngle, self.angleSlider_)
end

function Menu_eyebrowView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelBrowColor, hsv)
end

function Menu_eyebrowView:refreshSlider()
  local value = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelAnimHeadPinchBrowAngle) * 2 - 1
  value = self:GetValueInRang(value, Z.ModelAttr.EModelAnimHeadPinchBrowAngle)
  self:InitSlider(self.uiBinder.node_angle, value)
end

function Menu_eyebrowView:refreshFaceMenuView()
  super.refreshFaceMenuView(self)
  self:refreshSlider()
end

function Menu_eyebrowView:OnDeActive()
  super.OnDeActive(self)
end

return Menu_eyebrowView
