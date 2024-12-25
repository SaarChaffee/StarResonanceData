local QuestTrackComp = require("ui.component.quest.quest_track_comp")
local UI = Z.UI
local super = require("ui.ui_subview_base")
local Quest_trackView = class("Quest_trackView", super)

function Quest_trackView:ctor()
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "main/track/quest_track_sub_pc" or "main/track/quest_track_sub"
  super.ctor(self, "quest_track_sub", assetPath, UI.ECacheLv.None)
  self.questVM_ = Z.VMMgr.GetVM("quest")
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.trackCompList_ = {}
  for i = 1, 2 do
    self.trackCompList_[i] = QuestTrackComp.new(self)
  end
end

function Quest_trackView:OnActive()
  self.stateTimer_ = nil
  self.stateQueue_ = {}
  self.stateData_ = nil
  self:RefreshTrackOptionShow()
  if self.questData_:IsInForceTrack() then
    self.trackCompList_[1]:Init(self.uiBinder.binder_track_1, self.questData_:GetQuestTrackingId())
    self.trackCompList_[2]:Init(self.uiBinder.binder_track_2, 0)
  elseif self.showTrackOptional then
    for i = 1, #self.trackCompList_ do
      local questId
      if self.questData_.QuestMgrStage < E.QuestMgrStage.LoadEnd then
        questId = 0
      else
        questId = self.questData_:GetTrackOptionalIdByIndex(i)
      end
      local container = self.uiBinder["binder_track_" .. i]
      self.trackCompList_[i]:Init(container, questId)
    end
  else
    for i = 1, #self.trackCompList_ do
      local container = self.uiBinder["binder_track_" .. i]
      self.trackCompList_[i]:Init(container, 0)
    end
  end
  self:enableTimeLimitUI(true)
  self.uiBinder.btn_tip_bg:AddListener(function()
    self:onClickQuestTip()
  end)
  self:refreshTipState()
  self:bindEvents()
end

function Quest_trackView:OnDeActive()
  for i = 1, #self.trackCompList_ do
    self.trackCompList_[i]:UnInit()
  end
  self.stateTimer_ = nil
  self.stateQueue_ = nil
  self.stateData_ = nil
  self.showTrackOptional = true
end

function Quest_trackView:addTipState(questId, viewState)
  local isNeedAdd = true
  for _, data in pairs(self.stateQueue_) do
    if data.questId == questId and data.viewState == viewState then
      isNeedAdd = false
    end
  end
  if not isNeedAdd then
    return
  end
  table.insert(self.stateQueue_, {questId = questId, viewState = viewState})
  self:refreshTipState()
end

function Quest_trackView:refreshTipState()
  self.uiBinder.effect:SetEffectGoVisible(false)
  if #self.stateQueue_ == 0 then
    self.stateData_ = nil
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_tip, false)
    return
  end
  local stateData = self.stateQueue_[1]
  if self.stateData_ and self.stateData_.questId == stateData.questId and self.stateData_.viewState == stateData.viewState then
    return
  end
  self.stateData_ = stateData
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_quest_tip, true)
  self.uiBinder.effect:SetEffectGoVisible(true)
  local name = ""
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(stateData.questId)
  if questRow then
    name = questRow.QuestName
  end
  self.uiBinder.lab_quest_name.text = name
  if stateData.viewState == E.QuestTrackViewState.Accept then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_new, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_update, false)
  elseif stateData.viewState == E.QuestTrackViewState.StateChange then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_new, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_update, true)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  elseif stateData.viewState == E.QuestTrackViewState.StepChange then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_new, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_update, true)
    self.uiBinder.anim:Play(Z.DOTweenAnimType.Open)
  end
  self.uiBinder.img_sliced.fillAmount = 1
  self.uiBinder.dotween_sliced:DoImageFillAmount(0, 3)
  self.stateTimer_ = self.timerMgr:StartTimer(function()
  end, 3, 1, nil, function()
    self.stateTimer_ = nil
    table.remove(self.stateQueue_, 1)
    self:refreshTipState()
  end)
end

function Quest_trackView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackingIdChange, self.onTrackingIdChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackOptionChange, self.onTrackOptionChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.Accept, self.onQuestAccept, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StateChange, self.onQuestStateChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepChange, self.onQuestStepChange, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.Finish, self.onQuestFinish, self)
  Z.EventMgr:Add(Z.ConstValue.TimeLimitQuestAccept, self.onTimeLimitAccept, self)
  Z.EventMgr:Add(Z.ConstValue.InputTrackQuestKey, self.onClickQuestTip, self)
end

function Quest_trackView:onTimeLimitAccept(questId)
  self:enableTimeLimitUI(true, true)
  local trackComp = self:getTrackCompByQuestId(questId)
  if trackComp then
    trackComp:ForceShowQuestTrackDetail()
  end
end

function Quest_trackView:onTrackingIdChange()
  if self.questData_:IsInForceTrack() then
    self.trackCompList_[1]:SetTrackingId(self.questData_:GetQuestTrackingId())
    self.trackCompList_[2]:SetTrackingId(0)
  elseif self.showTrackOptional then
    for i = 1, #self.trackCompList_ do
      local questId
      if self.questData_.QuestMgrStage < E.QuestMgrStage.LoadEnd then
        questId = 0
      else
        questId = self.questData_:GetTrackOptionalIdByIndex(i)
      end
      self.trackCompList_[i]:SetTrackingId(questId)
      self.trackCompList_[i]:RefreshCurrentTrackUI()
    end
  end
  self:enableTimeLimitUI(true)
end

function Quest_trackView:onTrackOptionChange(index, questId)
  if self.questData_:IsInForceTrack() then
    return
  end
  if not self.showTrackOptional then
    return
  end
  self.trackCompList_[index]:SetTrackingId(questId)
end

function Quest_trackView:onQuestAccept(questId)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(questId)
  if questRow then
    local typeId = questRow.QuestType
    local questTypeRow = Z.TableMgr.GetTable("QuestTypeTableMgr").GetRow(typeId)
    if questTypeRow and questTypeRow.QuestTypeGroupID == E.QuestTypeGroup.WorldEvent then
      return
    end
  end
  self:addTipState(questId, E.QuestTrackViewState.Accept)
end

function Quest_trackView:onQuestStateChange(questId, oldState, newState)
  if oldState == E.QuestState.NotEnough then
    local trackComp = self:getTrackCompByQuestId(questId)
    if not trackComp then
      self:addTipState(questId, E.QuestTrackViewState.StateChange)
    end
  end
end

function Quest_trackView:getTrackCompByQuestId(id)
  for i = 1, #self.trackCompList_ do
    if self.trackCompList_[i]:GetTrackingId() == id then
      return self.trackCompList_[i]
    end
  end
end

function Quest_trackView:onQuestStepChange(questId, stepId)
  local stepRow = self.questData_:GetStepConfigByStepId(stepId)
  if stepRow and #stepRow.StepTargetInfo > 0 then
    local trackComp = self:getTrackCompByQuestId(questId)
    if trackComp then
      trackComp:AddTrackState(questId, E.QuestTrackViewState.StepChange)
    else
      self:addTipState(questId, E.QuestTrackViewState.StepChange)
    end
  end
  self:enableTimeLimitUI(true, true)
end

function Quest_trackView:onQuestFinish(questId)
  local trackComp = self:getTrackCompByQuestId(questId)
  if trackComp then
    trackComp:AddTrackState(questId, E.QuestTrackViewState.Finish)
  end
end

function Quest_trackView:onClickQuestTip()
  if self.stateData_ then
    local questTrackVM = Z.VMMgr.GetVM("quest_track")
    if questTrackVM.CheckIsAllowReplaceTrack(true) then
      questTrackVM.ReplaceAndTrackingQuest(self.stateData_.questId)
    end
  else
    for i = 1, #self.trackCompList_ do
      self.trackCompList_[i]:OnInputTrackQuestKeyPressed()
    end
  end
end

function Quest_trackView:RefreshTrackOptionShow()
  self.showTrackOptional = true
  if Z.StageMgr.GetCurrentStageType() == Z.EStageType.Dungeon or Z.StageMgr.GetCurrentStageType() == Z.EStageType.MirrorDungeon then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if dungeonsTable and dungeonsTable.HideQuest == 1 then
      self.showTrackOptional = false
    end
  end
end

function Quest_trackView:enableTimeLimitUI(isEnable, isFirstOpen)
  local questTimeLimitVM = Z.VMMgr.GetVM("quest_time_limit")
  local parkourData
  local quest = questTimeLimitVM.GetTrackingQuestInTimeLimitStep(false)
  if quest == nil then
    return
  end
  local stepTimeLimitInfo = questTimeLimitVM.GetQuestStepTimeLimitInfo(quest)
  if stepTimeLimitInfo == nil or not stepTimeLimitInfo.IsShowUI then
    return
  end
  self.questData_:SetQuestTimeLimitMessageId(quest.id, stepTimeLimitInfo.FailMessageId, stepTimeLimitInfo.SucceedMessageId)
  if isEnable then
    parkourData = {isOpenView = true, isFirstOpen = isFirstOpen}
  else
    parkourData = {isOpenView = false}
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.SetParkourSingleActive, parkourData)
end

return Quest_trackView
