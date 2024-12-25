local UI = Z.UI
local super = require("ui.ui_view_base")
local Pivot_reward_emptyView = class("Pivot_reward_emptyView", super)
local mapPivotView = require("ui.view.pivot_reward_sub_view")

function Pivot_reward_emptyView:ctor()
  self.uiBinder = nil
  super.ctor(self, "pivot_reward_empty")
  self.mapPivotView_ = mapPivotView.new()
end

function Pivot_reward_emptyView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.mapPivotView_ = mapPivotView.new()
  self.mapPivotView_:Active(self.viewData, self.uiBinder.cont_panel)
end

function Pivot_reward_emptyView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.mapPivotView_:DeActive()
end

function Pivot_reward_emptyView:OnRefresh()
end

return Pivot_reward_emptyView
