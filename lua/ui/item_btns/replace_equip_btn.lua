local equipSystemVm_ = Z.VMMgr.GetVM("equip_system")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable == nil then
    return E.ItemBtnState.UnActive
  end
  local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(equipTable.EquipPart)
  if not equipPartRow or not Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition) then
    return E.ItemBtnState.UnActive
  end
  local partId = equipTable.EquipPart
  local equipAttr = Z.ContainerMgr.CharSerialize.equip.equipList[partId]
  if not equipAttr or equipAttr.itemUuid == 0 then
    return E.ItemBtnState.UnActive
  end
  if equipAttr.itemUuid == itemUuid then
    return E.ItemBtnState.UnActive
  end
  if data.viewConfigKey == "backpack_main" then
    return E.ItemBtnState.Hide
  end
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if data.viewConfigKey == "backpack_main" then
    equipSystemVm_.OpenChangeEquipView({itemUuid = itemUuid, State = 2})
  elseif data.viewConfigKey == "equip_system" then
    if not equipSystemVm_.CheckEquipIsCurProfession(configId) then
      return
    end
    if equipTable then
      local equipVm = Z.VMMgr.GetVM("equip_system")
      equipVm.CheckPutOnEquip(equipTable.EquipPart, itemUuid, data.cancelToken)
    end
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Replace")
end
local priority = function()
  return 1
end
local loadRedNode = function(itemUuid, configId)
  if itemUuid and configId then
    local equipVm = Z.VMMgr.GetVM("equip_system")
    return equipVm.GetEquipPartTabRed(equipVm.GetEquipPartIdByConfigId(configId)) .. itemUuid
  end
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority,
  LoadRedNode = loadRedNode
}
return ret
