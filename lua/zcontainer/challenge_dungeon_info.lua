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
      container.dungeonInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("dungeonInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.dungeonInfo.__data__[dk]
      container.dungeonInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("dungeonInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.dungeonInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_info").New()
        container.dungeonInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("dungeonInfo", dk, {})
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
      local v = require("zcontainer.dungeon_target_award").New()
      v:MergeData(buffer, watcherList)
      container.dungeonTargetAward.__data__[dk] = v
      container.Watcher:MarkMapDirty("dungeonTargetAward", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.dungeonTargetAward.__data__[dk]
      container.dungeonTargetAward.__data__[dk] = nil
      container.Watcher:MarkMapDirty("dungeonTargetAward", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.dungeonTargetAward.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.dungeon_target_award").New()
        container.dungeonTargetAward.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("dungeonTargetAward", dk, {})
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
  if not pbData.dungeonInfo then
    container.__data__.dungeonInfo = {}
  end
  if not pbData.dungeonTargetAward then
    container.__data__.dungeonTargetAward = {}
  end
  setForbidenMt(container)
  container.dungeonInfo.__data__ = {}
  setForbidenMt(container.dungeonInfo)
  for k, v in pairs(pbData.dungeonInfo) do
    container.dungeonInfo.__data__[k] = require("zcontainer.dungeon_info").New()
    container.dungeonInfo[k]:ResetData(v)
  end
  container.__data__.dungeonInfo = nil
  container.dungeonTargetAward.__data__ = {}
  setForbidenMt(container.dungeonTargetAward)
  for k, v in pairs(pbData.dungeonTargetAward) do
    container.dungeonTargetAward.__data__[k] = require("zcontainer.dungeon_target_award").New()
    container.dungeonTargetAward[k]:ResetData(v)
  end
  container.__data__.dungeonTargetAward = nil
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
  if container.dungeonInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.dungeonInfo) do
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
    ret.dungeonInfo = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.dungeonInfo = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.dungeonTargetAward ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.dungeonTargetAward) do
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
    ret.dungeonTargetAward = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.dungeonTargetAward = {
      fieldId = 2,
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
    dungeonInfo = {
      __data__ = {}
    },
    dungeonTargetAward = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.dungeonInfo)
  setForbidenMt(ret.dungeonTargetAward)
  return ret
end
return {New = new}
