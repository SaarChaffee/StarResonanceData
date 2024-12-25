local super = require("ui.component.loop_list_view_item")
local WeekHuntLeftTowerLoopItem = class("WeekHuntLeftTowerLoopItem", super)

function WeekHuntLeftTowerLoopItem:ctor()
  self.uiBinder = nil
end

function WeekHuntLeftTowerLoopItem:OnInit()
end

function WeekHuntLeftTowerLoopItem:OnRefresh(data)
  self.loopListView:OnItemSizeChanged(self.Index)
end

function WeekHuntLeftTowerLoopItem:OnPointerClick()
end

function WeekHuntLeftTowerLoopItem:OnUnInit()
end

return WeekHuntLeftTowerLoopItem
