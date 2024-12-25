local UI = Z.UI
local super = require("ui.ui_view_base")
local Camera_decorate_controller_itemView = class("Camera_decorate_controller_itemView", super)

function Camera_decorate_controller_itemView:ctor()
  self.panel = nil
  super.ctor(self, "camera_decorate_controller_item")
end

function Camera_decorate_controller_itemView:OnActive()
end

function Camera_decorate_controller_itemView:OnDeActive()
end

function Camera_decorate_controller_itemView:OnRefresh()
end

return Camera_decorate_controller_itemView
