local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.avatarId
    container.__data__.avatarId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("avatarId", last)
  end,
  [2] = function(container, buffer, watcherList)
    container.profile:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("profile", {})
  end,
  [3] = function(container, buffer, watcherList)
    container.halfBody:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("halfBody", {})
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.businessCardStyleId
    container.__data__.businessCardStyleId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("businessCardStyleId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.avatarFrameId
    container.__data__.avatarFrameId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("avatarFrameId", last)
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
  if not pbData.avatarId then
    container.__data__.avatarId = 0
  end
  if not pbData.profile then
    container.__data__.profile = {}
  end
  if not pbData.halfBody then
    container.__data__.halfBody = {}
  end
  if not pbData.businessCardStyleId then
    container.__data__.businessCardStyleId = 0
  end
  if not pbData.avatarFrameId then
    container.__data__.avatarFrameId = 0
  end
  setForbidenMt(container)
  container.profile:ResetData(pbData.profile)
  container.__data__.profile = nil
  container.halfBody:ResetData(pbData.halfBody)
  container.__data__.halfBody = nil
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
  ret.avatarId = {
    fieldId = 1,
    dataType = 0,
    data = container.avatarId
  }
  if container.profile == nil then
    ret.profile = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.profile = {
      fieldId = 2,
      dataType = 1,
      data = container.profile:GetContainerElem()
    }
  end
  if container.halfBody == nil then
    ret.halfBody = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.halfBody = {
      fieldId = 3,
      dataType = 1,
      data = container.halfBody:GetContainerElem()
    }
  end
  ret.businessCardStyleId = {
    fieldId = 4,
    dataType = 0,
    data = container.businessCardStyleId
  }
  ret.avatarFrameId = {
    fieldId = 5,
    dataType = 0,
    data = container.avatarFrameId
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    profile = require("zcontainer.picture_info").New(),
    halfBody = require("zcontainer.picture_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
