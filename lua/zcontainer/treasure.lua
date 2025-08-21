local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.treasure_item_row").New()
      v:MergeData(buffer, watcherList)
      container.rows.__data__[dk] = v
      container.Watcher:MarkMapDirty("rows", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.rows.__data__[dk]
      container.rows.__data__[dk] = nil
      container.Watcher:MarkMapDirty("rows", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.rows.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.treasure_item_row").New()
        container.rows.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("rows", dk, {})
    end
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
      local v = require("zcontainer.treasure_item_row").New()
      v:MergeData(buffer, watcherList)
      container.historyRows.__data__[dk] = v
      container.Watcher:MarkMapDirty("historyRows", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.historyRows.__data__[dk]
      container.historyRows.__data__[dk] = nil
      container.Watcher:MarkMapDirty("historyRows", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.historyRows.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.treasure_item_row").New()
        container.historyRows.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("historyRows", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.flag
    container.__data__.flag = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("flag", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.refreshTime
    container.__data__.refreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("refreshTime", last)
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.selectedReward
    container.__data__.selectedReward = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("selectedReward", last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.seasonId
    container.__data__.seasonId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("seasonId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.lastSeasonId
    container.__data__.lastSeasonId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("lastSeasonId", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.lastRefreshTime
    container.__data__.lastRefreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("lastRefreshTime", last)
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
  if not pbData.rows then
    container.__data__.rows = {}
  end
  if not pbData.historyRows then
    container.__data__.historyRows = {}
  end
  if not pbData.flag then
    container.__data__.flag = false
  end
  if not pbData.refreshTime then
    container.__data__.refreshTime = 0
  end
  if not pbData.selectedReward then
    container.__data__.selectedReward = {}
  end
  if not pbData.seasonId then
    container.__data__.seasonId = 0
  end
  if not pbData.lastSeasonId then
    container.__data__.lastSeasonId = 0
  end
  if not pbData.lastRefreshTime then
    container.__data__.lastRefreshTime = 0
  end
  setForbidenMt(container)
  container.rows.__data__ = {}
  setForbidenMt(container.rows)
  for k, v in pairs(pbData.rows) do
    container.rows.__data__[k] = require("zcontainer.treasure_item_row").New()
    container.rows[k]:ResetData(v)
  end
  container.__data__.rows = nil
  container.historyRows.__data__ = {}
  setForbidenMt(container.historyRows)
  for k, v in pairs(pbData.historyRows) do
    container.historyRows.__data__[k] = require("zcontainer.treasure_item_row").New()
    container.historyRows[k]:ResetData(v)
  end
  container.__data__.historyRows = nil
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
  if container.rows ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.rows) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 1,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.rows = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.rows = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.historyRows ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.historyRows) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 2,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.historyRows = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.historyRows = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.flag = {
    fieldId = 3,
    dataType = 0,
    data = container.flag
  }
  ret.refreshTime = {
    fieldId = 4,
    dataType = 0,
    data = container.refreshTime
  }
  if container.selectedReward ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.selectedReward) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.selectedReward = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.selectedReward = {
      fieldId = 5,
      dataType = 3,
      data = {}
    }
  end
  ret.seasonId = {
    fieldId = 6,
    dataType = 0,
    data = container.seasonId
  }
  ret.lastSeasonId = {
    fieldId = 7,
    dataType = 0,
    data = container.lastSeasonId
  }
  ret.lastRefreshTime = {
    fieldId = 8,
    dataType = 0,
    data = container.lastRefreshTime
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    rows = {
      __data__ = {}
    },
    historyRows = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.rows)
  setForbidenMt(ret.historyRows)
  return ret
end
return {New = new}
