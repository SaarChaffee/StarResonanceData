local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.seasonId
    container.__data__.seasonId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("seasonId", last)
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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.medal_hole").New()
      v:MergeData(buffer, watcherList)
      container.normalHoleInfos.__data__[dk] = v
      container.Watcher:MarkMapDirty("normalHoleInfos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.normalHoleInfos.__data__[dk]
      container.normalHoleInfos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("normalHoleInfos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.normalHoleInfos.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.medal_hole").New()
        container.normalHoleInfos.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("normalHoleInfos", dk, {})
    end
  end,
  [3] = function(container, buffer, watcherList)
    container.coreHoleInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("coreHoleInfo", {})
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
      local dk = br.ReadUInt32(buffer)
      local v = require("zcontainer.medal_node").New()
      v:MergeData(buffer, watcherList)
      container.coreHoleNodeInfos.__data__[dk] = v
      container.Watcher:MarkMapDirty("coreHoleNodeInfos", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.coreHoleNodeInfos.__data__[dk]
      container.coreHoleNodeInfos.__data__[dk] = nil
      container.Watcher:MarkMapDirty("coreHoleNodeInfos", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.coreHoleNodeInfos.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.medal_node").New()
        container.coreHoleNodeInfos.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("coreHoleNodeInfos", dk, {})
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
  if not pbData.seasonId then
    container.__data__.seasonId = 0
  end
  if not pbData.normalHoleInfos then
    container.__data__.normalHoleInfos = {}
  end
  if not pbData.coreHoleInfo then
    container.__data__.coreHoleInfo = {}
  end
  if not pbData.coreHoleNodeInfos then
    container.__data__.coreHoleNodeInfos = {}
  end
  setForbidenMt(container)
  container.normalHoleInfos.__data__ = {}
  setForbidenMt(container.normalHoleInfos)
  for k, v in pairs(pbData.normalHoleInfos) do
    container.normalHoleInfos.__data__[k] = require("zcontainer.medal_hole").New()
    container.normalHoleInfos[k]:ResetData(v)
  end
  container.__data__.normalHoleInfos = nil
  container.coreHoleInfo:ResetData(pbData.coreHoleInfo)
  container.__data__.coreHoleInfo = nil
  container.coreHoleNodeInfos.__data__ = {}
  setForbidenMt(container.coreHoleNodeInfos)
  for k, v in pairs(pbData.coreHoleNodeInfos) do
    container.coreHoleNodeInfos.__data__[k] = require("zcontainer.medal_node").New()
    container.coreHoleNodeInfos[k]:ResetData(v)
  end
  container.__data__.coreHoleNodeInfos = nil
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
  ret.seasonId = {
    fieldId = 1,
    dataType = 0,
    data = container.seasonId
  }
  if container.normalHoleInfos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.normalHoleInfos) do
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
    ret.normalHoleInfos = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.normalHoleInfos = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.coreHoleInfo == nil then
    ret.coreHoleInfo = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.coreHoleInfo = {
      fieldId = 3,
      dataType = 1,
      data = container.coreHoleInfo:GetContainerElem()
    }
  end
  if container.coreHoleNodeInfos ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.coreHoleNodeInfos) do
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
    ret.coreHoleNodeInfos = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.coreHoleNodeInfos = {
      fieldId = 4,
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
    normalHoleInfos = {
      __data__ = {}
    },
    coreHoleInfo = require("zcontainer.medal_hole").New(),
    coreHoleNodeInfos = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.normalHoleInfos)
  setForbidenMt(ret.coreHoleNodeInfos)
  return ret
end
return {New = new}
