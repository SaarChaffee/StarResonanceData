local worldProxy = require("zproxy.world_proxy")
local equipCfgData = Z.DataMgr.Get("equip_config_data")
local EquipRecastVm = {}

function EquipRecastVm.OpenRecastChoiceView(configId, uuid)
  Z.UIMgr:OpenView("equip_choice_popup", {configId = configId, uuid = uuid})
end

function EquipRecastVm.ClostRecastChoiceView()
  Z.UIMgr:CloseView("equip_choice_popup")
end

function EquipRecastVm.AsyncRecastEquip(uuid, consumeUuid, cancelToken)
  local request = {uuid = uuid, consumeUuid = consumeUuid}
  local ret = worldProxy.RecastEquip(request, cancelToken)
  if ret == 0 then
    return ret
  else
    Z.TipsVM.ShowTips(ret)
  end
end

function EquipRecastVm.InitConfig()
  local equipPerfectLibRow = Z.TableMgr.GetTable("EquipPerfectLibTableMgr").GetDatas()
  local tab = {}
  local perfectTab = {}
  for index, value in pairs(equipPerfectLibRow) do
    if tab[value.PerfectLibId] == nil then
      tab[value.PerfectLibId] = value.PartLevel
    elseif tab[value.PerfectLibId] < value.PartLevel then
      tab[value.PerfectLibId] = value.PartLevel
    end
    if perfectTab[value.PerfectLibId] == nil then
      perfectTab[value.PerfectLibId] = {}
    end
    perfectTab[value.PerfectLibId][value.PartLevel] = value
  end
  equipCfgData.RecastMaxLevleTab = tab
  equipCfgData.RecastPerfectTab = perfectTab
end

function EquipRecastVm.GetEquipPerfectRow(configId, level)
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", configId)
  if not equipRow then
    return nil
  end
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local rows = equipCfgData.RecastPerfectTab[equipRow.PerfectLibId]
  if not rows then
    return nil
  end
  return rows[level]
end

return EquipRecastVm
