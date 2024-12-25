local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.mapId
    container.__data__.mapId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("mapId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.channelId
    container.__data__.channelId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("channelId", last)
  end,
  [3] = function(container, buffer, watcherList)
    container.pos:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("pos", {})
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.levelUuid
    container.__data__.levelUuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("levelUuid", last)
  end,
  [5] = function(container, buffer, watcherList)
    container.levelPos:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("levelPos", {})
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.levelMapId
    container.__data__.levelMapId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("levelMapId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.levelReviveId
    container.__data__.levelReviveId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("levelReviveId", last)
  end,
  [8] = function(container, buffer, watcherList)
    local add = br.ReadInt32(buffer)
    local remove = 0
    local update = 0
    if add == -4 then
      return
    end
    if add == -1 then
      add = br.ReadInt32(buffer)
    else
      remove = br.ReadInt32(buffer)
      update = br.ReadInt32(buffer)
    end
    for i = 1, add do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      container.recordId.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recordId", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadUInt32(buffer)
      local last = container.recordId.__data__[dk]
      container.recordId.__data__[dk] = nil
      container.Watcher:MarkMapDirty("recordId", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadUInt32(buffer)
      local dv = br.ReadUInt32(buffer)
      local last = container.recordId.__data__[dk]
      container.recordId.__data__[dk] = dv
      container.Watcher:MarkMapDirty("recordId", dk, last)
    end
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.planeId
    container.__data__.planeId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("planeId", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.sceneLayer
    container.__data__.sceneLayer = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("sceneLayer", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.canSwitchLayer
    container.__data__.canSwitchLayer = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("canSwitchLayer", last)
  end,
  [12] = function(container, buffer, watcherList)
    container.beforeFallPos:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("beforeFallPos", {})
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.sceneGuid
    container.__data__.sceneGuid = br.ReadString(buffer)
    container.Watcher:MarkDirty("sceneGuid", last)
  end,
  [14] = function(container, buffer, watcherList)
    local last = container.__data__.dungeonGuid
    container.__data__.dungeonGuid = br.ReadString(buffer)
    container.Watcher:MarkDirty("dungeonGuid", last)
  end,
  [15] = function(container, buffer, watcherList)
    local last = container.__data__.lineId
    container.__data__.lineId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("lineId", last)
  end,
  [16] = function(container, buffer, watcherList)
    local last = container.__data__.visualLayerConfigId
    container.__data__.visualLayerConfigId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("visualLayerConfigId", last)
  end,
  [17] = function(container, buffer, watcherList)
    container.lastSceneData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("lastSceneData", {})
  end,
  [18] = function(container, buffer, watcherList)
    local last = container.__data__.sceneAreaId
    container.__data__.sceneAreaId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sceneAreaId", last)
  end,
  [19] = function(container, buffer, watcherList)
    local last = container.__data__.levelAreaId
    container.__data__.levelAreaId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("levelAreaId", last)
  end,
  [20] = function(container, buffer, watcherList)
    local last = container.__data__.beforeFallSceneAreaId
    container.__data__.beforeFallSceneAreaId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("beforeFallSceneAreaId", last)
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
  if not pbData.mapId then
    container.__data__.mapId = 0
  end
  if not pbData.channelId then
    container.__data__.channelId = 0
  end
  if not pbData.pos then
    container.__data__.pos = {}
  end
  if not pbData.levelUuid then
    container.__data__.levelUuid = 0
  end
  if not pbData.levelPos then
    container.__data__.levelPos = {}
  end
  if not pbData.levelMapId then
    container.__data__.levelMapId = 0
  end
  if not pbData.levelReviveId then
    container.__data__.levelReviveId = 0
  end
  if not pbData.recordId then
    container.__data__.recordId = {}
  end
  if not pbData.planeId then
    container.__data__.planeId = 0
  end
  if not pbData.sceneLayer then
    container.__data__.sceneLayer = 0
  end
  if not pbData.canSwitchLayer then
    container.__data__.canSwitchLayer = false
  end
  if not pbData.beforeFallPos then
    container.__data__.beforeFallPos = {}
  end
  if not pbData.sceneGuid then
    container.__data__.sceneGuid = ""
  end
  if not pbData.dungeonGuid then
    container.__data__.dungeonGuid = ""
  end
  if not pbData.lineId then
    container.__data__.lineId = 0
  end
  if not pbData.visualLayerConfigId then
    container.__data__.visualLayerConfigId = 0
  end
  if not pbData.lastSceneData then
    container.__data__.lastSceneData = {}
  end
  if not pbData.sceneAreaId then
    container.__data__.sceneAreaId = 0
  end
  if not pbData.levelAreaId then
    container.__data__.levelAreaId = 0
  end
  if not pbData.beforeFallSceneAreaId then
    container.__data__.beforeFallSceneAreaId = 0
  end
  setForbidenMt(container)
  container.pos:ResetData(pbData.pos)
  container.__data__.pos = nil
  container.levelPos:ResetData(pbData.levelPos)
  container.__data__.levelPos = nil
  container.recordId.__data__ = pbData.recordId
  setForbidenMt(container.recordId)
  container.__data__.recordId = nil
  container.beforeFallPos:ResetData(pbData.beforeFallPos)
  container.__data__.beforeFallPos = nil
  container.lastSceneData:ResetData(pbData.lastSceneData)
  container.__data__.lastSceneData = nil
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
  ret.mapId = {
    fieldId = 1,
    dataType = 0,
    data = container.mapId
  }
  ret.channelId = {
    fieldId = 2,
    dataType = 0,
    data = container.channelId
  }
  if container.pos == nil then
    ret.pos = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.pos = {
      fieldId = 3,
      dataType = 1,
      data = container.pos:GetContainerElem()
    }
  end
  ret.levelUuid = {
    fieldId = 4,
    dataType = 0,
    data = container.levelUuid
  }
  if container.levelPos == nil then
    ret.levelPos = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.levelPos = {
      fieldId = 5,
      dataType = 1,
      data = container.levelPos:GetContainerElem()
    }
  end
  ret.levelMapId = {
    fieldId = 6,
    dataType = 0,
    data = container.levelMapId
  }
  ret.levelReviveId = {
    fieldId = 7,
    dataType = 0,
    data = container.levelReviveId
  }
  if container.recordId ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.recordId) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.recordId = {
      fieldId = 8,
      dataType = 2,
      data = data
    }
  else
    ret.recordId = {
      fieldId = 8,
      dataType = 2,
      data = {}
    }
  end
  ret.planeId = {
    fieldId = 9,
    dataType = 0,
    data = container.planeId
  }
  ret.sceneLayer = {
    fieldId = 10,
    dataType = 0,
    data = container.sceneLayer
  }
  ret.canSwitchLayer = {
    fieldId = 11,
    dataType = 0,
    data = container.canSwitchLayer
  }
  if container.beforeFallPos == nil then
    ret.beforeFallPos = {
      fieldId = 12,
      dataType = 1,
      data = nil
    }
  else
    ret.beforeFallPos = {
      fieldId = 12,
      dataType = 1,
      data = container.beforeFallPos:GetContainerElem()
    }
  end
  ret.sceneGuid = {
    fieldId = 13,
    dataType = 0,
    data = container.sceneGuid
  }
  ret.dungeonGuid = {
    fieldId = 14,
    dataType = 0,
    data = container.dungeonGuid
  }
  ret.lineId = {
    fieldId = 15,
    dataType = 0,
    data = container.lineId
  }
  ret.visualLayerConfigId = {
    fieldId = 16,
    dataType = 0,
    data = container.visualLayerConfigId
  }
  if container.lastSceneData == nil then
    ret.lastSceneData = {
      fieldId = 17,
      dataType = 1,
      data = nil
    }
  else
    ret.lastSceneData = {
      fieldId = 17,
      dataType = 1,
      data = container.lastSceneData:GetContainerElem()
    }
  end
  ret.sceneAreaId = {
    fieldId = 18,
    dataType = 0,
    data = container.sceneAreaId
  }
  ret.levelAreaId = {
    fieldId = 19,
    dataType = 0,
    data = container.levelAreaId
  }
  ret.beforeFallSceneAreaId = {
    fieldId = 20,
    dataType = 0,
    data = container.beforeFallSceneAreaId
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    pos = require("zcontainer.position").New(),
    levelPos = require("zcontainer.position").New(),
    recordId = {
      __data__ = {}
    },
    beforeFallPos = require("zcontainer.position").New(),
    lastSceneData = require("zcontainer.last_scene_data").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.recordId)
  return ret
end
return {New = new}
