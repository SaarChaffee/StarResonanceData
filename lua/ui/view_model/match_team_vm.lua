local MatchTeamVm = {}
local worldProxy = require("zproxy.world_proxy")
local MasterChallenDungeonTableMap = require("table.MasterChallenDungeonTableMap")

function MatchTeamVm.GetIsMatching()
  local matchData_ = Z.DataMgr.Get("match_data")
  return matchData_:GetMatchType() == E.MatchType.Team
end

local OpenRFDialog = function(dungeonId, suggestRF)
  local confirmFunc = function()
    local rfVM = Z.VMMgr.GetVM("recommend_fightvalue")
    rfVM.OpenMainView()
  end
  local cancelFunc = function()
    local teamMainVm = Z.VMMgr.GetVM("team_main")
    local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId)
    if not targetId then
      return
    end
    local teamTargetTableRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
    if teamTargetTableRow then
      local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
      quickjumpVm.DoJumpByConfigParam(teamTargetTableRow.QuickJumpType, teamTargetTableRow.QuickJumpParam)
    end
  end
  local data = {
    dlgType = E.DlgType.YesNo,
    onConfirm = confirmFunc,
    onCancel = cancelFunc,
    labDesc = Lang("ConfirmMatchRFTips", {combat = suggestRF}),
    labNo = Lang("ConfirmMatchTipsRFNo"),
    labYes = Lang("ConfirmMatchTipsRFYes")
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function MatchTeamVm.OpenEnterView()
  Z.UIMgr:OpenView("team_enter", {isMatching = true})
end

function MatchTeamVm.CloseEnterView()
  Z.UIMgr:CloseView("team_enter")
end

local CheckTeamMemberRF = function(members, suggestRF)
  for k, v in pairs(members) do
    if suggestRF > v.socialData.userAttrData.fightPoint and suggestRF ~= 0 then
      Z.TipsVM.ShowTips(1000646)
      return false
    end
  end
  return true
end
local CheckTeamMemberProfession = function(members, matchTableRow)
  local talentTable = {}
  local talentAll = matchTableRow.MatchMaxNum
  for k, v in pairs(matchTableRow.MatchProfessionLimitNum) do
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
local GetSuggestRF = function(dungeonId, difficulty)
  if difficulty and 0 < difficulty then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonId][difficulty]
    local tabData = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    if tabData then
      return tabData.RecommendFightValue
    end
  else
    local tabData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if tabData then
      return tabData.RecommendFightValue
    end
  end
  return 0
end
local CheckCanMatchTeam = function(dungeonId, difficulty)
  local teamVm = Z.VMMgr.GetVM("team")
  if not teamVm.GetYouIsLeader() then
    Z.TipsVM.ShowTips(1000643)
    return false
  end
  local teamMainVm = Z.VMMgr.GetVM("team_main")
  local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId, difficulty)
  if not targetId then
    return false
  end
  local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if not teamTargetRow then
    return false
  end
  local matchTableRow = Z.TableMgr.GetTable("MatchTableMgr").GetRow(teamTargetRow.MatchID)
  if not matchTableRow then
    return false
  end
  local teamData = Z.DataMgr.Get("team_data")
  local members = teamData.TeamInfo.members
  local suggestRF = GetSuggestRF(dungeonId, difficulty)
  if not CheckTeamMemberRF(members, suggestRF) then
    return false
  end
  if not CheckTeamMemberProfession(members, matchTableRow) then
    return false
  end
  return true
end
local CheckCanMatchSingle = function(dungeonId, difficulty)
  local recommendFightValueVM = Z.VMMgr.GetVM("recommend_fightvalue")
  local curRF = recommendFightValueVM.GetTotalPoint()
  local suggestRF = GetSuggestRF(dungeonId, difficulty)
  if curRF < suggestRF and suggestRF ~= 0 then
    OpenRFDialog(dungeonId, suggestRF)
    return false
  end
  return true
end
local CheckCanMatch = function(dungeonId, difficulty)
  local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonsTableRow then
    return false
  end
  if not Z.ConditionHelper.CheckCondition(dungeonsTableRow.Condition, true) then
    return false
  end
  local teamVm = Z.VMMgr.GetVM("team")
  if teamVm.CheckIsInTeam() then
    return CheckCanMatchTeam(dungeonId, difficulty)
  else
    return CheckCanMatchSingle(dungeonId, difficulty)
  end
  return true
end

function MatchTeamVm.IsShowMatchBtn(dungeonId, masterDifficultLevel)
  local teamMainVm = Z.VMMgr.GetVM("team_main")
  local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId, masterDifficultLevel)
  if not targetId then
    return false
  end
  local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if not teamTargetRow then
    return false
  end
  return teamTargetRow.MatchID and teamTargetRow.MatchID > 0 and Z.ConditionHelper.CheckCondition(teamTargetRow.MatchCondition)
end

function MatchTeamVm.CancelMatchDialog()
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
  local matchTeamData = Z.DataMgr.Get("match_team_data")
  local dungeonID = matchTeamData:GetCurMatchingDungeonId()
  local difficulty = matchTeamData:GetCurMatchingMasterDifficulty()
  local targetName = ""
  if difficulty and 0 < difficulty then
    local masterChallenDungeonId = MasterChallenDungeonTableMap.DungeonId[dungeonID][difficulty]
    local masterChallengeDungeonTableRow = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr").GetRow(masterChallenDungeonId)
    local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
    if dungeonsTableRow and masterChallengeDungeonTableRow then
      targetName = Lang("DungeonMasterName", {
        dungeonName = dungeonsTableRow.Name,
        masterName = masterChallengeDungeonTableRow.DungeonTypeName
      })
    end
  else
    local dungeonsTableRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonID)
    if dungeonsTableRow then
      targetName = dungeonsTableRow.Name
    end
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

function MatchTeamVm.KeepWaitingMatchDialog()
  local teamVM = Z.VMMgr.GetVM("team")
  if teamVM.CheckIsInTeam() and not teamVM.GetYouIsLeader() then
    return
  end
  local matchVm = Z.VMMgr.GetVM("match")
  local confirmFunc = function()
    Z.CoroUtil.create_coro_xpcall(function()
      matchVm.AsyncCancelMatch()
    end)()
  end
  local countDownConfirmFunc = function()
    Z.CoroUtil.create_coro_xpcall(function()
      matchVm.AsyncCancelMatch()
      local chatMainVm = Z.VMMgr.GetVM("chat_main")
      chatMainVm.addTipsByConfigId(8009006, false)
    end)()
  end
  local data = {
    dlgType = E.DlgType.CountdownYes,
    onConfirm = confirmFunc,
    labDesc = Lang("ConfirmKeepWaitingMatchTips"),
    labNo = Lang("ConfirmCancelMatchTipsNo"),
    labYes = Lang("ConfirmCancelMatchTipsYes"),
    countdown = Z.Global.MatchWaitingConfirmTime,
    countDownCanClick = true,
    countDownConfirmFunc = countDownConfirmFunc
  }
  Z.DialogViewDataMgr:OpenDialogView(data)
end

function MatchTeamVm.CreateMatchingTimer()
  if not MatchTeamVm.GetIsMatching() then
    Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TeamMatch)
    return
  end
  local timeDialog = Z.Global.MatchWaitingTime
  local now = Z.TimeTools.Now() / 1000
  local matchData_ = Z.DataMgr.Get("match_data")
  local matchBeginTime = matchData_:GetMatchStartTime()
  local duration = timeDialog - now + matchBeginTime / 1000
  if duration < 0 then
    return
  end
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamMatch, function()
    local matchBeginTime = matchData_:GetMatchStartTime()
    if 0 < matchBeginTime then
      MatchTeamVm.KeepWaitingMatchDialog()
    end
  end, duration, 1, nil, function()
  end)
end

function MatchTeamVm.CancelMatchingTimer()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TeamMatch)
end

function MatchTeamVm.TryBeginMatch(teamMatchParams)
  local dungeonId = teamMatchParams.dungeonId
  local difficulty = teamMatchParams.difficulty
  if not CheckCanMatch(dungeonId, difficulty) then
    return
  end
  local matchVm = Z.VMMgr.GetVM("match")
  if matchVm.IsMatching() then
    matchVm.TryChangeMatch(E.MatchType.Team, teamMatchParams)
    return
  end
  local teamMainVm = Z.VMMgr.GetVM("team_main")
  local targetId = teamMainVm.GetTargetIdByDungeonId(dungeonId, difficulty)
  if not targetId then
    return
  end
  local settingVm_ = Z.VMMgr.GetVM("setting")
  local requestParam = {}
  requestParam.targetId = targetId
  local confirmFunc = function()
    settingVm_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ToBeLeader")] = "0"
    })
    requestParam.wantLeader = 1
    Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchWantLeaderChange, true)
    MatchTeamVm.AsyncBeginMatch(requestParam)
  end
  local cancelFunc = function()
    settingVm_.AsyncSaveSetting({
      [Z.PbEnum("ESettingType", "ToBeLeader")] = "1"
    })
    requestParam.wantLeader = 0
    Z.EventMgr:Dispatch(Z.ConstValue.Match.MatchWantLeaderChange, false)
    MatchTeamVm.AsyncBeginMatch(requestParam)
  end
  local teamVM = Z.VMMgr.GetVM("team")
  if teamVM.CheckIsInTeam() and teamVM.GetYouIsLeader() then
    requestParam.wantLeader = 1
    MatchTeamVm.AsyncBeginMatch(requestParam)
  elseif Z.DialogViewDataMgr:CheckNeedShowDlg(E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.MatchLeaderConfirmTips) then
    local data = {
      dlgType = E.DlgType.YesNo,
      onConfirm = confirmFunc,
      onCancel = cancelFunc,
      labDesc = Lang("ConfirmMatchTips"),
      dlgPreferencesType = E.DlgPreferencesType.Login,
      preferencesKey = E.DlgPreferencesKeyType.MatchLeaderConfirmTips,
      labNo = Lang("ConfirmMatchTipsNo"),
      labYes = Lang("ConfirmMatchTipsYes")
    }
    Z.DialogViewDataMgr:OpenDialogView(data)
  else
    local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
    local isLeader = settingInfo[Z.PbEnum("ESettingType", "ToBeLeader")] or "0"
    requestParam.wantLeader = isLeader == "0" and 1 or 0
    MatchTeamVm.AsyncBeginMatch(requestParam)
  end
end

function MatchTeamVm.AsyncBeginMatch(requestParam)
  Z.CoroUtil.create_coro_xpcall(function()
    worldProxy.BeginMatch(requestParam)
  end)()
end

return MatchTeamVm
