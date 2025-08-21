local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("id", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.stepId
    container.__data__.stepId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("stepId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.state
    container.__data__.state = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("state", last)
  end,
  [4] = function(container, buffer, watcherList)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      container.targetMaxNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetMaxNum", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.targetMaxNum.__data__[dk]
      container.targetMaxNum.__data__[dk] = nil
      container.Watcher:MarkMapDirty("targetMaxNum", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.targetMaxNum.__data__[dk]
      container.targetMaxNum.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetMaxNum", dk, last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.stepLimitTime
    container.__data__.stepLimitTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("stepLimitTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.stepStatus
    container.__data__.stepStatus = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("stepStatus", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.addLimitTime
    container.__data__.addLimitTime = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("addLimitTime", last)
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
      local dv = br.ReadInt32(buffer)
      container.targetType.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetType", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.targetType.__data__[dk]
      container.targetType.__data__[dk] = nil
      container.Watcher:MarkMapDirty("targetType", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.targetType.__data__[dk]
      container.targetType.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targetType", dk, last)
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
  if not pbData.id then
    container.__data__.id = 0
  end
  if not pbData.stepId then
    container.__data__.stepId = 0
  end
  if not pbData.state then
    container.__data__.state = 0
  end
  if not pbData.targetNum then
    container.__data__.targetNum = {}
  end
  if not pbData.targetMaxNum then
    container.__data__.targetMaxNum = {}
  end
  if not pbData.stepLimitTime then
    container.__data__.stepLimitTime = 0
  end
  if not pbData.stepStatus then
    container.__data__.stepStatus = 0
  end
  if not pbData.addLimitTime then
    container.__data__.addLimitTime = 0
  end
  if not pbData.targetType then
    container.__data__.targetType = {}
  end
  setForbidenMt(container)
  container.targetNum.__data__ = pbData.targetNum
  setForbidenMt(container.targetNum)
  container.__data__.targetNum = nil
  container.targetMaxNum.__data__ = pbData.targetMaxNum
  setForbidenMt(container.targetMaxNum)
  container.__data__.targetMaxNum = nil
  container.targetType.__data__ = pbData.targetType
  setForbidenMt(container.targetType)
  container.__data__.targetType = nil
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
  ret.id = {
    fieldId = 1,
    dataType = 0,
    data = container.id
  }
  ret.stepId = {
    fieldId = 2,
    dataType = 0,
    data = container.stepId
  }
  ret.state = {
    fieldId = 3,
    dataType = 0,
    data = container.state
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
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.targetNum = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.targetMaxNum ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.targetMaxNum) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.targetMaxNum = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.targetMaxNum = {
      fieldId = 5,
      dataType = 2,
      data = {}
    }
  end
  ret.stepLimitTime = {
    fieldId = 6,
    dataType = 0,
    data = container.stepLimitTime
  }
  ret.stepStatus = {
    fieldId = 7,
    dataType = 0,
    data = container.stepStatus
  }
  ret.addLimitTime = {
    fieldId = 8,
    dataType = 0,
    data = container.addLimitTime
  }
  if container.targetType ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.targetType) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.targetType = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.targetType = {
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
    targetNum = {
      __data__ = {}
    },
    targetMaxNum = {
      __data__ = {}
    },
    targetType = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.targetNum)
  setForbidenMt(ret.targetMaxNum)
  setForbidenMt(ret.targetType)
  return ret
end
return {New = new}
