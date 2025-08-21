local equipVm_ = Z.VMMgr.GetVM("equip_system")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local checkValid = function(itemUuid, configId, data)
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  equipVm_.OpenEquipEnchantView()
end
local getBtnName = function(itemUuid, configId)
  return Lang("GoEnchantment")
end
local priority = function()
  return 26
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
