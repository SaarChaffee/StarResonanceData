local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.type
    container.__data__.type = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("type", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.maxCapacity
    container.__data__.maxCapacity = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("maxCapacity", last)
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
      local dv = br.ReadInt64(buffer)
      container.itemCd.__data__[dk] = dv
      container.Watcher:MarkMapDirty("itemCd", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.itemCd.__data__[dk]
      container.itemCd.__data__[dk] = nil
      container.Watcher:MarkMapDirty("itemCd", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt64(buffer)
      local last = container.itemCd.__data__[dk]
      container.itemCd.__data__[dk] = dv
      container.Watcher:MarkMapDirty("itemCd", dk, last)
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
      local dk = br.ReadInt64(buffer)
      local v = require("zcontainer.item").New()
      v:MergeData(buffer, watcherList)
      container.items.__data__[dk] = v
      container.Watcher:MarkMapDirty("items", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt64(buffer)
      local last = container.items.__data__[dk]
      container.items.__data__[dk] = nil
      container.Watcher:MarkMapDirty("items", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt64(buffer)
      local last = container.items.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.item").New()
        container.items.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("items", dk, {})
    end
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.publicCd
    container.__data__.publicCd = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("publicCd", last)
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
  if not pbData.type then
    container.__data__.type = 0
  end
  if not pbData.maxCapacity then
    container.__data__.maxCapacity = 0
  end
  if not pbData.itemCd then
    container.__data__.itemCd = {}
  end
  if not pbData.items then
    container.__data__.items = {}
  end
  if not pbData.publicCd then
    container.__data__.publicCd = 0
  end
  if not pbData.changeVersion then
    container.__data__.changeVersion = 0
  end
  setForbidenMt(container)
  container.itemCd.__data__ = pbData.itemCd
  setForbidenMt(container.itemCd)
  container.__data__.itemCd = nil
  container.items.__data__ = {}
  setForbidenMt(container.items)
  for k, v in pairs(pbData.items) do
    container.items.__data__[k] = require("zcontainer.item").New()
    container.items[k]:ResetData(v)
  end
  container.__data__.items = nil
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
  ret.type = {
    fieldId = 1,
    dataType = 0,
    data = container.type
  }
  ret.maxCapacity = {
    fieldId = 2,
    dataType = 0,
    data = container.maxCapacity
  }
  if container.itemCd ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.itemCd) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.itemCd = {
      fieldId = 3,
      dataType = 2,
      data = data
    }
  else
    ret.itemCd = {
      fieldId = 3,
      dataType = 2,
      data = {}
    }
  end
  if container.items ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.items) do
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
    ret.items = {
      fieldId = 4,
      dataType = 2,
      data = data
    }
  else
    ret.items = {
      fieldId = 4,
      dataType = 2,
      data = {}
    }
  end
  ret.publicCd = {
    fieldId = 5,
    dataType = 0,
    data = container.publicCd
  }
  ret.changeVersion = {
    fieldId = 6,
    dataType = 0,
    data = container.changeVersion
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    itemCd = {
      __data__ = {}
    },
    items = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.itemCd)
  setForbidenMt(ret.items)
  return ret
end
return {New = new}
