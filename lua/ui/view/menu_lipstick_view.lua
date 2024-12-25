local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_lipstickView = class("Menu_lipstickView", super)

function Menu_lipstickView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_lipstick_sub", "face/face_menu_lipstick_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadTexLip
  self.colorAttr_ = Z.ModelAttr.EModelLipColor
end

function Menu_lipstickView:OnSelectFaceStyle(faceId)
  super.OnSelectFaceStyle(self, faceId)
  self:refreshUIBySelectedStyle(faceId)
end

function Menu_lipstickView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "LipstickColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetModelAttr(Z.ModelAttr.EModelLipColor)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelLipColor)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_lipstickView:refreshUIBySelectedStyle(faceId)
  self.uiBinder.cont_palette.Ref.UIComp:SetVisible(0 < faceId)
end

function Menu_lipstickView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelLipColor, hsv)
end

function Menu_lipstickView:OnDeActive()
  super.OnDeActive(self)
end

return Menu_lipstickView
