local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.refreshTime
    container.__data__.refreshTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("refreshTime", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.goodsValue
    container.__data__.goodsValue = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("goodsValue", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.setOff
    container.__data__.setOff = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("setOff", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.canReceive
    container.__data__.canReceive = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("canReceive", last)
  end,
  [5] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.upGoodsList
    container.__data__.upGoodsList = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("upGoodsList", last)
    end
  end,
  [6] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.keepGoodsList
    container.__data__.keepGoodsList = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("keepGoodsList", last)
    end
  end,
  [7] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.downGoodsList
    container.__data__.downGoodsList = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("downGoodsList", last)
    end
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.canRewardTime
    container.__data__.canRewardTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("canRewardTime", last)
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
  if not pbData.refreshTime then
    container.__data__.refreshTime = 0
  end
  if not pbData.goodsValue then
    container.__data__.goodsValue = 0
  end
  if not pbData.setOff then
    container.__data__.setOff = false
  end
  if not pbData.canReceive then
    container.__data__.canReceive = false
  end
  if not pbData.upGoodsList then
    container.__data__.upGoodsList = {}
  end
  if not pbData.keepGoodsList then
    container.__data__.keepGoodsList = {}
  end
  if not pbData.downGoodsList then
    container.__data__.downGoodsList = {}
  end
  if not pbData.canRewardTime then
    container.__data__.canRewardTime = 0
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
  ret.refreshTime = {
    fieldId = 1,
    dataType = 0,
    data = container.refreshTime
  }
  ret.goodsValue = {
    fieldId = 2,
    dataType = 0,
    data = container.goodsValue
  }
  ret.setOff = {
    fieldId = 3,
    dataType = 0,
    data = container.setOff
  }
  ret.canReceive = {
    fieldId = 4,
    dataType = 0,
    data = container.canReceive
  }
  if container.upGoodsList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.upGoodsList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.upGoodsList = {
      fieldId = 5,
      dataType = 3,
      data = data
    }
  else
    ret.upGoodsList = {
      fieldId = 5,
      dataType = 3,
      data = {}
    }
  end
  if container.keepGoodsList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.keepGoodsList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.keepGoodsList = {
      fieldId = 6,
      dataType = 3,
      data = data
    }
  else
    ret.keepGoodsList = {
      fieldId = 6,
      dataType = 3,
      data = {}
    }
  end
  if container.downGoodsList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.downGoodsList) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.downGoodsList = {
      fieldId = 7,
      dataType = 3,
      data = data
    }
  else
    ret.downGoodsList = {
      fieldId = 7,
      dataType = 3,
      data = {}
    }
  end
  ret.canRewardTime = {
    fieldId = 8,
    dataType = 0,
    data = container.canRewardTime
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
