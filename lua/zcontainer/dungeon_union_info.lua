local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.unionId
    container.__data__.unionId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("unionId", last)
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
      local v = require("zcontainer.union_building").New()
      v:MergeData(buffer, watcherList)
      container.unionBuildings.__data__[dk] = v
      container.Watcher:MarkMapDirty("unionBuildings", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unionBuildings.__data__[dk]
      container.unionBuildings.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unionBuildings", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.unionBuildings.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.union_building").New()
        container.unionBuildings.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("unionBuildings", dk, {})
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
      local dk = br.ReadInt32(buffer)
      local v = require("zcontainer.union_e_screen_info").New()
      v:MergeData(buffer, watcherList)
      container.eScreenInfos.__data__[dk] = v
      container.Watcher:MarkMapDirty("eScreenInfos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.eScreenInfos.__data__[dk]
      container.eScreenInfos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("eScreenInfos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.eScreenInfos.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.union_e_screen_info").New()
        container.eScreenInfos.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("eScreenInfos", dk, {})
    end
  end,
  [4] = function(container, buffer, watcherList)
    container.danceBall:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("danceBall", {})
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
  if not pbData.unionBuildings then
    container.__data__.unionBuildings = {}
  end
  if not pbData.eScreenInfos then
    container.__data__.eScreenInfos = {}
  end
  if not pbData.danceBall then
    container.__data__.danceBall = {}
  end
  setForbidenMt(container)
  container.unionBuildings.__data__ = {}
  setForbidenMt(container.unionBuildings)
  for k, v in pairs(pbData.unionBuildings) do
    container.unionBuildings.__data__[k] = require("zcontainer.union_building").New()
    container.unionBuildings[k]:ResetData(v)
  end
  container.__data__.unionBuildings = nil
  container.eScreenInfos.__data__ = {}
  setForbidenMt(container.eScreenInfos)
  for k, v in pairs(pbData.eScreenInfos) do
    container.eScreenInfos.__data__[k] = require("zcontainer.union_e_screen_info").New()
    container.eScreenInfos[k]:ResetData(v)
  end
  container.__data__.eScreenInfos = nil
  container.danceBall:ResetData(pbData.danceBall)
  container.__data__.danceBall = nil
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
  if container.unionBuildings ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unionBuildings) do
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
    ret.unionBuildings = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.unionBuildings = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.eScreenInfos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.eScreenInfos) do
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
    ret.eScreenInfos = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.eScreenInfos = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.danceBall == nil then
    ret.danceBall = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.danceBall = {
      fieldId = 4,
      dataType = 1,
      data = container.danceBall:GetContainerElem()
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
    unionBuildings = {
      __data__ = {}
    },
    eScreenInfos = {
      __data__ = {}
    },
    danceBall = require("zcontainer.dance_ball").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.unionBuildings)
  setForbidenMt(ret.eScreenInfos)
  return ret
end
return {New = new}
