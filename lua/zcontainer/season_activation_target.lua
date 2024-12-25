local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("id", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.targetType
    container.__data__.targetType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("targetType", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.targetUuid
    container.__data__.targetUuid = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("targetUuid", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.rewardRate
    container.__data__.rewardRate = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("rewardRate", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.progress
    container.__data__.progress = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("progress", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.completedTimes
    container.__data__.completedTimes = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("completedTimes", last)
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
  if not pbData.id then
    container.__data__.id = 0
  end
  if not pbData.targetType then
    container.__data__.targetType = 0
  end
  if not pbData.targetUuid then
    container.__data__.targetUuid = 0
  end
  if not pbData.rewardRate then
    container.__data__.rewardRate = 0
  end
  if not pbData.progress then
    container.__data__.progress = 0
  end
  if not pbData.completedTimes then
    container.__data__.completedTimes = 0
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
  ret.id = {
    fieldId = 1,
    dataType = 0,
    data = container.id
  }
  ret.targetType = {
    fieldId = 2,
    dataType = 0,
    data = container.targetType
  }
  ret.targetUuid = {
    fieldId = 3,
    dataType = 0,
    data = container.targetUuid
  }
  ret.rewardRate = {
    fieldId = 4,
    dataType = 0,
    data = container.rewardRate
  }
  ret.progress = {
    fieldId = 5,
    dataType = 0,
    data = container.progress
  }
  ret.completedTimes = {
    fieldId = 6,
    dataType = 0,
    data = container.completedTimes
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
