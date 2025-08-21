local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.interactionStage
    container.__data__.interactionStage = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("interactionStage", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.actionId
    container.__data__.actionId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("actionId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.originatorId
    container.__data__.originatorId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("originatorId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.inviteeId
    container.__data__.inviteeId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("inviteeId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.isOriginator
    container.__data__.isOriginator = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isOriginator", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.interactionType
    container.__data__.interactionType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("interactionType", last)
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
  if not pbData.interactionStage then
    container.__data__.interactionStage = 0
  end
  if not pbData.actionId then
    container.__data__.actionId = 0
  end
  if not pbData.originatorId then
    container.__data__.originatorId = 0
  end
  if not pbData.inviteeId then
    container.__data__.inviteeId = 0
  end
  if not pbData.isOriginator then
    container.__data__.isOriginator = false
  end
  if not pbData.interactionType then
    container.__data__.interactionType = 0
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
  ret.interactionStage = {
    fieldId = 1,
    dataType = 0,
    data = container.interactionStage
  }
  ret.actionId = {
    fieldId = 2,
    dataType = 0,
    data = container.actionId
  }
  ret.originatorId = {
    fieldId = 3,
    dataType = 0,
    data = container.originatorId
  }
  ret.inviteeId = {
    fieldId = 4,
    dataType = 0,
    data = container.inviteeId
  }
  ret.isOriginator = {
    fieldId = 5,
    dataType = 0,
    data = container.isOriginator
  }
  ret.interactionType = {
    fieldId = 6,
    dataType = 0,
    data = container.interactionType
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
