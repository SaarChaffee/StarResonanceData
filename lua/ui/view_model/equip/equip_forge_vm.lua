local EquipForgeVm = {}
local worldProxy = require("zproxy.world_proxy")

function EquipForgeVm.OpenEquipForgeView(param)
  local viewConfigKey = "equip_forge_main"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.EquipForge, viewConfigKey, function()
    Z.UIMgr:OpenView(viewConfigKey, param)
  end)
end

function EquipForgeVm.OpenEquipMakeView()
  EquipForgeVm.CloseEquipForgeView()
  local viewConfigKey = "equip_forge_main"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.EquipForge, viewConfigKey, function()
    Z.UIMgr:OpenView(viewConfigKey, 1)
  end)
end

function EquipForgeVm.CloseEquipForgeView()
  Z.UIMgr:CloseView("equip_forge_main")
end

function EquipForgeVm.InitConfig()
  local data = Z.DataMgr.Get("equip_config_data")
  data:InitEquipBreakCfg()
  data:InitCreateCfg()
  data:InitEquipSchoolMap()
  data:InitEquipSuitMap()
  data:InitTalentSchoolMap()
end

function EquipForgeVm.OpenEquipObtainingPopup(itemInfo)
  Z.UIMgr:OpenView("equip_obtaining_popup", itemInfo)
end

function EquipForgeVm.CloseEquipObtainingPopup()
  Z.UIMgr:CloseView("equip_obtaining_popup")
end

function EquipForgeVm.AsyncEquipBreach(equipUid, token)
  local request = {equipUid = equipUid}
  local ret = worldProxy.EquipBreach(request, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  else
    local itemsVm = Z.VMMgr.GetVM("items")
    local item = itemsVm.GetItemInfo(equipUid, E.BackPackItemPackageType.Equip)
    if item then
      EquipForgeVm.OpenEquipObtainingPopup(item)
    end
  end
  return ret == 0
end

function EquipForgeVm.AsyncEquipCreate(equipConfigId, consumeEquipUuid, token)
  local request = {equipConfigId = equipConfigId, consumeEquipUuid = consumeEquipUuid}
  local ret = worldProxy.EquipCreate(request, token)
  if ret.errCode == 0 then
    local itemUuid = ret.itemUuids[1]
    local itemsVm = Z.VMMgr.GetVM("items")
    local item = itemsVm.GetItemInfo(itemUuid, E.BackPackItemPackageType.Equip)
    if item then
      EquipForgeVm.OpenEquipObtainingPopup(item)
    end
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
  return ret.errCode == 0
end

return EquipForgeVm
