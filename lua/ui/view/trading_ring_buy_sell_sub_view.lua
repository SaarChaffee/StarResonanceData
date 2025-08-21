local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_buy_sell_subView = class("Trading_ring_buy_sell_subView", super)
local loopListView = require("ui.component.loop_list_view")
local tradeRecordItem = require("ui.component.trade.trade_ring_buy_sell_item")

function Trading_ring_buy_sell_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "trading_ring/trading_ring_buy_sell_sub"
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_buy_sell_sub_pc"
  end
  super.ctor(self, "trading_ring_buy_sell_sub", assetPath, UI.ECacheLv.None)
end

function Trading_ring_buy_sell_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  Z.CoroUtil.create_coro_xpcall(function()
    self.tradeVm_:AsyncExchangeRecord(self.cancelSource:CreateToken())
    self:initLoop()
    local nodeState = Z.RedPointMgr.GetRedState(E.RedType.TradeItemPreBuy)
    if nodeState then
      Z.RedPointMgr.AsyncCancelRedDot(E.RedType.TradeItemPreBuy)
      Z.RedPointMgr.UpdateNodeCount(E.RedType.TradeItemPreBuy, 0)
    end
  end)()
end

function Trading_ring_buy_sell_subView:initLoop()
  local path = "trading_ring_buy_sell_item_tpl"
  if Z.IsPCUI then
    path = "trading_ring_buy_sell_item_tpl_pc"
  end
  if self.tradeData_.BuyRecord and #self.tradeData_.BuyRecord > 0 then
    local data = {}
    for _, value in ipairs(self.tradeData_.BuyRecord) do
      local temp = {}
      temp.serverData = value
      temp.isLeft = true
      table.insert(data, temp)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item_buy, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, false)
    self.buyLoopListView_ = loopListView.new(self, self.uiBinder.node_item_buy, tradeRecordItem, path)
    self.buyLoopListView_:Init(data)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item_buy, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, true)
  end
  if self.tradeData_.SellRecord and 0 < #self.tradeData_.SellRecord then
    local data = {}
    for _, value in ipairs(self.tradeData_.SellRecord) do
      local temp = {}
      temp.serverData = value
      temp.isLeft = false
      table.insert(data, temp)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item_sell, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, false)
    self.sellLoopListView_ = loopListView.new(self, self.uiBinder.node_item_sell, tradeRecordItem, path)
    self.sellLoopListView_:Init(data)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_item_sell, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_right, true)
  end
end

function Trading_ring_buy_sell_subView:OnDeActive()
  if self.buyLoopListView_ then
    self.buyLoopListView_:UnInit()
    self.buyLoopListView_ = nil
  end
  if self.sellLoopListView_ then
    self.sellLoopListView_:UnInit()
    self.sellLoopListView_ = nil
  end
end

function Trading_ring_buy_sell_subView:OnRefresh()
end

return Trading_ring_buy_sell_subView
