local UI = Z.UI
local super = require("ui.ui_subview_base")
local TeamView = class("TeamView", super)
local deadStateId = Z.PbEnum("EActorState", "ActorStateDead")
local entChar = Z.PbEnum("EEntityType", "EntChar")
local paths = {
  member_tpl = "ui/prefabs/team/team_member_tips_popup",
  team_icon_check = "ui/atlas/mainui/team/team_icon_check",
  team_icon_branching = "ui/atlas/mainui/team/team_icon_branching",
  team_icon_close = "ui/atlas/mainui/team/team_icon_close",
  team_icon_scene = "ui/atlas/mainui/team/team_icon_no_scene"
}
local inputKeyDescComp = require("input.input_key_desc_comp")
local ETeamFunctionType = {
  SendMsg = 1,
  ViewMsg = 2,
  AddFriend = 3,
  TransferLeader = 4,
  PleaseLevelTeam = 5,
  ApplyLeader = 6,
  GoToLine = 7,
  BlockVoice = 8,
  ReportVoice = 9,
  Convene = 10
}
local ETeamCallStatus = {
  ETeamCallStatus_Null = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Null"),
  ETeamCallStatus_Wait = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Wait"),
  ETeamCallStatus_Agree = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Agree"),
  ETeamCallStatus_Refuse = Z.PbEnum("ETeamCallStatus", "ETeamCallStatus_Refuse")
}

function TeamView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "team_window", "main/team/main_team_sub", UI.ECacheLv.None, true)
  self.memberInfoList_ = {}
  self.allFunctionContainer_ = {}
  self.allFunction_ = {}
  self.idCardShowList_ = {}
  self.memberHpAttrWatcher_ = {}
  self.memberDeadAttrWatcher_ = {}
  self.memberBuffAttrWatcher_ = {}
  self.vm = Z.VMMgr.GetVM("team")
  self.entityVm_ = Z.VMMgr.GetVM("entity")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.talentSkillVm_ = Z.VMMgr.GetVM("talent_skill")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.settingKeyVM_ = Z.VMMgr.GetVM("setting_key")
  self.dungeonPrepareVm_ = Z.VMMgr.GetVM("dungeon_prepare")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendData_ = Z.DataMgr.Get("friend_main_data")
  self.buffVm_ = Z.VMMgr.GetVM("buff")
  self.funcVm_ = Z.VMMgr.GetVM("gotofunc")
  self.fighterBtnsVm_ = Z.VMMgr.GetVM("fighterbtns")
  
  function self.onInputAction_(inputActionEventData)
    self:switchVoiceState()
  end
  
  self.inputKeyDescComp1_ = inputKeyDescComp.new()
  self.inputKeyDescComp2_ = inputKeyDescComp.new()
end

function TeamView:initZWidget()
  self.memberInfo_ = {}
  for i = 1, 5 do
    self.memberInfo_[i] = self.uiBinder["cont_member_" .. i]
  end
  self.memberNode20_ = self.uiBinder.layout_20member
  self.memberInfo20_ = {}
  if Z.IsPCUI then
    for i = 1, 20 do
      self.memberInfo20_[i] = self.memberNode20_["group_member_" .. i]
    end
  else
    self.tog12_ = self.memberNode20_.tog_12
    self.tog34_ = self.memberNode20_.tog_34
    self.tog12_.isOn = true
    for i = 1, 10 do
      self.memberInfo20_[i] = self.memberNode20_["group_20member_" .. i]
    end
  end
  self.contMembers_ = {}
  self.btn_voice_ = self.uiBinder.btn_voice
  self.voiceBtnIcon_ = self.uiBinder.img_voice
  self.voiceNode_ = self.uiBinder.node_voice
  self.btn_convene_ = self.uiBinder.btn_convene
  self.btn_team_ = self.uiBinder.btn_team
  self.nodeRed_ = self.uiBinder.node_red
  self.btn_create_ = self.uiBinder.btn_create
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.voiceTogNode_ = {}
  self.voiceTogNode_[E.ETeamVoiceState.CloseVoice] = self.uiBinder.tog_mute
  self.voiceTogNode_[E.ETeamVoiceState.SpeakerVoice] = self.uiBinder.tog_speaker
  self.voiceTogNode_[E.ETeamVoiceState.MicVoice] = self.uiBinder.tog_mic
  self.voicePress_ = self.uiBinder.node_voice_presscheck
  self.closeMatchingBtn_ = self.uiBinder.btn_close_match
  self.matchingImg_ = self.uiBinder.img_matching
  self.targetBtn_ = self.uiBinder.btn_target
  self.targetSetImg_ = self.uiBinder.img_set
  self.lab_target_ = self.uiBinder.lab_target
  self.setoutNode_ = self.uiBinder.node_setout
  self.memberNode5_ = self.uiBinder.layout_member
end

function TeamView:initData()
  self.voiceStatePath_ = {}
  self.conveneTimer_ = {}
  self.voiceStatePath_[E.ETeamVoiceState.CloseVoice] = self.prefab_cache_:GetString("close_voice")
  self.voiceStatePath_[E.ETeamVoiceState.SpeakerVoice] = self.prefab_cache_:GetString("speaker_voice")
  self.voiceStatePath_[E.ETeamVoiceState.MicVoice] = self.prefab_cache_:GetString("mic_voice")
  self.voiceStatePath_[E.ETeamVoiceState.ShieldVoice] = self.prefab_cache_:GetString("shield_voice")
  self.voiceStatePath_[E.ETeamVoiceState.SpeakingVoice] = self.prefab_cache_:GetString("speaking_voice")
  self.teamMaxMemberType_ = E.ETeamMemberType.Five
  self.curVoiceState_ = nil
  self.selectedTogIs12_ = true
  self.buffInfo_ = {}
end

function TeamView:initBtns()
  if not Z.IsPCUI then
    self:AddClick(self.tog12_, function(isOn)
      if Z.IsPCUI or self.teamMaxMemberType_ ~= E.ETeamMemberType.Twenty then
        return
      end
      if isOn then
        self.selectedTogIs12_ = true
        self:refreshTeam()
      end
    end)
    self:AddClick(self.tog34_, function(isOn)
      if Z.IsPCUI or self.teamMaxMemberType_ ~= E.ETeamMemberType.Twenty then
        return
      end
      if isOn then
        self.selectedTogIs12_ = false
        self:refreshTeam()
      end
    end)
    self:AddAsyncClick(self.closeMatchingBtn_, function()
      self.matchVm_.AsyncCancelMatch()
    end)
    self:AddClick(self.targetBtn_, function()
      local teamTargetVM = Z.VMMgr.GetVM("team_target")
      teamTargetVM.OpenTeamTargetView()
    end)
    self:AddClick(self.btn_team_, function()
      local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
      gotoFuncVM.GoToFunc(E.TeamFuncId.Team)
    end)
    self:AddAsyncClick(self.btn_create_, function()
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
    self:AddClick(self.voiceTogNode_[E.ETeamVoiceState.CloseVoice], function(isOn)
      if isOn then
        if self.curVoiceState_ ~= E.ETeamVoiceState.CloseVoice then
          self.vm.CloseTeamVoice()
          self.vm.SetMicrophoneStatus(E.ETeamVoiceState.CloseVoice)
        end
        self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
      end
    end)
    self:AddClick(self.voiceTogNode_[E.ETeamVoiceState.SpeakerVoice], function(isOn)
      if isOn then
        if self.curVoiceState_ ~= E.ETeamVoiceState.SpeakerVoice then
          local isOpen = self.vm.OpenTeamSpeaker()
          if isOpen == false and self.voiceTogNode_[self.curVoiceState_] then
            self.voiceTogNode_[self.curVoiceState_].isOn = true
          end
        end
        self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
      end
    end)
    self:AddClick(self.voiceTogNode_[E.ETeamVoiceState.MicVoice], function(isOn)
      if isOn then
        if self.curVoiceState_ ~= E.ETeamVoiceState.MicVoice then
          local isOpen = self.vm.OpenTeamMic()
          if isOpen == false and self.voiceTogNode_[self.curVoiceState_] then
            self.voiceTogNode_[self.curVoiceState_].isOn = true
          end
        end
        self.uiBinder.Ref:SetVisible(self.voiceNode_, false)
      end
    end)
  end
  self:AddAsyncClick(self.setoutNode_.btn_setout, function()
    if self.teamData_.IsDungeonPrepareIng then
      Z.TipsVM.ShowTips(1004114, {
        time = {
          cd = self.diffTime_
        }
      })
      return
    end
    if self.isInBattle_ then
      Z.TipsVM.ShowTips(1004115)
      return
    end
    local ret = self.dungeonPrepareVm_.AsyncLeaderReadyCheck(self.cancelSource:CreateToken())
    if ret == 0 then
      self:setPrepareInfo()
      self:setMemberPrepareState()
    end
  end)
  self:AddClick(self.uiBinder.btn_punctuate, function()
    local viewConfigKey = "main_copy_punctuate"
    if Z.UIMgr:IsActive(viewConfigKey) then
      Z.UIMgr:CloseView(viewConfigKey)
    else
      Z.UIMgr:OpenView(viewConfigKey)
    end
  end)
end

function TeamView:endDungeonPrepare()
  self:setMemberPrepareState()
  self:refreshSetoutNode()
end

function TeamView:setPrepareInfo()
  self:setMemberPrepareState()
  if self.prepareTime_ then
    self.timerMgr:StopTimer(self.prepareTime_)
    self.prepareTime_ = nil
  end
  if not self.teamData_.IsDungeonPrepareIng then
    return
  end
  local endTime = math.floor(self.teamData_.DungeonPrepareBeginTime / 1000) + Z.Global.DungeonPrepareTime
  self.diffTime_ = Z.TimeTools.DiffTime(endTime, math.floor(Z.ServerTime:GetServerTime() / 1000)) + Z.Global.DungeonPrepareCD
  local time = Z.Global.DungeonPrepareCD + Z.Global.DungeonPrepareTime
  self.setoutNode_.img_setout.fillAmount = 1
  self:refreshSetoutNode()
  self.prepareTime_ = self.timerMgr:StartTimer(function()
    self.diffTime_ = self.diffTime_ - 1
    self.setoutNode_.img_setout.fillAmount = 1 / time * self.diffTime_
  end, 1, self.diffTime_ + Z.Global.DungeonPrepareCD, nil, function()
    self:refreshSetoutNode()
  end)
end

function TeamView:setMemberPrepareStateByInfo(memberItem, memberInfo)
  local leaderCharId = self.teamData_.TeamInfo.baseInfo.leaderId
  if memberInfo.isAi then
    memberItem.Ref:SetVisible(memberItem.img_await, false)
    memberItem.Ref:SetVisible(memberItem.img_accept, false)
  elseif leaderCharId == memberInfo.charId then
    memberItem.img_accept:SetImage(paths.team_icon_check)
    memberItem.Ref:SetVisible(memberItem.img_accept, true)
  else
    local prepareCheckInfo = self.teamData_.DungeonPrepareCheckInfo[memberInfo.charId]
    local isWait = prepareCheckInfo == nil
    memberItem.Ref:SetVisible(memberItem.img_await, isWait)
    if prepareCheckInfo then
      local isReady = prepareCheckInfo.isReady
      local iconPath
      if isReady then
        iconPath = paths.team_icon_check
      else
        iconPath = paths.team_icon_close
      end
      memberItem.img_accept:SetImage(iconPath)
      memberItem.Ref:SetVisible(memberItem.img_accept, true)
    else
      memberItem.Ref:SetVisible(memberItem.img_accept, false)
    end
  end
end

function TeamView:setMemberPrepareState()
  if self.teamMaxMemberType_ == E.ETeamMemberType.Five then
    for k, v in ipairs(self.memberInfo_) do
      local display = self.memberInfoList_[k] and true or false
      v.Ref:SetVisible(v.img_accept, false)
      v.Ref:SetVisible(v.img_await, false)
      if display and self.teamData_.IsDungeonPrepareIng then
        self:setMemberPrepareStateByInfo(v, self.memberInfoList_[k])
      end
    end
  else
    for index, v in ipairs(self.memberInfo20_) do
      local memberInfo = self:getMemberInfoByIndex(index)
      v.Ref:SetVisible(v.img_accept, false)
      v.Ref:SetVisible(v.img_await, false)
      if memberInfo and self.teamData_.IsDungeonPrepareIng then
        self:setMemberPrepareStateByInfo(v, memberInfo)
      end
    end
  end
end

function TeamView:switchVoiceState()
  if not self.vm.CheckIsInTeam() then
    return
  end
  if self.curVoiceState_ == nil or self.curVoiceState_ == E.ETeamVoiceState.MicVoice then
    self.vm.OpenTeamSpeaker()
  elseif self.curVoiceState_ == E.ETeamVoiceState.SpeakerVoice then
    self.vm.CloseTeamVoice()
    self.vm.SetMicrophoneStatus(self.curVoiceState_)
  elseif self.curVoiceState_ == E.ETeamVoiceState.CloseVoice then
    local isOpen = self.vm.OpenTeamMic()
    if isOpen then
      self.vm.SetMicrophoneStatus(self.curVoiceState_)
    end
  end
end

function TeamView:initUI()
  local teamTipsVM = Z.VMMgr.GetVM("team_tips")
  teamTipsVM.OpenTeamTipsView()
  if Z.IsPCUI then
    self.inputKeyDescComp1_:Init(132, self.uiBinder.com_icon_key_voice)
    self.inputKeyDescComp2_:Init(132, self.uiBinder.com_icon_key_twenty)
  end
  if not Z.IsPCUI then
    Z.RedPointMgr.LoadRedDotItem(E.RedType.TeamApplyMain, self, self.nodeRed_.transform)
  end
end

function TeamView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
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
  self.inputKeyDescComp1_:UnInit()
  self.inputKeyDescComp2_:UnInit()
  if not Z.IsPCUI then
    Z.RedPointMgr.RemoveNodeItem(E.RedType.TeamApplyMain)
  end
  for index, value in pairs(self.conveneTimer_) do
    self.timerMgr:StopTimer(value)
  end
  self:unBindTeamMemberAttrWatchers()
  self.conveneTimer_ = {}
end

function TeamView:setVoiceIcon(state)
  if not state then
    return
  end
  if Z.IsPCUI then
    local str = ""
    if state == nil or state == E.ETeamVoiceState.MicVoice then
      str = Lang("OpenMic")
    elseif state == E.ETeamVoiceState.SpeakerVoice then
      str = Lang("OpenVoice")
    elseif state == E.ETeamVoiceState.CloseVoice then
      str = Lang("CloseVoice")
    elseif state == E.ETeamVoiceState.SpeakingVoice then
      str = Lang("Speaking")
    end
    self.uiBinder.lab_state_desc.text = str
    self.uiBinder.lab_state_desc_twenty.text = str
    self.uiBinder.img_voice_twenty:SetImage(self.voiceStatePath_[state])
  end
  self.voiceBtnIcon_:SetImage(self.voiceStatePath_[state])
  self.curVoiceState_ = state
  if self.voiceTogNode_[self.curVoiceState_] then
    self.voiceTogNode_[self.curVoiceState_].isOn = true
  end
end

function TeamView:refreshMic()
  local members = self.teamData_.TeamInfo.members
  for charId, member in pairs(members) do
    if member.speakState == E.ETeamVoiceSpeakState.Speaking then
      self:refreshMicState(charId, E.ETeamVoiceState.SpeakingVoice)
    else
      self:refreshMicState(charId, member.micState or E.ETeamVoiceState.SpeakerVoice)
    end
  end
end

function TeamView:refreshMicByCharId(charId)
  local members = self.teamData_.TeamInfo.members
  if members[charId] then
    if members[charId].speakState == E.ETeamVoiceSpeakState.Speaking then
      self:refreshMicState(charId, E.ETeamVoiceState.SpeakingVoice)
    else
      self:refreshMicState(charId, members[charId].micState or E.ETeamVoiceState.SpeakerVoice)
    end
  end
end

function TeamView:refreshMicState(charId, state)
  if not state then
    return
  end
  local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  local member = self.contMembers_[charId]
  if member then
    local isAi = self.entityVm_.CheckIsAIByEntId(charId)
    member.Ref:SetVisible(member.img_chat, not isAi)
    if state == E.ETeamVoiceState.ShieldVoice then
      member.img_chat:SetImage(self.voiceStatePath_[state])
    else
      local isBlock = self.teamData_:GetBlockVoiceState(charId)
      if not isBlock then
        member.img_chat:SetImage(self.voiceStatePath_[state])
      end
    end
  end
  if charId == curCharId then
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
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.OnLineState, self.memberOnLineChange, self)
  Z.EventMgr:Add(Z.ConstValue.Team.MemberInfoChange, self.memberInfoChange, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshPrepareMemberInfo, self.setMemberPrepareState, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshPrepareState, self.setPrepareInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Team.EndDungeonPrepare, self.endDungeonPrepare, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshMemberInfo, self.refreshMemberInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Team.CreateEntity, self.createEntity, self)
  self:bindAttrWatcher()
end

function TeamView:memberOnLineChange(socialData)
  if socialData.basicData.offlineTime == 0 then
    self:addMemberAttrWatcher(socialData.basicData.charID)
  else
    if self.memberHpAttrWatcher_[socialData.basicData.charID] then
      self:UnBindEntityLuaAttrWatcher(self.memberHpAttrWatcher_[socialData.basicData.charID])
      self.memberHpAttrWatcher_[socialData.basicData.charID] = nil
    end
    if self.memberDeadAttrWatcher_[socialData.basicData.charID] then
      self.memberDeadAttrWatcher_[socialData.basicData.charID]:Dispose()
      self.memberDeadAttrWatcher_[socialData.basicData.charID] = nil
    end
    if self.memberBuffAttrWatcher_[socialData.basicData.charID] then
      self:UnBindEntityLuaAttrWatcher(self.memberBuffAttrWatcher_[socialData.basicData.charID])
      self.memberBuffAttrWatcher_[socialData.basicData.charID] = nil
    end
  end
  self:changeCallStatus()
end

function TeamView:updateState()
  self:refreshSetoutNode()
end

function TeamView:bindAttrWatcher()
  self:BindEntityLuaAttrWatcher({
    Z.PbAttrEnum("AttrInBattleShow")
  }, Z.EntityMgr.PlayerEnt, self.updateState)
end

function TeamView:refreshBuffItem(item, buffData)
  if buffData and item then
    if buffData.DurationTime and buffData.DurationTime > 0 then
      if self.buffInfo_[item] ~= buffData.BuffUuid then
        self:AddClick(item.btn, function()
          Z.EventMgr:Dispatch(Z.ConstValue.Buff.BuffDataRefresh, {buffData})
          Z.UIMgr:OpenView("tips_battle_buff_popup", {
            buffList = {buffData},
            position = self.uiBinder.node_buff.transform.position
          })
        end)
        item.img_icon:SetImage(buffData.Icon)
        item.Ref:SetVisible(item.img_icon, true)
        if buffData.Layer > 1 then
          item.lab_digit.text = buffData.Layer
        else
          item.lab_digit.text = ""
        end
        local nowTime = Z.NumTools.GetPreciseDecimal(Z.ServerTime:GetServerTime() / 1000, 1)
        local nowValue = nowTime - buffData.CreateTime
        local begin
        if buffData.BuffTime and 0 < buffData.BuffTime and buffData.DurationTime > buffData.BuffTime then
          begin = 1 - (nowValue - (buffData.DurationTime - buffData.BuffTime)) / buffData.BuffTime
        else
          begin = 1 - nowValue / buffData.DurationTime
        end
        item.img_progress:Play(begin, 0, buffData.DurationTime - nowValue, nil, buffData.BuffTime)
        item.Ref:SetVisible(item.img_progress, true)
        self.buffInfo_[item] = buffData.BuffUuid
      end
    else
      self.buffInfo_[item] = nil
      item.img_progress:Stop()
      item.Ref:SetVisible(item.img_progress, false)
    end
  end
end

function TeamView:updateBuffInfo(charId)
  local memberItem = self.contMembers_[charId]
  if memberItem == nil then
    return
  end
  local entity = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
  if entity == nil then
    memberItem.battle_icon_buff_1.Ref.UIComp:SetVisible(false)
    memberItem.battle_icon_buff_2.Ref.UIComp:SetVisible(false)
    return
  end
  local gainBuffDataList = {}
  local deBuffDataList = self.buffVm_.GetEntityBuffListByType(E.EBuffType.Debuff, entity, self.buffVm_.SortCreateTimeFunc, E.EBuffPriority.NoticeAndTeamShow) or {}
  if Z.IsPCUI then
    gainBuffDataList = self.buffVm_.GetEntityBuffListByType(E.EBuffType.Gain, entity, self.buffVm_.SortCreateTimeFunc, E.EBuffPriority.NoticeAndTeamShow) or {}
  end
  local gainBuffData = gainBuffDataList[1]
  local deBuffData = deBuffDataList[1]
  memberItem.battle_icon_buff_1.Ref.UIComp:SetVisible(deBuffData ~= nil)
  memberItem.battle_icon_buff_2.Ref.UIComp:SetVisible(gainBuffData ~= nil)
  self:refreshBuffItem(memberItem.battle_icon_buff_1, deBuffData)
  self:refreshBuffItem(memberItem.battle_icon_buff_2, gainBuffData)
end

function TeamView:createEntity(charId)
  if self.memberHpAttrWatcher_[charId] then
    self:UnBindEntityLuaAttrWatcher(self.memberHpAttrWatcher_[charId])
    self.memberHpAttrWatcher_[charId] = nil
  end
  if self.memberDeadAttrWatcher_[charId] then
    self.memberDeadAttrWatcher_[charId]:Dispose()
    self.memberDeadAttrWatcher_[charId] = nil
  end
  self:addMemberAttrWatcher(charId)
end

function TeamView:addMemberAttrWatcher(charId)
  local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
  if ent == nil then
    return
  end
  if self.memberHpAttrWatcher_[charId] == nil then
    self.memberHpAttrWatcher_[charId] = self:BindEntityLuaAttrWatcher({
      Z.PbAttrEnum("AttrHp"),
      Z.PbAttrEnum("AttrMaxHp"),
      Z.PbAttrEnum("AttrShieldList")
    }, ent, function()
      self:updateMemberData({charId = charId})
    end)
  end
  if self.memberDeadAttrWatcher_[charId] == nil then
    local uuid = self.entityVm_.EntIdToUuid(charId, entChar)
    self.memberDeadAttrWatcher_[charId] = Z.DIServiceMgr.AttrStateComponentWatcherService:OnAttrStateChanged(uuid, function()
      local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
      if ent and ent:GetLuaAttrState() == deadStateId and self.contMembers_[charId] then
        self:updateHpComp(self.contMembers_[charId], 0)
        self:setShield(self.contMembers_[charId], 0, 0)
      end
    end)
  end
  if self.memberBuffAttrWatcher_[charId] == nil then
    self.memberBuffAttrWatcher_[charId] = self:BindEntityLuaAttrWatcher({
      Z.LocalAttr.ENowBuffList
    }, ent, function()
      self:updateBuffInfo(charId)
    end, true)
  end
end

function TeamView:memberInfoChange(teamMembers)
  self:addMemberAttrWatcher(teamMembers.charId)
end

function TeamView:bindAttrWatchers()
  local memberTbl = self.teamData_.TeamInfo.members
  if memberTbl then
    for k, v in pairs(memberTbl) do
      self:addMemberAttrWatcher(v.charId)
    end
  end
end

function TeamView:unBindTeamMemberAttrWatchers()
  for key, value in pairs(self.memberHpAttrWatcher_) do
    self:UnBindEntityLuaAttrWatcher(value)
  end
  for key, value in pairs(self.memberDeadAttrWatcher_) do
    value:Dispose()
  end
  for key, value in pairs(self.memberBuffAttrWatcher_) do
    self:UnBindEntityLuaAttrWatcher(value)
  end
  self.memberHpAttrWatcher_ = {}
  self.memberBuffAttrWatcher_ = {}
  self.memberDeadAttrWatcher_ = {}
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

function TeamView:updateHpComp(comp, hpValue)
  comp.sliced_image.fillAmount = hpValue
  comp.sliced_break.fillAmount = hpValue
end

function TeamView:setShield(uiBinder, maxHp, hpProgress, progressList)
  if progressList ~= nil and 0 < #progressList then
    local maxShieldValue = 0
    for _, progressInfo in ipairs(progressList) do
      if maxShieldValue < progressInfo.shieldValue then
        maxShieldValue = progressInfo.shieldValue
      end
    end
    uiBinder.sliced_shield.fillAmount = maxShieldValue / maxHp
  else
    uiBinder.sliced_shield.fillAmount = hpProgress
  end
end

function TeamView:updateMemberItemHp(comp, memberData, ent, isForce)
  if ent then
    local curHp = ent:GetLuaAttr(Z.PbAttrEnum("AttrHp")).Value
    local maxHp = ent:GetLuaAttr(Z.PbAttrEnum("AttrMaxHp")).Value
    local shieldMaxValue = 0
    if curHp == 0 then
      self:setShield(comp, maxHp, 0)
    else
      local shieldList = ent:GetLuaAttr(Z.PbAttrEnum("AttrShieldList")).Value
      local shieldProgressList = {}
      for i = shieldList.count - 1, 0, -1 do
        local shieldInfo = shieldList[i]
        if shieldMaxValue < shieldInfo.value then
          shieldMaxValue = shieldInfo.value
        end
        table.insert(shieldProgressList, {
          shieldType = shieldInfo.shieldType,
          shieldValue = shieldMaxValue + curHp
        })
      end
      self:setShield(comp, maxHp, 0, shieldProgressList)
    end
    if memberData then
      memberData.hp = curHp
      memberData.maxHp = maxHp
    end
    local hpValue = curHp / maxHp
    if maxHp < curHp + shieldMaxValue then
      hpValue = curHp / (maxHp + shieldMaxValue)
    end
    if ent:GetLuaAttrState() == deadStateId then
      hpValue = 0
    end
    self:updateHpComp(comp, hpValue)
  elseif isForce then
    if memberData then
      local hp = memberData.hp or 0
      local maxHp = memberData.maxHp or 0
      local hpValue = hp == maxHp and 1 or hp / maxHp
      self:updateHpComp(comp, hpValue)
      self:setShield(comp, maxHp, 0)
    else
      self:updateHpComp(comp, 1)
    end
  end
end

function TeamView:getMemberInfoByIndex(index)
  local groupId = Z.IsPCUI and math.ceil(index / 5) or math.ceil(index / 5) + (self.selectedTogIs12_ and 0 or 2)
  local index = index % 5 == 0 and 5 or index % 5
  local memberInfo = self.teamGroupMemberInfos_[groupId] and self.teamGroupMemberInfos_[groupId][index] or nil
  return memberInfo
end

function TeamView:updateMemberData(data)
  local data = data or {}
  local charId = data.charId
  if charId == nil then
    return
  end
  local isForce = data.isForce
  if isForce then
    self:addMemberAttrWatcher(data.charId)
  end
  local ent
  if charId then
    ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
  end
  local members = self.teamData_.TeamInfo.members
  if not members then
    return
  end
  if self.contMembers_[charId] then
    self:updateMemberItemHp(self.contMembers_[charId], members[charId], ent, isForce)
  end
end

function TeamView:refreshTeam()
  self:setTeamInfo()
  self:refreshMic()
  self:setTeamSetting()
  self:setCompActive()
  self:unBindTeamMemberAttrWatchers()
  self:bindAttrWatchers()
  self:refreshSetoutNode()
  self:refreshSceneMaskButton()
  self:refreshMemberBuffInfo()
end

function TeamView:refreshMemberInfo(memberInfo)
  local member = self.contMembers_[memberInfo.charId]
  self:setMemberItem(member, memberInfo)
end

function TeamView:refreshMemberBuffInfo()
end

function TeamView:getGroupIndexByCharId(group, charId)
  local teamInfo = self.teamData_.TeamInfo
  local groupInfos = teamInfo.baseInfo.teamMemberGroupInfos[group]
  if groupInfos then
    for index, value in ipairs(groupInfos.charIds) do
      if value == charId then
        return index
      end
    end
  end
  return 0
end

function TeamView:getTeamGroupMemberInfo()
  self.teamGroupMemberInfos_ = {
    {},
    {},
    {},
    {}
  }
  local teamInfo = self.teamData_.TeamInfo
  if teamInfo.baseInfo.teamMemberType == E.ETeamMemberType.Five then
    return
  end
  for index, value in pairs(teamInfo.members) do
    if self.teamGroupMemberInfos_[value.groupId] then
      table.insert(self.teamGroupMemberInfos_[value.groupId], value)
    end
  end
  for index, value in ipairs(self.teamGroupMemberInfos_) do
    table.sort(value, function(left, right)
      local leftIndex = self:getGroupIndexByCharId(index, left.charId)
      local rightIndex = self:getGroupIndexByCharId(index, right.charId)
      return leftIndex < rightIndex
    end)
  end
end

function TeamView:setMemberItem(v, member)
  if not v or not member then
    return
  end
  self.contMembers_[member.charId] = v
  local isCaptain = member.charId == self.teamData_.TeamInfo.baseInfo.leaderId
  v.Ref:SetVisible(v.img_leader, isCaptain)
  local professionId = 0
  if member.isAi then
    local botAiId = member.socialData.basicData.botAiId
    local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
    if botAITableRow then
      professionId = botAITableRow.Weapon[1]
      v.lab_name.text = botAITableRow.Name
    end
    v.lab_lv.text = Lang("Level", {
      val = self.teamData_:GetLeaderLevel()
    })
    v.Ref:SetVisible(v.node_newbie_icon, false)
  else
    v.Ref:SetVisible(v.node_newbie_icon, not isCaptain and Z.VMMgr.GetVM("player"):IsShowNewbie(member.socialData.basicData.isNewbie))
    local name = member.socialData.basicData.name
    if member.charId == Z.ContainerMgr.CharSerialize.charId then
      name = Z.RichTextHelper.ApplyColorTag(name, "#ffd100")
    end
    v.lab_name.text = name
    v.lab_lv.text = Lang("Level", {
      val = member.socialData.basicData.level
    })
    local professionData = member.socialData.professionData
    if professionData then
      professionId = professionData.professionId
    end
  end
  if professionId ~= 0 then
    local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if professionSystemTableRow then
      v.img_icon_type:SetImage(professionSystemTableRow.Icon)
      v.img_icon_type:SetColorByHex(professionSystemTableRow.TalentColor)
    end
  end
  if member.socialData then
    local hp = member.hp or 0
    local maxHp = member.maxHp or 0
    local hpValue = hp == maxHp and 1 or hp / maxHp
    self:updateHpComp(v, hpValue)
  else
    self:updateHpComp(v, 1)
  end
  self:AddClick(v.btn_selected, function()
    if not self.entityVm_.CheckIsAIByEntId(member.charId) and member.charId ~= Z.ContainerMgr.CharSerialize.charId then
      self:setTeamPop(member.charId)
    end
  end)
  self:updateBuffInfo(member.charId)
end

function TeamView:setTeamInfo()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.teamMaxMemberType_ = teamInfo.teamMemberType or 0
  local members = self.teamData_.TeamInfo.members
  local memberCount = table.zcount(members)
  local isInTeam = 0 < memberCount
  self.uiBinder.Ref:SetVisible(self.memberNode5_, isInTeam and self.teamMaxMemberType_ == E.ETeamMemberType.Five)
  self.memberNode20_.Ref.UIComp:SetVisible(isInTeam and self.teamMaxMemberType_ == E.ETeamMemberType.Twenty)
  local curCharId = Z.ContainerMgr.CharSerialize.charBase.charId
  local isLeader = false
  local selfInfo
  local isShow = false
  selfInfo = members[curCharId]
  if selfInfo then
    self:setVoiceIcon(selfInfo.micState or E.ETeamVoiceState.SpeakerVoice)
  end
  if isInTeam then
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
  if Z.IsPCUI then
    if isInTeam and self.curVoiceState_ == nil then
      self:switchVoiceState()
    end
  else
    self.uiBinder.Ref:SetVisible(self.btn_convene_, isShow)
    self.uiBinder.Ref:SetVisible(self.btn_create_, not isInTeam)
    self.uiBinder.Ref:SetVisible(self.btn_voice_, isInTeam)
    self.uiBinder.Ref:SetVisible(self.targetBtn_, isLeader)
  end
  self.setoutNode_.Ref.UIComp:SetVisible(isLeader and Z.StageMgr.IsDungeonStage() and 1 < memberCount)
  self:getTeamGroupMemberInfo()
  self:changeCallStatus()
  self.contMembers_ = {}
  if self.teamMaxMemberType_ == E.ETeamMemberType.Five then
    for k, v in ipairs(self.memberInfo_) do
      self:setMemberItem(v, self.memberInfoList_[k])
    end
  else
    for index, v in ipairs(self.memberInfo20_) do
      local memberInfo = self:getMemberInfoByIndex(index)
      self:setMemberItem(v, memberInfo)
    end
  end
end

function TeamView:refreshSetoutNode()
  self.isInBattle_ = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInBattleShow")).Value == 1
  self.setoutNode_.Ref:SetVisible(self.setoutNode_.node_on, not self.isInBattle_ and not self.teamData_.IsDungeonPrepareIng)
  self.setoutNode_.Ref:SetVisible(self.setoutNode_.node_off, self.isInBattle_ and not self.teamData_.IsDungeonPrepareIng)
  self.setoutNode_.Ref:SetVisible(self.setoutNode_.node_ing, self.teamData_.IsDungeonPrepareIng)
end

function TeamView:refreshSceneMaskButton()
  local leaderId = self.teamData_.TeamInfo.baseInfo.leaderId
  local isLeader = leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
  self:SetUIVisible(self.uiBinder.btn_punctuate, Z.StageMgr.IsDungeonStage() and isLeader)
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

function TeamView:changeCallStatusByInfo(v, member, labNum)
  local members = self.teamData_.TeamInfo.members
  local selfInfo
  if members then
    selfInfo = members[Z.ContainerMgr.CharSerialize.charBase.charId]
  end
  v.lab_num.text = labNum
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
          self:refreshShowConvene(v, member)
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
    local isOnLine = member.socialData.basicData.offlineTime == 0
    v.Ref:SetVisible(v.sliced_break, not isOnLine)
  end
end

function TeamView:changeCallStatus()
  if self.teamMaxMemberType_ == E.ETeamMemberType.Five then
    local memberTbl = self.vm.GetTeamMemData()
    self.memberInfoList_ = {}
    local memberPosList = {}
    for k, v in ipairs(memberTbl) do
      table.insert(self.memberInfoList_, v)
      memberPosList[v.charId] = k
    end
    for k, v in ipairs(self.memberInfo_) do
      local display = self.memberInfoList_[k] and true or false
      v.Ref.UIComp:SetVisible(display)
      v.Ref:SetVisible(v.btn_selected, display)
      v.Ref:SetVisible(v.img_convene, false)
      if display then
        local member = self.memberInfoList_[k]
        local labNum = memberPosList[self.memberInfoList_[k].charId] or ""
        self:changeCallStatusByInfo(v, member, labNum)
      end
    end
  else
    for index, item in ipairs(self.memberInfo20_) do
      local memberInfo = self:getMemberInfoByIndex(index)
      local groupId = Z.IsPCUI and math.ceil(index / 5) or math.ceil(index / 5) + (self.selectedTogIs12_ and 0 or 2)
      item.Ref.UIComp:SetVisible(memberInfo ~= nil)
      item.Ref:SetVisible(item.btn_selected, memberInfo ~= nil)
      item.Ref:SetVisible(item.img_convene, false)
      if memberInfo then
        local labNum = self:getGroupIndexByCharId(groupId, memberInfo.charId) + (groupId - 1) * 5
        self:changeCallStatusByInfo(item, memberInfo, labNum)
      end
    end
  end
end

function TeamView:refreshTipsItemPos()
  local wight = Z.IsPCUI and -36 or -49
  local offset = Z.IsPCUI and -44 or -58
  local itemPosX = Z.IsPCUI and 118 or 177
  local showIndex = 0
  local groupHeight = 0
  for type, item in pairs(self.allFunctionContainer_) do
    local isShow = self.tipsItemStateList_[type] ~= false
    item.Ref.UIComp:SetVisible(isShow)
    if isShow then
      groupHeight = wight + offset * showIndex
      item.Trans:SetAnchorPosition(itemPosX, groupHeight)
      showIndex = showIndex + 1
    end
  end
  self.uiBinder.node_tips.layout_group:SetHeight(math.abs(groupHeight) + math.abs(wight))
end

function TeamView:refreshShowConvene(unit, member)
  unit.Ref:SetVisible(unit.img_convene, self.vm.CheckCanSummoned(member))
end

function TeamView:setTeamPop(memberId)
  self.tipsItemStateList_ = {}
  local node_tips = self.uiBinder.node_tips
  self.allFunctionContainer_[ETeamFunctionType.SendMsg] = node_tips.node_send_message
  self.allFunctionContainer_[ETeamFunctionType.ViewMsg] = node_tips.node_view_message
  self.allFunctionContainer_[ETeamFunctionType.AddFriend] = node_tips.node_add_friend
  self.allFunctionContainer_[ETeamFunctionType.TransferLeader] = node_tips.node_transfer_captain
  self.allFunctionContainer_[ETeamFunctionType.PleaseLevelTeam] = node_tips.node_leave_team
  self.allFunctionContainer_[ETeamFunctionType.ApplyLeader] = node_tips.node_apply_captain
  self.allFunctionContainer_[ETeamFunctionType.GoToLine] = node_tips.node_go_line
  self.allFunctionContainer_[ETeamFunctionType.BlockVoice] = node_tips.node_block_voice
  self.allFunctionContainer_[ETeamFunctionType.ReportVoice] = node_tips.node_report_voice
  self.allFunctionContainer_[ETeamFunctionType.Convene] = node_tips.node_convene
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
    self.friendsMainVm_.AsyncSendAddFriend(memberId, E.FriendAddSource.Team, self.cancelSource:CreateToken())
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
  self.allFunction_[ETeamFunctionType.ReportVoice] = function()
    self.vm.AsyncReportPlayer(memberId, self.cancelSource:CreateToken())
  end
  self.allFunction_[ETeamFunctionType.Convene] = function()
    local members = self.teamData_.TeamInfo.members
    if members and members[memberId] then
      local charId = members[memberId].socialData.basicData.charID
      self.vm.AsyncInviteJoinDungeons(charId, self.cancelSource:CreateToken())
    end
  end
  self:updateApplyCaptainBtn(node_tips)
  if memberId then
    local leaderId = self.teamData_.TeamInfo.baseInfo.leaderId
    local selectIsLeader = memberId == leaderId
    local selfCharId = Z.ContainerMgr.CharSerialize.charBase.charId
    local selfIsLeader = leaderId == selfCharId
    local members = self.teamData_.TeamInfo.members
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    self.tipsItemStateList_[ETeamFunctionType.SendMsg] = true
    self.tipsItemStateList_[ETeamFunctionType.ViewMsg] = false
    self.tipsItemStateList_[ETeamFunctionType.AddFriend] = self.funcVm_.CheckFuncCanUse(E.FriendFunctionBtnType.AddFriend) and not self.friendData_:IsFriendByCharId(memberId)
    self.tipsItemStateList_[ETeamFunctionType.TransferLeader] = not selectIsLeader and selfIsLeader
    self.tipsItemStateList_[ETeamFunctionType.PleaseLevelTeam] = not selectIsLeader and selfIsLeader and dungeonId == 0
    self.tipsItemStateList_[ETeamFunctionType.ApplyLeader] = selectIsLeader
    self.tipsItemStateList_[ETeamFunctionType.BlockVoice] = true
    self.tipsItemStateList_[ETeamFunctionType.ReportVoice] = true
    if members and members[selfCharId] and members[memberId] then
      local selfSocialData = members[selfCharId].socialData
      local memberSocialData = members[memberId].socialData
      if selfSocialData and memberSocialData then
        local isShow = selfSocialData.basicData.sceneId == memberSocialData.basicData.sceneId and selfSocialData.basicData.sceneGuid ~= memberSocialData.basicData.sceneGuid
        self.tipsItemStateList_[ETeamFunctionType.GoToLine] = isShow
        self.tipsItemStateList_[ETeamFunctionType.Convene] = self.vm.CheckCanSummoned(members[memberId])
        self:refreshConveneCd(memberId, self.allFunctionContainer_[ETeamFunctionType.Convene].lab_name)
      end
    end
    node_tips.presscheck:StartCheck()
    node_tips.Ref.UIComp:SetVisible(true)
    self:refreshTipsItemPos()
  end
end

function TeamView:refreshConveneCd(charId, text)
  local deltaTime = math.floor(Z.TimeTools.Now() / 1000 - self.teamData_:GetInviteCd(charId))
  if deltaTime < Z.Global.DungeonSummonedCD then
    local cd = Z.Global.DungeonSummonedCD - deltaTime
    text.text = Lang("convene_cd_tips", {val = cd})
    if self.conveneTimer_[charId] then
      self.timerMgr:StopTimer(self.conveneTimer_[charId])
      self.conveneTimer_[charId] = nil
    end
    self.conveneTimer_[charId] = self.timerMgr:StartTimer(function()
      if cd <= 0 then
        text.text = Lang("Convene")
      else
        text.text = Lang("convene_cd_tips", {val = cd})
      end
      cd = cd - 1
    end, 1, cd + 1)
  else
    text.text = Lang("Convene")
  end
end

function TeamView:OnTriggerInputAction(inputActionEventData)
  if inputActionEventData.ActionId == Z.InputActionIds.TeamVoice then
    self:switchVoiceState()
  end
end

return TeamView
