local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.danceId
    container.__data__.danceId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("danceId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.beginTime
    container.__data__.beginTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("beginTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.endTime
    container.__data__.endTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("endTime", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.randIndex
    container.__data__.randIndex = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("randIndex", last)
  end,
  [5] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.dancer_info").New()
      v:MergeData(buffer, watcherList)
      container.dancers.__data__[dk] = v
      container.Watcher:MarkMapDirty("dancers", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.dancers.__data__[dk]
      container.dancers.__data__[dk] = nil
      container.Watcher:MarkMapDirty("dancers", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.dancers.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dancer_info").New()
        container.dancers.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("dancers", dk, {})
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.buffId
    container.__data__.buffId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("buffId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.npcId
    container.__data__.npcId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("npcId", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.npcPosIndex
    container.__data__.npcPosIndex = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("npcPosIndex", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.sumDanceScore
    container.__data__.sumDanceScore = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sumDanceScore", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.hasNotifyNpc
    container.__data__.hasNotifyNpc = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("hasNotifyNpc", last)
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
  if not pbData.danceId then
    container.__data__.danceId = 0
  end
  if not pbData.beginTime then
    container.__data__.beginTime = 0
  end
  if not pbData.endTime then
    container.__data__.endTime = 0
  end
  if not pbData.randIndex then
    container.__data__.randIndex = 0
  end
  if not pbData.dancers then
    container.__data__.dancers = {}
  end
  if not pbData.buffId then
    container.__data__.buffId = 0
  end
  if not pbData.npcId then
    container.__data__.npcId = 0
  end
  if not pbData.npcPosIndex then
    container.__data__.npcPosIndex = 0
  end
  if not pbData.sumDanceScore then
    container.__data__.sumDanceScore = 0
  end
  if not pbData.hasNotifyNpc then
    container.__data__.hasNotifyNpc = false
  end
  setForbidenMt(container)
  container.dancers.__data__ = {}
  setForbidenMt(container.dancers)
  for k, v in pairs(pbData.dancers) do
    container.dancers.__data__[k] = require("zcontainer.dancer_info").New()
    container.dancers[k]:ResetData(v)
  end
  container.__data__.dancers = nil
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
  ret.danceId = {
    fieldId = 1,
    dataType = 0,
    data = container.danceId
  }
  ret.beginTime = {
    fieldId = 2,
    dataType = 0,
    data = container.beginTime
  }
  ret.endTime = {
    fieldId = 3,
    dataType = 0,
    data = container.endTime
  }
  ret.randIndex = {
    fieldId = 4,
    dataType = 0,
    data = container.randIndex
  }
  if container.dancers ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.dancers) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 5,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.dancers = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.dancers = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  ret.buffId = {
    fieldId = 6,
    dataType = 0,
    data = container.buffId
  }
  ret.npcId = {
    fieldId = 7,
    dataType = 0,
    data = container.npcId
  }
  ret.npcPosIndex = {
    fieldId = 8,
    dataType = 0,
    data = container.npcPosIndex
  }
  ret.sumDanceScore = {
    fieldId = 9,
    dataType = 0,
    data = container.sumDanceScore
  }
  ret.hasNotifyNpc = {
    fieldId = 10,
    dataType = 0,
    data = container.hasNotifyNpc
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    dancers = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.dancers)
  return ret
end
return {New = new}
