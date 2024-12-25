local checkValid = function(itemUuid, configId, data)
  local recycleVM = Z.VMMgr.GetVM("recycle")
  if recycleVM:CheckItemCanRecycle(configId) then
    return E.ItemBtnState.Active
  else
    return E.ItemBtnState.UnActive
  end
end
local onClick = function(itemUuid, configId, data)
  local recycleVM = Z.VMMgr.GetVM("recycle")
  recycleVM:DoJumpByConfigId(configId)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Recycle")
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
