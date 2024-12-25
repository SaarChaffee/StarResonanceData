local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Mod) and data and data.viewConfigKey and data.viewConfigKey == "backpack_main" then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local isEquip, slot = modVM.IsModEquip(itemUuid)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if isEquip then
    gotoFuncVM.GoToFunc(E.FunctionID.Mod, slot)
  else
    slot = modVM.GetUnEquipSlotId()
    gotoFuncVM.GoToFunc(E.FunctionID.Mod, slot)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("GoToAssembly")
end
local priority = function()
  return 1
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
