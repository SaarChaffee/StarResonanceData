local checkItemType = function(configId, itemType)
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if not itemTableRow then
    return false
  end
  local itemTypeTableRow = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemTableRow.Type)
  if not itemTypeTableRow then
    return false
  end
  return itemTypeTableRow.Classify == itemType
end
local itemRareFilter = function(configId, rares)
  local config = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if config == nil then
    return false
  end
  for _, value in ipairs(rares) do
    if config.Quality == value then
      return true
    end
  end
  return false
end
local modTypeFilter = function(configId, modTypes)
  local modConfig = Z.TableMgr.GetTable("FantasyTableMgr").GetRow(configId)
  if modConfig == nil then
    return false
  end
  for _, value in ipairs(modTypes) do
    if modConfig.FantasyType == value then
      return true
    end
  end
  return false
end
local itemTypeFilter = function(filterFunc, data)
  local checkTypeFunc
  if data.filterMask & E.ItemFilterType.ItemType ~= 0 then
    function checkTypeFunc(itemUuid, configId)
      if data.itemType == nil or data.itemType == -1 then
        return true
      end
      return checkItemType(configId, data.itemType)
    end
    
    table.insert(filterFunc, checkTypeFunc)
  end
  if data.filterMask & E.ItemFilterType.ItemRare ~= 0 then
    function checkTypeFunc(itemUuid, configId)
      if data.filterTags[E.ItemFilterType.ItemRare] == nil then
        return true
      end
      return itemRareFilter(configId, data.filterTags[E.ItemFilterType.ItemRare])
    end
    
    table.insert(filterFunc, checkTypeFunc)
  end
  return filterFunc
end
local getBackpackItemFilterFunc = function(data)
  local filterFunc = {}
  itemTypeFilter(filterFunc, data)
  if #filterFunc < 1 then
    return nil
  end
  return filterFunc
end
local getItemFilterFunc = function(filterType)
  local filterFunc = {}
  for key, value in pairs(filterType) do
    if key == E.ItemFilterType.ItemRare then
      filterFunc[key] = itemRareFilter
    elseif key == E.ItemFilterType.ModType then
      filterFunc[key] = modTypeFilter
    end
  end
  return filterFunc
end
local ret = {GetBackpackItemFilterFunc = getBackpackItemFilterFunc, GetItemFilterFunc = getItemFilterFunc}
return ret
