local super = require("ui.service.service_base")
local WorldBossService = class("WorldBossService", super)

function WorldBossService:OnInit()
end

function WorldBossService:OnUnInit()
end

function WorldBossService:OnLogin()
  function self.worldBossTimer_(state, offestIndex)
    self:worldBossTimer(state, offestIndex)
  end
  
  if self.timerRegisted == nil or self.timerRegisted == false then
    Z.DIServiceMgr.ZCfgTimerService:RegisterTimerAction(Z.WorldBoss.WorldBossOpenTimerId, self.worldBossTimer_)
    self.timerRegisted = true
  end
  self.timeInited_ = false
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
end

function WorldBossService:OnLogout()
  if self.timerRegisted ~= nil and self.timerRegisted == true then
    Z.DIServiceMgr.ZCfgTimerService:UnRegisterTimerAction(220, self.worldBossTimer_)
    self.timerRegisted = false
  end
  local worldBossData = Z.DataMgr.Get("world_boss_data")
  worldBossData:SetRecommendRedChecked(false)
  self.containerSynced = false
  self.timeInited_ = false
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
end

function WorldBossService:onTimerInited()
  self.timeInited_ = true
  if self.containerSynced then
    local bossRed_ = require("rednode.world_boss_red")
    bossRed_.CheckRed()
  end
  if Z.TimeTools.CheckIsInTimeByTimeId(Z.WorldBoss.WorldBossOpenTimerId) then
    local worldBossVM_ = Z.VMMgr.GetVM("world_boss")
    worldBossVM_:NoticeWorldBossOpen()
  end
end

function WorldBossService:onTimerUnInited()
  self.timeInited_ = false
end

function WorldBossService:OnReconnect()
end

function WorldBossService:OnEnterScene()
end

function WorldBossService:worldBossTimer(state, offsetIndex)
  if state == Panda.ZGame.ETimerTriggerStage.CycleEnd then
    Z.EventMgr:Dispatch(Z.ConstValue.WorldBoss.WorldBossActivityEnd)
  end
end

function WorldBossService:OnSyncAllContainerData()
  self.containerSynced = true
  if self.timeInited_ then
    local bossRed_ = require("rednode.world_boss_red")
    bossRed_.CheckRed()
  end
end

return WorldBossService
