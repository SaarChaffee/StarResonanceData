local super = require("ui.service.service_base")
local DpsService = class("DpsService", super)

function DpsService:OnInit()
end

function DpsService:OnUnInit()
end

function DpsService:switchFunctionState(functionId, isOpen)
  if functionId == E.FunctionID.Dps and not isOpen then
    Z.DamageData:IsActiveUIPanel(false)
  end
end

function DpsService:OnLogin()
  local dpsData = Z.DataMgr.Get("dps_data")
  dpsData:InitCfgData()
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionIcon, self.switchFunctionState, self)
end

function DpsService:OnLeaveScene()
end

function DpsService:OnLogout()
  Z.DamageData:IsActiveUIPanel(false)
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionIcon, self.switchFunctionState, self)
end

function DpsService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    local funcVm = Z.VMMgr.GetVM("gotofunc")
    if not funcVm.CheckFuncCanUse(E.FunctionID.Dps, true) then
      return
    end
    Z.DamageData:IsActiveUIPanel(false)
    local dpsVm = Z.VMMgr.GetVM("dps")
    local isDpsTrackerOn = dpsVm.CheckIsDpsTrackerOn()
    if isDpsTrackerOn then
      Z.DamageData:IsActiveUIPanel(true)
    end
  end
end

return DpsService
