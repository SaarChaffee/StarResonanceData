local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.uuid
    container.__data__.uuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("uuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.clientUuid
    container.__data__.clientUuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("clientUuid", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.itemId
    container.__data__.itemId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("itemId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [5] = function(container, buffer, watcherList)
    container.position:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("position", {})
  end,
  [6] = function(container, buffer, watcherList)
    container.quaternion:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("quaternion", {})
  end,
  [7] = function(container, buffer, watcherList)
    container.color:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("color", {})
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
  if not pbData.uuid then
    container.__data__.uuid = 0
  end
  if not pbData.clientUuid then
    container.__data__.clientUuid = 0
  end
  if not pbData.itemId then
    container.__data__.itemId = 0
  end
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.position then
    container.__data__.position = {}
  end
  if not pbData.quaternion then
    container.__data__.quaternion = {}
  end
  if not pbData.color then
    container.__data__.color = {}
  end
  setForbidenMt(container)
  container.position:ResetData(pbData.position)
  container.__data__.position = nil
  container.quaternion:ResetData(pbData.quaternion)
  container.__data__.quaternion = nil
  container.color:ResetData(pbData.color)
  container.__data__.color = nil
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
  ret.uuid = {
    fieldId = 1,
    dataType = 0,
    data = container.uuid
  }
  ret.clientUuid = {
    fieldId = 2,
    dataType = 0,
    data = container.clientUuid
  }
  ret.itemId = {
    fieldId = 3,
    dataType = 0,
    data = container.itemId
  }
  ret.charId = {
    fieldId = 4,
    dataType = 0,
    data = container.charId
  }
  if container.position == nil then
    ret.position = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.position = {
      fieldId = 5,
      dataType = 1,
      data = container.position:GetContainerElem()
    }
  end
  if container.quaternion == nil then
    ret.quaternion = {
      fieldId = 6,
      dataType = 1,
      data = nil
    }
  else
    ret.quaternion = {
      fieldId = 6,
      dataType = 1,
      data = container.quaternion:GetContainerElem()
    }
  end
  if container.color == nil then
    ret.color = {
      fieldId = 7,
      dataType = 1,
      data = nil
    }
  else
    ret.color = {
      fieldId = 7,
      dataType = 1,
      data = container.color:GetContainerElem()
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
    position = require("zcontainer.int_vec3").New(),
    quaternion = require("zcontainer.vec4").New(),
    color = require("zcontainer.int_vec3").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
