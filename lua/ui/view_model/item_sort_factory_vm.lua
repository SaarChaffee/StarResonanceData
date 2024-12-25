local backpackItemstSort = function(left, right)
  local itemsVm = Z.VMMgr.GetVM("items")
  local leftData = itemsVm.GetItemInfobyItemId(left.itemUuid, left.configId)
  local rightData = itemsVm.GetItemInfobyItemId(right.itemUuid, right.configId)
  local backPackData = Z.DataMgr.Get("backpack_data")
  if backPackData.NewItems[left.itemUuid] and not backPackData.NewItems[right.itemUuid] then
    return true
  elseif not backPackData.NewItems[left.itemUuid] and backPackData.NewItems[right.itemUuid] then
    return false
  end
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local leftItemData
  if leftData then
    leftItemData = itemsTableMgr.GetRow(leftData.configId)
  end
  local rightItemData
  if rightData then
    rightItemData = itemsTableMgr.GetRow(rightData.configId)
  end
  if leftItemData == nil then
    return false
  end
  if rightItemData == nil then
    return false
  end
  local now = Z.TimeTools.Now() / 1000
  local leftIsCool = now < leftData.coolDownExpireTime
  local rightIsCool = now < rightData.coolDownExpireTime
  if leftIsCool and not rightIsCool then
    return false
  elseif not leftIsCool and rightIsCool then
    return true
  end
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local leftType = itemTypeTableMgr.GetRow(leftItemData.Type)
  local rightType = itemTypeTableMgr.GetRow(rightItemData.Type)
  if leftType == nil or rightType == nil then
    return false
  end
  if leftType.SortId < rightType.SortId then
    return true
  elseif leftType.SortId > rightType.SortId then
    return false
  end
  if leftItemData.SortID < rightItemData.SortID then
    return true
  elseif leftItemData.SortID > rightItemData.SortID then
    return false
  end
  if leftData.quality > rightData.quality then
    return true
  elseif leftData.quality < rightData.quality then
    return false
  end
  if leftData.count > rightData.count then
    return true
  elseif leftData.count < rightData.count then
    return false
  end
  if leftData.configId < rightData.configId then
    return true
  end
  return false
end
local LAST_SORT_NUM = 1000
local specialSortDic_
local getSpecialSort = function(itemConfig)
  if specialSortDic_ == nil then
    specialSortDic_ = {}
    local firstList = Z.Global.ItemSortFirst
    for i, v in ipairs(firstList) do
      specialSortDic_[v] = i
    end
    local lastList = Z.Global.ItemSortLast
    for i, v in ipairs(lastList) do
      specialSortDic_[v] = i + LAST_SORT_NUM
    end
  end
  return specialSortDic_[itemConfig.Id]
end
local getTypeSort = function(itemConfig)
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local itemTypeTableRow = itemTypeTableMgr.GetRow(itemConfig.Type)
  return itemTypeTableRow and itemTypeTableRow.PreviewId or 0
end
local defaultSendAwardSort = function(aItemId, bItemId)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local aItemConfig = itemsTableMgr.GetRow(aItemId)
  local bItemConfig = itemsTableMgr.GetRow(bItemId)
  local aSpecialSort = getSpecialSort(aItemConfig) or LAST_SORT_NUM * 0.5
  local bSpecialSort = getSpecialSort(bItemConfig) or LAST_SORT_NUM * 0.5
  if aSpecialSort == bSpecialSort then
    if aItemConfig.Quality == bItemConfig.Quality then
      local aTypeSort = getTypeSort(aItemConfig)
      local bTypeSort = getTypeSort(bItemConfig)
      if aTypeSort == bTypeSort then
        if aItemConfig.SortID == bItemConfig.SortID then
          return aItemConfig.Id < bItemConfig.Id
        else
          return aItemConfig.SortID < bItemConfig.SortID
        end
      else
        return aTypeSort < bTypeSort
      end
    else
      return aItemConfig.Quality > bItemConfig.Quality
    end
  else
    return aSpecialSort < bSpecialSort
  end
end
local defaultPreviewAwardSort = function(a, b)
  return defaultSendAwardSort(a.awardId, b.awardId)
end
local defaultSendAwardSortByConfigId = function(awardList)
  table.sort(awardList, function(a, b)
    return defaultSendAwardSort(a.configId, b.configId)
  end)
end
local sortEquipItems = function(left, right, sortType, isAscending, qualityAscending, gsAscending)
  local itemsVm = Z.VMMgr.GetVM("items")
  local leftData = itemsVm.GetItemInfobyItemId(left.itemUuid, left.configId)
  local rightData = itemsVm.GetItemInfobyItemId(right.itemUuid, right.configId)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local leftItemData = itemsTableMgr.GetRow(leftData.configId)
  local rightItemData = itemsTableMgr.GetRow(rightData.configId)
  local equipTableMgr = Z.TableMgr.GetTable("EquipTableMgr")
  local leftEquipData = equipTableMgr.GetRow(leftData.configId)
  local rightEquipData = equipTableMgr.GetRow(rightData.configId)
  if leftItemData == nil or rightItemData == nil or nil == leftEquipData or rightEquipData == nil then
    return
  end
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  local leftEquipInfo = equipList[leftEquipData.EquipPart]
  local rightEquipInfo = equipList[rightEquipData.EquipPart]
  if leftEquipInfo and leftEquipInfo.itemUuid == left.itemUuid and (not rightEquipInfo or rightEquipInfo.itemUuid ~= right.itemUuid) then
    return true
  elseif (not leftEquipInfo or leftEquipInfo.itemUuid ~= left.itemUuid) and rightEquipInfo and rightEquipInfo.itemUuid == right.itemUuid then
    return false
  end
  if leftEquipData.EquipType == E.EquipPart.Weapon and rightEquipData.EquipType == E.EquipPart.Weapon then
    local equipWeaponTableMgr = Z.TableMgr.GetTable("EquipWeaponTableMgr")
    local leftEquipWeaponRow = equipWeaponTableMgr.GetRow(left.configId)
    local rightEquipWeaponRow = equipWeaponTableMgr.GetRow(left.configId)
    if leftEquipWeaponRow and rightEquipWeaponRow then
      if leftEquipWeaponRow.PerfectLibId > rightEquipWeaponRow.PerfectLibId then
        return true
      elseif leftEquipWeaponRow.PerfectLibId < rightEquipWeaponRow.PerfectLibId then
        return false
      end
    end
  end
  if (sortType == E.EquipItemSortType.Quality or sortType == E.EquipItemSortType.GS) and leftEquipData and rightEquipData then
    if leftEquipData.EquipGs > rightEquipData.EquipGs then
      return not isAscending
    elseif leftEquipData.EquipGs < rightEquipData.EquipGs then
      return isAscending
    end
  end
  if sortType == E.EquipItemSortType.QualityAndGS and leftEquipData and rightEquipData then
    if leftData.quality > rightData.quality then
      return not qualityAscending
    elseif leftData.quality < rightData.quality then
      return qualityAscending
    end
    if leftEquipData.EquipGs > rightEquipData.EquipGs then
      return not gsAscending
    elseif leftEquipData.EquipGs < rightEquipData.EquipGs then
      return gsAscending
    end
  end
  if leftEquipInfo and rightEquipInfo then
    if leftData.equipAttr.perfectionValue > rightData.equipAttr.perfectionValue then
      return not isAscending
    elseif leftData.equipAttr.perfectionValue < rightData.equipAttr.perfectionValue then
      return isAscending
    end
    if leftData.equipAttr.totalRecastCount > rightData.equipAttr.totalRecastCount then
      return not isAscending
    elseif leftData.equipAttr.totalRecastCount < rightData.equipAttr.totalRecastCount then
      return isAscending
    end
  end
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local leftType = itemTypeTableMgr.GetRow(leftItemData.Type)
  local rightType = itemTypeTableMgr.GetRow(rightItemData.Type)
  if leftType == nil or rightType == nil then
    return
  end
  if leftType.SortId < rightType.SortId then
    return true
  elseif leftType.SortId > rightType.SortId then
    return false
  end
  if leftItemData.SortID < rightItemData.SortID then
    return true
  elseif leftItemData.SortID > rightItemData.SortID then
    return false
  end
  if leftData.quality > rightData.quality then
    return true
  elseif leftData.quality < rightData.quality then
    return false
  end
  if leftData.count > rightData.count then
    return true
  end
  if leftData.configId < rightData.configId then
    return true
  end
  return false
end
local equipItemsUpSortByQuality = function(left, right)
  return sortEquipItems(left, right, E.EquipItemSortType.Quality, true)
end
local equipItemsDownSortByQuality = function(left, right)
  return sortEquipItems(left, right, E.EquipItemSortType.Quality, false)
end
local equipItemsUpSortByGS = function(left, right)
  return sortEquipItems(left, right, E.EquipItemSortType.GS, true)
end
local equipItemsDownSortByGS = function(left, right)
  return sortEquipItems(left, right, E.EquipItemSortType.GS, false)
end
local getEquipItemsSortFunc = function(equipSortType, isAscending, qualityAscending, gsAscending)
  if not equipSortType then
    return backpackItemstSort
  end
  if equipSortType == E.EquipItemSortType.Quality and isAscending then
    return equipItemsUpSortByQuality
  elseif equipSortType == E.EquipItemSortType.Quality and not isAscending then
    return equipItemsDownSortByQuality
  elseif equipSortType == E.EquipItemSortType.GS and isAscending then
    return equipItemsUpSortByGS
  elseif equipSortType == E.EquipItemSortType.GS and not isAscending then
    return equipItemsDownSortByGS
  elseif equipSortType == E.EquipItemSortType.QualityAndGS then
    return function(left, right)
      return sortEquipItems(left, right, E.EquipItemSortType.QualityAndGS, isAscending, qualityAscending, gsAscending)
    end
  end
  return backpackItemstSort
end
local sortResonanceItems = function(left, right, sortType, isAscending)
  local itemsVm = Z.VMMgr.GetVM("items")
  local leftData = itemsVm.GetItemInfobyItemId(left.itemUuid, left.configId)
  local rightData = itemsVm.GetItemInfobyItemId(right.itemUuid, right.configId)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local leftItemData = itemsTableMgr.GetRow(leftData.configId)
  local rightItemData = itemsTableMgr.GetRow(rightData.configId)
  if sortType == E.ResonanceItemSortType.Quality then
    if leftData.quality > rightData.quality then
      return isAscending
    elseif leftData.quality < rightData.quality then
      return not isAscending
    end
  end
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local leftType = itemTypeTableMgr.GetRow(leftItemData.Type)
  local rightType = itemTypeTableMgr.GetRow(rightItemData.Type)
  if leftType == nil or rightType == nil then
    return
  end
  if leftType.SortId < rightType.SortId then
    return true
  elseif leftType.SortId > rightType.SortId then
    return false
  end
  if leftItemData.SortID < rightItemData.SortID then
    return true
  elseif leftItemData.SortID > rightItemData.SortID then
    return false
  end
  if leftData.quality > rightData.quality then
    return true
  elseif leftData.quality < rightData.quality then
    return false
  end
  if leftData.count > rightData.count then
    return true
  end
  if leftData.configId < rightData.configId then
    return true
  end
  return false
end
local resonanceItemsUpSortByQuality = function(left, right)
  return sortResonanceItems(left, right, E.ResonanceItemSortType.Quality, true)
end
local resonanceItemsDownSortByQuality = function(left, right)
  return sortResonanceItems(left, right, E.ResonanceItemSortType.Quality, false)
end
local getResonanceItemsSortFunc = function(equipSortType, isAscending)
  if not equipSortType then
    return backpackItemstSort
  end
  if equipSortType == E.ResonanceItemSortType.Quality and isAscending then
    return resonanceItemsUpSortByQuality
  elseif equipSortType == E.ResonanceItemSortType.Quality and not isAscending then
    return resonanceItemsDownSortByQuality
  end
  return backpackItemstSort
end
local modSortQuality = function(left, right, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local a_itemConfig = itemsTableMgr.GetRow(left.configId)
  local b_itemConfig = itemsTableMgr.GetRow(right.configId)
  local a_isEquip, a_pos = modVM.IsModEquip(left.itemUuid)
  local b_isEquip, b_pos = modVM.IsModEquip(right.itemUuid)
  local a_equipState = 2
  if a_isEquip then
    a_equipState = 1
  end
  local b_equipState = 2
  if b_isEquip then
    b_equipState = 1
  end
  if a_equipState == b_equipState then
    if a_isEquip and b_isEquip then
      return a_pos < b_pos
    elseif a_itemConfig.Quality == b_itemConfig.Quality then
      return left.configId > right.configId
    elseif data.isUp then
      return a_itemConfig.Quality > b_itemConfig.Quality
    else
      return a_itemConfig.Quality < b_itemConfig.Quality
    end
  else
    return a_equipState < b_equipState
  end
end
local modSortLevel = function(left, right, data)
  local modVM = Z.VMMgr.GetVM("mod")
  local a_isEquip, a_pos = modVM.IsModEquip(left.itemUuid)
  local b_isEquip, b_pos = modVM.IsModEquip(right.itemUuid)
  local a_equipState = 2
  if a_isEquip then
    a_equipState = 1
  end
  local b_equipState = 2
  if b_isEquip then
    b_equipState = 1
  end
  if a_equipState == b_equipState then
    local a_success = modVM.GetModSuccessTimes(left.itemUuid)
    local b_success = modVM.GetModSuccessTimes(right.itemUuid)
    if a_success == b_success then
      return left.configId < right.configId
    else
      return a_success > b_success
    end
  else
    return a_equipState < b_equipState
  end
end
local getModSortFunc = function(data)
  if data.sortType == E.EquipItemSortType.Quality then
    return function(left, right)
      return modSortQuality(left, right, data)
    end
  elseif data.sortType == E.EquipItemSortType.Lv then
    return function(left, right)
      return modSortLevel(left, right, data)
    end
  end
end
local tradeSellItemstSort = function(left, right)
  local itemsVm = Z.VMMgr.GetVM("items")
  local leftData = itemsVm.GetItemInfobyItemId(left.itemUuid, left.configId)
  local rightData = itemsVm.GetItemInfobyItemId(right.itemUuid, right.configId)
  local itemsTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local leftItemData
  if leftData then
    leftItemData = itemsTableMgr.GetRow(leftData.configId)
  end
  local rightItemData
  if rightData then
    rightItemData = itemsTableMgr.GetRow(rightData.configId)
  end
  if leftItemData == nil then
    return false
  end
  if rightItemData == nil then
    return false
  end
  local now = Z.TimeTools.Now() / 1000
  local leftIsCool = now < leftData.coolDownExpireTime
  local rightIsCool = now < rightData.coolDownExpireTime
  if leftIsCool and not rightIsCool then
    return false
  elseif not leftIsCool and rightIsCool then
    return true
  end
  local itemTypeTableMgr = Z.TableMgr.GetTable("ItemTypeTableMgr")
  local leftType = itemTypeTableMgr.GetRow(leftItemData.Type)
  local rightType = itemTypeTableMgr.GetRow(rightItemData.Type)
  if leftType == nil or rightType == nil then
    return false
  end
  if leftType.SortId < rightType.SortId then
    return true
  elseif leftType.SortId > rightType.SortId then
    return false
  end
  if leftItemData.SortID < rightItemData.SortID then
    return true
  elseif leftItemData.SortID > rightItemData.SortID then
    return false
  end
  if leftData.quality > rightData.quality then
    return true
  elseif leftData.quality < rightData.quality then
    return false
  end
  if leftData.count > rightData.count then
    return true
  elseif leftData.count < rightData.count then
    return false
  end
  if leftData.configId < rightData.configId then
    return true
  end
  return false
end
local sortRecycleItems = function(left, right, sortType, isAscending)
  local itemsVm = Z.VMMgr.GetVM("items")
  local leftData = itemsVm.GetItemInfobyItemId(left.itemUuid, left.configId)
  local rightData = itemsVm.GetItemInfobyItemId(right.itemUuid, right.configId)
  local leftHaveCount = itemsVm.GetItemTotalCount(left.configId)
  local rightHaveCount = itemsVm.GetItemTotalCount(right.configId)
  if sortType == E.RecycleItemSortType.Quality then
    if leftData.quality > rightData.quality then
      return isAscending
    elseif leftData.quality < rightData.quality then
      return not isAscending
    elseif leftData.configId == rightData.configId then
      return leftHaveCount > rightHaveCount
    else
      return leftData.configId < rightData.configId
    end
  elseif sortType == E.RecycleItemSortType.Count then
    if leftHaveCount > rightHaveCount then
      return isAscending
    elseif leftHaveCount < rightHaveCount then
      return not isAscending
    else
      return leftData.configId < rightData.configId
    end
  end
end
local recycleItemsUpSortByQuality = function(left, right)
  return sortRecycleItems(left, right, E.RecycleItemSortType.Quality, true)
end
local recycleItemsDownSortByQuality = function(left, right)
  return sortRecycleItems(left, right, E.RecycleItemSortType.Quality, false)
end
local recycleItemsUpSortByCount = function(left, right)
  return sortRecycleItems(left, right, E.RecycleItemSortType.Count, true)
end
local recycleItemsDownSortByCount = function(left, right)
  return sortRecycleItems(left, right, E.RecycleItemSortType.Count, false)
end
local getRecycleItemsSortFunc = function(recycleSortType, isAscending)
  if recycleSortType == E.RecycleItemSortType.Quality and isAscending then
    return recycleItemsUpSortByQuality
  elseif recycleSortType == E.RecycleItemSortType.Quality and not isAscending then
    return recycleItemsDownSortByQuality
  elseif recycleSortType == E.RecycleItemSortType.Count and isAscending then
    return recycleItemsUpSortByCount
  elseif recycleSortType == E.RecycleItemSortType.Count and not isAscending then
    return recycleItemsDownSortByCount
  end
end
local getItemSortFunc = function(packageType, data)
  if packageType == E.BackPackItemPackageType.Item then
    return backpackItemstSort
  elseif packageType == E.BackPackItemPackageType.Equip then
    if data == nil then
      return backpackItemstSort
    else
      return getEquipItemsSortFunc(data.equipSortType, data.isAscending, data.qualityAscending, data.gsAscending)
    end
  elseif packageType == E.BackPackItemPackageType.Mod then
    if data == nil then
      return backpackItemstSort
    else
      return getModSortFunc(data)
    end
  elseif packageType == E.BackPackItemPackageType.ResonanceSkill then
    if data == nil then
      return backpackItemstSort
    else
      return getResonanceItemsSortFunc(data)
    end
  elseif packageType == E.BackPackItemPackageType.RecycleItem then
    return getRecycleItemsSortFunc(data.recycleSortType, data.isAscending)
  end
end
local getSortData = function(packageType)
  if packageType == E.BackPackItemPackageType.Item then
    return nil
  elseif packageType == E.BackPackItemPackageType.Equip then
    local data = {}
    data.equipSortType = E.EquipItemSortType.QualityAndGS
    data.isAscending = false
    data.qualityAscending = false
    data.gsAscending = false
    return data
  elseif packageType == E.BackPackItemPackageType.Mod then
    local data = {}
    data.sortType = E.EquipItemSortType.Quality
    data.isUp = true
    return data
  end
end
local getTradeSellItemSortFunc = function()
  return tradeSellItemstSort
end
local ret = {
  GetItemSortFunc = getItemSortFunc,
  DefaultSendAwardSort = defaultSendAwardSort,
  DefaultPreviewAwardSort = defaultPreviewAwardSort,
  DefaultSendAwardSortByConfigId = defaultSendAwardSortByConfigId,
  GetSortData = getSortData,
  GetTradeSellItemSortFunc = getTradeSellItemSortFunc
}
return ret
