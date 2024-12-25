local super = require("ui.component.loop_grid_view_item")
local WareHouseLoopItem = class("WareHouseLoopItem", super)
local item = require("common.item_binder")

function WareHouseLoopItem:ctor()
end

function WareHouseLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.UIView = self.parent.UIView
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.charId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function WareHouseLoopItem:OnRefresh(data)
  self.data_ = data
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data.itemInfo.configId
  itemData.uuid = data.itemInfo.uuid
  itemData.itemInfo = data.itemInfo
  itemData.isClickOpenTips = false
  self.itemClass_:RefreshByData(itemData)
  local isSelfItem = data.ownerCharId == self.charId_
  self.itemClass_:SetNodeVisible(self.uiBinder.img_use, isSelfItem)
end

function WareHouseLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function WareHouseLoopItem:OnPointerClick(go, eventData)
  self.UIView:OnSelectedWarehouseItem(self.data_, self.uiBinder.Trans)
end

function WareHouseLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function WareHouseLoopItem:OnBeforePlayAnim()
end

return WareHouseLoopItem
