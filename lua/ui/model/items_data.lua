local super = require("ui.model.data_base")
local ItemData = class("ItemData", super)

function ItemData:ctor()
  super.ctor(self)
  self.itemConfigIdUuidsMap_ = nil
  self.itemUuidPackageIdMap_ = nil
  self.groupCd_ = {}
  self.recastTips = true
  self.ignoreItemTips_ = false
  self.itemTotalCount_ = {}
end

function ItemData:Init(...)
  self.ItemTableDatas = Z.TableMgr.GetTable("ItemTableMgr").GetDatas()
end

function ItemData:Clear()
  self.recastTips = true
  self.ignoreItemTips_ = false
end

function ItemData:InitItemIdsMap()
  self:ClearItemIdsMap()
  self.itemConfigIdUuidsMap_ = {}
  self.itemUuidPackageIdMap_ = {}
  self.itemTotalCount_ = {}
  local itemPackage = Z.ContainerMgr.CharSerialize.itemPackage
  for _, package in pairs(itemPackage.packages) do
    for _, item in pairs(package.items) do
      self:UpdateItem(item)
      if self.itemTotalCount_[item.configId] == nil then
        self.itemTotalCount_[item.configId] = item.count
      else
        self.itemTotalCount_[item.configId] = self.itemTotalCount_[item.configId] + item.count
      end
    end
  end
end

function ItemData:ClearItemIdsMap()
  self.itemConfigIdUuidsMap_ = nil
  self.itemUuidPackageIdMap_ = nil
end

function ItemData:GetItemUuidsByConfigId(configId)
  if self.itemConfigIdUuidsMap_ then
    return self.itemConfigIdUuidsMap_[configId]
  end
  return nil
end

function ItemData:GetItemPackageType(itemUuid)
  if self.itemUuidPackageIdMap_ then
    return self.itemUuidPackageIdMap_[itemUuid]
  end
  return nil
end

function ItemData:UpdateItem(item)
  if not item then
    return
  end
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTypeMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local itemTableBae = itemTableMgr.GetRow(item.configId)
  if itemTableBae then
    local itemTypeTableRow = itemTypeMgr.GetRow(itemTableBae.Type)
    if itemTypeTableRow then
      self.itemUuidPackageIdMap_[item.uuid] = itemTypeTableRow.Package
    end
    local uuids = self.itemConfigIdUuidsMap_[item.configId]
    if uuids then
      if table.zcontains(uuids, item.uuid) then
        return
      end
      table.insert(uuids, item.uuid)
    else
      self.itemConfigIdUuidsMap_[item.configId] = {
        item.uuid
      }
    end
  end
end

function ItemData:RemoveItem(item)
  if not item then
    return
  end
  self.itemUuidPackageIdMap_[item.uuid] = nil
  if self.itemConfigIdUuidsMap_[item.configId] then
    table.zremoveByValue(self.itemConfigIdUuidsMap_[item.configId], item.uuid, true)
  end
end

function ItemData:CreatCancelSource()
  if self.CancelSource == nil then
    self.CancelSource = Z.CancelSource.Rent()
  end
end

function ItemData:RecycleCancelSource()
  if self.CancelSource then
    self.CancelSource:Recycle()
    self.CancelSource = nil
  end
end

function ItemData:SetGroupCd(groupId, cd)
  self.groupCd_[groupId] = cd
end

function ItemData:GetGroupCd(groupId)
  return self.groupCd_[groupId]
end

function ItemData:SetKeyRecastTips(needTips)
  self.recastTips = needTips
end

function ItemData:GetKeyRecastTips()
  return self.recastTips
end

function ItemData:UnInit()
  if self.CancelSource then
    self.CancelSource:Recycle()
  end
end

function ItemData:SetIgnoreItemTips(isIgnore)
  self.ignoreItemTips_ = isIgnore
end

function ItemData:GetIgnoreItemTips()
  return self.ignoreItemTips_
end

function ItemData:GetItemTotalCount(config)
  if self.itemTotalCount_[config] ~= nil then
    return self.itemTotalCount_[config]
  end
  return 0
end

function ItemData:ChangeItemTotalCount(config, changeValue)
  if self.itemTotalCount_[config] ~= nil then
    self.itemTotalCount_[config] = self.itemTotalCount_[config] + changeValue
  else
    self.itemTotalCount_[config] = changeValue
  end
  self.itemTotalCount_[config] = math.max(0, self.itemTotalCount_[config])
end

function ItemData:SetItemTotalCount(config, count)
  self.itemTotalCount_[config] = count
end

function ItemData:GetAllQuickUseItemConfigWithCount()
  if self.quickUseItemMap then
    return self.quickUseItemMap
  end
  self.quickUseItemMap = {}
  for k, v in pairs(self.ItemTableDatas) do
    local itemFunctionTableRow = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(v.Id, true)
    if itemFunctionTableRow and itemFunctionTableRow.CanQuick == 1 then
      table.insert(self.quickUseItemMap, v.Id)
    end
  end
  return self.quickUseItemMap
end

return ItemData
