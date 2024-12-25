local super = require("ui.service.service_base")
local WarehouseService = class("WarehouseService", super)

function WarehouseService:OnInit()
end

function WarehouseService:OnUnInit()
end

function WarehouseService:OnLogin()
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  warehouseVm.GetAllWarehouseCfgData()
end

function WarehouseService:OnLeaveScene()
  local teamTipsVm = Z.VMMgr.GetVM("team_tips")
  teamTipsVm.CloseTeamTipsView()
end

function WarehouseService:OnLogout()
end

function WarehouseService:OnEnterScene(sceneId)
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  local subType = sceneTable.SceneSubType
  if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
    local warehouseVm = Z.VMMgr.GetVM("warehouse")
    warehouseVm.GetWarehouse()
  end
end

return WarehouseService
