local super = require("ui.component.loop_list_view_item")
local CommonRewardLoopListItem_2 = class("CommonRewardLoopListItem_2", super)
local itemBinder = require("common.item_binder")

function CommonRewardLoopListItem_2:OnInit()
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonRewardLoopListItem_2:OnRefresh(data)
  local itemData = {
    configId = data.awardId,
    uiBinder = self.uiBinder.binder_item,
    isShowReceive = data.received,
    isSquareItem = true,
    PrevDropType = data.PrevDropType
  }
  itemData.labType, itemData.lab = self.awardPreviewVM_.GetPreviewShowNum(data)
  self.itemBinder_:RefreshByData(itemData)
end

function CommonRewardLoopListItem_2:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return CommonRewardLoopListItem_2
