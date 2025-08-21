local openTeamMainView = function(targetId)
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_Team_yzh, "team_main", function()
    Z.UIMgr:OpenView("team_main", targetId)
  end, Z.ConstValue.UnrealSceneConfigPaths.Yzh)
end
local closeTeamMainView = function()
  Z.UIMgr:CloseView("team_main")
end
local teamSort = function(teamList)
  table.sort(teamList, function(left, right)
    if left.setTargetTime < right.setTargetTime then
      return true
    elseif left.setTargetTime == right.setTargetTime then
      local leftTargetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(left.targetId)
      local rightTargetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(right.targetId)
      local leftMems = #left.mems
      local rightMems = #right.mems
      if leftTargetInfo and rightTargetInfo then
        leftMems = leftTargetInfo.TeamType == E.ETeamMemberType.Twenty and math.ceil(leftMems / 5) or leftMems
        rightMems = rightTargetInfo.TeamType == E.ETeamMemberType.Twenty and math.ceil(rightMems / 5) or rightMems
      end
      if leftMems > rightMems then
        return true
      elseif leftMems == rightMems and left.teamId < right.teamId then
        return true
      end
    end
    return false
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
local checkMemberCount = function(teamInfo)
  local teamData = Z.DataMgr.Get("team_data")
  return table.zcount(teamInfo.mems) > teamData.NeedMreMemberCount
end
local checkProfession = function(teamInfo)
  local teamData = Z.DataMgr.Get("team_data")
  if not teamData.IsNeedCurProfession then
    return true
  end
  local targetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(teamInfo.targetId)
  if not targetInfo then
    return true
  end
  local talentIdList = {}
  if targetInfo then
    for index, value in ipairs(targetInfo.Talent) do
      talentIdList[value[1]] = value[2]
    end
  end
  if talentIdList[0] or next(talentIdList) == nil then
    return true
  end
  for key, data in ipairs(teamInfo.mems) do
    local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", data.socialData.professionData.professionId)
    if professionRow and talentIdList[professionRow.Talent] then
      talentIdList[professionRow.Talent] = talentIdList[professionRow.Talent] - 1
      if talentIdList[professionRow.Talent] <= 0 then
        talentIdList[professionRow.Talent] = nil
      end
    end
  end
  local curProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", curProfessionId)
  if professionRow then
    return talentIdList[professionRow.Talent] ~= nil
  end
  return false
end
local getTeamList = function(teamList, maxNum, targetId)
  local teamData = Z.DataMgr.Get("team_data")
  local newTeamList = {}
  for i = 1, maxNum do
    local team = teamList[i]
    if team and team.teamId ~= teamData.TeamInfo.baseInfo.teamId and checkTargetCondition(team.targetId) and (targetId == E.TeamTargetId.All or team.targetId == targetId) and checkMemberCount(team) then
      local isShow = true
      for index, value in ipairs(team.mems) do
        if value.socialData and team.leaderId == value.socialData.basicData.charID then
          local sceneId = value.socialData.basicData.sceneId
          local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(sceneId, true)
          if dungeonRow and not dungeonRow.IgnoreDungeonCheck then
            isShow = false
          end
          break
        end
      end
      if isShow and checkProfession(team) then
        table.insert(newTeamList, team)
      end
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
