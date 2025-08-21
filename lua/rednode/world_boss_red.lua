local WorldBossRed = {}
local worldBossData = Z.DataMgr.Get("world_boss_data")
local worldBossVM = Z.VMMgr.GetVM("world_boss")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local progressCfgData = {}

function WorldBossRed.CheckLimitCount()
end

function WorldBossRed.CheckRed(isInTime, isInRecommendTime)
  if type(isInTime) ~= "boolean" then
    isInTime = nil
  end
  if type(isInRecommendTime) ~= "boolean" then
    isInRecommendTime = nil
  end
  local isRed = WorldBossRed.CheckHasAwardInOpenTime(isInTime, isInRecommendTime) and not WorldBossRed.RedChecked()
  WorldBossRed.CheckScoreAwardRed()
  WorldBossRed.CheckProgress()
  if WorldBossRed.HasScoreAwardRed() or WorldBossRed.HasProgressRed() then
    Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.WorldBoss, true)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.WorldBoss, isRed)
  end
end

function WorldBossRed.CheckScoreAwardRed()
  local awardInfo = Z.WorldBoss.WorldBossPersonalScoreAward
  local worldBossInfo = Z.ContainerMgr.CharSerialize.personalWorldBossInfo
  local receiveData = worldBossInfo.scoreAwardInfo
  for k, v in ipairs(awardInfo) do
    local score = v[1]
    local awardId = v[2]
    local redNodeName = worldBossVM:GetScoreItemRedName(score)
    Z.RedPointMgr.AddChildNodeData(E.RedType.WorldBossScoreRed, E.RedType.WorldBossScoreAwardItemRed, redNodeName)
    local curNum = worldBossInfo.score or 0
    local redCount = score <= curNum and 1 or 0
    if receiveData then
      local rewardState = receiveData[k]
      if rewardState and rewardState.awardStatus == E.ReceiveRewardStatus.Received then
        redCount = 0
      end
    end
    Z.RedPointMgr.UpdateNodeCount(redNodeName, redCount)
  end
end

function WorldBossRed.HasScoreAwardRed()
  local awardInfo = Z.WorldBoss.WorldBossPersonalScoreAward
  local worldBossInfo = Z.ContainerMgr.CharSerialize.personalWorldBossInfo
  local receiveData = worldBossInfo.scoreAwardInfo
  for k, v in ipairs(awardInfo) do
    local score = v[1]
    local curNum = worldBossInfo.score or 0
    local hasRed = score <= curNum
    if receiveData then
      local rewardState = receiveData[k]
      if rewardState and rewardState.awardStatus == E.ReceiveRewardStatus.Received then
        hasRed = false
      end
    end
    if hasRed then
      return true
    end
  end
  return false
end

function WorldBossRed.CheckProgress()
  local serveData = worldBossData:GetWorldBossInfoData()
  if serveData == nil then
    return
  end
  local stage = serveData.bossStage
  local receiveData = Z.ContainerMgr.CharSerialize.personalWorldBossInfo.bossAwardInfo
  for k, data in ipairs(progressCfgData) do
    if 1 < k then
      local redNodeName = worldBossVM:GetProgressItemRedName(k)
      Z.RedPointMgr.AddChildNodeData(E.RedType.WorldBossProgressRed, E.RedType.WorldBossProgressAwardItemRed, redNodeName)
      local redCount = 0
      if k <= stage then
        redCount = 1
        if receiveData then
          local curData = receiveData[data.Id]
          if curData and curData.awardStatus == E.ReceiveRewardStatus.Received then
            redCount = 0
          end
        end
      end
      local switchVm = Z.VMMgr.GetVM("switch")
      local isWorldBossScheduleOpen = switchVm.CheckFuncSwitch(E.FunctionID.WorldBossSchedule)
      if not isWorldBossScheduleOpen then
        redCount = 0
      end
      Z.RedPointMgr.UpdateNodeCount(redNodeName, redCount)
    end
  end
end

function WorldBossRed.HasProgressRed()
  local switchVm = Z.VMMgr.GetVM("switch")
  local isWorldBossScheduleOpen = switchVm.CheckFuncSwitch(E.FunctionID.WorldBossSchedule)
  if not isWorldBossScheduleOpen then
    return false
  end
  local serveData = worldBossData:GetWorldBossInfoData()
  if serveData == nil then
    return false
  end
  local stage = serveData.bossStage
  local receiveData = Z.ContainerMgr.CharSerialize.personalWorldBossInfo.bossAwardInfo
  for k, data in ipairs(progressCfgData) do
    if 1 < k and k <= stage then
      if receiveData then
        local curData = receiveData[data.Id]
        if curData and curData.awardStatus ~= E.ReceiveRewardStatus.Received then
          return true
        end
      else
        return true
      end
    end
  end
  return false
end

function WorldBossRed.CheckHasAwardInOpenTime(isInTime, isInRecommendTime)
  local isRed = false
  if isInTime == nil then
    isInTime = Z.TimeTools.CheckIsInTimeByTimeId(Z.WorldBoss.WorldBossOpenTimerId)
  end
  if isInRecommendTime == nil then
    local recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
    local seasonActTableRow = recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.WorldBoss)
    if seasonActTableRow == nil then
      return
    end
    isInRecommendTime = Z.TimeTools.CheckIsInTimeByTimeId(seasonActTableRow.OpenTimerId)
  end
  local countID = Z.WorldBoss.WorldBossAwardCountId
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  isRed = 0 < normalAwardCount and isInTime and isInRecommendTime
  return isRed
end

function WorldBossRed.RedChecked()
  return worldBossData:RecommendRedChecked()
end

function WorldBossRed.Init()
  progressCfgData = worldBossVM:GetStageTableData()
  
  function WorldBossRed.bossAwardInfoChange(container, dirtyKeys)
    if dirtyKeys.scoreAwardInfo or dirtyKeys.score then
      WorldBossRed.CheckRed()
    elseif dirtyKeys.bossAwardInfo then
      WorldBossRed.CheckRed()
    end
  end
  
  function WorldBossRed.counterListInfoChange(container, dirtyKeys)
    WorldBossRed.CheckRed()
  end
  
  Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:RegWatcher(WorldBossRed.bossAwardInfoChange)
  Z.EventMgr:Add(Z.ConstValue.WorldBoss.GetWorldBossInfoCall, WorldBossRed.CheckRed)
  Z.EventMgr:Add(Z.ConstValue.SeasonIdChange, WorldBossRed.CheckRed)
  Z.ContainerMgr.CharSerialize.counterList.Watcher:RegWatcher(WorldBossRed.counterListInfoChange)
end

function WorldBossRed.UnInit()
  if WorldBossRed.bossAwardInfoChange then
    Z.ContainerMgr.CharSerialize.personalWorldBossInfo.Watcher:UnregWatcher(WorldBossRed.bossAwardInfoChange)
    WorldBossRed.bossAwardInfoChange = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.WorldBoss.GetWorldBossInfoCall, WorldBossRed.CheckRed)
  Z.EventMgr:Remove(Z.ConstValue.SeasonIdChange, WorldBossRed.CheckRed)
  Z.ContainerMgr.CharSerialize.counterList.Watcher:UnregWatcher(WorldBossRed.counterListInfoChange)
end

return WorldBossRed
