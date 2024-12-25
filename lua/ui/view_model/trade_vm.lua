local TradeVM = {}

function TradeVM.OpenTradeMainView(configId, firstType, subType, itemUuid)
  configId = configId and tonumber(configId)
  if firstType ~= nil and type(firstType) == "string" then
    firstType = tonumber(firstType)
  end
  if subType ~= nil and type(subType) == "string" then
    subType = tonumber(subType)
  end
  local viewData = {
    type = firstType,
    subType = subType,
    configId = configId,
    itemUuid = itemUuid
  }
  Z.UIMgr:OpenView("trading_ring_main", viewData)
end

function TradeVM:CloseTradeMainView()
  Z.UIMgr:CloseView("trading_ring_main")
end

function TradeVM:CheckItemIsPreOrder(configId, guid)
  local tradeData = Z.DataMgr.Get("trade_data")
  if tradeData.PlayerPrebuyItemList == nil then
    return false
  end
  for _, value in pairs(tradeData.PlayerPrebuyItemList) do
    if value.guid == guid then
      return true
    end
  end
  return false
end

function TradeVM:CheckPreOrderMaxNum()
  local tradeData = Z.DataMgr.Get("trade_data")
  local data = tradeData.PlayerPrebuyItemList
  return table.zcount(data) >= tradeData.PreSaleNum
end

function TradeVM:AsyncExchangeList(type, subType, cancelToken)
  local tradeData = Z.DataMgr.Get("trade_data")
  if tradeData.ExchangeItemCD[type] and tradeData.ExchangeItemCD[type][subType] and tradeData.ExchangeItemCD[type][subType] > 0 then
    return true
  end
  local worldProxy = require("zproxy.world_proxy")
  local exchangeListRequest = {type = type, subType = subType}
  local ret = worldProxy.ExchangeList(exchangeListRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  tradeData:CacheExchangeItemList(type, subType, ret.items)
  return true
end

function TradeVM:AsyncExchangeItem(configId, filter, nextPage, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local tradeData = Z.DataMgr.Get("trade_data")
  if not nextPage then
    tradeData:SetTradeCurPageIndex(0)
  else
    tradeData:SetTradeCurPageIndex(tradeData.CurPageIndex + 1)
  end
  local exchangeItemRequest = {
    configId = configId,
    filter = filter,
    page = tradeData.CurPageIndex
  }
  local ret = worldProxy.GetExchangeItem(exchangeItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  tradeData:CacheExchangePriceItemList(configId, ret.items, nextPage)
  return true
end

function TradeVM:AsyncExchangeSellItem(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangeSellItemRequest = {}
  local ret = worldProxy.ExchangeSellItem(exchangeSellItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CacheExchangeSellItemData(ret.items, ret.withDrawItem, ret.limit, ret.rate)
  return true
end

function TradeVM:AsyncExchangeRecord(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangeRecordRequest = {}
  local ret = worldProxy.ExchangeRecord(exchangeRecordRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CacheRecordItemData(ret.buyRecord, ret.sellRecord)
  return true
end

function TradeVM:AsyncExchangeBuyItem(uuid, configId, num, price, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangeBuyItemRequest = {
    uuid = tostring(uuid),
    configId = configId,
    num = num,
    price = price
  }
  local ret = worldProxy.ExchangeBuyItem(exchangeBuyItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:SetCacheTradeSellItemNum(configId, num)
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ExchangeBuyItemSuccess)
  return true
end

function TradeVM:AsyncExchangePutItem(uuid, num, step, isPublic, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangePutItemRequest = {
    uuid = uuid,
    num = num,
    step = step,
    isPublic = isPublic
  }
  local ret = worldProxy.ExchangePutItem(exchangePutItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.TipsVM.ShowTips(1000801)
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ExchangePutItemSuccess)
  return true
end

function TradeVM:AsyncExchangeTakeItem(uuid, configId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangeTakeItemRequest = {uuid = uuid, configId = configId}
  local ret = worldProxy.ExchangeTakeItem(exchangeTakeItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ExchangeTakeItemSuccess)
  return true
end

function TradeVM:AsyncExchangeWithdraw(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local exchangeWithdrawRequest = {}
  local ret = worldProxy.ExchangeWithdraw(exchangeWithdrawRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ExchangeWithdrawSuccess)
  return true
end

function TradeVM:AsyncExchangeNotice(type, subType, cancelToken)
  local tradeData = Z.DataMgr.Get("trade_data")
  if tradeData.ExchangeNoticeItemCD[type] and tradeData.ExchangeNoticeItemCD[type][subType] and tradeData.ExchangeNoticeItemCD[type][subType] > 0 then
    return true
  end
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeNoticeRequest = {type = type, subType = subType}
  local ret = worldProxy.ExchangeNotice(ExchangeNoticeRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  tradeData:CacheEchangeNoticeData(type, subType, ret.items)
  return true
end

function TradeVM:AsyncExchangeNoticeDetail(configId, filter, nextPage, cancelToken)
  local tradeData = Z.DataMgr.Get("trade_data")
  local worldProxy = require("zproxy.world_proxy")
  if not nextPage then
    tradeData:SetTradeCurPageIndex(0)
  else
    tradeData:SetTradeCurPageIndex(tradeData.CurPageIndex + 1)
  end
  local ExchangeNoticeDetailRequest = {
    configId = configId,
    filter = filter,
    page = tradeData.CurPageIndex
  }
  local ret = worldProxy.ExchangeNoticeDetail(ExchangeNoticeDetailRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  tradeData:CacheExchangeNoticePriceItemList(configId, ret.items, nextPage)
  return true
end

function TradeVM:ExchangeNoticePreBuy(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeNoticePreBuyRequest = {}
  local ret = worldProxy.ExchangeNoticePreBuy(ExchangeNoticePreBuyRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CachePlayerPreBuyItemData(ret.items)
  return true
end

function TradeVM:AsyncExchangeNoticeBuyItem(configId, uuid, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeNoticeBuyItemRequest = {uuid = uuid, configId = configId}
  local ret = worldProxy.ExchangeNoticeBuyItem(ExchangeNoticeBuyItemRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ExchangeBuyItemSuccess)
  return true
end

function TradeVM:AsyncExchangeSaleRank(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleRankRequest = {}
  local ret = worldProxy.ExchangeSaleRank(ExchangeSaleRankRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CacheSaleRankItemData(ret.items)
  return true
end

function TradeVM:AsyncExchangeSaleData(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleDataRequest = {}
  local ret = worldProxy.ExchangeSaleData(ExchangeSaleDataRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CachePlayerSaleData(ret.items, ret.minRate)
  return true
end

function TradeVM:AsyncExchangeSaleRecord(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleRecordRequest = {}
  local ret = worldProxy.ExchangeSaleRecord(ExchangeSaleRecordRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CacheExchangeSaleRecord(ret.buyRecord, ret.sellRecord)
  return true
end

function TradeVM:AsyncExchangeSale(num, rate, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleRequest = {num = num, rate = rate}
  local ret = worldProxy.ExchangeSale(ExchangeSaleRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ConsignmentPutItemSuccess)
  return true
end

function TradeVM:AsyncExchangeSaleTake(guid, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleTakeRequest = {guid = guid}
  local ret = worldProxy.ExchangeSaleTake(ExchangeSaleTakeRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ConsignmentTakeItemSuccess)
  return true
end

function TradeVM:AsyncExchangeSaleBuy(rate, num, elseRate, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeSaleBuyRequest = {
    rate = rate,
    num = num,
    elseRate = elseRate or 0
  }
  local ret = worldProxy.ExchangeSaleBuy(ExchangeSaleBuyRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Trade.ConsignmentBuyItemSuccess)
  return true
end

function TradeVM:AsyncExchangeCare(type, itemConfigId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeCareRequest = {type = type, itemConfigId = itemConfigId}
  local ret = worldProxy.ExchangeCare(ExchangeCareRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  return true
end

function TradeVM:AsyncExchangeCareCancel(type, itemConfigId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeCareCancelRequest = {type = type, itemConfigId = itemConfigId}
  local ret = worldProxy.ExchangeCareCancel(ExchangeCareCancelRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  return true
end

function TradeVM:AsyncExchangeCareList(type, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ExchangeCareListRequest = {type = type}
  local ret = worldProxy.ExchangeCareList(ExchangeCareListRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local tradeData = Z.DataMgr.Get("trade_data")
  tradeData:CacheFocusItemList(ret.items)
  return ret.items
end

local stallItem

function TradeVM:CheckItemCanExchange(itemId, itemUuid)
  local itemsVm = Z.VMMgr.GetVM("items")
  local itemInfo = itemsVm.GetItemInfobyItemId(itemUuid, itemId)
  if itemInfo == nil then
    return false
  end
  if stallItem == nil then
    local stallTableData = Z.TableMgr.GetTable("StallDetailTableMgr").GetDatas()
    stallItem = {}
    for _, value in pairs(stallTableData) do
      stallItem[value.ItemID] = true
    end
  end
  return stallItem[itemId] ~= nil and itemInfo.bindFlag == 1
end

function TradeVM:CheckAnySellItemTimeOut()
  local tradeData = Z.DataMgr.Get("trade_data")
  local now = Z.TimeTools.Now() / 1000
  for _, value in ipairs(tradeData.ExchangeSellItemList) do
    if value.state ~= E.EExchangeItemState.ExchangeItemStatePublic and now > value.endTime then
      return true
    end
  end
  return false
end

return TradeVM
