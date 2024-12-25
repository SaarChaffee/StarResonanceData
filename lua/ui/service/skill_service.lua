local super = require("ui.service.service_base")
local SkillService = class("SkillService", super)
local skillRed = require("rednode.skill_red")

function SkillService:OnInit()
end

function SkillService:OnUnInit()
end

function SkillService:OnLogin()
  skillRed.Init()
end

function SkillService:OnLeaveScene()
end

function SkillService:OnLateInit()
  local skillVm = Z.VMMgr.GetVM("skill")
  skillVm.CacheSKillFightLevelTable()
end

function SkillService:OnLogout()
  skillRed.UnInit()
end

function SkillService:OnEnterScene(sceneId)
end

return SkillService
