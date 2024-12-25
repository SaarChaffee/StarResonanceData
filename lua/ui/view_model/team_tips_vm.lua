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
    tipsType = E.InvitationTipsType.Leader,
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
    tipsType = E.InvitationTipsType.Transfer,
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
  local members = teamVM_.GetTeamMemData()
  if flag then
    if not teamVM_.CheckIsInTeam() then
      Z.TipsVM.ShowTipsLang(1000617)
      return
    end
    if 4 <= #members then
      Z.TipsVM.ShowTipsLang(1000619)
      return
    end
  end
  teamVM_.AsyncDealApplyJoin(callData.charId, flag, cancelSource:CreateToken())
  teamVM_.AsyncLeaderGetApplyList(false, cancelSource:CreateToken())
end
local applyTeam = function(applyInfo)
  local info = {
    charId = applyInfo.charId,
    tipsType = E.InvitationTipsType.Request,
    content = Lang("RequestJoinTeam"),
    func = applyTeamCall,
    cd = Z.Global.TeamApplyCaptainLastTime,
    funcParam = {
      charId = applyInfo.charId
    },
    curTalentPoolId = applyInfo.curTalentPoolId
  }
  teamData:SetApplyList(applyInfo.charId)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.TeamApplyButton, teamData:GetApplyCount())
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
        Z.DialogViewDataMgr:CloseDialogView()
      end)
    else
      teamVM_.AsyncReplyBeInvitation(callData.teamId, true, cancelSource:CreateToken())
    end
  else
    teamVM_.AsyncReplyBeInvitation(callData.teamId, false, cancelSource:CreateToken())
  end
end
local receiveInvited = function(inviteMemData, teamId, targetId, teamNum)
  local teamTargetData = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if teamTargetData == nil then
    return
  end
  local targetName = teamTargetData.Name
  local inviteInfo = {
    charId = inviteMemData.basicData.charID,
    tipsType = E.InvitationTipsType.Invite,
    content = targetName .. " " .. teamNum .. "/" .. 4,
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
local ret = {
  CloseTeamTipsView = closeTeamTipsView,
  OpenTeamTipsView = openTeamTipsView,
  ApplyTeam = applyTeam,
  ReceiveInvited = receiveInvited,
  ApplyCaptain = applyCaptain,
  TransferCaptain = transferCaptain,
  CallTogether = callTogether
}
return ret
