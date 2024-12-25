local super = require("ui.service.service_base")
local BuffService = class("BuffService", super)

function BuffService:OnInit()
  Z.BuffMgr:Init()
end

function BuffService:OnUnInit()
  Z.BuffMgr:UnInit()
end

function BuffService:OnLogin()
  Z.BuffMgr:Clear()
end

function BuffService:OnLogout()
  Z.BuffMgr:Clear()
end

function BuffService:OnReconnect()
end

function BuffService:OnEnterScene()
  Z.BuffMgr:Clear()
  if not Z.StageMgr.GetIsInGameScene() then
    return
  end
  Z.BuffMgr:CreateEntityBuffData(Z.EntityMgr.PlayerUuid, "BuffService")
end

return BuffService
