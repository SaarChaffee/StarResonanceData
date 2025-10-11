local worldProxy = require("zproxy.world_proxy")
local MatchActivityVM = {}

function MatchActivityVM.GetIsMatching()
  local matchData_ = Z.DataMgr.Get("match_data")
  return matchData_:GetMatchType() == E.MatchType.Activity
end

function MatchActivityVM.CloseMatchView()
  Z.UIMgr:CloseView("common_matching")
  Z.UIMgr:CloseView("world_boss_matching")
end

function MatchActivityVM.OpenMatchView()
  local matchActivityData = Z.DataMgr.Get("match_activity_data")
  local curMatchActivityType = matchActivityData:GetCurMatchActivityType()
  if curMatchActivityType == E.MatchActivityType.CommonActivity then
    Z.UIMgr:OpenView("common_matching")
  elseif curMatchActivityType == E.MatchActivityType.WorldBoseActivity then
    MatchActivityVM.OpenWorldBossMatchView()
  end
end

function MatchActivityVM.OpenWorldBossMatchView()
  Z.UIMgr:OpenView("world_boss_matching")
end

function MatchActivityVM.AsyncBeginMatch(param)
  local matchActivityData = Z.DataMgr.Get("match_activity_data")
  local curMatchActivityType = matchActivityData:GetMatchActivityTypeByActId(param)
  if curMatchActivityType == E.MatchActivityType.CommonActivity then
    local request = {}
    request.activityId = param
    worldProxy.BeginRecommendPlayMatch(request)
  elseif curMatchActivityType == E.MatchActivityType.WorldBoseActivity then
    local worldBossMatchParam = {}
    worldBossMatchParam.activityId = param
    local matchData_ = Z.DataMgr.Get("match_data")
    worldProxy.BeginWorldBossMatch(worldBossMatchParam, matchData_.CancelSource:CreateToken())
  end
end

local CheckTeamMemberProfession = function(members, matchMaxNum, matchProfessionLimitNum)
  local talentTable = {}
  local talentAll = matchMaxNum
  for k, v in pairs(matchProfessionLimitNum) do
    talentTable[v[1]] = v[2]
    talentAll = talentAll - v[2]
  end
  talentTable[0] = talentAll
  local professionSystemTableMgr = Z.TableMgr.GetTable("ProfessionSystemTableMgr")
  for k, v in pairs(members) do
    local professionID = v.socialData.professionData.professionId
    local professionSystemTableRow = professionSystemTableMgr.GetRow(professionID)
    if not professionSystemTableRow then
      return false
    end
    local talentId = professionSystemTableRow.Talent
    if talentTable[talentId] and 0 < talentTable[talentId] then
      talentTable[talentId] = talentTable[talentId] - 1
    elseif 0 < talentTable[0] then
      talentTable[0] = talentTable[0] - 1
    else
      Z.TipsVM.ShowTips(1000647)
      return false
    end
  end
  return true
end
local CheckCanMatchTeam = function(activityId)
  local matchActivityData = Z.DataMgr.Get("match_activity_data")
  local curMatchActivityType = matchActivityData:GetMatchActivityTypeByActId(activityId)
  local teamData = Z.DataMgr.Get("team_data")
  local members = teamData.TeamInfo.members
  if curMatchActivityType == E.MatchActivityType.CommonActivity then
    local matchActTableRow = Z.TableMgr.GetTable("MatchActTableMgr").GetRow(activityId)
    if not matchActTableRow then
      return false
    end
    local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(matchActTableRow.MatchId)
    if not matchTableRow then
      return false
    end
    if not CheckTeamMemberProfession(members, matchTableRow.MatchMaxNum, matchTableRow.MatchProfessionLimitNum) then
      return false
    end
  else
    local worldBossData = Z.DataMgr.Get("world_boss_data")
    local worldBossInfo = worldBossData:GetWorldBossInfoData()
    local bossSwitchID = worldBossInfo.bossCfgId
    local worldBossSwitchTableRow = Z.TableMgr.GetTable("WorldBossSwitchTableMgr").GetRow(bossSwitchID)
    if not worldBossSwitchTableRow then
      return false
    end
    local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(worldBossSwitchTableRow.MatchId)
    if not matchTableRow then
      return false
    end
    if not CheckTeamMemberProfession(members, matchTableRow.MatchMaxNum, matchTableRow.MatchProfessionLimitNum) then
      return false
    end
  end
  return true
end
local CheckCanMatch = function(activityId)
  local teamVm = Z.VMMgr.GetVM("team")
  if teamVm.CheckIsInTeam() then
    return CheckCanMatchTeam(activityId)
  else
    return true
  end
  return true
end

function MatchActivityVM.TryBeginMatch(param)
  if not CheckCanMatch(param) then
    return
  end
  local matchVm = Z.VMMgr.GetVM("match")
  if matchVm.IsMatching() then
    matchVm.TryChangeMatch(E.MatchType.Activity, param)
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    MatchActivityVM.AsyncBeginMatch(param)
  end)()
end

function MatchActivityVM.CancelMatchDialog()
  local teamVM = Z.VMMgr.GetVM("team")
  if teamVM.CheckIsInTeam() and not teamVM.GetYouIsLeader() then
    Z.TipsVM.ShowTips(1000645)
    return
  end
  local matchVm = Z.VMMgr.GetVM("match")
  local confirmFunc = function()
    Z.CoroUtil.create_coro_xpcall(function()
      matchVm.AsyncCancelMatch()
    end)()
  end
  local matchActivityData = Z.DataMgr.Get("match_activity_data")
  local activityId = matchActivityData:GetActivityId()
  local cfg = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(activityId)
  local targetName = ""
  if cfg then
    targetName = cfg.Name
  end
  local now = Z.TimeTools.Now() / 1000
  local matchData_ = Z.DataMgr.Get("match_data")
  local matchBeginTime = matchData_:GetMatchStartTime()
  local duration = now - matchBeginTime / 1000
  local data = {
    dlgType = E.DlgType.YesNo,
    onConfirm = confirmFunc,
    labDesc = Lang("ConfirmCancelMatchTips", {
      target = targetName,
      waitTime = Z.TimeFormatTools.FormatToDHMS(Z.Global.MatchTime),
      curWaitTime = Z.TimeFormatTools.FormatToDHMS(duration)
    }),
    labNo = Lang("ConfirmCancelMatchTipsNo"),
    labYes = Lang("ConfirmCancelMatchTipsYes")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

return MatchActivityVM
