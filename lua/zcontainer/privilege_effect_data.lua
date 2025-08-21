local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.normalPassId
    container.__data__.normalPassId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("normalPassId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.PrimePassId
    container.__data__.PrimePassId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("PrimePassId", last)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.normalPassIdMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("normalPassIdMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.normalPassIdMap.__data__[dk]
      container.normalPassIdMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("normalPassIdMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.normalPassIdMap.__data__[dk]
      container.normalPassIdMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("normalPassIdMap", dk, last)
    end
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.PrimePassIdMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("PrimePassIdMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.PrimePassIdMap.__data__[dk]
      container.PrimePassIdMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("PrimePassIdMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.PrimePassIdMap.__data__[dk]
      container.PrimePassIdMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("PrimePassIdMap", dk, last)
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
  if not pbData.normalPassId then
    container.__data__.normalPassId = 0
  end
  if not pbData.PrimePassId then
    container.__data__.PrimePassId = 0
  end
  if not pbData.normalPassIdMap then
    container.__data__.normalPassIdMap = {}
  end
  if not pbData.PrimePassIdMap then
    container.__data__.PrimePassIdMap = {}
  end
  setForbidenMt(container)
  container.normalPassIdMap.__data__ = pbData.normalPassIdMap
  setForbidenMt(container.normalPassIdMap)
  container.__data__.normalPassIdMap = nil
  container.PrimePassIdMap.__data__ = pbData.PrimePassIdMap
  setForbidenMt(container.PrimePassIdMap)
  container.__data__.PrimePassIdMap = nil
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
  ret.normalPassId = {
    fieldId = 1,
    dataType = 0,
    data = container.normalPassId
  }
  ret.PrimePassId = {
    fieldId = 2,
    dataType = 0,
    data = container.PrimePassId
  }
  if container.normalPassIdMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.normalPassIdMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.normalPassIdMap = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.normalPassIdMap = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.PrimePassIdMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.PrimePassIdMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.PrimePassIdMap = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.PrimePassIdMap = {
      fieldId = 4,
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
    normalPassIdMap = {
      __data__ = {}
    },
    PrimePassIdMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.normalPassIdMap)
  setForbidenMt(ret.PrimePassIdMap)
  return ret
end
return {New = new}
