local UI = Z.UI
local super = require("ui.ui_subview_base")
local Union_schedule_item_tplView = class("Union_schedule_item_tplView", super)

function Union_schedule_item_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_schedule_item_tpl", "union/union_schedule_item_tpl", UI.ECacheLv.None)
end

function Union_schedule_item_tplView:OnActive()
end

function Union_schedule_item_tplView:OnDeActive()
end

function Union_schedule_item_tplView:OnRefresh()
end

return Union_schedule_item_tplView
