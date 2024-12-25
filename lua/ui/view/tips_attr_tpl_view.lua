local UI = Z.UI
local super = require("ui.ui_subview_base")
local Tips_attr_tplView = class("Tips_attr_tplView", super)

function Tips_attr_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "tips_attr_tpl", "common_tips/tips_attr_tpl", UI.ECacheLv.None)
end

function Tips_attr_tplView:OnActive()
end

function Tips_attr_tplView:OnDeActive()
end

function Tips_attr_tplView:OnRefresh()
end

return Tips_attr_tplView
