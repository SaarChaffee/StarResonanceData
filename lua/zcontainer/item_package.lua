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
      local v = require("zcontainer.package").New()
      v:MergeData(buffer, watcherList)
      container.packages.__data__[dk] = v
      container.Watcher:MarkMapDirty("packages", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.packages.__data__[dk]
      container.packages.__data__[dk] = nil
      container.Watcher:MarkMapDirty("packages", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local last = container.packages.__data__[dk]
      if last == nil then
        logWarning("last is nil: " .. dk)
        last = require("zcontainer.package").New()
        container.packages.__data__[dk] = last
      end
      last:MergeData(buffer, watcherList)
      container.Watcher:MarkMapDirty("packages", dk, {})
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
      container.unlockItems.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockItems", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.unlockItems.__data__[dk]
      container.unlockItems.__data__[dk] = nil
      container.Watcher:MarkMapDirty("unlockItems", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt32(buffer)
      local last = container.unlockItems.__data__[dk]
      container.unlockItems.__data__[dk] = dv
      container.Watcher:MarkMapDirty("unlockItems", dk, last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.quickBar
    container.__data__.quickBar = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("quickBar", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.itemUuid
    container.__data__.itemUuid = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("itemUuid", last)
  end,
  [5] = function(container, buffer, watcherList)
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
      container.useGroupCd.__data__[dk] = dv
      container.Watcher:MarkMapDirty("useGroupCd", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.useGroupCd.__data__[dk]
      container.useGroupCd.__data__[dk] = nil
      container.Watcher:MarkMapDirty("useGroupCd", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadInt64(buffer)
      local last = container.useGroupCd.__data__[dk]
      container.useGroupCd.__data__[dk] = dv
      container.Watcher:MarkMapDirty("useGroupCd", dk, last)
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
  if not pbData.packages then
    container.__data__.packages = {}
  end
  if not pbData.unlockItems then
    container.__data__.unlockItems = {}
  end
  if not pbData.quickBar then
    container.__data__.quickBar = 0
  end
  if not pbData.itemUuid then
    container.__data__.itemUuid = 0
  end
  if not pbData.useGroupCd then
    container.__data__.useGroupCd = {}
  end
  setForbidenMt(container)
  container.packages.__data__ = {}
  setForbidenMt(container.packages)
  for k, v in pairs(pbData.packages) do
    container.packages.__data__[k] = require("zcontainer.package").New()
    container.packages[k]:ResetData(v)
  end
  container.__data__.packages = nil
  container.unlockItems.__data__ = pbData.unlockItems
  setForbidenMt(container.unlockItems)
  container.__data__.unlockItems = nil
  container.useGroupCd.__data__ = pbData.useGroupCd
  setForbidenMt(container.useGroupCd)
  container.__data__.useGroupCd = nil
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
  if container.packages ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.packages) do
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
    ret.packages = {
      fieldId = 1,
      dataType = 2,
      data = data
    }
  else
    ret.packages = {
      fieldId = 1,
      dataType = 2,
      data = {}
    }
  end
  if container.unlockItems ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.unlockItems) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.unlockItems = {
      fieldId = 2,
      dataType = 2,
      data = data
    }
  else
    ret.unlockItems = {
      fieldId = 2,
      dataType = 2,
      data = {}
    }
  end
  ret.quickBar = {
    fieldId = 3,
    dataType = 0,
    data = container.quickBar
  }
  ret.itemUuid = {
    fieldId = 4,
    dataType = 0,
    data = container.itemUuid
  }
  if container.useGroupCd ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.useGroupCd) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.useGroupCd = {
      fieldId = 5,
      dataType = 2,
      data = data
    }
  else
    ret.useGroupCd = {
      fieldId = 5,
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
    packages = {
      __data__ = {}
    },
    unlockItems = {
      __data__ = {}
    },
    useGroupCd = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.packages)
  setForbidenMt(ret.unlockItems)
  setForbidenMt(ret.useGroupCd)
  return ret
end
return {New = new}
