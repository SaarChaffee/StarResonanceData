local super = require("ui.component.loop_list_view_item")
local SeasonAchievementRewardItem = class("SeasonAchievementRewardItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function SeasonAchievementRewardItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
end

function SeasonAchievementRewardItem:OnRefresh(data)
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = data.beGet ~= nil and data.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = data.PrevDropType
  self.itemClass_:Init(itemData)
end

function SeasonAchievementRewardItem:OnUnInit()
  self.itemClass_:UnInit()
end

return SeasonAchievementRewardItem
