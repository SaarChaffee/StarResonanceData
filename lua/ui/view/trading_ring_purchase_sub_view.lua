local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_purchase_subView = class("Trading_ring_purchase_subView", super)

function Trading_ring_purchase_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "trading_ring_purchase_sub", "trading_ring/trading_ring_purchase_sub", UI.ECacheLv.None)
end

function Trading_ring_purchase_subView:OnActive()
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function Trading_ring_purchase_subView:refreshRightBuyInfo()
end

function Trading_ring_purchase_subView:OnDeActive()
end

function Trading_ring_purchase_subView:OnRefresh()
end

return Trading_ring_purchase_subView
