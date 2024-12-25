local equipVm_ = Z.VMMgr.GetVM("equip_system")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, true)
  if equipTable == nil then
    return E.ItemBtnState.UnActive
  end
  local partId = equipTable.EquipPart
  local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(partId)
  if not equipPartRow or not Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition) then
    return E.ItemBtnState.UnActive
  end
  local equipAttr = Z.ContainerMgr.CharSerialize.equip.equipList[partId]
  if not equipAttr or equipAttr.itemUuid == 0 then
    if data.viewConfigKey == "backpack_main" then
      return E.ItemBtnState.Hide
    end
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable then
    if data.viewConfigKey == "backpack_main" then
      equipVm_.OpenEquipSystemView(equipTable.EquipPart)
    else
      if not equipVm_.CheckEquipIsCurProfession(configId) then
        return
      end
      equipVm_.CheckPutOnEquip(equipTable.EquipPart, itemUuid, data.cancelToken)
    end
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Equip")
end
local priority = function()
  return 4
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
