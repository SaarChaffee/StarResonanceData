local expressionVm_ = Z.VMMgr.GetVM("expression")
local checkValid = function(itemUuid, configId, data)
  local row = expressionVm_.CheckIsUnlockByItemId(configId)
  if row then
    return E.ItemBtnState.Active
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local actionData = Z.DataMgr.Get("action_data")
  if not configId then
    return
  end
  local actionRow = actionData:GetActionDataByUnlockItemId(configId)
  if actionRow == nil then
    return
  end
  local expressionData = Z.DataMgr.Get("expression_data")
  local emoteTableData = expressionData:GetEmoteDataByActionName(actionRow.Id)
  if not emoteTableData then
    return
  end
  local ret = expressionVm_.UnlockShowPiece(emoteTableData.Type, actionRow.Id)
  if ret == 0 then
    Z.TipsVM.ShowTipsLang(1000031)
  end
end
local getBtnName = function(itemUuid, configId)
  local btnName = Lang("ExpressionItemUse")
  return btnName
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
