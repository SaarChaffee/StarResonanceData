local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Equip) then
    return E.ItemBtnState.UnActive
  end
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.TraceOrSwitchFunc(E.EquipFuncId.EquipTrace)
end
local getBtnName = function(itemUuid, configId)
  return Lang("GoToCultivate")
end
local loadRedNode = function(itemUuid, configId)
  if itemUuid and configId then
    local equipVm = Z.VMMgr.GetVM("equip_refine")
    return equipVm.GetRefineItemRedName(itemUuid)
  end
end
local priority = function()
  return 1
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority,
  LoadRedNode = loadRedNode
}
return ret
