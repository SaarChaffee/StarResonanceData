local getBattlePassContainer = function()
  return Z.ContainerMgr.CharSerialize.seasonCenter.battlePass
end
local getBattlePassQuestContainer = function()
  return Z.ContainerMgr.CharSerialize.seasonCenter.bpQuestList
end
local getBattlePassGlobalTableInfo = function(battlePassId)
  if not battlePassId then
    logError("Battle pass id is empty!")
    return
  end
  local bpTableInfo = Z.TableMgr.GetTable("BattlePassGlobalTableMgr").GetRow(battlePassId)
  return bpTableInfo
end
local getBattlePassCardDataByLevel = function(level)
  if not level then
    return
  end
  local bpCardData = Z.TableMgr.GetTable("BattlePassCardTableMgr").GetRow(level)
  return bpCardData
end
local assemblyData = function()
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local battlePassAwardInfo = getBattlePassContainer()
  local bpCardInfo = battlePassData:GetBattlePassData(battlePassAwardInfo.id)
  for k, v in pairs(battlePassAwardInfo.award) do
    if bpCardInfo[k] then
      bpCardInfo[k].freeAwardIsReceive = v.freeAward
      if battlePassAwardInfo.isUnlock then
        bpCardInfo[k].paidAwardIsReceive = v.paidAward
      end
    end
  end
  return bpCardInfo
end
local getBattlePassShowData = function(battlePassId)
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local bpCardTableInfo = battlePassData:GetBattlePassData(battlePassId)
  local bpCardInfo = {}
  for k, v in pairs(bpCardTableInfo) do
    if v.configData.BattlePassCardId == battlePassId and v.configData.KeyAward == 1 then
      table.insert(bpCardInfo, v)
    end
  end
  table.sort(bpCardInfo, function(a, b)
    return a.configData.Id < b.configData.Id
  end)
  return bpCardInfo
end
local getBattlePassShowLocation = function()
  local battlePassInfo = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass
  for i = 1, battlePassInfo.level do
    if not battlePassInfo.award[i] then
      return i - 1
    elseif not battlePassInfo.award[i].freeAward or battlePassInfo.isUnlock and not battlePassInfo.award[i].paidAward then
      return i - 1
    end
  end
  return battlePassInfo.level - 1
end
local getSeasonCurrentWeek = function()
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local seasonWeek = battlePassData:GetSeasonWeek()
  for k, v in pairs(seasonWeek) do
    if Z.ConditionHelper.CheckSingleCondition(tonumber(v.condition[1]), false, tonumber(v.condition[2]), v.condition[3], v.condition[4]) then
      return v.index
    end
  end
  return 1
end
local getActivationTableData = function()
  local activationTableData = Z.TableMgr.GetTable("ActivationTableMgr").GetDatas()
  return activationTableData
end
local setTaskState = function(taskData, isIgnoredSort)
  local questList = getBattlePassQuestContainer()
  for k, v in pairs(questList.seasonMap) do
    if taskData[k] then
      taskData[k].award = v.award
      taskData[k].targetNum = v.targetNum
    end
  end
  local tempTable = {}
  for k, v in pairs(taskData) do
    table.insert(tempTable, v)
  end
  if not isIgnoredSort then
    table.sort(tempTable, function(a, b)
      return a.configData.PassAward > b.configData.PassAward
    end)
  end
  return tempTable
end
local getSeasonTaskByWeek = function(weekIndex, seasonId)
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local seasonData = battlePassData:GetSeasonTaskBySeasonId(seasonId)
  local weekData = {}
  for k, v in pairs(seasonData) do
    if weekIndex == 0 then
      if E.EBpDailyTaskRandom.Fixed == v.configData.DailyTaskRandom then
        v.award = 0
        v.targetNum = 0
        weekData[v.configData.TargetId] = v
      end
    elseif weekIndex == v.configData.ShowWeek then
      v.award = 0
      v.targetNum = 0
      weekData[v.configData.TargetId] = v
    end
  end
  return setTaskState(weekData)
end
local getSeasonDailyTask = function(seasonId)
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local seasonData = battlePassData:GetSeasonTaskBySeasonId(seasonId)
  local data = {}
  local questList = getBattlePassQuestContainer()
  for _, v in pairs(questList.randomMap) do
    local tableData = Z.TableMgr.GetTable("SeasonBPTaskTableMgr").GetRow(v)
    if tableData then
      local tempData = {}
      tempData.award = 0
      tempData.targetNum = 0
      tempData.configData = tableData
      data[v] = tempData
    end
  end
  for _, v in pairs(seasonData) do
    if E.EBpDailyTaskRandom.Fixed == v.configData.DailyTaskRandom then
      v.award = 0
      v.targetNum = 0
      data[v.configData.TargetId] = v
    end
  end
  return setTaskState(data)
end
local getPaymentTaskAward = function(seasonId, currentWeek)
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local taskTableData = battlePassData:GetSeasonTaskBySeasonId(seasonId)
  local taskAward = {}
  local taskData = setTaskState(taskTableData, true)
  local battlePassInfo = getBattlePassContainer()
  if not battlePassInfo.isUnlock then
    for k, v in pairs(taskData) do
      if v.configData.PassAward == 1 and currentWeek >= v.configData.ShowWeek and v.award == E.DrawState.CanDraw then
        table.insert(taskAward, v.configData.AwardId)
      end
    end
  end
  return taskAward
end
local getBattlePassPayId = function(battlePassId)
  local battlePassInfo = getBattlePassGlobalTableInfo(battlePassId)
  local payTable = {}
  if not battlePassInfo then
    return
  end
  local normalPayInfo = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(battlePassInfo.NormalPassPaymentID)
  local primePayInfo = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(battlePassInfo.PrimePassPaymentID)
  local discountPayInfo = Z.TableMgr.GetTable("PaymentTableMgr").GetRow(battlePassInfo.PassPriceDiffPaymentID)
  if normalPayInfo and primePayInfo and discountPayInfo then
    payTable.normalPayInfo = normalPayInfo
    payTable.primePayInfo = primePayInfo
    payTable.discountPayInfo = discountPayInfo
  end
  return payTable
end
local getFashionData = function(battlePassId)
  local data = {}
  local playerGender = Z.ContainerMgr.CharSerialize.charBase.gender
  local battlePassGlobaTableInfo = getBattlePassGlobalTableInfo(battlePassId)
  if battlePassGlobaTableInfo then
    local fashionId = playerGender == Z.PbEnum("EGender", "GenderMale") and battlePassGlobaTableInfo.Fashion[1] or battlePassGlobaTableInfo.Fashion[2]
    data.FashionId = fashionId[1]
  end
  return data
end
local setPlayerFashion = function(battlePassId)
  local dataList = {}
  local data = getFashionData(battlePassId)
  if not data or not next(data) then
    return
  end
  table.insert(dataList, data)
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local zList = fashionVM.WearDataListToZList(dataList)
  return zList
end
local getMaxLevel = function(battlePassId)
  if not battlePassId then
    return 0
  end
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local bpCardInfo = battlePassData:GetBattlePassData(battlePassId)
  local maxNum = 0
  if bpCardInfo and next(bpCardInfo) then
    maxNum = #bpCardInfo
  end
  return maxNum
end
local getBuyLevelAwards = function(level)
  local battlePassInfo = getBattlePassContainer()
  local awardTable = {}
  if not battlePassInfo then
    return awardTable
  end
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local cardData = battlePassData:GetBattlePassData(battlePassInfo.id)
  local targetLevel = level + battlePassInfo.level
  for i = battlePassInfo.level + 1, targetLevel do
    if cardData[i] then
      for k, v in pairs(cardData[i].configData.FreeAward) do
        table.insert(awardTable, v)
      end
      if battlePassInfo.isUnlock then
        for k, v in pairs(cardData[i].configData.PaidAward) do
          table.insert(awardTable, v)
        end
      end
    end
  end
  return awardTable
end
local openBattlePassPurchaseView = function()
  local battlePassInfo = getBattlePassContainer()
  local max = getMaxLevel(battlePassInfo.id)
  if not battlePassInfo then
    return
  end
  if max <= battlePassInfo.level then
    Z.TipsVM.ShowTips(1003001)
    return
  end
  Z.UIMgr:OpenView("battle_pass_purchase_level")
end
local getFashionName = function(battlePassId)
  local fashionData = getFashionData(battlePassId)
  local name = ""
  if not (battlePassId and fashionData) or not next(fashionData) then
    logError("Battle pass battlePassId is empty!")
    return name
  end
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(fashionData.FashionId)
  if itemTable then
    name = itemTable.Name
  end
  return name
end
local checkBPCardIsHasUnclaimedAward = function()
  local bpCardData = assemblyData()
  local bpContainer = getBattlePassContainer()
  for k, v in pairs(bpCardData) do
    if v.configData.SeasonLevel <= bpContainer.level then
      if not v.freeAwardIsReceive then
        return true
      elseif bpContainer.isUnlock and not v.paidAwardIsReceive then
        return true
      end
    end
  end
  return false
end
local checkTaskIsHasUnclaimedAward = function()
  local questList = getBattlePassQuestContainer()
  local battlePassContainer = getBattlePassContainer()
  local currentWeek = getSeasonCurrentWeek()
  for _, v in pairs(questList.seasonMap) do
    local seasonBPTaskTableData = Z.TableMgr.GetTable("SeasonBPTaskTableMgr").GetRow(v.id)
    if not seasonBPTaskTableData then
      logError("Battle pass task config is empty!")
      return false
    end
    if v.award == E.DrawState.CanDraw and currentWeek >= seasonBPTaskTableData.ShowWeek and (seasonBPTaskTableData.PassAward == 1 and battlePassContainer.isUnlock or seasonBPTaskTableData.PassAward ~= 1) then
      return true
    end
  end
  return false
end
local checkHasRewardCanReceive = function(pageIndex)
  if pageIndex == E.EBattlePassViewType.Task then
    return checkTaskIsHasUnclaimedAward()
  else
    return checkBPCardIsHasUnclaimedAward()
  end
end
local openBattlePassBuyView = function()
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "battle_pass_buy", function()
    local battlePassData = Z.DataMgr.Get("battlepass_data")
    Z.UIMgr:OpenView("battle_pass_buy")
  end)
end
local closeBattlePassBuyView = function()
  Z.UIMgr:CloseView("battle_pass_buy")
end
local asyncGetBattlePassAwardRequest = function(oneKey, level, unlock, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {
    onekey = oneKey,
    level = level,
    unlock = unlock
  }
  worldProxy.GetBattlePassAward(request, cancelToken)
end
local asyncGetBattlePassQuestRequest = function(targetId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {targetId = targetId}
  worldProxy.GetSeasonBpQuestAward(request, cancelToken)
end
local asyncPayment = function(id)
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {}
  vRequest.orderGuid = ""
  vRequest.paymentId = id
  worldProxy.Payment(vRequest)
  Z.TipsVM.ShowTips(1400001)
end
local asyncBuyBattlePassLevel = function(level, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {}
  vRequest.level = level
  local ret = worldProxy.BuyBattlePassLevel(vRequest, cancelToken)
  return ret
end
local ret = {
  GetBattlePassGlobalTableInfo = getBattlePassGlobalTableInfo,
  GetBattlePassCardDataByLevel = getBattlePassCardDataByLevel,
  AssemblyData = assemblyData,
  GetBattlePassShowData = getBattlePassShowData,
  GetBattlePassShowLocation = getBattlePassShowLocation,
  GetActivationTableData = getActivationTableData,
  GetSeasonTaskByWeek = getSeasonTaskByWeek,
  GetSeasonDailyTask = getSeasonDailyTask,
  GetPaymentTaskAward = getPaymentTaskAward,
  OpenBattlePassBuyView = openBattlePassBuyView,
  CloseBattlePassBuyView = closeBattlePassBuyView,
  GetBattlePassContainer = getBattlePassContainer,
  GetBattlePassPayId = getBattlePassPayId,
  SetPlayerFashion = setPlayerFashion,
  AsyncGetBattlePassAwardRequest = asyncGetBattlePassAwardRequest,
  AsyncPayment = asyncPayment,
  GetMaxLevel = getMaxLevel,
  OpenBattlePassPurchaseView = openBattlePassPurchaseView,
  GetBuyLevelAwards = getBuyLevelAwards,
  AsyncBuyBattlePassLevel = asyncBuyBattlePassLevel,
  AsyncGetBattlePassQuestRequest = asyncGetBattlePassQuestRequest,
  GetFashionName = getFashionName,
  CheckBPCardIsHasUnclaimedAward = checkBPCardIsHasUnclaimedAward,
  GetSeasonCurrentWeek = getSeasonCurrentWeek,
  CheckHasRewardCanReceive = checkHasRewardCanReceive
}
return ret
