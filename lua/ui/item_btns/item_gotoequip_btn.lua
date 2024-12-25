local equipVm_ = Z.VMMgr.GetVM("equip_system")
local characterinfoGatherVm_ = Z.VMMgr.GetVM("characterinfo_gather")
local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  if equipVm_.IsPutEquipByUuid(itemUuid) then
    return E.ItemBtnState.UnActive
  end
  if data.viewConfigKey ~= "backpack_main" then
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
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local isOn = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.EquipFuncId.Equip)
  if not isOn then
    return
  end
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local equipTable = equipTableMgr.GetRow(configId, false)
  if equipTable then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.EquipFuncId.Equip, {
      itemUuid = itemUuid,
      prtId = equipTable.EquipPart
    })
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("ClickToEquip")
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
