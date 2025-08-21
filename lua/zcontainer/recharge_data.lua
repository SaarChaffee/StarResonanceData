local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.accumulateAmount
    container.__data__.accumulateAmount = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("accumulateAmount", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.lastRechargeTime
    container.__data__.lastRechargeTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("lastRechargeTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.lastRechargeAmount
    container.__data__.lastRechargeAmount = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("lastRechargeAmount", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.lastDiamondAmount
    container.__data__.lastDiamondAmount = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("lastDiamondAmount", last)
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
  if not pbData.accumulateAmount then
    container.__data__.accumulateAmount = 0
  end
  if not pbData.lastRechargeTime then
    container.__data__.lastRechargeTime = 0
  end
  if not pbData.lastRechargeAmount then
    container.__data__.lastRechargeAmount = 0
  end
  if not pbData.lastDiamondAmount then
    container.__data__.lastDiamondAmount = 0
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
  ret.accumulateAmount = {
    fieldId = 1,
    dataType = 0,
    data = container.accumulateAmount
  }
  ret.lastRechargeTime = {
    fieldId = 2,
    dataType = 0,
    data = container.lastRechargeTime
  }
  ret.lastRechargeAmount = {
    fieldId = 3,
    dataType = 0,
    data = container.lastRechargeAmount
  }
  ret.lastDiamondAmount = {
    fieldId = 4,
    dataType = 0,
    data = container.lastDiamondAmount
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
