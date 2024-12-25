local super = require("ui.component.loop_list_view_item")
local QuestDetailSeriesRewardItem = class("QuestDetailSeriesRewardItem", super)
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local itemBinder = require("common.item_binder")

function QuestDetailSeriesRewardItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function QuestDetailSeriesRewardItem:OnRefresh(data)
  local itemData = {}
  itemData.configId = data[1]
  itemData.uiBinder = self.uiBinder.binder_item
  itemData.isShowReceive = data[2] == 1
  itemData.isSquareItem = true
  self.itemBinder_:RefreshByData(itemData)
end

function QuestDetailSeriesRewardItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return QuestDetailSeriesRewardItem
