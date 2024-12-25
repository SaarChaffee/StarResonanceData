local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_eyelashView = class("Menu_eyelashView", super)

function Menu_eyelashView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_eyelash_sub", "face/face_menu_eyelash_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadTexLash
  self.colorAttr_ = Z.ModelAttr.EModelLashColor
end

function Menu_eyelashView:OnActive()
  super.OnActive(self)
  local colorData = self.faceMenuVM_.GetFaceColorDataByOptionEnum(Z.PbEnum("EFaceDataType", "EyelashColor"))
  self.colorPalette_:RefreshPaletteByColorGroupId(colorData.GroupId)
  self.colorPalette_:SetDefaultColor(colorData.HSV)
  local hsv = self.faceVM_.GetFaceOptionByAttrType(Z.ModelAttr.EModelLashColor)
  self.colorPalette_:SelectItemByHSVWithoutNotify(hsv)
end

function Menu_eyelashView:OnColorChange(hsv)
  self.faceVM_.SetFaceOptionByAttrType(Z.ModelAttr.EModelLashColor, hsv)
end

function Menu_eyelashView:OnDeActive()
  super.OnDeActive(self)
end

return Menu_eyelashView
