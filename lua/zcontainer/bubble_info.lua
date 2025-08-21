local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.bubbleScore
    container.__data__.bubbleScore = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("bubbleScore", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.bubbleAwardCount
    container.__data__.bubbleAwardCount = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("bubbleAwardCount", last)
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
  if not pbData.bubbleScore then
    container.__data__.bubbleScore = 0
  end
  if not pbData.bubbleAwardCount then
    container.__data__.bubbleAwardCount = 0
  end
  if not pbData.additionalTargetUuidList then
    container.__data__.additionalTargetUuidList = {}
  end
  if not pbData.lastRefreshTime then
    container.__data__.lastRefreshTime = 0
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
  ret.bubbleScore = {
    fieldId = 1,
    dataType = 0,
    data = container.bubbleScore
  }
  ret.bubbleAwardCount = {
    fieldId = 2,
    dataType = 0,
    data = container.bubbleAwardCount
  }
  if container.additionalTargetUuidList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.additionalTargetUuidList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.additionalTargetUuidList = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.additionalTargetUuidList = {
      fieldId = 3,
      dataType = 3,
      data = {}
    }
  end
  ret.lastRefreshTime = {
    fieldId = 4,
    dataType = 0,
    data = container.lastRefreshTime
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
