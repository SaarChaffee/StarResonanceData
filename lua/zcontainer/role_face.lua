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
      container.unlockItemMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockItemMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockItemMap.__data__[dk]
      container.unlockItemMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockItemMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.unlockItemMap.__data__[dk]
      container.unlockItemMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockItemMap", dk, last)
    end
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.saveNeedConsume
    container.__data__.saveNeedConsume = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("saveNeedConsume", last)
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
  if not pbData.unlockItemMap then
    container.__data__.unlockItemMap = {}
  end
  if not pbData.saveNeedConsume then
    container.__data__.saveNeedConsume = false
  end
  setForbidenMt(container)
  container.unlockItemMap.__data__ = pbData.unlockItemMap
  setForbidenMt(container.unlockItemMap)
  container.__data__.unlockItemMap = nil
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
  if container.unlockItemMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockItemMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.unlockItemMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.unlockItemMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  ret.saveNeedConsume = {
    fieldId = 2,
    dataType = 0,
    data = container.saveNeedConsume
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    unlockItemMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.unlockItemMap)
  return ret
end
return {New = new}
