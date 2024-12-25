local worldTeamProxy = require("zproxy.world_proxy")
local TeamEnterDungeonConditionType = {
  [124005] = E.ConditionType.Level,
  [124006] = E.ConditionType.TaskOver,
  [1000639] = E.ConditionType.DungeonId,
  [1000638] = E.ConditionType.GS,
  [1000640] = E.ConditionType.DungeonScroe,
  [3322] = 99995,
  [3323] = 999956,
  [15001032] = 99997,
  [15001031] = 99998,
  [1000641] = 99999
}
local ETeamVoiceState = {
  MicVoice = 0,
  CloseVoice = 1,
  SpeakerVoice = 2,
  ShieldVoice = 3
}
local ETeamVoiceSpeakState = {
  NotSpeak = 0,
  Speaking = 1,
  EndSpeak = 2
}
local handleError = function(errCode)
  if errCode ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= errCode then
    Z.TipsVM.ShowTips(errCode)
  end
end
local setMicrophoneStatus = function(microphoneStatus)
  local require = {}
  require.microphoneStatus = microphoneStatus
  worldTeamProxy.SetMicrophoneStatus(require)
end
local setSpeakStatus = function(speakStatus)
  local require = {}
  require.speakStatus = speakStatus
  worldTeamProxy.SetSpeakStatus(require)
end
local closeTeamVoice = function()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TeamSpeakVoice)
  Z.VoiceBridge.CloseMic()
  Z.VoiceBridge.CloseSpeaker()
end
local openTeamSpeaker = function()
  local isOpen = Z.VoiceBridge.OpenSpeaker()
  if isOpen then
    local settingVm = Z.VMMgr.GetVM("setting")
    local value = settingVm.Get(E.SettingID.PlayerVoiceReceptionVolume)
    Z.VoiceBridge.SetSpeakerVolume(value / 100)
    Z.VoiceBridge.CloseMic()
    Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.TeamSpeakVoice)
  end
  return isOpen
end
local openTeamMic = function()
  local isOpen = Z.VoiceBridge.OpenMic()
  if isOpen then
    local settingVm = Z.VMMgr.GetVM("setting")
    local value = settingVm.Get(E.SettingID.PlayerVoiceTransmissionVolume)
    Z.VoiceBridge.SetMicVolume(value / 100)
    local selfCharId = Z.ContainerMgr.CharSerialize.charBase.charId
    Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamSpeakVoice, function()
      local isSpeaking = Z.VoiceBridge.IsSpeaking()
      local state = isSpeaking and ETeamVoiceSpeakState.Speaking or ETeamVoiceSpeakState.NotSpeak
      local teamData = Z.DataMgr.Get("team_data")
      local memberData = teamData.TeamInfo.members[selfCharId]
      if memberData and memberData.micState ~= state then
        setSpeakStatus(state)
      end
    end, 1, -1, nil, function()
      setSpeakStatus(ETeamVoiceSpeakState.NotSpeak)
    end)
  else
    Z.TipsVM.ShowTips(4401)
  end
  return isOpen
end
local joinTeamVoice = function()
  local teamData = Z.DataMgr.Get("team_data")
  if teamData.TeamInfo.baseInfo.teamId == nil then
    return
  end
  local teamId = tostring(teamData.TeamInfo.baseInfo.teamId)
  if teamData.VoiceRoomName ~= teamId then
    local isJoin = Z.VoiceBridge.JoinRoom(teamId)
    if isJoin then
      local isOpen = openTeamSpeaker()
      if isOpen then
        Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshTeamVoiceState, ETeamVoiceState.SpeakerVoice)
        setMicrophoneStatus(ETeamVoiceState.SpeakerVoice)
      end
    end
  end
end
local quiteTeamVoice = function()
  closeTeamVoice()
  local teamData = Z.DataMgr.Get("team_data")
  Z.VoiceBridge.QuitRoom(teamData.VoiceRoomName)
end
local blockTeamMemberVoice = function(charId, isBlock)
  local teamData = Z.DataMgr.Get("team_data")
  if teamData.TeamInfo.baseInfo.teamId then
    local member = teamData.TeamInfo.members[charId]
    if member and member.socialData then
      local memberVoiceId = teamData:GetMemberVoiceId(charId)
      if memberVoiceId and memberVoiceId ~= 0 then
        Z.VoiceBridge.BlockPlayerVoice(memberVoiceId, isBlock, teamData.TeamInfo.baseInfo.teamId)
        teamData:SetBlockVoiceState(charId, isBlock)
        if isBlock then
          Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshTeamMicState, charId, ETeamVoiceState.ShieldVoice)
        else
          Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshMemberMicState, charId)
        end
      end
    end
  end
end
local recoverMicState = function()
  local teamData = Z.DataMgr.Get("team_data")
  local charId = Z.ContainerMgr.CharSerialize.charBase.charId
  local memberData = teamData.TeamInfo.members[charId]
  if memberData then
    if memberData.micState == ETeamVoiceState.CloseVoice then
      closeTeamVoice()
    elseif memberData.micState == ETeamVoiceState.SpeakerVoice then
      openTeamSpeaker()
    elseif memberData.micState == ETeamVoiceState.MicVoice then
      openTeamMic()
    end
  end
end
local recoverTeamVoice = function()
  local teamData = Z.DataMgr.Get("team_data")
  if teamData.TeamInfo.baseInfo.teamId == nil then
    return
  end
  local teamId = tostring(teamData.TeamInfo.baseInfo.teamId)
  if teamData.VoiceRoomName ~= teamId then
    local isJoin = Z.VoiceBridge.JoinRoom(teamId)
    if isJoin then
      recoverMicState()
    end
  end
end
local asyncCreatTeam = function(targetId, cancelToken)
  if targetId == E.TeamTargetId.All then
    targetId = E.TeamTargetId.Costume
  end
  local request = {}
  local settingInfo = Z.ContainerMgr.CharSerialize.settingData.settingMap
  local inTeamHall = settingInfo[Z.PbEnum("ESettingType", "ShowInTeamHall")] or "0"
  local autoMatch = settingInfo[Z.PbEnum("ESettingType", "TeamAutoMatch")] or "0"
  request.charId = Z.ContainerMgr.CharSerialize.charBase.charId
  request.targetId = targetId
  request.isAutoMatch = autoMatch == "0"
  request.isShowInHall = inTeamHall == "0"
  local ret = worldTeamProxy.CreateTeam(request, cancelToken)
  handleError(ret.errCode)
  local teamInfo = ret.teamInfo
  if teamInfo then
    local teamData = Z.DataMgr.Get("team_data")
    Z.TipsVM.ShowTipsLang(1000612)
    teamData:SetTeamInfo(teamInfo.baseInfo, teamInfo.members)
    teamData:SetSocialData(Z.ContainerMgr.CharSerialize.charBase.charId, ret.userDetailedData)
    local matchVm_ = Z.VMMgr.GetVM("match")
    matchVm_.SetSelfMatchData(false, "matching")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
    Z.EventMgr:Dispatch(Z.ConstValue.Chat.ChatInputState)
    Z.EventMgr:Dispatch(Z.ConstValue.Team.EnterTeam)
    Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
    joinTeamVoice()
  end
end
local setTeamApplyTime = function(teamId)
  local teamData = Z.DataMgr.Get("team_data")
  local teamApplyCd = Z.Global.TeamApplyCD
  teamData:SetTeamApplyStatus(teamId, true)
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamApply .. "_" .. teamId, function()
    teamData:SetTeamApplyStatus(teamId, nil)
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateApplyBtn)
  end, teamApplyCd)
end
local asyncApplyJoinTeam = function(teamIdList, cancelToken)
  local request = {}
  request.teamId = teamIdList
  local ret = worldTeamProxy.ApplyJoinTeam(request, cancelToken)
  local teamIdList = ret.teamId
  for key, value in pairs(teamIdList) do
    setTeamApplyTime(value)
  end
  handleError(ret.errCode)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateApplyBtn)
  return ret.errCode
end
local asyncReplyBeInvitation = function(teamId, isAgree, cancelToken)
  local request = {}
  request.teamId = teamId
  request.agree = isAgree
  local ret = worldTeamProxy.ReplyBeInvitation(request, cancelToken)
  handleError(ret.errCode)
end
local asyncQuitTeam = function(cancelSource)
  local request = {}
  local ret = worldTeamProxy.QuitTeam(request, cancelSource:CreateToken())
  handleError(ret.errCode)
  if ret.errCode ~= 0 then
    return ret.errCode
  end
  local teamData = Z.DataMgr.Get("team_data")
  local matchVm_ = Z.VMMgr.GetVM("match")
  local isKickOut = ret.isKickOut
  if isKickOut then
    Z.TipsVM.ShowTipsLang(1000626)
  else
    quiteTeamVoice()
    teamData:SetTeamInfo({}, {})
    local param = {
      player = {name = " "}
    }
    Z.TipsVM.ShowTipsLang(1000616, param)
    matchVm_.CancelMatchingTips()
    local teamList = teamData:GetLeaveAndApplyTeam()
    if teamList then
      asyncApplyJoinTeam(teamList, cancelSource:CreateToken())
      teamData:SetLeaveAndApplyTeam(nil)
    end
    local replyTeam = teamData:GetLeaveAndReplyTeam()
    if replyTeam then
      asyncReplyBeInvitation(replyTeam, true, cancelSource:CreateToken())
      teamData:SetLeaveAndReplyTeam(nil)
    end
  end
  teamData:SetTeamSimpleTime(0, "applyCaptain")
  Z.VMMgr.GetVM("chat_main").ClearChannelQueueByChannelId(E.ChatChannelType.EChannelTeam)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.TeamApplyButton, 0)
  matchVm_.SetSelfMatchData(false, "teamMatching")
  return ret.errCode
end
local asyncSetTeamTargetInfo = function(targetId, desc, autoMatch, show, cancelToken)
  local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
  if not teamTargetRow then
    return
  end
  if autoMatch and teamTargetRow.MemberCountStopMatch == 0 then
    Z.TipsVM.ShowTips(1000750)
    autoMatch = false
  end
  local request = {}
  request.targetId = targetId
  request.desc = desc
  request.autoMatch = autoMatch
  request.show = show
  local ret = worldTeamProxy.SetTeamTargetInfo(request, cancelToken)
  handleError(ret.errCode)
  if ret.errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.ScreenWordAndGrpcPass)
  end
end
local setTeamInviteTime = function(charId)
  local teamData = Z.DataMgr.Get("team_data")
  local teamInviteCd = Z.Global.TeamInviteCD
  teamData:SetTeamInviteStatus(charId, true)
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamInvite .. "_" .. charId, function()
    teamData:SetTeamInviteStatus(charId, nil)
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateInviteBtn, charId)
  end, teamInviteCd)
end
local asyncInviteToTeam = function(inviteeCharId, cancelToken)
  local request = {}
  request.inviteeCharId = inviteeCharId
  local ret = worldTeamProxy.InviteToTeam(request, cancelToken)
  handleError(ret.errCode)
  if ret.errCode == 0 then
    Z.TipsVM.ShowTipsLang(1000627)
    setTeamInviteTime(inviteeCharId)
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateInviteBtn, inviteeCharId)
  end
end
local leaveTeamDialog = function(cancelSource)
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("QuitTeam"), function()
    asyncQuitTeam(cancelSource)
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end
local asyncApplyBeLeader = function(cancelToken)
  local request = {}
  local ret = worldTeamProxy.ApplyBeLeader(request, cancelToken)
  handleError(ret.errCode)
end
local asyncTransferLeader = function(newLeaderId, cancelToken)
  local request = {}
  request.newLeaderId = newLeaderId
  local ret = worldTeamProxy.TransferLeader(request, cancelToken)
  handleError(ret.errCode)
end
local asyncAcceptTransferBeLeader = function(agree, cancelToken)
  local request = {}
  request.agree = agree
  local ret = worldTeamProxy.AcceptTransferBeLeader(request, cancelToken)
  handleError(ret.errCode)
end
local asyncTickOut = function(memberId, cancelToken)
  local request = {}
  request.vMemId = memberId
  local ret = worldTeamProxy.KickOut(request, cancelToken)
  handleError(ret.errCode)
end
local asyncGetTeamList = function(targetId, isRefresh, cancelToken)
  local request = {}
  request.targetId = targetId
  request.isRefresh = isRefresh
  local ret = worldTeamProxy.GetTeamList(request, cancelToken)
  if isRefresh then
    Z.TipsVM.ShowTipsLang(1000625)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshHallList, ret.teamList)
  handleError(ret.errCode)
end
local asyncGetNearTeamList = function(mapId, isRefresh, cancelToken)
  local request = {}
  request.mapId = mapId
  request.isRefresh = isRefresh
  local ret = worldTeamProxy.GetNearTeamList(request, cancelToken)
  if isRefresh then
    Z.TipsVM.ShowTipsLang(1000628)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshNearByList, ret.teamList)
  handleError(ret.errCode)
end
local asyncDealApplyJoin = function(applicantId, isAgree, cancelToken)
  local request = {}
  request.applicantId = applicantId
  request.agree = isAgree
  local ret = worldTeamProxy.DealApplyJoin(request, cancelToken)
  handleError(ret.errCode)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:RemoveApplyList(applicantId)
  Z.RedPointMgr.RefreshClientNodeCount(E.RedType.TeamApplyButton, teamData:GetApplyCount())
end
local asyncDenyAllApllyJoin = function(cancelToken)
  local request = {}
  local ret = worldTeamProxy.DenyAllApplyJoin(request, cancelToken)
  handleError(ret.errCode)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:ClearApply()
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.TeamApplyButton, 0)
end
local asyncLeaderGetApplyList = function(isRefresh, cancelToken)
  local request = {}
  request.isRefresh = isRefresh
  local ret = worldTeamProxy.LeaderGetApplyList(request, cancelToken)
  handleError(ret.errCode)
  if isRefresh then
    Z.TipsVM.ShowTipsLang(1000629)
  end
  local teamRequestVM = Z.VMMgr.GetVM("team_request")
  local applyList = teamRequestVM.GetApplyList(ret.apply)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:RefeshApplyList(applyList)
  Z.EventMgr:Dispatch(Z.ConstValue.Team.RefreshApplyList, applyList, isRefresh)
end
local asyncQuitJoinTeam = function(teamIdList, cancelSource)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:SetLeaveAndApplyTeam(teamIdList)
  local ret = asyncQuitTeam(cancelSource)
  if ret ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= ret then
    return
  end
end
local asyncQuitReplyTeam = function(teamId, cancelSource)
  local teamData = Z.DataMgr.Get("team_data")
  teamData:SetLeaveAndReplyTeam(teamId)
  local ret = asyncQuitTeam(cancelSource)
  if ret ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= ret then
    return
  end
end
local refuseLeaderApply = function(charId, cancelToken)
  local request = {}
  request.charId = charId
  local ret = worldTeamProxy.RefuseLeaderApply(request, cancelToken)
  handleError(ret.errCode)
end
local checkIsInTeam = function()
  local teamData = Z.DataMgr.Get("team_data")
  local teamId = teamData.TeamInfo.baseInfo.teamId
  if teamId and 0 < teamId then
    return true
  end
  return false
end
local getTeamMemData = function()
  local teamData = Z.DataMgr.Get("team_data")
  local members = teamData.TeamInfo.members
  local sortList = {}
  if not members then
    return sortList
  end
  for _, value in pairs(members) do
    sortList[#sortList + 1] = value
  end
  table.sort(sortList, function(a, b)
    if a.enterTime == b.enterTime then
      return a.charId < b.charId
    else
      return a.enterTime < b.enterTime
    end
  end)
  return sortList
end
local getMemDataNotContainSelf = function()
  local charId = Z.ContainerMgr.CharSerialize.charBase.charId
  local sortList = getTeamMemData()
  for index, value in ipairs(sortList) do
    if value.charId == charId then
      table.remove(sortList, index)
      return sortList, index
    end
  end
  return sortList, 0
end
local getTeamMembersNum = function()
  local teamMembers = getTeamMemData()
  if 1 < #teamMembers then
    return true
  end
  return false
end
local getNotMyUnionMemberInTeam = function()
  local teamData = Z.DataMgr.Get("team_data")
  local r = {}
  local unionVM_ = Z.VMMgr.GetVM("union")
  local members = teamData.TeamInfo.members
  for _, value in pairs(members) do
    if not unionVM_:IsUnionMember(value.charId) then
      table.insert(r, value)
    end
  end
  return r
end
local setHallRefreshBtnTime = function()
  local teamData = Z.DataMgr.Get("team_data")
  local refreshNewCd = Z.Global.TeamRefreshNewCD
  teamData:SetTeamSimpleTime(refreshNewCd, "hallTeamListRefresh")
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.HallTeamListRefresh, function()
    teamData:SetTeamSimpleTime(0, "hallTeamListRefresh")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateHallRefreshBtn)
  end, refreshNewCd)
end
local setNearbyRefreshBtnTime = function()
  local teamData = Z.DataMgr.Get("team_data")
  local refreshNewCd = Z.Global.TeamRefreshNewCD
  teamData:SetTeamSimpleTime(refreshNewCd, "nearbyTeamListRefresh")
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.NearbyTeamListRefresh, function()
    teamData:SetTeamSimpleTime(0, "nearbyTeamListRefresh")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateNearByRefreshBtn)
  end, refreshNewCd)
end
local setOneKeyJoinTime = function()
  local teamData = Z.DataMgr.Get("team_data")
  local teamApplyCd = Z.Global.TeamApplyCD
  teamData:SetTeamSimpleTime(teamApplyCd, "oneKeyJoin")
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamOneKeyJoin, function()
    teamData:SetTeamSimpleTime(0, "oneKeyJoin")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateOneKeyJoinBtn)
  end, teamApplyCd)
end
local setTeamApplyCaptainTime = function()
  local teamData = Z.DataMgr.Get("team_data")
  local teamApplyCaptainCd = Z.Global.TeamApplyCaptainCD
  teamData:SetTeamSimpleTime(teamApplyCaptainCd, "applyCaptain")
  Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.TeamApplyCaptain, function()
    teamData:SetTeamSimpleTime(0, "applyCaptain")
    Z.EventMgr:Dispatch(Z.ConstValue.Team.UpdateApplyCaptainBtn)
  end, teamApplyCaptainCd)
end
local setShowHall = function(canShow, cancelToken)
  local request = {}
  request.isShow = canShow
  local ret = worldTeamProxy.SetShowHall(request, cancelToken)
  handleError(ret.errCode)
end
local setLeaderId = function()
  local teamData = Z.DataMgr.Get("team_data")
  local leaderId = teamData.TeamInfo.baseInfo.leaderId
  local lasterLeaderId = teamData:GetLastLeaderId()
  if leaderId == lasterLeaderId then
    return
  end
  if lasterLeaderId == Z.ContainerMgr.CharSerialize.charBase.charId then
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.TeamApplyButton, 0)
  end
  teamData:SetLeaderId(leaderId)
end
local getYouIsLeader = function()
  local teamData = Z.DataMgr.Get("team_data")
  local leaderId = teamData.TeamInfo.baseInfo.leaderId
  if leaderId == Z.ContainerMgr.CharSerialize.charBase.charId then
    return true
  end
  return false
end
local asyncGoToTeamMemWorld = function(charId, token)
  local request = {}
  request.charId = charId
  local ret = worldTeamProxy.GoToTeamMemWorld(request, token)
  handleError(ret.errCode)
end
local asyncTeamLeaderCall = function(token)
  local request = {}
  local ret = worldTeamProxy.TeamLeaderCall(request, token)
  handleError(ret.errCode)
  if ret.errCode == 0 then
    Z.TipsVM.ShowTipsLang(1000600)
  end
end
local asyncTeamMemCallOperator = function(flag, cancelSource)
  local request = {}
  if flag then
    Z.TipsVM.ShowTipsLang(1000608)
    request.callStatus = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Agree")
  else
    Z.TipsVM.ShowTipsLang(1000609)
    request.callStatus = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Refuse")
  end
  local ret = worldTeamProxy.TeamMemCall(request, cancelSource:CreateToken())
  handleError(ret.errCode)
end
local getStringByCharCount = function(str, count, index)
  if str == nil or type(str) ~= "string" then
    return nil
  end
  if count == nil or type(count) ~= "number" then
    return nil
  end
  if count == 0 then
    return ""
  end
  local len = #str
  index = index or 1
  if str == "" or count >= len and index == 1 then
    return str
  end
  local byte
  local i, curCount = 1, 0
  local curIndex = 1
  local startIndex = 0
  local endIndex = 1
  while true do
    if startIndex == 0 then
      startIndex = curIndex == index and i or 0
    end
    byte = string.byte(str, i)
    if 239 < byte then
      i = i + 4
    elseif 223 < byte then
      i = i + 3
    elseif 128 < byte then
      i = i + 2
    else
      i = i + 1
    end
    if startIndex == 0 then
      curIndex = curIndex + 1
    else
      curCount = curCount + 1
    end
    if count == curCount then
      endIndex = i - 1
      break
    end
    if len == i then
      endIndex = i
      break
    end
  end
  return string.sub(str, startIndex, endIndex)
end
local asyncGetTeamInfo = function(token)
  local ret = worldTeamProxy.GetTeamInfo({}, token)
  local teamData = Z.DataMgr.Get("team_data")
  if ret.errCode == 0 then
    local baseInfo = {}
    if ret.baseInfo then
      baseInfo = ret.baseInfo
    end
    teamData:SetTeamBaseInfo(baseInfo)
    local memberData = {}
    if ret.memberData then
      local entityVm = Z.VMMgr.GetVM("entity")
      for _, member in pairs(ret.memberData) do
        local charId = member.charId
        local voiceInfo = ret.memRealTimeVoiceInfos[charId]
        if voiceInfo then
          member.speakState = voiceInfo.speakStatus
          member.micState = voiceInfo.microphoneStatus
        else
          member.speakState = 0
          member.micState = 0
        end
        member.isAi = entityVm.CheckIsAIByEntId(charId)
        memberData[charId] = member
      end
    end
    teamData:SetTeamMembers(memberData)
    if ret.memSocialData then
      for _, socialData in pairs(ret.memSocialData) do
        teamData:SetSocialData(socialData.basicData.charID, socialData)
      end
    end
    if ret.memVoiceId then
      for charId, voiceId in pairs(ret.memVoiceId) do
        teamData:SetMemberVoiceId(charId, voiceId)
      end
    end
    recoverTeamVoice()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.Refresh)
    if ret.teamActivity then
      local teamEntersVM = Z.VMMgr.GetVM("team_enter")
      teamEntersVM.HandleTeamActivity(ret.teamActivity)
    end
  else
    handleError(ret.errCode)
  end
end
local getProfessionIcon = function(professionId)
  if not professionId or professionId == 0 then
    return ""
  end
  local professionConfig = Z.TableMgr.GetTable("ProfessionTableMgr").GetRow(professionId, true)
  if professionConfig then
    return professionConfig.Icon
  end
  return ""
end
local dungeonErrDungeonNotClear = function(dungeonData, names)
  local playerParm = {
    player = {name = ""},
    dungeon = {name = ""}
  }
  if dungeonData.Condition then
    for _, value in pairs(dungeonData.Condition) do
      if value and next(value) and 2 <= #value and value[1] == E.ConditionType.DungeonId then
        local dungeonsCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(value[2])
        if dungeonsCfg == nil then
          return
        end
        local name = dungeonsCfg.Name
        if name then
          playerParm.dungeon.name = Z.RichTextHelper.ApplyStyleTag(name, E.TextStyleTag.AccentGreen)
          break
        end
      end
    end
  end
  local names = table.zconcat(names, ",")
  playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
  Z.TipsVM.ShowTips(1000639, playerParm)
end
local dungeonErrGsNotEnough = function(dungeonData, names)
  local playerParm = {
    player = {name = ""},
    dungeon = {gs = ""}
  }
  if dungeonData.Condition then
    for _, value in pairs(dungeonData.Condition) do
      if value[1] == E.ConditionType.GS then
        local gs = value[2]
        if gs then
          playerParm.dungeon.gs = Z.RichTextHelper.ApplyStyleTag(gs, E.TextStyleTag.AccentGreen)
          break
        end
      end
    end
  end
  local names = table.zconcat(names, ",")
  playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
  Z.TipsVM.ShowTips(1000638, playerParm)
end
local dungeonError = function(names, tipsId)
  local player = {name = ""}
  local names = table.zconcat(names, ",")
  player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
  Z.TipsVM.ShowTips(tipsId, {player = player})
end
local dungeonErrorScore = function(dungeonData, names)
  local playerParm = {
    player = {name = ""},
    dungeon = {name = "", score = ""}
  }
  local names = table.zconcat(names, ",")
  playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
  if dungeonData.Condition then
    for _, value in pairs(dungeonData.Condition) do
      if value and next(value) and 2 <= #value and value[1] == E.ConditionType.DungeonScroe then
        local dungeonsCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(value[2])
        if dungeonsCfg then
          playerParm.dungeon.name = Z.RichTextHelper.ApplyStyleTag(dungeonsCfg.Name, E.TextStyleTag.AccentGreen)
          playerParm.dungeon.score = Z.RichTextHelper.ApplyStyleTag(value[3], E.TextStyleTag.AccentGreen)
          break
        end
      end
    end
  end
  Z.TipsVM.ShowTips(1000640, playerParm)
end
local errFunctionUnlock = function(charIds, dungeonData)
  local playerParm = {
    player = {name = ""}
  }
  local functonId = 0
  if dungeonData.Condition then
    for _, value in pairs(dungeonData.Condition) do
      if value and next(value) and 2 <= #value and value[1] == E.ConditionType.Function then
        functonId = value[2]
        break
      end
    end
  end
  local teamData = Z.DataMgr.Get("team_data")
  local teamMembers = teamData.TeamInfo.members
  if functonId ~= 0 then
    local fucntionTableRow = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(functonId, true)
    if fucntionTableRow then
      local levelErrorNames = {}
      local questErrorNames = {}
      for key, charId in pairs(charIds) do
        local teamMember = teamMembers[charId]
        if teamMember and teamMember.socialData then
          if teamMember.socialData.basicData.level < fucntionTableRow.RoleLevel then
            table.insert(levelErrorNames, teamMember.socialData.basicData.name)
          else
            table.insert(questErrorNames, teamMember.socialData.basicData.name)
          end
        end
      end
      if 0 < #levelErrorNames then
        local names = table.zconcat(levelErrorNames, ",")
        playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
        Z.TipsVM.ShowTips(124005, playerParm)
      elseif 0 < #questErrorNames then
        local names = table.zconcat(questErrorNames, ",")
        playerParm.player.name = Z.RichTextHelper.ApplyStyleTag(names, E.TextStyleTag.AccentGreen)
        Z.TipsVM.ShowTips(124006, playerParm)
      end
    end
  end
end
local teamActivityListResult = function(vRequest)
  local ErrorId = {
    [Z.PbEnum("EErrorCode", "ErrLevelNotEnough")] = 124005,
    [Z.PbEnum("EErrorCode", "ErrQuestNotCompleted")] = 124006,
    [Z.PbEnum("EErrorCode", "ErrGsNotEnough")] = 1000638,
    [Z.PbEnum("EErrorCode", "ErrDungeonNotClear")] = 1000639,
    [Z.PbEnum("EErrorCode", "ErrFunctionUnlock")] = 15001031,
    [Z.PbEnum("EErrorCode", "ErrDungeonScoreError")] = 1000640,
    [Z.PbEnum("EErrorCode", "ErrDungeonPlayerNotEnough")] = 3322,
    [Z.PbEnum("EErrorCode", "ErrDungeonPlayerFull")] = 3323,
    [Z.PbEnum("EErrorCode", "ErrTeamMemInDungeon")] = 15001032,
    [Z.PbEnum("EErrorCode", "ErrCantChangeDungeon")] = 15001032,
    [Z.PbEnum("EErrorCode", "ErrConditionTimerOpen")] = 1000641
  }
  local teamData = Z.DataMgr.Get("team_data")
  local teamMembers = teamData.TeamInfo.members
  local dungeonid = vRequest.result.dungeonId
  local dungeonTableMgr = Z.TableMgr.GetTable("DungeonsTableMgr")
  local dungeonData = dungeonTableMgr.GetRow(dungeonid)
  if dungeonData == nil or vRequest.result.checkResult == nil then
    return
  end
  local errorTab = {}
  for charId, errorId in pairs(vRequest.result.checkResult) do
    if errorId ~= 0 then
      local tipsId = ErrorId[errorId] or 1000641
      if errorTab[tipsId] == nil then
        errorTab[tipsId] = {}
        errorTab[tipsId].tipsId = tipsId
        errorTab[tipsId].charIds = {}
      end
      table.insert(errorTab[tipsId].charIds, charId)
    end
  end
  local tab = table.zvalues(errorTab)
  table.sort(tab, function(a, b)
    if TeamEnterDungeonConditionType[a.tipsId] and TeamEnterDungeonConditionType[b.tipsId] then
      return TeamEnterDungeonConditionType[a.tipsId] < TeamEnterDungeonConditionType[b.tipsId]
    end
    return true
  end)
  if tab[1] then
    local tipsId = tab[1].tipsId
    if 15001031 == tipsId then
      errFunctionUnlock(tab[1].charIds, dungeonData)
    else
      local names = {}
      for index, charId in ipairs(tab[1].charIds) do
        local teamMember = teamMembers[charId]
        if teamMember and teamMember.socialData then
          table.insert(names, teamMember.socialData.basicData.name)
        end
      end
      if tipsId == 1000639 then
        dungeonErrDungeonNotClear(dungeonData, names)
      elseif tipsId == 1000640 then
        dungeonErrorScore(dungeonData, names)
      elseif tipsId == 1000638 then
        dungeonErrGsNotEnough(dungeonData, names)
      elseif tipsId == 3323 or tipsId == 3322 then
        Z.TipsVM.ShowTips(tipsId)
      elseif tipsId == 1000638 then
        dungeonErrGsNotEnough(dungeonData, names)
      else
        dungeonError(names, tipsId)
      end
    end
    return
  end
end
local enterVoiceRoom = function(roomName, member)
  local teamData = Z.DataMgr.Get("team_data")
  teamData.VoiceRoomName = roomName
  Z.CoroUtil.create_coro_xpcall(function()
    worldTeamProxy.SetVoiceId({voiceId = member}, teamData.CancelSource:CreateToken())
    recoverMicState()
  end)()
end
local quitVoiceRoom = function(roomName, member)
  local teamData = Z.DataMgr.Get("team_data")
  teamData.VoiceRoomName = nil
end
local getTeamMemberInfoByCharId = function(charId)
  local teamData = Z.DataMgr.Get("team_data")
  return teamData.TeamInfo.members[charId]
end
local ret = {
  AsyncCreatTeam = asyncCreatTeam,
  AsyncInviteToTeam = asyncInviteToTeam,
  AsyncReplyBeInvitation = asyncReplyBeInvitation,
  AsyncQuitTeam = asyncQuitTeam,
  GetTeamMembersNum = getTeamMembersNum,
  AsyncApplyBeLeader = asyncApplyBeLeader,
  AsyncTransferLeader = asyncTransferLeader,
  AsyncAcceptTransferBeLeader = asyncAcceptTransferBeLeader,
  AsyncTickOut = asyncTickOut,
  AsyncGetTeamList = asyncGetTeamList,
  AsyncGetNearTeamList = asyncGetNearTeamList,
  AsyncApplyJoinTeam = asyncApplyJoinTeam,
  AsyncDealApplyJoin = asyncDealApplyJoin,
  AsyncDenyAllApllyJoin = asyncDenyAllApllyJoin,
  AsyncLeaderGetApplyList = asyncLeaderGetApplyList,
  AsyncQuitJoinTeam = asyncQuitJoinTeam,
  AsyncSetTeamTargetInfo = asyncSetTeamTargetInfo,
  SetTeamApplyTime = setTeamApplyTime,
  SetTeamInviteTime = setTeamInviteTime,
  RefuseLeaderApply = refuseLeaderApply,
  LeaveTeamDialog = leaveTeamDialog,
  CheckIsInTeam = checkIsInTeam,
  GetTeamMemData = getTeamMemData,
  SetHallRefreshBtnTime = setHallRefreshBtnTime,
  SetNearbyRefreshBtnTime = setNearbyRefreshBtnTime,
  SetOneKeyJoinTime = setOneKeyJoinTime,
  AsyncQuitReplyTeam = asyncQuitReplyTeam,
  SetTeamApplyCaptainTime = setTeamApplyCaptainTime,
  SetShowHall = setShowHall,
  SetLeaderId = setLeaderId,
  GetYouIsLeader = getYouIsLeader,
  AsyncGoToTeamMemWorld = asyncGoToTeamMemWorld,
  AsyncTeamLeaderCall = asyncTeamLeaderCall,
  AsyncTeamMemCallOperator = asyncTeamMemCallOperator,
  GetStringByCharCount = getStringByCharCount,
  AsyncGetTeamInfo = asyncGetTeamInfo,
  GetProfessionIcon = getProfessionIcon,
  TeamActivityListResult = teamActivityListResult,
  JoinTeamVoice = joinTeamVoice,
  QuiteTeamVoice = quiteTeamVoice,
  BlockTeamMemberVoice = blockTeamMemberVoice,
  SetMicrophoneStatus = setMicrophoneStatus,
  SetSpeakStatus = setSpeakStatus,
  OpenTeamSpeaker = openTeamSpeaker,
  OpenTeamMic = openTeamMic,
  CloseTeamVoice = closeTeamVoice,
  GetMemDataNotContainSelf = getMemDataNotContainSelf,
  EnterVoiceRoom = enterVoiceRoom,
  QuitVoiceRoom = quitVoiceRoom,
  GetNotMyUnionMemberInTeam = getNotMyUnionMemberInTeam,
  GetTeamMemberInfoByCharId = getTeamMemberInfoByCharId
}
return ret
