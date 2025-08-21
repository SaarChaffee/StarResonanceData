local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    container.basicData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("basicData", {})
  end,
  [2] = function(container, buffer, watcherList)
    container.avatarInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("avatarInfo", {})
  end,
  [3] = function(container, buffer, watcherList)
    container.faceData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("faceData", {})
  end,
  [4] = function(container, buffer, watcherList)
    container.professionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("professionData", {})
  end,
  [5] = function(container, buffer, watcherList)
    container.equipData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equipData", {})
  end,
  [6] = function(container, buffer, watcherList)
    container.fashionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fashionData", {})
  end,
  [7] = function(container, buffer, watcherList)
    container.userSceneInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("userSceneInfo", {})
  end,
  [8] = function(container, buffer, watcherList)
    container.userAttrData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("userAttrData", {})
  end,
  [9] = function(container, buffer, watcherList)
    container.personalZone:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("personalZone", {})
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
  if not pbData.basicData then
    container.__data__.basicData = {}
  end
  if not pbData.avatarInfo then
    container.__data__.avatarInfo = {}
  end
  if not pbData.faceData then
    container.__data__.faceData = {}
  end
  if not pbData.professionData then
    container.__data__.professionData = {}
  end
  if not pbData.equipData then
    container.__data__.equipData = {}
  end
  if not pbData.fashionData then
    container.__data__.fashionData = {}
  end
  if not pbData.userSceneInfo then
    container.__data__.userSceneInfo = {}
  end
  if not pbData.userAttrData then
    container.__data__.userAttrData = {}
  end
  if not pbData.personalZone then
    container.__data__.personalZone = {}
  end
  setForbidenMt(container)
  container.basicData:ResetData(pbData.basicData)
  container.__data__.basicData = nil
  container.avatarInfo:ResetData(pbData.avatarInfo)
  container.__data__.avatarInfo = nil
  container.faceData:ResetData(pbData.faceData)
  container.__data__.faceData = nil
  container.professionData:ResetData(pbData.professionData)
  container.__data__.professionData = nil
  container.equipData:ResetData(pbData.equipData)
  container.__data__.equipData = nil
  container.fashionData:ResetData(pbData.fashionData)
  container.__data__.fashionData = nil
  container.userSceneInfo:ResetData(pbData.userSceneInfo)
  container.__data__.userSceneInfo = nil
  container.userAttrData:ResetData(pbData.userAttrData)
  container.__data__.userAttrData = nil
  container.personalZone:ResetData(pbData.personalZone)
  container.__data__.personalZone = nil
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
  if container.basicData == nil then
    ret.basicData = {
      fieldId = 1,
      dataType = 1,
      data = nil
    }
  else
    ret.basicData = {
      fieldId = 1,
      dataType = 1,
      data = container.basicData:GetContainerElem()
    }
  end
  if container.avatarInfo == nil then
    ret.avatarInfo = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.avatarInfo = {
      fieldId = 2,
      dataType = 1,
      data = container.avatarInfo:GetContainerElem()
    }
  end
  if container.faceData == nil then
    ret.faceData = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.faceData = {
      fieldId = 3,
      dataType = 1,
      data = container.faceData:GetContainerElem()
    }
  end
  if container.professionData == nil then
    ret.professionData = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.professionData = {
      fieldId = 4,
      dataType = 1,
      data = container.professionData:GetContainerElem()
    }
  end
  if container.equipData == nil then
    ret.equipData = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.equipData = {
      fieldId = 5,
      dataType = 1,
      data = container.equipData:GetContainerElem()
    }
  end
  if container.fashionData == nil then
    ret.fashionData = {
      fieldId = 6,
      dataType = 1,
      data = nil
    }
  else
    ret.fashionData = {
      fieldId = 6,
      dataType = 1,
      data = container.fashionData:GetContainerElem()
    }
  end
  if container.userSceneInfo == nil then
    ret.userSceneInfo = {
      fieldId = 7,
      dataType = 1,
      data = nil
    }
  else
    ret.userSceneInfo = {
      fieldId = 7,
      dataType = 1,
      data = container.userSceneInfo:GetContainerElem()
    }
  end
  if container.userAttrData == nil then
    ret.userAttrData = {
      fieldId = 8,
      dataType = 1,
      data = nil
    }
  else
    ret.userAttrData = {
      fieldId = 8,
      dataType = 1,
      data = container.userAttrData:GetContainerElem()
    }
  end
  if container.personalZone == nil then
    ret.personalZone = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.personalZone = {
      fieldId = 9,
      dataType = 1,
      data = container.personalZone:GetContainerElem()
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
    basicData = require("zcontainer.basic_data").New(),
    avatarInfo = require("zcontainer.avatar_info").New(),
    faceData = require("zcontainer.face_data").New(),
    professionData = require("zcontainer.profession_data").New(),
    equipData = require("zcontainer.equip_data").New(),
    fashionData = require("zcontainer.fashion_data").New(),
    userSceneInfo = require("zcontainer.user_scene_info").New(),
    userAttrData = require("zcontainer.user_attr_data").New(),
    personalZone = require("zcontainer.personal_zone_show").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
