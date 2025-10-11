local pb = require("pb2")
local GrpcTeamNtfStubImpl = {}

function GrpcTeamNtfStubImpl:OnCreateStub()
end

function GrpcTeamNtfStubImpl:NoticeUpdateTeamInfo(call, vRequest)
  local serverTeamBaseInfo = vRequest.baseInfo
  local teamData = Z.DataMgr.Get("team_data")
  local clientTeamBaseInfo = teamData.TeamInfo.baseInfo
  local matchVm = Z.VMMgr.GetVM("match")
  if clientTeamBaseInfo and serverTeamBaseInfo then
    if clientTeamBaseInfo.targetId ~= serverTeamBaseInfo.targetId then
      local teamTargetInfo = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(serverTeamBaseInfo.targetId)
      if teamTargetInfo == nil then
        return
      end
      local param = {
        pt = {
          target = teamTargetInfo.Name
        }
      }
      clientTeamBaseInfo.targetId = serverTeamBaseInfo.targetId
      clientTeamBaseInfo.desc = serverTeamBaseInfo.desc
      clientTeamBaseInfo.hallShow = serverTeamBaseInfo.hallShow
      Z.TipsVM.ShowTipsLang(1000635, param)
      Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshSetting)
    elseif clientTeamBaseInfo.desc ~= serverTeamBaseInfo.desc then
      clientTeamBaseInfo.desc = serverTeamBaseInfo.desc
      Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshSettingDes)
    elseif clientTeamBaseInfo.hallShow ~= serverTeamBaseInfo.hallShow then
      clientTeamBaseInfo.hallShow = serverTeamBaseInfo.hallShow
    end
    local leaderChange = false
    if clientTeamBaseInfo.leaderId ~= serverTeamBaseInfo.leaderId then
      local dungeonPrepareVm_ = Z.VMMgr.GetVM("dungeon_prepare")
      dungeonPrepareVm_.CancelReadyCheck()
      if serverTeamBaseInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId then
        Z.TipsVM.ShowTipsLang(1000633)
      else
        local teamMebmer = teamData.TeamInfo.members[serverTeamBaseInfo.leaderId]
        if teamMebmer then
          local param = {
            player = {
              name = teamMebmer.socialData.basicData.name
            }
          }
          Z.TipsVM.ShowTipsLang(1000618, param)
        end
      end
      teamData:SetLeaderId(serverTeamBaseInfo.leaderId)
      leaderChange = true
    end
    if clientTeamBaseInfo.teamMemberType ~= serverTeamBaseInfo.teamMemberType then
      local tab = {}
      if serverTeamBaseInfo.teamMemberType == E.ETeamMemberType.Five then
        tab = {val = 5}
      else
        tab = {val = 20}
      end
      Z.TipsVM.ShowTips(1000648, tab)
    end
    teamData.TeamInfo.baseInfo = serverTeamBaseInfo
    if leaderChange then
      teamData:setAttrETeammateList()
    end
    self:setTeamGroupInfo()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:updateTeamFastSyncData(teamFastSyncData)
  local teamData = Z.DataMgr.Get("team_data")
  local clientMemberInfo = teamData.TeamInfo.members[teamFastSyncData.charId]
  if clientMemberInfo then
    if clientMemberInfo.pos ~= teamFastSyncData.position then
      clientMemberInfo.pos = teamFastSyncData.position
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MemberInfoChange, clientMemberInfo)
    end
    if clientMemberInfo.hp ~= teamFastSyncData.hp or clientMemberInfo.maxHp ~= teamFastSyncData.maxHp then
      clientMemberInfo.hp = teamFastSyncData.hp
      clientMemberInfo.maxHp = teamFastSyncData.maxHp
      Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateMemberData, {
        charId = teamFastSyncData.charId,
        isForce = true
      })
    end
    if clientMemberInfo.socialData.basicData.sceneId ~= teamFastSyncData.sceneId then
      clientMemberInfo.socialData.basicData.sceneId = teamFastSyncData.sceneId
      Z.EventMgr:Dispatch(Z.ConstValue.Team.ChangeSceneId, clientMemberInfo.socialData)
    end
  end
end

function GrpcTeamNtfStubImpl:NoticeUpdateTeamMemberInfo(call, vRequest)
  if vRequest.teamMemberSyncDatas then
    for index, value in pairs(vRequest.teamMemberSyncDatas) do
      GrpcTeamNtfStubImpl:updateTeamFastSyncData(value)
    end
  end
  if vRequest.teamMemberSocialDatas then
    local teamData = Z.DataMgr.Get("team_data")
    for index, value in ipairs(vRequest.teamMemberSocialDatas) do
      local charId = value.charId
      local clientMemberInfo = teamData.TeamInfo.members[charId]
      if clientMemberInfo == nil then
        return
      end
      if clientMemberInfo.isAi then
        return
      end
      if clientMemberInfo.socialData then
        if value.socialData.basicData and clientMemberInfo.socialData.basicData.offlineTime ~= value.socialData.basicData.offlineTime then
          clientMemberInfo.socialData.basicData.offlineTime = value.socialData.basicData.offlineTime
          Z.EventMgr:Dispatch(Z.ConstValue.Team.OnLineState, value.socialData)
        end
        teamData:SetSocialData(charId, value.socialData)
        Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshMemberInfo, clientMemberInfo)
      end
    end
  end
end

function GrpcTeamNtfStubImpl:NotifyApplyJoin(call, vRequest)
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.ApplyTeam(vRequest.apply)
end

function GrpcTeamNtfStubImpl:NotifyInvitation(call, vRequest)
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.ReceiveInvited(vRequest.inviteMemData, vRequest.teamid, vRequest.targetId, vRequest.teamNum, vRequest.teamMemberType)
end

function GrpcTeamNtfStubImpl:NotifyRefuseInvite(call, vRequest)
  local param = {
    player = {
      name = vRequest.inviteesName
    }
  }
  Z.TipsVM.ShowTipsLang(1000620, param)
end

function GrpcTeamNtfStubImpl:RetInviteToTeam(call, vRequest)
end

function GrpcTeamNtfStubImpl:NotifyLeaderApplyListSize(call, vRequest)
  Z.CoroUtil.create_coro_xpcall(function()
    local teamData = Z.DataMgr.Get("team_data")
    local teamVm = Z.VMMgr.GetVM("team")
    teamVm.AsyncLeaderGetApplyList(false, teamData.CancelSource:CreateToken())
    Z.RedPointMgr.UpdateNodeCount(E.RedType.TeamApplyButton, teamData:GetApplyCount())
  end)()
end

function GrpcTeamNtfStubImpl:NotifyApplyBeLeader(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  if vRequest.memData.charId == teamData.TeamInfo.baseInfo.leaderId or vRequest.memData.charId == Z.ContainerMgr.CharSerialize.charBase.charId then
    return
  end
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.ApplyCaptain(vRequest.memData)
end

function GrpcTeamNtfStubImpl:NotifyRejectApplicant(call, vRequest)
  local param = {
    player = {
      name = vRequest.leaderName
    }
  }
  Z.TipsVM.ShowTipsLang(1000621, param)
end

function GrpcTeamNtfStubImpl:NotifyBeTransferLeader(call, vRequest)
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.TransferCaptain(vRequest.leaderData)
end

function GrpcTeamNtfStubImpl:NotifyRefuseBeTransferLeader(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local param = {
    player = {name = ""}
  }
  local memData = teamData.TeamInfo.members[vRequest.memId]
  if memData then
    param.player.name = memData.socialData and memData.socialData.basicData.name or ""
  end
  local teamData = Z.DataMgr.Get("team_data")
  local teamInfo = teamData.TeamInfo.baseInfo
  if teamInfo.leaderId == vRequest.memId then
    Z.TipsVM.ShowTipsLang(1000634, param)
  else
    Z.TipsVM.ShowTipsLang(1000607, param)
  end
end

function GrpcTeamNtfStubImpl:NoticeTeamDissolve(call, vRequest)
  Z.TipsVM.ShowTipsLang(1000617)
  local teamVm = Z.VMMgr.GetVM("team")
  teamVm.QuiteTeamVoice()
  local teamData = Z.DataMgr.Get("team_data")
  teamData:SetTeamInfo({}, {})
  Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:NotifyCharMatchResult(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local teamVM = Z.VMMgr.GetVM("team")
  local matchVm = Z.VMMgr.GetVM("match")
  if vRequest.success then
    if not teamVM.CheckIsInTeam() then
      Z.SDKReport.Report(Z.SDKReportEvent.TeamUp)
    end
    teamVM.QuiteTeamVoice()
    teamData:SetTeamInfo(vRequest.teamInfo.baseInfo, vRequest.teamInfo.members)
    teamVM.JoinTeamVoice()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.Team.MatchWaitTimeOut)
  end
end

function GrpcTeamNtfStubImpl:NotifyTeamMatchResult(call, vRequest)
  if vRequest.success then
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
  else
    local teamData = Z.DataMgr.Get("team_data")
    local teamInfo = teamData.TeamInfo.baseInfo
    local selfIsLeader = teamInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
    if selfIsLeader then
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MatchWaitTimeOut)
    end
  end
end

function GrpcTeamNtfStubImpl:NotifyCharAbortMatch(call, vRequest)
end

function GrpcTeamNtfStubImpl:NotifyTeamActivityState(call, vRequest)
  local teamEntersVM = Z.VMMgr.GetVM("team_enter")
  teamEntersVM.HandleTeamActivity(vRequest.state)
end

function GrpcTeamNtfStubImpl:TeamActivityResult(call, vRequest)
  Z.TipsVM.ShowTips(vRequest.errCode)
end

function GrpcTeamNtfStubImpl:TeamActivityListResult(call, vRequest)
  local teamVm = Z.VMMgr.GetVM("team")
  teamVm.TeamActivityListResult(vRequest)
end

function GrpcTeamNtfStubImpl:TeamActivityVoteResult(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local mems = teamData.TeamInfo.members
  local memInfo = mems[vRequest.vCharId]
  if not memInfo then
    return
  end
  if vRequest.code == E.TeamVoteRet.Cancel then
    Z.TipsVM.ShowTipsLang(1000636)
  elseif vRequest.code == E.TeamVoteRet.TimeOut then
    local param = {
      player = {
        name = memInfo.socialData and memInfo.socialData.basicData.name or ""
      }
    }
    Z.TipsVM.ShowTipsLang(1000637, param)
  else
    local isAgree = vRequest.code == E.TeamVoteRet.Agree and true or false
    Z.EventMgr:Dispatch(Z.ConstValue.Team.TeamRefreshActivityVoteResult, {
      charId = vRequest.vCharId,
      isAgree = isAgree
    })
    if vRequest.code == E.TeamVoteRet.Refuse then
      local param = {
        player = {
          name = memInfo.socialData and memInfo.socialData.basicData.name or ""
        }
      }
      Z.TipsVM.ShowTipsLang(1000637, param)
    end
  end
end

function GrpcTeamNtfStubImpl:RetApplyJoinList(call, vRequest)
end

function GrpcTeamNtfStubImpl:NotifyJoinTeam(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local param = {
    player = {name = ""}
  }
  local teamVm = Z.VMMgr.GetVM("team")
  local isNewTeam = false
  if vRequest.baseInfo then
    if not teamVm.CheckIsInTeam() then
      isNewTeam = true
      param.player.name = Z.ContainerMgr.CharSerialize.charBase.name
      Z.TipsVM.ShowTipsLang(1000615, param)
      teamData:SetTeamInfo(vRequest.baseInfo, {})
      teamVm.JoinTeamVoice()
      Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
      Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
      Z.EventMgr:Dispatch(Z.ConstValue.Team.EnterTeam)
      if vRequest.teamJoinType and vRequest.teamJoinType == Z.PbEnum("ETeamJoinType", "ETeamJoinTypeTargetMatch") and vRequest.baseInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId then
        Z.TipsVM.ShowTips(1000642)
      end
      Z.SDKReport.Report(Z.SDKReportEvent.TeamUp)
    else
      teamData.TeamInfo.baseInfo = vRequest.baseInfo
    end
  end
  for key, menber in ipairs(vRequest.memberData) do
    local charId = menber.charId
    local voiceInfo = vRequest.memRealTimeVoiceInfos[charId]
    if voiceInfo then
      menber.speakState = voiceInfo.speakStatus
      menber.micState = voiceInfo.microphoneStatus
    end
    local entityVm = Z.VMMgr.GetVM("entity")
    menber.isAi = entityVm.CheckIsAIByEntId(charId)
    teamData:SetTeamMember(charId, menber)
  end
  for key, member in ipairs(vRequest.memberData) do
    local charId = member.charId
    teamData:SetSocialData(charId, member.socialData)
    if not isNewTeam and charId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
      if member.socialData.basicData.botAiId and member.socialData.basicData.botAiId ~= 0 then
        local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", member.socialData.basicData.botAiId)
        if botAITableRow then
          param.player.name = botAITableRow.Name
        end
      else
        param.player.name = member.socialData.basicData.name
      end
      Z.TipsVM.ShowTipsLang(1000615, param)
    end
  end
  if not isNewTeam then
    local dungeonPrepareVm_ = Z.VMMgr.GetVM("dungeon_prepare")
    dungeonPrepareVm_.CancelReadyCheck()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:CheckNeedSwitchSceneLine(vRequest)
  local leaderId_ = vRequest.baseInfo.leaderId
  local playerId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  local leaderLineId_, playerLineId, leaderSceneId, playerSceneId
  for key, value in ipairs(vRequest.memberData) do
    if value.charId == leaderId_ then
      leaderSceneId = value.socialData.basicData.sceneId
      leaderLineId_ = value.socialData.userSceneInfo.lineId
    end
    if value.charId == playerId_ then
      playerLineId = value.socialData.userSceneInfo.lineId
      playerSceneId = value.socialData.basicData.sceneId
    end
  end
  if leaderSceneId == playerSceneId and leaderLineId_ ~= playerLineId then
    Z.DialogViewDataMgr:OpenCountdownNODialog(Lang("TeamSwitchLineCheck"), function()
      local scenelineVM_ = Z.VMMgr.GetVM("sceneline")
      scenelineVM_.AsyncReqSwitchSceneLineByCharId(leaderId_)
    end, nil, Z.Global.LineTipButtonCD)
  end
end

function GrpcTeamNtfStubImpl:NotifyLeaveTeam(call, vRequest)
  local param = {
    player = {name = ""}
  }
  local charId = vRequest.charId
  local type = vRequest.leaveType
  local teamData = Z.DataMgr.Get("team_data")
  if charId == Z.ContainerMgr.CharSerialize.charBase.charId then
    if type == E.TeamQuitType.KickOut then
      Z.TipsVM.ShowTipsLang(1000626)
    end
    if type == E.TeamQuitType.MatchUnReady then
      Z.TipsVM.ShowTipsLang(16002046)
    end
    local teamVm = Z.VMMgr.GetVM("team")
    teamVm.QuiteTeamVoice()
    teamData:SetTeamInfo({}, {})
    Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
  else
    local member = teamData.TeamInfo.members[charId]
    if member and member.socialData then
      if member.isAi then
        local botAiId = member.socialData.basicData.botAiId
        local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
        if botAITableRow then
          param.player.name = botAITableRow.Name
        end
      else
        param.player.name = member.socialData.basicData.name
      end
    end
    Z.TipsVM.ShowTipsLang(1000616, param)
    teamData:SetTeamMember(charId, nil)
  end
  local dungeonPrepareVm_ = Z.VMMgr.GetVM("dungeon_prepare")
  dungeonPrepareVm_.CancelReadyCheck()
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:NotifyTeamMemBeCall(call, vRequest)
  local leaderId = vRequest.leaderId
  local teamTipsVm = Z.VMMgr.GetVM("team_tips")
  teamTipsVm.CallTogether(leaderId)
end

function GrpcTeamNtfStubImpl:UpdateTeamMemBeCall(call, vRequest)
  local callState = vRequest.callState
  local teamData = Z.DataMgr.Get("team_data")
  for charId, state in pairs(callState) do
    local memberData = teamData.TeamInfo.members[charId]
    if memberData then
      teamData.TeamInfo.members[charId].callStatus = state
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.ChangeCallStatus)
end

function GrpcTeamNtfStubImpl:NotifyTeamMemBeCallResult(call, vRequest)
  local charId = vRequest.memberId
  local tipId = vRequest.tipsId
  if tipId == 0 then
    return
  end
  local param = {
    player = {name = ""}
  }
  local teamData = Z.DataMgr.Get("team_data")
  local memberData = teamData.TeamInfo.members[charId]
  if charId ~= Z.ContainerMgr.CharSerialize.charBase.charId and memberData and memberData.socialData then
    param.player.name = memberData.socialData.basicData.name
  end
  Z.TipsVM.ShowTipsLang(1000600 + tipId, param)
end

function GrpcTeamNtfStubImpl:NotifyTeamEnterErr(call, vRequest)
  Z.TipsVM.ShowTips(vRequest.errCode)
end

function GrpcTeamNtfStubImpl:NotifyTeamMemMicrophoneStatusChange(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local memberData = teamData.TeamInfo.members[vRequest.memberId]
  if memberData and memberData.micState ~= vRequest.microphoneStatus then
    memberData.micState = vRequest.microphoneStatus
    Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshTeamMicState, vRequest.memberId, vRequest.microphoneStatus)
  end
end

function GrpcTeamNtfStubImpl:NotifyTeamMemsSpeakStatusChange(call, vRequest)
  local isRefresh = false
  local teamData = Z.DataMgr.Get("team_data")
  for charId, state in pairs(vRequest.memSpeakStatus) do
    local memberData = teamData.TeamInfo.members[charId]
    if memberData and memberData.speakState ~= state then
      memberData.speakState = state
      isRefresh = true
    end
  end
  if isRefresh then
    Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshTeamSpeakState)
  end
end

function GrpcTeamNtfStubImpl:NotifyTeamMemVoiceIdChange(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:SetMemberVoiceId(vRequest.memberId, vRequest.voiceId)
end

function GrpcTeamNtfStubImpl:NotifyInviteJoinDungeons(call, vRequest)
  local groupKey = vRequest.groupKey
  local dungeonId = vRequest.dungeonId
  local charId = vRequest.senderId
  local teamTipsVm = Z.VMMgr.GetVM("team_tips")
  teamTipsVm.CallInviteJoinDungeons(charId, groupKey, dungeonId)
end

function GrpcTeamNtfStubImpl:UpdateTeamMemberFastData(call, vRequest)
  GrpcTeamNtfStubImpl:updateTeamFastSyncData(vRequest.teamMemberFastSyncData)
end

function GrpcTeamNtfStubImpl:NotifyTeamGroupUpdate(call, vRequest)
  if vRequest.errCode ~= 0 then
    Z.TipsVM.ShowTips(vRequest.errCode)
  else
    local teamData = Z.DataMgr.Get("team_data")
    teamData.TeamInfo.baseInfo.teamMemberGroupInfos = vRequest.teamMemberGroupInfos
    self:setTeamGroupInfo()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
  end
end

function GrpcTeamNtfStubImpl:NotifyTeamChangeMemberType(call, vRequest)
  if vRequest.errorCode ~= 0 then
    Z.TipsVM.ShowTips(vRequest.errorCode)
  else
  end
end

function GrpcTeamNtfStubImpl:setTeamGroupInfo()
  local teamData = Z.DataMgr.Get("team_data")
  for groupId, memberGroupInfo in pairs(teamData.TeamInfo.baseInfo.teamMemberGroupInfos) do
    for index, charId in ipairs(memberGroupInfo.charIds) do
      if teamData.TeamInfo.members[charId] then
        teamData.TeamInfo.members[charId].groupId = groupId
      end
    end
  end
end

return GrpcTeamNtfStubImpl
