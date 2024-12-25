local super = require("ui.service.service_base")
local BossService = class("BossService", super)

function BossService:OnInit()
end

function BossService:OnUnInit()
end

function BossService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.BossDeadlySkillCD, self.OnRefreshSkillData, self)
end

function BossService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.BossDeadlySkillCD, self.OnRefreshSkillData, self)
end

function BossService:OnReconnect()
end

function BossService:OnEnterScene()
end

function BossService:asyncInitChat()
end

function BossService:OnRefreshSkillData(skillLevelId, beginTime, duration, validCDTime)
  local monster_data = Z.DataMgr.Get("monster_data")
  monster_data:UpdateSkillCDData(skillLevelId, beginTime, duration, validCDTime)
  Z.EventMgr:Dispatch(Z.ConstValue.BossDeadlySkillCDUpdateView)
end

return BossService
