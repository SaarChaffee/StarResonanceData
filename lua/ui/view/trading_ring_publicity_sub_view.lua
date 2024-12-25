local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_publicity_subView = class("Trading_ring_publicity_subView", super)
local TradeNoticeItem = require("ui.component.trade.trade_ring_public_notice_item")
local TradeItem = require("ui.component.trade.trade_ring_public_shop_item")
local loopGridView = require("ui.component.loop_grid_view")

function Trading_ring_publicity_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "trading_ring/trading_ring_publicity_sub"
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_publicity_sub_pc"
  end
  super.ctor(self, "trading_ring_publicity_sub", assetPath, UI.ECacheLv.None)
end

function Trading_ring_publicity_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  Z.CoroUtil.create_coro_xpcall(function()
    self.tradeVm_:ExchangeNoticePreBuy(self.cancelSource:CreateToken())
    self:initLoop()
  end)()
end

function Trading_ring_publicity_subView:initLoop()
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, false)
  local data = {}
  for _, value in pairs(self.tradeData_.PlayerPrebuyItemDict) do
    table.insert(data, value)
  end
  if data == nil or #data == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, true)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_empty, false)
  if self.itemLoopListView_ == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, true)
    local path = "trading_ring_item_tpl"
    if Z.IsPCUI then
      path = "trading_ring_item_tpl_pc"
    end
    self.itemLoopListView_ = loopGridView.new(self, self.uiBinder.scrollview_item, TradeItem, path)
    self.itemLoopListView_:Init(data)
  else
    self.itemLoopListView_:RefreshListView(data)
  end
end

function Trading_ring_publicity_subView:OnItemSelect(configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, false)
  if self.tradeData_.PlayerPrebuyItemList == nil or #self.tradeData_.PlayerPrebuyItemList == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, false)
    return
  end
  local data = {}
  for index, value in ipairs(self.tradeData_.PlayerPrebuyItemList) do
    if value.itemInfo.configId == configId then
      table.insert(data, value)
    end
  end
  table.sort(data, function(a, b)
    return a.noticeTime > b.noticeTime
  end)
  if self.sellLoopListView_ == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview, true)
    local path = "trading_ring_publicity_item_tpl"
    if Z.IsPCUI then
      path = "trading_ring_publicity_item_tpl_pc"
    end
    self.sellLoopListView_ = loopGridView.new(self, self.uiBinder.scrollview, TradeNoticeItem, path)
    self.sellLoopListView_:Init(data)
  else
    self.sellLoopListView_:RefreshListView(data)
  end
end

function Trading_ring_publicity_subView:OnDeActive()
  if self.itemLoopListView_ then
    self.itemLoopListView_:UnInit()
    self.itemLoopListView_ = nil
  end
  if self.sellLoopListView_ then
    self.sellLoopListView_:UnInit()
    self.sellLoopListView_ = nil
  end
end

function Trading_ring_publicity_subView:OnRefresh()
end

return Trading_ring_publicity_subView
