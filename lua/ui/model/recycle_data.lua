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
      if self.recycleItemConfigDict_[row.FunctionId] == nil then
        self.recycleItemConfigDict_[row.FunctionId] = {}
      end
      self.recycleItemConfigDict_[row.FunctionId][row.ItemID] = row
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
  local itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  local sortFunc = itemSortFactoryVm_.GetItemSortFunc(E.BackPackItemPackageType.RecycleItem, sortData)
  local ownItemList = itemsVM.GetItemIds(E.BackPackItemPackageType.Item, nil, sortFunc, false)
  for i, v in ipairs(ownItemList) do
    if recycleItemDict[v.configId] then
      table.insert(resultList, v)
    end
  end
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

function RecycleData:AddTempRecycleData(data)
  if self.tempRecycleData_[data.configId] == nil then
    self.tempRecycleData_[data.configId] = {}
  end
  local count = self.tempRecycleData_[data.configId][data.itemUuid] or 0
  self.tempRecycleData_[data.configId][data.itemUuid] = count + 1
end

function RecycleData:ReduceTempRecycleData(data)
  if self.tempRecycleData_[data.configId] == nil then
    self.tempRecycleData_[data.configId] = {}
  end
  local count = self.tempRecycleData_[data.configId][data.itemUuid] or 0
  self.tempRecycleData_[data.configId][data.itemUuid] = count - 1
end

function RecycleData:GetTempRecycleCount(data)
  if self.tempRecycleData_[data.configId] == nil then
    return 0
  end
  local count = self.tempRecycleData_[data.configId][data.itemUuid] or 0
  return count
end

function RecycleData:SetTempRecycleItemSelect(itemUuid, isSelect)
  self.tempSelectRecycleDict_[itemUuid] = isSelect
end

function RecycleData:GetTempRecycleItemSelect(itemUuid)
  return self.tempSelectRecycleDict_[itemUuid]
end

function RecycleData:GetTempRecycleRolumnCount()
  local rolumnCount = 0
  for configId, info in pairs(self.tempRecycleData_) do
    for itemUuid, count in pairs(info) do
      if 0 < count then
        rolumnCount = rolumnCount + 1
      end
    end
  end
  return rolumnCount
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
  for i, info in ipairs(tempRecycleList) do
    local itemInfo = recycleItemDict[info.configId]
    if itemInfo then
      local recycleInfo = {
        recycleId = itemInfo.Id,
        itemUuid = info.itemUuid,
        count = info.count
      }
      table.insert(itemList, recycleInfo)
    end
  end
  return itemList
end

return RecycleData
