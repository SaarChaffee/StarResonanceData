local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.currentTotal
    container.__data__.currentTotal = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("currentTotal", last)
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
      local dv = br.ReadUInt32(buffer)
      container.targets.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targets", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.targets.__data__[dk]
      container.targets.__data__[dk] = nil
      container.Watcher:MarkMapDirty("targets", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.targets.__data__[dk]
      container.targets.__data__[dk] = dv
      container.Watcher:MarkMapDirty("targets", dk, last)
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
      local dv = br.ReadBoolean(buffer)
      container.awards.__data__[dk] = dv
      container.Watcher:MarkMapDirty("awards", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.awards.__data__[dk]
      container.awards.__data__[dk] = nil
      container.Watcher:MarkMapDirty("awards", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.awards.__data__[dk]
      container.awards.__data__[dk] = dv
      container.Watcher:MarkMapDirty("awards", dk, last)
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
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      container.enteredZones.__data__[dk] = dv
      container.Watcher:MarkMapDirty("enteredZones", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.enteredZones.__data__[dk]
      container.enteredZones.__data__[dk] = nil
      container.Watcher:MarkMapDirty("enteredZones", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadBoolean(buffer)
      local last = container.enteredZones.__data__[dk]
      container.enteredZones.__data__[dk] = dv
      container.Watcher:MarkMapDirty("enteredZones", dk, last)
    end
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("id", last)
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
  if not pbData.currentTotal then
    container.__data__.currentTotal = 0
  end
  if not pbData.targets then
    container.__data__.targets = {}
  end
  if not pbData.awards then
    container.__data__.awards = {}
  end
  if not pbData.enteredZones then
    container.__data__.enteredZones = {}
  end
  if not pbData.id then
    container.__data__.id = 0
  end
  setForbidenMt(container)
  container.targets.__data__ = pbData.targets
  setForbidenMt(container.targets)
  container.__data__.targets = nil
  container.awards.__data__ = pbData.awards
  setForbidenMt(container.awards)
  container.__data__.awards = nil
  container.enteredZones.__data__ = pbData.enteredZones
  setForbidenMt(container.enteredZones)
  container.__data__.enteredZones = nil
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
  ret.currentTotal = {
    fieldId = 1,
    dataType = 0,
    data = container.currentTotal
  }
  if container.targets ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.targets) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.targets = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.targets = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.awards ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.awards) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.awards = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.awards = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.enteredZones ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.enteredZones) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.enteredZones = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.enteredZones = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  ret.id = {
    fieldId = 5,
    dataType = 0,
    data = container.id
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    targets = {
      __data__ = {}
    },
    awards = {
      __data__ = {}
    },
    enteredZones = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.targets)
  setForbidenMt(ret.awards)
  setForbidenMt(ret.enteredZones)
  return ret
end
return {New = new}
