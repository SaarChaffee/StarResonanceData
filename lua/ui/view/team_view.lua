local UI = Z.UI
local super = require("ui.ui_subview_base")
local TeamView = class("TeamView", super)
local paths = {
  member_tpl = "ui/prefabs/team/team_member_tips_popup",
  team_icon_check = "ui/atlas/mainui/team/team_icon_check",
  team_icon_branching = "ui/atlas/mainui/team/team_icon_branching",
  team_icon_close = "ui/atlas/mainui/team/team_icon_close",
  team_icon_scene = "ui/atlas/mainui/team/team_icon_no_scene"
}
local keyIconHelper = require("ui.component.mainui.new_key_icon_helper")
local ETeamFunctionType = {
  SendMsg = 1,
  ViewMsg = 2,
  AddFriend = 3,
  TransferLeader = 4,
  PleaseLevelTeam = 5,
  ApplyLeader = 6,
  GoToLine = 7,
  BlockVoice = 8
}
local ETeamCallStatus = {
  ETeamCallStatus_Null = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Null"),
  ETeamCallStatus_Wait = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Wait"),
  ETeamCallStatus_Agree = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Agree"),
  ETeamCallStatus_Refuse = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Refuse")
}
local ETeamVoiceState = {
  MicVoice = 0,
  CloseVoice = 1,
  SpeakerVoice = 2,
  ShieldVoice = 3,
  SpeakingVoice = 4
}
local ETeamVoiceSpeakState = {
  NotSpeak = 0,
  Speaking = 1,
  EndSpeak = 2
}
local MAX_SHOW_NAME_LENGTH = 9

function TeamView:ctor(parent)
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "main/team/main_team_pc_sub" or "main/team/main_team_sub"
  super.ctor(self, "team_window", assetPath, UI.ECacheLv.None, parent)
  self.isOen_ = false
  self.memberAttrWatcher_ = {}
  self.memberList_ = {}
  self.allFunctionContainer_ = {}
  self.allFunction_ = {}
  self.idCardShowList_ = {}
  self.vm = Z.VMMgr.GetVM("team")
  self.entityVm_ = Z.VMMgr.GetVM("entity")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function TeamView:initZWidget()
  self.memberInfo_ = {
    self.uiBinder.cont_member_1,
    self.uiBinder.cont_member_2,
    self.uiBinder.cont_member_3
  }
  self.contMembers_ = {}
  self.btn_voice_ = self.uiBinder.btn_voice
  self.voiceBtnIcon_ = self.uiBinder.img_voice
  self.voiceNode_ = self.uiBinder.node_voice
  self.node_head = self.uiBinder.node_head
  self.btn_convene_ = self.uiBinder.btn_convene
  self.btn_team_ = self.uiBinder.btn_team
  self.nodeRed_ = self.uiBinder.node_red
  self.btn_creat_ = self.uiBinder.btn_creat
  self.img_call_ = self.uiBinder.img_call
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.voiceTogNode_ = {}
  self.voiceTogNode_[ETeamVoiceState.CloseVoice] = self.uiBinder.tog_mute
  self.voiceTogNode_[ETeamVoiceState.SpeakerVoice] = self.uiBinder.tog_speaker
  self.voiceTogNode_[ETeamVoiceState.MicVoice] = self.uiBinder.tog_mic
  self.voicePress_ = self.uiBinder.node_voice_presscheck
  self.node_icon_key_ = self.uiBinder.node_icon_key
  self.closeMatchingBtn_ = self.uiBinder.btn_close_match
  self.matchingImg_ = self.uiBinder.img_matching
  self.targetBtn_ = self.uiBinder.btn_target
  self.targetSetImg_ = self.uiBinder.img_set
  self.lab_target_ = self.uiBinder.lab_target
end

function TeamView:initData()
  self.voiceStatePath_ = {}
  self.voiceStatePath_[ETeamVoiceState.CloseVoice] = self.prefab_cache_:GetString("close_voice")
  self.voiceStatePath_[ETeamVoiceState.SpeakerVoice] = self.prefab_cache_:GetString("speaker_voice")
  self.voiceStatePath_[ETeamVoiceState.MicVoice] = self.prefab_cache_:GetString("mic_voice")
  self.voiceStatePath_[ETeamVoiceState.ShieldVoice] = self.prefab_cache_:GetString("shield_voice")
  self.voiceStatePath_[ETeamVoiceState.SpeakingVoice] = self.prefab_cache_:GetString("speaking_voice")
end

function TeamView:initBtns()
  self:AddAsyncClick(self.btn_creat_, function()
    local members = self.teamData_.TeamInfo.members
    if table.zcount(members) == 0 then
      self.vm.AsyncCreatTeam(E.TeamTargetId.Costume, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.btn_convene_, function()
    local members = self.teamData_.TeamInfo.members
    if table.zcount(members) > 0 then
      self.vm.AsyncTeamLeaderCall(self.cancelSource:CreateToken())
    end
  end)
  self:AddClick(self.targetBtn_, function()
    local teamTargetVM = Z.VMMgr.GetVM("team_target")
    teamTargetVM.OpenTeamTargetView()
  end)
  self:AddClick(self.btn_team_, function()
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.TeamFuncId.Team)
  end)
  self:AddAsyncClick(self.closeMatchingBtn_, function()
    self.matchVm_.AsyncCancelMatchNew(E.MatchType.Team, true, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.btn_voice_, function(isOn)
    local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
    local member = self.teamData_.TeamInfo.members[curCharId]
    if member then
      self.uiBinder.Ref:SetVisible(self.voiceNode_, true)
      self.voicePress_:StartCheck()
    end
  end)
  self:AddClick(self.voicePress_.ContainGoEvent, function(isCheck)
    if not isCheck then
      self.uiBinder.Ref:SetVisible(self.voiceNode_, isCheck)
      self.voicePress_:StopCheck()
    end
  end)
  self:AddClick(self.voiceTogNode_[ETeamVoiceState.CloseVoice], function(isOn)
    if isOn then
      self.vm.CloseTeamVoice()
      self:setVoiceIcon(ETeamVoiceState.CloseVoice)
      self.vm.SetMicrophoneStatus(ETeamVoiceState.CloseVoice)
    end
  end)
  self:AddClick(self.voiceTogNode_[ETeamVoiceState.SpeakerVoice], function(isOn)
    if isOn then
      local isOpen = self.vm.OpenTeamSpeaker()
      if isOpen then
        self:setVoiceIcon(ETeamVoiceState.SpeakerVoice)
        self.vm.SetMicrophoneStatus(ETeamVoiceState.SpeakerVoice)
      else
        self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
      end
    end
  end)
  self:AddClick(self.voiceTogNode_[ETeamVoiceState.MicVoice], function(isOn)
    if isOn then
      local isOpen = self.vm.OpenTeamMic()
      if isOpen then
        self:setVoiceIcon(ETeamVoiceState.MicVoice)
        self.vm.SetMicrophoneStatus(ETeamVoiceState.MicVoice)
      else
        self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
      end
    end
  end)
end

function TeamView:initUI()
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.OpenTeamTipsView()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TeamApplyMain, self, self.nodeRed_.transform)
  keyIconHelper.InitKeyIcon(self, self.node_icon_key_, 109)
end

function TeamView:OnActive()
  self:initZWidget()
  self:initData()
  self:initBtns()
  self:initUI()
  self:BindEvents()
end

function TeamView:OnRefresh()
  self:refreshTeam()
end

function TeamView:OnDeActive()
  self.isOen_ = false
  Z.RedPointMgr.RemoveNodeItem(E.RedType.TeamApplyMain)
end

function TeamView:setVoiceIcon(state)
  if not state then
    return
  end
  self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
  self.voiceBtnIcon_:SetImage(self.voiceStatePath_[state])
end

function TeamView:refreshMic()
  local members = self.teamData_.TeamInfo.members
  for charId, member in pairs(members) do
    if member.speakState == ETeamVoiceSpeakState.Speaking then
      self:refreshMicState(charId, ETeamVoiceState.SpeakerVoice)
    else
      self:refreshMicState(charId, member.micState)
    end
  end
end

function TeamView:refreshMicByCharId(charId)
  local members = self.teamData_.TeamInfo.members
  if members[charId] then
    if members[charId].speakState == ETeamVoiceSpeakState.Speaking then
      self:refreshMicState(charId, ETeamVoiceState.SpeakerVoice)
    else
      self:refreshMicState(charId, members[charId].micState)
    end
  end
end

function TeamView:refreshMicState(charId, state)
  if not state then
    return
  end
  local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  if charId ~= curCharId then
    local member = self.contMembers_[charId]
    if member then
      local isAi = self.entityVm_.CheckIsAIByEntId(charId)
      member.Ref:SetVisible(member.img_chat, not isAi)
      if state == ETeamVoiceState.ShieldVoice then
        member.img_chat:SetImage(self.voiceStatePath_[state])
      else
        local isBlock = self.teamData_:GetBlockVoiceState(charId)
        if not isBlock then
          member.img_chat:SetImage(self.voiceStatePath_[state])
        end
      end
    end
  else
    self:setVoiceIcon(state)
  end
end

function TeamView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.refreshTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshSetting, self.refreshSetting, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateMemberData, self.updateMemberData, self)
  Z.EventMgr:Add(Z.ConstValue.Team.UpdateApplyCaptainBtn, self.updateApplyCaptainBtn, self)
  Z.EventMgr:Add(Z.ConstValue.Team.QuitAndApplyTeam, self.quitAndApplyTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneGuid, self.setTeamInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneId, self.setTeamInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeCallStatus, self.changeCallStatus, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshTeamMicState, self.refreshMicState, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshTeamSpeakState, self.refreshMic, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshTeamVoiceState, self.setVoiceIcon, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshMemberMicState, self.refreshMicByCharId, self)
  Z.EventMgr:Add(Z.ConstValue.Team.MatchWaitTimeOut, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshMatchingStatus, self.setCompActive, self)
end

function TeamView:UnBindTeamMemberAttrWatchers()
  for i = 1, #self.memberAttrWatcher_ do
    self:UnBindEntityLuaAttrWatcher(self.memberAttrWatcher_[i])
  end
  self.memberAttrWatcher_ = {}
end

function TeamView:quitAndApplyTeam(teamList)
  Z.CoroUtil.create_coro_xpcall(function()
    self.vm.AsyncQuitJoinTeam(teamList, self.cancelSource)
  end)()
end

function TeamView:updateApplyCaptainBtn()
  local teamData = Z.DataMgr.Get("team_data")
  local isApply = teamData:GetTeamSimpleTime("applyCaptain")
  self.uiBinder.node_tips.node_apply_captain.tog.interactable = isApply == 0
end

function TeamView:updateMemberData(data)
  local data = data or {}
  local charId = data.charId
  local isForce = data.isForce
  local ent
  if charId and not isForce then
    ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
  end
  local members = self.teamData_.TeamInfo.members
  if not members then
    return
  end
  for k, v in ipairs(self.memberList_) do
    if v.charId == charId then
      local comp = self.memberInfo_[k]
      if isForce then
        local memberData = members[v.charId]
        if memberData and memberData.socialData then
          comp.slider.maxValue = memberData.socialData.userAttrData.maxHp
          comp.slider.value = memberData.socialData.userAttrData.hp
        end
      elseif ent then
        comp.slider.maxValue = ent:GetLuaAttr(Z.PbAttrEnum("AttrMaxHp")).Value
        comp.slider.value = ent:GetLuaAttr(Z.PbAttrEnum("AttrHp")).Value
      end
    end
  end
end

function TeamView:refreshTeam()
  self:UnBindTeamMemberAttrWatchers()
  self:setTeamInfo()
  self:refreshMic()
  self:setTeamSetting()
  self:setCompActive()
end

function TeamView:setTeamInfo()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  local members = self.teamData_.TeamInfo.members
  local isLeader = false
  local selfInfo
  local isShow = false
  if members then
    selfInfo = members[curCharId]
    if selfInfo then
      self:setVoiceIcon(selfInfo.micState)
    end
  end
  local memberCount = table.zcount(members)
  if 0 < memberCount then
    local leaderId = teamInfo.leaderId
    if curCharId == leaderId then
      isLeader = true
      for charId, member in pairs(members) do
        if member.socialData and not member.isAi and selfInfo and charId ~= curCharId and member.socialData.basicData.sceneGuid ~= selfInfo.socialData.basicData.sceneGuid and member.socialData.basicData.sceneId == selfInfo.socialData.basicData.sceneId then
          isShow = true
          break
        end
      end
    end
  end
  self.uiBinder.Ref:SetVisible(self.btn_convene_, isShow)
  self.uiBinder.Ref:SetVisible(self.btn_creat_, memberCount == 0)
  self.uiBinder.Ref:SetVisible(self.btn_voice_, 0 < memberCount)
  self.uiBinder.Ref:SetVisible(self.targetBtn_, isLeader)
  self:changeCallStatus()
  self.contMembers_ = {}
  for k, v in ipairs(self.memberInfo_) do
    local display = self.memberList_[k] and true or false
    if display then
      local member = self.memberList_[k]
      if member and member.socialData then
        self.contMembers_[member.charId] = v
        local isCaptain = member.charId == teamInfo.leaderId
        v.Ref:SetVisible(v.img_leader, isCaptain)
        v.lab_name.text = member.socialData.basicData.name
        local professionId = 0
        if member.isAi then
          local botAiId = member.socialData.basicData.botAiId
          local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
          if botAITableRow then
            professionId = botAITableRow.Duty
          end
        else
          local professionData = member.socialData.professionData
          if professionData then
            professionId = professionData.professionId
          end
          v.slider.maxValue = member.socialData.userAttrData.maxHp
          v.slider.value = member.socialData.userAttrData.hp
        end
        if professionId ~= 0 then
          local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
          if professionSystemTableRow then
            v.img_icon_type:SetImage(professionSystemTableRow.Icon)
          end
        end
      end
      self:AddClick(v.btn_selected, function()
        if not self.entityVm_.CheckIsAIByEntId(member.charId) then
          self:setTeamPop(member.charId)
        end
      end)
    end
  end
end

function TeamView:setCompActive()
  if not self.vm.CheckIsInTeam() then
    return
  end
  local matchType = self.matchData_:GetMatchType()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local matching = teamInfo.matching and matchType == E.MatchType.Team
  self.uiBinder.Ref:SetVisible(self.closeMatchingBtn_, matching)
  self.uiBinder.Ref:SetVisible(self.matchingImg_, matching)
  self.uiBinder.Ref:SetVisible(self.targetSetImg_, not matching)
end

function TeamView:setTeamSetting()
  if not self.vm.CheckIsInTeam() then
    return
  end
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local teamTargetCfg = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(teamInfo.targetId, true)
  if not teamTargetCfg then
    return
  end
  local param = {
    pt = {
      target = teamTargetCfg.Name
    }
  }
  self.lab_target_.text = Lang("teamTargetText", param)
end

function TeamView:refreshSetting()
  self:setTeamSetting()
  self:setTeamInfo()
end

function TeamView:changeCallStatus()
  local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  local members = self.teamData_.TeamInfo.members
  local selfInfo
  if members then
    selfInfo = members[curCharId]
  end
  local memberTbl = self.vm.GetTeamMemData()
  self.memberList_ = {}
  local memberPosList = {}
  for k, v in ipairs(memberTbl) do
    if v.charId ~= curCharId then
      table.insert(self.memberList_, v)
    end
    memberPosList[v.charId] = k
  end
  for k, v in ipairs(self.memberInfo_) do
    local display = self.memberList_[k] and true or false
    v.Ref.UIComp:SetVisible(display)
    v.Ref:SetVisible(v.btn_selected, display)
    if display then
      v.lab_num.text = memberPosList[self.memberList_[k].charId] or ""
      local member = self.memberList_[k]
      if member.isAi then
        v.Ref:SetVisible(v.img_await, false)
        v.Ref:SetVisible(v.img_accept, false)
      else
        local isWait = member.callStatus == ETeamCallStatus.ETeamCallStatus_Wait
        v.Ref:SetVisible(v.img_await, isWait)
        if not isWait then
          if selfInfo and selfInfo.socialData and member.socialData then
            local iconPath
            if selfInfo.socialData.basicData.sceneGuid ~= member.socialData.basicData.sceneGuid then
              iconPath = paths.team_icon_branching
            end
            if selfInfo.socialData.basicData.sceneId ~= member.socialData.basicData.sceneId then
              iconPath = paths.team_icon_scene
            end
            if member.callStatus == ETeamCallStatus.ETeamCallStatus_Refuse then
              iconPath = paths.team_icon_close
            end
            if member.callStatus == ETeamCallStatus.ETeamCallStatus_Agree then
              iconPath = paths.team_icon_check
            end
            if iconPath then
              v.Ref:SetVisible(v.img_accept, true)
              v.img_accept:SetImage(iconPath)
            else
              v.Ref:SetVisible(v.img_accept, false)
            end
          end
        else
          v.Ref:SetVisible(v.img_accept, false)
        end
      end
    end
  end
end

function TeamView:setTeamPop(memberId)
  local node_tips = self.uiBinder.node_tips
  self.allFunctionContainer_[ETeamFunctionType.SendMsg] = node_tips.node_send_message
  self.allFunctionContainer_[ETeamFunctionType.ViewMsg] = node_tips.node_view_message
  self.allFunctionContainer_[ETeamFunctionType.AddFriend] = node_tips.node_add_friend
  self.allFunctionContainer_[ETeamFunctionType.TransferLeader] = node_tips.node_transfer_captain
  self.allFunctionContainer_[ETeamFunctionType.PleaseLevelTeam] = node_tips.node_leave_team
  self.allFunctionContainer_[ETeamFunctionType.ApplyLeader] = node_tips.node_apply_captain
  self.allFunctionContainer_[ETeamFunctionType.GoToLine] = node_tips.node_go_line
  self.allFunctionContainer_[ETeamFunctionType.BlockVoice] = node_tips.node_block_voice
  local isBlock = self.teamData_:GetBlockVoiceState(memberId)
  if isBlock then
    self.allFunctionContainer_[ETeamFunctionType.BlockVoice].lab_name.text = Lang("BeginVoice")
  else
    self.allFunctionContainer_[ETeamFunctionType.BlockVoice].lab_name.text = Lang("BlockVoice")
  end
  for eTeamFunctionType, container in pairs(self.allFunctionContainer_) do
    container.tog.isOn = false
    self:AddAsyncClick(container.tog, function(isOn)
      if isOn then
        node_tips.Ref.UIComp:SetVisible(false)
        node_tips.presscheck:StopCheck()
        self.allFunction_[eTeamFunctionType]()
      end
    end)
  end
  self:AddClick(node_tips.presscheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      node_tips.presscheck:StopCheck()
      node_tips.Ref.UIComp:SetVisible(false)
    end
  end)
  self.allFunction_[ETeamFunctionType.SendMsg] = function()
    Z.VMMgr.GetVM("friends_main").OpenPrivateChat(memberId)
  end
  self.allFunction_[ETeamFunctionType.ViewMsg] = function()
  end
  self.allFunction_[ETeamFunctionType.AddFriend] = function()
  end
  self.allFunction_[ETeamFunctionType.TransferLeader] = function()
    self.vm.AsyncTransferLeader(memberId, self.cancelSource:CreateToken())
  end
  self.allFunction_[ETeamFunctionType.PleaseLevelTeam] = function()
    self.vm.AsyncTickOut(memberId, self.cancelSource:CreateToken())
  end
  self.allFunction_[ETeamFunctionType.ApplyLeader] = function()
    self.vm.AsyncApplyBeLeader(self.cancelSource:CreateToken())
  end
  self.allFunction_[ETeamFunctionType.GoToLine] = function()
    self.vm.AsyncGoToTeamMemWorld(memberId, self.cancelSource:CreateToken())
  end
  self.allFunction_[ETeamFunctionType.BlockVoice] = function()
    self.vm.BlockTeamMemberVoice(memberId, not isBlock)
  end
  self:updateApplyCaptainBtn(node_tips)
  if memberId then
    local leaderId = self.teamData_.TeamInfo.baseInfo.leaderId
    local selectIsLeader = memberId == leaderId
    local selfCharId = Z.ContainerMgr.CharSerialize.charBase.charId
    local selfIsLeader = leaderId == selfCharId
    local members = self.teamData_.TeamInfo.members
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    node_tips.node_view_message.Ref.UIComp:SetVisible(false)
    node_tips.node_add_friend.Ref.UIComp:SetVisible(false)
    node_tips.node_transfer_captain.Ref.UIComp:SetVisible(not selectIsLeader and selfIsLeader)
    node_tips.node_leave_team.Ref.UIComp:SetVisible(not selectIsLeader and selfIsLeader and dungeonId == 0)
    node_tips.node_apply_captain.Ref.UIComp:SetVisible(selectIsLeader)
    if members and members[selfCharId] and members[memberId] then
      local selfSocialData = members[selfCharId].socialData
      local memberSocialData = members[memberId].socialData
      if selfSocialData and memberSocialData then
        local isShow = selfSocialData.basicData.sceneId == memberSocialData.basicData.sceneId and selfSocialData.basicData.sceneGuid ~= memberSocialData.basicData.sceneGuid
        node_tips.node_go_line.Ref.UIComp:SetVisible(isShow)
      end
    end
    node_tips.presscheck:StartCheck()
    node_tips.Ref.UIComp:SetVisible(true)
  end
end

return TeamView
