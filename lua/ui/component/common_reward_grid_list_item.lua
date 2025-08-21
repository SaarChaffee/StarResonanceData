local super = require("ui.component.loop_grid_view_item")
local CommonRewardLoopGridItem = class("CommonRewardLoopGridItem", super)
local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
local itemBinder = require("common.item_binder")

function CommonRewardLoopGridItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonRewardLoopGridItem:OnRefresh(data)
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder.binder_item
  itemData.labType, itemData.lab = awardPreviewVm.GetPreviewShowNum(data)
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isShowReceive = data.received
  itemData.isSquareItem = true
  itemData.PrevDropType = data.PrevDropType
  if self.parent.UIView.press then
    itemData.tipsBindPressCheckComp = self.parent.UIView.press
  end
  self.itemBinder_:RefreshByData(itemData)
end

function CommonRewardLoopGridItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return CommonRewardLoopGridItem
