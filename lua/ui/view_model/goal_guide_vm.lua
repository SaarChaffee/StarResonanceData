local getLevelTableByPosType = function(posType)
  local tbl
  if posType == Z.GoalPosType.Point then
    tbl = Z.TableMgr.GetTable("ScenePointInfoTableMgr")
  elseif posType == Z.GoalPosType.Npc then
    tbl = Z.TableMgr.GetTable("NpcEntityTableMgr")
  elseif posType == Z.GoalPosType.Monster then
    tbl = Z.TableMgr.GetTable("MonsterEntityTableMgr")
  elseif posType == Z.GoalPosType.Zone then
    tbl = Z.TableMgr.GetTable("ZoneEntityTableMgr")
  elseif posType == Z.GoalPosType.SceneObject then
    tbl = Z.TableMgr.GetTable("SceneObjectEntityTableMgr")
  elseif posType == Z.GoalPosType.Collection then
    tbl = Z.TableMgr.GetTable("CollectionEntityTableMgr")
  end
  return tbl
end
local changeGuideDataBySrcId = function(src, flagData)
  local guideData = Z.DataMgr.Get("goal_guide_data")
  local oldGoalList = guideData:GetGuideGoalsBySource(src) or {}
  for goalIndex, info in ipairs(oldGoalList) do
    if info.Uid == flagData.Uid then
      info.Pos = flagData.Pos
      Z.EventMgr:Dispatch(Z.ConstValue.OnRefreshGuidePos, src, info)
      return
    end
  end
end
local setGuideDataAndNotify = function(src, goalList, sourceGoalList)
  local trackTbl = Z.TableMgr.GetTable("TargetTrackTableMgr")
  local trackRow = trackTbl.GetRow(src)
  if not trackRow then
    return
  end
  local guideData = Z.DataMgr.Get("goal_guide_data")
  local oldGoalList = guideData:GetGuideGoalsBySource(src) or {}
  guideData:SetGuideGoals(src, goalList, sourceGoalList)
  if src == E.GoalGuideSource.Quest then
    if goalList == nil then
      Z.GoalGuideMgr:SetQuestGoalGuide(nil)
    else
      local zList = ZUtil.Pool.Collections.ZList_Panda_ZGame_GoalPosInfo.Rent()
      for _, info in ipairs(goalList) do
        zList:Add(info)
      end
      Z.GoalGuideMgr:SetQuestGoalGuide(zList)
      zList:Recycle()
    end
  end
  local endDist = trackRow.EndDistance
  if 0 < endDist and src ~= E.GoalGuideSource.CustomMapFlag then
    for goalIndex, info in ipairs(oldGoalList) do
      local srcId = src * 100 + goalIndex
      Z.GoalGuideMgr:RemoveGoalDistanceCheck(srcId)
    end
    if goalList then
      for goalIndex, info in ipairs(goalList) do
        local srcId = src * 100 + goalIndex
        Z.GoalGuideMgr:AddGoalDistanceCheck(srcId, info, endDist)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GoalGuideChange, src, oldGoalList)
end
local setGuideGoals = function(src, goalList, sourceGoalList)
  local trackTbl = Z.TableMgr.GetTable("TargetTrackTableMgr")
  local trackRow = trackTbl.GetRow(src)
  if not trackRow then
    return
  end
  local guideData = Z.DataMgr.Get("goal_guide_data")
  if goalList == nil or #goalList == 0 then
    setGuideDataAndNotify(src, nil, sourceGoalList)
  else
    local dict = guideData:GetAllGuideGoalsDict()
    local tempDict = table.zclone(dict)
    for k, _ in pairs(tempDict) do
      local row = trackTbl.GetRow(k)
      if row and row.Team == trackRow.Team then
        setGuideDataAndNotify(k, nil, nil)
      end
    end
    setGuideDataAndNotify(src, goalList, sourceGoalList)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.AllGoalGuideChange)
end
local removeGuideGoalBySrcId = function(id)
  local src = id // 100
  local goalIndex = id % 100
  local guideData = Z.DataMgr.Get("goal_guide_data")
  local oldGoalList_ = guideData:GetGuideGoalsBySource(src) or {}
  guideData:RemoveGuideGoal(src, goalIndex)
  if src == E.MapFlagType.Position then
    local mapData = Z.DataMgr.Get("map_data")
    mapData:ClearDynamicTraceParam()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GoalGuideChange, src, oldGoalList_)
end
local ret = {
  SetGuideGoals = setGuideGoals,
  RemoveGuideGoalBySrcId = removeGuideGoalBySrcId,
  GetLevelTableByPosType = getLevelTableByPosType,
  ChangeGuideDataBySrcId = changeGuideDataBySrcId
}
return ret
