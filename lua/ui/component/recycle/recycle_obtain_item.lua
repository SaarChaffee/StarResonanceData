local super = require("ui.component.loop_list_view_item")
local RecycleLoopObtainItem = class("RecycleLoopObtainItem", super)
local itemBinder = require("common.item_binder")

function RecycleLoopObtainItem:OnInit()
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
  self.awardPreviewVM_ = Z.VMMgr.GetVM("awardpreview")
end

function RecycleLoopObtainItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.awardId,
    isShowZero = false,
    isShowOne = true,
    isShowReceive = data.received,
    isSquareItem = true,
    PrevDropType = data.PrevDropType
  }
  itemData.labType, itemData.lab = self.awardPreviewVM_.GetPreviewShowNum(data)
  self.itemBinder_:RefreshByData(itemData)
end

function RecycleLoopObtainItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return RecycleLoopObtainItem
