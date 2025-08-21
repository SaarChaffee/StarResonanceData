local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  if not itemsVM.CheckPackageTypeByItemUuid(itemUuid, E.BackPackItemPackageType.Mod) then
    return E.ItemBtnState.UnActive
  end
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.TraceOrSwitchFunc(E.FunctionID.ModTrace)
end
local getBtnName = function(itemUuid, configId)
  return Lang("GoToCultivate")
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
