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
      local v = require("zcontainer.dungeon_info").New()
      v:MergeData(buffer, watcherList)
      container.completeDungeon.__data__[dk] = v
      container.Watcher:MarkMapDirty("completeDungeon", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.completeDungeon.__data__[dk]
      container.completeDungeon.__data__[dk] = nil
      container.Watcher:MarkMapDirty("completeDungeon", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.completeDungeon.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_info").New()
        container.completeDungeon.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("completeDungeon", dk, {})
    end
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.resetTime
    container.__data__.resetTime = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("resetTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.normalDungeonPassCount
    container.__data__.normalDungeonPassCount = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("normalDungeonPassCount", last)
  end,
  [5] = function(container, buffer, watcherList)
    container.weekTarget:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("weekTarget", {})
  end,
  [7] = function(container, buffer, watcherList)
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
      local v = require("zcontainer.raid_record").New()
      v:MergeData(buffer, watcherList)
      container.raidRecordTable.__data__[dk] = v
      container.Watcher:MarkMapDirty("raidRecordTable", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.raidRecordTable.__data__[dk]
      container.raidRecordTable.__data__[dk] = nil
      container.Watcher:MarkMapDirty("raidRecordTable", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.raidRecordTable.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.raid_record").New()
        container.raidRecordTable.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("raidRecordTable", dk, {})
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
  if not pbData.completeDungeon then
    container.__data__.completeDungeon = {}
  end
  if not pbData.resetTime then
    container.__data__.resetTime = 0
  end
  if not pbData.normalDungeonPassCount then
    container.__data__.normalDungeonPassCount = 0
  end
  if not pbData.dungeonEnterLimit then
    container.__data__.dungeonEnterLimit = {}
  end
  if not pbData.weekTarget then
    container.__data__.weekTarget = {}
  end
  if not pbData.isAssist then
    container.__data__.isAssist = false
  end
  if not pbData.raidRecordTable then
    container.__data__.raidRecordTable = {}
  end
  setForbidenMt(container)
  container.completeDungeon.__data__ = {}
  setForbidenMt(container.completeDungeon)
  for k, v in pairs(pbData.completeDungeon) do
    container.completeDungeon.__data__[k] = require("zcontainer.dungeon_info").New()
    container.completeDungeon[k]:ResetData(v)
  end
  container.__data__.completeDungeon = nil
  container.dungeonEnterLimit:ResetData(pbData.dungeonEnterLimit)
  container.__data__.dungeonEnterLimit = nil
  container.weekTarget:ResetData(pbData.weekTarget)
  container.__data__.weekTarget = nil
  container.raidRecordTable.__data__ = {}
  setForbidenMt(container.raidRecordTable)
  for k, v in pairs(pbData.raidRecordTable) do
    container.raidRecordTable.__data__[k] = require("zcontainer.raid_record").New()
    container.raidRecordTable[k]:ResetData(v)
  end
  container.__data__.raidRecordTable = nil
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
  if container.completeDungeon ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.completeDungeon) do
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
    ret.completeDungeon = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.completeDungeon = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  ret.resetTime = {
    fieldId = 2,
    dataType = 0,
    data = container.resetTime
  }
  ret.normalDungeonPassCount = {
    fieldId = 3,
    dataType = 0,
    data = container.normalDungeonPassCount
  }
  if container.dungeonEnterLimit == nil then
    ret.dungeonEnterLimit = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonEnterLimit = {
      fieldId = 4,
      dataType = 1,
      data = container.dungeonEnterLimit:GetContainerElem()
    }
  end
  if container.weekTarget == nil then
    ret.weekTarget = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.weekTarget = {
      fieldId = 5,
      dataType = 1,
      data = container.weekTarget:GetContainerElem()
    }
  end
  ret.isAssist = {
    fieldId = 6,
    dataType = 0,
    data = container.isAssist
  }
  if container.raidRecordTable ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.raidRecordTable) do
      if repeatedItem == nil then
        data[key] = {
          fieldId = 7,
          dataType = 1,
          data = nil
        }
      else
        data[key] = {
          fieldId = 7,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.raidRecordTable = {
      fieldId = 7,
      dataType = 2,
      data = data
    }
  else
    ret.raidRecordTable = {
      fieldId = 7,
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
    completeDungeon = {
      __data__ = {}
    },
    dungeonEnterLimit = require("zcontainer.dungeon_enter_limit").New(),
    weekTarget = require("zcontainer.dungeon_week_target_list").New(),
    raidRecordTable = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.completeDungeon)
  setForbidenMt(ret.raidRecordTable)
  return ret
end
return {New = new}
