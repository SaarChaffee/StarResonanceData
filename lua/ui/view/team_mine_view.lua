local UI = Z.UI
local super = require("ui.ui_subview_base")
local Team_mineView = class("Team_mineView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local paths = {
  team_icon_branching = "ui/atlas/mainui/team/team_icon_branching",
  team_icon_scene = "ui/atlas/mainui/team/team_icon_no_scene"
}
local grayColorKey = "#ababab"
local modelActionName = {
  [100001] = "as_m_base_idle",
  [100002] = "as_f_base_team_fsidle01",
  [100003] = "as_m_base_idle",
  [100004] = "as_f_base_idle",
  [100005] = "as_wpnpc_f_base_olvera_perform01",
  [100006] = "as_f_base_skt_akimboidle_loop"
}
local selfIndex = 100
local rotateY = {
  176,
  165,
  170,
  176,
  [selfIndex] = 180
}
local playerRotateY = {
  160,
  180,
  190,
  190,
  [selfIndex] = 165
}

function Team_mineView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "team_mine_add_sub", "team/team_mine_add_sub", UI.ECacheLv.None)
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.itemSourceVm_ = Z.VMMgr.GetVM("item_source")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.matchData_ = Z.DataMgr.Get("match_data")
  self.matchTeamData_ = Z.DataMgr.Get("match_team_data")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.matchTeamVm_ = Z.VMMgr.GetVM("match_team")
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
  self.node_members_ = {
    self.uiBinder.node_member_tpl1,
    self.uiBinder.node_member_tpl3,
    self.uiBinder.node_member_tpl4,
    self.uiBinder.node_member_tpl5
  }
  self.teamNode20_ = self.uiBinder.node_20team
  self.memberGroupNodes20_ = {}
  for i = 1, 4 do
    self.memberGroupNodes20_[i] = {}
    for j = 1, 5 do
      self.memberGroupNodes20_[i][j] = self.teamNode20_["group_" .. i]["team_20team_add_tpl_" .. j]
    end
  end
  self.copyNode_ = self.teamNode20_.node_drag
  self.copyItem_ = self.teamNode20_.team_20team_add_drag
  self.prefab_cache_ = self.uiBinder.prefab_cache
  self.targetBtn_ = self.uiBinder.btn_target
  self.switch20Node_ = self.uiBinder.node_20_switch
  self.switch20_ = self.uiBinder.switch_20
end

function Team_mineView:initBtns()
  self:AddClick(self.targetBtn_, function()
    if self.teamTargetCfg_ then
      local quickjumpVm = Z.VMMgr.GetVM("quick_jump")
      quickjumpVm.DoJumpByConfigParam(self.teamTargetCfg_.QuickJumpType, self.teamTargetCfg_.QuickJumpParam)
    end
  end)
  self:AddAsyncClick(self.switch20_, function(isOn)
    local teamMemberType = isOn and E.ETeamMemberType.Twenty or E.ETeamMemberType.Five
    if self.teamMaxMemberType_ == teamMemberType then
      return
    end
    local targetId = self.teamData_.TeamInfo.baseInfo.targetId
    if targetId ~= E.TeamTargetId.Costume then
      return
    end
    if not self.teamVM_.GetYouIsLeader() then
      return
    end
    local refreshCd = self.teamData_:GetTeamSimpleTime("teamTypeCD")
    if not refreshCd or refreshCd == 0 then
    else
      Z.TipsVM.ShowTips(1000650)
      self.switch20_.IsOn = not self.switch20_.IsOn
      return
    end
    local teamMembers = self.teamVM_.GetTeamMemData()
    if isOn then
      local isSuccess = self.teamVM_.AsyncChangeTeamMemberType(E.ETeamMemberType.Twenty, targetId)
      if not isSuccess then
        self.switch20_:SetIsOnWithoutNotify(false)
      end
    else
      if 5 < #teamMembers then
        self.switch20_.IsOn = true
        Z.TipsVM.ShowTips(1000651)
        return
      end
      self.teamVM_.AsyncChangeTeamMemberType(E.ETeamMemberType.Five, targetId)
    end
    self.teamVM_.SetTeamTargetTime()
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
    if #members >= self.teamData_:GetTeamMaxMember() then
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
    local teamTargetRow = Z.TableMgr.GetTable("TeamTargetTableMgr").GetRow(targetId)
    if not teamTargetRow then
      return
    end
    self.matchVm_.RequestBeginMatch(E.MatchType.Team, {
      dungeonId = teamTargetRow.RelativeDungeonId,
      difficulty = teamTargetRow.Difficulty
    }, self.cancelSource:CreateToken())
  end)
  self:AddAsyncClick(self.btn_leave_, function()
    self.matchVm_.AsyncCancelMatch()
  end)
  for groupId, value in ipairs(self.memberGroupNodes20_) do
    for index, item in ipairs(value) do
      item.Ref:SetVisible(item.img_mark, false)
      local func = function()
        self.onEnterDic_ = {
          {},
          {},
          {},
          {}
        }
        self:onBeginDrag(groupId, index)
      end
      local endFunc = function()
        self:onEndDrag()
      end
      local onEnterFunc = function()
        self:onEnter(groupId, index)
      end
      local onExitFunc = function()
        self:onExit(groupId, index)
      end
      local onClickEvent = function()
        self:onClick(groupId, index)
      end
      self:initDraw(item, func, endFunc, onEnterFunc, onExitFunc, onClickEvent)
    end
  end
end

function Team_mineView:onClick(groupId, index)
  local memberInfo = self.teamGroupMemberInfos_[groupId][index]
  if memberInfo == nil then
    local teamInviteVM = Z.VMMgr.GetVM("team_invite_popup")
    teamInviteVM.OpenInviteView()
  else
    local idCardVM = Z.VMMgr.GetVM("idcard")
    idCardVM.AsyncGetCardData(memberInfo.charId, self.cancelSource:CreateToken())
  end
end

function Team_mineView:onEnter(groupId, index)
  self.onEnterDic_[groupId][index] = true
  local items = {}
  for groupId, indexs in pairs(self.onEnterDic_) do
    for index, v in pairs(indexs) do
      local item = self.memberGroupNodes20_[groupId][index]
      if item then
        items[#items + 1] = item
      end
    end
  end
  if #items == 1 then
    local item = items[1]
    item.Ref:SetVisible(item.img_frame, true)
  else
  end
end

function Team_mineView:onExit(groupId, index)
  self.onEnterDic_[groupId][index] = nil
  local item = self.memberGroupNodes20_[groupId][index]
  if item then
    item.Ref:SetVisible(item.img_frame, false)
  end
end

function Team_mineView:onBeginDrag(groupId, index)
  self.isDraw_ = false
  local memberInfo = self.teamGroupMemberInfos_[groupId][index]
  if not memberInfo then
    return
  end
  if not self.teamVM_.GetYouIsLeader() then
    return
  end
  local item = self.memberGroupNodes20_[groupId][index]
  if item == nil then
    return
  end
  item.Ref:SetVisible(item.img_mark, true)
  self.drawGroupId_ = groupId
  self.drawIndex_ = index
  self.isDraw_ = true
  playerPortraitHgr.InsertNewPortraitBySocialData(self.copyItem_, memberInfo.socialData, nil, self.cancelSource:CreateToken())
end

function Team_mineView:onEndDrag()
  local items = {}
  local exchangeGroupId = 0
  local exchangeIndex = 0
  for groupId, indexs in pairs(self.onEnterDic_) do
    for index, v in pairs(indexs) do
      local item = self.memberGroupNodes20_[groupId][index]
      if item then
        exchangeGroupId = groupId
        exchangeIndex = index - 1
        items[#items + 1] = item
        break
      end
    end
  end
  local item = self.memberGroupNodes20_[self.drawGroupId_][self.drawIndex_]
  if item then
    item.Ref:SetVisible(item.img_mark, false)
  end
  if #items == 1 then
    local item = items[1]
    item.Ref:SetVisible(item.img_frame, false)
    local memberInfo = self.teamGroupMemberInfos_[self.drawGroupId_][self.drawIndex_]
    if memberInfo then
      Z.CoroUtil.create_coro_xpcall(function()
        self.teamVM_.AsyncUpdateTeamGroup(exchangeGroupId, memberInfo.charId, exchangeIndex)
      end)()
    end
  else
  end
end

function Team_mineView:initDraw(skillItem, initDataFunc, endDragFunc, onEnterFunc, onExitFunc, onClickEvent)
  skillItem.trigger_img.onBeginDrag:AddListener(function(go, pointerData)
    if initDataFunc then
      initDataFunc()
    end
    if not self.isDraw_ then
      return
    end
    self.copyItem_.Trans:SetParent(skillItem.Trans)
    self.copyItem_.Trans.localScale = Vector3.one
    self.copyItem_.Trans.localPosition = Vector3.zero
    self.copyItem_.Trans.localRotation = Quaternion.identity
    self.copyItem_.Trans:SetParent(self.copyNode_.transform)
    self.teamNode20_.Ref:SetVisible(self.copyNode_, true)
  end)
  skillItem.trigger_img.onDrag:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    local trans_ = self.copyItem_.Trans
    local ison, uiPos = ZTransformUtility.ScreenPointToLocalPointInRectangle(trans_, pointerData.position, nil)
    local posX, posY = trans_:GetAnchorPosition(nil, nil)
    posX = posX + uiPos.x
    posY = posY + uiPos.y
    trans_:SetAnchorPosition(posX, posY)
  end)
  skillItem.trigger_img.onEndDrag:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    self.teamNode20_.Ref:SetVisible(self.copyNode_, false)
    self.isDraw_ = false
    if endDragFunc then
      Z.CoroUtil.create_coro_xpcall(function()
        endDragFunc()
      end)()
    end
  end)
  skillItem.trigger_img.onEnter:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    if onEnterFunc then
      onEnterFunc()
    end
  end)
  skillItem.trigger_img.onExit:AddListener(function(go, pointerData)
    if not self.isDraw_ then
      return
    end
    if onExitFunc then
      onExitFunc()
    end
  end)
  self:AddAsyncClick(skillItem.trigger_img.onClick, function()
    onClickEvent()
  end)
end

function Team_mineView:OnActive()
  self.isEndLoad_ = true
  self.isRefreshTeamInfo_ = false
  self:initBinder()
  self:initBtns()
  self.modelPos_ = {
    Vector3.New(-0.5, 0.0, 1.5),
    Vector3.New(0.1, 0.0, 3),
    Vector3.New(0.7, 0.0, 3.5),
    Vector3.New(1, 0.0, 3.5)
  }
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TeamApplyButton, self, self.node_apply_.transform)
  self.uiBinder.Trans:SetOffsetMin(130, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.teamModelList_ = {}
  self.allUIModel = {}
  self.effectUuidTab_ = {}
  self.chariId_ = Z.ContainerMgr.CharSerialize.charBase.charId
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self:setTeamSetting()
  self:initMemberItems()
  self:BindEvents()
end

function Team_mineView:setCompActive()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local selfIsLeader = teamInfo.leaderId == self.chariId_
  local matchType = self.matchData_:GetMatchType()
  local matching = matchType == E.MatchType.Team and self.teamTargetCfg_.RelativeDungeonId == self.matchTeamData_:GetCurMatchingDungeonId()
  local canMatch = self.matchTeamVm_.IsShowMatchBtn(self.teamTargetCfg_.RelativeDungeonId, self.teamTargetCfg_.Difficulty)
  self.uiBinder.Ref:SetVisible(self.match_lab_tips_, matching)
  self.uiBinder.Ref:SetVisible(self.btn_leave_, selfIsLeader and matching and canMatch)
  self.uiBinder.Ref:SetVisible(self.btn_match_, selfIsLeader and not matching and canMatch)
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
  self:setCompActive()
end

function Team_mineView:setTeamDes()
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.lab_desc_.text = teamInfo.desc
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
  self.self_nodemember.Ref:SetVisible(self.self_nodemember.img_scene, false)
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
      modelClone:SetLuaAnimBase(Z.AnimBaseData.Rent(modelActionName[modelId]))
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
    if member.charId == Z.EntityMgr.PlayerEnt.CharId then
      Z.UnrealSceneMgr:ClearEffect(self.teamPosEffect_)
      self.teamPosEffect_ = Z.UnrealSceneMgr:CreatEffect("common_new/env/p_fx_juese_zhanwei_tishi", "team_pos" .. index)
      y = playerRotateY[selfIndex]
    else
      worldPosition = worldPosition + self.modelPos_[index]
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
  self.teamItem_[memberInfo.charId] = item
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
    item.Ref:SetVisible(item.lab_area, false)
    self:loadMode(item, memberInfo, index)
    self:changeSceneGuid(memberInfo.socialData)
    local isOnLine = memberInfo.socialData.basicData.offlineTime == 0
    item.Ref:SetVisible(item.img_break, not isOnLine)
    item.Ref:SetVisible(item.group_play_info, true)
    item.Ref:SetVisible(item.img_icon, false)
    local professionId = 0
    if not memberInfo.isAi then
      local score = 0
      local master_dungeon_score_text = score
      if memberInfo.socialData.masterModeDungeonData then
        score = memberInfo.socialData.masterModeDungeonData.seasonScore
        local scoreText = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
        master_dungeon_score_text = scoreText
        if memberInfo.socialData.masterModeDungeonData.isShow then
          master_dungeon_score_text = Lang("Hidden")
          item.Ref:SetVisible(item.layout_lab, true)
        else
          item.Ref:SetVisible(item.layout_lab, 0 < score)
        end
      else
        item.Ref:SetVisible(item.layout_lab, false)
      end
      if not isOnLine then
        item.lab_name.text = Z.RichTextHelper.ApplyColorTag(memberInfo.socialData.basicData.name, grayColorKey)
        item.lab_gs.text = Z.RichTextHelper.ApplyColorTag(Lang("LvFormatSymbol", {
          val = memberInfo.socialData.basicData.level
        }), grayColorKey)
        item.lab_master_dungeon_score.text = Z.RichTextHelper.ApplyColorTag(master_dungeon_score_text, grayColorKey)
      else
        local name = memberInfo.socialData.basicData.name
        if memberInfo.charId == Z.ContainerMgr.CharSerialize.charId then
          name = Z.RichTextHelper.ApplyColorTag(name, "#ffd100")
        end
        item.lab_name.text = name
        item.lab_gs.text = Lang("LvFormatSymbol", {
          val = memberInfo.socialData.basicData.level
        })
        item.lab_master_dungeon_score.text = master_dungeon_score_text
      end
      self:AddAsyncClick(item.btn_card, function()
        local idCardVM = Z.VMMgr.GetVM("idcard")
        idCardVM.AsyncGetCardData(memberInfo.charId, self.cancelSource:CreateToken())
      end)
      professionId = memberInfo.socialData.professionData.professionId
      item.Ref:SetVisible(item.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(memberInfo.socialData.basicData.isNewbie))
    else
      item.Ref:SetVisible(item.lab_master_dungeon_score, false)
      local leaderLevel = self.teamData_:GetLeaderLevel()
      item.lab_gs.text = Lang("LvFormatSymbol", {val = leaderLevel})
      local botAiId = memberInfo.socialData.basicData.botAiId
      local botAITableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
      if botAITableRow then
        item.lab_name.text = botAITableRow.Name
        professionId = botAITableRow.Duty
      end
      item.Ref:SetVisible(item.img_newbie, false)
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

function Team_mineView:setOnlineState(memberInfo)
  if self.teamMaxMemberType_ == E.ETeamMemberType.Twenty then
    local clientMemberInfo = self.teamData_.TeamInfo.members[memberInfo.basicData.charID]
    self:setTwentyMemberItem(self.teamItem_[memberInfo.basicData.charID], clientMemberInfo)
    return
  end
  local memberItem = self:getMemberItemAndMemberDataByCharId(memberInfo.basicData.charID)
  if memberItem then
    local isOnLine = memberInfo.basicData.offlineTime == 0
    memberItem.Ref:SetVisible(memberItem.img_break, not isOnLine)
    local score = 0
    local master_dungeon_score_text = score
    if memberInfo.masterModeDungeonData then
      score = memberInfo.masterModeDungeonData.seasonScore
      local scoreText = Z.VMMgr.GetVM("hero_dungeon_main").GetPlayerSeasonMasterDungeonTotalScoreWithColor(score)
      master_dungeon_score_text = scoreText
      if memberInfo.masterModeDungeonData.isShow then
        master_dungeon_score_text = Lang("Hidden")
        memberItem.Ref:SetVisible(memberItem.layout_lab, true)
      else
        memberItem.Ref:SetVisible(memberItem.layout_lab, 0 < score)
      end
    else
      memberItem.Ref:SetVisible(memberItem.layout_lab, false)
    end
    if not isOnLine then
      memberItem.lab_name.text = Z.RichTextHelper.ApplyColorTag(memberInfo.basicData.name, grayColorKey)
      memberItem.lab_gs.text = Z.RichTextHelper.ApplyColorTag(Lang("LvFormatSymbol", {
        val = memberInfo.basicData.level
      }), grayColorKey)
      memberItem.lab_master_dungeon_score.text = Z.RichTextHelper.ApplyColorTag(master_dungeon_score_text, grayColorKey)
    else
      memberItem.lab_name.text = memberInfo.basicData.name
      memberItem.lab_gs.text = Lang("LvFormatSymbol", {
        val = memberInfo.basicData.level
      })
      memberItem.lab_master_dungeon_score.text = master_dungeon_score_text
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

function Team_mineView:onMatchStateChange()
  self:setCompActive()
end

function Team_mineView:getGroupIndexByCharId(group, charId)
  local teamInfo = self.teamData_.TeamInfo
  local groupInfos = teamInfo.baseInfo.teamMemberGroupInfos[group]
  if groupInfos then
    for index, value in pairs(groupInfos.charIds) do
      if value == charId then
        return index
      end
    end
  end
  return 0
end

function Team_mineView:getTeamGroupMemberInfo()
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
      local groupIndex = self:getGroupIndexByCharId(value.groupId, value.charId)
      self.teamGroupMemberInfos_[value.groupId][groupIndex] = value
    end
  end
end

function Team_mineView:setTeamInfo()
  self.teamItem_ = {}
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.teamNode20_.Ref:SetVisible(self.copyNode_, false)
  self.teamMaxMemberType_ = teamInfo.teamMemberType or 0
  self.uiBinder.Ref:SetVisible(self.layout_content_, self.teamMaxMemberType_ == E.ETeamMemberType.Five)
  self.teamNode20_.Ref.UIComp:SetVisible(self.teamMaxMemberType_ == E.ETeamMemberType.Twenty)
  local showswitch20Node = false
  if teamInfo.targetId == E.TeamTargetId.Costume then
    if Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.TeamTwenty, true) then
      showswitch20Node = true
    elseif self.teamMaxMemberType_ == E.ETeamMemberType.Twenty then
      showswitch20Node = true
    end
  end
  self.uiBinder.Ref:SetVisible(self.switch20Node_, showswitch20Node and self.teamVM_.GetYouIsLeader())
  self.switch20_.IsOn = self.teamMaxMemberType_ == E.ETeamMemberType.Twenty
  if self.teamMaxMemberType_ == E.ETeamMemberType.Five then
    self.isEndLoad_ = false
    Z.CoroUtil.create_coro_xpcall(function()
      self.teamModelList_ = {}
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
  else
    self.isEndLoad_ = true
    self:clearAllMod()
    self:getTeamGroupMemberInfo()
    for groupId, items in ipairs(self.memberGroupNodes20_) do
      for index, item in ipairs(items) do
        local memberInfo = self.teamGroupMemberInfos_[groupId][index]
        if memberInfo then
          self:setTwentyMemberItem(item, memberInfo)
        else
          item.Ref:SetVisible(item.img_profession, false)
          item.Ref:SetVisible(item.img_team, false)
          item.Ref:SetVisible(item.img_empty, true)
        end
      end
    end
  end
end

function Team_mineView:setTwentyMemberItem(item, memberInfo)
  if not item or not memberInfo then
    return
  end
  self.teamItem_[memberInfo.charId] = item
  local name = memberInfo.socialData.basicData.name
  local isOnLine = memberInfo.socialData.basicData.offlineTime == 0
  if memberInfo.charId == Z.ContainerMgr.CharSerialize.charId then
    name = Z.RichTextHelper.ApplyColorTag(name, "#ffd100")
  end
  local sceneName = ""
  local sceneData = Z.TableMgr.GetRow("SceneTableMgr", memberInfo.sceneId)
  if sceneData then
    sceneName = sceneData.Name
  end
  if not isOnLine then
    item.lab_name.text = Z.RichTextHelper.ApplyColorTag(name, grayColorKey)
    item.lab_level.text = Z.RichTextHelper.ApplyColorTag(Lang("LvFormatSymbol", {
      val = memberInfo.socialData.basicData.level
    }), grayColorKey)
    item.lab_area.text = Z.RichTextHelper.ApplyColorTag(sceneName, grayColorKey)
  else
    item.lab_name.text = name
    item.lab_level.text = Lang("LvFormatSymbol", {
      val = memberInfo.socialData.basicData.level
    })
    item.lab_area.text = sceneName
  end
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local isLeader = teamInfo.leaderId == memberInfo.charId
  item.Ref:SetVisible(item.img_leader, isLeader)
  playerPortraitHgr.InsertNewPortraitBySocialData(item.node_head_51_item, memberInfo.socialData, nil, self.cancelSource:CreateToken())
  item.Ref:SetVisible(item.img_team, true)
  item.Ref:SetVisible(item.img_empty, false)
  local professionId = memberInfo.socialData.professionData.professionId
  local professionSystemTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if professionSystemTableRow then
    item.img_profession:SetImage(professionSystemTableRow.Icon)
    item.Ref:SetVisible(item.img_profession, true)
  end
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

function Team_mineView:getMemberItemAndMemberDataByCharId(charId)
  local members = self.teamVM_.GetMemDataNotContainSelf()
  for index, member in ipairs(members) do
    if member.charId == charId then
      return self.node_members_[index], member
    end
  end
  return nil, nil
end

function Team_mineView:changeSceneGuid(memberInfo)
  if memberInfo == nil then
    return
  end
  local memberItem, teamMember = self:getMemberItemAndMemberDataByCharId(memberInfo.charId)
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
    local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(memberInfo.basicData.sceneId, true)
    if sceneRow then
      memberItem.lab_area.text = sceneRow.Name
    else
      memberItem.lab_area.text = ""
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

function Team_mineView:clearAllMod()
  if self.allUIModel then
    for i, v in pairs(self.allUIModel) do
      Z.UnrealSceneMgr:ClearModel(v)
    end
    self.allUIModel = {}
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
  self:clearAllMod()
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
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.setCompActive, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshSetting, self.setTeamSetting, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshSettingDes, self.setTeamDes, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneGuid, self.changeSceneGuid, self)
  Z.EventMgr:Add(Z.ConstValue.Team.ChangeSceneId, self.changeSceneGuid, self)
  Z.EventMgr:Add(Z.ConstValue.Team.OnLineState, self.setOnlineState, self)
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStateChange, self.onMatchStateChange, self)
end

return Team_mineView
