local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.communityId
    container.__data__.communityId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("communityId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.homelandId
    container.__data__.homelandId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("homelandId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.cohabitantIds
    container.__data__.cohabitantIds = t
    for i = 1, count do
      local v = br.ReadInt64(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("cohabitantIds", last)
    end
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.lastExitCohabitationTime
    container.__data__.lastExitCohabitationTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("lastExitCohabitationTime", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.buyCount
    container.__data__.buyCount = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("buyCount", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.level
    container.__data__.level = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("level", last)
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
  if not pbData.communityId then
    container.__data__.communityId = 0
  end
  if not pbData.homelandId then
    container.__data__.homelandId = 0
  end
  if not pbData.cohabitantIds then
    container.__data__.cohabitantIds = {}
  end
  if not pbData.lastExitCohabitationTime then
    container.__data__.lastExitCohabitationTime = 0
  end
  if not pbData.buyCount then
    container.__data__.buyCount = 0
  end
  if not pbData.level then
    container.__data__.level = 0
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
  ret.communityId = {
    fieldId = 1,
    dataType = 0,
    data = container.communityId
  }
  ret.homelandId = {
    fieldId = 2,
    dataType = 0,
    data = container.homelandId
  }
  if container.cohabitantIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.cohabitantIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.cohabitantIds = {
      fieldId = 3,
      dataType = 3,
      data = data
    }
  else
    ret.cohabitantIds = {
      fieldId = 3,
      dataType = 3,
      data = {}
    }
  end
  ret.lastExitCohabitationTime = {
    fieldId = 4,
    dataType = 0,
    data = container.lastExitCohabitationTime
  }
  ret.buyCount = {
    fieldId = 5,
    dataType = 0,
    data = container.buyCount
  }
  ret.level = {
    fieldId = 6,
    dataType = 0,
    data = container.level
  }
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
