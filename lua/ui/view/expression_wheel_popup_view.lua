local UI = Z.UI
local super = require("ui.ui_view_base")
local Expression_wheel_popupView = class("Expression_wheel_popupView", super)
local wheelSubView = require("ui.view.expression_wheel_sub_view")

function Expression_wheel_popupView:ctor()
  self.panel = nil
  super.ctor(self, "expression_wheel_popup")
  self.wheelSubView_ = wheelSubView.new()
end

function Expression_wheel_popupView:OnActive()
  self.wheelSubView_:Active({}, self.panel.node_sub.Trans)
end

function Expression_wheel_popupView:OnDeActive()
  self.wheelSubView_:DeActive()
end

function Expression_wheel_popupView:OnRefresh()
end

return Expression_wheel_popupView
