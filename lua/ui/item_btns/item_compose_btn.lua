local checkValid = function(itemUuid, configId)
  if Z.TableMgr.GetTable("ComposeTableMgr").GetRow(configId, true) == nil then
    return E.ItemBtnState.UnActive
  else
    return E.ItemBtnState.Active
  end
end
local onClick = function(itemUuid, configId)
  Z.VMMgr.GetVM("compose").OpenComposeView(configId)
end
local getBtnName = function(itemUuid, configId)
  return "\229\144\136\230\136\144"
end
local priority = function()
  return 3
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
