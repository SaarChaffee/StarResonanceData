local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.id
    container.__data__.id = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("id", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.guaranteeX
    container.__data__.guaranteeX = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("guaranteeX", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.guaranteeY
    container.__data__.guaranteeY = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("guaranteeY", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.residueGuaranteeTimeX
    container.__data__.residueGuaranteeTimeX = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("residueGuaranteeTimeX", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.residueGuaranteeTimeY
    container.__data__.residueGuaranteeTimeY = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("residueGuaranteeTimeY", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.residueGuaranteeTimeZ
    container.__data__.residueGuaranteeTimeZ = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("residueGuaranteeTimeZ", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.guaranteeZ
    container.__data__.guaranteeZ = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("guaranteeZ", last)
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
  if not pbData.id then
    container.__data__.id = 0
  end
  if not pbData.guaranteeX then
    container.__data__.guaranteeX = 0
  end
  if not pbData.guaranteeY then
    container.__data__.guaranteeY = 0
  end
  if not pbData.residueGuaranteeTimeX then
    container.__data__.residueGuaranteeTimeX = 0
  end
  if not pbData.residueGuaranteeTimeY then
    container.__data__.residueGuaranteeTimeY = 0
  end
  if not pbData.residueGuaranteeTimeZ then
    container.__data__.residueGuaranteeTimeZ = 0
  end
  if not pbData.guaranteeZ then
    container.__data__.guaranteeZ = 0
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
  ret.id = {
    fieldId = 1,
    dataType = 0,
    data = container.id
  }
  ret.guaranteeX = {
    fieldId = 2,
    dataType = 0,
    data = container.guaranteeX
  }
  ret.guaranteeY = {
    fieldId = 3,
    dataType = 0,
    data = container.guaranteeY
  }
  ret.residueGuaranteeTimeX = {
    fieldId = 4,
    dataType = 0,
    data = container.residueGuaranteeTimeX
  }
  ret.residueGuaranteeTimeY = {
    fieldId = 5,
    dataType = 0,
    data = container.residueGuaranteeTimeY
  }
  ret.residueGuaranteeTimeZ = {
    fieldId = 6,
    dataType = 0,
    data = container.residueGuaranteeTimeZ
  }
  ret.guaranteeZ = {
    fieldId = 7,
    dataType = 0,
    data = container.guaranteeZ
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
