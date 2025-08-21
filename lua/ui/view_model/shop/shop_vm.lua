local ShopVm = {}
local worldProxy = require("zproxy.world_proxy")
local shopRedClass = require("rednode.shop_red")
local mallPagetabTableMap = require("table.MallPagetabTableMap")
local mallTableMap = require("table.MallTableMap")

function ShopVm.OpenShopView(funcId, configId)
  local gotoVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = gotoVm.CheckFuncCanUse(E.FunctionID.Shop, false)
  if not funcOpen then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local shopData = Z.DataMgr.Get("shop_data")
    local shopItemData = ShopVm.AsyncGetShopDataByShopType(E.EShopType.Shop, shopData.CancelSource:CreateToken())
    if table.zcount(shopItemData) == 0 then
      Z.TipsVM.ShowTips(1000749)
      return
    end
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Store, "shop_window", function()
      Z.UIMgr:OpenView("shop_window", {
        funcId = tonumber(funcId),
        configId = tonumber(configId)
      })
    end)
  end)()
end

function ShopVm.CloseShopView()
  Z.UIMgr:CloseView("shop_window")
end

function ShopVm.OpenTokenShopView(funcId, configId)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = funcVm.FuncIsOn(E.FunctionID.TokenShop, false)
  if not funcOpen then
    return
  end
  ShopVm.openCommonShopView(E.EShopType.TokenShop, funcId, configId)
end

function ShopVm.OpenCompensatenShopView(funcId, configId)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = funcVm.FuncIsOn(E.FunctionID.CompensatenShop, false)
  if not funcOpen then
    return
  end
  ShopVm.openCommonShopView(E.EShopType.CompensateShop, funcId, configId)
end

function ShopVm.OpenActivityShopView(funcId, configId)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  local funcOpen = funcVm.FuncIsOn(E.FunctionID.ActivityShop, false)
  if not funcOpen then
    return
  end
  ShopVm.openCommonShopView(E.EShopType.ActivityShop, funcId, configId)
end

function ShopVm.openCommonShopView(shopType, funcId, configId)
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Store, "shop_token", function()
    Z.UIMgr:OpenView("shop_token", {
      shopType = shopType,
      funcId = tonumber(funcId),
      configId = tonumber(configId)
    })
  end)
end

function ShopVm.CloseTokenShopView()
  Z.UIMgr:CloseView("shop_token")
end

function ShopVm.AsyncGetShopDataByShopType(shopType, token)
  if not mallTableMap.MallIdList[shopType] then
    return {}
  end
  local tab = ShopVm.AsyncGetShopData(mallTableMap.MallIdList[shopType], token)
  local shopData = ShopVm.processShopTabs(tab)
  return shopData
end

function ShopVm.AsyncGetShopData(mallIdList, token)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetShopItemList({shopId = mallIdList}, token)
  if ret.errCode > 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return {}
  end
  return ret.tab
end

local canBuy = function(item)
  for _, count in pairs(item.buyCount) do
    if count.canBuyCount == 0 then
      return false
    end
  end
  return true
end
local shopItemSortFunc = function(a, b)
  local buyA, buyB = canBuy(a), canBuy(b)
  if buyA == buyB then
    if a.unlockCondition and not b.unlockCondition then
      return true
    elseif not a.unlockCondition and b.unlockCondition then
      return false
    end
    if a.cfg.Sort == b.cfg.Sort then
      return a.cfg.Id < b.cfg.Id
    else
      return a.cfg.Sort < b.cfg.Sort
    end
  end
  return buyA and not buyB
end

function ShopVm.processShopTabs(tabs)
  local configs = Z.TableMgr.GetTable("MallTableMgr")
  local propConfigs = Z.TableMgr.GetTable("MallItemTableMgr")
  local processedTabs = {}
  for id, tab in pairs(tabs) do
    if #tab.items > 0 then
      local cfg = configs.GetRow(id, true)
      if cfg then
        local items = ShopVm.processShopItems(tab.items, cfg, propConfigs)
        table.sort(items, shopItemSortFunc)
        table.insert(processedTabs, {
          Id = id,
          cfg = cfg,
          items = items
        })
      end
    end
  end
  table.sort(processedTabs, function(a, b)
    return a.cfg.Sort < b.cfg.Sort
  end)
  return processedTabs
end

function ShopVm.UpdataAllShopItemData(newShopData, shopData)
  local configs = Z.TableMgr.GetTable("MallTableMgr")
  local propConfigs = Z.TableMgr.GetTable("MallItemTableMgr")
  for id, tab in pairs(newShopData) do
    if #tab.items > 0 then
      local cfg = configs.GetRow(id, true)
      if cfg then
        for i = 1, #shopData do
          if shopData[i].Id == id then
            local items = ShopVm.processShopItems(tab.items, cfg, propConfigs)
            table.sort(items, shopItemSortFunc)
            shopData[i].items = items
            break
          end
        end
      end
    end
  end
end

function ShopVm.UpdataShopItemData(curItems, newShopData, updataShopId, updataShopItemId)
  if not newShopData[updataShopId] then
    return
  end
  local newItems = newShopData[updataShopId].items
  local newShopItemData
  for i = 1, #newItems do
    if updataShopItemId == newItems[i].itemId then
      newShopItemData = newItems[i]
      break
    end
  end
  if not newShopItemData then
    return
  end
  for i = 1, #curItems do
    if curItems[i].itemId == newShopItemData.itemId then
      local cfg = curItems[i].cfg
      local shopType = curItems[i].shopType
      local unlockCondition = curItems[i].unlockCondition
      curItems[i] = newShopItemData
      curItems[i].cfg = cfg
      curItems[i].shopType = shopType
      curItems[i].unlockCondition = unlockCondition
      break
    end
  end
  table.sort(curItems, shopItemSortFunc)
end

function ShopVm.processShopItems(items, cfg, propConfigs)
  local showData = Z.DataMgr.Get("shop_data")
  local processedItems = {}
  for _, item in ipairs(items) do
    local pcfg = propConfigs.GetRow(item.itemId, true)
    if pcfg and (not pcfg.IsShow or pcfg.IsShow == 0) and ShopVm.CheckUnlockCondition(pcfg.ShowLimitType) then
      item.cfg = pcfg
      item.shopType = cfg.ShowType
      item.unlockCondition = ShopVm.CheckUnlockCondition(pcfg.UnlockConditions)
      table.insert(processedItems, item)
      if showData.FreeMallItemTab and showData.FreeMallItemTab[pcfg.Id] then
        shopRedClass.AddNewRed(pcfg.Id, cfg.ShowType)
        showData.FreeMallItemTab[pcfg.Id] = nil
      end
    end
  end
  return processedItems
end

function ShopVm.CheckUnlockCondition(unlockConditions)
  if unlockConditions and 0 < #unlockConditions then
    return Z.ConditionHelper.CheckCondition(unlockConditions)
  else
    return true
  end
end

function ShopVm.GetShopTabIndexByFunctionId(functionId, shopItemList)
  for index, value in ipairs(shopItemList) do
    if value.fristLevelTabData.FunctionId == functionId then
      return index
    elseif value.secondaryTabList then
      for secondIndex, v in ipairs(value.secondaryTabList) do
        if v.FunctionId == functionId then
          return index, secondIndex
        end
      end
    end
  end
end

function ShopVm.checkFirstShop(mallCfgData, shopTabList, firstShopIdList, mallChildList, shopType)
  if not mallCfgData then
    return
  end
  local isFirstShop = mallCfgData.HasFatherType == 0 or mallCfgData.HasFatherType == mallCfgData.Id
  if not isFirstShop then
    return
  end
  if mallCfgData.ShowType ~= shopType then
    return
  end
  if not firstShopIdList[mallCfgData.Id] then
    local redNodeId = ShopVm.getShopRedNodeId(mallCfgData.FunctionId, mallCfgData.Id)
    table.insert(shopTabList, {fristLevelTabData = mallCfgData, redNodeId = redNodeId})
    firstShopIdList[mallCfgData.Id] = true
  end
  if not mallChildList[mallCfgData.Id] then
    mallChildList[mallCfgData.Id] = {}
  end
end

function ShopVm.checkMallChildList(mallChildList, mallCfgData)
  local isFirstShop = mallCfgData.HasFatherType == 0 or mallCfgData.HasFatherType == mallCfgData.Id
  if isFirstShop then
    return
  end
  if not mallChildList[mallCfgData.HasFatherType] then
    mallChildList[mallCfgData.HasFatherType] = {}
  end
  table.insert(mallChildList[mallCfgData.HasFatherType], mallCfgData)
end

local threeTabSort = function(left, right)
  return left.Sort < right.Sort
end

function ShopVm.checkMallThreeList(shopTabData, mallPagetabTableData)
  if not mallPagetabTableMap or not mallPagetabTableMap.MallList then
    return
  end
  for _, secondTabConfig in ipairs(shopTabData.secondaryTabList) do
    local list = mallPagetabTableMap.MallList[secondTabConfig.MallPageId]
    if list then
      if not shopTabData.threeTabList then
        shopTabData.threeTabList = {}
      end
      if not shopTabData.threeTabList[secondTabConfig.Id] then
        shopTabData.threeTabList[secondTabConfig.Id] = {}
      end
      for i = 1, #list do
        local row = mallPagetabTableData.GetRow(list[i], true)
        if row and not row.IsHide then
          table.insert(shopTabData.threeTabList[secondTabConfig.Id], row)
        end
      end
      table.sort(shopTabData.threeTabList[secondTabConfig.Id], threeTabSort)
    end
  end
end

function ShopVm.GetShopTabTable(shopDatas, shopType)
  local mallTable = Z.TableMgr.GetTable("MallTableMgr")
  local switchVm = Z.VMMgr.GetVM("switch")
  local shopTabList = {}
  local firstShopIdList = {}
  local mallChildList = {}
  for _, value in ipairs(shopDatas) do
    local mallCfgData = mallTable.GetRow(value.Id)
    if mallCfgData and switchVm.CheckFuncSwitch(mallCfgData.FunctionId) then
      ShopVm.checkFirstShop(mallCfgData, shopTabList, firstShopIdList, mallChildList, shopType)
      local mallTableRow = mallTable.GetRow(mallCfgData.HasFatherType, true)
      ShopVm.checkFirstShop(mallTableRow, shopTabList, firstShopIdList, mallChildList, shopType)
      ShopVm.checkMallChildList(mallChildList, mallCfgData)
    end
  end
  local mallPagetabTableData = Z.TableMgr.GetTable("MallPagetabTableMgr")
  for _, shopTabData in ipairs(shopTabList) do
    if shopTabData.secondaryTabList == nil then
      shopTabData.secondaryTabList = {}
    end
    if mallChildList[shopTabData.fristLevelTabData.Id] then
      shopTabData.secondaryTabList = mallChildList[shopTabData.fristLevelTabData.Id]
      ShopVm.checkMallThreeList(shopTabData, mallPagetabTableData)
    end
  end
  if shopType == E.EShopType.Shop then
    ShopVm.InitShopTableData(E.FunctionID.PayFunction, shopTabList)
    ShopVm.InitShopTableData(E.FunctionID.MonthlyCard, shopTabList)
    ShopVm.InitRechargeActivityTableData(shopTabList)
  end
  table.sort(shopTabList, function(a, b)
    return a.fristLevelTabData.Sort < b.fristLevelTabData.Sort
  end)
  local shopData = Z.DataMgr.Get("shop_data")
  shopData:SetShopItemList(shopTabList)
  return shopTabList
end

function ShopVm.getShopRedNodeId(functionId, id)
  local redNodeId
  if functionId == E.FunctionID.MysteriousShop then
    redNodeId = E.RedType.MysteriousShopRed
  elseif functionId == E.FunctionID.RechargeActivityBuyGiftA or functionId == E.FunctionID.RechargeActivityBuyGiftB then
    redNodeId = E.RedType.RechargeActivityBuyGift
  elseif functionId == E.FunctionID.MonthlyCard then
    redNodeId = E.RedType.MonthlyCardTab
  elseif functionId ~= E.FunctionID.PayFunction then
    redNodeId = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, id)
  end
  return redNodeId
end

function ShopVm.InitShopTableData(functionId, shopTabList)
  local functionCfg = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(functionId)
  local switchVm = Z.VMMgr.GetVM("switch")
  if functionCfg and switchVm.CheckFuncSwitch(functionId) then
    for _, row in pairs(Z.TableMgr.GetTable("MallTableMgr").GetDatas()) do
      if row.FunctionId == functionId then
        local redNodeId = ShopVm.getShopRedNodeId(row.FunctionId, row.Id)
        table.insert(shopTabList, {
          fristLevelTabData = row,
          secondaryTabList = {},
          redNodeId = redNodeId
        })
        break
      end
    end
  end
end

function ShopVm.InitRechargeActivityTableData(shopTabList)
  local rechargeActivityVM = Z.VMMgr.GetVM("recharge_activity")
  local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
  if rechargeActivityVM.IsShowRechargeActivityBuyGifts(E.FunctionID.RechargeActivityBuyGiftA) then
    table.insert(shopTabList, 1, {
      fristLevelTabData = rechargeActivityData.RechargeActivityMallConfig[E.FunctionID.RechargeActivityBuyGiftA]
    })
  end
  if rechargeActivityVM.IsShowRechargeActivityBuyGifts(E.FunctionID.RechargeActivityBuyGiftB) then
    table.insert(shopTabList, 1, {
      fristLevelTabData = rechargeActivityData.RechargeActivityMallConfig[E.FunctionID.RechargeActivityBuyGiftB]
    })
  end
end

function ShopVm.CheckShopItemFirstCharge(productId)
  local shopData = Z.DataMgr.Get("shop_data")
  local isFirstCharge = shopData:GetShopItemFirstInfo(productId)
  return isFirstCharge
end

function ShopVm.CheckShopItemExtraAwardCharge(productId)
  local shopData = Z.DataMgr.Get("shop_data")
  local isExtraAwardCharge = false
  local extraAwardCharge = shopData:GetShopItemLadderInfo(productId)
  if extraAwardCharge then
    for itemId, count in pairs(extraAwardCharge.ladderPayInfo) do
      if itemId ~= 0 and 0 < count then
        isExtraAwardCharge = true
        break
      end
    end
    if extraAwardCharge.extraAwardID and extraAwardCharge.extraAwardID ~= 0 then
      isExtraAwardCharge = true
    end
  end
  return isExtraAwardCharge
end

function ShopVm.GetShopItemExtraAwardCharge(productId)
  local shopData = Z.DataMgr.Get("shop_data")
  local extraAwardCharge = shopData:GetShopItemLadderInfo(productId)
  for itemId, count in pairs(extraAwardCharge.ladderPayInfo) do
    if itemId ~= 0 and 0 < count then
      local award = {awardId = itemId, awardNum = count}
      return award
    end
  end
  if extraAwardCharge.extraAwardID and extraAwardCharge.extraAwardID ~= 0 then
    local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
    local award = awardPreviewVm.GetAllAwardPreListByIds(extraAwardCharge.extraAwardID)
    if award and award[1] then
      return award[1]
    end
  end
  return nil
end

function ShopVm.AsyncGetFirstPayInfo(cancelToken)
  local paymentVm = Z.VMMgr.GetVM("payment")
  if not paymentVm:CheckPaymentEnable() then
    return
  end
  local ret = worldProxy.GetFirstPay(cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  local shopData = Z.DataMgr.Get("shop_data")
  shopData:SetShopItemFirstInfo(ret.firstPayInfo, ret.ladderPayInfo)
  return true
end

function ShopVm.GetShopItemCurrencySymbol()
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local paymentSignalData = Z.TableMgr.GetTable("PaymentSignalTableMgr").GetDatas()
  for _, value in ipairs(paymentSignalData) do
    if value.Platform == currentPlatform then
      return value.Signal
    end
  end
  return "\239\191\165"
end

function ShopVm.GetShopItemAwardInfo(paymentId)
  local paymentCfg = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(paymentId)
  local awardTab = {}
  local awardVm = Z.VMMgr.GetVM("awardpreview")
  if paymentCfg and paymentCfg.MailId == 0 then
    if paymentCfg.AwardId ~= 0 then
      local award = awardVm.GetAllAwardPreListByIds(paymentCfg.AwardId)
      for _, value in ipairs(award) do
        table.insert(awardTab, {
          configId = value.awardId,
          count = value.awardNum
        })
      end
    end
    if ShopVm.CheckShopItemExtraAwardCharge(paymentId) then
      local award = awardVm.GetAllAwardPreListByIds(paymentCfg.ExtraAwardID)
      for key, value in ipairs(award) do
        local isMerge = false
        for _, awardData in ipairs(awardTab) do
          if awardData.configId == value.awardId then
            awardData.count = awardData.count + value.awardNum
            isMerge = true
          end
        end
        if not isMerge then
          table.insert(awardTab, {
            configId = value.awardId,
            count = value.awardNum
          })
        end
      end
    end
    if ShopVm.CheckShopItemFirstCharge(paymentId) and paymentCfg.FirstChargeAwardID ~= 0 then
      local award = awardVm.GetAllAwardPreListByIds(paymentCfg.FirstChargeAwardID)
      for key, value in ipairs(award) do
        local isMerge = false
        for _, awardData in ipairs(awardTab) do
          if awardData.configId == value.awardId then
            awardData.count = awardData.count + value.awardNum
            isMerge = true
          end
        end
        if not isMerge then
          table.insert(awardTab, {
            configId = value.awardId,
            count = value.awardNum
          })
        end
      end
    end
    for _, value in pairs(paymentCfg.Items) do
      local isMerge = false
      for _, awardData in ipairs(awardTab) do
        if awardData.configId == value[1] then
          awardData.count = awardData.count + value[2]
          isMerge = true
        end
      end
      if not isMerge then
        table.insert(awardTab, {
          configId = value[1],
          count = value[2]
        })
      end
    end
  end
  return awardTab
end

function ShopVm.AsyncExchangeCurrency(functionId, useCount)
  worldProxy.ExchangeCurrency(functionId, useCount)
end

function ShopVm.SetShopItemRed(itemId, shopType)
  shopRedClass.AddNewRed(itemId, shopType)
end

function ShopVm.SetMallItemRed()
  local showData = Z.DataMgr.Get("shop_data")
  showData.FreeMallItemTab = {}
  local cfg = showData.MallItemTableDatas
  for _, data in pairs(cfg) do
    for _, num in pairs(data.Cost) do
      if num == 0 then
        showData.FreeMallItemTab[data.Id] = true
        break
      end
    end
  end
end

function ShopVm.BuyCallFunc(vRequest)
  if vRequest.errCode == 0 then
    local awardTab = ShopVm.GetShopItemAwardInfo(vRequest.paymentId)
    if 0 < #awardTab then
      local itemShowVm = Z.VMMgr.GetVM("item_show")
      itemShowVm.OpenItemShowView(awardTab)
    end
  else
    Z.TipsVM.ShowTips(vRequest.errCode)
  end
end

function ShopVm.AsyncRefreshShop(shopId, cancelToken)
  local request = {}
  request.shopId = shopId
  local reply = worldProxy.RefreshShop(request, cancelToken)
  return reply
end

function ShopVm.InitCfgData()
  local mallTab = {}
  for key, cfgData in pairs(Z.TableMgr.GetTable("MallTableMgr").GetDatas()) do
    mallTab[cfgData.FunctionId] = cfgData
  end
  local showData = Z.DataMgr.Get("shop_data")
  showData.MallTableDatas = mallTab
end

function ShopVm.OpenBuyPopup(data, buyFunc, currencyArray)
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

function ShopVm.CloseBuyPopup()
  Z.UIMgr:CloseView("season_item_buy_popup")
end

function ShopVm.OpenShopBuyPopup(viewData)
  Z.UIMgr:OpenView("shop_buy_popup", viewData)
end

function ShopVm.CloseShopBuyPopup()
  Z.UIMgr:CloseView("shop_buy_popup")
end

function ShopVm.GetShopMallItemOriginal(data)
  for id, num in pairs(data.OriginalPrice) do
    return num, id
  end
  return 0
end

function ShopVm.GetShopMallItemPrice(data)
  local costType, costNum
  for id, num in pairs(data.Cost) do
    costType = id
    costNum = num
    break
  end
  if not costType or not costNum then
    return 0
  end
  if not data.GoodsGroup or #data.GoodsGroup == 0 then
    return costNum
  end
  local originalNum = data.OriginalPrice[costType]
  if not originalNum then
    return costNum
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local discount = costNum / originalNum
  for i = 1, #data.GoodsGroup do
    local row = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.GoodsGroup[i], true)
    if row then
      local itemCost = row.OriginalPrice[costType]
      itemCost = itemCost or row.Cost[costType]
      if itemCost then
        local haveCount = itemsVM.GetItemTotalCount(row.ItemId)
        if 0 < haveCount then
          originalNum = originalNum - itemCost
        end
      end
    end
  end
  return math.max(0, math.floor(originalNum * discount))
end

function ShopVm.calculateSubCouponsCost(costId, costValue, couponsRow, couponsCount)
  local sub = 0
  if couponsRow and couponsRow.CurrencyItem == costId then
    if couponsRow.Type == E.MallCouponsType.Discount then
      sub = costValue - costValue * couponsRow.CouponsTypeParameter * 0.01
    elseif couponsRow.Type == E.MallCouponsType.Deduction then
      sub = couponsRow.CouponsTypeParameter * couponsCount
    end
  end
  return sub
end

function ShopVm.CalculateCouponsCostByCouponsList(costId, costValue, list)
  if not list then
    return costValue
  end
  local sub = 0
  for i = 1, #list do
    local row = Z.TableMgr.GetTable("MallCouponsTableMgr").GetRow(list[i].configId, true)
    if row and 0 < list[i].count then
      sub = sub + ShopVm.calculateSubCouponsCost(costId, costValue, row, list[i].count)
    end
  end
  return costValue - sub
end

function ShopVm.CheckCouponsCanUse(mallItemRow, mallCouponsRow)
  for costType, _ in pairs(mallItemRow.Cost) do
    if costType ~= mallCouponsRow.CurrencyItem then
      return false
    end
    local costValue = ShopVm.GetShopMallItemPrice(mallItemRow)
    if mallCouponsRow.Type == E.MallCouponsType.Deduction and costValue < mallCouponsRow.CouponsTypeParameter then
      return false
    end
    return true
  end
  return false
end

function ShopVm.AsyncShopBuyItemList(shopItemList, token)
  local proxy = require("zproxy.world_proxy")
  local paymentVm = Z.VMMgr.GetVM("payment")
  local shopItemInfo = {
    buyShopItemInfo = shopItemList,
    extData = paymentVm:GetExtData()
  }
  proxy.BuyShopItem(shopItemInfo, token)
end

function ShopVm.NotifyBuyShopResult(data)
  if data.errCode ~= 0 then
    Z.TipsVM.ShowTips(data.errCode)
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Shop.NotifyBuyShopResult, data.buyShopItemInfo)
end

function ShopVm.ShowBuyResultTips(DeliverWay)
  if not DeliverWay or not DeliverWay[E.ShopDeliverWayType.EDeliverWayType] then
    return
  end
  local tipsParam = DeliverWay[1][E.ShopDeliverWayType.EDeliverWayTipsParam]
  if tipsParam then
    if tipsParam < 0 then
      return
    end
    if 0 < tipsParam then
      Z.TipsVM.ShowTipsLang(tipsParam)
      return
    end
  end
  local type = DeliverWay[1][E.ShopDeliverWayType.EDeliverWayType]
  if type == E.EDeliverWayType.EMail then
    Z.TipsVM.ShowTipsLang(1000732)
  elseif type == E.EDeliverWayType.EBack then
    Z.TipsVM.ShowTipsLang(1000733)
  end
end

function ShopVm.ShowBuyResultItemTips(mallCfg, buyCount)
  if not (mallCfg and mallCfg.DeliverWay) or not mallCfg.DeliverWay[1] then
    Z.TipsVM.ShowTipsLang(1000722)
    return
  end
  local tipsParam = mallCfg.DeliverWay[1][E.ShopDeliverWayType.EDeliverWayTipsParam]
  if tipsParam then
    if tipsParam < 0 then
      return
    end
    if 0 < tipsParam then
      Z.TipsVM.ShowTipsLang(tipsParam)
      return
    end
  end
  local type = mallCfg.DeliverWay[1][E.ShopDeliverWayType.EDeliverWayType]
  if type == E.EDeliverWayType.EBack then
    local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", mallCfg.ItemId)
    if itemTableRow and itemTableRow.SpecialDisplayType == 0 then
      local awardTab = ShopVm:generateAwardTab(mallCfg, buyCount)
      local itemShowVm = Z.VMMgr.GetVM("item_show")
      itemShowVm.OpenItemShowView(awardTab)
    end
  else
    Z.TipsVM.ShowTipsLang(1000722)
  end
end

function ShopVm:generateAwardTab(mallCfg, buyCount)
  local awardTab = {}
  local equipTabCfg = Z.TableMgr.GetTable("EquipTableMgr").GetRow(mallCfg.ItemId, true)
  if equipTabCfg then
    for i = 1, buyCount do
      table.insert(awardTab, {
        configId = mallCfg.ItemId,
        lab = 1
      })
    end
  else
    table.insert(awardTab, {
      configId = mallCfg.ItemId,
      count = buyCount
    })
  end
  return awardTab
end

function ShopVm.calculateOriginalValueByCostId(id, num)
  local shopData = Z.DataMgr.Get("shop_data")
  for i = 1, #shopData.ShopCostList do
    if shopData.ShopCostList[i].costId == 0 or shopData.ShopCostList[i].costId == id then
      shopData.ShopCostList[i].costId = id
      shopData.ShopCostList[i].originalValue = shopData.ShopCostList[i].originalValue + num
      break
    end
  end
end

function ShopVm.calculateCostValueByCostId(id, row, couponList)
  local shopData = Z.DataMgr.Get("shop_data")
  for i = 1, #shopData.ShopCostList do
    if shopData.ShopCostList[i].costId == 0 or shopData.ShopCostList[i].costId == id then
      shopData.ShopCostList[i].costId = id
      local price = ShopVm.GetShopMallItemPrice(row)
      local costValue = math.floor(ShopVm.CalculateCouponsCostByCouponsList(id, price, couponList))
      shopData.ShopCostList[i].costValue = shopData.ShopCostList[i].costValue + costValue
      break
    end
  end
end

function ShopVm.calculateCostByMallItem(row, couponList)
  for id, _ in pairs(row.Cost) do
    ShopVm.calculateCostValueByCostId(id, row, couponList)
  end
  for id, num in pairs(row.OriginalPrice) do
    ShopVm.calculateOriginalValueByCostId(id, num)
  end
end

function ShopVm.refreshCostByMallData(data)
  if not data.mallItemRow then
    data.mallItemRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.data.itemId, true)
  end
  if not data.mallItemRow then
    return
  end
  ShopVm.calculateCostByMallItem(data.mallItemRow, data.couponsList)
end

function ShopVm.RefreshCost()
  local shopData = Z.DataMgr.Get("shop_data")
  shopData:InitCostList()
  for _, mallData in pairs(shopData.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      ShopVm.refreshCostByMallData(data)
    end
  end
end

function ShopVm.CheckItemExchangeCount(costId, costCount, token)
  if costId ~= Z.SystemItem.ItemEnergyPoint then
    return false
  end
  local itemVM = Z.VMMgr.GetVM("items")
  local have = itemVM.GetItemTotalCount(Z.SystemItem.ItemEnergyPoint)
  if costCount <= have then
    return false
  end
  local diamondHave = itemVM.GetItemTotalCount(Z.SystemItem.ItemDiamond)
  if costCount > diamondHave + have then
    return false
  end
  local param = {
    val = costCount - have
  }
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = Lang("GemsReplaceBindingTips", param),
    onConfirm = function()
      local buyList = {
        [Z.SystemItem.ItemEnergyPoint] = {
          buyNum = costCount - have
        }
      }
      ShopVm.AsyncShopBuyItemList(buyList, token)
    end
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
  return true
end

return ShopVm
