local checkValid = function(itemUuid, configId, data)
  local config = Z.TableMgr.GetRow("ItemFunctionTableMgr", configId, true)
  if config ~= nil and config.Type == E.ItemFunctionType.FuncSwitch then
    return E.ItemBtnState.Active
  else
    return E.ItemBtnState.UnActive
  end
end
local onClick = function(itemUuid, configId, data)
  local config = Z.TableMgr.GetRow("ItemFunctionTableMgr", configId, true)
  if config ~= nil and config.Type == E.ItemFunctionType.FuncSwitch then
    local funcId = tonumber(config.Parameter[1])
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.TraceOrSwitchFunc(funcId)
  end
end
local getBtnName = function(itemUuid, configId)
  local labelName = ""
  local config = Z.TableMgr.GetRow("ItemFunctionTableMgr", configId, true)
  if config ~= nil and config.Type == E.ItemFunctionType.FuncSwitch then
    labelName = config.Button
  end
  if labelName == "" then
    labelName = Lang("Goto")
  end
  return labelName
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
