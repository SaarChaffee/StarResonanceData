local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.skillLevelId
    container.__data__.skillLevelId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("skillLevelId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.skillBeginTime
    container.__data__.skillBeginTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("skillBeginTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.duration
    container.__data__.duration = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("duration", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.skillCDType
    container.__data__.skillCDType = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("skillCDType", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.professionHoldBeginTime
    container.__data__.professionHoldBeginTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("professionHoldBeginTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.chargeCount
    container.__data__.chargeCount = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("chargeCount", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.validCDTime
    container.__data__.validCDTime = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("validCDTime", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.subCDRatio
    container.__data__.subCDRatio = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("subCDRatio", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.subCDFixed
    container.__data__.subCDFixed = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("subCDFixed", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.accelerateCDRatio
    container.__data__.accelerateCDRatio = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("accelerateCDRatio", last)
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
  if not pbData.skillLevelId then
    container.__data__.skillLevelId = 0
  end
  if not pbData.skillBeginTime then
    container.__data__.skillBeginTime = 0
  end
  if not pbData.duration then
    container.__data__.duration = 0
  end
  if not pbData.skillCDType then
    container.__data__.skillCDType = 0
  end
  if not pbData.professionHoldBeginTime then
    container.__data__.professionHoldBeginTime = 0
  end
  if not pbData.chargeCount then
    container.__data__.chargeCount = 0
  end
  if not pbData.validCDTime then
    container.__data__.validCDTime = 0
  end
  if not pbData.subCDRatio then
    container.__data__.subCDRatio = 0
  end
  if not pbData.subCDFixed then
    container.__data__.subCDFixed = 0
  end
  if not pbData.accelerateCDRatio then
    container.__data__.accelerateCDRatio = 0
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
  ret.skillLevelId = {
    fieldId = 1,
    dataType = 0,
    data = container.skillLevelId
  }
  ret.skillBeginTime = {
    fieldId = 2,
    dataType = 0,
    data = container.skillBeginTime
  }
  ret.duration = {
    fieldId = 3,
    dataType = 0,
    data = container.duration
  }
  ret.skillCDType = {
    fieldId = 4,
    dataType = 0,
    data = container.skillCDType
  }
  ret.professionHoldBeginTime = {
    fieldId = 6,
    dataType = 0,
    data = container.professionHoldBeginTime
  }
  ret.chargeCount = {
    fieldId = 7,
    dataType = 0,
    data = container.chargeCount
  }
  ret.validCDTime = {
    fieldId = 8,
    dataType = 0,
    data = container.validCDTime
  }
  ret.subCDRatio = {
    fieldId = 9,
    dataType = 0,
    data = container.subCDRatio
  }
  ret.subCDFixed = {
    fieldId = 10,
    dataType = 0,
    data = container.subCDFixed
  }
  ret.accelerateCDRatio = {
    fieldId = 11,
    dataType = 0,
    data = container.accelerateCDRatio
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
