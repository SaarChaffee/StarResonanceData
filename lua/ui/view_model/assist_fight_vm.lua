local AssistFightVM = {}

function AssistFightVM:GetRecommendedPlay(dungeonId, functionId)
  if functionId == E.FunctionID.HeroChallengeDungeon or functionId == E.FunctionID.HeroChallengeJuTaYiJi or functionId == E.FunctionID.HeroChallengeJuLongZhuaHen or functionId == E.FunctionID.HeroChallengeKaNiMan then
    return self:CheckChallengeDungeonAssist(dungeonId)
  elseif functionId == E.FunctionID.WeeklyHunt then
    return Z.ContainerMgr.CharSerialize.weeklyTower.maxClimbUpId > 1
  elseif functionId == E.FunctionID.UnionHunt then
    return self:CheckUnionHunt(functionId)
  end
  return false
end

function AssistFightVM:CheckChallengeDungeonAssist(dungeonId)
  local heroDungeonVM = Z.VMMgr.GetVM("hero_dungeon_main")
  local targetList, groupId = heroDungeonVM.GetChallengeHeroDungeonTarget(dungeonId)
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[groupId]
  for k, v in pairs(targetList) do
    local targetTableRow = Z.TableMgr.GetTable("HeroDungeonTargetTableMgr").GetRow(v.targetId)
    if targetTableRow then
      if dungeonInfo and dungeonInfo.dungeonTargetProgress[targetTableRow.Id] then
        return true
      end
      local dungeonTargetProgress
      if dungeonInfo and dungeonInfo.dungeonTargetProgress[targetTableRow.Id] then
        dungeonTargetProgress = dungeonInfo.dungeonTargetProgress[targetTableRow.Id]
      else
        dungeonTargetProgress = {targetProgress = 0, awardState = 0}
      end
      if dungeonTargetProgress then
        return dungeonTargetProgress.targetProgress == 1
      end
    end
  end
  return false
end

function AssistFightVM:CheckUnionHunt(functionID)
  local unionActivityData = Z.DataMgr.Get("union_activity_data")
  local countId = unionActivityData:GetCounterByFuncID(functionID)
  if countId == 0 then
    return false
  end
  local maxLimitNum = 0
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(countId)
  local normalAwardCount = 0
  local nowAwardCount = 0
  if counterCfgData then
    maxLimitNum = counterCfgData.Limit
    if Z.ContainerMgr.CharSerialize.counterList.counterMap[countId] then
      nowAwardCount = Z.ContainerMgr.CharSerialize.counterList.counterMap[countId].counter
    end
  end
  normalAwardCount = maxLimitNum - nowAwardCount
  return normalAwardCount == 0
end

return AssistFightVM
