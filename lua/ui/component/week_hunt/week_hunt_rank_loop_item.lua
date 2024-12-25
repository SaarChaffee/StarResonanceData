local super = require("ui.component.loop_list_view_item")
local WeekHuntRankLoopItem = class("WeekHuntRankLoopItem", super)
local loopListView = require("ui.component.loop_list_view")
local rewardLoopItem = require("ui.component.week_hunt.week_hunt_reward_loop_item")
local item = require("common.item_binder")

function WeekHuntRankLoopItem:ctor()
  self.uiBinder = nil
end

function WeekHuntRankLoopItem:OnInit()
  self.units_ = {}
  self.rewardListView_ = loopListView.new(self, self.uiBinder.node_loop_reward_item, rewardLoopItem, "com_item_square_7")
  self.rewardListView_:Init({})
end

function WeekHuntRankLoopItem:Reset()
  self:removeUnits()
end

function WeekHuntRankLoopItem:OnRefresh(data)
end

function WeekHuntRankLoopItem:OnPointerClick()
end

function WeekHuntRankLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  if self.rewardListView_ then
    self.rewardListView_:UnInit()
    self.rewardListView_ = nil
  end
end

function WeekHuntRankLoopItem:removeUnits()
  for unitName, v in pairs(self.units_) do
    self.parent.UIView:RemoveUiUnit(unitName)
  end
  self.units_ = {}
end

return WeekHuntRankLoopItem
