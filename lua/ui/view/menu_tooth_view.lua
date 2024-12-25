local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_toothView = class("Menu_toothView", super)

function Menu_toothView:ctor(parentView)
  self.uiBinder = nil
  super.ctor(self, parentView, "face_menu_tooth_sub", "face/face_menu_tooth_sub")
  self.styleAttr_ = Z.ModelAttr.EModelHeadMouth
  self.styleAttrIndex_ = 2
end

function Menu_toothView:OnActive()
  super.OnActive(self)
end

function Menu_toothView:OnDeActive()
  super.OnDeActive(self)
end

function Menu_toothView:IsAllowDyeing()
  return false
end

return Menu_toothView
