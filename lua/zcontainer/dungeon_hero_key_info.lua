local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.heroKeyItem
    container.__data__.heroKeyItem = t
    for i = 1, count do
      local v = require("zcontainer.item").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("heroKeyItem", last)
    end
  end,
  [3] = function(container, buffer, watcherList)
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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.hero_key_item_info").New()
      v:MergeData(buffer, watcherList)
      container.keyInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("keyInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.keyInfo.__data__[dk]
      container.keyInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("keyInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.keyInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.hero_key_item_info").New()
        container.keyInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("keyInfo", dk, {})
    end
  end,
  [4] = function(container, buffer, watcherList)
    container.useItem:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("useItem", {})
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.heroKeyAwardItem
    container.__data__.heroKeyAwardItem = t
    for i = 1, count do
      local v = require("zcontainer.item").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("heroKeyAwardItem", last)
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
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.heroKeyItem then
    container.__data__.heroKeyItem = {}
  end
  if not pbData.keyInfo then
    container.__data__.keyInfo = {}
  end
  if not pbData.useItem then
    container.__data__.useItem = {}
  end
  if not pbData.heroKeyAwardItem then
    container.__data__.heroKeyAwardItem = {}
  end
  setForbidenMt(container)
  container.keyInfo.__data__ = {}
  setForbidenMt(container.keyInfo)
  for k, v in pairs(pbData.keyInfo) do
    container.keyInfo.__data__[k] = require("zcontainer.hero_key_item_info").New()
    container.keyInfo[k]:ResetData(v)
  end
  container.__data__.keyInfo = nil
  container.useItem:ResetData(pbData.useItem)
  container.__data__.useItem = nil
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
  ret.charId = {
    fieldId = 1,
    dataType = 0,
    data = container.charId
  }
  if container.heroKeyItem ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.heroKeyItem) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 2,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 2,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.heroKeyItem = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.heroKeyItem = {
      fieldId = 2,
      dataType = 3,
      data = {}
    }
  end
  if container.keyInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.keyInfo) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.keyInfo = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.keyInfo = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.useItem == nil then
    ret.useItem = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.useItem = {
      fieldId = 4,
      dataType = 1,
      data = container.useItem:GetContainerElem()
    }
  end
  if container.heroKeyAwardItem ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.heroKeyAwardItem) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 5,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 5,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.heroKeyAwardItem = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.heroKeyAwardItem = {
      fieldId = 5,
      dataType = 3,
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
    keyInfo = {
      __data__ = {}
    },
    useItem = require("zcontainer.item").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.keyInfo)
  return ret
end
return {New = new}
