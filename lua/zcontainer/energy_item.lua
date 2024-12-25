local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.energyLimit
    container.__data__.energyLimit = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("energyLimit", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.extraEnergyLimit
    container.__data__.extraEnergyLimit = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("extraEnergyLimit", last)
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
      local v = require("zcontainer.energy_info").New()
      v:MergeData(buffer, watcherList)
      container.energyInfo.__data__[dk] = v
      container.Watcher:MarkMapDirty("energyInfo", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.energyInfo.__data__[dk]
      container.energyInfo.__data__[dk] = nil
      container.Watcher:MarkMapDirty("energyInfo", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local last = container.energyInfo.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.energy_info").New()
        container.energyInfo.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("energyInfo", dk, {})
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
  if not pbData.energyLimit then
    container.__data__.energyLimit = 0
  end
  if not pbData.extraEnergyLimit then
    container.__data__.extraEnergyLimit = 0
  end
  if not pbData.energyInfo then
    container.__data__.energyInfo = {}
  end
  setForbidenMt(container)
  container.energyInfo.__data__ = {}
  setForbidenMt(container.energyInfo)
  for k, v in pairs(pbData.energyInfo) do
    container.energyInfo.__data__[k] = require("zcontainer.energy_info").New()
    container.energyInfo[k]:ResetData(v)
  end
  container.__data__.energyInfo = nil
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
  ret.energyLimit = {
    fieldId = 1,
    dataType = 0,
    data = container.energyLimit
  }
  ret.extraEnergyLimit = {
    fieldId = 2,
    dataType = 0,
    data = container.extraEnergyLimit
  }
  if container.energyInfo ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.energyInfo) do
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
    ret.energyInfo = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.energyInfo = {
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
    energyInfo = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.energyInfo)
  return ret
end
return {New = new}
