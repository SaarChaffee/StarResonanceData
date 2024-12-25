local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charID
    container.__data__.charID = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charID", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.showId
    container.__data__.showId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("showId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.name
    container.__data__.name = br.ReadString(buffer)
    container.Watcher:MarkDirty("name", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.gender
    container.__data__.gender = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("gender", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.bodySize
    container.__data__.bodySize = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("bodySize", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.sceneId
    container.__data__.sceneId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sceneId", last)
  end,
  [8] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.personalState
    container.__data__.personalState = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("personalState", last)
    end
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.offlineTime
    container.__data__.offlineTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("offlineTime", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.sceneGuid
    container.__data__.sceneGuid = br.ReadString(buffer)
    container.Watcher:MarkDirty("sceneGuid", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.createTime
    container.__data__.createTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("createTime", last)
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.curTalentPoolId
    container.__data__.curTalentPoolId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("curTalentPoolId", last)
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.botAiId
    container.__data__.botAiId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("botAiId", last)
  end,
  [14] = function(container, buffer, watcherList)
    local last = container.__data__.registerChannel
    container.__data__.registerChannel = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("registerChannel", last)
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
  if not pbData.charID then
    container.__data__.charID = 0
  end
  if not pbData.showId then
    container.__data__.showId = 0
  end
  if not pbData.name then
    container.__data__.name = ""
  end
  if not pbData.gender then
    container.__data__.gender = 0
  end
  if not pbData.bodySize then
    container.__data__.bodySize = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.sceneId then
    container.__data__.sceneId = 0
  end
  if not pbData.personalState then
    container.__data__.personalState = {}
  end
  if not pbData.offlineTime then
    container.__data__.offlineTime = 0
  end
  if not pbData.sceneGuid then
    container.__data__.sceneGuid = ""
  end
  if not pbData.createTime then
    container.__data__.createTime = 0
  end
  if not pbData.curTalentPoolId then
    container.__data__.curTalentPoolId = 0
  end
  if not pbData.botAiId then
    container.__data__.botAiId = 0
  end
  if not pbData.registerChannel then
    container.__data__.registerChannel = 0
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
  ret.charID = {
    fieldId = 1,
    dataType = 0,
    data = container.charID
  }
  ret.showId = {
    fieldId = 2,
    dataType = 0,
    data = container.showId
  }
  ret.name = {
    fieldId = 3,
    dataType = 0,
    data = container.name
  }
  ret.gender = {
    fieldId = 4,
    dataType = 0,
    data = container.gender
  }
  ret.bodySize = {
    fieldId = 5,
    dataType = 0,
    data = container.bodySize
  }
  ret.level = {
    fieldId = 6,
    dataType = 0,
    data = container.level
  }
  ret.sceneId = {
    fieldId = 7,
    dataType = 0,
    data = container.sceneId
  }
  if container.personalState ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.personalState) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.personalState = {
      fieldId = 8,
      dataType = 3,
      data = data
    }
  else
    ret.personalState = {
      fieldId = 8,
      dataType = 3,
      data = {}
    }
  end
  ret.offlineTime = {
    fieldId = 9,
    dataType = 0,
    data = container.offlineTime
  }
  ret.sceneGuid = {
    fieldId = 10,
    dataType = 0,
    data = container.sceneGuid
  }
  ret.createTime = {
    fieldId = 11,
    dataType = 0,
    data = container.createTime
  }
  ret.curTalentPoolId = {
    fieldId = 12,
    dataType = 0,
    data = container.curTalentPoolId
  }
  ret.botAiId = {
    fieldId = 13,
    dataType = 0,
    data = container.botAiId
  }
  ret.registerChannel = {
    fieldId = 14,
    dataType = 0,
    data = container.registerChannel
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
