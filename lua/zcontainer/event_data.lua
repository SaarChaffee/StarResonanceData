local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.eventType
    container.__data__.eventType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("eventType", last)
  end,
  [2] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.intParams
    container.__data__.intParams = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("intParams", last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.longParams
    container.__data__.longParams = t
    for i = 1, count do
      local v = br.ReadInt64(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("longParams", last)
    end
  end,
  [4] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.floatParams
    container.__data__.floatParams = t
    for i = 1, count do
      local v = br.ReadSingle(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("floatParams", last)
    end
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.strParams
    container.__data__.strParams = t
    for i = 1, count do
      local v = br.ReadString(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("strParams", last)
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
  if not pbData.eventType then
    container.__data__.eventType = 0
  end
  if not pbData.intParams then
    container.__data__.intParams = {}
  end
  if not pbData.longParams then
    container.__data__.longParams = {}
  end
  if not pbData.floatParams then
    container.__data__.floatParams = {}
  end
  if not pbData.strParams then
    container.__data__.strParams = {}
  end
  setForbidenMt(container)
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
  ret.eventType = {
    fieldId = 1,
    dataType = 0,
    data = container.eventType
  }
  if container.intParams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.intParams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.intParams = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.intParams = {
      fieldId = 2,
      dataType = 3,
      data = {}
    }
  end
  if container.longParams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.longParams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.longParams = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.longParams = {
      fieldId = 3,
      dataType = 3,
      data = {}
    }
  end
  if container.floatParams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.floatParams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.floatParams = {
      fieldId = 4,
      dataType = 3,
      data = data
    }
  else
    ret.floatParams = {
      fieldId = 4,
      dataType = 3,
      data = {}
    }
  end
  if container.strParams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.strParams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.strParams = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.strParams = {
      fieldId = 5,
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
    GetContainerElem = getContainerElem
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
