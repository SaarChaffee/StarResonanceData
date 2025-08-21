local super = require("ui.component.loop_list_view_item")
local MonthlyRewardLoopListItem = class("MonthlyRewardLoopListItem", super)
local itemBinder = require("common.item_binder")

function MonthlyRewardLoopListItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function MonthlyRewardLoopListItem:OnRefresh(data)
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.awardId,
    lab = data.awardNum,
    isShowReceive = data.IsShowReceive,
    isSquareItem = true
  })
end

function MonthlyRewardLoopListItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return MonthlyRewardLoopListItem
