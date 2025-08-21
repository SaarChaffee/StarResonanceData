local super = require("ui.ui_view_base")
local Dungeon_timer_windowView = class("Dungeon_timer_windowView", super)
local countDownView = require("ui.view.parkour_count_down_tpl_view")
local timePrepareView = require("ui.view.parkour_time_prepare_tpl_view")
local rankingView = require("ui.view.parkour_ranking_tpl_view")
local heroTimeView = require("ui/component/dungeon/dungeon_time")

function Dungeon_timer_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "dungeon_timer_window")
  self.componentArray_ = {}
  self.dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
  self.dungeonTimerVM = Z.VMMgr.GetVM("dungeon_timer")
  self.lastDungeonType = E.DungeonTimerType.DungeonTimerTypeNull
  self.parkourVM = Z.VMMgr.GetVM("parkourtips")
end

function Dungeon_timer_windowView:OnActive()
  self:initUi()
  self:bindEvent()
end

function Dungeon_timer_windowView:initUi()
  self.countDownZwidget = self.uiBinder.node_count_down
  self.rankingZwidget = self.uiBinder.node_rangking
  self.timePrepareZwidget = self.uiBinder.node_time_prepare
  self.leftCommonZwidget = self.uiBinder.node_time_left_common
end

function Dungeon_timer_windowView:OnDeActive()
  self.lastDungeonType = E.DungeonTimerType.DungeonTimerTypeNull
  self:clearAll()
end

function Dungeon_timer_windowView:OnRefresh()
  if self.dungeonTimerData.DungeonHideTag and self.dungeonTimerData.MainViewHideTag then
    self:Show()
  else
    self:Hide()
  end
  self:SetAsFirstSibling()
  Z.CoroUtil.create_coro_xpcall(function()
    self:initSubView()
  end)()
end

function Dungeon_timer_windowView:clearAll()
  for _, v in pairs(self.componentArray_) do
    if v then
      v:DeActive()
      v = nil
    end
  end
  self.componentArray_ = {}
  self:ClearAllUnits()
end

function Dungeon_timer_windowView:initSubView()
  if not Z.StageMgr.GetIsInDungeon() then
    self:DeActive()
    return
  end
  local timerInfo = Z.ContainerMgr.DungeonSyncData.timerInfo
  self:clearAll()
  if not timerInfo or timerInfo.type == E.DungeonTimerType.DungeonTimerTypeNull then
    return
  end
  if timerInfo.type == E.DungeonTimerType.DungeonTimerTypeHero then
    local heroDungeonVM = Z.VMMgr.GetVM("hero_dungeon_main")
    local playingTime = heroDungeonVM.GetHeroChallengePlayingTime()
    if playingTime <= 0 then
      return
    end
  end
  local endTime = timerInfo.startTime + timerInfo.dungeonTimes
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  if timerInfo.direction == E.DungeonTimerDirection.DungeonTimerDirectionDown and endTime < nowTime then
    return
  end
  self.lastDungeonType = timerInfo.type
  local timerData = self.dungeonTimerData.DungeonTimerViewData
  if timerData == nil then
    timerData = {}
  end
  if timerInfo.type == E.DungeonTimerType.DungeonTimerTypeWait then
    self:initWaitCommonCountdownUI(timerData, timerInfo)
  elseif timerInfo.type == E.DungeonTimerType.DungeonTimerTypeMiddlerCommon then
    self:initMiddleCommonCountdownUI(timerData, timerInfo)
  elseif timerInfo.type == E.DungeonTimerType.DungeonTimerTypePrepare then
    self:initStartingGunCountdownUI(timerData, timerInfo)
  elseif timerInfo.type == E.DungeonTimerType.DungeonTimerTypeRightCommon then
    self:initRightCommonCountdownUI(timerInfo)
  elseif timerInfo.type == E.DungeonTimerType.DungeonTimerTypeHero then
    local ignoreChange = false
    if self.viewData and self.viewData.ignoreChange then
      ignoreChange = true
    end
    self:initHeroCountdownUI(timerData, ignoreChange)
  end
end

function Dungeon_timer_windowView:createUiUnit(path, name, trans)
  local uiUnit_ = self:AsyncLoadUiUnit(path, name, trans, self.cancelSource:CreateToken())
  return uiUnit_
end

function Dungeon_timer_windowView:closeView(sceneId)
  if not sceneId then
    return
  end
  local isInDungeon = Z.StageMgr.GetIsInDungeon()
  if not isInDungeon then
    self:DeActive()
  end
end

function Dungeon_timer_windowView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.SceneActionEvent.EnterScene, self.closeView, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.HideLeft, self.hideLeftSub, self)
end

function Dungeon_timer_windowView:hideLeftSub(IsOpen)
  self.uiBinder.Ref:SetVisible(self.leftCommonZwidget, not IsOpen)
end

function Dungeon_timer_windowView:initWaitCommonCountdownUI(timerData, timerInfo)
  local compName = "parkour_time_prepare_tpl_view"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "timePreparePath")
  local uiUnit_ = self:createUiUnit(path, compName, self.timePrepareZwidget)
  if not uiUnit_ then
    return
  end
  self.componentArray_.timePreparePrefab = timePrepareView.new()
  local timeStamp = self.dungeonTimerVM.GetEndTimeStamp()
  self.componentArray_.timePreparePrefab:Init(uiUnit_.Go, compName)
  local data = {
    timeNumber = timeStamp,
    startTime = timerInfo.startTime,
    timingDirection = timerInfo.direction,
    addTime = timerInfo.changeTime,
    addTimeUiType = timerInfo.effectType,
    limitTime = timerData.timeLimitNumber,
    timeFinishFunc = timerData.timeFinishFunc,
    timeCallFunc = timerData.timeCallFunc,
    timeLimitFunc = timerData.timeLimitFunc,
    isShowZeroSecond = timerData.isShowZeroSecond,
    pauseTime = timerInfo.pauseTime,
    pauseTotalTime = timerInfo.pauseTotalTime,
    outLookType = timerInfo.outLookType
  }
  self.componentArray_.timePreparePrefab:CountDownFunc(data)
end

function Dungeon_timer_windowView:initMiddleCommonCountdownUI(timerData, timerInfo)
  local compName = "parkour_time_ranking_tpl_view"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "rankingPath")
  local uiUnit_ = self:createUiUnit(path, compName, self.rankingZwidget)
  if not uiUnit_ then
    return
  end
  self.componentArray_.rankingPrefab = rankingView.new()
  self.componentArray_.rankingPrefab:Init(uiUnit_.Go, compName, timerData.isShowRank, timerData.rankStartMark, function()
    if timerData.rankCallBack then
      timerData.rankCallBack()
    end
  end)
  local timeStamp = self.dungeonTimerVM.GetEndTimeStamp()
  if timerData.rankStartMark then
    timerData.rankStartMark = false
  end
  local data = {
    timeNumber = timeStamp,
    limitTime = timerData.timeLimitNumber,
    addLimitTime = timerInfo.changeTime,
    timingDirection = timerInfo.direction,
    addTimeUiType = timerInfo.effectType,
    startTime = timerInfo.startTime,
    pauseTime = timerInfo.pauseTime
  }
  self.componentArray_.rankingPrefab:CountDownFunc(data)
  if timerData.isShowRank then
    timerData.rankData = self.parkourVM.GetParkourRankingByContainer()
    if timerData.rankData and timerData.rankData.rank then
      self.componentArray_.rankingPrefab:ChangeCurrentRank(timerData.rankData.rank)
    end
  end
end

function Dungeon_timer_windowView:initStartingGunCountdownUI(timerData, timerInfo)
  local compName = "parkour_count_down_tpl_view"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, "countDownPath")
  local uiUnit_ = self:createUiUnit(path, compName, self.countDownZwidget)
  if not uiUnit_ then
    return
  end
  self.componentArray_.countDownPrefab = countDownView.new()
  self.componentArray_.countDownPrefab:Init(uiUnit_.Go, compName)
  local data = {
    timeNumber = timerInfo.dungeonTimes,
    limitTime = timerData.timeLimitNumber,
    timeFinishFunc = timerData.timeFinishFunc,
    timeCallFunc = timerData.timeCallFunc,
    timeLimitFunc = timerData.timeLimitFunc,
    isEndShow = timerData.isEndShow
  }
  self.componentArray_.countDownPrefab:CountDownFunc(data)
end

function Dungeon_timer_windowView:initRightCommonCountdownUI(timerInfo)
  local compName = "hero_dungeon_time_tpl_view"
  local pathKey = Z.IsPCUI and "heroTimePathPC" or "heroTimePath"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, pathKey)
  local uiUnit_ = self:createUiUnit(path, compName, self.leftCommonZwidget)
  if not uiUnit_ then
    return
  end
  local data = {}
  data.showType = E.DungeonTimeShowType.time
  data.startTime = timerInfo.startTime
  data.endTime = timerInfo.startTime + timerInfo.dungeonTimes + timerInfo.pauseTotalTime
  data.timeType = timerInfo.direction
  data.changeTimeNumber = timerInfo.changeTime
  data.changeTimeType = timerInfo.effectType
  data.lookType = timerInfo.outLookType
  data.pauseTime = timerInfo.pauseTime
  self.componentArray_.rightCommonPrefab = heroTimeView.new()
  self.componentArray_.rightCommonPrefab:Init(self, uiUnit_, data)
  Z.AudioMgr:Play("UI_Event_Countdown_Short")
end

function Dungeon_timer_windowView:initHeroCountdownUI(timerData, ignoreChange)
  local compName = "hero_dungeon_time_tpl_view"
  local pathKey = Z.IsPCUI and "heroTimePathPC" or "heroTimePath"
  local path = self:GetPrefabCacheDataNew(self.uiBinder.pcd, pathKey)
  local uiUnit_ = self:createUiUnit(path, compName, self.leftCommonZwidget)
  if not uiUnit_ then
    return
  end
  self.componentArray_.heroTimePrefab = heroTimeView.new()
  self.componentArray_.heroTimePrefab:Init(self, uiUnit_, timerData, ignoreChange)
  Z.AudioMgr:Play("UI_Event_Countdown_Short")
end

return Dungeon_timer_windowView
