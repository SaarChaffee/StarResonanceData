local itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
local heroData = Z.DataMgr.Get("hero_dungeon_main_data")
local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
local openHeroView = function()
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if funcVM.CheckFuncCanUse(E.FunctionID.HeroDungeon) then
    if heroData.FunctionId == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonNormal") then
      Z.UIMgr:OpenView("hero_dungeon_instability_main")
    elseif heroData.FunctionId == Z.PbEnum("EFunctionType", "FunctionTypeHeroDungeonChallenge") then
      Z.UIMgr:OpenView("hero_dungeon_main")
    end
  end
end
local closeHeroView = function()
  Z.UIMgr:CloseView("hero_dungeon_main")
end
local closeHeroInstabilityView = function()
  Z.UIMgr:CloseView("hero_dungeon_instability_main")
end
local openAffixPopupView = function(viewData)
  Z.UIMgr:OpenView("hero_dungeon_affix_popup", viewData)
end
local closeAffixPopupView = function()
  Z.UIMgr:CloseView("hero_dungeon_affix_popup")
end
local openScorePopupView = function(viewData)
  Z.UIMgr:OpenView("hero_dungeon_score_popup", viewData)
end
local closeScorePopupView = function()
  Z.UIMgr:CloseView("hero_dungeon_score_popup")
end
local openDungeonOpenView = function(data)
  Z.UIMgr:OpenView("hero_dungeon_open_window", data)
end
local closeDungeonOpenView = function()
  Z.UIMgr:CloseView("hero_dungeon_open_window")
end
local openTargetPopupView = function(dungeonId)
  Z.UIMgr:OpenView("hero_dungeon_target_popup", {dungeonId = dungeonId})
end
local closeTargetPopupView = function()
  Z.UIMgr:CloseView("hero_dungeon_target_popup")
end
local openKeyPopupView = function(viewData)
  Z.UIMgr:OpenView("hero_dungeon_key_tips", viewData, "hero_dungeon_instability_main")
end
local closeKeyPopupView = function()
  Z.UIMgr:CloseView("hero_dungeon_key_tips")
end
local getChallengeHeroDungeonTarget = function(dungeonId)
  local targetList = {}
  local groupId = 0
  local cHeroDungeonCfg = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(dungeonId)
  if cHeroDungeonCfg then
    groupId = cHeroDungeonCfg.DungeonGroup
    local heroDungeonTargetCfg = Z.TableMgr.GetTable("ChallengeHeroDungeonTargetTableMgr").GetRow(cHeroDungeonCfg.DungeonGroup)
    if heroDungeonTargetCfg then
      for _, v in ipairs(heroDungeonTargetCfg.TargetAward) do
        local targetId = v[1]
        local awardId = v[2]
        table.insert(targetList, {targetId = targetId, awardId = awardId})
      end
    end
  end
  return targetList, groupId
end
local getChallengeHeroDungeonProbability = function(dungeonId)
  local buffCount = 0
  local buffId = 0
  local clothItemId = 0
  local maxBuffCount = 0
  local upItemId = 0
  local cHeroDungeonCfg = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(dungeonId)
  if cHeroDungeonCfg then
    local heroDungeonTargetCfg = Z.TableMgr.GetTable("ChallengeHeroDungeonTargetTableMgr").GetRow(cHeroDungeonCfg.DungeonGroup)
    if heroDungeonTargetCfg and 0 < #heroDungeonTargetCfg.TargetAward then
      for _, v in pairs(heroDungeonTargetCfg.TargetAward) do
        if v[3] ~= 0 then
          buffId = v[3]
        end
      end
      local gender = Z.ContainerMgr.CharSerialize.charBase.gender
      clothItemId = gender == 1 and heroDungeonTargetCfg.FashionAwardItemId[1] or heroDungeonTargetCfg.FashionAwardItemId[2]
      upItemId = heroDungeonTargetCfg.PropUpItemId
      local buffData = Z.BuffMgr:GetBuffData(Z.EntityMgr.PlayerUuid, buffId)
      if buffData then
        buffCount = buffData.Layer
      end
      if buffId and 0 < buffId then
        local buffCfg = Z.TableMgr.GetTable("BuffTableMgr").GetRow(buffId)
        if buffCfg then
          maxBuffCount = buffCfg.RepeatAddRule[2]
        end
      end
    end
  end
  return buffId, buffCount, maxBuffCount, clothItemId, upItemId
end
local asyncStartEnterDungeon = function(dungeonId, affix, cancelSource, selectType, heroKeyItemUuid)
  local ret = enterdungeonsceneVm.AsyncCreateLevel(heroData.FunctionId, dungeonId, cancelSource:CreateToken(), affix, nil, selectType, heroKeyItemUuid)
  if not heroData.IsHaveAward and ret == 0 then
    if heroData.IsChellange then
      Z.TipsVM.ShowTipsLang(130011)
    else
      Z.TipsVM.ShowTipsLang(130012)
    end
  end
end
local asyncStartEnterDungeonByToken = function(dungeonId, affix, cancelToken)
  local ret = enterdungeonsceneVm.AsyncCreateLevel(heroData.FunctionId, dungeonId, cancelToken, affix)
  return ret
end
local getItemShowData = function(configId)
  local itemTableRow = itemTableMgr_.GetRow(configId)
  return itemTableRow
end
local getNowAwardCount = function()
  local nomarlPassCount = 0
  if Z.ContainerMgr.CharSerialize.dungeonList.normalDungeonPassCount then
    nomarlPassCount = nomarlPassCount + Z.ContainerMgr.CharSerialize.dungeonList.normalDungeonPassCount
  end
  return heroData:GetNormalHeroAwardCount() - nomarlPassCount
end
local dungeonPeopleCount = function(dungeonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local tabData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if tabData then
    local limitedArray = tabData.LimitedNum
    local minCount = limitedArray[1] and limitedArray[1] or 1
    local maxCount = limitedArray[2] and limitedArray[2] or 4
    data:SetBeginCount(minCount, maxCount)
    for _, v in pairs(tabData.Condition) do
      if v[1] == 4 then
        data:SetNowGs(v[2])
        break
      end
    end
  end
end
local setRecommendFightValue = function(dungeonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local tabData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if tabData then
    data:SetRecommendFightValue(tabData.RecommendFightValue)
  end
end
local isHeroDungeonNormalScene = function()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < curDungeonId then
    local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
    if cfg and cfg.PlayType == E.DungeonType.HeroNormalDungeon then
      return true
    end
  end
  return false
end
local isHeroChallengeDungeonScene = function()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < curDungeonId then
    local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
    if cfg and cfg.PlayType == E.DungeonType.HeroChallengeDungeon then
      return true
    end
  end
  return false
end
local isUnionHuntDungeonScene = function()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < curDungeonId then
    local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
    if cfg and cfg.PlayType == E.DungeonType.UnionHunt then
      return true
    end
  end
  return false
end
local isUnlockDungeonId = function(dungeonId)
  local data = Z.ContainerMgr.CharSerialize.challengeDungeonInfo
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if cfg then
    for _, v in ipairs(cfg.Condition) do
      if v[1] == E.DungeonCondition.DungeonConditionalLimitations and not data.dungeonInfo[v[2]] then
        return false, v[1], nil
      end
      if v[1] == E.DungeonCondition.DungeonScoreConditionalLimitations and (not data.dungeonInfo[v[2]] or data.dungeonInfo[v[2]].score < v[3]) then
        local param = {}
        param.val = v[3]
        local des
        Z.TipsVM.GetMessageContent(130013, param)
        return false, v[1], des
      end
      if v[1] == E.DungeonCondition.SeasonTimeOffset or v[1] == E.DungeonCondition.TimeIntervalConditionalLimitations then
        local check, des = Z.ConditionHelper.GetSingleConditionDesc(v[1], v[2], v[3])
        if not check then
          return check, v[1], des
        end
      end
    end
  end
  return true, nil, nil
end
local getHighestScore = function(dungonId)
  local dungeonList = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonInfo
  if not dungeonList[dungonId] or dungeonList[dungonId].score <= 0 then
    return false
  else
    return dungeonList[dungonId].score
  end
end
local setAffix = function(dungonId, newIdList)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  data.AffixDic[dungonId] = newIdList
end
local getAffix = function(dungonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local list = {}
  if data.AffixDic[dungonId] == nil then
    local dungeonsList = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(dungonId, true)
    if dungeonsList then
      for _, v in ipairs(dungeonsList.Affix) do
        table.insert(list, v[1])
      end
    end
    return list
  end
  for i, v in pairs(data.AffixDic[dungonId]) do
    list[#list + 1] = tonumber(v)
  end
  return list
end
local reqExtremeSpaceAffix = function(dungonId)
  Z.CoroUtil.create_coro_xpcall(function()
    local data = Z.DataMgr.Get("hero_dungeon_main_data")
    local worldProxy = require("zproxy.world_proxy")
    local param = {}
    param.dungeonId = dungonId
    local ret = worldProxy.GetChallengeDungeonAffix(param, data.CancelSource:CreateToken())
    local list = {}
    for _, v in ipairs(ret.affix) do
      table.insert(list, v)
    end
    table.sort(list, function(a, b)
      return a < b
    end)
    data.ExtremeSpaceAffixDict_[dungonId] = list
    Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonAffixChange)
  end)()
end
local getExtremeSpaceAffix = function(dungonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  return data.ExtremeSpaceAffixDict_[dungonId]
end
local getAffixValue = function(dungonId, affixList)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local affixValueList = data:GetAffixValueList()
  if not affixValueList[dungonId] then
    affixValueList[dungonId] = {}
    local dungeonsList = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(dungonId)
    if dungeonsList then
      for _, v in ipairs(dungeonsList.Affix) do
        affixValueList[dungonId][v[1]] = v[2]
      end
      for _, v in ipairs(dungeonsList.SelectAffix) do
        affixValueList[dungonId][v[1]] = v[2]
      end
    end
    data:SetAffixValueList(affixValueList)
  end
  local value = 0
  for _, v in pairs(affixList) do
    value = value + affixValueList[dungonId][v] or 0
  end
  return value
end
local getChalleAffixValue = function(dungonId, affixList)
  return 1
end
local asyncGetAward = function(groupId, targetId, cancelToken)
  local parm = {}
  parm.groupId = groupId
  parm.targetId = targetId
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetChallengeDungeonScoreAward(parm, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local asyncGetDungeonWeekTargetAward = function(targetId, cancelToken)
  local parm = {groupId = targetId}
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetDungeonWeekTargetAward(parm, cancelToken)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local getScoreRatio = function()
  local ratio = Z.ContainerMgr.DungeonSyncData.dungeonScore.totalScore
  if ratio then
    return ratio
  end
  return 0
end
local getDungeonState = function()
  return Z.ContainerMgr.DungeonSyncData.flowInfo.state or E.DungeonState.DungeonStateNull
end
local getStartOpenTime = function()
  local readyTime = Z.ContainerMgr.DungeonSyncData.flowInfo.readyTime or 0
  local curTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local startTime = Z.Global.HeroReadyToStartTime
  return math.max(startTime - (curTime - readyTime), 0)
end
local getStartCloseTime = function()
  local curTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local playTime = Z.ContainerMgr.DungeonSyncData.flowInfo.playTime or 0
  return math.max(playTime - curTime, 0)
end
local getReadyStateTime = function(dungeonId)
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not cfg then
    return 0
  end
  local readyTime = Z.ContainerMgr.DungeonSyncData.flowInfo.readyTime or 0
  local curTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local time = cfg.ReadyStateTime
  return math.max(time - (curTime - readyTime), 0)
end
local asyncStartPlayingDungeon = function(cancelSource, isUseKey)
  local request = {}
  request.isUseKey = isUseKey
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.StartPlayingDungeon(request, cancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end
local getCanRewards = function(dungeonId)
  local list = {}
  local dungeonsList = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetRow(dungeonId)
  if not dungeonsList then
    return list
  end
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[dungeonId]
  if not dungeonInfo then
    return list
  end
  local targetInfo
  for _, v in pairs(dungeonsList.ScoreAward) do
    if v[1] and v[1] > 0 then
      targetInfo = Z.TableMgr.GetTable("TargetTableMgr").GetRow(v[1])
      if targetInfo then
        local targetDataDic = dungeonInfo.dungeonTargetProgress[targetInfo.Id]
        if targetDataDic and targetDataDic.awardState == 1 then
          table.insert(list, v[1])
        end
      end
    end
  end
  return list
end
local getRedCount = function(dungeonId)
  local list = getCanRewards(dungeonId)
  return table.zcount(list)
end
local refreshRed = function(dungeonId)
  local count = getRedCount(dungeonId)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.HeroDungeonReward, count)
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.DungeonRed, dungeonId, 0 < count)
end
local isRegularAffix = function(affix, affixId)
  for _, v in pairs(affix) do
    if v[1] == affixId then
      return true
    end
  end
  return false
end
local getDungeonTimerData = function(timerType)
  local timerData = {}
  if timerType == E.DungeonTimerType.DungeonTimerTypeHero then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    local dungeonsTableMgr = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr")
    local heroDungeonCfgData = dungeonsTableMgr.GetRow(dungeonId)
    local herdDungeonData = Z.DataMgr.Get("hero_dungeon_main_data")
    if isHeroChallengeDungeonScene() then
      local startTime = Z.ContainerMgr.DungeonSyncData.flowInfo.playTime
      local dungeoncfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
      if dungeoncfg and heroDungeonCfgData then
        timerData.startTime = startTime
        local dungeonTime = Z.ContainerMgr.DungeonSyncData.timerInfo.dungeonTimes
        timerData.endTime = startTime + dungeonTime
        local firstEnter = heroDungeonCfgData.LimitTime == dungeonTime
        timerData.showType = E.DungeonTimeShowType.time
        timerData.isShowScore = false
        timerData.timeType = E.DungeonTimerDirection.DungeonTimerDirectionDown
        timerData.showDead = dungeoncfg.DeathReleaseTime > 0
        timerData.timeLab = Lang("RemainTime")
        if herdDungeonData.DunegonEndTime ~= timerData.endTime and not firstEnter then
          timerData.changeTimeNumber = -1 * dungeoncfg.DeathReleaseTime
          herdDungeonData.DunegonEndTime = timerData.endTime
        end
        timerData.changeTimeType = E.DungeonTimerEffectType.EDungeonTimerEffectTypeAdd
      end
    end
    if isHeroDungeonNormalScene() and heroDungeonCfgData then
      local startTime = Z.ContainerMgr.DungeonSyncData.flowInfo.playTime
      timerData.startTime = startTime
      timerData.endTime = startTime + heroDungeonCfgData.LimitTime
      timerData.showType = E.DungeonTimeShowType.time
      timerData.isShowScore = true
      timerData.timeType = E.DungeonTimerDirection.DungeonTimerDirectionUp
      timerData.timeLab = Lang("PointTime")
    end
  end
  return timerData
end
local getAffixGS = function(dungonId)
  local affixList = getAffix(dungonId)
  local affixTableMgr = Z.TableMgr.GetTable("AffixTableMgr")
  local gs = 0
  for i, v in pairs(affixList) do
    local config = affixTableMgr.GetRow(v)
    if config and config.GsChange then
      gs = gs + config.GsChange
    end
  end
  return gs
end
local getWeekAwardCount = function(key)
  local keyCounterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(key)
  local remainCount = 0
  if keyCounterCfgData then
    local keyConter = Z.ContainerMgr.CharSerialize.counterList.counterMap[key]
    remainCount = keyCounterCfgData.Limit
    if keyCounterCfgData and keyConter then
      remainCount = keyCounterCfgData.Limit - keyConter.counter
    end
  end
  return remainCount
end
local asyncDungeonRoll = function(index, giveUp, token)
  local request = {}
  request.index = index
  request.giveUp = giveUp
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.DungeonRoll(request, token)
  Z.TipsVM.ShowTips(ret)
  return ret
end
local sendRollInfoToSystemMsg = function(id, count, headStr)
  local info = {
    Time = os.time(),
    Type = E.ESystemTipInfoType.ItemInfo,
    Content = count,
    Id = id,
    HeadStr = headStr
  }
  Z.VMMgr.GetVM("chat_main").SetReceiveSystemMsg(info)
end
local openProbabilityPopup = function(dungeonId)
  Z.UIMgr:OpenView("hero_dungeon_probability_popup", {dungeonId = dungeonId})
end
local closeProbabilityPopup = function()
  Z.UIMgr:CloseView("hero_dungeon_probability_popup")
end
local setProbabilityCountUI = function(count, uibinder)
  if uibinder.img_decoration_0 then
    uibinder.Ref:SetVisible(uibinder.img_decoration_0, 0 <= count)
  end
  uibinder.Ref:SetVisible(uibinder.img_decoration_1, 1 <= count)
  uibinder.Ref:SetVisible(uibinder.img_decoration_2, 2 <= count)
  uibinder.Ref:SetVisible(uibinder.img_decoration_3, 3 <= count)
  uibinder.Ref:SetVisible(uibinder.img_decoration_4, 4 <= count)
  uibinder.Ref:SetVisible(uibinder.img_decoration_5, 5 <= count)
end
local checkProbabilityHaveGet = function(dungeonId)
  local _, _, _, clothItemId, _ = getChallengeHeroDungeonProbability(dungeonId)
  local itemVM = Z.VMMgr.GetVM("items")
  local count = itemVM.GetItemTotalCount(clothItemId)
  return 0 < count, clothItemId
end
local getHeroChallengePlayingTime = function(dungeonId)
  dungeonId = dungeonId or Z.StageMgr.GetCurrentDungeonId()
  local time = 0
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if dungeonCfg then
    time = dungeonCfg.PlayingStateTime
  end
  return time
end
local ret = {
  OpenHeroView = openHeroView,
  OpenAffixPopupView = openAffixPopupView,
  OpenScorePopupView = openScorePopupView,
  OpenDungeonOpenView = openDungeonOpenView,
  OpenTargetPopupView = openTargetPopupView,
  CloseHeroView = closeHeroView,
  CloseAffixPopupView = closeAffixPopupView,
  CloseScorePopupView = closeScorePopupView,
  CloseDungeonOpenView = closeDungeonOpenView,
  CloseHeroInstabilityView = closeHeroInstabilityView,
  CloseTargetPopupView = closeTargetPopupView,
  AsyncStartPlayingDungeon = asyncStartPlayingDungeon,
  AsyncDungeonRoll = asyncDungeonRoll,
  AsyncGetDungeonWeekTargetAward = asyncGetDungeonWeekTargetAward,
  AsyncStartEnterDungeon = asyncStartEnterDungeon,
  AsyncStartEnterDungeonByToken = asyncStartEnterDungeonByToken,
  GetItemShowData = getItemShowData,
  GetNowAwardCount = getNowAwardCount,
  DungeonPeopleCount = dungeonPeopleCount,
  SetRecommendFightValue = setRecommendFightValue,
  IsHeroDungeonNormalScene = isHeroDungeonNormalScene,
  IsHeroChallengeDungeonScene = isHeroChallengeDungeonScene,
  IsUnionHuntDungeonScene = isUnionHuntDungeonScene,
  IsUnlockDungeonId = isUnlockDungeonId,
  GetHighestScore = getHighestScore,
  SetAffix = setAffix,
  GetAffix = getAffix,
  GetExtremeSpaceAffix = getExtremeSpaceAffix,
  ReqExtremeSpaceAffix = reqExtremeSpaceAffix,
  GetAffixValue = getAffixValue,
  GetChalleAffixValue = getChalleAffixValue,
  AsyncGetAward = asyncGetAward,
  GetScoreRatio = getScoreRatio,
  GetDungeonState = getDungeonState,
  GetStartOpenTime = getStartOpenTime,
  GetStartCloseTime = getStartCloseTime,
  GetCanRewards = getCanRewards,
  IsRegularAffix = isRegularAffix,
  RefreshRed = refreshRed,
  GetDungeonTimerData = getDungeonTimerData,
  GetReadyStateTime = getReadyStateTime,
  GetAffixGS = getAffixGS,
  GetWeekAwardCount = getWeekAwardCount,
  SendRollInfoToSystemMsg = sendRollInfoToSystemMsg,
  OpenKeyPopupView = openKeyPopupView,
  CloseKeyPopupView = closeKeyPopupView,
  GetChallengeHeroDungeonTarget = getChallengeHeroDungeonTarget,
  GetChallengeHeroDungeonProbability = getChallengeHeroDungeonProbability,
  OpenProbabilityPopup = openProbabilityPopup,
  CloseProbabilityPopup = closeProbabilityPopup,
  SetProbabilityCountUI = setProbabilityCountUI,
  CheckProbabilityHaveGet = checkProbabilityHaveGet,
  GetHeroChallengePlayingTime = getHeroChallengePlayingTime
}
return ret
