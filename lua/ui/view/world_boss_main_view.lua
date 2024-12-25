local UI = Z.UI
local super = require("ui.ui_view_base")
local World_boss_mainView = class("World_boss_mainView", super)
local loopGridView = require("ui.component.loop_grid_view")
local commonRewardItem = require("ui.component.common_reward_grid_list_item")

function World_boss_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "world_boss_main")
end

function World_boss_mainView:OnActive()
  self:InitBinders()
  self:initBtnFunc()
  self:initLoopView()
  self:InitActivityData()
  self:BindEvents()
  Z.CoroUtil.create_coro_xpcall(function()
    self.worldBossVM_:AsyncGetWorldBossInfo(self.cancelSource:CreateToken(), function(ret)
      self:RefreshActivityState(ret)
    end)
  end)()
  local awardId = Z.WorldBoss.WorldBossPreviewAward
  self:RefreshRewardList(awardId)
  self:RefreshRightInfo()
  self:RefreshMatchState(E.MatchType.WorldBoss)
end

function World_boss_mainView:OnDeActive()
  self:unInitLoopView()
  Z.EventMgr:RemoveObjAll(self)
end

function World_boss_mainView:OnRefresh()
end

function World_boss_mainView:InitBinders()
  self.labTitle_ = self.uiBinder.lab_title_name
  self.labCompanion_ = self.uiBinder.lab_companion
  self.labInfo_ = self.uiBinder.lab_info
  self.labTime_ = self.uiBinder.lab_time
  self.labAwardNum_ = self.uiBinder.lab_award_num
  self.imgBG = self.uiBinder.rimg_bg
  self.btnInfo_ = self.uiBinder.btn_info
  self.btnGo_ = self.uiBinder.btn_go
  self.nodeReward_ = self.uiBinder.node_reward_item
  self.tipsRelativeTo_ = self.imgBG.transform
end

function World_boss_mainView:initLoopView()
  local dataList = {}
  self.loopRewardView_ = loopGridView.new(self, self.uiBinder.loopscroll_reward, commonRewardItem, "com_item_square_8")
  self.loopRewardView_:Init(dataList)
end

function World_boss_mainView:initBtnFunc()
  self:AddAsyncClick(self.btnGo_, function()
    local func = function()
      local param = {}
      local teamVM_ = Z.VMMgr.GetVM("team")
      self.matchVm_.AsyncBeginMatchNew(E.MatchType.WorldBoss, param, teamVM_.CheckIsInTeam(), self.cancelSource:CreateToken())
    end
    local countID = Z.WorldBoss.WorldBossAwardCountId
    local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
    local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
    if normalAwardCount == 0 then
      Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("WorldBossLimitOver"), func, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.WorldBossMatch)
    else
      func()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    local matchData = Z.DataMgr.Get("match_data")
    self.matchVm_.AsyncCancelMatchNew(E.MatchType.WorldBoss, false, matchData.CancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_team, function()
    self.teamMainVM_.OpenTeamMainView(self.teamTargetId_)
  end)
  self:AddClick(self.btnInfo_, function()
    Z.VMMgr.GetVM("helpsys").OpenFullScreenTipsView(30101)
  end)
  self:AddClick(self.uiBinder.btn_integral, function()
    self.worldBossVM_:OpenWorldBossScoreView()
  end)
  self:AddClick(self.uiBinder.btn_schedule, function()
    self.worldBossVM_:OpenWorldBossScheduleView()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.worldBossVM_.CloseWorldBossMainView()
  end)
end

function World_boss_mainView:unInitLoopView()
  self.loopRewardView_:UnInit()
  self.loopRewardView_ = nil
end

function World_boss_mainView:InitActivityData()
  self.itemClassTab_ = {}
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.matchVm_ = Z.VMMgr.GetVM("match")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.awardVM_ = Z.VMMgr.GetVM("awardpreview")
  self.teamMainVM_ = Z.VMMgr.GetVM("team_main")
  self.itemUnit = {}
  self.maxNum = 0
  self.teamTargetId_ = 0
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WorldBossScoreRed, self, self.uiBinder.btn_integral.transform)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.WorldBossProgressRed, self, self.uiBinder.btn_schedule.transform)
end

function World_boss_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStartTimeChange, self.RefreshMatchState, self)
  Z.EventMgr:Add(Z.ConstValue.WorldBoss.WorldBossActivityEnd, self.onActivityEnd, self)
end

function World_boss_mainView:RefreshRewardList(rewardID)
  local awardList_ = {}
  if 0 < rewardID then
    awardList_ = self.awardVM_.GetAllAwardPreListByIds(rewardID)
  end
  self.loopRewardView_:RefreshListView(awardList_)
end

function World_boss_mainView:RefreshActivityState(ret)
  self.uiBinder.lab_num.text = ret.bossStage
end

function World_boss_mainView:RefreshRightInfo()
  local timeId = Z.WorldBoss.WorldBossOpenTimerId
  local countID = Z.WorldBoss.WorldBossAwardCountId
  local limtCount = Z.CounterHelper.GetCounterLimitCount(countID)
  local normalAwardCount = Z.CounterHelper.GetCounterResidueLimitCount(countID, limtCount)
  local langString = Lang("WorldBossAward")
  self.labAwardNum_.text = langString .. normalAwardCount .. "/" .. limtCount
  local seasonVm = Z.VMMgr.GetVM("season")
  local actConfig = seasonVm.GetSeasonActConfigByFuncId(800902)
  if actConfig == nil then
    return
  end
  self.labTitle_.text = actConfig.Name
  self.labInfo_.text = actConfig.ActDes
  self.labTime_.text = actConfig.OtherDes
  local startTimeList, endTimeList = Z.TimeTools.GetCycleTimeDataByTimeId(timeId)
  local strTable = {}
  for _, value in ipairs(startTimeList) do
    local strResult = Z.TimeTools.FormatToWDHM(value)
    table.insert(strTable, strResult)
  end
  local timeStr_ = table.zconcat(strTable, ",")
  local str = timeStr_ .. Lang("WorldBossOpenTime")
  self.labCompanion_.text = str
  local leftTime_, beforeLeftTime = Z.TimeTools.GetTimeLeftInSpecifiedTime(timeId)
  local curLeftTime = beforeLeftTime
  local func = function()
    curLeftTime = curLeftTime - 1
    if 0 <= curLeftTime then
      local timeStr_ = Z.TimeTools.FormatToDHMSStr(curLeftTime)
      str = Lang("remainderLimit", {str = timeStr_})
      self.uiBinder.lab_start_time.text = str
    else
      if self.timer then
        self.timerMgr:StopTimer(self.timer)
        self.timer = nil
      end
      self:RefreshRightInfo()
    end
  end
  local canMatch = 0 < leftTime_ and beforeLeftTime <= 0
  if canMatch == false then
    if 0 < beforeLeftTime then
      func()
      self.timer = self.timerMgr:StartTimer(func, 1, beforeLeftTime + 1)
    elseif leftTime_ <= 0 then
      self.uiBinder.lab_start_time.text = Lang("ActivityHasEnd")
    end
  end
  self.isOpen_ = canMatch
  self:SetUIVisible(self.uiBinder.node_btn_list, self.isOpen_)
  self:SetUIVisible(self.uiBinder.btn_cancel, false)
  self:SetUIVisible(self.uiBinder.lab_matching, false)
  self:SetUIVisible(self.uiBinder.lab_start_time, not self.isOpen_)
end

function World_boss_mainView:onActivityEnd()
  self.isOpen_ = false
  self:SetUIVisible(self.uiBinder.node_btn_list, self.isOpen_)
  self:SetUIVisible(self.uiBinder.btn_cancel, false)
  self:SetUIVisible(self.uiBinder.lab_matching, false)
  self:SetUIVisible(self.uiBinder.lab_start_time, not self.isOpen_)
end

function World_boss_mainView:RefreshMatchState(matchType)
  if self.isOpen_ == false then
    return
  end
  if matchType ~= E.MatchType.WorldBoss then
    return
  end
  local matchData_ = Z.DataMgr.Get("match_data")
  local time = matchData_:GetMatchStartTime()
  local isMatching = 0 < time
  self:SetUIVisible(self.uiBinder.lab_matching, isMatching)
  self:SetUIVisible(self.uiBinder.btn_cancel, isMatching)
  self:SetUIVisible(self.uiBinder.node_btn_list, isMatching == false)
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  if isMatching then
    local time2 = (Z.TimeTools.Now() - time) / 1000
    self.uiBinder.lab_matching.text = Lang("Matchmaking") .. Z.TimeTools.S2HMSFormat(time2)
    self.timer_ = self.timerMgr:StartTimer(function()
      local time1 = (Z.TimeTools.Now() - time) / 1000
      self.uiBinder.lab_matching.text = Lang("Matchmaking") .. Z.TimeTools.S2HMSFormat(time1)
    end, 1, -1)
  end
end

return World_boss_mainView
