local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.unionId
    container.__data__.unionId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("unionId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.nextJoinTime
    container.__data__.nextJoinTime = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("nextJoinTime", last)
  end,
  [3] = function(container, buffer, watcherList)
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
      local dv = br.ReadUInt64(buffer)
      container.reqUnionTimes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("reqUnionTimes", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.reqUnionTimes.__data__[dk]
      container.reqUnionTimes.__data__[dk] = nil
      container.Watcher:MarkMapDirty("reqUnionTimes", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local dv = br.ReadUInt64(buffer)
      local last = container.reqUnionTimes.__data__[dk]
      container.reqUnionTimes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("reqUnionTimes", dk, last)
    end
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.joinFlag
    container.__data__.joinFlag = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("joinFlag", last)
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.collectedIds
    container.__data__.collectedIds = t
    for i = 1, count do
      local v = br.ReadInt64(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("collectedIds", last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.activeAwardResetTime
    container.__data__.activeAwardResetTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("activeAwardResetTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.receivedAwardIds
    container.__data__.receivedAwardIds = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("receivedAwardIds", last)
    end
  end,
  [8] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.historyActivePoints
    container.__data__.historyActivePoints = t
    for i = 1, count do
      local v = require("zcontainer.union_history_active").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("historyActivePoints", last)
    end
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.activeLastRefreshTime
    container.__data__.activeLastRefreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("activeLastRefreshTime", last)
  end,
  [10] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.finishDailyActiveIds
    container.__data__.finishDailyActiveIds = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("finishDailyActiveIds", last)
    end
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.leaveTime
    container.__data__.leaveTime = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("leaveTime", last)
  end,
  [13] = function(container, buffer, watcherList)
    container.danceRecord:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("danceRecord", {})
  end,
  [14] = function(container, buffer, watcherList)
    container.userUnionHuntInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("userUnionHuntInfo", {})
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
  if not pbData.unionId then
    container.__data__.unionId = 0
  end
  if not pbData.nextJoinTime then
    container.__data__.nextJoinTime = 0
  end
  if not pbData.reqUnionTimes then
    container.__data__.reqUnionTimes = {}
  end
  if not pbData.joinFlag then
    container.__data__.joinFlag = false
  end
  if not pbData.collectedIds then
    container.__data__.collectedIds = {}
  end
  if not pbData.activeAwardResetTime then
    container.__data__.activeAwardResetTime = 0
  end
  if not pbData.receivedAwardIds then
    container.__data__.receivedAwardIds = {}
  end
  if not pbData.historyActivePoints then
    container.__data__.historyActivePoints = {}
  end
  if not pbData.activeLastRefreshTime then
    container.__data__.activeLastRefreshTime = 0
  end
  if not pbData.finishDailyActiveIds then
    container.__data__.finishDailyActiveIds = {}
  end
  if not pbData.leaveTime then
    container.__data__.leaveTime = 0
  end
  if not pbData.danceRecord then
    container.__data__.danceRecord = {}
  end
  if not pbData.userUnionHuntInfo then
    container.__data__.userUnionHuntInfo = {}
  end
  setForbidenMt(container)
  container.reqUnionTimes.__data__ = pbData.reqUnionTimes
  setForbidenMt(container.reqUnionTimes)
  container.__data__.reqUnionTimes = nil
  container.danceRecord:ResetData(pbData.danceRecord)
  container.__data__.danceRecord = nil
  container.userUnionHuntInfo:ResetData(pbData.userUnionHuntInfo)
  container.__data__.userUnionHuntInfo = nil
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
  ret.unionId = {
    fieldId = 1,
    dataType = 0,
    data = container.unionId
  }
  ret.nextJoinTime = {
    fieldId = 2,
    dataType = 0,
    data = container.nextJoinTime
  }
  if container.reqUnionTimes ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.reqUnionTimes) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.reqUnionTimes = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.reqUnionTimes = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  ret.joinFlag = {
    fieldId = 4,
    dataType = 0,
    data = container.joinFlag
  }
  if container.collectedIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.collectedIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.collectedIds = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.collectedIds = {
      fieldId = 5,
      dataType = 3,
      data = {}
    }
  end
  ret.activeAwardResetTime = {
    fieldId = 6,
    dataType = 0,
    data = container.activeAwardResetTime
  }
  if container.receivedAwardIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.receivedAwardIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.receivedAwardIds = {
      fieldId = 7,
      dataType = 3,
      data = data
    }
  else
    ret.receivedAwardIds = {
      fieldId = 7,
      dataType = 3,
      data = {}
    }
  end
  if container.historyActivePoints ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.historyActivePoints) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 8,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 8,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.historyActivePoints = {
      fieldId = 8,
      dataType = 3,
      data = data
    }
  else
    ret.historyActivePoints = {
      fieldId = 8,
      dataType = 3,
      data = {}
    }
  end
  ret.activeLastRefreshTime = {
    fieldId = 9,
    dataType = 0,
    data = container.activeLastRefreshTime
  }
  if container.finishDailyActiveIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.finishDailyActiveIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishDailyActiveIds = {
      fieldId = 10,
      dataType = 3,
      data = data
    }
  else
    ret.finishDailyActiveIds = {
      fieldId = 10,
      dataType = 3,
      data = {}
    }
  end
  ret.leaveTime = {
    fieldId = 11,
    dataType = 0,
    data = container.leaveTime
  }
  if container.danceRecord == nil then
    ret.danceRecord = {
      fieldId = 13,
      dataType = 1,
      data = nil
    }
  else
    ret.danceRecord = {
      fieldId = 13,
      dataType = 1,
      data = container.danceRecord:GetContainerElem()
    }
  end
  if container.userUnionHuntInfo == nil then
    ret.userUnionHuntInfo = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.userUnionHuntInfo = {
      fieldId = 14,
      dataType = 1,
      data = container.userUnionHuntInfo:GetContainerElem()
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
    reqUnionTimes = {
      __data__ = {}
    },
    danceRecord = require("zcontainer.union_dance_history").New(),
    userUnionHuntInfo = require("zcontainer.user_union_hunt_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.reqUnionTimes)
  return ret
end
return {New = new}
