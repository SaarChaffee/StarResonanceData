local super = require("ui.service.service_base")
local SavePowerService = class("SavePowerService", super)

function SavePowerService:OnInit()
  self.powerSaveVM_ = Z.VMMgr.GetVM("power_save")
end

function SavePowerService:OnUnInit()
end

function SavePowerService:OnLogin()
  if Z.GameContext.IsPC then
    return
  end
  self.login = true
  self.powerSaveVM_.SetIsPowerSaveOpen(true)
end

function SavePowerService:OnLeaveScene()
  if Z.GameContext.IsPC then
    return
  end
  self.powerSaveVM_.ClosePowerSaveMode()
end

function SavePowerService:OnLogout()
  if Z.GameContext.IsPC then
    return
  end
  self.login = false
  self.powerSaveVM_.ClosePowerSaveMode()
end

function SavePowerService:OnEnterScene(sceneId)
  if Z.GameContext.IsPC then
    return
  end
  if not self.login then
    return
  end
  self.powerSaveVM_.OpenPowerSaveMode()
end

return SavePowerService
