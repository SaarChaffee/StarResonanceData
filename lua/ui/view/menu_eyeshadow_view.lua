local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_eyeshadowView = class("Menu_eyeshadowView", super)

function Menu_eyeshadowView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_eyeshadow_sub", "face/face_menu_eyeshadow_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadTexEye_Shadow
  self.colorAttr_ = Z.ModelAttr.EModelEyeShadowColor
end

function Menu_eyeshadowView:OnSelectFaceStyle(faceId)
  super.OnSelectFaceStyle(self, faceId)
  self:refreshUIBySelectedStyle(faceId)
end

function Menu_eyeshadowView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "EyeshadowColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelEyeShadowColor)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_eyeshadowView:refreshUIBySelectedStyle(faceId)
  self.uiBinder.cont_palette.Ref.UIComp:SetVisible(0 < faceId)
end

function Menu_eyeshadowView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelEyeShadowColor, hsv)
end

function Menu_eyeshadowView:OnDeActive()
  super.OnDeActive(self)
end

return Menu_eyeshadowView
