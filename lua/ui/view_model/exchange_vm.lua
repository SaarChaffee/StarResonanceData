local exchangeItemTbl = Z.TableMgr.GetTable("ExchangeItemTableMgr")
local itemsVM = Z.VMMgr.GetVM("items")
local exchangeItemTableMap = require("table.ExchangeItemTableMap")
local openExchangeView = function(shopId, npcId)
  local entityVM = Z.VMMgr.GetVM("entity")
  local uuid = 0
  if npcId ~= nil then
    uuid = entityVM.ConfigIdToUUid(npcId)
  end
  Z.UIMgr:OpenView("exchange_main", {
    shopId = tonumber(shopId),
    npcId = uuid
  })
end
local openExchangeViewByInteration = function(shopId, uuid)
  Z.UIMgr:OpenView("exchange_main", {
    shopId = tonumber(shopId),
    npcId = uuid
  })
end
local openExchangeViewByFunctionId = function(functionId)
  local talkData = Z.DataMgr.Get("talk_data")
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(functionId, talkData:GetTalkingNpcId())
end
local closeExchangeView = function()
  Z.UIMgr:CloseView("exchange_main")
end
local getConsumeItemDataListByGoodsId = function(goodsId)
  local dataList = {}
  local exchangeItemRow = exchangeItemTbl.GetRow(goodsId)
  if exchangeItemRow == nil then
    return dataList
  end
  for _, consumeList in pairs(exchangeItemRow.ConsumableID) do
    local itemData = {
      id = consumeList[1],
      consumeNum = consumeList[2],
      ownNum = itemsVM.GetItemTotalCount(consumeList[1])
    }
    table.insert(dataList, itemData)
  end
  return dataList
end
local isEnoughConsumeItems = function(itemDataList)
  for _, itemData in ipairs(itemDataList) do
    if itemData.consumeNum > itemData.ownNum then
      return false
    end
  end
  return true
end
local getExchangeLimitType = function(itemId)
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(itemId)
  if exchangeItemRow then
    local type = exchangeItemRow.RefreshType
    if 0 < type then
      local timerInfo = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(type)
      if timerInfo == nil then
        return E.ExchangeLimitType.Always
      end
      if timerInfo.TimerType == E.TimerType.Daily then
        return E.ExchangeLimitType.Day
      elseif timerInfo.TimerType == E.TimerType.Weekly then
        return E.ExchangeLimitType.Week
      end
    end
    return E.ExchangeLimitType.Always
  end
  return E.ExchangeLimitType.Always
end
local isEnoughExchangeChance = function(goodsId)
  local exchangeItemRow = exchangeItemTbl.GetRow(goodsId)
  if exchangeItemRow == nil then
    return false
  end
  local shopId = exchangeItemRow.ExchangeID
  local shopInfo = Z.ContainerMgr.CharSerialize.exchangeItems.exchangeInfo[shopId]
  local data = shopInfo.exchangeData[goodsId]
  if data then
    local curExchangeNum = data.curExchangeCount
    local maxNum = exchangeItemRow.RefreshNum
    local limitType = getExchangeLimitType(goodsId)
    if limitType == E.ExchangeLimitType.Not then
      return true
    else
      return curExchangeNum < maxNum
    end
  else
    return false
  end
end
local isUpperLimmit = function(goodsId)
  local exchangeItemRow = exchangeItemTbl.GetRow(goodsId)
  if exchangeItemRow == nil then
    return false
  end
  local upperLimmit = false
  local itemVM = Z.VMMgr.GetVM("items")
  local count = itemVM.GetItemTotalCount(exchangeItemRow.GetItemId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(exchangeItemRow.GetItemId)
  if itemCfg then
    local itemTypeCfg = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemCfg.Type)
    if itemTypeCfg and itemTypeCfg.UpperLlimit ~= 0 then
      upperLimmit = count >= itemTypeCfg.UpperLlimit
    end
  end
  return upperLimmit
end
local sortGoods = function(left, right)
  if left.isUnlock and not right.isUnlock then
    return true
  elseif not left.isUnlock and right.isUnlock then
    return false
  end
  local leftChanceEnough = isEnoughExchangeChance(left.goodsId)
  local rightChanceEnough = isEnoughExchangeChance(right.goodsId)
  local leftUpperLimit = isUpperLimmit(left.goodsId)
  local rightUpperLimit = isUpperLimmit(right.goodsId)
  if leftUpperLimit ~= rightUpperLimit then
    return rightUpperLimit
  end
  if leftChanceEnough ~= rightChanceEnough then
    return leftChanceEnough
  end
  local leftExchangeItemRow = exchangeItemTbl.GetRow(left.goodsId)
  local rightExchangeItemRow = exchangeItemTbl.GetRow(right.goodsId)
  if leftExchangeItemRow and rightExchangeItemRow then
    return leftExchangeItemRow.Sort < rightExchangeItemRow.Sort
  end
  return false
end
local getExchangeItemConditionDataAndState = function(itemId)
  local tab = {}
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(itemId)
  local isUnlock = true
  if exchangeItemRow then
    local unlockConditions = exchangeItemRow.UnlockConditions
    local index = 1
    for index, value in ipairs(unlockConditions) do
      local bResult, tips, progress = Z.ConditionHelper.GetSingleConditionDesc(value[1], value[2], value[3])
      tab[index] = {
        bResult = bResult,
        tips = tips,
        progress = progress
      }
      index = index + 1
      if not bResult then
        isUnlock = bResult
      end
    end
  end
  return tab, isUnlock
end
local getGoodsIdListByShopId = function(shopId, professionId)
  local idList = {}
  local sex = Z.ContainerMgr.CharSerialize.charBase.gender
  local exchangeItemMgr = Z.TableMgr.GetTable("ExchangeItemTableMgr")
  local equipMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local exchangeShopItems = {}
  if exchangeItemTableMap and exchangeItemTableMap.QualityGroup and exchangeItemTableMap.QualityGroup[shopId] then
    exchangeShopItems = exchangeItemTableMap.QualityGroup[shopId]
  end
  for _, goodsId in ipairs(exchangeShopItems) do
    local exchangeItemConfig = exchangeItemMgr.GetRow(goodsId)
    if exchangeItemConfig then
      if professionId == nil then
        if exchangeItemConfig.SexLimit == 0 or exchangeItemConfig.SexLimit == sex then
          local conditionData, isUnlock = getExchangeItemConditionDataAndState(goodsId)
          table.insert(idList, {
            goodsId = goodsId,
            conditionData = conditionData,
            isUnlock = isUnlock,
            itemId = exchangeItemConfig.GetItemId
          })
        end
      else
        local isProfessionEquipItem = false
        local equipConfig = equipMgr.GetRow(exchangeItemConfig.GetItemId, true)
        if equipConfig then
          for _, pro in ipairs(equipConfig.EquipProfession) do
            if pro == professionId then
              isProfessionEquipItem = true
              break
            end
          end
        else
          isProfessionEquipItem = true
        end
        if (exchangeItemConfig.SexLimit == 0 or exchangeItemConfig.SexLimit == sex) and isProfessionEquipItem then
          local conditionData, isUnlock = getExchangeItemConditionDataAndState(goodsId)
          table.insert(idList, {
            goodsId = goodsId,
            conditionData = conditionData,
            isUnlock = isUnlock,
            itemId = exchangeItemConfig.GetItemId
          })
        end
      end
    end
  end
  table.sort(idList, sortGoods)
  return idList
end
local asyncSendExchange = function(shopId, goodsId, shopNum, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ExchangeItem(shopId, goodsId, shopNum, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end
local onGoodsChange = function(goodsData, dirtyKeys)
  local countDirty = dirtyKeys.curExchangeCount
  if countDirty == nil then
    return
  end
  Z.EventMgr:Dispatch("GoodsExchangeCountChange", goodsData)
end
local regGoodsChangeWatcherByShopId = function(shopId)
  local shopData = Z.ContainerMgr.CharSerialize.exchangeItems.exchangeInfo[shopId]
  for _, goodsData in pairs(shopData.exchangeData) do
    goodsData.Watcher:RegWatcher(onGoodsChange)
  end
end
local unregGoodsChangeWatcherByShopId = function(shopId)
  local shopData = Z.ContainerMgr.CharSerialize.exchangeItems.exchangeInfo[shopId]
  if not shopData then
    return
  end
  for _, goodsData in pairs(shopData.exchangeData) do
    goodsData.Watcher:UnregWatcher(onGoodsChange)
  end
end
local getExchangeItemUnlock = function(itemId)
  local exchangeItemRow = Z.TableMgr.GetTable("ExchangeItemTableMgr").GetRow(itemId)
  local isUnlock = true
  if exchangeItemRow then
    local unlockConditions = exchangeItemRow.UnlockConditions
    for index, value in ipairs(unlockConditions) do
      local bResult, tips, progress = Z.ConditionHelper.GetSingleConditionDesc(value[1], value[2], value[3])
      if not bResult then
        isUnlock = bResult
      end
    end
  end
  return isUnlock
end
local resetEntityAndUIVisible = function(isExchange)
  local entityandhudRecordData = Z.DataMgr.Get("entityandhud_record_data")
  local showSelf
  if isExchange then
    showSelf = false
  else
    showSelf = entityandhudRecordData:GetShowEntityRecord(E.CameraSystemShowEntityType.Oneself)
  end
  Z.LuaBridge.SetExchangeEntityShow(E.CameraSystemShowEntityType.Oneself, showSelf)
  local showOtherPlayer
  if isExchange then
    showOtherPlayer = false
  else
    showOtherPlayer = entityandhudRecordData:GetShowEntityRecord(E.CameraSystemShowEntityType.OtherPlayer)
  end
  Z.LuaBridge.SetExchangeEntityShow(E.CameraSystemShowEntityType.OtherPlayer, showOtherPlayer)
end
local ret = {
  AsyncSendExchange = asyncSendExchange,
  CloseExchangeView = closeExchangeView,
  GetGoodsIdListByShopId = getGoodsIdListByShopId,
  GetConsumeItemDataListByGoodsId = getConsumeItemDataListByGoodsId,
  OpenExchangeView = openExchangeView,
  OpenExchangeViewByInteration = openExchangeViewByInteration,
  OpenExchangeViewByFunctionId = openExchangeViewByFunctionId,
  RegGoodsChangeWatcherByShopId = regGoodsChangeWatcherByShopId,
  UnregGoodsChangeWatcherByShopId = unregGoodsChangeWatcherByShopId,
  GetExchangeLimitType = getExchangeLimitType,
  ResetEntityAndUIVisible = resetEntityAndUIVisible,
  IsUpperLimmit = isUpperLimmit
}
return ret
