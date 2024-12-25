local ItemEvent = {}
local ItemEventName = {
  [E.ItemChangeType.Add] = Z.ConstValue.Backpack.AddItem,
  [E.ItemChangeType.Delete] = Z.ConstValue.Backpack.DelItem,
  [E.ItemChangeType.Change] = Z.ConstValue.Backpack.ItemCountChange,
  [E.ItemChangeType.Insert] = Z.ConstValue.Backpack.InsertItem,
  [E.ItemChangeType.Reduce] = Z.ConstValue.Backpack.Reduce,
  [E.ItemChangeType.AllChange] = Z.ConstValue.Backpack.AllChange,
  [E.ItemAddEventType.ItemId] = "ItemIdEvent",
  [E.ItemAddEventType.ItemType] = "ItemTypeEvent",
  [E.ItemAddEventType.ItemPackage] = "ItemPackageEvent"
}
local itemEventNames = {
  [E.ItemChangeType.Add] = {},
  [E.ItemChangeType.Delete] = {},
  [E.ItemChangeType.Change] = {},
  [E.ItemChangeType.Insert] = {},
  [E.ItemChangeType.Reduce] = {},
  [E.ItemChangeType.AllChange] = {}
}
local itemTableRows = {}
local backPackData_, itemsData, itemsVm
local equipRed = require("rednode.equip_red")
local bagRed = require("rednode.bag_red")
local quickItemUsageVm

function ItemEvent.initData()
  itemsData = Z.DataMgr.Get("items_data")
  backPackData_ = Z.DataMgr.Get("backpack_data")
  itemsVm = Z.VMMgr.GetVM("items")
  quickItemUsageVm = Z.VMMgr.GetVM("quick_item_usage")
end

function ItemEvent.RegisterAllChangeEvent(addEventType, id, func, obj)
  ItemEvent.Register(E.ItemChangeType.AllChange, addEventType, id, func, obj)
end

function ItemEvent.RegisterNewEvent(addEventType, id, func, obj)
  ItemEvent.Register(E.ItemChangeType.Add, addEventType, id, func, obj)
end

function ItemEvent.RegisterDelEvent(addEventType, id, func, obj)
  ItemEvent.Register(E.ItemChangeType.Delete, addEventType, id, func, obj)
end

function ItemEvent.RegisterReduceEvent(addEventType, id, func, obj)
  ItemEvent.Register(E.ItemChangeType.Reduce, addEventType, id, func, obj)
end

function ItemEvent.RegisterInsertEvent(addEventType, id, func, obj)
  ItemEvent.Register(E.ItemChangeType.Insert, addEventType, id, func, obj)
end

function ItemEvent.RegisterEvents(itemChangeType, addEventType, ids, func, obj)
  for i, id in ipairs(ids) do
    ItemEvent.Register(itemChangeType, addEventType, id, func, obj)
  end
end

function ItemEvent.Register(itemChangeType, addEventType, id, func, obj)
  if itemChangeType == nil or addEventType == nil or id == nil or func == nil then
    return
  end
  if not ItemEventName[addEventType] or not itemEventNames[itemChangeType] then
    return
  end
  if itemEventNames[itemChangeType][addEventType] == nil then
    itemEventNames[itemChangeType][addEventType] = {}
  end
  local eventName = itemEventNames[itemChangeType][addEventType][id]
  if eventName == nil then
    eventName = ItemEventName[itemChangeType] .. ItemEventName[addEventType] .. id
    itemEventNames[itemChangeType][addEventType][id] = eventName
  end
  Z.EventMgr:Add(eventName, func, obj)
end

function ItemEvent.Remove(itemChangeType, addEventType, id, func, obj)
  if itemChangeType == nil or addEventType == nil or id == nil or func == nil then
    return
  end
  if not (ItemEventName[addEventType] and itemEventNames[itemChangeType]) or not itemEventNames[itemChangeType][addEventType] then
    return
  end
  local eventName = itemEventNames[itemChangeType][addEventType][id]
  if eventName == nil then
    return
  end
  Z.EventMgr:Remove(eventName, func, obj)
end

function ItemEvent.RemoveObjAllByEvent(itemChangeType, addEventType, id, obj)
  if not (ItemEventName[addEventType] and itemEventNames[itemChangeType]) or not itemEventNames[itemChangeType][addEventType] then
    return
  end
  local eventName = itemEventNames[itemChangeType][addEventType][id]
  if eventName == nil then
    return
  end
  Z.EventMgr:RemoveObjAllByEvent(eventName, obj)
end

function ItemEvent.dispatch(itemChangeType, eventType, id, ...)
  if not (ItemEventName[eventType] and itemEventNames[itemChangeType]) or not itemEventNames[itemChangeType][eventType] then
    return
  end
  local eventName = itemEventNames[itemChangeType][eventType][id]
  if eventName == nil then
    return
  end
  Z.EventMgr:Dispatch(eventName, ...)
end

function ItemEvent.onItemCountChangeEvent(item, changeType, info)
  if itemTableRows[item.configId] == nil then
    itemTableRows[item.configId] = Z.TableMgr.GetRow("ItemTableMgr", item.configId)
  end
  if not itemTableRows[item.configId] then
    return
  end
  local itemsData = Z.DataMgr.Get("items_data")
  if changeType == E.ItemChangeType.Add then
    itemsData:UpdateItem(item)
    itemsVm.setQuickBar(item.configId)
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.AddItem, item)
    ItemEvent.dispatch(E.ItemChangeType.Add, E.ItemAddEventType.ItemId, item.configId, item)
    ItemEvent.dispatch(E.ItemChangeType.Add, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
    if not itemsData:GetIgnoreItemTips() then
      quickItemUsageVm.AddItemToQuickUseQueue(item.configId)
    end
    itemsVm.checkItemAutoApply(item)
  elseif changeType == E.ItemChangeType.Delete then
    itemsData:RemoveItem(item)
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.DelItem, item)
    ItemEvent.dispatch(E.ItemChangeType.Delete, E.ItemAddEventType.ItemId, item.configId, item)
    ItemEvent.dispatch(E.ItemChangeType.Delete, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
    quickItemUsageVm.DelQuickItemData(item.configId)
  elseif changeType == E.ItemChangeType.Change then
    itemsData:UpdateItem(item)
    Z.EventMgr:Dispatch(Z.ConstValue.Backpack.ItemCountChange, item)
    ItemEvent.dispatch(E.ItemChangeType.Change, E.ItemAddEventType.ItemId, item.configId, item)
    ItemEvent.dispatch(E.ItemChangeType.Change, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
    if info.count > 0 then
      Z.EventMgr:Dispatch(Z.ConstValue.Backpack.InsertItem, item)
      ItemEvent.dispatch(E.ItemChangeType.Insert, E.ItemAddEventType.ItemId, item.configId, item)
      ItemEvent.dispatch(E.ItemChangeType.Insert, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
      quickItemUsageVm.AddItemToQuickUseQueue(item.configId)
      itemsVm.checkItemAutoApply(item)
    elseif info.count < 0 then
      ItemEvent.dispatch(E.ItemChangeType.Reduce, E.ItemAddEventType.ItemId, item.configId, item)
      ItemEvent.dispatch(E.ItemChangeType.Reduce, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
      quickItemUsageVm.DelQuickItemData(item.configId)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Backpack.AllChange, item)
  ItemEvent.dispatch(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, item.configId, item)
  ItemEvent.dispatch(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemType, itemTableRows[item.configId].Type, item)
end

function ItemEvent.onItemCountChange(item, dirtyKeys)
  if backPackData_.SortState then
    return
  end
  local countDirty = dirtyKeys.count
  if countDirty == nil then
    return
  end
  local changeCount = countDirty:Get() - countDirty:GetLast()
  ItemEvent.onItemCountChangeEvent(item, E.ItemChangeType.Change, {count = changeCount})
  if changeCount < 1 then
    return
  end
  ItemEvent.addItemGetTipsData(item, item.uuid, changeCount)
end

function ItemEvent.onpackageChange(package, dirtyKeys)
  local items = dirtyKeys.items
  if items == nil then
    return
  end
  for k, v in pairs(items) do
    if v:IsNew() then
      local item = package.items[k]
      item.Watcher:RegWatcher(ItemEvent.onItemCountChange)
      if package.type == E.BackPackItemPackageType.Equip then
        equipRed.ChangeEquip(item)
      end
      ItemEvent.onItemCountChangeEvent(item, E.ItemChangeType.Add)
      if not backPackData_.SortState then
        if not backPackData_.NewPackageItems[package.type] then
          backPackData_.NewPackageItems[package.type] = {}
        end
        if not backPackData_.NewPackageItems[package.type][k] then
          backPackData_.NewPackageItems[package.type][k] = k
        end
        if not backPackData_.NewItems[k] then
          backPackData_.NewItems[k] = k
        end
        ItemEvent.addItemGetTipsData(item, k, item.count)
      end
    end
    if v:IsDel() then
      if package.type == E.BackPackItemPackageType.Equip then
        equipRed.DelEquip(v:GetLast())
      end
      bagRed.RemoveRed(k)
      ItemEvent.onItemCountChangeEvent(v:GetLast(), E.ItemChangeType.Delete)
    end
  end
end

function ItemEvent.WatcherItemsChange()
  ItemEvent.initData()
  local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages
  for _, v in pairs(packages) do
    local package = v
    package.Watcher:RegWatcher(ItemEvent.onpackageChange)
    for _, item in pairs(package.items) do
      item.Watcher:RegWatcher(ItemEvent.onItemCountChange)
      itemsVm.setQuickBar(item.configId)
    end
  end
  itemsData:InitItemIdsMap()
end

function ItemEvent.addItemGetTipsData(item, uuid, changeCount)
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableRow = itemTableMgr.GetRow(item.configId)
  if not itemTableRow or itemTableRow.GetTips == 1 then
    return
  end
  local tipsData = Z.DataMgr.Get("tips_data")
  local itemGetTipsData = {
    ItemUuid = uuid,
    ItemConfigId = item.configId,
    ChangeCount = changeCount
  }
  tipsData:AddSystemTipInfo(E.ESystemTipInfoType.ItemInfo, itemGetTipsData.ItemConfigId, itemGetTipsData.ChangeCount)
  if itemsData:GetIgnoreItemTips() then
    return
  end
  if itemTableRow.SpecialDisplayType == E.ItemSpecialDisplayType.FashionAndVehicle then
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FashionAndVehicle, "com_rewards_window", {
      configId = item.configId
    })
  elseif not itemTableRow.IsSpecialDisplay then
    tipsData:PushAcquireItemInfo(itemGetTipsData)
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.ItemGet, "acquiretip")
  elseif itemTableRow.SpecialDisplayType == E.ItemSpecialDisplayType.Mod then
  elseif itemTableRow.SpecialDisplayType == E.ItemSpecialDisplayType.Talent then
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "talent_award_window", {itemData = itemGetTipsData}, 9999)
  elseif itemTableRow.SpecialDisplayType == E.ItemSpecialDisplayType.ResonanceSkill then
    Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.ResonanceSkillGet, "weapon_resonance_obtain_popup", {itemData = itemGetTipsData})
  end
  ItemEvent.showExpireItemTips(item)
end

function ItemEvent.showExpireItemTips(item)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemsTableMgr.GetRow(item.configId)
  if itemTableData and itemTableData.TimeType ~= 0 then
    local time = item.expireTime - Z.ServerTime:GetServerTime()
    if time < 0 then
      local param = {
        item = {
          name = itemTableData.Name
        }
      }
      Z.TipsVM.ShowTipsLang(100106, param)
    end
  end
end

return ItemEvent
