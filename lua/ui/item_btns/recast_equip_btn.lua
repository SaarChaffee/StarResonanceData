local equipVm_ = Z.VMMgr.GetVM("equip_system")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not funcVM.CheckFuncCanUse(E.EquipFuncId.EquipRecast, true) then
    return E.ItemBtnState.UnActive
  end
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, true)
  if equipTable == nil then
    return E.ItemBtnState.UnActive
  end
  local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(equipTable.EquipPart)
  if not equipPartRow or not Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition) then
    return E.ItemBtnState.UnActive
  end
  if equipVm_.CheckCanRecast(itemUuid, configId) then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  equipVm_.OpenEquipRecastView(itemUuid, configId)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Recast")
end
local priority = function()
  return 20
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
