local super = require("ui.service.service_base")
local EquipService = class("EquipService", super)
local equipRed = require("rednode.equip_red")

function EquipService:OnInit()
end

function EquipService:OnUnInit()
end

function EquipService:OnLogin()
  equipRed.Init()
  local equipRefineVm = Z.VMMgr.GetVM("equip_refine")
  equipRefineVm.InitRefineData()
  local equipRecastVm = Z.VMMgr.GetVM("equip_recast")
  equipRecastVm.InitConfig()
  local equipEnchantVm = Z.VMMgr.GetVM("equip_enchant")
  equipEnchantVm.InitConfig()
  local equipForgeVm = Z.VMMgr.GetVM("equip_forge")
  equipForgeVm.InitConfig()
end

function EquipService:OnLeaveScene()
end

function EquipService:OnLogout()
  equipRed.UnInit()
end

function EquipService:OnEnterScene(sceneId)
end

return EquipService
