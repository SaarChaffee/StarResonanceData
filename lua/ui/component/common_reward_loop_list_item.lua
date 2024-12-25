local super = require("ui.component.loop_list_view_item")
local CommonRewardLoopListItem = class("CommonRewardLoopListItem", super)
local itemBinder = require("common.item_binder")

function CommonRewardLoopListItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonRewardLoopListItem:OnRefresh(data)
  local curCount = self.itemsVM_.GetItemTotalCount(data.ItemId)
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.ItemId,
    isSquareItem = true
  })
  self.itemBinder_:SetExpendCount(curCount, data.Num)
end

function CommonRewardLoopListItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return CommonRewardLoopListItem
