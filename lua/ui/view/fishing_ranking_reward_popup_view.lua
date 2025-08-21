local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_ranking_reward_popupView = class("Fishing_ranking_reward_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local fishingRankingLoopItem = require("ui.component.fishing.fishing_ranking_reward_item")

function Fishing_ranking_reward_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_ranking_reward_popup")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  self.fishingVM_ = Z.VMMgr.GetVM("fishing")
end

function Fishing_ranking_reward_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    self.fishingVM_.CloseRankingAwardPopup()
  end)
  self:initViewList()
  if not self.timer then
    self:startTimer()
  end
end

function Fishing_ranking_reward_popupView:OnDeActive()
  self.loopLevelListView_:UnInit()
  self.loopLevelListView_ = nil
  self:stopTime()
end

function Fishing_ranking_reward_popupView:OnRefresh()
  self.fishId_ = self.viewData.fishId
  self.showWorld_ = self.viewData.isWorld
  local fishingRankRewards = self.fishingData_:GetFishingRankRewardsData(self.fishId_, self.showWorld_)
  self.loopLevelListView_:RefreshListView(fishingRankRewards)
end

function Fishing_ranking_reward_popupView:initViewList()
  self.loopLevelListView_ = loopListView.new(self, self.uiBinder.loop_list_fish, fishingRankingLoopItem, "fishing_ranking_list_reward_item_tpl")
  self.loopLevelListView_:Init({})
end

function Fishing_ranking_reward_popupView:startTimer()
  local hasEnd, _, endTime = Z.TimeTools.GetCycleStartEndTimeByTimeId(Z.Global.FishRankResetTimerId)
  if not hasEnd then
    return
  end
  if not self.timer then
    self.timer = self.timerMgr:StartTimer(function()
      self:countdownTime(endTime)
    end, 1, -1)
  end
end

function Fishing_ranking_reward_popupView:countdownTime(endTime)
  local dTime = math.floor(endTime - Z.ServerTime:GetServerTime() / 1000)
  local time = Z.TimeFormatTools.FormatToDHMS(dTime)
  self.uiBinder.lab_time.text = Lang("FishingRankResetTime", {val = time})
end

function Fishing_ranking_reward_popupView:stopTime()
  if self.timer then
    self.timerMgr:StopTimer(self.timer)
    self.timer = nil
  end
end

return Fishing_ranking_reward_popupView
