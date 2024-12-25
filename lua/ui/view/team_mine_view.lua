local UI = Z.UI
local super = require("ui.ui_subview_base")
local Team_mineView = class("Team_mineView", super)
local paths = {
  team_icon_branching = "ui/atlas/mainui/team/team_icon_branching",
  team_icon_scene = "ui/atlas/mainui/team/team_icon_no_scene"
}
local modelActionName = {
  [100001] = "as_m_base_idle",
  [100002] = "as_f_base_team_fsidle01",
  [100003] = "as_m_base_idle",
  [100004] = "as_f_base_idle",
  [100005] = "as_wpnpc_f_base_olvera_perform01",
  [100006] = "as_f_base_skt_akimboidle_loop"
}
local selfIndex = 100
local modelPos = {
  Vector3.New(-0.5, 0.0, 1.5),
  Vector3.New(0.1, 0.0, 3),
  Vector3.New(0.7, 0.0, 3.5)
}
local rotateY = {
  176,
  161,
  160,
  [selfIndex] = 180
}
local playerRotateY = {
  160,
  180,
  190,
  [selfIndex] = 165
}

function Team_mineView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "team_mine_add_sub", "team/team_mine_add_sub", UI.ECacheLv.None, parent)
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function Team_mineView:initBinder()
  self.layout_content_ = self.uiBinder.layout_content
  self.lab_desc_ = self.uiBinder.lab_desc
  self.lab_target_ = self.uiBinder.lab_target
  self.img_target_1_ = self.uiBinder.img_target_1
  self.img_target_2_ = self.uiBinder.img_target_2
  self.btn_apply_ = self.uiBinder.btn_apply
  self.node_apply_ = self.uiBinder.node_apply
  self.btn_leave_ = self.uiBinder.btn_leave
  self.btn_match_ = self.uiBinder.btn_match
  self.btn_out_ = self.uiBinder.btn_out
  self.btn_setting_ = self.uiBinder.btn_setting
  self.anim_ = self.uiBinder.anim
  self.match_lab_tips_ = self.uiBinder.match_lab_tips
  self.self_nodemember = self.uiBinder.node_member_tpl2
  self.node_members_ = {}
  self.node_members_[1] = self.uiBinder.node_member_tpl1
  self.node_members_[2] = self.uiBinder.node_member_tpl3
  self.node_members_[3] = self.uiBinder.node_member_tpl4
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.targetBtn_ = self.uiBinder.btn_target
end

function Team_mineView:initBtns()
  self:AddClick(self.targetBtn_, function()
    if self.teamTargetCfg_ then
      local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
      quickjumpVm.DoJumpByConfigParam(self.teamTargetCfg_.QuickJumpType, self.teamTargetCfg_.QuickJumpParam)
    end
  end)
  self:AddAsyncClick(self.btn_apply_, function()
    local teamRequestVM = Z.VMMgr.GetVM("team_request")
    teamRequestVM.OpenRequestView()
    Z.RedPointMgr.OnClickRedDot(E.RedType.TeamApplyButton)
  end)
  self:AddClick(self.btn_setting_, function()
    local teamTargetVM = Z.VMMgr.GetVM("team_target")
    teamTargetVM.OpenTeamTargetView()
  end)
  self:AddAsyncClick(self.btn_out_, function()
    Z.EventMgr:Dispatch(Z.ConstValue.Team.QuitTeam)
  end)
  self:AddAsyncClick(self.btn_match_, function()
    local teamInfo = self.teamData_.TeamInfo.baseInfo
    if not teamInfo.teamId then
      return
    end
    local targetId = teamInfo.targetId
    if targetId == 0 then
      Z.TipsVM.ShowTipsLang(100111)
      return
    end
    if targetId == E.TeamTargetId.Costume then
      Z.TipsVM.ShowTipsLang(1000622)
      return
    end
    local members = self.teamVM_.GetTeamMemData()
    if 4 <= #members then
      Z.TipsVM.ShowTipsLang(1000619)
      return
    end
    local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
    if not teamTargetRow then
      return
    end
    if not teamTargetRow.MemberCountStopMatch or teamTargetRow.MemberCountStopMatch == 0 then
      Z.TipsVM.ShowTips(1000750)
      return
    end
    self.matchVm_.AsyncBeginMatchNew(E.MatchType.Team, {}, true, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btn_leave_, function()
    self.matchVm_.AsyncCancelMatchNew(E.MatchType.Team, true, self.cancelSource:CreateToken())
  end)
end

function Team_mineView:OnActive()
  self.isEndLoad_ = true
  self.isRefreshTeamInfo_ = false
  self:initBinder()
  self:initBtns()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TeamApplyButton, self, self.node_apply_.transform)
  self.uiBinder.Trans:SetOffsetMin(130, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.teamModelList_ = {}
  self.allUIModel = {}
  self.effectUuidTab_ = {}
  self.chariId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self:setCompActive()
  self:setTeamSetting()
  self:initMemberItems()
  self:BindEvents()
end

function Team_mineView:setCompActive()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local selfIsLeader = teamInfo.leaderId == self.chariId_
  local matchType = self.matchData_:GetMatchType()
  local matching = teamInfo.matching and matchType == E.MatchType.Team
  self.uiBinder.Ref:SetVisible(self.match_lab_tips_, matching)
  self.uiBinder.Ref:SetVisible(self.btn_leave_, selfIsLeader and matching)
  self.uiBinder.Ref:SetVisible(self.btn_match_, selfIsLeader and not matching)
  self.uiBinder.Ref:SetVisible(self.btn_apply_, selfIsLeader)
end

function Team_mineView:setTeamSetting()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.teamTargetCfg_ = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(teamInfo.targetId)
  if not self.teamTargetCfg_ then
    logError("TeamTargetTable \233\133\141\231\189\174id {0} \228\184\141\229\173\152\229\156\168", teamInfo.targetId)
    return
  end
  self.sourceData_ = self.itemSourceVm_.GetSourceByFunctionId(self.teamTargetCfg_.FunctionID)
  if self.teamTargetCfg_.QuickJumpType ~= 0 and self.teamData_.TeamInfo.baseInfo.leaderId == self.chariId_ then
    self.uiBinder.Ref:SetVisible(self.targetBtn_, true)
  else
    self.uiBinder.Ref:SetVisible(self.targetBtn_, false)
  end
  local param = {
    pt = {
      target = self.teamTargetCfg_.Name
    }
  }
  self.lab_target_.text = Lang("teamTargetText", param)
  self.lab_desc_.text = teamInfo.desc
  self.uiBinder.Ref:SetVisible(self.img_target_1_, not teamInfo.hallShow)
  self.uiBinder.Ref:SetVisible(self.img_target_2_, teamInfo.hallShow)
end

function Team_mineView:initMeberItem(memberItem, index)
  memberItem.Ref:SetVisible(memberItem.group_play_info, false)
  memberItem.anim:Restart(Z.DOTweenAnimType.Open)
  self:AddAsyncClick(memberItem.btn_add_empty, function()
    local teamInviteVM = Z.VMMgr.GetVM("team_invite_popup")
    teamInviteVM.OpenInviteView()
  end)
end

function Team_mineView:initMemberItems()
  for index, memberItem in ipairs(self.node_members_) do
    self:initMeberItem(memberItem, index)
  end
  self:initMeberItem(self.self_nodemember, selfIndex)
  self.self_nodemember.Ref:SetVisible(self.self_nodemember.node_empty, false)
  self:setTeamInfo()
end

function Team_mineView:preLoadTimeline()
  self.faceData_ = Z.DataMgr.Get("face_data")
  self.timelineInfoList_ = {}
  if self.faceData_.Gender == Z.PbEnum("EGender", "GenderMale") then
    self.timelineInfoList_ = Z.Global.RoleEditorShowActionM
  else
    self.timelineInfoList_ = Z.Global.RoleEditorShowActionF
  end
  for _, timelineInfo in ipairs(self.timelineInfoList_) do
    local timelineId = timelineInfo[1]
    if timelineId then
      Z.UITimelineDisplay:AsyncPreLoadTimeline(timelineId, self.cancelSource:CreateToken())
    end
  end
end

function Team_mineView:loadAiMode(member)
  local mode
  if member and member.socialData then
    local clipNames = ZUtil.Pool.Collections.ZList_string.Rent()
    for _, value in pairs(modelActionName) do
      clipNames:Add(value)
    end
    mode = Z.UnrealSceneMgr:GenAiModelByLua(nil, member.socialData.basicData.botAiId)
    clipNames:Recycle()
  end
  return mode
end

function Team_mineView:loadMode(unit, member, index)
  local createPos = Z.UnrealSceneMgr:GetTransPos("pos")
  local modelClone, modelId
  if member then
    if member.isAi then
      modelClone = self:loadAiMode(member)
      local BotAIRow = Z.TableMgr.GetRow("BotAITableMgr", member.socialData.basicData.botAiId)
      if BotAIRow then
        modelId = BotAIRow.ModelID
      end
    else
      local socialData = self.socialVm_.AsyncGetSocialData(0, member.charId, self.cancelSource:CreateToken())
      if socialData then
        local clipNames = ZUtil.Pool.Collections.ZList_string.Rent()
        for _, value in pairs(modelActionName) do
          clipNames:Add(value)
        end
        modelClone = Z.UnrealSceneMgr:GenModelByLuaSocialData(socialData)
        clipNames:Recycle()
        self.teamData_:SetSocialData(member.charId, socialData)
      end
      modelId = Z.ModelManager:GetModelIdByGenderAndSize(member.socialData.basicData.gender, member.socialData.basicData.bodySize)
    end
  else
    return
  end
  if modelClone ~= nil then
    if modelActionName[modelId] then
      local clipNames = ZUtil.Pool.Collections.ZList_string.Rent()
      modelClone:SetLuaAttr(Z.ModelAttr.EModelAnimBase, Z.AnimBaseData.Rent(modelActionName[modelId]))
      clipNames:Recycle()
    end
    if not self.teamData_.TeamInfo.members[member.charId] then
      self.teamModelList_[index] = nil
      self:clearModel(index)
      self:cleaEffect(index)
      return
    end
    self.allUIModel[index] = modelClone
    local y = rotateY[index]
    local screenPosition = Z.UIRoot.UICam:WorldToScreenPoint(unit.group_play_info.transform.position)
    local newScreenPos = Vector3.New(screenPosition.x, screenPosition.y, Z.NumTools.Distance(Z.CameraMgr.MainCamera.transform.position, createPos))
    local worldPosition = Z.CameraMgr.MainCamera:ScreenToWorldPoint(newScreenPos)
    worldPosition.y = createPos.y
    if member.charId == Z.EntityMgr.PlayerEnt.EntId then
      Z.UnrealSceneMgr:ClearEffect(self.teamPosEffect_)
      self.teamPosEffect_ = Z.UnrealSceneMgr:CreatEffect("common_new/env/p_fx_juese_zhanwei_tishi", "team_pos" .. index)
      y = playerRotateY[selfIndex]
    else
      worldPosition = worldPosition + modelPos[index]
    end
    modelClone:SetAttrGoPosition(worldPosition)
    modelClone:SetAttrGoRotation(Quaternion.Euler(Vector3.New(0, y, 0)))
    self.effectUuidTab_[index] = Z.UnrealSceneMgr:CreatEffect("virtualscene/p_fx_dmj_xuanzhong", "team_mine_" .. index)
  end
end

function Team_mineView:setMemberItem(item, memberInfo, index)
  if memberInfo == nil then
    return
  end
  local charId = memberInfo.charId
  local isLeader = self.teamData_.TeamInfo.baseInfo.leaderId == charId
  item.Ref:SetVisible(item.img_on, isLeader)
  item.Ref:SetVisible(item.img_off, not isLeader)
  item.Ref:SetVisible(item.node_leader, isLeader)
  if self.allUIModel[index] and self.teamModelList_[index] ~= charId then
    self:clearModel(index)
    self:cleaEffect(index)
    self.teamModelList_[index] = nil
  end
  if self.teamModelList_[index] == nil or self.teamModelList_[index] ~= charId then
    self.teamModelList_[index] = charId
    Z.Delay(0.2, self.cancelSource:CreateToken())
    self:loadMode(item, memberInfo, index)
    self:changeSceneGuid(memberInfo.socialData)
    item.Ref:SetVisible(item.group_play_info, true)
    item.Ref:SetVisible(item.img_icon, false)
    item.lab_name.text = memberInfo.socialData.basicData.name
    local professionId = 0
    if not memberInfo.isAi then
      item.lab_gs.text = Lang("LvFormatSymbol", {
        val = memberInfo.socialData.basicData.level
      })
      self:AddAsyncClick(item.btn_card, function()
        local idCardVM = Z.VMMgr.GetVM("idcard")
        idCardVM.AsyncGetCardData(memberInfo.charId, self.cancelSource:CreateToken())
      end)
      professionId = memberInfo.socialData.professionData.professionId
    else
      local selfInfo = self.teamData_.TeamInfo.members[self.chariId_]
      if selfInfo then
        item.lab_gs.text = Lang("LvFormatSymbol", {
          val = selfInfo.socialData.basicData.level
        })
      else
        item.lab_gs.text = ""
      end
      local botAiId = memberInfo.socialData.basicData.botAiId
      local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
      if botAITableRow then
        professionId = botAITableRow.Duty
      end
    end
    if professionId ~= 0 then
      local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
      if professionSystemTableRow then
        item.img_icon:SetImage(professionSystemTableRow.Icon)
        item.Ref:SetVisible(item.img_icon, true)
      end
    end
  end
end

function Team_mineView:setMemberItemAddImg(selfIndex)
  local index = selfIndex == 1 and 2 or 1
  local imgPath = self.prefab_cache_:GetString("img_add_" .. index)
  if imgPath then
    self.node_members_[1].img_add:SetImage(imgPath)
  end
end

function Team_mineView:setTeamInfo()
  self.isEndLoad_ = false
  Z.CoroUtil.create_coro_xpcall(function()
    local teamInfo = self.teamData_.TeamInfo.baseInfo
    local selfIsLeader = teamInfo.leaderId == self.chariId_
    self.uiBinder.Ref:SetVisible(self.btn_setting_, selfIsLeader)
    local members, index = self.teamVM_.GetMemDataNotContainSelf()
    self:setMemberItemAddImg(index)
    for i, memberItem in ipairs(self.node_members_) do
      local memberInfo = members[i]
      local havInfo = memberInfo and true or false
      memberItem.Ref:SetVisible(memberItem.node_empty, not havInfo)
      memberItem.Ref:SetVisible(memberItem.btn_card, havInfo)
      if memberInfo then
        self:setMemberItem(memberItem, memberInfo, i)
      else
        memberItem.Ref:SetVisible(memberItem.group_play_info, false)
        self.teamModelList_[i] = nil
        self:clearModel(i)
        self:cleaEffect(i)
      end
    end
    local selfInfo = self.teamData_.TeamInfo.members[self.chariId_]
    self:setMemberItem(self.self_nodemember, selfInfo, selfIndex)
    if self.isRefreshTeamInfo_ then
      self.isRefreshTeamInfo_ = false
      self:setTeamInfo()
    end
    self.isEndLoad_ = true
  end)()
end

function Team_mineView:clearModel(i)
  if self.allUIModel[i] then
    Z.UnrealSceneMgr:ClearModel(self.allUIModel[i])
    self.allUIModel[i] = nil
  end
end

function Team_mineView:cleaEffect(index)
  if self.effectUuidTab_[index] then
    Z.UnrealSceneMgr:ClearEffect(self.effectUuidTab_[index])
  end
  self.effectUuidTab_[index] = nil
end

function Team_mineView:changeSceneGuid(memberInfo)
  if memberInfo == nil then
    return
  end
  local memberItem
  local members = self.teamVM_.GetMemDataNotContainSelf()
  local teamMember
  for index, member in ipairs(members) do
    if member.charId == memberInfo.charId then
      memberItem = self.node_members_[index]
      teamMember = member
      break
    end
  end
  if memberItem == nil then
    return
  end
  if teamMember and teamMember.isAi then
    memberItem.Ref:SetVisible(memberItem.img_scene, false)
    return
  end
  local selfInfo = self.teamData_.TeamInfo.members[self.chariId_]
  if selfInfo == nil then
    return
  end
  local selfSocialData = selfInfo.socialData
  if selfSocialData == nil or memberInfo == nil then
    return
  end
  local iconPath
  if selfSocialData.basicData.sceneGuid ~= memberInfo.basicData.sceneGuid then
    iconPath = paths.team_icon_branching
  end
  if selfSocialData.basicData.sceneId ~= memberInfo.basicData.sceneId then
    iconPath = paths.team_icon_scene
    memberItem.Ref:SetVisible(memberItem.lab_area, true)
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(memberInfo.basicData.sceneId)
    if sceneRow then
      memberItem.lab_area.text = sceneRow.Name
    end
  else
    memberItem.Ref:SetVisible(memberItem.lab_area, false)
  end
  if iconPath then
    memberItem.Ref:SetVisible(memberItem.img_scene, true)
    memberItem.img_scene:SetImage(iconPath)
  else
    memberItem.Ref:SetVisible(memberItem.img_scene, false)
  end
end

function Team_mineView:OnDeActive()
  Z.UnrealSceneMgr:ClearEffect(self.teamPosEffect_)
  if self.effectUuidTab_ then
    for key, value in pairs(self.effectUuidTab_) do
      Z.UnrealSceneMgr:ClearEffect(value)
    end
    self.effectUuidTab_ = nil
  end
  if self.allUIModel then
    for i, v in pairs(self.allUIModel) do
      Z.UnrealSceneMgr:ClearModel(v)
    end
    self.allUIModel = nil
  end
  self.anim_:Play(Z.DOTweenAnimType.Close)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.TeamApplyButton)
end

function Team_mineView:refreshTeam()
  if self.teamVM_.CheckIsInTeam() then
    if self.isEndLoad_ then
      self:setTeamInfo()
    else
      self.isRefreshTeamInfo_ = true
    end
    self:setCompActive()
  end
end

function Team_mineView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.Refresh, self.refreshTeam, self)
  Z.EventMgr:Add(Z.ConstValue.Team.MatchWaitTimeOut, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshMatchingStatus, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshSetting, self.setTeamSetting, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneGuid, self.changeSceneGuid, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneId, self.changeSceneGuid, self)
end

return Team_mineView
