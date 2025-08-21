local UI = Z.UI
local super = require("ui.ui_subview_base")
local Parkour_tooltip_single_windowView = class("Parkour_tooltip_single_windowView", super)
local rankingView = require("ui.view.parkour_ranking_tpl_view")
local rankingPath = {
  [1] = "ui/prefabs/parkour/parkour_ranking_tpl_pc",
  [2] = "ui/prefabs/parkour/parkour_ranking_tpl"
}

function Parkour_tooltip_single_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "parkour_tooltip_single_window", "parkour/parkour_tooltip_single_window", UI.ECacheLv.None)
  self.rankingPrefab = nil
  self.viewData = nil
  self.timeLimitVM_ = Z.VMMgr.GetVM("quest_time_limit")
end

function Parkour_tooltip_single_windowView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.endAudioIsPlaying = false
  self:BindEvents()
end

function Parkour_tooltip_single_windowView:ClearAll()
  self.timerMgr:Clear()
  if self.rankingPrefab then
    self.rankingPrefab.lab_time.ParkourTime:EndTime()
    self.rankingPrefab:DeActive()
    self:RemoveUiUnit(self.rankingPrefab.name)
    self.rankingPrefab = nil
  end
end

function Parkour_tooltip_single_windowView:OnDeActive()
  self:ClearAll()
  self.endAudioIsPlaying = false
end

function Parkour_tooltip_single_windowView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.TimeLimitQuestEnd, self.onTimeLimitQuestEnd, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.StepLimitTimeChange, self.onTimeLimitQuestGoing, self)
  Z.EventMgr:Add(Z.ConstValue.Quest.TrackingIdChange, self.onQuestTrackingIdChange, self)
end

function Parkour_tooltip_single_windowView:onQuestTrackingIdChange(questId)
  if questId <= 0 then
    self:CloseParkourSingleView()
  else
    self:TimeLimitQuestStart()
  end
end

function Parkour_tooltip_single_windowView:onTimeLimitQuestEnd()
  local quest = self.timeLimitVM_.GetTrackingQuestInTimeLimitStep(true)
  if not quest then
    self:CloseParkourSingleView()
    return
  end
  local delayTime = 0
  local stepStatus = quest.stepStatus
  self.uiBinder.countdown_audio:Stop()
  local questData = Z.DataMgr.Get("quest_data")
  local messageIds = questData:GetQuestTimeLimitMessageId(quest.id)
  if stepStatus then
    self:StopAudio()
    self:ClearAll()
    if stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepFail") then
      self.uiBinder.fail_audio:Play()
      Z.TipsVM.ShowTipsLang(messageIds.failMessageId)
      self.endAudioIsPlaying = true
    end
    if stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepFinish") then
      self.uiBinder.success_audio:Play()
      Z.TipsVM.ShowTipsLang(messageIds.succeedMessageId)
      self.endAudioIsPlaying = true
    end
    delayTime = 0.8
  end
  self.timerMgr:StartTimer(function()
    self.endAudioIsPlaying = false
    self:CloseParkourSingleView()
  end, delayTime)
end

function Parkour_tooltip_single_windowView:onTimeLimitQuestGoing(quest)
  if not quest then
    return
  end
  local stepStatus = quest.stepStatus
  self.uiBinder.countdown_audio:Stop()
  if stepStatus then
    self:StopAudio()
    if stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepGoing") then
      self:SetCountDown(quest.addLimitTime)
    end
  end
end

function Parkour_tooltip_single_windowView:StopAudio()
  self.uiBinder.countdown_audio:Stop()
end

function Parkour_tooltip_single_windowView:OnRefresh()
  if not self.rankingPrefab then
    Z.CoroUtil.create_coro_xpcall(function()
      self:InitSubView()
      self:TimeLimitQuestStart()
    end)()
  else
    self:TimeLimitQuestStart()
  end
end

function Parkour_tooltip_single_windowView:TimeLimitQuestStart()
  local quest = self.timeLimitVM_.GetTrackingQuestInTimeLimitStep()
  if not quest then
    self:CloseParkourSingleView()
    return
  end
  self.timerMgr:Clear()
  local questData = Z.DataMgr.Get("quest_data")
  local row = questData:GetStepConfigByStepId(quest.stepId)
  if row == nil or row.StepTargetInfo == nil or row.StepTargetInfo[1] == nil then
    return
  end
  if self.viewData then
    Z.TipsVM.ShowTips(16002001)
  end
  if self.rankingPrefab then
    self.rankingPrefab.node_time:SetVisible(true)
    self.uiBinder.begin_audio:Play()
    self:SetCountDown()
  end
end

function Parkour_tooltip_single_windowView:SetCountDown(addLimitTime)
  local quest = self.timeLimitVM_.GetTrackingQuestInTimeLimitStep()
  if not quest then
    self:CloseParkourSingleView()
    return
  end
  if quest.stepLimitTime <= 0 or not self.rankingPrefab then
    return
  end
  local timeLimitNumber = Z.Global.TimeLimitQuestAlert
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local t = quest.stepLimitTime - nowTime
  if t <= 0 then
    self.rankingPrefab.lab_time.ParkourTime:EndTime()
    return
  end
  self.rankingPrefab.lab_time.ParkourTime:StartTime(quest.stepLimitTime, tonumber(timeLimitNumber), self.uiBinder.countdown_audio)
end

function Parkour_tooltip_single_windowView:InitSubView()
  local compName = "parkour_time_prepare_tpl_view"
  local index = Z.GameContext.IsPC and 1 or 2
  local uiUnit_ = self:AsyncLoadUiUnit(rankingPath[index], compName, self.uiBinder.trans_rangking, self.cancelSource:CreateToken())
  self.rankingPrefab = rankingView.new()
  self.rankingPrefab:Init(uiUnit_.Go, compName)
  self.rankingPrefab:SetRankingNodeIsOpen(false)
  self.rankingPrefab.node_time:SetVisible(false)
end

function Parkour_tooltip_single_windowView:CloseParkourSingleView()
  if not self.endAudioIsPlaying then
    self:DeActive()
  end
end

return Parkour_tooltip_single_windowView
