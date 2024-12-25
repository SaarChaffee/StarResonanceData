local closeRefineSystemView = function()
  Z.UIMgr:CloseView("refine_system")
end
local setItemSelected = function(index)
  local refineData = Z.DataMgr.Get("refine_data")
  refineData.ItemsSelected = index
end
local setSmashItemData = function(id, count)
  local refineData = Z.DataMgr.Get("refine_data")
  refineData:SetSmashItemData(id, count)
end
local setAddEnergy = function(count, isAdd)
  local refineData = Z.DataMgr.Get("refine_data")
  local nowAddEnergy = refineData:GetAddEnergy()
  if isAdd then
    local energy = nowAddEnergy + count
    refineData:SetAddEnergy(energy)
  else
    local energy = nowAddEnergy - count
    if energy < 0 then
      energy = 0
    end
    refineData:SetAddEnergy(energy)
  end
end
local setSmashItemConfigData = function(configId, smashId, count, isAdd)
  local refineData = Z.DataMgr.Get("refine_data")
  refineData:SetSmashItemConfigData(configId, count, isAdd)
  local resolveCfg = Z.TableMgr.GetTable("ResolveTableMgr").GetRow(smashId)
  if resolveCfg then
    setAddEnergy(resolveCfg.GetItem[2], isAdd)
  end
end
local resetSmashItemData = function()
  local refineData = Z.DataMgr.Get("refine_data")
  refineData:ResetSmashItemData()
end
local setRefineItemListData = function(queueIndex, columnIndex, status)
  local refineData = Z.DataMgr.Get("refine_data")
  refineData:SetRefineItemListData(queueIndex, columnIndex, status)
end
local getShowItemIds = function()
  local ids = {}
  local package = Z.ContainerMgr.CharSerialize.itemPackage.packages[1]
  local resolveCfg = Z.TableMgr.GetTable("ResolveTableMgr").GetDatas()
  for _, item in pairs(package.items) do
    for _, v in pairs(resolveCfg) do
      if item.configId == v.ItemID then
        table.insert(ids, {
          uuid = item.uuid,
          configId = item.configId,
          smashId = v.Id
        })
        break
      end
    end
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  table.sort(ids, itemsVm.BackpackItemsSort)
  return ids
end
local onEnergyItemInfoChange = function(energyItemInfo, dirtyKeys)
  if dirtyKeys.refineState then
    Z.EventMgr:Dispatch(Z.ConstValue.Refine.RefreshItemStatus, energyItemInfo)
  end
end
local onEnergyInfoChange = function(energyInfo, dirtyKeys)
  local energyItemInfo = dirtyKeys.energyItemInfo or {}
  for k, v in pairs(energyItemInfo) do
    if v:IsNew() then
      local energyItemInfo = energyInfo.energyItemInfo[k]
      energyItemInfo.Watcher:RegWatcher(onEnergyItemInfoChange)
    end
  end
end
local onEnergyItemChange = function(energyItem, dirtyKeys)
  if dirtyKeys.energyLimit then
    Z.EventMgr:Dispatch(Z.ConstValue.Refine.RefreshEnergy)
  end
  local energyInfo = dirtyKeys.energyInfo or {}
  for k, v in pairs(energyInfo) do
    if v:IsNew() then
      local energyInfo = energyItem.energyInfo[k]
      energyInfo.Watcher:RegWatcher(onEnergyInfoChange)
    end
  end
end
local watcherRefineChange = function()
  local energyItem = Z.ContainerMgr.CharSerialize.energyItem
  energyItem.Watcher:RegWatcher(onEnergyItemChange)
  local energyInfo = energyItem.energyInfo
  for k, v in pairs(energyInfo) do
    v.Watcher:RegWatcher(onEnergyInfoChange)
    for k2, v2 in pairs(v.energyItemInfo) do
      local energyItemInfo = v2
      energyItemInfo.Watcher:RegWatcher(onEnergyItemInfoChange)
    end
  end
end
local refineUnRegWatcher = function()
  local energyItem = Z.ContainerMgr.CharSerialize.energyItem
  energyItem.Watcher:UnregWatcher(onEnergyItemChange)
  local energyInfo = energyItem.energyInfo
  for k1, v1 in pairs(energyInfo) do
    for k2, v2 in pairs(v1.energyItemInfo) do
      v2.Watcher:UnregWatcher(onEnergyItemInfoChange)
    end
  end
end
local showError = function(ret)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local asyncDecomposeItem = function(itemDict, funcId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.DecomposeItem(itemDict, funcId, cancelToken)
  return showError(ret)
end
local asyncAddEnergyLimit = function(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.AddEnergyLimit(cancelToken)
  return showError(ret)
end
local asyncRefineItem = function(queueIndex, columnIndex, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.RefineItem(queueIndex, columnIndex, cancelToken)
  return showError(ret)
end
local asyncGainItem = function(queueIndex, columnIndex, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.GainItem(queueIndex, columnIndex, cancelToken)
  return showError(ret)
end
local asyncUnlockItem = function(queueIndex, columnIndex, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.UnlockItem(queueIndex, columnIndex, cancelToken)
  return showError(ret)
end
local asyncInstantRefine = function(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.InstantRefine(cancelToken)
  return showError(ret)
end
local asyncInstantReceive = function(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.InstantReceive(cancelToken)
  return showError(ret)
end
local timeFormat = function(time)
  local hour = math.floor(time / 3600)
  local minute = math.fmod(math.floor(time / 60), 60)
  local second = math.fmod(time, 60)
  if hour < 10 then
    hour = "0" .. hour
  end
  if minute < 10 then
    minute = "0" .. minute
  end
  if second < 10 then
    second = "0" .. second
  end
  local rtTime = string.format("%s:%s:%s", hour, minute, second)
  return rtTime
end
local ret = {
  CloseRefineSystemView = closeRefineSystemView,
  GetShowItemIds = getShowItemIds,
  SetItemSelected = setItemSelected,
  SetSmashItemData = setSmashItemData,
  SetSmashItemConfigData = setSmashItemConfigData,
  SetAddEnergy = setAddEnergy,
  WatcherRefineChange = watcherRefineChange,
  RefineUnRegWatcher = refineUnRegWatcher,
  ResetSmashItemData = resetSmashItemData,
  AsyncDecomposeItem = asyncDecomposeItem,
  AsyncAddEnergyLimit = asyncAddEnergyLimit,
  AsyncRefineItem = asyncRefineItem,
  AsyncGainItem = asyncGainItem,
  AsyncUnlockItem = asyncUnlockItem,
  AsyncInstantRefine = asyncInstantRefine,
  AsyncInstantReceive = asyncInstantReceive,
  SetRefineItemListData = setRefineItemListData,
  TimeFormat = timeFormat
}
return ret
