local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("id", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.drawCount
    container.__data__.drawCount = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("drawCount", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.refreshTime
    container.__data__.refreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("refreshTime", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.wishId
    container.__data__.wishId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("wishId", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.wishValue
    container.__data__.wishValue = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("wishValue", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.wishFinishCount
    container.__data__.wishFinishCount = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("wishFinishCount", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.wishResetTime
    container.__data__.wishResetTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("wishResetTime", last)
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.wishLimit
    container.__data__.wishLimit = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("wishLimit", last)
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
  if not pbData.drawCount then
    container.__data__.drawCount = 0
  end
  if not pbData.refreshTime then
    container.__data__.refreshTime = 0
  end
  if not pbData.wishId then
    container.__data__.wishId = 0
  end
  if not pbData.wishValue then
    container.__data__.wishValue = 0
  end
  if not pbData.wishFinishCount then
    container.__data__.wishFinishCount = 0
  end
  if not pbData.wishResetTime then
    container.__data__.wishResetTime = 0
  end
  if not pbData.wishLimit then
    container.__data__.wishLimit = 0
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
  ret.drawCount = {
    fieldId = 4,
    dataType = 0,
    data = container.drawCount
  }
  ret.refreshTime = {
    fieldId = 5,
    dataType = 0,
    data = container.refreshTime
  }
  ret.wishId = {
    fieldId = 8,
    dataType = 0,
    data = container.wishId
  }
  ret.wishValue = {
    fieldId = 9,
    dataType = 0,
    data = container.wishValue
  }
  ret.wishFinishCount = {
    fieldId = 10,
    dataType = 0,
    data = container.wishFinishCount
  }
  ret.wishResetTime = {
    fieldId = 11,
    dataType = 0,
    data = container.wishResetTime
  }
  ret.wishLimit = {
    fieldId = 12,
    dataType = 0,
    data = container.wishLimit
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
