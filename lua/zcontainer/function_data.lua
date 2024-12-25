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
      local dv = br.ReadBoolean(buffer)
      container.unlockedMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockedMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockedMap.__data__[dk]
      container.unlockedMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockedMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.unlockedMap.__data__[dk]
      container.unlockedMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockedMap", dk, last)
    end
  end,
  [2] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.drawnFunctionIds
    container.__data__.drawnFunctionIds = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("drawnFunctionIds", last)
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
  if not pbData.unlockedMap then
    container.__data__.unlockedMap = {}
  end
  if not pbData.drawnFunctionIds then
    container.__data__.drawnFunctionIds = {}
  end
  setForbidenMt(container)
  container.unlockedMap.__data__ = pbData.unlockedMap
  setForbidenMt(container.unlockedMap)
  container.__data__.unlockedMap = nil
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
  if container.unlockedMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockedMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.unlockedMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.unlockedMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.drawnFunctionIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.drawnFunctionIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.drawnFunctionIds = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.drawnFunctionIds = {
      fieldId = 2,
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
    unlockedMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.unlockedMap)
  return ret
end
return {New = new}
