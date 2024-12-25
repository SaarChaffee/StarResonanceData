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
      local v = require("zcontainer.mark_data").New()
      v:MergeData(buffer, watcherList)
      container.markDataMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("markDataMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.markDataMap.__data__[dk]
      container.markDataMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("markDataMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.markDataMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.mark_data").New()
        container.markDataMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("markDataMap", dk, {})
    end
  end,
  [2] = function(container, buffer, watcherList)
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
      local dv = br.ReadBoolean(buffer)
      container.aresMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("aresMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.aresMap.__data__[dk]
      container.aresMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("aresMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.aresMap.__data__[dk]
      container.aresMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("aresMap", dk, last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.markUuid
    container.__data__.markUuid = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("markUuid", last)
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
  if not pbData.markDataMap then
    container.__data__.markDataMap = {}
  end
  if not pbData.aresMap then
    container.__data__.aresMap = {}
  end
  if not pbData.markUuid then
    container.__data__.markUuid = 0
  end
  setForbidenMt(container)
  container.markDataMap.__data__ = {}
  setForbidenMt(container.markDataMap)
  for k, v in pairs(pbData.markDataMap) do
    container.markDataMap.__data__[k] = require("zcontainer.mark_data").New()
    container.markDataMap[k]:ResetData(v)
  end
  container.__data__.markDataMap = nil
  container.aresMap.__data__ = pbData.aresMap
  setForbidenMt(container.aresMap)
  container.__data__.aresMap = nil
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
  if container.markDataMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.markDataMap) do
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
    ret.markDataMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.markDataMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.aresMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.aresMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.aresMap = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.aresMap = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.markUuid = {
    fieldId = 3,
    dataType = 0,
    data = container.markUuid
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    markDataMap = {
      __data__ = {}
    },
    aresMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.markDataMap)
  setForbidenMt(ret.aresMap)
  return ret
end
return {New = new}
