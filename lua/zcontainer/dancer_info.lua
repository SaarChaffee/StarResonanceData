local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.danceSecs
    container.__data__.danceSecs = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("danceSecs", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.isDancing
    container.__data__.isDancing = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isDancing", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.hasDrawn
    container.__data__.hasDrawn = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("hasDrawn", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.hasSend
    container.__data__.hasSend = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("hasSend", last)
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
  if not pbData.danceSecs then
    container.__data__.danceSecs = 0
  end
  if not pbData.isDancing then
    container.__data__.isDancing = false
  end
  if not pbData.hasDrawn then
    container.__data__.hasDrawn = false
  end
  if not pbData.hasSend then
    container.__data__.hasSend = false
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
  ret.charId = {
    fieldId = 1,
    dataType = 0,
    data = container.charId
  }
  ret.danceSecs = {
    fieldId = 2,
    dataType = 0,
    data = container.danceSecs
  }
  ret.isDancing = {
    fieldId = 3,
    dataType = 0,
    data = container.isDancing
  }
  ret.hasDrawn = {
    fieldId = 4,
    dataType = 0,
    data = container.hasDrawn
  }
  ret.hasSend = {
    fieldId = 5,
    dataType = 0,
    data = container.hasSend
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
