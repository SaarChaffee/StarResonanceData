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
      local v = require("zcontainer.cut_scene_info").New()
      v:MergeData(buffer, watcherList)
      container.cutSceneInfos.__data__[dk] = v
      container.Watcher:MarkMapDirty("cutSceneInfos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.cutSceneInfos.__data__[dk]
      container.cutSceneInfos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("cutSceneInfos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.cutSceneInfos.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.cut_scene_info").New()
        container.cutSceneInfos.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("cutSceneInfos", dk, {})
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
      local dv = br.ReadBoolean(buffer)
      container.finishedCutScenes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishedCutScenes", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.finishedCutScenes.__data__[dk]
      container.finishedCutScenes.__data__[dk] = nil
      container.Watcher:MarkMapDirty("finishedCutScenes", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.finishedCutScenes.__data__[dk]
      container.finishedCutScenes.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishedCutScenes", dk, last)
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
      local dk = br.ReadInt64(buffer)
      local dv = br.ReadBoolean(buffer)
      container.finishedInfos.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishedInfos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.finishedInfos.__data__[dk]
      container.finishedInfos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("finishedInfos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.finishedInfos.__data__[dk]
      container.finishedInfos.__data__[dk] = dv
      container.Watcher:MarkMapDirty("finishedInfos", dk, last)
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
  if not pbData.cutSceneInfos then
    container.__data__.cutSceneInfos = {}
  end
  if not pbData.finishedCutScenes then
    container.__data__.finishedCutScenes = {}
  end
  if not pbData.finishedInfos then
    container.__data__.finishedInfos = {}
  end
  setForbidenMt(container)
  container.cutSceneInfos.__data__ = {}
  setForbidenMt(container.cutSceneInfos)
  for k, v in pairs(pbData.cutSceneInfos) do
    container.cutSceneInfos.__data__[k] = require("zcontainer.cut_scene_info").New()
    container.cutSceneInfos[k]:ResetData(v)
  end
  container.__data__.cutSceneInfos = nil
  container.finishedCutScenes.__data__ = pbData.finishedCutScenes
  setForbidenMt(container.finishedCutScenes)
  container.__data__.finishedCutScenes = nil
  container.finishedInfos.__data__ = pbData.finishedInfos
  setForbidenMt(container.finishedInfos)
  container.__data__.finishedInfos = nil
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
  if container.cutSceneInfos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.cutSceneInfos) do
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
    ret.cutSceneInfos = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.cutSceneInfos = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.finishedCutScenes ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.finishedCutScenes) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishedCutScenes = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.finishedCutScenes = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.finishedInfos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.finishedInfos) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.finishedInfos = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.finishedInfos = {
      fieldId = 3,
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
    cutSceneInfos = {
      __data__ = {}
    },
    finishedCutScenes = {
      __data__ = {}
    },
    finishedInfos = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.cutSceneInfos)
  setForbidenMt(ret.finishedCutScenes)
  setForbidenMt(ret.finishedInfos)
  return ret
end
return {New = new}
