local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.passTime
    container.__data__.passTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("passTime", last)
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
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.dungeon_award").New()
      v:MergeData(buffer, watcherList)
      container.award.__data__[dk] = v
      container.Watcher:MarkMapDirty("award", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.award.__data__[dk]
      container.award.__data__[dk] = nil
      container.Watcher:MarkMapDirty("award", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.award.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_award").New()
        container.award.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("award", dk, {})
    end
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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.settlement_position").New()
      v:MergeData(buffer, watcherList)
      container.settlementPos.__data__[dk] = v
      container.Watcher:MarkMapDirty("settlementPos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.settlementPos.__data__[dk]
      container.settlementPos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("settlementPos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.settlementPos.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.settlement_position").New()
        container.settlementPos.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("settlementPos", dk, {})
    end
  end,
  [4] = function(container, buffer, watcherList)
    container.worldBossSettlement:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("worldBossSettlement", {})
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.masterModeScore
    container.__data__.masterModeScore = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("masterModeScore", last)
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
  if not pbData.passTime then
    container.__data__.passTime = 0
  end
  if not pbData.award then
    container.__data__.award = {}
  end
  if not pbData.settlementPos then
    container.__data__.settlementPos = {}
  end
  if not pbData.worldBossSettlement then
    container.__data__.worldBossSettlement = {}
  end
  if not pbData.masterModeScore then
    container.__data__.masterModeScore = 0
  end
  setForbidenMt(container)
  container.award.__data__ = {}
  setForbidenMt(container.award)
  for k, v in pairs(pbData.award) do
    container.award.__data__[k] = require("zcontainer.dungeon_award").New()
    container.award[k]:ResetData(v)
  end
  container.__data__.award = nil
  container.settlementPos.__data__ = {}
  setForbidenMt(container.settlementPos)
  for k, v in pairs(pbData.settlementPos) do
    container.settlementPos.__data__[k] = require("zcontainer.settlement_position").New()
    container.settlementPos[k]:ResetData(v)
  end
  container.__data__.settlementPos = nil
  container.worldBossSettlement:ResetData(pbData.worldBossSettlement)
  container.__data__.worldBossSettlement = nil
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
  ret.passTime = {
    fieldId = 1,
    dataType = 0,
    data = container.passTime
  }
  if container.award ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.award) do
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
    ret.award = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.award = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.settlementPos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.settlementPos) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 3,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.settlementPos = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.settlementPos = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.worldBossSettlement == nil then
    ret.worldBossSettlement = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.worldBossSettlement = {
      fieldId = 4,
      dataType = 1,
      data = container.worldBossSettlement:GetContainerElem()
    }
  end
  ret.masterModeScore = {
    fieldId = 5,
    dataType = 0,
    data = container.masterModeScore
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    award = {
      __data__ = {}
    },
    settlementPos = {
      __data__ = {}
    },
    worldBossSettlement = require("zcontainer.dungeon_world_boss_settlement").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.award)
  setForbidenMt(ret.settlementPos)
  return ret
end
return {New = new}
