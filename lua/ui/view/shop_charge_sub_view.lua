local UI = Z.UI
local super = require("ui.ui_subview_base")
local Shop_charge_subView = class("Shop_charge_subView", super)
local loopListView = require("ui.component.loop_list_view")
local payItem = require("ui.component.shop.pay_loop_item")

function Shop_charge_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "shop_charge_sub", "shop/shop_charge_sub", UI.ECacheLv.None)
end

function Shop_charge_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.loopListView_ = loopListView.new(self, self.uiBinder.node_scrollview, payItem, "shop_charge_item_tpl")
  self.loopListView_:Init({})
  self:RefreshData()
end

function Shop_charge_subView:OnDeActive()
  self.loopListView_:UnInit()
  self.loopListView_ = nil
end

function Shop_charge_subView:OpenBuyPopup(data, index)
  self.viewData.parentView:OpenBuyPopup(data, index)
end

function Shop_charge_subView:RefreshData()
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  local showItemList = self.shopVm_.GetPayTable()
  self.loopListView_:RefreshListView(showItemList, false)
end

return Shop_charge_subView
