local pb = require("pb2")
local MatchNtfImpl = {}
local teamVM = Z.VMMgr.GetVM("team")
local worldBossVM = Z.VMMgr.GetVM("world_boss")
local teamEntersVM = Z.VMMgr.GetVM("team_enter")
local matchVm_ = Z.VMMgr.GetVM("match")
local worldBossData = Z.DataMgr.Get("world_boss_data")

function MatchNtfImpl:EnterMatchNtf(call, vData)
  local matchStatus = vData.matchStatus
  local matchType = vData.matchType
  local errcode = vData.errCode
  if errcode ~= 0 then
    Z.TipsVM.ShowTips(errcode)
    return
  end
  local matchdata = Z.DataMgr.Get("match_data")
  matchdata:SetMatchState(vData.matchType, vData.matchStatus)
  matchdata:SetMatchType(vData.matchType)
  if matchType == E.MatchType.Team then
    if matchStatus == E.MatchSatatusType.WaitReady then
      local teamActivity = 0
      teamEntersVM.OpenEnterView(teamActivity)
    elseif matchStatus == E.MatchSatatusType.MatchIng then
      Z.TipsVM.ShowTipsLang(1000613)
      matchdata:SetSelfMatchData(true, "matching")
      matchVm_.CreateMatchingTips()
    end
  elseif matchType == E.MatchType.WorldBoss then
    if worldBossData:GetWorldBossPrepared() then
      worldBossData:SetWorldBossPrepared(false)
      if matchStatus ~= E.MatchSatatusType.AllReady then
        Z.TipsVM.ShowTips(16002044)
        worldBossVM:CloseWorldBossMatchView()
      end
    end
    if matchStatus == E.MatchSatatusType.WaitReady then
      worldBossData:SetWorldBossMatchSuccessTime(Z.TimeTools.Now() / 1000)
      worldBossVM:OpenWorldBossMatchView()
    elseif matchStatus ~= E.MatchSatatusType.AllReady then
      worldBossVM:CloseWorldBossMatchView()
    end
    if matchStatus == E.MatchSatatusType.MatchIng then
      matchdata:SetMatchStartTime(Z.TimeTools.Now(), matchType)
    else
      matchdata:SetMatchStartTime(0, matchType)
    end
  end
end

function MatchNtfImpl:CancelMatchNtf(call, vData)
  local matchdata = Z.DataMgr.Get("match_data")
  if vData.matchType == E.MatchType.Team then
    teamEntersVM.CloseEnterView()
    Z.TipsVM.ShowTipsLang(1000614)
    if teamVM.CheckIsInTeam() then
      matchdata:SetSelfMatchData(false, "teamMatching")
      Z.EventMgr:Dispatch(Z.ConstValue.Team.RepeatTeamCancelMatch)
    else
      matchdata:SetSelfMatchData(false, "matching")
    end
    matchVm_.CancelMatchingTips()
    matchdata:ClearMatchData()
  elseif vData.matchType == E.MatchType.WorldBoss then
    worldBossData:SetWorldBossPrepared(false)
    worldBossVM:CloseWorldBossMatchView()
    matchdata:SetMatchStartTime(0, vData.matchType)
    if vData.cancelType == E.MatchCancelType.UnReady then
      Z.TipsVM.ShowTips(16002041)
    end
    if vData.cancelType == E.MatchCancelType.Request then
      Z.TipsVM.ShowTips(16002045)
    end
    if vData.cancelType == E.MatchCancelType.TimeOut then
      Z.TipsVM.ShowTips(16002046)
    end
    matchdata:ClearMatchData()
  end
end

function MatchNtfImpl:MatchReadyStatusNtf(call, vData)
  local playerDatas = vData.matchPlayerInfo
  local matchdata = Z.DataMgr.Get("match_data")
  matchdata:SetMatchPlayerInfo(playerDatas, vData.matchType)
  matchdata:SetMatchType(vData.matchType)
  if vData.matchType == E.MatchType.Team then
    local teamData = Z.DataMgr.Get("team_data")
    local mems = teamData.TeamInfo.members
    for _, value in pairs(playerDatas) do
      local vRequest = value
      local memInfo = mems[vRequest.charId]
      if not memInfo then
        return
      end
      if vRequest.readyStatus == E.RedayType.UnReady then
        local param = {
          player = {
            name = memInfo.socialData and memInfo.socialData.basicData.name or ""
          }
        }
        Z.TipsVM.ShowTipsLang(1000637, param)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshActivityVoteResult)
end

return MatchNtfImpl
