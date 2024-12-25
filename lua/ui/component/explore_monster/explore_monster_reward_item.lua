local super = require("ui.component.loop_list_view_item")
local ExploreMonsterRewardItem = class("ExploreMonsterRewardItem", super)
local item = require("common.item_binder")
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")

function ExploreMonsterRewardItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function ExploreMonsterRewardItem:OnRefresh(awardData_)
  if awardData_ == nil then
    return
  end
  local itemData = {}
  itemData.configId = awardData_.awardId
  itemData.uiBinder = self.uiBinder
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(awardData_)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = awardData_.beGet ~= nil and awardData_.beGet
  itemData.isSquareItem = true
  itemData.PrevDropType = awardData_.PrevDropType
  self.itemClass_:RefreshByData(itemData)
end

function ExploreMonsterRewardItem:OnUnInit()
  self.itemClass_:UnInit()
end

function ExploreMonsterRewardItem:OnRecycle()
  self.uiBinder.rimg_icon.enabled = false
end

return ExploreMonsterRewardItem
