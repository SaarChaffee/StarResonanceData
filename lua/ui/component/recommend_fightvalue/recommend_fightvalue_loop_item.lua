local super = require("ui.component.loop_list_view_item")
local RecommendFightValueLoopItem = class("RecommendFightValueLoopItem", super)
local itemBinder = require("common.item_binder")

function RecommendFightValueLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function RecommendFightValueLoopItem:OnRefresh(data)
  local curCount = self.itemsVM_.GetItemTotalCount(data.ItemId)
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.ItemId
  })
  self.itemBinder_:SetLab(curCount)
end

function RecommendFightValueLoopItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return RecommendFightValueLoopItem
