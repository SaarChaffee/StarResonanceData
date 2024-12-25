local openTeamMainView = function(targetId)
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_Team_yzh, "team_main", function()
    Z.UIMgr:OpenView("team_main", targetId)
  end, Z.ConstValue.UnrealSceneConfigPaths.Yzh)
end
local closeTeamMainView = function()
  Z.UIMgr:CloseView("team_main")
end
local teamSort = function(teamList)
  table.sort(teamList, function(a, b)
    if a.setTargetTime < b.setTargetTime then
      return a
    elseif a.setTargetTime == b.setTargetTime then
      if #a.mems > #b.mems then
        return a
      elseif #a.mems == #b.mems and a.teamId < b.teamId then
        return a
      end
    end
  end)
  return teamList
end
local checkTargetCondition = function(target, isShowError)
  local targetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(target)
  if targetInfo then
    if targetInfo.RelativeDungeonId == 0 then
      return true
    end
    local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(targetInfo.RelativeDungeonId, true)
    if dungeonRow then
      return Z.ConditionHelper.CheckCondition(dungeonRow.Condition, isShowError)
    end
  end
  return false
end
local getTeamList = function(teamList, maxNum, targetId)
  local teamData = Z.DataMgr.Get("team_data")
  local newTeamList = {}
  for i = 1, maxNum do
    local team = teamList[i]
    if team and team.teamId ~= teamData.TeamInfo.baseInfo.teamId and checkTargetCondition(team.targetId) and (targetId == E.TeamTargetId.All or team.targetId == targetId) then
      table.insert(newTeamList, team)
    end
  end
  newTeamList = teamSort(newTeamList)
  return newTeamList
end
local targetSort = function(targetList)
  table.sort(targetList, function(a, b)
    if a.Sort < b.Sort then
      return a
    end
  end)
  return targetList
end
local getTargetIdByDungeonId = function(dungeonid)
  local teamData = Z.DataMgr.Get("team_data")
  for id, cfgData in pairs(teamData.TeamTargetTableDatas) do
    if cfgData.RelativeDungeonId == dungeonid then
      return id
    end
  end
end
local enterTeamTargetByDungeonId = function(dungeonid)
  openTeamMainView(getTargetIdByDungeonId(dungeonid))
end
local ret = {
  OpenTeamMainView = openTeamMainView,
  CloseTeamMainView = closeTeamMainView,
  GetTeamList = getTeamList,
  TargetSort = targetSort,
  EnterTeamTargetByDungeonId = enterTeamTargetByDungeonId,
  GetTargetIdByDungeonId = getTargetIdByDungeonId,
  CheckTargetCondition = checkTargetCondition
}
return ret
