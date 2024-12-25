local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.isUnlock
    container.__data__.isUnlock = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isUnlock", last)
  end,
  [2] = function(container, buffer, watcherList)
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
      local dv = br.ReadInt32(buffer)
      container.targetNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetNum", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.targetNum.__data__[dk]
      container.targetNum.__data__[dk] = nil
      container.Watcher:MarkMapDirty("targetNum", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.targetNum.__data__[dk]
      container.targetNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetNum", dk, last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.awardFlag
    container.__data__.awardFlag = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("awardFlag", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.isFlag
    container.__data__.isFlag = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isFlag", last)
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
  if not pbData.isUnlock then
    container.__data__.isUnlock = false
  end
  if not pbData.targetNum then
    container.__data__.targetNum = {}
  end
  if not pbData.awardFlag then
    container.__data__.awardFlag = 0
  end
  if not pbData.isFlag then
    container.__data__.isFlag = false
  end
  setForbidenMt(container)
  container.targetNum.__data__ = pbData.targetNum
  setForbidenMt(container.targetNum)
  container.__data__.targetNum = nil
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
  ret.isUnlock = {
    fieldId = 1,
    dataType = 0,
    data = container.isUnlock
  }
  if container.targetNum ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.targetNum) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.targetNum = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.targetNum = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.awardFlag = {
    fieldId = 3,
    dataType = 0,
    data = container.awardFlag
  }
  ret.isFlag = {
    fieldId = 4,
    dataType = 0,
    data = container.isFlag
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    targetNum = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.targetNum)
  return ret
end
return {New = new}
