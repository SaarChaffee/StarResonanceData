local getItemfuncData = function(configId)
  local itemFuctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local funcData = itemFuctionTableMgr.GetRow(configId, true)
  return funcData
end
local checkValid = function(itemUuid, configId, data)
  local funcData = getItemfuncData(configId)
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemCount = itemsVM.GetItemTotalCount(configId)
  if funcData == nil or funcData.ItemBatch <= 1 or itemCount <= 1 or funcData.UseCD > 0 then
    return E.ItemBtnState.UnActive
  end
  local awardId = tonumber(funcData.Parameter[1])
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local isSelect = awardPreviewVm.CheckAwardTypeIsSelect(awardId)
  if isSelect then
    return E.ItemBtnState.UnActive
  end
  return E.ItemBtnState.Active
end
local onClick = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  local item = itemsVM.GetItemInfobyItemId(itemUuid, configId)
  if item then
    itemsVM.OpenBatchUseView(configId, itemUuid, item.count)
  end
end
local getBtnName = function(itemUuid, configId)
  local funcData = getItemfuncData(configId)
  if funcData == nil then
    return
  end
  return Lang("BatchUser")
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
