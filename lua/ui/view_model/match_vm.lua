local matchVm = {}
local worldProxy = require("zproxy.world_proxy")

function matchVm.HandleError(errCode)
  if errCode ~= nil and errCode ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= errCode then
    if errCode == Z.PbEnum("EErrorCode", "ErrFunctionUnlock") then
      logGreen("\229\138\159\232\131\189\230\156\170\229\188\128\229\144\175")
    else
      Z.TipsVM.ShowTips(errCode)
    end
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
      if data.matchStatus == E.MatchSatatusType.MatchIng then
        matchVm.SetSelfMatchData(true, "matching")
      end
      matchData:SetMatchInfo(data)
    end
  end
  return ret.errCode
end

function matchVm.SetSelfMatchData(data, key)
  local matchData = Z.DataMgr.Get("match_data")
  matchData:SetSelfMatchData(data, key)
end

function matchVm.GetSelfMatchData(key)
  local matchData = Z.DataMgr.Get("match_data")
  return matchData:GetSelfMatchData(key)
end

function matchVm.AsyncBeginMatchNew(matchType, matchParam, hasTeam, cancelToken)
  local request = {
    matchType = matchType,
    matchParamContext = {}
  }
  if matchType == E.MatchType.Team then
    if not hasTeam then
      request.matchParamContext.matchTeamParam = matchParam
    end
  elseif matchType == E.MatchType.WorldBoss then
    request.matchParamContext.matchWorldBossParam = matchParam
  end
  local ret = worldProxy.BeginMatch(request, cancelToken)
  matchVm.HandleError(ret)
  if matchType == E.MatchType.Team and not hasTeam and ret == 0 then
    matchVm.SetSelfMatchData(true, "matching")
    matchVm.CreateMatchingTips()
  end
end

function matchVm.AsyncMatchReady(playerIsReady, cancelToken)
  local request = {isReady = playerIsReady}
  local ret = worldProxy.MatchReady(request, cancelToken)
  if ret == 0 then
    local matchData = Z.DataMgr.Get("match_data")
    matchData:SetMatchStartTime(0, E.MatchType.WorldBoss)
  end
end

function matchVm.AsyncCancelMatchNew(matchType, isLeader, cancelToken)
  local request = {}
  local ret = worldProxy.CancelMatch(request, cancelToken)
  matchVm.HandleError(ret)
  if ret == 0 and not isLeader then
    matchVm.SetSelfMatchData(false, "matching")
    matchVm.CancelMatchingTips()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.RepeatCharCancelMatch)
    if matchType == E.MatchType.WorldBoss then
      local matchData = Z.DataMgr.Get("match_data")
      matchData:SetMatchStartTime(0, E.MatchType.WorldBoss)
      matchData:ClearMatchData()
    end
  end
end

function matchVm.CreateMatchingTips()
  local timeDelay = math.floor(Z.Global.MatchTime / 60)
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamMatch, function()
    local param = {val = timeDelay}
    Z.TipsVM.ShowTipsLang(1000624, param)
  end, Z.Global.TeamMatchTipsTime)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshMatchingStatus)
end

function matchVm.CancelMatchingTips()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TeamMatch)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshMatchingStatus)
end

return matchVm
