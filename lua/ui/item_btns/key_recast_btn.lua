local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if itemsVM.CheckItemIsKey(configId) then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  itemsVM.OpenKeyRecastView(configId, itemUuid)
end
local getBtnName = function(itemUuid, configId)
  return Lang("Recast")
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
