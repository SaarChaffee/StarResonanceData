local checkValid = function(itemUuid, configId, data)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemData = itemTableMgr.GetRow(configId, true)
  if itemData == nil then
    return E.ItemBtnState.UnActive
  end
  return itemData.Discard == 1 and E.ItemBtnState.Active or E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  local item = itemsVM.GetItemInfobyItemId(itemUuid, configId)
  if item then
    itemsVM.OpenDeleteItemView(configId, itemUuid, item.count)
  end
end
local getBtnName = function(itemUuid, configId)
  return Lang("Discard")
end
local priority = function()
  return 100
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
