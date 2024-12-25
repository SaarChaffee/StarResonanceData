local super = require("ui.service.service_base")
local CookService = class("CookService", super)

function CookService:OnInit()
end

function CookService:OnUnInit()
end

function CookService:OnLogin()
  self.cancelSource = Z.CancelSource.Rent()
  self:startTime()
end

function CookService:startTime()
  local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
  
  function self.refreshEnergyTimer_()
    self:refreshEnergy()
  end
  
  if craftEnergyTableRow then
    Z.DIServiceMgr.ZCfgTimerService:RegisterTimerAction(craftEnergyTableRow.Refresh, self.refreshEnergyTimer_)
  end
end

function CookService:refreshEnergy()
  Z.CoroUtil.create_coro_xpcall(function()
    local WorldProxy = require("zproxy.world_proxy")
    WorldProxy.CraftEnergyRefresh({
      type = Z.PbEnum("CraftEnergyType", "CraftEnergyTypeEnergy")
    }, self.cancelSource:CreateToken())
  end)()
end

function CookService:OnLeaveScene()
end

function CookService:OnLogout()
  local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
  if craftEnergyTableRow and self.refreshEnergyTimer_ then
    Z.DIServiceMgr.ZCfgTimerService:UnRegisterTimerAction(craftEnergyTableRow.Refresh, self.refreshEnergyTimer_)
    self.refreshEnergyTimer_ = nil
  end
  if self.cancelSource then
    self.cancelSource:Recycle()
    self.cancelSource = nil
  end
end

function CookService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self:refreshEnergy()
  end
end

return CookService
