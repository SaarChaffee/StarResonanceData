local super = require("ui.ui_view_base")
local Union_unlockscene_mainView = class("Union_unlockscene_mainView", super)
local playerPortraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Union_unlockscene_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_unlockscene_main")
  self.unionVM_ = Z.VMMgr.GetVM("union")
end

function Union_unlockscene_mainView:OnActive()
  self:initBaseData()
  self:initBinders()
  Z.CoroUtil.create_coro_xpcall(function()
    self.socialData_ = self.socialVm_.AsyncGetSocialData(0, Z.EntityMgr.PlayerEnt.EntId, self.cancelSource:CreateToken())
    if self.socialData_ and self.lastSelectItem_ then
      self:refreshSelectItem(self.lastSelectItem_)
    end
    local ret = self.unionVM_:AsyncGetUnlockUnionSceneData(self.cancelSource:CreateToken())
    self:refreshMemberList()
    self:refreshUnlockInfo()
  end)()
end

function Union_unlockscene_mainView:OnDeActive()
  self.lastSelectItem_ = nil
  self.socialVm_ = nil
  self.snapshotVm_ = nil
  self.baseData_ = nil
  if self.countTimer_ then
    self.timerMgr:StopTimer(self.countTimer_)
    self.countTimer_ = nil
  end
end

function Union_unlockscene_mainView:OnRefresh()
end

function Union_unlockscene_mainView:initBinders()
  self:AddAsyncClick(self.uiBinder.btn_attend, function()
    if self.currentSelectItemIndex_ > 0 then
      local ret = self.unionVM_:AsyncUnlockUnionScene(self.currentSelectItemIndex_ - 1, self.cancelSource:CreateToken())
      if ret == 0 then
        self:onAttendSuccess()
      end
    else
      Z.TipsVM.ShowTips(1000583)
    end
  end)
  self:AddClick(self.uiBinder.btn_close_new, function()
    self.unionVM_:CloseUnionUnlockSceneView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_share, function()
    local chatMainVm = Z.VMMgr.GetVM("chat_main")
    local isSuccess = chatMainVm.AsyncSendShare(E.ChatChannelType.EChannelUnion, 6, self.cancelSource:CreateToken())
    if isSuccess then
      Z.TipsVM.ShowTips(1000584)
    end
  end)
  self.uiBinder.btn_attend.IsDisabled = self.currentSelectItemIndex_ == 0
end

function Union_unlockscene_mainView:initBaseData()
  self.maxMemberCount_ = Z.Global.UnionunlocksceneNum
  self.currentSelectItemIndex_ = 0
  self.lastSelectItem_ = nil
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.snapshotVm_ = Z.VMMgr.GetVM("snapshot")
  self.baseData_ = Z.ContainerMgr.CharSerialize.charBase
end

function Union_unlockscene_mainView:refreshSelectItem(item)
  if self.lastSelectItem_ then
    self.lastSelectItem_.Ref:SetVisible(self.lastSelectItem_.img_on, false)
    self.lastSelectItem_.Ref:SetVisible(self.lastSelectItem_.node_round, false)
    self.lastSelectItem_.Ref:SetVisible(self.lastSelectItem_.lab_add, true)
    self.lastSelectItem_.Ref:SetVisible(self.lastSelectItem_.lab_name, false)
  end
  item.Ref:SetVisible(item.img_on, true)
  item.Ref:SetVisible(item.node_round, true)
  item.Ref:SetVisible(item.lab_add, false)
  item.Ref:SetVisible(item.lab_name, true)
  local colorType = E.TextStyleTag.UnionUnlockYellow
  item.lab_name.text = Z.RichTextHelper.ApplyStyleTag(self.baseData_.name, colorType)
  if self.socialData_ then
    self:getAvatarImgBySocialData(item, self.socialData_)
  end
  self.lastSelectItem_ = item
end

function Union_unlockscene_mainView:refreshMemberList()
  self.memberList_ = self.unionVM_:GetUnionSceneUnlockMembers()
  for i = 1, self.maxMemberCount_ do
    local d = self.memberList_[i]
    local hasData = d ~= nil
    local item = self.uiBinder[string.format("union_unlockscene_avatar_%02d", i)]
    self:AddClick(item.btn_avatar, function()
      if hasData == false then
        if self.unionVM_:GetHasJoinUnionSceneUnlock() == false then
          self.currentSelectItemIndex_ = i
          self:refreshSelectItem(item)
          self.uiBinder.btn_attend.IsDisabled = self.currentSelectItemIndex_ == 0
        end
      else
        Z.CoroUtil.create_coro_xpcall(function()
          local idCardVM = Z.VMMgr.GetVM("idcard")
          idCardVM.AsyncGetCardData(d.basicAvatarData.basicData.charID, self.cancelSource:CreateToken())
        end)()
      end
    end)
    item.Ref:SetVisible(item.img_on, false)
    item.Ref:SetVisible(item.node_round, hasData)
    item.Ref:SetVisible(item.lab_add, hasData == false)
    item.Ref:SetVisible(item.lab_name, hasData == true)
    if hasData then
      do
        local socialData = d.basicAvatarData
        local name = socialData.basicData.name
        if socialData.basicData.charID == self.baseData_.charId then
          local colorType = E.TextStyleTag.UnionUnlockYellow
          name = Z.RichTextHelper.ApplyStyleTag(name, colorType)
        end
        item.lab_name.text = name
        self:getAvatarImgBySocialData(item, socialData)
      end
    end
  end
end

function Union_unlockscene_mainView:getAvatarImgBySocialData(item, socialData)
  local modelId = self.socialVm_.GetModelId(socialData)
  local textureId
  if socialData.avatarInfo and socialData.avatarInfo.avatarId then
    textureId = socialData.avatarInfo.avatarId
  end
  local viewData = {}
  viewData.id = textureId
  viewData.modelId = modelId
  viewData.charId = socialData.basicData.charID
  viewData.token = self.cancelSource:CreateToken()
  playerPortraitMgr.InsertNewPortrait(item, viewData)
end

function Union_unlockscene_mainView:refreshUnlockInfo()
  local isInUnlock, state, leftTime = self.unionVM_:GetUnionSceneIsUnlock()
  local memberCount = self.unionVM_:GetUnionSceneUnlockProgress()
  local progress = memberCount / self.maxMemberCount_
  self.uiBinder.lab_figure.text = memberCount .. "/" .. self.maxMemberCount_
  self.uiBinder.img_schedule.fillAmount = progress
  local isEnough = state == E.UnionUnlockState.WaitBuildEnd or isInUnlock == true
  self:SetUIVisible(self.uiBinder.node_time, isEnough == false)
  self:SetUIVisible(self.uiBinder.node_unlock, isEnough)
  local hasAttend = self.unionVM_:GetHasJoinUnionSceneUnlock()
  if isEnough then
    self:SetUIVisible(self.uiBinder.node_await, not isInUnlock)
    self:SetUIVisible(self.uiBinder.node_complete, isInUnlock)
    if 0 < leftTime then
      local nowTime = math.floor(Z.TimeTools.Now() / 1000)
      if leftTime > nowTime then
        if self.countTimer_ then
          self.timerMgr:StopTimer(self.countTimer_)
          self.countTimer_ = nil
        end
        self.countTimer_ = self.timerMgr:StartTimer(function()
          local nowTimes = math.floor(Z.TimeTools.Now() / 1000)
          local time = leftTime - nowTimes
          if 0 < time then
            self.uiBinder.lab_time.text = Lang("UnionSenceUnlock") .. Z.TimeFormatTools.FormatToDHMS(time, true)
          else
            self.timerMgr:StopTimer(self.countTimer_)
            self.countTimer_ = nil
            self:SetUIVisible(self.uiBinder.node_await, false)
            self:SetUIVisible(self.uiBinder.node_complete, true)
          end
        end, 1, -1)
      end
    end
  else
    self:SetUIVisible(self.uiBinder.btn_attend, hasAttend == false)
    self.uiBinder.lab_time.text = Lang("UnionSenceUnlock") .. Z.TimeFormatTools.FormatToDHMS(Z.Global.UnionunlocksceneBuildingTime, true)
  end
  self:SetUIVisible(self.uiBinder.node_label, isEnough == false or hasAttend == false)
  self:SetUIVisible(self.uiBinder.node_share, hasAttend)
end

function Union_unlockscene_mainView:onAttendSuccess()
  Z.TipsVM.ShowTips(1000581)
  local isInUnlock, state, leftTime = self.unionVM_:GetUnionSceneIsUnlock()
  local isEnough = state == E.UnionUnlockState.WaitBuildEnd
  if isEnough then
    self.unionVM_:OpenUnionUnlockSceneSuccessView()
  end
  if self.lastSelectItem_ then
    self.lastSelectItem_.Ref:SetVisible(self.lastSelectItem_.img_on, false)
    self:refreshUnlockInfo()
  end
end

return Union_unlockscene_mainView
