local super = require("ui.service.service_base")
local PlayerService = class("PlayerService", super)

function PlayerService:OnInit()
end

function PlayerService:OnUnInit()
end

function PlayerService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.OnUIClose, self)
end

function PlayerService:OnLeaveScene()
end

function PlayerService:OnLateInit()
end

function PlayerService:OnLogout()
  Z.EventMgr:RemoveObjAll(self)
end

function PlayerService:OnEnterScene(sceneId)
end

function PlayerService:OnUIClose(viewConfigKey)
  if viewConfigKey == "name_window" then
    local talkVM = Z.VMMgr.GetVM("talk")
    if not talkVM.IsTalking() then
      return
    end
    local playerVm = Z.VMMgr.GetVM("player")
    if playerVm:IsNamed() then
      return
    end
    Z.UIMgr:OpenView("name_window")
  end
end

return PlayerService
