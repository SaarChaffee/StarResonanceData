local equipVm_ = Z.VMMgr.GetVM("equip_system")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not funcVM.CheckFuncCanUse(E.EquipFuncId.EquipRefine, true) then
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
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  equipVm_.OpenEquipRefineView(itemUuid, configId)
end
local getBtnName = function(itemUuid, configId)
  return Lang("EquipRefining")
end
local loadRedNode = function(itemUuid, configId)
  if itemUuid and configId then
    local equipVm = Z.VMMgr.GetVM("equip_refine")
    return equipVm.GetRefineItemRedName(itemUuid)
  end
end
local priority = function()
  return 22
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority,
  LoadRedNode = loadRedNode
}
return ret
