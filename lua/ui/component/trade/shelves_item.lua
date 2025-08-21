local super = require("ui.component.loop_list_view_item")
local ShelvesItem = class("ShelvesItem", super)
local item = require("common.item_binder")

function ShelvesItem:ctor()
end

function ShelvesItem:OnInit()
  self.itemClass_ = {}
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  self.itemSellTimer_ = {}
end

function ShelvesItem:OnRefresh(data)
  local itemSellBinder = {
    [1] = self.uiBinder.binder_trading_ring_shelf_item_1,
    [2] = self.uiBinder.binder_trading_ring_shelf_item_2
  }
  for index, uiBinder in ipairs(itemSellBinder) do
    local sellData = data[index].data
    if sellData == nil or sellData.itemInfo == nil then
      self:refreshEmpty(uiBinder, data[index])
    else
      self:refreshTradeItemInfo(uiBinder, sellData, index)
      self:refreshExchangeWithDraw(uiBinder, sellData)
      self.parent.UIView:AddAsyncClick(uiBinder.btn_shelf, function()
        local success = self.tradeVm_:AsyncExchangeTakeItem(sellData.uuid, sellData.itemInfo.configId, self.parent.UIView.cancelSource:CreateToken())
        if success and not self.tradeVm_:CheckAnySellItemTimeOut() then
          Z.RedPointMgr.AsyncCancelRedDot(E.RedType.TradeItemTimeout)
          Z.RedPointMgr.UpdateNodeCount(E.RedType.TradeItemTimeout, 0)
        end
      end)
    end
  end
end

function ShelvesItem:refreshEmpty(uiBinder, data)
  uiBinder.Ref:SetVisible(uiBinder.node_has_item, false)
  uiBinder.Ref:SetVisible(uiBinder.reddot, false)
  uiBinder.Ref:SetVisible(uiBinder.node_click_shelf, data.isSelect)
  uiBinder.Ref:SetVisible(uiBinder.node_idle, not data.isSelect)
  uiBinder.Ref:SetVisible(uiBinder.img_select, data.isSelect)
end

function ShelvesItem:refreshTradeItemInfo(uiBinder, sellData, index)
  uiBinder.Ref:SetVisible(uiBinder.node_has_item, true)
  uiBinder.Ref:SetVisible(uiBinder.node_click_shelf, false)
  uiBinder.Ref:SetVisible(uiBinder.node_idle, false)
  uiBinder.Ref:SetVisible(uiBinder.img_select, false)
  local itemData = {}
  itemData.uiBinder = uiBinder.binder_item
  itemData.configId = sellData.itemInfo.configId
  itemData.labType = E.ItemLabType.Num
  itemData.lab = sellData.itemInfo.count
  itemData.isSquareItem = true
  itemData.itemInfo = sellData.itemInfo
  if self.itemClass_[index] == nil then
    self.itemClass_[index] = item.new(self.parent.UIView)
  end
  self.itemClass_[index]:Init(itemData)
  local itemSellrow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(sellData.itemInfo.configId)
  local sellRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(sellData.itemInfo.configId)
  if sellRow then
    uiBinder.lab_name.text = sellRow.Name
  end
  if itemSellrow then
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemSellrow.Currency)
    if itemRow then
      uiBinder.rimg_sell_icon:SetImage(self.itemVm_.GetItemIcon(itemSellrow.Currency))
    end
  end
  uiBinder.lab_sell_num.text = sellData.price
  if sellData.state == E.EExchangeItemState.ExchangeItemStatePublic then
    uiBinder.Ref:SetVisible(uiBinder.lab_publicity, true)
    uiBinder.Ref:SetVisible(uiBinder.img_time_bg, false)
  else
    uiBinder.Ref:SetVisible(uiBinder.lab_publicity, false)
    if sellData.WithdrawType == E.EExchangeWithDrawType.ExchangeWithDrawTypeAll then
      uiBinder.Ref:SetVisible(uiBinder.img_time_bg, false)
    else
      uiBinder.Ref:SetVisible(uiBinder.img_time_bg, true)
      self:refreshSellItemCountDown(index, uiBinder, sellData.endTime)
    end
  end
end

function ShelvesItem:refreshExchangeWithDraw(uiBinder, sellData)
  uiBinder.Ref:SetVisible(uiBinder.btn_shelf, sellData.WithdrawType ~= E.EExchangeWithDrawType.ExchangeWithDrawTypeAll)
  uiBinder.Ref:SetVisible(uiBinder.img_no_shelf, sellData.WithdrawType == E.EExchangeWithDrawType.ExchangeWithDrawTypeAll)
  uiBinder.Ref:SetVisible(uiBinder.img_can_sell, sellData.WithdrawType == E.EExchangeWithDrawType.ExchangeWithDrawTypeAll)
  uiBinder.Ref:SetVisible(uiBinder.img_can_partially, sellData.WithdrawType == E.EExchangeWithDrawType.ExchangeWithDrawTypePart)
  uiBinder.Ref:SetVisible(uiBinder.reddot, sellData.endTime < Z.TimeTools.Now() / 1000)
end

function ShelvesItem:refreshSellItemCountDown(index, uiBinder, endTime)
  if self.itemSellTimer_[index] then
    self.parent.UIView.timerMgr:StopTimer(self.itemSellTimer_[index])
    self.itemSellTimer_[index] = nil
  end
  local now = Z.TimeTools.Now() / 1000
  if endTime < now then
    uiBinder.Ref:SetVisible(uiBinder.lab_timeout, true)
    uiBinder.Ref:SetVisible(uiBinder.lab_time, false)
  else
    uiBinder.Ref:SetVisible(uiBinder.lab_timeout, false)
    uiBinder.Ref:SetVisible(uiBinder.lab_time, true)
    local delta = math.floor(endTime - now)
    uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(delta, true, true)
    self.itemSellTimer_[index] = self.parent.UIView.timerMgr:StartTimer(function()
      delta = delta - 1
      uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(delta, true, true)
      if delta <= 0 then
        uiBinder.Ref:SetVisible(uiBinder.lab_timeout, true)
        uiBinder.Ref:SetVisible(uiBinder.lab_time, false)
        uiBinder.Ref:SetVisible(uiBinder.reddot, true)
      end
    end, 1, delta + 1)
  end
end

function ShelvesItem:OnSelected(isSelected)
end

function ShelvesItem:OnUnInit()
  for index, value in pairs(self.itemSellTimer_) do
    self.parent.UIView.timerMgr:StopTimer(value)
  end
  self.itemSellTimer_ = {}
  for _, value in ipairs(self.itemClass_) do
    value:UnInit()
  end
end

return ShelvesItem
