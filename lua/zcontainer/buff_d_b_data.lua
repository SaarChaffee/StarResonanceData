local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.buffUuid
    container.__data__.buffUuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("buffUuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.firerId
    container.__data__.firerId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("firerId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.buffConfigId
    container.__data__.buffConfigId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("buffConfigId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.baseId
    container.__data__.baseId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("baseId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.layer
    container.__data__.layer = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("layer", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.duration
    container.__data__.duration = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("duration", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.count
    container.__data__.count = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("count", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.createTime
    container.__data__.createTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("createTime", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.partId
    container.__data__.partId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("partId", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.createSceneId
    container.__data__.createSceneId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("createSceneId", last)
  end,
  [12] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.customParamsKey
    container.__data__.customParamsKey = t
    for i = 1, count do
      local v = br.ReadString(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("customParamsKey", last)
    end
  end,
  [13] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.customParams
    container.__data__.customParams = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("customParams", last)
    end
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
  if not pbData.buffUuid then
    container.__data__.buffUuid = 0
  end
  if not pbData.firerId then
    container.__data__.firerId = 0
  end
  if not pbData.buffConfigId then
    container.__data__.buffConfigId = 0
  end
  if not pbData.baseId then
    container.__data__.baseId = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.layer then
    container.__data__.layer = 0
  end
  if not pbData.duration then
    container.__data__.duration = 0
  end
  if not pbData.count then
    container.__data__.count = 0
  end
  if not pbData.createTime then
    container.__data__.createTime = 0
  end
  if not pbData.partId then
    container.__data__.partId = 0
  end
  if not pbData.createSceneId then
    container.__data__.createSceneId = 0
  end
  if not pbData.customParamsKey then
    container.__data__.customParamsKey = {}
  end
  if not pbData.customParams then
    container.__data__.customParams = {}
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
  ret.buffUuid = {
    fieldId = 1,
    dataType = 0,
    data = container.buffUuid
  }
  ret.firerId = {
    fieldId = 2,
    dataType = 0,
    data = container.firerId
  }
  ret.buffConfigId = {
    fieldId = 3,
    dataType = 0,
    data = container.buffConfigId
  }
  ret.baseId = {
    fieldId = 4,
    dataType = 0,
    data = container.baseId
  }
  ret.level = {
    fieldId = 5,
    dataType = 0,
    data = container.level
  }
  ret.layer = {
    fieldId = 6,
    dataType = 0,
    data = container.layer
  }
  ret.duration = {
    fieldId = 7,
    dataType = 0,
    data = container.duration
  }
  ret.count = {
    fieldId = 8,
    dataType = 0,
    data = container.count
  }
  ret.createTime = {
    fieldId = 9,
    dataType = 0,
    data = container.createTime
  }
  ret.partId = {
    fieldId = 10,
    dataType = 0,
    data = container.partId
  }
  ret.createSceneId = {
    fieldId = 11,
    dataType = 0,
    data = container.createSceneId
  }
  if container.customParamsKey ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.customParamsKey) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.customParamsKey = {
      fieldId = 12,
      dataType = 3,
      data = data
    }
  else
    ret.customParamsKey = {
      fieldId = 12,
      dataType = 3,
      data = {}
    }
  end
  if container.customParams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.customParams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.customParams = {
      fieldId = 13,
      dataType = 3,
      data = data
    }
  else
    ret.customParams = {
      fieldId = 13,
      dataType = 3,
      data = {}
    }
  end
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
