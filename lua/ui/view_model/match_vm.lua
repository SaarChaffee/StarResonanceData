local matchVm = {}
local worldProxy = require("zproxy.world_proxy")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")

function matchVm.HandleError(errCode)
  if errCode ~= nil and errCode ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= errCode then
    if errCode == Z.PbEnum("EErrorCode", "ErrFunctionUnlock") then
      logGreen("\229\138\159\232\131\189\230\156\170\229\188\128\229\144\175")
    else
      Z.TipsVM.ShowTips(errCode)
    end
  end
end

function matchVm.OpenMatchView(matchType)
  if matchType == E.MatchType.Team then
    local matchTeamVm = Z.VMMgr.GetVM("match_team")
    matchTeamVm.OpenEnterView()
  elseif matchType == E.MatchType.Activity then
    local matchActivityVM = Z.VMMgr.GetVM("match_activity")
    matchActivityVM.OpenMatchView()
  end
end

function matchVm.CloseMatchView()
  local matchData = Z.DataMgr.Get("match_data")
  local matchType = matchData:GetMatchType()
  if matchType == E.MatchType.Team then
    local matchTeamVm = Z.VMMgr.GetVM("match_team")
    matchTeamVm.CloseEnterView()
  elseif matchType == E.MatchType.Activity then
    local matchActivityVM = Z.VMMgr.GetVM("match_activity")
    matchActivityVM.CloseMatchView()
  end
end

function matchVm.CancelMatchDialog()
  local matchData = Z.DataMgr.Get("match_data")
  local matchType = matchData:GetMatchType()
  if matchType == E.MatchType.Team then
    local matchTeamVm = Z.VMMgr.GetVM("match_team")
    matchTeamVm.CancelMatchDialog()
  elseif matchType == E.MatchType.Activity then
    local matchActivityVM = Z.VMMgr.GetVM("match_activity")
    matchActivityVM.CancelMatchDialog()
  end
end

function matchVm.AsyncGetMatchInfo(param, cancelToken)
  local matchData = Z.DataMgr.Get("match_data")
  if cancelToken == nil then
    cancelToken = matchData.CancelSource:CreateToken()
  end
  if param == nil then
    param = {}
  end
  local ret = worldProxy.GetMatchInfo(param, matchData.CancelSource:CreateToken())
  matchVm.HandleError(ret.errCode)
  if ret then
    local data = ret
    if data then
      matchData:SetMatchData(data)
    end
  end
end

function matchVm.AsyncMatchReady(playerIsReady)
  local matchData = Z.DataMgr.Get("match_data")
  local data = matchData:GetMatchData()
  local request = {
    isReady = playerIsReady,
    matchToken = data.matchToken
  }
  worldProxy.MatchReady(request)
end

function matchVm.AsyncCancelMatch()
  local matchData = Z.DataMgr.Get("match_data")
  local data = matchData:GetMatchData()
  local request = {}
  request.matchToken = data.matchToken
  worldProxy.CancelMatch(request)
end

function matchVm.RequestBeginMatch(matchType, param, cancelToken)
  if matchType == E.MatchType.Team then
    local matchTeamVm = Z.VMMgr.GetVM("match_team")
    matchTeamVm.TryBeginMatch(param)
  elseif matchType == E.MatchType.Activity then
    local matchActivityVM = Z.VMMgr.GetVM("match_activity")
    matchActivityVM.TryBeginMatch(param)
  end
end

function matchVm.RequestBeginActivityMatch(uuid, token, param)
  local activityId = tonumber(param[3])
  if not activityId then
    return
  end
  local matchActivityVM = Z.VMMgr.GetVM("match_activity")
  matchActivityVM.TryBeginMatch(activityId)
end

function matchVm.IsMatching()
  local matchData = Z.DataMgr.Get("match_data")
  return matchData:GetMatchType() ~= E.MatchType.Null
end

function matchVm.TryChangeMatch(newMatchType, param)
  local matchData = Z.DataMgr.Get("match_data")
  local matchTeamData = Z.DataMgr.Get("match_team_data")
  local MatchActivityData = Z.DataMgr.Get("match_activity_data")
  local matchType = matchData:GetMatchType()
  local oldTargetName, newTargetName, confirmFunc, beginMatchFunc
  if matchType == E.MatchType.Team then
    local dungeonID = matchTeamData:GetCurMatchingDungeonId()
    local difficulty = matchTeamData:GetCurMatchingMasterDifficulty()
    if newMatchType == matchType and param == dungeonID then
      return
    end
    if difficulty and 0 < difficulty then
      local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonID][difficulty]
      local masterChallengeDungeonTableRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
      local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
      if dungeonsTableRow and masterChallengeDungeonTableRow then
        oldTargetName = Lang("DungeonMasterName", {
          dungeonName = dungeonsTableRow.Name,
          masterName = masterChallengeDungeonTableRow.DungeonTypeName
        })
      end
    else
      local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
      if dungeonsTableRow then
        oldTargetName = dungeonsTableRow.Name
      end
    end
  elseif matchType == E.MatchType.Activity then
    local actID = MatchActivityData:GetActivityId()
    if newMatchType == matchType and param == actID then
      return
    end
    local cfg = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(actID)
    oldTargetName = cfg.Name
  end
  if newMatchType == E.MatchType.Team then
    local dungeonId = param.dungeonId
    local difficulty = param.difficulty
    if difficulty and 0 < difficulty then
      local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][difficulty]
      local masterChallengeDungeonTableRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
      local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
      if dungeonsTableRow and masterChallengeDungeonTableRow then
        newTargetName = Lang("DungeonMasterName", {
          dungeonName = dungeonsTableRow.Name,
          masterName = masterChallengeDungeonTableRow.DungeonTypeName
        })
      end
    else
      local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
      if dungeonsTableRow then
        newTargetName = dungeonsTableRow.Name
      end
    end
    
    function beginMatchFunc()
      local teamMainVm = Z.VMMgr.GetVM("team_main")
      local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId, difficulty)
      if not targetId then
        return
      end
      local requestParam = {}
      requestParam.targetId = targetId
      local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
      local isLeader = settingInfo[Z.PbEnum("ESettingType", "ToBeLeader")] or "0"
      requestParam.wantLeader = isLeader == "0" and 1 or 0
      Z.CoroUtil.create_coro_xpcall(function()
        local matchTeamVm = Z.VMMgr.GetVM("match_team")
        matchTeamVm.AsyncBeginMatch(requestParam)
      end)()
    end
  elseif newMatchType == E.MatchType.Activity then
    local actID = param
    local cfg = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(actID)
    newTargetName = cfg.Name
    
    function beginMatchFunc()
      local matchActivityVM = Z.VMMgr.GetVM("match_activity")
      Z.CoroUtil.create_coro_xpcall(function()
        matchActivityVM.AsyncBeginMatch(param)
      end)()
    end
  end
  
  function confirmFunc()
    Z.CoroUtil.create_coro_xpcall(function()
      matchVm.AsyncCancelMatch()
      matchData:SetIsChangeMatching(true, beginMatchFunc)
    end)()
  end
  
  matchVm.ChangeMatchDialog(oldTargetName, newTargetName, confirmFunc)
end

function matchVm.ChangeMatchDialog(oldTargetName, newTargetName, confirmFunc)
  local data = {
    dlgType = E.DlgType.YesNo,
    onConfirm = confirmFunc,
    labDesc = Lang("ChangeMatchTips", {target = oldTargetName, newTarget = newTargetName})
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

return matchVm
