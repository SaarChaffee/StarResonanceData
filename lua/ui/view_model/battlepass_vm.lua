local getCurrentBattlePassContainer = function()
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  if not battlePassData.CurBattlePassData or next(battlePassData.CurBattlePassData) == nil then
    return nil
  end
  return battlePassData.CurBattlePassData
end
local getBattlePassQuestContainer = function()
  return Z.ContainerMgr.CharSerialize.seasonCenter.bpQuestList
end
local getBattlePassGlobalTableInfo = function(battlePassId)
  if not battlePassId then
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
  local battlePassAwardInfo = getCurrentBattlePassContainer()
  if not battlePassAwardInfo then
    return
  end
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
local getBattlePassShowData = function(curBattlePassData)
  if not curBattlePassData then
    return
  end
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local bpCardTableInfo = battlePassData:GetBattlePassData(curBattlePassData.id)
  local bpCardInfo = {}
  for k, v in pairs(bpCardTableInfo) do
    if v.configData.BattlePassCardId == curBattlePassData.id and v.configData.KeyAward == 1 then
      table.insert(bpCardInfo, v)
    end
  end
  table.sort(bpCardInfo, function(a, b)
    return a.configData.Id < b.configData.Id
  end)
  return bpCardInfo
end
local getBattlePassShowLocation = function()
  local battlePassInfo = getCurrentBattlePassContainer()
  if not battlePassInfo then
    return 1
  end
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
  local battlePassInfo = getCurrentBattlePassContainer()
  if not battlePassInfo then
    return {}
  end
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
  local paymentDict = {}
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local paymentData = Z.TableMgr.GetTable("PaymentTableMgr"):GetDatas()
  for id, paymentRow in pairs(paymentData) do
    if table.zcontains(paymentRow.Platform, currentPlatform) and paymentRow.PaymentId and paymentRow.PaymentId ~= 0 then
      if paymentDict[paymentRow.PaymentId] then
        logError("currentPlatform has same paymentId")
      else
        paymentDict[paymentRow.PaymentId] = paymentRow
      end
    end
  end
  local normalPayInfo = paymentDict[battlePassInfo.NormalPassPaymentID]
  local primePayInfo = paymentDict[battlePassInfo.PrimePassPaymentID]
  local discountPayInfo = paymentDict[battlePassInfo.PassPriceDiffPaymentID]
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
    for k, v in pairs(fashionId) do
      local tempTable = {}
      tempTable.FashionId = v
      table.insert(data, tempTable)
    end
  end
  return data
end
local setPlayerFashion = function(battlePassId)
  local dataList = {}
  local data = getFashionData(battlePassId)
  if not data or not next(data) then
    return
  end
  for k, v in pairs(data) do
    table.insert(dataList, v)
  end
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
  local battlePassInfo = getCurrentBattlePassContainer()
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
  local battlePassInfo = getCurrentBattlePassContainer()
  if not battlePassInfo then
    return
  end
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
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr").GetRow(fashionData[1].FashionId)
  if itemTable then
    name = itemTable.Name
  end
  return name
end
local checkBPCardIsHasUnclaimedAward = function()
  local bpCardData = assemblyData()
  if not bpCardData then
    return false
  end
  local bpContainer = getCurrentBattlePassContainer()
  if not bpContainer then
    return false
  end
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
  local battlePassContainer = getCurrentBattlePassContainer()
  if not battlePassContainer then
    return false
  end
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
local getBpCardPrivilegesData = function(bpCardId)
  local tempPrivilegesTable = {}
  local bpCardData = getBattlePassGlobalTableInfo(bpCardId)
  local privilegeConfigTableMgr = Z.TableMgr.GetTable("PrivilegeConfigTableMgr")
  if bpCardData and next(bpCardData.PrimePassPrivilege) ~= nil then
    for k, v in pairs(bpCardData.PrimePassPrivilege) do
      local privilegeConfigData = privilegeConfigTableMgr.GetRow(v)
      if privilegeConfigData then
        table.insert(tempPrivilegesTable, privilegeConfigData)
      end
    end
  end
  if table.zcount(tempPrivilegesTable) > 0 then
    table.sort(tempPrivilegesTable, function(a, b)
      return a.Sort < b.Sort
    end)
  end
  return tempPrivilegesTable
end
local assembledBpCardPrivilegesContent = function(privilegeConfigRow)
  local content = ""
  if not privilegeConfigRow then
    return content
  end
  local privilegeTableMgr = Z.TableMgr.GetTable("PrivilegeTableMgr")
  local privilegeConfigInfo = privilegeConfigRow.PrivilegeConfig[1]
  local privilegeTableRow = privilegeTableMgr.GetRow(privilegeConfigInfo[1])
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  if table.zcount(privilegeConfigInfo) == 3 then
    local val1 = privilegeConfigInfo[2]
    local val2 = privilegeConfigInfo[3]
    if privilegeTableRow.Type == E.PrivilegeShowType.Item then
      local itemInfo = itemTableMgr.GetRow(val1)
      if itemInfo then
        val1 = itemInfo.Name
      end
      val2 = math.floor(val2 / 100)
      content = Z.Placeholder.Placeholder(privilegeTableRow.ShowWords, {val1 = val1, val2 = val2})
    elseif privilegeTableRow.Type == E.PrivilegeShowType.Count then
      content = Z.Placeholder.Placeholder(privilegeTableRow.ShowWords, {val = val2})
    end
  elseif table.zcount(privilegeConfigInfo) == 2 then
    local val = privilegeConfigInfo[2]
    if privilegeTableRow.Type == E.PrivilegeShowType.Experience then
      val = math.floor(val / 100)
    end
    content = Z.Placeholder.Placeholder(privilegeTableRow.ShowWords, {val = val})
  end
  return content
end
local openBattlePassBuyView = function()
  local curBattlePassData = getCurrentBattlePassContainer()
  if curBattlePassData == nil then
    return
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "battle_pass_buy", function()
    Z.UIMgr:OpenView("battle_pass_buy")
  end)
end
local closeBattlePassBuyView = function()
  Z.UIMgr:CloseView("battle_pass_buy")
end
local asyncGetBattlePassAwardRequest = function(bpCardId, oneKey, level, unlock, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {
    onekey = oneKey,
    level = level,
    unlock = unlock,
    id = bpCardId
  }
  local ret = worldProxy.GetBattlePassAward(request, cancelToken)
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
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
local asyncBuyBattlePassLevel = function(level, bpCardId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local vRequest = {level = level, id = bpCardId}
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
  GetCurrentBattlePassContainer = getCurrentBattlePassContainer,
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
  CheckHasRewardCanReceive = checkHasRewardCanReceive,
  GetBpCardPrivilegesData = getBpCardPrivilegesData,
  AssembledBpCardPrivilegesContent = assembledBpCardPrivilegesContent
}
return ret
