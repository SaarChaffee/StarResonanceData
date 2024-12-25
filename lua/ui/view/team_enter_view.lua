local UI = Z.UI
local super = require("ui.ui_view_base")
local Team_enterView = class("Team_enterView", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Team_enterView:ctor()
  self.uiBinder = nil
  super.ctor(self, "team_enter")
  self.selfIsLeader_ = false
  self.vm = Z.VMMgr.GetVM("team_enter")
  self.teamData_ = Z.DataMgr.Get("team_data")
  self.worldquestVM_ = Z.VMMgr.GetVM("worldquest")
  self.snapShotVM_ = Z.VMMgr.GetVM("snapshot")
end

function Team_enterView:initBinder()
  self.sceneMask_ = self.uiBinder.scenemask
  self.anim_ = self.uiBinder.anim
  self.lab_title_ = self.uiBinder.lab_title
  self.btn_confirm_ = self.uiBinder.btn_confirm
  self.btn_cancel_ = self.uiBinder.btn_cancel
  self.slider_ = self.uiBinder.slider_time
  self.lab_time_ = self.uiBinder.lab_time
  self.btn_node_ = self.uiBinder.btn_node
  self.layout_gruop_ = self.uiBinder.layout_gruop
  self.node_worldquest = self.uiBinder.node_worldquest
end

function Team_enterView:OnActive()
  self:initBinder()
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
  self.anim_:Restart(Z.DOTweenAnimType.Open)
  self.uiBinder.Ref:SetVisible(self.btn_node_, true)
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self:setViewInfo()
  Z.CoroUtil.create_coro_xpcall(function()
    self:setMemberInfo()
  end)()
  self:BindEvents()
end

function Team_enterView:OnDeActive()
  self.anim_:Play(Z.DOTweenAnimType.Close)
end

function Team_enterView:setViewInfo()
  local dungeonId = self.viewData.assignSceneParams.sceneId
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not dungeonCfg then
    return
  end
  self.lab_title_.text = dungeonCfg.DungeonTypeName
  self.uiBinder.lab_name.text = dungeonCfg.Name
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  self.selfIsLeader_ = teamInfo.leaderId == Z.ContainerMgr.CharSerialize.charBase.charId
  self:AddAsyncClick(self.btn_confirm_, function()
    if not self.teamVM_.CheckIsInTeam() then
      self.vm.CloseEnterView()
      return
    end
    self.vm.AsyncReplyJoinActivity(true, self.cancelSource:CreateToken())
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
  end, nil, nil)
  self:AddAsyncClick(self.btn_cancel_, function()
    if not self.teamVM_.CheckIsInTeam() then
      self.vm.CloseEnterView()
      return
    end
    if self.selfIsLeader_ then
      self.vm.AsyncTeamCancelActivity(self.cancelSource:CreateToken())
    else
      self.vm.AsyncReplyJoinActivity(false, self.cancelSource:CreateToken())
    end
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
    self.vm.CloseEnterView()
  end, nil, nil)
  self:AddClick(self.uiBinder.btn_label, function()
    self.vm.OpenAffixInfoView(self.viewData)
  end)
  self.uiBinder.Ref:SetVisible(self.btn_confirm_, not self.selfIsLeader_)
  self.uiBinder.Ref:SetVisible(self.node_worldquest, self.worldquestVM_.CheckIsWorldDungeonAndFinish(dungeonId))
  local teamActivity = self.viewData
  local useItem
  if teamActivity.dungeonInfo then
    useItem = teamActivity.dungeonInfo.useItem
  end
  local hasUseKey = useItem and useItem.uuid > 0
  local dungeonId = teamActivity.assignSceneParams.sceneId
  local affixList
  local hasAffix = false
  local dungeon_data = Z.DataMgr.Get("dungeon_data")
  local dungeonAffix = dungeon_data:GetDungeonAffixDic(dungeonId)
  if dungeonAffix and dungeonAffix.affixes then
    affixList = dungeonAffix.affixes
    hasAffix = 0 < table.zcount(affixList)
  end
  if hasUseKey then
    affixList = useItem.affixData.affixIds
    hasAffix = 0 < table.zcount(affixList)
  end
  self:SetUIVisible(self.uiBinder.btn_label, hasAffix)
  local lastTime = Z.Global.TeamApplyActivityLastTime
  self.slider_.value = lastTime
  self.slider_.maxValue = lastTime
  local sliderValue = lastTime
  self.timerMgr:StartFrameTimer(function()
    sliderValue = sliderValue - Time.deltaTime
    self.slider_.value = sliderValue
  end, 1, -1)
  self.lab_time_.text = lastTime .. Lang("EquipSecondsText")
  local time = 0
  self.timerMgr:StartTimer(function()
    time = time + 1
    self.lab_time_.text = lastTime - time .. Lang("EquipSecondsText")
    if time >= lastTime then
      if not self.teamVM_.CheckIsInTeam() then
        self.vm.CloseEnterView()
      end
      self.timerMgr:Clear()
    end
  end, 1, -1)
end

function Team_enterView:setMemberInfo()
  local teamActivity = self.viewData
  local useItem
  if teamActivity.dungeonInfo then
    useItem = teamActivity.dungeonInfo.useItem
  end
  local hasUseKey = useItem and useItem.uuid > 0
  local teamInfo = self.teamData_.TeamInfo.baseInfo
  local memberList = self.teamVM_.GetTeamMemData()
  local memberListCount = #memberList
  for i = 1, memberListCount do
    local memberInfo = memberList[i]
    local charId = memberInfo.charId
    local memberItem = self:AsyncLoadUiUnit(GetLoadAssetPath(Z.ConstValue.Team.EnterPlayTpl), "member" .. charId, self.layout_gruop_.transform)
    local isLeader = charId == teamInfo.leaderId
    memberItem.Ref:SetVisible(memberItem.img_leader, isLeader)
    local memberSocialData = memberInfo.socialData
    memberItem.Ref:SetVisible(memberItem.img_select, isLeader)
    memberItem.Ref:SetVisible(memberItem.cont_login, not isLeader)
    memberItem.Ref:SetVisible(memberItem.lab_tips, hasUseKey == true)
    memberItem.Ref:SetVisible(memberItem.img_line_1, i < memberListCount)
    if hasUseKey then
      local limitID, limitCount, curCount, str
      if isLeader then
        limitID = Z.Global.KeyRewardLimitId
        limitCount = Z.CounterHelper.GetCounterLimitCount(limitID)
        curCount = limitCount - teamActivity.awardCountInfo[charId].keyAwardCount
        str = Lang("RewardKey")
      else
        limitID = Z.Global.RollRewardLimitId
        limitCount = Z.CounterHelper.GetCounterLimitCount(limitID)
        curCount = limitCount - teamActivity.awardCountInfo[charId].rollAwardCount
        str = Lang("RewardRoll")
      end
      local strType = curCount == 0 and E.TextStyleTag.Red or E.TextStyleTag.White
      local numStr = Z.RichTextHelper.ApplyStyleTag(tostring(curCount), strType)
      str = str .. " " .. numStr .. "/" .. limitCount
      memberItem.lab_tips.text = str
    end
    if memberSocialData then
      memberItem.lab_name.text = memberSocialData.basicData.name
      self:setHalfPortraitPImg(memberInfo, memberSocialData, memberItem)
    end
  end
end

function Team_enterView:setHalfPortraitPImg(memberInfo, memberSocialData, memberItem)
  memberItem.Ref:SetVisible(memberItem.img_idcard, false)
  memberItem.Ref:SetVisible(memberItem.rimg_idcard, false)
  local modelId = 0
  if memberInfo.isAi then
    local botAiId = memberSocialData.basicData.botAiId
    local botAiTableRow = Z.TableMgr.GetRow("BotAITableMgr", botAiId)
    if botAiTableRow then
      modelId = botAiTableRow.ModelID
      local path = self.snapShotVM_.GetModelHalfPortrait(modelId)
      if path ~= nil then
        memberItem.Ref:SetVisible(memberItem.img_idcard, true)
        memberItem.img_idcard:SetImage(path)
      end
    end
  else
    modelId = Z.ModelManager:GetModelIdByGenderAndSize(memberSocialData.basicData.gender, memberSocialData.basicData.bodySize)
    local path = self.snapShotVM_.GetInternalHalfPortrait(memberInfo.charId, modelId)
    if path ~= nil then
      if type(path) == "number" then
        memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
        memberItem.rimg_idcard:SetNativeTexture(path)
      else
        memberItem.Ref:SetVisible(memberItem.img_idcard, true)
        memberItem.img_idcard:SetImage(path)
      end
    end
    local headId, charId = self.snapShotVM_.AsyncGetHttpHalfPortraitId(memberInfo.charId)
    if not self.uiBinder then
      return
    end
    if charId == memberInfo.charId and headId ~= nil and headId ~= 0 then
      memberItem.Ref:SetVisible(memberItem.img_idcard, false)
      memberItem.Ref:SetVisible(memberItem.rimg_idcard, true)
      memberItem.rimg_idcard:SetNativeTexture(headId)
    end
  end
end

function Team_enterView:teamRefreshActivityVoteResult(resultData)
  if resultData == nil then
    return
  end
  local unit = self.units["member" .. resultData.charId]
  if unit then
    unit.Ref:SetVisible(unit.img_select, resultData.isAgree)
    unit.Ref:SetVisible(unit.cont_login, not resultData.isAgree)
  end
end

function Team_enterView:refreshTeamActivityVoteResult()
  local data = self.teamData_:GetMemberReadyState()
  if not data then
    return
  end
  for _, resultData in pairs(data) do
    local unit = self.units["member" .. resultData.charId]
    if unit then
      local isAgree = resultData.readyStatus == E.RedayType.Ready or self.selfIsLeader_
      unit.Ref:SetVisible(unit.img_select, isAgree)
      unit.Ref:SetVisible(unit.cont_login, not isAgree)
    end
  end
end

function Team_enterView:hideActivityLeaderCancelBtn()
  if self.selfIsLeader_ then
    self.uiBinder.Ref:SetVisible(self.btn_node_, false)
  end
end

function Team_enterView:removeTeamMen(charId)
  if self.units and self.units["member" .. charId] then
    self:RemoveUiUnit("member" .. charId)
  end
end

function Team_enterView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Team.HideActivityLeaderCancelBtn, self.hideActivityLeaderCancelBtn, self)
  Z.EventMgr:Add("removeTeamMen", self.removeTeamMen, self)
  Z.EventMgr:Add(Z.ConstValue.Team.RefreshActivityVoteResult, self.refreshTeamActivityVoteResult, self)
  Z.EventMgr:Add(Z.ConstValue.Team.TeamRefreshActivityVoteResult, self.teamRefreshActivityVoteResult, self)
end

function Team_enterView:OnRefresh()
end

return Team_enterView
