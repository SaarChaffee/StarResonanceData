local super = require("ui.service.service_base")
local TimerService = class("TimerService", super)

function TimerService:OnInit()
  self.timerID2ActionMap_ = {
    [500] = function(state, offestIndex)
      self:unionWarDanceTimer(state, offestIndex)
    end,
    [501] = function(state, offestIndex)
      self:unionWarDanceWillOpenTimer(state, offestIndex)
    end,
    [Z.WorldBoss.WorldBossOpenTimerId] = function(state, offestIndex)
      self:WorldBossOpenTimer(state, offestIndex)
    end
  }
  local recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  local seasonActTableRow = recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.WorldBoss)
  if seasonActTableRow ~= nil then
    self.timerID2ActionMap_[seasonActTableRow.OpenTimerId] = function(state, offestIndex)
      self:WorldBossRecommendOpenTimer(state, offestIndex)
    end
  end
end

function TimerService:OnUnInit()
  self.timerID2ActionMap_ = nil
end

function TimerService:OnLogin()
  local unionActRow = Z.TableMgr.GetTable("UnionActivityTableMgr").GetRow(E.UnionActivityType.UnionHunt)
  if unionActRow ~= nil and unionActRow.TimerId == nil then
    self.timerID2ActionMap_[unionActRow.TimerId] = function(state, offestIndex)
      self:UnionHuntOpenTimer(state, offestIndex)
    end
  end
  if self.timerRegisted == nil or self.timerRegisted == false then
    for k, v in pairs(self.timerID2ActionMap_) do
      Z.DIServiceMgr.ZCfgTimerService:RegisterTimerAction(k, v)
    end
    self.timerRegisted = true
  end
end

function TimerService:OnLogout()
  if self.timerRegisted ~= nil and self.timerRegisted == true then
    for k, v in pairs(self.timerID2ActionMap_) do
      Z.DIServiceMgr.ZCfgTimerService:UnRegisterTimerAction(k, v)
    end
    self.timerRegisted = false
  end
end

function TimerService:OnReconnect()
end

function TimerService:OnEnterScene()
end

function TimerService:unionWarDanceTimer(state, offsetIndex)
  local unionRed_ = require("rednode.union_red")
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  if state == Panda.ZGame.ETimerTriggerStage.CycleStart then
    Z.EventMgr:Dispatch(Z.ConstValue.UnionWarDanceEvt.UnionWarDanceSelfActivityStart)
    unionWarDanceVM:NoticeActivityOpen()
    unionWarDanceVM:StartUnionWarDanceMusic(true)
    unionWarDanceVM:ShowUnionWarDanceVibe()
    local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
    local isInArea = unionWarDanceData_:IsInDanceArea()
    if isInArea then
      unionWarDanceVM:OpenDanceView()
    end
    unionRed_.RefreshDanceRecommendRed(true)
  elseif state == Panda.ZGame.ETimerTriggerStage.CycleEnd then
    unionWarDanceVM:NoticeActivityEnd()
    unionWarDanceVM:EndUnionWarDanceMusic()
    unionWarDanceVM:HideUnionWarDanceVibe()
    unionWarDanceVM:CloseDanceView()
    unionWarDanceVM:StopDance()
    unionRed_.RefreshDanceRecommendRed(false)
  end
end

function TimerService:unionWarDanceWillOpenTimer(state, offsetIndex)
  local unionWarDanceVM = Z.VMMgr.GetVM("union_wardance")
  if state == Panda.ZGame.ETimerTriggerStage.CycleStart then
    unionWarDanceVM:NoticeActivityWillOpen()
    local unionWarDanceData_ = Z.DataMgr.Get("union_wardance_data")
    local isInArea = unionWarDanceData_:IsInDanceArea()
    if isInArea then
      unionWarDanceVM:OpenDanceView()
    end
  end
end

function TimerService:WorldBossOpenTimer(state, offsetIndex)
  local bossRed_ = require("rednode.world_boss_red")
  if state == Panda.ZGame.ETimerTriggerStage.CycleStart then
    bossRed_.CheckRed(true)
  elseif state == Panda.ZGame.ETimerTriggerStage.CycleEnd then
    bossRed_.CheckRed(false)
  end
end

function TimerService:UnionHuntOpenTimer(state, offsetIndex)
  local unionRed_ = require("rednode.union_red")
  if state == Panda.ZGame.ETimerTriggerStage.CycleStart then
    unionRed_.RefreshHuntRecommendRed(true)
  elseif state == Panda.ZGame.ETimerTriggerStage.CycleEnd then
    unionRed_.RefreshHuntRecommendRed(false)
  end
end

function TimerService:WorldBossRecommendOpenTimer(state, offsetIndex)
  local bossRed_ = require("rednode.world_boss_red")
  if state == Panda.ZGame.ETimerTriggerStage.CycleStart then
    bossRed_.CheckRed(nil, true)
    local worldBossVM_ = Z.VMMgr.GetVM("world_boss")
    worldBossVM_:NoticeWorldBossOpen()
  elseif state == Panda.ZGame.ETimerTriggerStage.CycleEnd then
    bossRed_.CheckRed(nil, false)
  end
end

return TimerService
