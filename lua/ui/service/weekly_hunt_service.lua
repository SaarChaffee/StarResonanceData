local super = require("ui.service.service_base")
local WeeklyHuntService = class("WeeklyHuntService", super)

function WeeklyHuntService:OnInit()
  self.weeklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
  self.weeklyHuntRed_ = require("rednode.weeklyhunt_red")
end

function WeeklyHuntService:OnUnInit()
end

function WeeklyHuntService:OnLogin()
  self.weeklyHuntVm_.InitClimbUpLayerTable()
  self.weeklyHuntRed_.Init()
end

function WeeklyHuntService:OnLogout()
  self.weeklyHuntRed_.UnInit()
end

function WeeklyHuntService:OnReconnect()
end

function WeeklyHuntService:OnEnterScene()
end

return WeeklyHuntService
