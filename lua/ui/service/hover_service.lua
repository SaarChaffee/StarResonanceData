local super = require("ui.service.service_base")
local HoverService = class("HoverService", super)

function HoverService:OnInit()
end

function HoverService:OnUnInit()
end

function HoverService:OnLogin()
end

function HoverService:OnLogout()
end

function HoverService:OnEnterScene()
  if Z.StageMgr.GetIsInGameScene() then
    self.airLastTime = Z.Global.AirLastTime
    self.curTime_ = 0
    self.isHover_ = false
    self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
      if Z.EntityMgr.PlayerEnt then
        local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
        if stateId == Z.PbEnum("EActorState", "ActorStateJump") or stateId == Z.PbEnum("EActorState", "ActorStateFall") or stateId == Z.PbEnum("EActorState", "ActorStateFlow") or stateId == Z.PbEnum("EActorState", "ActorStateGlide") or stateId == Z.PbEnum("EActorState", "ActorStateLevitation") then
          self.isHover_ = true
          if self.curTime_ <= 0 then
            self.curTime_ = math.floor(Z.ServerTime:GetServerTime() / 1000)
          end
        else
          if self.isHover_ then
            local time = math.floor(Z.ServerTime:GetServerTime() / 1000) - self.curTime_
            if time >= self.airLastTime then
              local goalVM = Z.VMMgr.GetVM("goal")
              goalVM.SetGoalFinish(E.GoalType.HoverTime, time)
            end
          end
          self.isHover_ = false
          self.curTime_ = 0
        end
      end
    end)
  end
end

function HoverService:OnLeaveScene()
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
end

return HoverService
