local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.teamId
    container.__data__.teamId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("teamId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.leaderId
    container.__data__.leaderId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("leaderId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.teamTargetId
    container.__data__.teamTargetId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("teamTargetId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.teamNum
    container.__data__.teamNum = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("teamNum", last)
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.charIds
    container.__data__.charIds = t
    for i = 1, count do
      local v = br.ReadInt64(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("charIds", last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.isMatching
    container.__data__.isMatching = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isMatching", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.charTeamVersion
    container.__data__.charTeamVersion = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("charTeamVersion", last)
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
  if not pbData.teamId then
    container.__data__.teamId = 0
  end
  if not pbData.leaderId then
    container.__data__.leaderId = 0
  end
  if not pbData.teamTargetId then
    container.__data__.teamTargetId = 0
  end
  if not pbData.teamNum then
    container.__data__.teamNum = 0
  end
  if not pbData.charIds then
    container.__data__.charIds = {}
  end
  if not pbData.isMatching then
    container.__data__.isMatching = false
  end
  if not pbData.charTeamVersion then
    container.__data__.charTeamVersion = 0
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
  ret.teamId = {
    fieldId = 1,
    dataType = 0,
    data = container.teamId
  }
  ret.leaderId = {
    fieldId = 2,
    dataType = 0,
    data = container.leaderId
  }
  ret.teamTargetId = {
    fieldId = 3,
    dataType = 0,
    data = container.teamTargetId
  }
  ret.teamNum = {
    fieldId = 4,
    dataType = 0,
    data = container.teamNum
  }
  if container.charIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.charIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.charIds = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.charIds = {
      fieldId = 5,
      dataType = 3,
      data = {}
    }
  end
  ret.isMatching = {
    fieldId = 6,
    dataType = 0,
    data = container.isMatching
  }
  ret.charTeamVersion = {
    fieldId = 7,
    dataType = 0,
    data = container.charTeamVersion
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
