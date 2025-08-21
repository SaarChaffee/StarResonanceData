local super = require("ui.component.loop_list_view_item")
local HouseLevelAwardLoopItem = class("HouseLevelAwardLoopItem", super)
local item = require("common.item_binder")

function HouseLevelAwardLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function HouseLevelAwardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function HouseLevelAwardLoopItem:OnRefresh(data)
  local awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder.binder_item
  itemData.labType, itemData.lab = awardPreviewVM_.GetPreviewShowNum(data)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = data.received
  itemData.isSquareItem = true
  itemData.PrevDropType = data.PrevDropType
  self.itemClass_:RefreshByData(itemData)
end

return HouseLevelAwardLoopItem
