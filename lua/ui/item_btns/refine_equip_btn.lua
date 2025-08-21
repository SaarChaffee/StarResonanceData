local equipVm_ = Z.VMMgr.GetVM("equip_system")
local funcVM = Z.VMMgr.GetVM("gotofunc")
local checkValid = function(itemUuid, configId, data)
  return E.ItemBtnState.UnActive
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
