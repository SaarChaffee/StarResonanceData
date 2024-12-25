local seasonShopRefreshType = {
  none = 0,
  season = 1,
  daily = 2,
  month = 3,
  week = 4
}
local eShopType = {NormalShop = 0, SeasonShop = 1}
local getShopConfigs = function(shopType)
  local configs, propConfigs
  if shopType == eShopType.NormalShop then
    configs = Z.TableMgr.GetTable("MallTableMgr")
    propConfigs = Z.TableMgr.GetTable("MallItemTableMgr")
  elseif shopType == eShopType.SeasonShop then
    configs = Z.TableMgr.GetTable("SeasonShopTableMgr")
    propConfigs = Z.TableMgr.GetTable("SeasonShopItemTableMgr")
  end
  return configs, propConfigs
end
local shouldShowShopTab = function(cfg, shopType, showType)
  return shopType ~= E.EShopType.Shop or cfg.ShowType == showType
end
local checkUnlockCondition = function(pcfg)
  if pcfg.UnlockConditions and #pcfg.UnlockConditions > 0 then
    return Z.ConditionHelper.CheckCondition(pcfg.UnlockConditions)
  else
    return true
  end
end
local processShopItems = function(items, propConfigs, shopType)
  local processedItems = {}
  for _, item in ipairs(items) do
    local pcfg = propConfigs.GetRow(item.itemId)
    if pcfg then
      item.cfg = pcfg
      item.shopType = shopType
      item.unlockCondition = checkUnlockCondition(pcfg)
      table.insert(processedItems, item)
    end
  end
  return processedItems
end
local shopItemSortFunc = function(a, b)
  local canBuy = function(item)
    for _, count in pairs(item.buyCount) do
      if count.canBuyCount == 0 then
        return false
      end
    end
    return true
  end
  local buyA, buyB = canBuy(a), canBuy(b)
  if buyA == buyB then
    if a.unlockCondition and not b.unlockCondition then
      return true
    elseif not a.unlockCondition and b.unlockCondition then
      return false
    end
    return a.cfg.Sort < b.cfg.Sort
  end
  return buyA and not buyB
end
local processShopTabs = function(tabs, configs, propConfigs, shopType, showType)
  local processedTabs = {}
  for id, tab in pairs(tabs) do
    local cfg = configs.GetRow(id)
    if cfg and shouldShowShopTab(cfg, shopType, showType) then
      local items = processShopItems(tab.items, propConfigs, shopType)
      table.sort(items, shopItemSortFunc)
      table.insert(processedTabs, {
        Id = id,
        cfg = cfg,
        items = items
      })
    end
  end
  table.sort(processedTabs, function(a, b)
    return a.cfg.Sort < b.cfg.Sort
  end)
  return processedTabs
end
local asyncGetShopData = function(cancelSource, shopType, showType)
  shopType = shopType or eShopType.NormalShop
  showType = showType or E.EShopShowType.Shop
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetShopItemList({shopType = shopType}, cancelSource:CreateToken())
  if ret.errCode > 0 then
    return {}
  end
  local configs, propConfigs = getShopConfigs(shopType)
  local shopData = processShopTabs(ret.tabs, configs, propConfigs, shopType, showType)
  return shopData
end
local buyPropCallback_
local asyncBuyShopItem = function(shopType, data, num, callback, cancelSource, tabId)
  local proxy = require("zproxy.world_proxy")
  buyPropCallback_ = callback
  proxy.BuyShopItem({
    shopType = shopType,
    itemId = data.itemId,
    buyCount = num,
    tabId = tabId
  }, cancelSource:CreateToken())
end
local buyShopItemResponse = function(call, data)
  if buyPropCallback_ then
    if data.errorCode > 0 then
      Z.VMMgr.GetVM("all_tips").ShowTips(data.errorCode)
    end
    buyPropCallback_(data)
    buyPropCallback_ = nil
  end
end
local getShopPageCfg = function(id)
  local cfg = Z.TableMgr.GetTable("SeasonShopTableMgr").GetRow(id)
  return cfg
end
local openBuyPopup = function(data, buyFunc, currencyArray)
  local num
  if data.cfg and data.cfg.Cost then
    for _, v in pairs(data.cfg.Cost) do
      num = v
    end
  end
  if num and num == 0 then
    if buyFunc then
      buyFunc(data, 1)
    end
  else
    Z.UIMgr:OpenView("season_item_buy_popup", {
      data = data,
      buyFunc = buyFunc,
      currencyArray = currencyArray
    })
  end
end
local closeBuyPopup = function()
  Z.UIMgr:CloseView("season_item_buy_popup")
end
local ret = {
  AsyncGetShopData = asyncGetShopData,
  OpenBuyPopup = openBuyPopup,
  CloseBuyPopup = closeBuyPopup,
  AsyncBuyShopItem = asyncBuyShopItem,
  BuyShopItemResponse = buyShopItemResponse,
  SeasonShopRefreshType = seasonShopRefreshType
}
return ret
