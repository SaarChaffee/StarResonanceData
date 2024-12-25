local UI = Z.UI
local super = require("ui.ui_subview_base")
local Pivot_description_subView = class("Pivot_description_subView", super)

function Pivot_description_subView:ctor(parent)
  self.panel = nil
  super.ctor(self, "pivot_description_sub", "pivot/pivot_description_sub", UI.ECacheLv.None)
end

function Pivot_description_subView:OnActive()
  self.panel.Ref:SetPosition(0, 0)
  self.panel.Ref:SetSize(0, 0)
  self.pivotId_ = self.viewData.pivotId
end

function Pivot_description_subView:OnDeActive()
end

function Pivot_description_subView:OnRefresh()
end

return Pivot_description_subView
