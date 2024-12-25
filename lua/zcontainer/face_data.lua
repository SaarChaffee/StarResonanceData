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
      local dv = br.ReadInt32(buffer)
      container.faceInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("faceInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.faceInfo.__data__[dk]
      container.faceInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("faceInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.faceInfo.__data__[dk]
      container.faceInfo.__data__[dk] = dv
      container.Watcher:MarkMapDirty("faceInfo", dk, last)
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
      local v = require("zcontainer.int_vec3").New()
      v:MergeData(buffer, watcherList)
      container.colorInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("colorInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.colorInfo.__data__[dk]
      container.colorInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("colorInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.colorInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.int_vec3").New()
        container.colorInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("colorInfo", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.height
    container.__data__.height = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("height", last)
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
  if not pbData.faceInfo then
    container.__data__.faceInfo = {}
  end
  if not pbData.colorInfo then
    container.__data__.colorInfo = {}
  end
  if not pbData.height then
    container.__data__.height = 0
  end
  setForbidenMt(container)
  container.faceInfo.__data__ = pbData.faceInfo
  setForbidenMt(container.faceInfo)
  container.__data__.faceInfo = nil
  container.colorInfo.__data__ = {}
  setForbidenMt(container.colorInfo)
  for k, v in pairs(pbData.colorInfo) do
    container.colorInfo.__data__[k] = require("zcontainer.int_vec3").New()
    container.colorInfo[k]:ResetData(v)
  end
  container.__data__.colorInfo = nil
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
  if container.faceInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.faceInfo) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.faceInfo = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.faceInfo = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.colorInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.colorInfo) do
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
    ret.colorInfo = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.colorInfo = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.height = {
    fieldId = 3,
    dataType = 0,
    data = container.height
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    faceInfo = {
      __data__ = {}
    },
    colorInfo = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.faceInfo)
  setForbidenMt(ret.colorInfo)
  return ret
end
return {New = new}
