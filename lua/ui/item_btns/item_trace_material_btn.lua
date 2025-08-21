local checkValid = function(itemUuid, configId, data)
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemMaterialVm = Z.VMMgr.GetVM("item_material")
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId, true)
  if itemRow.Type ~= E.ItemType.Blueprint then
    return E.ItemBtnState.UnActive
  end
  local consumeList = itemMaterialVm.GetItemConsumeList(configId)
  if consumeList == nil or not next(consumeList) then
    return E.ItemBtnState.UnActive
  end
  for index, value in ipairs(consumeList) do
    local configId = value[1]
    local consumeNum = value[2]
    local curCount = itemsVM.GetItemTotalCount(configId)
    if consumeNum > curCount then
      return E.ItemBtnState.Active
    end
  end
  return E.ItemBtnState.UnActive
end
local onClick = function(itemUuid, configId, data)
  local itemMaterialVm = Z.VMMgr.GetVM("item_material")
  local consumeList = itemMaterialVm.GetItemConsumeList(configId)
  if consumeList == nil then
    return
  end
  local itemData = {}
  for index, value in ipairs(consumeList) do
    local configId = value[1]
    local consumeNum = value[2]
    itemData[index] = {
      ItemId = configId,
      ItemNum = consumeNum,
      LabType = E.ItemLabType.Expend
    }
  end
  local itemTraceVm = Z.VMMgr.GetVM("item_trace")
  itemTraceVm.ShowTraceView(configId, itemData)
end
local getBtnName = function(itemUuid, configId)
  return Lang("MaterialTracking")
end
local priority = function()
  return 27
end
local ret = {
  CheckValid = checkValid,
  OnClick = onClick,
  GetBtnName = getBtnName,
  Priority = priority
}
return ret
