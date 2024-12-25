local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    container.data:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("data", {})
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.serverId
    container.__data__.serverId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("serverId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.sceneId
    container.__data__.sceneId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("sceneId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.host
    container.__data__.host = br.ReadString(buffer)
    container.Watcher:MarkDirty("host", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.changemap
    container.__data__.changemap = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("changemap", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.oldSceneId
    container.__data__.oldSceneId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("oldSceneId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.oldSceneSubType
    container.__data__.oldSceneSubType = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("oldSceneSubType", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.sceneSubType
    container.__data__.sceneSubType = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("sceneSubType", last)
  end,
  [9] = function(container, buffer, watcherList)
    container.transferInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("transferInfo", {})
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
  if not pbData.data then
    container.__data__.data = {}
  end
  if not pbData.serverId then
    container.__data__.serverId = 0
  end
  if not pbData.sceneId then
    container.__data__.sceneId = 0
  end
  if not pbData.host then
    container.__data__.host = ""
  end
  if not pbData.changemap then
    container.__data__.changemap = false
  end
  if not pbData.oldSceneId then
    container.__data__.oldSceneId = 0
  end
  if not pbData.oldSceneSubType then
    container.__data__.oldSceneSubType = 0
  end
  if not pbData.sceneSubType then
    container.__data__.sceneSubType = 0
  end
  if not pbData.transferInfo then
    container.__data__.transferInfo = {}
  end
  setForbidenMt(container)
  container.data:ResetData(pbData.data)
  container.__data__.data = nil
  container.transferInfo:ResetData(pbData.transferInfo)
  container.__data__.transferInfo = nil
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
  if container.data == nil then
    ret.data = {
      fieldId = 1,
      dataType = 1,
      data = nil
    }
  else
    ret.data = {
      fieldId = 1,
      dataType = 1,
      data = container.data:GetContainerElem()
    }
  end
  ret.serverId = {
    fieldId = 2,
    dataType = 0,
    data = container.serverId
  }
  ret.sceneId = {
    fieldId = 3,
    dataType = 0,
    data = container.sceneId
  }
  ret.host = {
    fieldId = 4,
    dataType = 0,
    data = container.host
  }
  ret.changemap = {
    fieldId = 5,
    dataType = 0,
    data = container.changemap
  }
  ret.oldSceneId = {
    fieldId = 6,
    dataType = 0,
    data = container.oldSceneId
  }
  ret.oldSceneSubType = {
    fieldId = 7,
    dataType = 0,
    data = container.oldSceneSubType
  }
  ret.sceneSubType = {
    fieldId = 8,
    dataType = 0,
    data = container.sceneSubType
  }
  if container.transferInfo == nil then
    ret.transferInfo = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.transferInfo = {
      fieldId = 9,
      dataType = 1,
      data = container.transferInfo:GetContainerElem()
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
    data = require("zcontainer.scene_data").New(),
    transferInfo = require("zcontainer.transfer_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
