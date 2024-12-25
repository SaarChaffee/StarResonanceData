local super = require("ui.component.loop_list_view_item")
local WeekHuntRewardLoopItem = class("WeekHuntRewardLoopItem", super)
local item = require("common.item_binder")

function WeekHuntRewardLoopItem:ctor()
  self.uiBinder = nil
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
end

function WeekHuntRewardLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function WeekHuntRewardLoopItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.awardId,
    isSquareItem = true,
    PrevDropType = data.PrevDropType
  }
  itemData.labType, itemData.lab = self.awardPreviewVm_.GetPreviewShowNum(data)
  self.itemClass_:RefreshByData(itemData)
end

function WeekHuntRewardLoopItem:OnPointerClick()
end

function WeekHuntRewardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return WeekHuntRewardLoopItem
