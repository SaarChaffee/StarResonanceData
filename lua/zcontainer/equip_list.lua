local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.equip_info").New()
      v:MergeData(buffer, watcherList)
      container.equipList.__data__[dk] = v
      container.Watcher:MarkMapDirty("equipList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.equipList.__data__[dk]
      container.equipList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("equipList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.equipList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.equip_info").New()
        container.equipList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("equipList", dk, {})
    end
  end,
  [2] = function(container, buffer, watcherList)
    container.equipAttr:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equipAttr", {})
  end,
  [4] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadUInt64(buffer)
      local v = require("zcontainer.equip_attr").New()
      v:MergeData(buffer, watcherList)
      container.equipRecastInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("equipRecastInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt64(buffer)
      local last = container.equipRecastInfo.__data__[dk]
      container.equipRecastInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("equipRecastInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt64(buffer)
      local last = container.equipRecastInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.equip_attr").New()
        container.equipRecastInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("equipRecastInfo", dk, {})
    end
  end,
  [5] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.equip_enchant_info").New()
      v:MergeData(buffer, watcherList)
      container.equipEnchant.__data__[dk] = v
      container.Watcher:MarkMapDirty("equipEnchant", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.equipEnchant.__data__[dk]
      container.equipEnchant.__data__[dk] = nil
      container.Watcher:MarkMapDirty("equipEnchant", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.equipEnchant.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.equip_enchant_info").New()
        container.equipEnchant.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("equipEnchant", dk, {})
    end
  end,
  [6] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.equip_suit_info").New()
      v:MergeData(buffer, watcherList)
      container.suitInfoDict.__data__[dk] = v
      container.Watcher:MarkMapDirty("suitInfoDict", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.suitInfoDict.__data__[dk]
      container.suitInfoDict.__data__[dk] = nil
      container.Watcher:MarkMapDirty("suitInfoDict", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.suitInfoDict.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.equip_suit_info").New()
        container.suitInfoDict.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("suitInfoDict", dk, {})
    end
  end
}
local setForbidenMt = function(t)
  local mt = {
    __index = t.__data__,
    __newindex = function(_, _, _)
      error("__newindex is forbidden for container")
    end,
    __pairs = function(tbl)
      local stateless_iter = function(tbl, k)
        local v
        k, v = next(t.__data__, k)
        if nil ~= v or "__data__" ~= k then
          return k, v
        end
      end
      return stateless_iter, tbl, nil
    end
  }
  setmetatable(t, mt)
end
local resetData = function(container, pbData)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  if not pbData then
    return
  end
  container.__data__ = pbData
  if not pbData.equipList then
    container.__data__.equipList = {}
  end
  if not pbData.equipAttr then
    container.__data__.equipAttr = {}
  end
  if not pbData.equipRecastInfo then
    container.__data__.equipRecastInfo = {}
  end
  if not pbData.equipEnchant then
    container.__data__.equipEnchant = {}
  end
  if not pbData.suitInfoDict then
    container.__data__.suitInfoDict = {}
  end
  setForbidenMt(container)
  container.equipList.__data__ = {}
  setForbidenMt(container.equipList)
  for k, v in pairs(pbData.equipList) do
    container.equipList.__data__[k] = require("zcontainer.equip_info").New()
    container.equipList[k]:ResetData(v)
  end
  container.__data__.equipList = nil
  container.equipAttr:ResetData(pbData.equipAttr)
  container.__data__.equipAttr = nil
  container.equipRecastInfo.__data__ = {}
  setForbidenMt(container.equipRecastInfo)
  for k, v in pairs(pbData.equipRecastInfo) do
    container.equipRecastInfo.__data__[k] = require("zcontainer.equip_attr").New()
    container.equipRecastInfo[k]:ResetData(v)
  end
  container.__data__.equipRecastInfo = nil
  container.equipEnchant.__data__ = {}
  setForbidenMt(container.equipEnchant)
  for k, v in pairs(pbData.equipEnchant) do
    container.equipEnchant.__data__[k] = require("zcontainer.equip_enchant_info").New()
    container.equipEnchant[k]:ResetData(v)
  end
  container.__data__.equipEnchant = nil
  container.suitInfoDict.__data__ = {}
  setForbidenMt(container.suitInfoDict)
  for k, v in pairs(pbData.suitInfoDict) do
    container.suitInfoDict.__data__[k] = require("zcontainer.equip_suit_info").New()
    container.suitInfoDict[k]:ResetData(v)
  end
  container.__data__.suitInfoDict = nil
end
local mergeData = function(container, buffer, watcherList)
  if not container or not container.__data__ then
    error("container is nil or not container")
  end
  local tag = br.ReadInt32(buffer)
  if tag ~= -2 then
    error("Invalid begin tag:" .. tag)
    return
  end
  local size = br.ReadInt32(buffer)
  if size == -3 then
    return
  end
  local offset = br.Offset(buffer)
  local index = br.ReadInt32(buffer)
  while 0 < index do
    local func = mergeDataFuncs[index]
    if func ~= nil then
      func(container, buffer, watcherList)
    else
      logWarning("Unknown field: " .. index)
      br.SetOffset(buffer, offset + size)
    end
    index = br.ReadInt32(buffer)
  end
  if index ~= -3 then
    error("Invalid end tag:" .. index)
  end
  if watcherList and container.Watcher.isDirty then
    watcherList[#watcherList + 1] = container.Watcher
  end
end
local getContainerElem = function(container)
  if container == nil then
    return nil
  end
  local ret = {}
  if container.equipList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.equipList) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.equipList = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.equipList = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.equipAttr == nil then
    ret.equipAttr = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.equipAttr = {
      fieldId = 2,
      dataType = 1,
      data = container.equipAttr:GetContainerElem()
    }
  end
  if container.equipRecastInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.equipRecastInfo) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.equipRecastInfo = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.equipRecastInfo = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.equipEnchant ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.equipEnchant) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.equipEnchant = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.equipEnchant = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  if container.suitInfoDict ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.suitInfoDict) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 6,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 6,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.suitInfoDict = {
      fieldId = 6,
      dataType = 2,
      data = data
    }
  else
    ret.suitInfoDict = {
      fieldId = 6,
      dataType = 2,
      data = {}
    }
  end
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    equipList = {
      __data__ = {}
    },
    equipAttr = require("zcontainer.equip_attr").New(),
    equipRecastInfo = {
      __data__ = {}
    },
    equipEnchant = {
      __data__ = {}
    },
    suitInfoDict = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.equipList)
  setForbidenMt(ret.equipRecastInfo)
  setForbidenMt(ret.equipEnchant)
  setForbidenMt(ret.suitInfoDict)
  return ret
end
return {New = new}
