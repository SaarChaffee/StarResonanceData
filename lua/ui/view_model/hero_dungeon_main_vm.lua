local itemTableMgr_ = Z.TableMgr.GetTable("ItemTableMgr")
local heroData = Z.DataMgr.Get("hero_dungeon_main_data")
local enterdungeonsceneVm = Z.VMMgr.GetVM("ui_enterdungeonscene")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")
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
local openBeginReadyView = function()
  Z.UIMgr:OpenView("hero_dungeon_begin_ready_tpl")
end
local closeBeginReadyView = function()
  Z.UIMgr:CloseView("hero_dungeon_begin_ready_tpl")
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
local asyncStartEnterDungeon = function(dungeonId, affix, cancelSource, selectType, heroKeyItemUuid, masterModeDiff)
  local ret = enterdungeonsceneVm.AsyncCreateLevel(heroData.FunctionId, dungeonId, cancelSource:CreateToken(), affix, nil, selectType, heroKeyItemUuid, masterModeDiff)
  if not heroData.IsHaveAward and ret == 0 then
    if heroData.IsChellange then
      Z.TipsVM.ShowTipsLang(130011)
    else
      Z.TipsVM.ShowTipsLang(130012)
    end
  end
end
local asyncStartEnterDungeonByToken = function(dungeonId, affix, cancelToken, masterModeDiff)
  local ret = enterdungeonsceneVm.AsyncCreateLevel(heroData.FunctionId, dungeonId, cancelToken, affix, masterModeDiff)
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
local checkDungeonIsComplete = function(dungeonId)
  return Z.ContainerMgr.CharSerialize.dungeonList.completeDungeon[dungeonId] ~= nil
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
local setRecommendFightValue = function(dungeonId, diff)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  if diff and 0 < diff then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][diff]
    local tabData = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    if tabData then
      data:SetRecommendFightValue(tabData.RecommendFightValue)
    end
  else
    local tabData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if tabData then
      data:SetRecommendFightValue(tabData.RecommendFightValue)
    end
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
local isMasterChallengeDungeonScene = function()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < curDungeonId then
    local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
    if cfg and cfg.PlayType == E.DungeonType.MasterChallengeDungeon then
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
        local des = Z.TipsVM.GetMessageContent(130013, param)
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
local reqExtremeSpaceAffix = function(dungonId, diff)
  Z.CoroUtil.create_coro_xpcall(function()
    local data = Z.DataMgr.Get("hero_dungeon_main_data")
    local worldProxy = require("zproxy.world_proxy")
    local param = {}
    param.dungeonId = dungonId
    param.diff = diff
    local ret = worldProxy.GetChallengeDungeonAffix(param, data.CancelSource:CreateToken())
    local list = {}
    for _, v in ipairs(ret.affix) do
      table.insert(list, v)
    end
    table.sort(list, function(a, b)
      return a < b
    end)
    if data.ExtremeSpaceAffixDict_[dungonId] == nil then
      data.ExtremeSpaceAffixDict_[dungonId] = {}
    end
    data.ExtremeSpaceAffixDict_[dungonId][diff] = list
    Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonAffixChange)
  end)()
end
local getExtremeSpaceAffix = function(dungonId, diff)
  diff = diff or 1
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  return data.ExtremeSpaceAffixDict_[dungonId][diff]
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
  Z.RedPointMgr.UpdateNodeCount(E.RedType.HeroDungeonReward, count)
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
local getCurMasterChallengeDungeonId = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
  local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][diff]
  return masterChallenDungeonId
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
        local timerInfo = Z.ContainerMgr.DungeonSyncData.timerInfo
        timerData.endTime = startTime + timerInfo.dungeonTimes
        if timerInfo.direction == E.DungeonTimerDirection.DungeonTimerDirectionDown then
          timerData.endTime = timerData.endTime + timerInfo.pauseTotalTime
        end
        local firstEnter = heroDungeonCfgData.LimitTime == timerInfo.dungeonTimes
        timerData.showType = E.DungeonTimeShowType.time
        timerData.isShowScore = false
        timerData.timeType = Z.ContainerMgr.DungeonSyncData.timerInfo.direction
        timerData.showDead = dungeoncfg.DeathReleaseTime > 0
        timerData.timeLab = Lang("DungeonShowTime")
        timerData.lookType = Z.ContainerMgr.DungeonSyncData.timerInfo.outLookType
        timerData.pauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTime
        timerData.totalPauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTotalTime
        timerData.curPauseTimestamp = Z.ContainerMgr.DungeonSyncData.timerInfo.curPauseTimestamp
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
      timerData.timeType = Z.ContainerMgr.DungeonSyncData.timerInfo.direction
      timerData.lookType = Z.ContainerMgr.DungeonSyncData.timerInfo.outLookType
      timerData.timeLab = Lang("DungeonShowTime")
      timerData.pauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTime
      timerData.totalPauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTotalTime
      timerData.curPauseTimestamp = Z.ContainerMgr.DungeonSyncData.timerInfo.curPauseTimestamp
    end
    if isMasterChallengeDungeonScene() and heroDungeonCfgData then
      local direction = Z.ContainerMgr.DungeonSyncData.timerInfo.direction
      local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
      local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][diff]
      local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId, true)
      local startTime = Z.ContainerMgr.DungeonSyncData.flowInfo.playTime
      local pauseTotalTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTotalTime
      timerData.startTime = startTime
      timerData.endTime = startTime + Z.ContainerMgr.DungeonSyncData.timerInfo.dungeonTimes
      if direction == E.DungeonTimerDirection.DungeonTimerDirectionDown then
        timerData.endTime = timerData.endTime + pauseTotalTime
      end
      timerData.showType = E.DungeonTimeShowType.time
      timerData.isShowScore = false
      if masterChallengeDungeonRow then
        timerData.showDead = masterChallengeDungeonRow.DeathReleaseTime > 0
        timerData.timeLab = Lang("DungeonShowTime")
      end
      local changeTimeNumber = Z.ContainerMgr.DungeonSyncData.timerInfo.changeTime
      if changeTimeNumber ~= 0 then
        timerData.changeTimeNumber = math.abs(changeTimeNumber)
        herdDungeonData.DunegonEndTime = timerData.endTime
      end
      if herdDungeonData.DunegonEndTime == 0 then
        timerData.isShowStartAnim = true
      end
      if herdDungeonData.DunegonEndTime ~= timerData.endTime then
        herdDungeonData.DunegonEndTime = timerData.endTime
      end
      timerData.changeTimeType = E.DungeonTimerEffectType.EDungeonTimerEffectTypeAdd
      timerData.timeType = direction
      timerData.lookType = Z.ContainerMgr.DungeonSyncData.timerInfo.outLookType
      timerData.timeLab = Lang("DungeonShowTime")
      timerData.pauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTime
      timerData.totalPauseTime = Z.ContainerMgr.DungeonSyncData.timerInfo.pauseTotalTime
      timerData.curPauseTimestamp = Z.ContainerMgr.DungeonSyncData.timerInfo.curPauseTimestamp
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
local isInDungeonMultiaAward = function()
  local res = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrHeroDungeonMultiaAward, E.ETempAttrType.TempAttrGlobal, 0)
  return res ~= 0
end
local asyncCheckAndUseMultiaItem = function(cancelToken)
  local name = ""
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(E.DungeonMultiAwardItemId)
  if itemRow then
    name = itemRow.Name
  end
  if isInDungeonMultiaAward() then
    local param = {
      item = {name = name}
    }
    Z.TipsVM.ShowTipsLang(1004108, param)
  else
    local itemsVM = Z.VMMgr.GetVM("items")
    local param = {
      item = {name = name}
    }
    if itemsVM.GetItemTotalCount(E.DungeonMultiAwardItemId) <= 0 then
      Z.TipsVM.ShowTipsLang(1004107, param)
    else
      local useItemParam = itemsVM.AssembleUseItemParam(E.DungeonMultiAwardItemId, nil, 1)
      itemsVM.AsyncUseItemByUuid(useItemParam, cancelToken)
    end
  end
end
local getDeadreduceTime = function()
  local curDungeonId = Z.StageMgr.GetCurrentDungeonId()
  local deadreduceTime = 0
  if curDungeonId <= 0 then
    return deadreduceTime
  end
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(curDungeonId)
  if not cfg then
    return deadreduceTime
  end
  if cfg.PlayType == E.DungeonType.HeroChallengeDungeon then
    return cfg.DeathReleaseTime
  end
  if cfg.PlayType == E.DungeonType.MasterChallengeDungeon then
    local diff = Z.ContainerMgr.DungeonSyncData.dungeonSceneInfo.difficulty
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[curDungeonId][diff]
    local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    if not masterChallengeDungeonRow then
      return deadreduceTime
    end
    return masterChallengeDungeonRow.DeathReleaseTime
  end
  return deadreduceTime
end
local openMaseterScoreView = function(isShowSceneMask)
  Z.UIMgr:OpenView("hero_dungeon_master_popup", isShowSceneMask)
end
local closeMaseterScoreView = function()
  Z.UIMgr:CloseView("hero_dungeon_master_popup")
end
local checkAnyMasterDungeonOpen = function()
  for dungeonID, _ in pairs(MasterChallenDungeonTableMap.DungeonId) do
    if isUnlockDungeonId(dungeonID) then
      return true
    end
  end
  return false
end
local getHeroDungeonTypeName = function(dungeonId, diff)
  local dungeonTypeName = ""
  local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][diff]
  local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
  if masterChallengeDungeonRow then
    dungeonTypeName = masterChallengeDungeonRow.DungeonTypeName
  end
  return dungeonTypeName
end
local getPlayerSeasonMasterDungeonScore = function(seasonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local scoreData = data:GetMasterDungeonScore(seasonId)
  local score = 0
  for _, value in pairs(scoreData) do
    score = score + value.score
  end
  return score
end
local getPlayerSeasonMasterDungeonScoreWithColor = function(score)
  score = score or 0
  local color
  local level = 1
  for _, value in ipairs(Z.GlobalDungeon.MasterSingleDungeonScoreLevel) do
    if score >= value[1] then
      level = value[2]
    end
  end
  for _, value in ipairs(Z.GlobalDungeon.MasterScoreLevelColor) do
    if level == tonumber(value[1]) then
      color = value[2]
    end
  end
  return string.format("<color=%s>%s</color>", color, score)
end
local getPlayerSeasonMasterDungeonTotalScoreWithColor = function(score)
  score = score or 0
  local color
  local level = 1
  for _, value in ipairs(Z.GlobalDungeon.MasterTotolDungeonScoreLevel) do
    if score >= value[1] then
      level = value[2]
    end
  end
  for _, value in ipairs(Z.GlobalDungeon.MasterScoreLevelColor) do
    if level == tonumber(value[1]) then
      color = value[2]
    end
  end
  return string.format("<color=%s>%s</color>", color, score)
end
local checkGetSeasonScoreAwrard = function(index)
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo.seasonAwards then
    return seasonMasterDungeonInfo.seasonAwards[index - 1] == 1
  end
  return false
end
local checkMasterDungeonScoreNewRecord = function(dungeonId)
  local data = Z.DataMgr.Get("hero_dungeon_main_data")
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local lastMaxScore = getPlayerSeasonMasterDungeonScore(seasonId)
  data:UpdateMasterDungeonScore(dungeonId)
  local newMaxScore = getPlayerSeasonMasterDungeonScore(seasonId)
  if lastMaxScore >= newMaxScore then
    return false, 0
  end
  return true, newMaxScore - lastMaxScore
end
local getDungeonDiffScore = function(dungeonId, diff)
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo.masterModeDiffInfo and seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId] then
    local dungeonInfo = seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId].dungeonInfo[diff]
    if dungeonInfo then
      return dungeonInfo.score
    end
  end
  return 0
end
local getMasterDungeonIsComplete = function(dungeonId, diff)
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo.masterModeDiffInfo and seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId] then
    local dungeonInfo = seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId].dungeonInfo[diff]
    if dungeonInfo then
      return dungeonInfo.completeCount > 0
    end
  end
  return false
end
local getMasterDungeonFasterTime = function(dungeonId)
  local time = 0
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo.masterModeDiffInfo and seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId] then
    for diff, dungenData in pairs(seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId].dungeonInfo) do
      if time == 0 then
        time = dungenData.passTime
      end
      if time > dungenData.passTime then
        time = dungenData.passTime
      end
    end
  end
  return time
end
local getMasterDungeonMaxDiff = function(dungeonID)
  local maxDiff = 0
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  local tmpDiff = 0
  for index, value in ipairs(Z.GlobalDungeon.MasterDungeonUnlockLevel) do
    local diff = tonumber(value)
    local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(dungeonID * 100 + diff)
    if Z.ConditionHelper.CheckCondition(masterChallengeDungeonRow.Condition) and tmpDiff < diff - 1 then
      tmpDiff = diff - 1
    end
  end
  if Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId] == nil then
    return tmpDiff
  end
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId].masterModeDiffInfo
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo[dungeonID] then
    for diff, _ in pairs(seasonMasterDungeonInfo[dungeonID].dungeonInfo) do
      if diff > maxDiff then
        maxDiff = diff
      end
    end
  end
  if tmpDiff > maxDiff then
    maxDiff = tmpDiff
  end
  return maxDiff
end
local getDungeonScoreMax = function(dungonId)
  local maxScore = 0
  for _, value in pairs(MasterChallenDungeonTableMap.DungeonId[dungonId]) do
    local masterChallengeDungeonRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(value)
    if masterChallengeDungeonRow and #masterChallengeDungeonRow.Score ~= 0 and maxScore < masterChallengeDungeonRow.Score[1][4] then
      maxScore = masterChallengeDungeonRow.Score[1][4]
    end
  end
  return maxScore
end
local asyncGetMasterModeAward = function(index, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local request = {}
  request.index = index
  local ret = proxy.GetMasterModeAward(request, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local asyncSetShowMasterModeScore = function(isShow, cancelToken)
  local proxy = require("zproxy.world_proxy")
  local request = {}
  request.isShow = isShow
  local ret = proxy.SetShowMasterModeScore(request, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.MasterScoreShowRefresh, isShow)
  return true
end
local ret = {
  OpenHeroView = openHeroView,
  OpenAffixPopupView = openAffixPopupView,
  OpenScorePopupView = openScorePopupView,
  OpenDungeonOpenView = openDungeonOpenView,
  OpenTargetPopupView = openTargetPopupView,
  OpenBeginReadyView = openBeginReadyView,
  CloseHeroView = closeHeroView,
  CloseAffixPopupView = closeAffixPopupView,
  CloseScorePopupView = closeScorePopupView,
  CloseDungeonOpenView = closeDungeonOpenView,
  CloseHeroInstabilityView = closeHeroInstabilityView,
  CloseTargetPopupView = closeTargetPopupView,
  CloseBeginReadyView = closeBeginReadyView,
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
  GetHeroChallengePlayingTime = getHeroChallengePlayingTime,
  IsInDungeonMultiaAward = isInDungeonMultiaAward,
  AsyncCheckAndUseMultiaItem = asyncCheckAndUseMultiaItem,
  GetHeroDungeonTypeName = getHeroDungeonTypeName,
  GetPlayerSeasonMasterDungeonScore = getPlayerSeasonMasterDungeonScore,
  CheckAnyMasterDungeonOpen = checkAnyMasterDungeonOpen,
  GetPlayerSeasonMasterDungeonScoreWithColor = getPlayerSeasonMasterDungeonScoreWithColor,
  GetPlayerSeasonMasterDungeonTotalScoreWithColor = getPlayerSeasonMasterDungeonTotalScoreWithColor,
  OpenMaseterScoreView = openMaseterScoreView,
  CloseMaseterScoreView = closeMaseterScoreView,
  CheckGetSeasonScoreAwrard = checkGetSeasonScoreAwrard,
  IsMasterChallengeDungeonScene = isMasterChallengeDungeonScene,
  GetMasterDungeonMaxDiff = getMasterDungeonMaxDiff,
  CheckMasterDungeonScoreNewRecord = checkMasterDungeonScoreNewRecord,
  GetDungeonScoreMax = getDungeonScoreMax,
  GetMasterDungeonFasterTime = getMasterDungeonFasterTime,
  GetDungeonDiffScore = getDungeonDiffScore,
  AsyncGetMasterModeAward = asyncGetMasterModeAward,
  AsyncSetShowMasterModeScore = asyncSetShowMasterModeScore,
  CheckDungeonIsComplete = checkDungeonIsComplete,
  GetMasterDungeonIsComplete = getMasterDungeonIsComplete,
  GetCurMasterChallengeDungeonId = getCurMasterChallengeDungeonId,
  GetDeadreduceTime = getDeadreduceTime
}
return ret
