local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.guid
    container.__data__.guid = br.ReadString(buffer)
    container.Watcher:MarkDirty("guid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.price
    container.__data__.price = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("price", last)
  end,
  [3] = function(container, buffer, watcherList)
    container.itemInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("itemInfo", {})
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.endTime
    container.__data__.endTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("endTime", last)
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
  if not pbData.guid then
    container.__data__.guid = ""
  end
  if not pbData.price then
    container.__data__.price = 0
  end
  if not pbData.itemInfo then
    container.__data__.itemInfo = {}
  end
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.endTime then
    container.__data__.endTime = 0
  end
  setForbidenMt(container)
  container.itemInfo:ResetData(pbData.itemInfo)
  container.__data__.itemInfo = nil
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
  ret.guid = {
    fieldId = 1,
    dataType = 0,
    data = container.guid
  }
  ret.price = {
    fieldId = 2,
    dataType = 0,
    data = container.price
  }
  if container.itemInfo == nil then
    ret.itemInfo = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.itemInfo = {
      fieldId = 3,
      dataType = 1,
      data = container.itemInfo:GetContainerElem()
    }
  end
  ret.charId = {
    fieldId = 4,
    dataType = 0,
    data = container.charId
  }
  ret.endTime = {
    fieldId = 5,
    dataType = 0,
    data = container.endTime
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    itemInfo = require("zcontainer.item").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
