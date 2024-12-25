local equipVm_ = Z.VMMgr.GetVM("equip_system")
local checkValid = function(itemUuid, configId, data)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, true)
  if equipTable == nil then
    return E.ItemBtnState.UnActive
  end
  local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(equipTable.EquipPart)
  if not equipPartRow or not Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition) then
    return E.ItemBtnState.UnActive
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    local equipVm = Z.VMMgr.GetVM("equip_system")
    if equipVm.CheckEquipDecomonece(itemUuid, configId) then
      return E.ItemBtnState.Active
    end
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByConfigId(configId, E.BackPackItemPackageType.Equip) then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.EquipFuncId.EquipDecompose, itemUuid, configId)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Decompose")
end
local priority = function()
  return 2
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
