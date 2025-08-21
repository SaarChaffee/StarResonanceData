local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.fishId
    container.__data__.fishId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("fishId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.firstFlag
    container.__data__.firstFlag = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("firstFlag", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.size
    container.__data__.size = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("size", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.millisecond
    container.__data__.millisecond = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("millisecond", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.research
    container.__data__.research = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("research", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.count
    container.__data__.count = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("count", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.minSize
    container.__data__.minSize = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("minSize", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.minSizemillisecond
    container.__data__.minSizemillisecond = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("minSizemillisecond", last)
  end,
  [9] = function(container, buffer, watcherList)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt64(buffer)
      container.starCnts.__data__[dk] = dv
      container.Watcher:MarkMapDirty("starCnts", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.starCnts.__data__[dk]
      container.starCnts.__data__[dk] = nil
      container.Watcher:MarkMapDirty("starCnts", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt64(buffer)
      local last = container.starCnts.__data__[dk]
      container.starCnts.__data__[dk] = dv
      container.Watcher:MarkMapDirty("starCnts", dk, last)
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
  if not pbData.fishId then
    container.__data__.fishId = 0
  end
  if not pbData.firstFlag then
    container.__data__.firstFlag = false
  end
  if not pbData.size then
    container.__data__.size = 0
  end
  if not pbData.millisecond then
    container.__data__.millisecond = 0
  end
  if not pbData.research then
    container.__data__.research = 0
  end
  if not pbData.count then
    container.__data__.count = 0
  end
  if not pbData.minSize then
    container.__data__.minSize = 0
  end
  if not pbData.minSizemillisecond then
    container.__data__.minSizemillisecond = 0
  end
  if not pbData.starCnts then
    container.__data__.starCnts = {}
  end
  setForbidenMt(container)
  container.starCnts.__data__ = pbData.starCnts
  setForbidenMt(container.starCnts)
  container.__data__.starCnts = nil
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
  ret.fishId = {
    fieldId = 1,
    dataType = 0,
    data = container.fishId
  }
  ret.firstFlag = {
    fieldId = 2,
    dataType = 0,
    data = container.firstFlag
  }
  ret.size = {
    fieldId = 3,
    dataType = 0,
    data = container.size
  }
  ret.millisecond = {
    fieldId = 4,
    dataType = 0,
    data = container.millisecond
  }
  ret.research = {
    fieldId = 5,
    dataType = 0,
    data = container.research
  }
  ret.count = {
    fieldId = 6,
    dataType = 0,
    data = container.count
  }
  ret.minSize = {
    fieldId = 7,
    dataType = 0,
    data = container.minSize
  }
  ret.minSizemillisecond = {
    fieldId = 8,
    dataType = 0,
    data = container.minSizemillisecond
  }
  if container.starCnts ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.starCnts) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.starCnts = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.starCnts = {
      fieldId = 9,
      dataType = 2,
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
    GetContainerElem = getContainerElem,
    starCnts = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.starCnts)
  return ret
end
return {New = new}
