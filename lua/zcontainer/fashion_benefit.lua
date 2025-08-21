local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.lastRewardId
    container.__data__.lastRewardId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("lastRewardId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.pointsTask
    container.__data__.pointsTask = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("pointsTask", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.pointsCycle
    container.__data__.pointsCycle = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("pointsCycle", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.pointsCollection
    container.__data__.pointsCollection = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("pointsCollection", last)
  end,
  [6] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.fashion_benefit_task_info").New()
      v:MergeData(buffer, watcherList)
      container.taskList.__data__[dk] = v
      container.Watcher:MarkMapDirty("taskList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.taskList.__data__[dk]
      container.taskList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("taskList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.taskList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.fashion_benefit_task_info").New()
        container.taskList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("taskList", dk, {})
    end
  end,
  [7] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.collectionHistory
    container.__data__.collectionHistory = t
    for i = 1, count do
      local v = require("zcontainer.fashion_benefit_collection_history").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("collectionHistory", last)
    end
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.nextRefreshTime
    container.__data__.nextRefreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("nextRefreshTime", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.maxPoints
    container.__data__.maxPoints = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("maxPoints", last)
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.expireCycle
    container.__data__.expireCycle = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("expireCycle", last)
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.lastLevel
    container.__data__.lastLevel = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("lastLevel", last)
  end,
  [15] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.lastRewardIds
    container.__data__.lastRewardIds = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("lastRewardIds", last)
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
  if not pbData.lastRewardId then
    container.__data__.lastRewardId = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.pointsTask then
    container.__data__.pointsTask = 0
  end
  if not pbData.pointsCycle then
    container.__data__.pointsCycle = 0
  end
  if not pbData.pointsCollection then
    container.__data__.pointsCollection = 0
  end
  if not pbData.taskList then
    container.__data__.taskList = {}
  end
  if not pbData.collectionHistory then
    container.__data__.collectionHistory = {}
  end
  if not pbData.nextRefreshTime then
    container.__data__.nextRefreshTime = 0
  end
  if not pbData.maxPoints then
    container.__data__.maxPoints = 0
  end
  if not pbData.lastAddTime then
    container.__data__.lastAddTime = 0
  end
  if not pbData.curDayMaxPoints then
    container.__data__.curDayMaxPoints = 0
  end
  if not pbData.expireCycle then
    container.__data__.expireCycle = 0
  end
  if not pbData.lastLevel then
    container.__data__.lastLevel = 0
  end
  if not pbData.firtExpireTime then
    container.__data__.firtExpireTime = 0
  end
  if not pbData.lastRewardIds then
    container.__data__.lastRewardIds = {}
  end
  setForbidenMt(container)
  container.taskList.__data__ = {}
  setForbidenMt(container.taskList)
  for k, v in pairs(pbData.taskList) do
    container.taskList.__data__[k] = require("zcontainer.fashion_benefit_task_info").New()
    container.taskList[k]:ResetData(v)
  end
  container.__data__.taskList = nil
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
  ret.lastRewardId = {
    fieldId = 1,
    dataType = 0,
    data = container.lastRewardId
  }
  ret.level = {
    fieldId = 2,
    dataType = 0,
    data = container.level
  }
  ret.pointsTask = {
    fieldId = 3,
    dataType = 0,
    data = container.pointsTask
  }
  ret.pointsCycle = {
    fieldId = 4,
    dataType = 0,
    data = container.pointsCycle
  }
  ret.pointsCollection = {
    fieldId = 5,
    dataType = 0,
    data = container.pointsCollection
  }
  if container.taskList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.taskList) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 6,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 6,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.taskList = {
      fieldId = 6,
      dataType = 2,
      data = data
    }
  else
    ret.taskList = {
      fieldId = 6,
      dataType = 2,
      data = {}
    }
  end
  if container.collectionHistory ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.collectionHistory) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 7,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 7,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.collectionHistory = {
      fieldId = 7,
      dataType = 3,
      data = data
    }
  else
    ret.collectionHistory = {
      fieldId = 7,
      dataType = 3,
      data = {}
    }
  end
  ret.nextRefreshTime = {
    fieldId = 8,
    dataType = 0,
    data = container.nextRefreshTime
  }
  ret.maxPoints = {
    fieldId = 9,
    dataType = 0,
    data = container.maxPoints
  }
  ret.lastAddTime = {
    fieldId = 10,
    dataType = 0,
    data = container.lastAddTime
  }
  ret.curDayMaxPoints = {
    fieldId = 11,
    dataType = 0,
    data = container.curDayMaxPoints
  }
  ret.expireCycle = {
    fieldId = 12,
    dataType = 0,
    data = container.expireCycle
  }
  ret.lastLevel = {
    fieldId = 13,
    dataType = 0,
    data = container.lastLevel
  }
  ret.firtExpireTime = {
    fieldId = 14,
    dataType = 0,
    data = container.firtExpireTime
  }
  if container.lastRewardIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.lastRewardIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.lastRewardIds = {
      fieldId = 15,
      dataType = 3,
      data = data
    }
  else
    ret.lastRewardIds = {
      fieldId = 15,
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
    GetContainerElem = getContainerElem,
    taskList = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.taskList)
  return ret
end
return {New = new}
