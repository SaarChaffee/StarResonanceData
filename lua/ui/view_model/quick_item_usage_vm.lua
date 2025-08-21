local ret = {}

function ret.AsyncUseItem(configId, cancelToken, uuid)
  local itemFunctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local itemFunctionTable = itemFunctionTableMgr.GetRow(configId)
  if itemFunctionTable == nil then
    return
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local count = 0
  local bindFlag
  if uuid ~= nil then
    local itemInfo = itemsVM.GetItemInfobyItemId(uuid, configId)
    count = itemInfo and itemInfo.count or 0
    bindFlag = itemInfo and itemInfo.bindFlag or nil
  else
    count = itemsVM.GetItemTotalCount(configId)
  end
  local isOk = itemsVM.OpenSelectGiftPackageView(configId, uuid, count)
  if isOk then
    return
  end
  isOk = itemsVM.OpenBatchUseView(configId, uuid, count)
  if isOk then
    return
  end
  return itemsVM.AsyncUseItemByConfigId(configId, cancelToken, 1, bindFlag)
end

function ret.checkCanQuickUse(configId)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTable = itemTableMgr.GetRow(configId)
  if itemTable == nil or itemTable.QuickUse == 0 then
    return false
  end
  local itemFunctionTableMgr = Z.TableMgr.GetTable("ItemFunctionTableMgr")
  local itemFunctionTable = itemFunctionTableMgr.GetRow(configId, true)
  if itemFunctionTable == nil then
    return false
  end
  if itemFunctionTable.Type == E.ItemFunctionType.Gift then
    return true
  end
  return false
end

function ret.AddItemToQuickUseQueue(configId, uuid)
  if not ret.checkCanQuickUse(configId) then
    return
  end
  local quickItemUsageData = Z.DataMgr.Get("quick_item_usage_data")
  quickItemUsageData:EnItemQuickQueue(configId, uuid)
  ret.ShowQuickUseView()
end

function ret.ShowQuickUseView()
  local quickItemUsageData = Z.DataMgr.Get("quick_item_usage_data")
  if not quickItemUsageData:HasQuickUseItem() then
    return
  end
  Z.UIMgr:OpenView("quick_item_usage")
end

function ret.DelQuickItemData(configId, uuid)
  local quickItemUsageData = Z.DataMgr.Get("quick_item_usage_data")
  if not quickItemUsageData:CheckItemVail(configId, uuid) then
    return
  end
  quickItemUsageData:DeItemQuickQueue(configId, uuid)
  Z.UIMgr:OpenView("quick_item_usage")
end

function ret.CloseQuickUseView()
  Z.UIMgr:CloseView("quick_item_usage")
end

return ret
