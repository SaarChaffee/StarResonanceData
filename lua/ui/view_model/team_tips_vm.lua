local teamData = Z.DataMgr.Get("team_data")
local openTeamTipsView = function()
  Z.UIMgr:OpenView("team_tips")
end
local closeTeamTipsView = function()
  Z.UIMgr:CloseView("team_tips")
end
local applyCaptainCall = function(callData, flag, cancelSource)
  local teamVM_ = Z.VMMgr.GetVM("team")
  if flag then
    teamVM_.AsyncTransferLeader(callData.charId, cancelSource:CreateToken())
  else
    teamVM_.RefuseLeaderApply(callData.charId, cancelSource:CreateToken())
  end
end
local applyCaptain = function(memData)
  local info = {
    charId = memData.basicData.charID,
    tipsType = E.InvitationTipsType.TeamLeader,
    content = Lang("RequestToBeCaptain"),
    func = applyCaptainCall,
    cd = Z.Global.TeamApplyCaptainLastTime,
    funcParam = {
      charId = memData.basicData.charID
    },
    curTalentPoolId = memData.basicData.curTalentPoolId
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end
local transferCaptainCall = function(callData, flag, cancelSource)
  local teamVM_ = Z.VMMgr.GetVM("team")
  teamVM_.AsyncAcceptTransferBeLeader(flag, cancelSource:CreateToken())
end
local transferCaptain = function(leaderData)
  local info = {
    charId = leaderData.basicData.charID,
    tipsType = E.InvitationTipsType.TeamTransfer,
    content = Lang("ChangeCaptain"),
    func = transferCaptainCall,
    cd = Z.Global.TeamApplyCaptainLastTime,
    funcParam = {},
    curTalentPoolId = leaderData.basicData.curTalentPoolId
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end
local applyTeamCall = function(callData, flag, cancelSource)
  local teamVM_ = Z.VMMgr.GetVM("team")
  teamVM_.AsyncDealApplyJoin(callData.charId, flag, teamData.CancelSource:CreateToken())
  teamVM_.AsyncLeaderGetApplyList(false, teamData.CancelSource:CreateToken())
end
local applyTeam = function(applyInfo)
  local chatSettingVm = Z.VMMgr.GetVM("chat_setting")
  if not chatSettingVm.CheckApplyType(E.ESocialApplyType.ETeamApply, applyInfo.charId) then
    return
  end
  local info = {
    charId = applyInfo.charId,
    tipsType = E.InvitationTipsType.TeamRequest,
    content = Lang("RequestJoinTeam"),
    func = applyTeamCall,
    cd = Z.Global.TeamApplyCaptainLastTime,
    funcParam = {
      charId = applyInfo.charId
    },
    curTalentPoolId = applyInfo.curTalentPoolId
  }
  teamData:SetApplyList(applyInfo.charId)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.TeamApplyButton, teamData:GetApplyCount())
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end
local receiveInvitedCall = function(callData, flag, cancelSource)
  local teamVM_ = Z.VMMgr.GetVM("team")
  if flag then
    if teamVM_.CheckIsInTeam() then
      local nowTeam = teamData.TeamInfo.baseInfo.teamId
      if nowTeam == callData.teamId then
        Z.TipsVM.ShowTipsLang(1000623)
        return
      end
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitAgreeTeam"), function()
        teamVM_.AsyncQuitReplyTeam(callData.teamId, cancelSource)
      end)
    else
      teamVM_.AsyncReplyBeInvitation(callData.teamId, true, cancelSource:CreateToken())
    end
  else
    teamVM_.AsyncReplyBeInvitation(callData.teamId, false, cancelSource:CreateToken())
  end
end
local receiveInvited = function(inviteMemData, teamId, targetId, teamNum, memberType)
  local teamTargetData = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if teamTargetData == nil then
    return
  end
  local chatSettingVm = Z.VMMgr.GetVM("chat_setting")
  if not chatSettingVm.CheckApplyType(E.ESocialApplyType.ETeamApply, inviteMemData.basicData.charID) then
    return
  end
  local targetName = teamTargetData.Name
  local teamMaxNum = (memberType == nil or memberType == E.ETeamMemberType.Five) and Z.Global.TeamMaxNum or 20
  local inviteInfo = {
    charId = inviteMemData.basicData.charID,
    tipsType = E.InvitationTipsType.TeamInvite,
    content = string.zconcat(targetName, " ", teamNum, "/", teamMaxNum),
    func = receiveInvitedCall,
    cd = Z.Global.TeamInviteLastTime,
    funcParam = {teamId = teamId},
    curTalentPoolId = inviteMemData.curTalentPoolId
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, inviteInfo)
end
local callTogether = function(charId)
  local teamVM = Z.VMMgr.GetVM("team")
  local teamData = Z.DataMgr.Get("team_data")
  local curTalentPoolId = 0
  local memberData = teamData.TeamInfo.members[charId]
  if memberData and memberData.socialData then
    curTalentPoolId = memberData.socialData.basicData.curTalentPoolId
  end
  local inviteInfo = {
    charId = charId,
    tipsType = E.InvitationTipsType.Branching,
    content = Lang("TeamCallTogether"),
    func = teamVM.AsyncTeamMemCallOperator,
    cd = Z.Global.TeamCallCD,
    curTalentPoolId = curTalentPoolId
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, inviteInfo)
end
local callInviteJoinDungeons = function(charId, groupKey, dungeonId)
  local teamVM = Z.VMMgr.GetVM("team")
  local teamData = Z.DataMgr.Get("team_data")
  local dungeonRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local memberData = teamData.TeamInfo.members[charId]
  if not dungeonRow then
    return
  end
  local inviteInfo = {
    charId = charId,
    tipsType = E.InvitationTipsType.Summon,
    content = Lang("DungeonCallTogether", {
      val1 = memberData.socialData.basicData.name,
      val2 = dungeonRow.Name
    }),
    func = teamVM.AsyncJoinDungeons,
    funcParam = {groupKey = groupKey, dungeonId = dungeonId},
    cd = Z.Global.DungeonSummonedTime
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, inviteInfo)
end
local ret = {
  CloseTeamTipsView = closeTeamTipsView,
  OpenTeamTipsView = openTeamTipsView,
  ApplyTeam = applyTeam,
  ReceiveInvited = receiveInvited,
  ApplyCaptain = applyCaptain,
  TransferCaptain = transferCaptain,
  CallTogether = callTogether,
  CallInviteJoinDungeons = callInviteJoinDungeons
}
return ret
