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
      container.basicAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("basicAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.basicAttr.__data__[dk]
      container.basicAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("basicAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.basicAttr.__data__[dk]
      container.basicAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("basicAttr", dk, last)
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
      local dv = br.ReadInt32(buffer)
      container.advanceAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("advanceAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.advanceAttr.__data__[dk]
      container.advanceAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("advanceAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.advanceAttr.__data__[dk]
      container.advanceAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("advanceAttr", dk, last)
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
      local dv = br.ReadInt32(buffer)
      container.recastAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recastAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.recastAttr.__data__[dk]
      container.recastAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("recastAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.recastAttr.__data__[dk]
      container.recastAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recastAttr", dk, last)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      container.rareQualityAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.rareQualityAttr.__data__[dk]
      container.rareQualityAttr.__data__[dk] = nil
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.rareQualityAttr.__data__[dk]
      container.rareQualityAttr.__data__[dk] = dv
      container.Watcher:MarkMapDirty("rareQualityAttr", dk, last)
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
  if not pbData.basicAttr then
    container.__data__.basicAttr = {}
  end
  if not pbData.advanceAttr then
    container.__data__.advanceAttr = {}
  end
  if not pbData.recastAttr then
    container.__data__.recastAttr = {}
  end
  if not pbData.rareQualityAttr then
    container.__data__.rareQualityAttr = {}
  end
  setForbidenMt(container)
  container.basicAttr.__data__ = pbData.basicAttr
  setForbidenMt(container.basicAttr)
  container.__data__.basicAttr = nil
  container.advanceAttr.__data__ = pbData.advanceAttr
  setForbidenMt(container.advanceAttr)
  container.__data__.advanceAttr = nil
  container.recastAttr.__data__ = pbData.recastAttr
  setForbidenMt(container.recastAttr)
  container.__data__.recastAttr = nil
  container.rareQualityAttr.__data__ = pbData.rareQualityAttr
  setForbidenMt(container.rareQualityAttr)
  container.__data__.rareQualityAttr = nil
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
  if container.basicAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.basicAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.basicAttr = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.basicAttr = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.advanceAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.advanceAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.advanceAttr = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.advanceAttr = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  if container.recastAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.recastAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.recastAttr = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.recastAttr = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.rareQualityAttr ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.rareQualityAttr) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.rareQualityAttr = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.rareQualityAttr = {
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
    basicAttr = {
      __data__ = {}
    },
    advanceAttr = {
      __data__ = {}
    },
    recastAttr = {
      __data__ = {}
    },
    rareQualityAttr = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.basicAttr)
  setForbidenMt(ret.advanceAttr)
  setForbidenMt(ret.recastAttr)
  setForbidenMt(ret.rareQualityAttr)
  return ret
end
return {New = new}
