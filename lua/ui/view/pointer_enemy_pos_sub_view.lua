local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pointer_enemy_pos_subView = class("Pointer_enemy_pos_subView", super)

function Pointer_enemy_pos_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "pointer_enemy_pos_sub", "main/pointer_enemy_pos_sub", UI.ECacheLv.None)
end

function Pointer_enemy_pos_subView:OnActive()
end

function Pointer_enemy_pos_subView:OnDeActive()
end

function Pointer_enemy_pos_subView:OnRefresh()
end

return Pointer_enemy_pos_subView
