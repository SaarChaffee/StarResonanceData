local UI = Z.UI
local super = require("ui.view.face_menu_base_view")
local Menu_mouthView = class("Menu_mouthView", super)

function Menu_mouthView:ctor(parentView)
  self.panel = nil
  super.ctor(self, parentView, "face_menu_mouth_sub", "face/face_menu_mouth_sub", UI.ECacheLv.None)
  self.styleAttr_ = Z.ModelAttr.EModelHeadMouth
  self.styleAttrIndex_ = 1
end

function Menu_mouthView:OnActive()
  super.OnActive(self)
end

function Menu_mouthView:OnDeActive()
  super.OnDeActive(self)
end

function Menu_mouthView:IsAllowDyeing()
  return false
end

return Menu_mouthView
