local super = require("ui.model.data_base")
local HomeEditorData = class("HomeEditorData", super)

function HomeEditorData:ctor()
  super.ctor(self)
end

function HomeEditorData:Init()
  self.homeCfgDatas_ = {}
  self.homeLandId = -1
  self.homeCfgItemDatas_ = {}
  self.AlignMoveValue = 1
  self.AlignRotateValue = 1
  self.AlignHightValue = 1
  self.HomelandFurnitureWarehouseGrid = {}
  self.IsDrag = false
  self.IsAlign = false
  self.IsAbsorb = false
  self.LangData = {}
  self.HomelandDatas = {}
  self.CommunityDatas = {}
  self.FurnitureGroupInfo = {}
  self.FurnitureGroupInfoDic = {}
  self.IsMultiSelected = false
  self.IsOperationState = false
  self.IsEditingItemMat = false
  self.LocalCreateHomeFurnitureDic = {}
  self.CancelSource = Z.CancelSource.Rent()
  self.HouseItemConfigUUidMap = {}
  self.HouseItemUUidMap = {}
  self.HouseItemTypeCountMap = {}
  self.SelectedGroupId = 0
  self.SelectedTypeId = 0
  self.HousingGroupTypeMap = {}
  self.HousingItemsTypeMap = {}
  self:InitCfgData()
end

function HomeEditorData:InitTab()
  self.LocalCreateHomeFurnitureDic = {}
  self.CurMultiSelectedEntIds = {}
  self.CurMultiSelectedGroupIds = {}
  self.IsGroupEditorState = false
  self.CurEditorGroupId = nil
  self.CurEditorGroupEntityId = nil
  self.CurSelectedList = {}
end

function HomeEditorData:InitCopyTab()
  self.CopyUUidList = {}
  self.CopyClientUidList = {}
  self.CopyItemCount = 0
end

function HomeEditorData:InitCfgData()
  self.HousingItemsTypeGroupDatas = Z.TableMgr.GetTable("HousingItemsTypeGroupMgr").GetDatas()
  self.HousingItemsTypeDatas = Z.TableMgr.GetTable("HousingItemsTypeMgr").GetDatas()
  self.HousingGroupTypeMap = {}
  for index, value in pairs(self.HousingItemsTypeDatas) do
    if self.HousingGroupTypeMap[value.GroupId] == nil then
      self.HousingGroupTypeMap[value.GroupId] = {}
    end
    local data = self.HousingGroupTypeMap[value.GroupId]
    data[#data + 1] = value.Id
  end
  self.HousingItemsTypeMap = {}
  local housingItemsRows = Z.TableMgr.GetTable("HousingItemsMgr").GetDatas()
  for index, value in pairs(housingItemsRows) do
    if value.Exist then
      if self.HousingItemsTypeMap[value.Type] == nil then
        self.HousingItemsTypeMap[value.Type] = {}
      end
      local data = self.HousingItemsTypeMap[value.Type]
      data[#data + 1] = value.Id
    end
  end
  for index, value in pairs(self.HousingItemsTypeMap) do
    table.sort(value, function(leftId, rightId)
      local leftItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", leftId)
      local rightItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", rightId)
      if leftItemsRow and rightItemsRow then
        return leftItemsRow.SortId < rightItemsRow.SortId
      end
      return false
    end)
  end
end

function HomeEditorData:OnLanguageChange()
  self:InitCfgData()
end

function HomeEditorData:Clear()
  self.HouseItemConfigUUidMap = {}
  self.HouseItemUUidMap = {}
  self.HouseItemTypeCountMap = {}
  self.LocalCreateHomeFurnitureDic = {}
  self.LangData = {}
  self.HomelandDatas = {}
  self.CommunityDatas = {}
  self.FurnitureGroupInfo = {}
  self.FurnitureGroupInfoDic = {}
end

function HomeEditorData:UnInit()
  self.CancelSource:Recycle()
end

function HomeEditorData:CreateHomeFurniture(configId)
  if self.LocalCreateHomeFurnitureDic[configId] then
    self.LocalCreateHomeFurnitureDic[configId] = self.LocalCreateHomeFurnitureDic[configId] + 1
  else
    self.LocalCreateHomeFurnitureDic[configId] = 1
  end
end

function HomeEditorData:EntityDestroyed(configId)
  if self.LocalCreateHomeFurnitureDic[configId] then
    self.LocalCreateHomeFurnitureDic[configId] = self.LocalCreateHomeFurnitureDic[configId] - 1
    if self.LocalCreateHomeFurnitureDic[configId] < 0 then
      self.LocalCreateHomeFurnitureDic[configId] = 0
    end
  else
    self.LocalCreateHomeFurnitureDic[configId] = 0
  end
end

function HomeEditorData:SetHomeCfgDatas(data)
  self.homeCfgDatas_ = data
end

function HomeEditorData:GetHomeCfgDatas()
  return self.homeCfgDatas_
end

function HomeEditorData:SetHomeCfgItemDatas(data)
  self.homeCfgItemDatas_ = data
end

function HomeEditorData:GetHomeCfgItemDatasByGroup(groupId)
  return self.homeCfgItemDatas_[groupId]
end

function HomeEditorData:SetHomeLandId(homeLandId)
  self.homeLandId = homeLandId
end

function HomeEditorData:GetHomeLandId()
  return self.homeLandId
end

function HomeEditorData:SetAlignState(state)
  self.IsAlign = state
end

function HomeEditorData:GetAlignState()
  return self.IsAlign
end

function HomeEditorData:SetLangData(clientUuid, itemId)
  self.LangData[clientUuid] = itemId
end

function HomeEditorData:GetLangData(clientUuid)
  self:GetHouseItemList()
  return self.HouseItemUUidMap[clientUuid] ~= nil
end

function HomeEditorData:SetCommunityDatas(homelandDatas)
  self.CommunityDatas = homelandDatas
end

function HomeEditorData:GetCommunityDatas()
  return self.CommunityDatas
end

function HomeEditorData:SetHomelandDatas(homelandDatas)
  self.HomelandDatas = homelandDatas
end

function HomeEditorData:GetHomelandDatas()
  return self.HomelandDatas
end

function HomeEditorData:UpdateHomelandFurnitureWarehouseGrid(furnitureGrids)
  for slotId, value in pairs(furnitureGrids) do
    self.HomelandFurnitureWarehouseGrid[slotId] = value
  end
end

function HomeEditorData:RemoveHomelandFurnitureWarehouseGrid(removeInstances)
  for slotId, instanceId in pairs(removeInstances) do
    if self.HomelandFurnitureWarehouseGrid[slotId] and self.HomelandFurnitureWarehouseGrid[slotId].InstanceId == instanceId then
      self.HomelandFurnitureWarehouseGrid[slotId] = nil
    end
  end
end

function HomeEditorData:AddHomelandFurnitureWarehouseGrid(addInstances)
  for slotId, value in pairs(addInstances) do
    if self.HomelandFurnitureWarehouseGrid[slotId] then
      self.HomelandFurnitureWarehouseGrid[slotId].InstanceId = value.InstanceId
      self.HomelandFurnitureWarehouseGrid[slotId].ConfigId = value.ConfigId
      for charId, item in pairs(value.ownerToStackMap) do
        self.HomelandFurnitureWarehouseGrid[slotId].ownerToStackMap[charId] = item
      end
    else
      self.HomelandFurnitureWarehouseGrid[slotId] = value
    end
  end
end

function HomeEditorData:GetItemIsHouseWarehouseItem(itemId)
  local itemsVm = Z.VMMgr.GetVM("items")
  return itemsVm.CheckPackageTypeByConfigId(itemId, E.BackPackItemPackageType.HouseCurrency) or itemsVm.CheckPackageTypeByConfigId(itemId, E.BackPackItemPackageType.HouseItem)
end

function HomeEditorData:GetFurnitureWarehouseItem(itemId, isSelf)
  local homeLandItems = {}
  local index = 1
  for _, instance in pairs(self.HomelandFurnitureWarehouseGrid) do
    if instance.ConfigId == itemId then
      local isAdd = false
      if not isSelf then
        isAdd = true
      else
        for charId, value in pairs(instance.ownerToStackMap) do
          if charId == Z.ContainerMgr.CharSerialize.charId then
            isAdd = true
            break
          end
        end
      end
      if isAdd then
        homeLandItems[index] = instance
        index = index + 1
      end
    end
  end
  return homeLandItems
end

function HomeEditorData:GetFurnitureWarehouseItemCount(itemId)
  local count = 0
  for index, value in pairs(self.HomelandFurnitureWarehouseGrid) do
    if value.ConfigId == itemId then
      for key, item in pairs(value.ownerToStackMap) do
        count = count + item.count
      end
    end
  end
  return count
end

function HomeEditorData:GetSelfFurnitureWarehouseItemCount(itemId)
  local count = 0
  for index, value in pairs(self.HomelandFurnitureWarehouseGrid) do
    if value.ConfigId == itemId then
      for charId, item in pairs(value.ownerToStackMap) do
        if charId == Z.ContainerMgr.CharSerialize.charId then
          count = count + item.count
        end
      end
    end
  end
  return count
end

function HomeEditorData:ResetHomeItemMap()
  self.HouseItemConfigUUidMap = {}
  self.HouseItemUUidMap = {}
  self.HouseItemTypeCountMap = {}
  self:initHouseItemList()
end

function HomeEditorData:initHouseItemList()
  local isHave = false
  for key, value in pairs(self.HouseItemConfigUUidMap) do
    isHave = true
    break
  end
  if not isHave then
    local itemList = Z.DIServiceMgr.HomeService:GetHouseItemList(Z.ContainerMgr.CharSerialize.communityHomeInfo.homelandId)
    if itemList then
      for uuid, configId in pairs(itemList) do
        local uuid = tonumber(uuid)
        self.HouseItemUUidMap[uuid] = configId
        if self.HouseItemConfigUUidMap[configId] == nil then
          self.HouseItemConfigUUidMap[configId] = {}
        end
        local data = self.HouseItemConfigUUidMap[configId]
        data[#data + 1] = uuid
        self:ChangeHouseItemTypeCount(configId, 1)
      end
    end
  end
end

function HomeEditorData:AddHouseItem(itemId, uid)
  self:initHouseItemList()
  if self.HouseItemConfigUUidMap[itemId] == nil then
    self.HouseItemConfigUUidMap[itemId] = {}
  end
  local data = self.HouseItemConfigUUidMap[itemId]
  if not table.zcontains(data, uid) then
    data[#data + 1] = uid
  end
  if self.HouseItemUUidMap then
    self.HouseItemUUidMap[uid] = itemId
  end
  self:ChangeHouseItemTypeCount(itemId, 1)
end

function HomeEditorData:ChangeHouseItemTypeCount(itemId, changeCount)
  local housingItemsRow = Z.TableMgr.GetRow("HousingItemsMgr", itemId)
  local nowCount = self.HouseItemTypeCountMap[housingItemsRow.Type] or 0
  if housingItemsRow then
    self.HouseItemTypeCountMap[housingItemsRow.Type] = nowCount + changeCount
  end
end

function HomeEditorData:GetHouseItemTypeCount(type)
  return self.HouseItemTypeCountMap[type] or 0
end

function HomeEditorData:DelHouseItem(itemId, uid)
  self:initHouseItemList()
  local data = self.HouseItemConfigUUidMap[itemId]
  if data then
    for index, value in ipairs(data) do
      if value == uid then
        table.remove(data, index)
        self:ChangeHouseItemTypeCount(itemId, -1)
        break
      end
    end
  end
  if self.HouseItemUUidMap then
    self.HouseItemUUidMap[uid] = nil
  end
end

function HomeEditorData:GetItemIdByUid(uid)
  return self.HouseItemUUidMap[uid]
end

function HomeEditorData:GetHouseItemList()
  self:initHouseItemList()
  return self.HouseItemConfigUUidMap
end

return HomeEditorData
