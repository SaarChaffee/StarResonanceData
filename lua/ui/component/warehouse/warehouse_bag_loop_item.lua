local super = require("ui.component.loop_grid_view_item")
local WareHouseBagLoopItem = class("WareHouseBagLoopItem", super)
local item = require("common.item_binder")

function WareHouseBagLoopItem:ctor()
end

function WareHouseBagLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.UIView = self.parent.UIView
  self.warehouseVm_ = Z.VMMgr.GetVM("warehouse")
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function WareHouseBagLoopItem:OnRefresh(data)
  self.data_ = data
  self.isWarehouse_ = true
  if data.bindFlag == 0 then
    self.isWarehouse_ = false
  end
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data.configId
  itemData.uuid = data.uuid
  itemData.itemInfo = data
  itemData.isClickOpenTips = false
  self.itemClass_:RefreshByData(itemData)
  self.itemClass_:SetImgLockState(not self.isWarehouse_)
end

function WareHouseBagLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function WareHouseBagLoopItem:OnPointerClick(go, eventData)
  if self.isWarehouse_ then
    self.UIView:OnSelectedBagItem(self.data_, self.uiBinder.Trans)
  else
    Z.TipsVM.ShowTips(122004)
  end
end

function WareHouseBagLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function WareHouseBagLoopItem:OnBeforePlayAnim()
end

return WareHouseBagLoopItem
