local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.lifeProfessionId
    container.__data__.lifeProfessionId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("lifeProfessionId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.beginTime
    container.__data__.beginTime = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("beginTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.endTime
    container.__data__.endTime = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("endTime", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.count
    container.__data__.count = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("count", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.cost
    container.__data__.cost = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("cost", last)
  end,
  [6] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.reward
    container.__data__.reward = t
    for i = 1, count do
      local v = require("zcontainer.item").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("reward", last)
    end
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.costId
    container.__data__.costId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("costId", last)
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
  if not pbData.lifeProfessionId then
    container.__data__.lifeProfessionId = 0
  end
  if not pbData.beginTime then
    container.__data__.beginTime = 0
  end
  if not pbData.endTime then
    container.__data__.endTime = 0
  end
  if not pbData.count then
    container.__data__.count = 0
  end
  if not pbData.cost then
    container.__data__.cost = 0
  end
  if not pbData.reward then
    container.__data__.reward = {}
  end
  if not pbData.costId then
    container.__data__.costId = 0
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
  ret.lifeProfessionId = {
    fieldId = 1,
    dataType = 0,
    data = container.lifeProfessionId
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
  ret.count = {
    fieldId = 4,
    dataType = 0,
    data = container.count
  }
  ret.cost = {
    fieldId = 5,
    dataType = 0,
    data = container.cost
  }
  if container.reward ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.reward) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 6,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 6,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.reward = {
      fieldId = 6,
      dataType = 3,
      data = data
    }
  else
    ret.reward = {
      fieldId = 6,
      dataType = 3,
      data = {}
    }
  end
  ret.costId = {
    fieldId = 7,
    dataType = 0,
    data = container.costId
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
