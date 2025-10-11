local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.type
    container.__data__.type = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("type", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.startTime
    container.__data__.startTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("startTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.dungeonTimes
    container.__data__.dungeonTimes = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("dungeonTimes", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.direction
    container.__data__.direction = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("direction", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.index
    container.__data__.index = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("index", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.changeTime
    container.__data__.changeTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("changeTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.effectType
    container.__data__.effectType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("effectType", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.pauseTime
    container.__data__.pauseTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("pauseTime", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.pauseTotalTime
    container.__data__.pauseTotalTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("pauseTotalTime", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.outLookType
    container.__data__.outLookType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("outLookType", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.curPauseTimestamp
    container.__data__.curPauseTimestamp = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("curPauseTimestamp", last)
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
  if not pbData.type then
    container.__data__.type = 0
  end
  if not pbData.startTime then
    container.__data__.startTime = 0
  end
  if not pbData.dungeonTimes then
    container.__data__.dungeonTimes = 0
  end
  if not pbData.direction then
    container.__data__.direction = 0
  end
  if not pbData.index then
    container.__data__.index = 0
  end
  if not pbData.changeTime then
    container.__data__.changeTime = 0
  end
  if not pbData.effectType then
    container.__data__.effectType = 0
  end
  if not pbData.pauseTime then
    container.__data__.pauseTime = 0
  end
  if not pbData.pauseTotalTime then
    container.__data__.pauseTotalTime = 0
  end
  if not pbData.outLookType then
    container.__data__.outLookType = 0
  end
  if not pbData.curPauseTimestamp then
    container.__data__.curPauseTimestamp = 0
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
  ret.type = {
    fieldId = 1,
    dataType = 0,
    data = container.type
  }
  ret.startTime = {
    fieldId = 2,
    dataType = 0,
    data = container.startTime
  }
  ret.dungeonTimes = {
    fieldId = 3,
    dataType = 0,
    data = container.dungeonTimes
  }
  ret.direction = {
    fieldId = 4,
    dataType = 0,
    data = container.direction
  }
  ret.index = {
    fieldId = 5,
    dataType = 0,
    data = container.index
  }
  ret.changeTime = {
    fieldId = 6,
    dataType = 0,
    data = container.changeTime
  }
  ret.effectType = {
    fieldId = 7,
    dataType = 0,
    data = container.effectType
  }
  ret.pauseTime = {
    fieldId = 8,
    dataType = 0,
    data = container.pauseTime
  }
  ret.pauseTotalTime = {
    fieldId = 9,
    dataType = 0,
    data = container.pauseTotalTime
  }
  ret.outLookType = {
    fieldId = 10,
    dataType = 0,
    data = container.outLookType
  }
  ret.curPauseTimestamp = {
    fieldId = 11,
    dataType = 0,
    data = container.curPauseTimestamp
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
