local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.loadFlag
    container.__data__.loadFlag = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("loadFlag", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.type
    container.__data__.type = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("type", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
  end,
  [4] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.modAttrInfo
    container.__data__.modAttrInfo = t
    for i = 1, count do
      local v = require("zcontainer.mod_attr_info").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("modAttrInfo", last)
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
  if not pbData.loadFlag then
    container.__data__.loadFlag = 0
  end
  if not pbData.type then
    container.__data__.type = 0
  end
  if not pbData.level then
    container.__data__.level = 0
  end
  if not pbData.modAttrInfo then
    container.__data__.modAttrInfo = {}
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
  ret.loadFlag = {
    fieldId = 1,
    dataType = 0,
    data = container.loadFlag
  }
  ret.type = {
    fieldId = 2,
    dataType = 0,
    data = container.type
  }
  ret.level = {
    fieldId = 3,
    dataType = 0,
    data = container.level
  }
  if container.modAttrInfo ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.modAttrInfo) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 4,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 4,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.modAttrInfo = {
      fieldId = 4,
      dataType = 3,
      data = data
    }
  else
    ret.modAttrInfo = {
      fieldId = 4,
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
