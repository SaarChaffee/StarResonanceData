local super = require("ui.component.loop_grid_view_item")
local TradeRingSellBuyItem = class("TradeRingSellBuyItem", super)
local item = require("common.item_binder")

function TradeRingSellBuyItem:ctor()
end

function TradeRingSellBuyItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function TradeRingSellBuyItem:OnRefresh(data)
  self.configId_ = data.configId
  self.itemUuid_ = data.itemUuid
  local package = self.itemVm_.GetPackageInfobyItemId(data.configId)
  self.itemData_ = package.items[data.itemUuid]
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data.configId
  itemData.uuid = data.itemUuid
  itemData.labType = E.ItemLabType.Num
  itemData.itemInfo = self.itemData_
  itemData.isClickOpenTips = false
  self.itemClass_:Init(itemData)
  self.itemClass_:SetSelected(self.IsSelected)
end

function TradeRingSellBuyItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected)
  if isSelected then
    self.parent.UIView:onClickSellItem(self.configId_, self.itemUuid_)
  end
end

function TradeRingSellBuyItem:OnUnInit()
  self.itemClass_:UnInit()
end

return TradeRingSellBuyItem
