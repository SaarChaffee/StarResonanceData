local super = require("ui.model.data_base")
local TradeData = class("TradeData", super)

function TradeData:ctor()
end

function TradeData:Init()
  self.exchangeItemList_ = {}
  self.ExchangeItemCD = {}
  self.ExchangeRefreshClickCD = 0
  self.ExchangeItemDict = {}
  self.ExchangePriceItemList = {}
  self.ExchangeSellItemList = {}
  self.WithDrawItem = {}
  self.Limit = 0
  self.BuyRecord = {}
  self.SellRecord = {}
  self.ServerRate = 0
  self.CurPageIndex = 1
  self.CurTradeItemNum = 0
  self.ExchangeNoticeItemCD = {}
  self.ExchangeNoticeRefreshClickCD = 0
  self.ExchangeNoticeItemDict = {}
  self.ExchangeNoticePriceItemList = {}
  self.PlayerPrebuyItemList = {}
  self.PlayerPrebuyItemDict = {}
  self.ConsignmentDataRankList = {}
  self.ConsignmentBuyRecord = {}
  self.ConsignmentSellRecord = {}
  self.ConsignmentMinRate = 0
  self.ConsignmentItemDataList = {}
  self.InitialStallNum = Z.StallRuleConfig.InitialStallNum
  self.RefreshCD = Z.StallRuleConfig.refreshCD
  self.MaxDeposit = Z.StallRuleConfig.MaxDeposit
  self.MinDeposit = Z.StallRuleConfig.MinDeposit
  self.DefaultItem = Z.StallRuleConfig.lunuoID
  self.DiamondItem = Z.StallRuleConfig.diamondID
  self.FakeDiamondItem = Z.StallRuleConfig.fakediamondID
  self.SaleDiamondTax = Z.StallRuleConfig.SaleTax
  self.DefalutDiamondTax = Z.StallRuleConfig.BasicRate
  self.MaxDiamondTax = Z.StallRuleConfig.SaleMax
  self.MinDiamondTax = Z.StallRuleConfig.SaleMin
  self.PreSaleNum = Z.StallRuleConfig.PreSaleNum
  self.showMaxNun = Z.StallRuleConfig.SaleItemMaxShowNum
  local allSellItem = Z.TableMgr.GetTable("StallDetailTableMgr").GetDatas()
  for _, value in pairs(allSellItem) do
    if self.exchangeItemList_[value.Category] == nil then
      self.exchangeItemList_[value.Category] = {}
    end
    if self.exchangeItemList_[value.Category][value.Subcategory] == nil then
      self.exchangeItemList_[value.Category][value.Subcategory] = {}
    end
    table.insert(self.exchangeItemList_[value.Category][value.Subcategory], value.ItemID)
  end
end

function TradeData:CacheExchangeItemList(type, subType, itemList)
  local newExchangeItemData = {}
  for _, value in ipairs(itemList) do
    newExchangeItemData[value.configId] = value
  end
  if self.exchangeItemList_[type] and self.exchangeItemList_[type][subType] then
    for _, itemId in ipairs(self.exchangeItemList_[type][subType]) do
      if newExchangeItemData[itemId] then
        self.ExchangeItemDict[itemId] = newExchangeItemData[itemId]
      else
        self.ExchangeItemDict[itemId] = nil
      end
    end
  end
  if self.ExchangeItemCD[type] == nil then
    self.ExchangeItemCD[type] = {}
  end
  self.ExchangeItemCD[type][subType] = self.RefreshCD
  Z.GlobalTimerMgr:StartTimer("exchange_mainType_" .. type .. "subType" .. subType, function()
    self.ExchangeItemCD[type][subType] = self.ExchangeItemCD[type][subType] - 1
  end, 1, self.RefreshCD)
end

function TradeData:CacheFocusItemList(itemList)
  for _, value in ipairs(itemList) do
    value.isCare = true
    self.ExchangeItemDict[value.configId] = value
  end
end

function TradeData:SetClickRefreshCD(isNotice)
  if isNotice then
    self.ExchangeNoticeRefreshClickCD = self.RefreshCD
    Z.GlobalTimerMgr:StartTimer("click_refresh_mainType_1", function()
      self.ExchangeNoticeRefreshClickCD = self.ExchangeNoticeRefreshClickCD - 1
    end, 1, self.RefreshCD)
  else
    self.ExchangeRefreshClickCD = self.RefreshCD
    Z.GlobalTimerMgr:StartTimer("click_refresh_mainType_2", function()
      self.ExchangeRefreshClickCD = self.ExchangeRefreshClickCD - 1
    end, 1, self.RefreshCD)
  end
end

function TradeData:CacheExchangePriceItemList(configId, itemList, nextPage)
  if self.ExchangePriceItemList[configId] == nil then
    self.ExchangePriceItemList[configId] = {}
  end
  if nextPage then
    for _, value in ipairs(itemList) do
      table.insert(self.ExchangePriceItemList[configId], value)
    end
  else
    self.ExchangePriceItemList[configId] = itemList
  end
end

function TradeData:CacheExchangeSellItemData(itemList, withDrawItem, limit, serverRate)
  self.ExchangeSellItemList = itemList
  self.WithDrawItem = withDrawItem
  self.Limit = limit
  if serverRate == 0 then
    self.ServerRate = self.DefalutDiamondTax
  else
    self.ServerRate = serverRate
  end
end

function TradeData:CacheRecordItemData(buyRecord, sellRecord)
  self.BuyRecord = table.zreverse(buyRecord)
  self.SellRecord = table.zreverse(sellRecord)
end

function TradeData:CacheEchangeNoticeData(type, subType, itemList)
  local newExchangeItemData = {}
  for _, value in ipairs(itemList) do
    newExchangeItemData[value.configId] = value
  end
  if self.exchangeItemList_[type] and self.exchangeItemList_[type][subType] then
    for _, itemId in ipairs(self.exchangeItemList_[type][subType]) do
      if newExchangeItemData[itemId] then
        self.ExchangeNoticeItemDict[itemId] = newExchangeItemData[itemId]
      else
        self.ExchangeNoticeItemDict[itemId] = nil
      end
    end
  end
  if self.ExchangeNoticeItemCD[type] == nil then
    self.ExchangeNoticeItemCD[type] = {}
  end
  self.ExchangeNoticeItemCD[type][subType] = self.RefreshCD
  Z.GlobalTimerMgr:StartTimer("notice_mainType_" .. type .. "subType" .. subType, function()
    self.ExchangeNoticeItemCD[type][subType] = self.ExchangeNoticeItemCD[type][subType] - 1
  end, 1, self.RefreshCD)
end

function TradeData:CacheExchangeNoticePriceItemList(configId, itemList, nextPage)
  if self.ExchangeNoticePriceItemList[configId] == nil then
    self.ExchangeNoticePriceItemList[configId] = {}
  end
  if nextPage then
    for _, value in ipairs(itemList) do
      table.insert(self.ExchangeNoticePriceItemList[configId], value)
    end
  else
    self.ExchangeNoticePriceItemList[configId] = itemList
  end
end

function TradeData:CachePlayerPreBuyItemData(itemList)
  self.PlayerPrebuyItemList = itemList
  self.PlayerPrebuyItemDict = {}
  for _, value in ipairs(itemList) do
    local configId = value.itemInfo.configId
    if self.PlayerPrebuyItemDict[configId] == nil then
      self.PlayerPrebuyItemDict[configId] = {}
      self.PlayerPrebuyItemDict[configId].num = 0
      self.PlayerPrebuyItemDict[configId].price = 999999999
      self.PlayerPrebuyItemDict[configId].configId = configId
      self.PlayerPrebuyItemDict[configId].itemInfo = value.itemInfo
    end
    self.PlayerPrebuyItemDict[configId].num = self.PlayerPrebuyItemDict[configId].num + value.num
    if self.PlayerPrebuyItemDict[configId].price > value.price then
      self.PlayerPrebuyItemDict[configId].price = value.price
    end
  end
end

function TradeData:CacheSaleRankItemData(saleRankItemData)
  self.ConsignmentDataRankList = saleRankItemData
  table.sort(self.ConsignmentDataRankList, function(a, b)
    return a.rate < b.rate
  end)
end

function TradeData:CacheExchangeSaleRecord(buyRecord, sellRecord)
  self.ConsignmentBuyRecord = buyRecord
  self.ConsignmentSellRecord = sellRecord
end

function TradeData:CachePlayerSaleData(dataList, minRate)
  self.ConsignmentItemDataList = dataList
  if minRate == 0 then
    self.ConsignmentMinRate = self.DefalutDiamondTax
  else
    self.ConsignmentMinRate = minRate
  end
end

function TradeData:SetCacheTradeSellItemNum(configId, buyNum)
  if self.ExchangeItemDict[configId] then
    self.ExchangeItemDict[configId].num = self.ExchangeItemDict[configId].num - buyNum
  end
end

function TradeData:SetTradeCurPageIndex(index)
  self.CurPageIndex = index
end

function TradeData:SetCurTradeNum(num)
  self.CurTradeItemNum = num
end

function TradeData:Clear()
end

return TradeData
