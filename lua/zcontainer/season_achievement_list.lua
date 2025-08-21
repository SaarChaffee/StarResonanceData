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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.season_achievement").New()
      v:MergeData(buffer, watcherList)
      container.seasonAchievementList.__data__[dk] = v
      container.Watcher:MarkMapDirty("seasonAchievementList", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.seasonAchievementList.__data__[dk]
      container.seasonAchievementList.__data__[dk] = nil
      container.Watcher:MarkMapDirty("seasonAchievementList", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.seasonAchievementList.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.season_achievement").New()
        container.seasonAchievementList.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("seasonAchievementList", dk, {})
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
  if not pbData.seasonAchievementList then
    container.__data__.seasonAchievementList = {}
  end
  if not pbData.hasInitDones then
    container.__data__.hasInitDones = {}
  end
  if not pbData.version then
    container.__data__.version = 0
  end
  setForbidenMt(container)
  container.seasonAchievementList.__data__ = {}
  setForbidenMt(container.seasonAchievementList)
  for k, v in pairs(pbData.seasonAchievementList) do
    container.seasonAchievementList.__data__[k] = require("zcontainer.season_achievement").New()
    container.seasonAchievementList[k]:ResetData(v)
  end
  container.__data__.seasonAchievementList = nil
  container.hasInitDones.__data__ = pbData.hasInitDones
  setForbidenMt(container.hasInitDones)
  container.__data__.hasInitDones = nil
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
  if container.seasonAchievementList ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.seasonAchievementList) do
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
    ret.seasonAchievementList = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.seasonAchievementList = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.hasInitDones ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.hasInitDones) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.hasInitDones = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.hasInitDones = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.version = {
    fieldId = 3,
    dataType = 0,
    data = container.version
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    seasonAchievementList = {
      __data__ = {}
    },
    hasInitDones = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.seasonAchievementList)
  setForbidenMt(ret.hasInitDones)
  return ret
end
return {New = new}
