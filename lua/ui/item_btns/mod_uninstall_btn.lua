local checkValid = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local itemsVM = Z.VMMgr.GetVM("items")
  local isEquip, pos = modVM.IsModEquip(itemUuid)
  if itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Mod) and data and data.viewConfigKey and data.viewConfigKey == "mod_window" and isEquip and pos == data.slotId then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local modVM = Z.VMMgr.GetVM("mod")
  modVM.AsyncUninstallMod(data.slotId, data.cancelToken)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Remove")
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
