local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_beardView = class("Menu_beardView", super)

function Menu_beardView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_beard_sub", "face/face_menu_beard_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadBeard
  self.colorAttr_ = Z.ModelAttr.EModelBeardColor
end

function Menu_beardView:OnSelectFaceStyle(faceId)
  super.OnSelectFaceStyle(self, faceId)
  self:refreshUIBySelectedStyle(faceId)
end

function Menu_beardView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "BeardColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelBeardColor)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_beardView:refreshUIBySelectedStyle(faceId)
  self.uiBinder.cont_palette.Ref.UIComp:SetVisible(0 < faceId)
end

function Menu_beardView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelBeardColor, hsv)
end

function Menu_beardView:OnDeActive()
  super.OnDeActive(self)
end

return Menu_beardView
