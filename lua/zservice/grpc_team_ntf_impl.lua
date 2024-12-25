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
    if clientTeamBaseInfo.targetId ~= serverTeamBaseInfo.targetId or clientTeamBaseInfo.desc ~= serverTeamBaseInfo.desc or clientTeamBaseInfo.hallShow ~= serverTeamBaseInfo.hallShow then
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
    end
    if clientTeamBaseInfo.leaderId ~= serverTeamBaseInfo.leaderId then
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
    end
    local matchData = Z.DataMgr.Get("match_data")
    local matchType = matchData:GetMatchType()
    if clientTeamBaseInfo.matching ~= serverTeamBaseInfo.matching and matchType == E.MatchType.Team then
      local matching = serverTeamBaseInfo.matching
      local matchingId = matching and 1000613 or 1000614
      clientTeamBaseInfo.matching = serverTeamBaseInfo.matching
      Z.TipsVM.ShowTipsLang(matchingId)
      matchVm.SetSelfMatchData(matching, "teamMatching")
      if matching then
        matchVm.CreateMatchingTips()
      else
        Z.EventMgr:Dispatch(Z.ConstValue.Team.RepeatTeamCancelMatch)
        matchVm.CancelMatchingTips()
      end
    end
    teamData.TeamInfo.baseInfo = serverTeamBaseInfo
  end
  if serverTeamBaseInfo.teamId and serverTeamBaseInfo.teamId > 0 then
    matchVm.SetSelfMatchData(false, "matching")
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:updateTeamFastSyncData(teamFastSyncData)
  local teamData = Z.DataMgr.Get("team_data")
  local clientMemberInfo = teamData.TeamInfo.members[teamFastSyncData.charId]
  if clientMemberInfo then
    if clientMemberInfo.socialData.sceneData.levelPos ~= teamFastSyncData.position then
      clientMemberInfo.socialData.sceneData.levelPos = teamFastSyncData.position
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MemberInfoChange, clientMemberInfo.socialData)
    end
    if clientMemberInfo.socialData.userAttrData.hp ~= teamFastSyncData.hp or clientMemberInfo.socialData.userAttrData.maxHp ~= teamFastSyncData.maxHp then
      clientMemberInfo.socialData.userAttrData.hp = teamFastSyncData.hp
      clientMemberInfo.socialData.userAttrData.maxHp = teamFastSyncData.maxHp
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
  if vRequest.syncType == 1 then
    for index, value in pairs(vRequest.teamFastSyncData.teamMemberSyncDatas) do
      GrpcTeamNtfStubImpl:updateTeamFastSyncData(value)
    end
    return
  end
  local serverMemberInfo = vRequest.socialData
  local charId = serverMemberInfo.basicData.charID
  local teamData = Z.DataMgr.Get("team_data")
  local clientMemberInfo = teamData.TeamInfo.members[charId]
  if clientMemberInfo == nil then
    return
  end
  if clientMemberInfo.isAi then
    if clientMemberInfo.socialData and clientMemberInfo.socialData.userAttrData and (clientMemberInfo.socialData.userAttrData.hp ~= serverMemberInfo.userAttrData.hp or clientMemberInfo.socialData.userAttrData.maxHp ~= serverMemberInfo.userAttrData.maxHp) then
      clientMemberInfo.socialData.userAttrData.hp = serverMemberInfo.userAttrData.hp
      clientMemberInfo.socialData.userAttrData.maxHp = serverMemberInfo.userAttrData.maxHp
      Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateMemberData, {
        charId = serverMemberInfo.basicData.charID,
        isForce = true
      })
    end
    return
  end
  if serverMemberInfo and clientMemberInfo.socialData then
    if clientMemberInfo.socialData.userAttrData.hp ~= serverMemberInfo.userAttrData.hp or clientMemberInfo.socialData.userAttrData.maxHp ~= serverMemberInfo.userAttrData.maxHp then
      clientMemberInfo.socialData.userAttrData.hp = serverMemberInfo.userAttrData.hp
      clientMemberInfo.socialData.userAttrData.maxHp = serverMemberInfo.userAttrData.maxHp
      Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateMemberData, {
        charId = serverMemberInfo.basicData.charID,
        isForce = true
      })
    end
    if clientMemberInfo.socialData.avatarInfo.avatarId ~= serverMemberInfo.avatarInfo.avatarId then
      clientMemberInfo.socialData.avatarInfo.avatarId = serverMemberInfo.avatarInfo.avatarId
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MemberUpDateHedaId, {
        charId = serverMemberInfo.basicData.charID,
        isForce = true
      })
    end
    if clientMemberInfo.socialData.sceneData.levelPos ~= serverMemberInfo.sceneData.levelPos then
      clientMemberInfo.socialData.sceneData.levelPos = serverMemberInfo.sceneData.levelPos
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MemberInfoChange, serverMemberInfo)
    end
    if clientMemberInfo.socialData.basicData.sceneGuid ~= serverMemberInfo.basicData.sceneGuid then
      teamData:SetTeamMemberSceneGuide(charId, serverMemberInfo.basicData.sceneGuid)
      Z.EventMgr:Dispatch(Z.ConstValue.Team.ChangeSceneGuid, serverMemberInfo)
    end
    if clientMemberInfo.socialData.basicData.sceneId ~= serverMemberInfo.basicData.sceneId then
      clientMemberInfo.socialData.basicData.sceneId = serverMemberInfo.basicData.sceneId
      Z.EventMgr:Dispatch(Z.ConstValue.Team.ChangeSceneId, serverMemberInfo)
    end
    if clientMemberInfo.socialData.sceneData.mapId ~= serverMemberInfo.sceneData.mapId then
      clientMemberInfo.socialData.sceneData.mapId = serverMemberInfo.sceneData.mapId
      teamData:SetSocialData(charId, serverMemberInfo)
      Z.EventMgr:Dispatch(Z.ConstValue.Team.MemberChangeScene)
    else
      teamData:SetSocialData(charId, serverMemberInfo)
    end
  end
  local teamVM = Z.VMMgr.GetVM("team")
  teamVM.SetLeaderId()
end

function GrpcTeamNtfStubImpl:NotifyApplyJoin(call, vRequest)
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.ApplyTeam(vRequest.apply)
end

function GrpcTeamNtfStubImpl:NotifyInvitation(call, vRequest)
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.ReceiveInvited(vRequest.inviteMemData, vRequest.teamid, vRequest.targetId, vRequest.teamNum)
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
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.TeamApplyButton, teamData:GetApplyCount())
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
    teamVM.QuiteTeamVoice()
    teamData:SetTeamInfo(vRequest.teamInfo.baseInfo, vRequest.teamInfo.members)
    teamVM.JoinTeamVoice()
    matchVm.SetSelfMatchData(false, "matching")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
    matchVm.CancelMatchingTips()
  else
    matchVm.SetSelfMatchData(false, "matching")
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
  if vRequest.retCode == 3 then
    Z.TipsVM.ShowTipsLang(1000636)
  elseif vRequest.retCode == 4 then
    local param = {
      player = {
        name = memInfo.socialData and memInfo.socialData.basicData.name or ""
      }
    }
    Z.TipsVM.ShowTipsLang(1000637, param)
  else
    local isAgree = vRequest.retCode == 1 and true or false
    Z.EventMgr:Dispatch(Z.ConstValue.Team.TeamRefreshActivityVoteResult, {
      charId = vRequest.vCharId,
      isAgree = isAgree
    })
    if vRequest.retCode == 2 then
      local param = {
        player = {
          name = memInfo.socialData and memInfo.socialData.basicData.name or ""
        }
      }
      Z.TipsVM.ShowTipsLang(1000637, param)
    end
  end
end

function GrpcTeamNtfStubImpl:TeamTargetList(call, vRequest)
  if vRequest.vIsRefresh then
    Z.TipsVM.ShowTipsLang(1000625)
  end
  local matchData = Z.DataMgr.Get("match_data")
  matchData:SetSelfMatchData(vRequest.vTargetId, "targetId")
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshHallList, vRequest.vTeamList)
end

function GrpcTeamNtfStubImpl:RetApplyJoinList(call, vRequest)
end

function GrpcTeamNtfStubImpl:NotifyJoinTeam(call, vRequest)
  local teamData = Z.DataMgr.Get("team_data")
  local param = {
    player = {name = ""}
  }
  local isNewTeam = false
  if vRequest.baseInfo then
    isNewTeam = true
    Z.TipsVM.ShowTipsLang(1000615, param)
    teamData:SetTeamInfo(vRequest.baseInfo, {})
    local teamVm = Z.VMMgr.GetVM("team")
    teamVm.JoinTeamVoice()
    local matchData = Z.DataMgr.Get("match_data")
    matchData:SetSelfMatchData(false, "matching")
    Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
    Z.EventMgr:Dispatch(Z.ConstValue.Team.EnterTeam)
    self:CheckNeedSwitchSceneLine(vRequest)
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
  for key, socialData in ipairs(vRequest.socialDatas) do
    local charId = socialData.basicData.charID
    teamData:SetSocialData(charId, socialData)
    if not isNewTeam and charId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
      param.player.name = socialData.basicData.name
      Z.TipsVM.ShowTipsLang(1000615, param)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
end

function GrpcTeamNtfStubImpl:CheckNeedSwitchSceneLine(vRequest)
  local leaderId_ = vRequest.baseInfo.leaderId
  local playerId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  local leaderLineId_, playerLineId, leaderSceneId, playerSceneId
  for key, value in ipairs(vRequest.socialDatas) do
    if value.basicData.charID == leaderId_ then
      leaderSceneId = value.basicData.sceneId
      leaderLineId_ = value.sceneData.lineId
    end
    if value.basicData.charID == playerId_ then
      playerLineId = value.sceneData.lineId
      playerSceneId = value.basicData.sceneId
    end
  end
  if leaderSceneId == playerSceneId and leaderLineId_ ~= playerLineId then
    Z.DialogViewDataMgr:OpenCountdownNODialog(Lang("TeamSwitchLineCheck"), function()
      local scenelineVM_ = Z.VMMgr.GetVM("sceneline")
      scenelineVM_.EnterSceneLine(leaderLineId_)
      Z.DialogViewDataMgr:CloseDialogView()
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
      param.player.name = member.socialData.basicData.name
    end
    Z.TipsVM.ShowTipsLang(1000616, param)
    teamData:SetTeamMember(charId, nil)
  end
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
  Z.TipsVM.ShowTips(vRequest.errorCode)
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

function GrpcTeamNtfStubImpl:UpdateTeamMemberFastData(call, vRequest)
  GrpcTeamNtfStubImpl:updateTeamFastSyncData(vRequest.teamMemberFastSyncData)
end

return GrpcTeamNtfStubImpl
