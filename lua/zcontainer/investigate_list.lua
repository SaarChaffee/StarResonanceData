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
      local v = require("zcontainer.investigate_data").New()
      v:MergeData(buffer, watcherList)
      container.investigateMap.__data__[dk] = v
      container.Watcher:MarkMapDirty("investigateMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.investigateMap.__data__[dk]
      container.investigateMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("investigateMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.investigateMap.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.investigate_data").New()
        container.investigateMap.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("investigateMap", dk, {})
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.compInvestigateMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("compInvestigateMap", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.compInvestigateMap.__data__[dk]
      container.compInvestigateMap.__data__[dk] = nil
      container.Watcher:MarkMapDirty("compInvestigateMap", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.compInvestigateMap.__data__[dk]
      container.compInvestigateMap.__data__[dk] = dv
      container.Watcher:MarkMapDirty("compInvestigateMap", dk, last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.compReasoningMap
    container.__data__.compReasoningMap = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("compReasoningMap", last)
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
  if not pbData.investigateMap then
    container.__data__.investigateMap = {}
  end
  if not pbData.compInvestigateMap then
    container.__data__.compInvestigateMap = {}
  end
  if not pbData.compReasoningMap then
    container.__data__.compReasoningMap = {}
  end
  setForbidenMt(container)
  container.investigateMap.__data__ = {}
  setForbidenMt(container.investigateMap)
  for k, v in pairs(pbData.investigateMap) do
    container.investigateMap.__data__[k] = require("zcontainer.investigate_data").New()
    container.investigateMap[k]:ResetData(v)
  end
  container.__data__.investigateMap = nil
  container.compInvestigateMap.__data__ = pbData.compInvestigateMap
  setForbidenMt(container.compInvestigateMap)
  container.__data__.compInvestigateMap = nil
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
  if container.investigateMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.investigateMap) do
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
    ret.investigateMap = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.investigateMap = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.compInvestigateMap ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.compInvestigateMap) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.compInvestigateMap = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.compInvestigateMap = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.compReasoningMap ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.compReasoningMap) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.compReasoningMap = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.compReasoningMap = {
      fieldId = 3,
      dataType = 3,
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
    investigateMap = {
      __data__ = {}
    },
    compInvestigateMap = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.investigateMap)
  setForbidenMt(ret.compInvestigateMap)
  return ret
end
return {New = new}
