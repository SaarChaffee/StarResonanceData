local UI = Z.UI
local super = require("ui.ui_subview_base")
local Expression_wheel_subView = class("Expression_wheel_subView", super)

function Expression_wheel_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "expression_wheel_sub", "expression/expression_wheel_sub", UI.ECacheLv.None)
end

function Expression_wheel_subView:OnActive()
  function self.panel.node_wheel.ZWheelDisc.OnWheelDiscChanged(isTrigger, areaIndex)
    self:onWheelDiscChanged(isTrigger, areaIndex)
  end
  
  function self.panel.node_wheel.ZWheelDisc.OnWheelDiscSelected(isTrigger, areaIndex)
    self:onWheelDiscSelected(isTrigger, areaIndex)
  end
end

function Expression_wheel_subView:OnDeActive()
  self.panel.node_wheel.ZWheelDisc.OnWheelDiscChanged = nil
  self.panel.node_wheel.ZWheelDisc.OnWheelDiscSelected = nil
end

function Expression_wheel_subView:OnRefresh()
end

function Expression_wheel_subView:onWheelDiscChanged(isTrigger, areaIndex)
  for i = 1, 8 do
    self.panel["cont_group_" .. i].node_on:SetVisible(isTrigger and areaIndex == i)
  end
end

function Expression_wheel_subView:onWheelDiscSelected(isTrigger, areaIndex)
end

return Expression_wheel_subView
