local super = require("ui.service.service_base")
local LifeWorkService = class("LifeWorkService", super)

function LifeWorkService:OnInit()
  self.lifeWorkVM = Z.VMMgr.GetVM("life_work")
  self.lifeWorkRed = require("rednode.life_work_red")
  self.timerMgr = Z.TimerMgr.new()
  
  function self.workInfoChangeFunc(container, dirtys)
    if dirtys.lifeProfessionId then
      self.timerMgr:Clear()
      Z.EventMgr:Dispatch(Z.ConstValue.LifeWork.LifeWorkRewardChange)
      if container.endTime > Z.TimeTools.Now() / 1000 then
        self:startTimer(container.lifeProfessionId)
      end
    end
  end
end

function LifeWorkService:OnUnInit()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timerMgr:Clear()
end

function LifeWorkService:OnLogin()
end

function LifeWorkService:OnLogout()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self:UninitContainerWatcher()
  self.lifeWorkRed.UnInit()
end

function LifeWorkService:OnSyncAllContainerData()
  self:InitContainerWatcher()
  self.lifeWorkRed.Init()
end

function LifeWorkService:OnReconnect()
end

function LifeWorkService:OnEnterScene()
end

function LifeWorkService:InitContainerWatcher()
  Z.ContainerMgr.CharSerialize.lifeProfessionWork.lifeProfessionWorkInfo.Watcher:RegWatcher(self.workInfoChangeFunc)
end

function LifeWorkService:startTimer(lifeProfessionId)
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartTimer(function()
    if self.lifeWorkVM.IsCurWorkingEnd(lifeProfessionId) then
      self.timerMgr:StopTimer(self.timer_)
      self.timer_ = nil
      Z.EventMgr:Dispatch(Z.ConstValue.LifeWork.LifeWorkRewardChange)
    end
  end, 1, -1)
end

function LifeWorkService:UninitContainerWatcher()
  Z.ContainerMgr.CharSerialize.lifeProfessionWork.lifeProfessionWorkInfo.Watcher:UnregWatcher(self.workInfoChangeFunc)
end

return LifeWorkService
