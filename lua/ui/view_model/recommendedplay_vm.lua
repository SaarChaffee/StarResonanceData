local RecommendedPlayVM = {}
local worldProxy = require("zproxy.world_proxy")

function RecommendedPlayVM.OpenView(id)
  Z.CoroUtil.create_coro_xpcall(function()
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    RecommendedPlayVM.AsyncGetRecommendPlayData(recommendedPlayData.CancelSource:CreateToken())
    Z.UIMgr:OpenView("recommendedplay_main", id)
  end)()
end

function RecommendedPlayVM.CheckTypeIsRed(typeID)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local seconds = recommendedPlayData.AllRedDots[typeID]
  local redDots = false
  if seconds then
    for _, thirds in pairs(seconds) do
      if thirds.isRed then
        redDots = true
        break
      else
        for _, isRed in pairs(thirds.childRed) do
          if isRed then
            redDots = true
            break
          end
        end
      end
    end
  end
  return redDots
end

function RecommendedPlayVM.CheckSecondTagIsRed(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    local thirds
    if recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]] and recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][id] then
      thirds = recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]][id]
    end
    if thirds then
      if thirds.isRed then
        return true
      else
        for _, isRed in pairs(thirds.childRed) do
          if isRed then
            return true
          end
        end
      end
    end
  end
  return false
end

function RecommendedPlayVM.CheckThirdTagIsRed(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    local config = recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]]
    local parentId
    if recommendedplayConfig.ParentId and #recommendedplayConfig.ParentId > 0 then
      parentId = recommendedplayConfig.ParentId[1]
    end
    if config and parentId and config[parentId] then
      return config[parentId].childRed[id]
    end
  end
  return false
end

function RecommendedPlayVM.CheckRedById(id)
  local recommendedplayConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if recommendedplayConfig then
    local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
    local config = recommendedPlayData.AllRedDots[recommendedplayConfig.Type[1]]
    if not config then
      return false
    end
    if config[id] then
      return config[id].isRed
    end
    local parentId
    if recommendedplayConfig.ParentId and #recommendedplayConfig.ParentId > 0 then
      parentId = recommendedplayConfig.ParentId[1]
    end
    if parentId and config[parentId] and config[parentId].childRed[id] then
      return config[parentId].childRed[id]
    end
  end
  return false
end

function RecommendedPlayVM.GetRecommendSurpluseCount(config)
  local count = -1
  if config.FunctionId == E.FunctionID.HeroDungeon then
    count = 0
    local thirdConfigs = Z.DataMgr.Get("recommendedplay_data"):GetThirdTagsById(config.Id)
    if thirdConfigs then
      for _, value in pairs(thirdConfigs) do
        count = count + RecommendedPlayVM.GetRecommendSurpluseCount(value)
      end
    end
  elseif config.FunctionId == E.FunctionID.HeroDungeonDiNa or config.FunctionId == E.FunctionID.HeroDungeonJuTaYiJi or config.FunctionId == E.FunctionID.HeroDungeonJuLongZhuaHen or config.FunctionId == E.FunctionID.HeroDungeonKaNiMan then
    local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(config.RelatedDungeonId)
    if dungeonData then
      local dungeonNormalCounterId = dungeonData.CountLimit
      local limtCount = Z.CounterHelper.GetCounterLimitCount(dungeonNormalCounterId)
      count = Z.CounterHelper.GetCounterResidueLimitCount(dungeonNormalCounterId, limtCount)
    end
  elseif config.FunctionId == E.FunctionID.WorldEvent then
    count = Z.ContainerMgr.CharSerialize.worldEventMap.acceptCount
  elseif config.FunctionId == E.FunctionID.UnionTask then
    local unionTaskVM = Z.VMMgr.GetVM("union_task")
    if Z.TimeTools.Now() / 1000 >= unionTaskVM:GetCanGetRewardTime() then
      count = 1
    else
      count = unionTaskVM:GetHasSend() and 0 or 1
    end
  elseif config.FunctionId == E.FunctionID.ExploreMonsterElite then
    count = Z.VMMgr.GetVM("items").GetItemTotalCount(Z.MonsterHunt.MonsterHuntEliteBootyKeyId)
  elseif config.FunctionId == E.FunctionID.ExploreMonsterBoss then
    count = Z.VMMgr.GetVM("items").GetItemTotalCount(Z.MonsterHunt.MonsterHuntBossBootyKeyId)
  elseif config.FunctionId == E.FunctionID.WorldBoss then
    local countID = Z.WorldBoss.WorldBossAwardCountId
    local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
    count = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  elseif config.FunctionId == E.FunctionID.SeasonBattlePass then
    count = 0
    local seasonActivationVm = Z.VMMgr.GetVM("season_activation")
    local awardData = seasonActivationVm.GetActivationAwards()
    local maxProgress = 0
    if next(awardData) then
      maxProgress = awardData[#awardData - 1].Activation
    end
    if maxProgress > Z.ContainerMgr.CharSerialize.seasonActivation.activationPoint then
      count = 1
    end
  elseif config.FunctionId == E.FunctionID.UnionWarDance then
    count = RecommendedPlayVM.GetUnionActivityCount(E.FunctionID.UnionWarDance)
  elseif config.FunctionId == E.FunctionID.UnionHunt then
    count = RecommendedPlayVM.GetUnionActivityCount(E.FunctionID.UnionHunt)
  else
    local leisureActivityConfig = Z.DataMgr.Get("recommendedplay_data"):GetRecommendedPlayConfigByFunctionId(E.FunctionID.LeisureActivities)
    if config.ParentId ~= nil and config.ParentId[1] ~= nil and leisureActivityConfig ~= nil and config.ParentId[1] == leisureActivityConfig.Id then
      local state = RecommendedPlayVM.GetActivityState(config.Id)
      if state == E.LeisureActivityState.TodayNotOpen then
        count = 0
      else
        count = 1
      end
    end
  end
  return count
end

function RecommendedPlayVM.CheckServerDataShow(functionID)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local config = recommendedPlayData:GetRecommendedPlayConfigByFunctionId(functionID)
  if config == nil then
    logError("RecommendedData \233\133\141\231\189\174\228\184\186\231\169\186, FunctionID : " .. functionID)
    return false
  end
  local serverTimeData = recommendedPlayData:GetServerData(E.SeasonActFuncType.Recommend, config.Id)
  if serverTimeData and Z.TimeTools.Now() / 1000 >= serverTimeData.startTimestamp and Z.TimeTools.Now() / 1000 <= serverTimeData.endTimestamp then
    return true
  end
  return false
end

function RecommendedPlayVM.CheckShowMainIconEffect()
  if RecommendedPlayVM.CheckServerDataShow(E.FunctionID.WorldBoss) then
    local bossRed_ = require("rednode.world_boss_red")
    if (bossRed_.HasScoreAwardRed() or bossRed_.HasProgressRed() or bossRed_.CheckHasAwardInOpenTime()) and not bossRed_.RedChecked() then
      return true
    end
  end
  local unionRed_ = require("rednode.union_red")
  if unionRed_.RefreshUnionWarDanceRed() and not unionRed_.UnionWarDanceRedChecked() then
    return true
  end
  if (unionRed_.RefreshUnionHuntRed() or unionRed_.RefreshUnionHuntRecommendRed()) and not unionRed_.UnionHuntRedChecked() then
    return true
  end
  return false
end

function RecommendedPlayVM.GetUnionActivityCount(functionID)
  local unionActivityData = Z.DataMgr.Get("union_activity_data")
  local countid = unionActivityData:GetCounterByFuncID(functionID)
  if countid == 0 then
    return 0
  end
  local maxLimitNum = 0
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countid)
  local normalAwardCount = 0
  local nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countid] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countid].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  return normalAwardCount
end

function RecommendedPlayVM.GetActivityState(id)
  local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
  if config == nil then
    return E.LeisureActivityState.TodayNotOpen
  end
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local startTime, endTime = recommendedPlayData:GetActivityStartAndEndTime(E.SeasonActFuncType.Recommend, id)
  if startTime ~= nil and endTime ~= nil then
    local curTime = math.floor(Z.TimeTools.Now() / 1000)
    if startTime <= curTime and endTime >= curTime then
      return E.LeisureActivityState.TodayOpenAndCurOpen
    elseif startTime > curTime then
      local isSameDay = Z.TimeTools.CheckIsSameDay(startTime, curTime)
      if isSameDay then
        return E.LeisureActivityState.TodayOpen
      else
        return E.LeisureActivityState.TodayNotOpen
      end
    elseif endTime < curTime then
      local isSameDay = Z.TimeTools.CheckIsSameDay(endTime, curTime)
      if isSameDay then
        return E.LeisureActivityState.TodayOpen
      else
        return E.LeisureActivityState.TodayNotOpen
      end
    end
  else
    return E.LeisureActivityState.TodayOpen
  end
end

function RecommendedPlayVM.StartTimer()
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local minTime
  local needCheckActivities = {}
  local leisureActivityConfig = recommendedPlayData:GetRecommendedPlayConfigByFunctionId(E.FunctionID.LeisureActivities)
  if leisureActivityConfig then
    local allLeisureActivityConfigs = recommendedPlayData:GetThirdTagsById(leisureActivityConfig.Id)
    if allLeisureActivityConfigs then
      local curTime = math.floor(Z.TimeTools.Now() / 1000)
      for _, v in pairs(allLeisureActivityConfigs) do
        local startTime, endTime = recommendedPlayData:GetActivityStartAndEndTime(E.SeasonActFuncType.Recommend, v.Id)
        if startTime ~= nil and endTime ~= nil and recommendedPlayData:GetLocalSave(v.Id) then
          if curTime <= startTime then
            if minTime == nil then
              minTime = startTime - curTime
              needCheckActivities = {
                [1] = {isStart = true, config = v}
              }
            elseif minTime > startTime - curTime then
              minTime = startTime - curTime
              needCheckActivities = {
                [1] = {isStart = true, config = v}
              }
            elseif startTime - curTime == minTime then
              table.insert(needCheckActivities, {isStart = true, config = v})
            end
          end
          if curTime <= endTime then
            if minTime == nil then
              minTime = endTime - curTime
              needCheckActivities = {
                [1] = {isStart = false, config = v}
              }
            elseif minTime > endTime - curTime then
              minTime = endTime - curTime
              needCheckActivities = {
                [1] = {isStart = false, config = v}
              }
            elseif endTime - curTime == minTime then
              table.insert(needCheckActivities, {isStart = false, config = v})
            end
          end
        end
      end
    end
  end
  recommendedPlayData.TimerMgr:Clear()
  if minTime then
    recommendedPlayData.TimerMgr:StartTimer(function()
      for _, activityInfo in ipairs(needCheckActivities) do
        if activityInfo.isStart then
          local inviteFunc = function(callData, flag, cancelSource)
            if callData ~= nil and flag then
              Z.VMMgr.GetVM("quick_jump").DoJumpByConfigParam(callData.QuickJumpType, callData.QuickJumpParam, {
                DynamicFlagName = callData.Name,
                isShowRedInfo = false
              })
            end
          end
          local info = {
            charId = "",
            tipsType = E.InvitationTipsType.LeisureActivity,
            content = Lang("ActNotice", {
              val = activityInfo.config.Name
            }),
            cd = Z.Global.ActNoticeTime,
            func = inviteFunc,
            funcParam = activityInfo.config
          }
          Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
        end
      end
      RecommendedPlayVM.StartTimer()
      RecommendedPlayVM.CheckLeisureActivitiesRed()
    end, minTime)
  end
end

function RecommendedPlayVM.CheckLeisureActivitiesRed()
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local leisureActivityConfig = recommendedPlayData:GetRecommendedPlayConfigByFunctionId(E.FunctionID.LeisureActivities)
  if leisureActivityConfig then
    local allLeisureActivityConfigs = recommendedPlayData:GetThirdTagsById(leisureActivityConfig.Id)
    if allLeisureActivityConfigs then
      local curTime = Z.TimeTools.Now() / 1000
      for _, v in pairs(allLeisureActivityConfigs) do
        local startTime, endTime = recommendedPlayData:GetActivityStartAndEndTime(E.SeasonActFuncType.Recommend, v.Id)
        if startTime ~= nil and endTime ~= nil and recommendedPlayData:GetLocalSave(v.Id) then
          if curTime >= startTime and curTime <= endTime then
            Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, v.FunctionId, true)
          else
            Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, v.FunctionId, false)
          end
        else
          Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, v.FunctionId, false)
        end
      end
    end
  end
end

function RecommendedPlayVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function RecommendedPlayVM.AsyncGetRecommendPlayData(cancelSource)
  local request = {}
  local reply = worldProxy.GetRecommendPlayData(request, cancelSource)
  Z.DIServiceMgr.RecommendedPlayService:ClearServerData()
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  if RecommendedPlayVM.CheckReply(reply.errCode) then
    recommendedPlayData:SetServerData(reply.recommendPlayData)
    local datas = {}
    local datasCount = 0
    for k, v in pairs(reply.recommendPlayData) do
      datasCount = datasCount + 1
      local startTime, endTime = RecommendedPlayVM.GetTimeStampByServerData(v)
      datas[datasCount] = {
        [1] = k,
        [2] = startTime,
        [3] = endTime
      }
    end
    Z.DIServiceMgr.RecommendedPlayService:SetServerData(datas)
    RecommendedPlayVM.StartTimer()
    RecommendedPlayVM.CheckLeisureActivitiesRed()
    return true
  end
  recommendedPlayData:SetServerData({})
  return false
end

function RecommendedPlayVM.GetTimeStampByServerData(serverData)
  local startTime = serverData.startTimestamp
  local endTime = serverData.endTimestamp
  if serverData.timerType ~= E.TimerType.FixedTime then
    if serverData.curType == E.TimerExeType.Start or serverData.curType == E.TimerExeType.CycleStart then
      startTime = serverData.lastTimeStamp
      endTime = serverData.lastEndTimeStamp
    elseif serverData.curType == E.TimerExeType.End or serverData.curType == E.TimerExeType.CycleEnd then
      startTime = serverData.nextTimeStamp
      endTime = serverData.nextEndTimeStamp
    end
  end
  return startTime, endTime
end

return RecommendedPlayVM
