local super = require("ui.model.data_base")
local RecycleData = class("RecycleData", super)

function RecycleData:ctor()
end

function RecycleData:Init()
  self.recycleConfigDict_ = nil
  self.recycleItemConfigDict_ = nil
end

function RecycleData:Clear()
end

function RecycleData:UnInit()
end

function RecycleData:GetRecycleRowByFuncId(funcId)
  if self.recycleConfigDict_ == nil then
    self.recycleConfigDict_ = {}
    local recycleTableMgr = Z.TableMgr.GetTable("RecycleTableMgr")
    local recycleTableRows = recycleTableMgr:GetDatas()
    for id, row in pairs(recycleTableRows) do
      self.recycleConfigDict_[row.SystemId] = row
    end
  end
  return self.recycleConfigDict_[funcId]
end

function RecycleData:GetAllRecycleItemDict()
  if self.recycleItemConfigDict_ == nil then
    self.recycleItemConfigDict_ = {}
    local recycleItemTableMgr = Z.TableMgr.GetTable("RecycleItemTableMgr")
    local recycleItemTableRows = recycleItemTableMgr:GetDatas()
    for id, row in pairs(recycleItemTableRows) do
      if not row.IsBlocked then
        if self.recycleItemConfigDict_[row.FunctionId] == nil then
          self.recycleItemConfigDict_[row.FunctionId] = {}
        end
        self.recycleItemConfigDict_[row.FunctionId][row.ItemID] = row
      end
    end
  end
  return self.recycleItemConfigDict_
end

function RecycleData:GetRecycleItemDictByFunctionId(functionId)
  local allRecycleItemDict = self:GetAllRecycleItemDict()
  return allRecycleItemDict[functionId]
end

function RecycleData:GetTotalCanRecycleItems(functionId, sortData)
  local resultList = {}
  local recycleItemDict = self:GetRecycleItemDictByFunctionId(functionId)
  if recycleItemDict == nil then
    return resultList
  end
  local itemsVM = Z.VMMgr.GetVM("items")
  local itemData = Z.DataMgr.Get("items_data")
  if functionId == E.FunctionID.HomeFlowerRecycle then
    local homeData = Z.DataMgr.Get("home_editor_data")
    for configId, row in pairs(recycleItemDict) do
      local items = homeData:GetFurnitureWarehouseItem(configId, true)
      if items and 0 < #items then
        for i, item in ipairs(items) do
          table.insert(resultList, item)
        end
      end
    end
  else
    for configId, row in pairs(recycleItemDict) do
      local uuidList = itemData:GetItemUuidsByConfigId(configId)
      if uuidList and 0 < #uuidList then
        for i, uuid in ipairs(uuidList) do
          table.insert(resultList, {itemUuid = uuid, configId = configId})
        end
      end
    end
  end
  local itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  local sortFunc = itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.RecycleItem, sortData)
  table.sort(resultList, sortFunc)
  return resultList
end

function RecycleData:InitTempRecycleData()
  self.tempRecycleData_ = {}
  self.tempSelectRecycleDict_ = {}
end

function RecycleData:ClearTempRecycleData()
  self.tempRecycleData_ = {}
  self.tempSelectRecycleDict_ = {}
end

function RecycleData:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  local configId = 0
  local itemUid = 0
  if functionId == E.FunctionID.HomeFlowerRecycle then
    configId = data.ConfigId
    itemUid = data.InstanceId
  else
    configId = data.configId
    itemUid = data.itemUuid
  end
  return configId, itemUid
end

function RecycleData:SetTempRecycleData(data, functionId, cnt)
  local configId, uid = self:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  if self.tempRecycleData_[configId] == nil then
    self.tempRecycleData_[configId] = {}
  end
  self.tempRecycleData_[configId][uid] = cnt
end

function RecycleData:AddTempRecycleData(data, functionId)
  local configId, uid = self:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  if self.tempRecycleData_[configId] == nil then
    self.tempRecycleData_[configId] = {}
  end
  local count = self.tempRecycleData_[configId][uid] or 0
  self.tempRecycleData_[configId][uid] = count + 1
end

function RecycleData:ReduceTempRecycleData(data, functionId)
  local configId, uid = self:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  if self.tempRecycleData_[configId] == nil then
    self.tempRecycleData_[configId] = {}
  end
  local count = self.tempRecycleData_[configId][uid] or 0
  if count == 1 then
    return
  end
  self.tempRecycleData_[configId][uid] = count - 1
end

function RecycleData:ClearCurTempRecycleData(data, functionId)
  local configId, uid = self:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  if self.tempRecycleData_[configId] == nil then
    self.tempRecycleData_[configId] = {}
  end
  self.tempRecycleData_[configId][uid] = 0
end

function RecycleData:GetTempRecycleCount(data, functionId)
  local configId, uid = self:GetConfigIdAndUidByDataAndFunctionId(data, functionId)
  if self.tempRecycleData_[configId] == nil then
    return 0
  end
  local count = self.tempRecycleData_[configId][uid] or 0
  return count
end

function RecycleData:SetTempRecycleItemSelect(itemUuid, isSelect)
  self.tempSelectRecycleDict_[itemUuid] = isSelect
end

function RecycleData:GetTempRecycleItemSelect(itemUuid)
  return self.tempSelectRecycleDict_[itemUuid]
end

function RecycleData:GetTempRecycleColumnCount()
  local columnCount = 0
  for configId, info in pairs(self.tempRecycleData_) do
    for itemUuid, count in pairs(info) do
      if 0 < count then
        columnCount = columnCount + 1
      end
    end
  end
  return columnCount
end

function RecycleData:GetTempRecycleList()
  local resultList = {}
  for configId, info in pairs(self.tempRecycleData_) do
    for itemUuid, count in pairs(info) do
      if 0 < count then
        table.insert(resultList, {
          configId = configId,
          itemUuid = itemUuid,
          count = count
        })
      end
    end
  end
  table.sort(resultList, function(a, b)
    if a.configId == b.configId then
      return a.itemUuid < b.itemUuid
    else
      return a.configId < b.configId
    end
  end)
  return resultList
end

function RecycleData:GetRecycleObtainList(functionId, tempRecycleList)
  local recycleItemDict = self:GetRecycleItemDictByFunctionId(functionId)
  if recycleItemDict == nil then
    return {}
  end
  local awardPreviewVM = Z.VMMgr.GetVM("awardpreview")
  local awardIdList = {}
  for i, info in ipairs(tempRecycleList) do
    local itemInfo = recycleItemDict[info.configId]
    if itemInfo and #itemInfo.GetItem > 0 then
      for j = 1, info.count do
        table.zmerge(awardIdList, itemInfo.GetItem)
      end
    end
  end
  local resultList = awardPreviewVM.GetAllAwardPreListByIds(awardIdList)
  return resultList
end

function RecycleData:GetSendServerItemList(functionId, tempRecycleList)
  local recycleItemDict = self:GetRecycleItemDictByFunctionId(functionId)
  if recycleItemDict == nil then
    return
  end
  local itemList = {}
  local isHomeFlower = functionId == E.FunctionID.HomeFlowerRecycle
  for i, info in ipairs(tempRecycleList) do
    local itemInfo = recycleItemDict[info.configId]
    if itemInfo then
      local recycleInfo = {
        recycleId = itemInfo.Id,
        itemUuid = isHomeFlower and info.configId or info.itemUuid,
        count = info.count
      }
      table.insert(itemList, recycleInfo)
    end
  end
  return itemList
end

return RecycleData
