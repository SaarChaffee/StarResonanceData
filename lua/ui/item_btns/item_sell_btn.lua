local checkValid = function(itemUuid, configId, data)
  local tradeVm = Z.VMMgr.GetVM("trade")
  if tradeVm:CheckItemCanExchange(configId, itemUuid) and data and data.viewConfigKey and data.viewConfigKey == "backpack_main" then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local tradeVm = Z.VMMgr.GetVM("trade")
  tradeVm.OpenTradeMainView(nil, 3, 1, itemUuid)
end
local getBtnName = function(itemUuid, configId)
  return Lang("sell")
end
local priority = function()
  return 22
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
