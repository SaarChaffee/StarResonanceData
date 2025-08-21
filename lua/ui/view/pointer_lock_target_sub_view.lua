local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pointer_lock_target_subView = class("Pointer_lock_target_subView", super)

function Pointer_lock_target_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "pointer_lock_target_sub", "main/pointer_lock_target_sub", UI.ECacheLv.None)
end

function Pointer_lock_target_subView:OnActive()
end

function Pointer_lock_target_subView:OnDeActive()
end

function Pointer_lock_target_subView:OnRefresh()
end

return Pointer_lock_target_subView
