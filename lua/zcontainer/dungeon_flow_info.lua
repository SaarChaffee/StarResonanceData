local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.state
    container.__data__.state = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("state", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.activeTime
    container.__data__.activeTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("activeTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.readyTime
    container.__data__.readyTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("readyTime", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.playTime
    container.__data__.playTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("playTime", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.endTime
    container.__data__.endTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("endTime", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.settlementTime
    container.__data__.settlementTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("settlementTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.dungeonTimes
    container.__data__.dungeonTimes = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("dungeonTimes", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.result
    container.__data__.result = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("result", last)
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
  if not pbData.state then
    container.__data__.state = 0
  end
  if not pbData.activeTime then
    container.__data__.activeTime = 0
  end
  if not pbData.readyTime then
    container.__data__.readyTime = 0
  end
  if not pbData.playTime then
    container.__data__.playTime = 0
  end
  if not pbData.endTime then
    container.__data__.endTime = 0
  end
  if not pbData.settlementTime then
    container.__data__.settlementTime = 0
  end
  if not pbData.dungeonTimes then
    container.__data__.dungeonTimes = 0
  end
  if not pbData.result then
    container.__data__.result = 0
  end
  setForbidenMt(container)
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
  ret.state = {
    fieldId = 1,
    dataType = 0,
    data = container.state
  }
  ret.activeTime = {
    fieldId = 2,
    dataType = 0,
    data = container.activeTime
  }
  ret.readyTime = {
    fieldId = 3,
    dataType = 0,
    data = container.readyTime
  }
  ret.playTime = {
    fieldId = 4,
    dataType = 0,
    data = container.playTime
  }
  ret.endTime = {
    fieldId = 5,
    dataType = 0,
    data = container.endTime
  }
  ret.settlementTime = {
    fieldId = 6,
    dataType = 0,
    data = container.settlementTime
  }
  ret.dungeonTimes = {
    fieldId = 7,
    dataType = 0,
    data = container.dungeonTimes
  }
  ret.result = {
    fieldId = 8,
    dataType = 0,
    data = container.result
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
