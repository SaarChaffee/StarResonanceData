local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.bossHpPercent
    container.__data__.bossHpPercent = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("bossHpPercent", last)
  end,
  [2] = function(container, buffer, watcherList)
    container.dungeonBossRank:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonBossRank", {})
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
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.dungeon_award").New()
      v:MergeData(buffer, watcherList)
      container.bossRankAward.__data__[dk] = v
      container.Watcher:MarkMapDirty("bossRankAward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.bossRankAward.__data__[dk]
      container.bossRankAward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("bossRankAward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.bossRankAward.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_award").New()
        container.bossRankAward.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("bossRankAward", dk, {})
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
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.dungeon_award").New()
      v:MergeData(buffer, watcherList)
      container.lastHitAward.__data__[dk] = v
      container.Watcher:MarkMapDirty("lastHitAward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.lastHitAward.__data__[dk]
      container.lastHitAward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("lastHitAward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.lastHitAward.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_award").New()
        container.lastHitAward.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("lastHitAward", dk, {})
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
  if not pbData.bossHpPercent then
    container.__data__.bossHpPercent = 0
  end
  if not pbData.dungeonBossRank then
    container.__data__.dungeonBossRank = {}
  end
  if not pbData.award then
    container.__data__.award = {}
  end
  if not pbData.bossRankAward then
    container.__data__.bossRankAward = {}
  end
  if not pbData.lastHitAward then
    container.__data__.lastHitAward = {}
  end
  setForbidenMt(container)
  container.dungeonBossRank:ResetData(pbData.dungeonBossRank)
  container.__data__.dungeonBossRank = nil
  container.award.__data__ = {}
  setForbidenMt(container.award)
  for k, v in pairs(pbData.award) do
    container.award.__data__[k] = require("zcontainer.dungeon_award").New()
    container.award[k]:ResetData(v)
  end
  container.__data__.award = nil
  container.bossRankAward.__data__ = {}
  setForbidenMt(container.bossRankAward)
  for k, v in pairs(pbData.bossRankAward) do
    container.bossRankAward.__data__[k] = require("zcontainer.dungeon_award").New()
    container.bossRankAward[k]:ResetData(v)
  end
  container.__data__.bossRankAward = nil
  container.lastHitAward.__data__ = {}
  setForbidenMt(container.lastHitAward)
  for k, v in pairs(pbData.lastHitAward) do
    container.lastHitAward.__data__[k] = require("zcontainer.dungeon_award").New()
    container.lastHitAward[k]:ResetData(v)
  end
  container.__data__.lastHitAward = nil
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
  ret.bossHpPercent = {
    fieldId = 1,
    dataType = 0,
    data = container.bossHpPercent
  }
  if container.dungeonBossRank == nil then
    ret.dungeonBossRank = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonBossRank = {
      fieldId = 2,
      dataType = 1,
      data = container.dungeonBossRank:GetContainerElem()
    }
  end
  if container.award ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.award) do
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
    ret.award = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.award = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.bossRankAward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.bossRankAward) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 4,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.bossRankAward = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.bossRankAward = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  if container.lastHitAward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.lastHitAward) do
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
    ret.lastHitAward = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.lastHitAward = {
      fieldId = 5,
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
    dungeonBossRank = require("zcontainer.dungeon_boss_rank").New(),
    award = {
      __data__ = {}
    },
    bossRankAward = {
      __data__ = {}
    },
    lastHitAward = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.award)
  setForbidenMt(ret.bossRankAward)
  setForbidenMt(ret.lastHitAward)
  return ret
end
return {New = new}
