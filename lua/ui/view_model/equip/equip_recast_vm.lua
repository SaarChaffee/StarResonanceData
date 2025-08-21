local worldProxy = require("zproxy.world_proxy")
local equipCfgData = Z.DataMgr.Get("equip_config_data")
local EquipRecastVm = {}
local recastType = {
  NoToNo = 1,
  NoToRa = 2,
  RaToRa = 3,
  RoToNo = 4,
  Item = 5
}

function EquipRecastVm.OpenRecastChoiceView(configId, uuid)
  Z.UIMgr:OpenView("equip_choice_popup", {configId = configId, uuid = uuid})
end

function EquipRecastVm.ClostRecastChoiceView()
  Z.UIMgr:CloseView("equip_choice_popup")
end

function EquipRecastVm.AsyncRecastEquip(uuid, recastItemInfo, cancelToken)
  local consumeUuid, itemConfigId
  if recastItemInfo.IsEquipItem then
    consumeUuid = {
      recastItemInfo.Item.uuid
    }
  else
    itemConfigId = recastItemInfo.ConfigId
  end
  local request = {
    uuid = uuid,
    consumeUuid = consumeUuid,
    itemConfigId = itemConfigId
  }
  local ret = worldProxy.RecastEquip(request, cancelToken)
  if ret == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Equip.EquipRecastSuccess, uuid)
    return ret
  else
    Z.TipsVM.ShowTips(ret)
  end
end

function EquipRecastVm.InitConfig()
  equipCfgData:InitRecastConfig()
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

function EquipRecastVm.GetRecastItems(configId, difUuid, isNoGetPutEquip)
  local equipSysVm = Z.VMMgr.GetVM("equip_system")
  local tab = {}
  local equipRow = Z.TableMgr.GetRow("EquipTableMgr", configId)
  if not equipRow then
    return tab
  end
  local configIdMaps = {}
  local itemsVm = Z.VMMgr.GetVM("items")
  for index, typeId in ipairs(equipRow.RecastType) do
    local recastItemRow = Z.TableMgr.GetRow("EquipRecastTypeTableMgr", typeId)
    if recastItemRow then
      if recastItemRow.RecastType == recastType.Item then
        local itemId = recastItemRow.RecastItemId
        local count = itemsVm.GetItemTotalCount(itemId)
        if 0 < count then
          tab[#tab + 1] = {
            IsEquipItem = false,
            ConfigId = itemId,
            ExpendNum = recastItemRow.AllPurposeItem
          }
        end
      elseif recastItemRow.RecastType == recastType.NoToNo then
        if equipRow.QualitychiIdType == 0 then
          configIdMaps[configId] = 1
        end
      elseif recastItemRow.RecastType == recastType.RaToRa then
        if equipRow.QualitychiIdType ~= 0 then
          configIdMaps[configId] = 1
        end
      elseif equipRow.EquipNameGroupId ~= 0 then
        local rareEquipMap = equipCfgData.EquipRareMap[equipRow.EquipNameGroupId]
        if rareEquipMap then
          for index, rareConfigId in ipairs(rareEquipMap) do
            if configIdMaps[configId] == nil then
              local neWEquipRow = Z.TableMgr.GetRow("EquipTableMgr", rareConfigId)
              if recastItemRow.RecastType == recastType.NoToRa then
                if neWEquipRow and neWEquipRow.QualitychiIdType ~= 0 then
                  configIdMaps[configId] = 1
                end
              elseif recastItemRow.RecastType == recastType.RoToNo and neWEquipRow and neWEquipRow.QualitychiIdType == 0 then
                configIdMaps[configId] = 1
              end
            end
          end
        end
      end
    end
  end
  table.zmerge(tab, equipSysVm.GetEquipItemsByConfigIdMap(configIdMaps, difUuid, isNoGetPutEquip))
  return tab
end

return EquipRecastVm
