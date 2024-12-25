local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.photoId
    container.__data__.photoId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("photoId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.images
    container.__data__.images = t
    for i = 1, count do
      local v = require("zcontainer.image_info").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("images", last)
    end
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.renderInfo
    container.__data__.renderInfo = br.ReadString(buffer)
    container.Watcher:MarkDirty("renderInfo", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.photoDesc
    container.__data__.photoDesc = br.ReadString(buffer)
    container.Watcher:MarkDirty("photoDesc", last)
  end,
  [5] = function(container, buffer, watcherList)
    container.ownerInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("ownerInfo", {})
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
  if not pbData.photoId then
    container.__data__.photoId = 0
  end
  if not pbData.images then
    container.__data__.images = {}
  end
  if not pbData.renderInfo then
    container.__data__.renderInfo = ""
  end
  if not pbData.photoDesc then
    container.__data__.photoDesc = ""
  end
  if not pbData.ownerInfo then
    container.__data__.ownerInfo = {}
  end
  setForbidenMt(container)
  container.ownerInfo:ResetData(pbData.ownerInfo)
  container.__data__.ownerInfo = nil
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
  ret.photoId = {
    fieldId = 1,
    dataType = 0,
    data = container.photoId
  }
  if container.images ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.images) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 2,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 2,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.images = {
      fieldId = 2,
      dataType = 3,
      data = data
    }
  else
    ret.images = {
      fieldId = 2,
      dataType = 3,
      data = {}
    }
  end
  ret.renderInfo = {
    fieldId = 3,
    dataType = 0,
    data = container.renderInfo
  }
  ret.photoDesc = {
    fieldId = 4,
    dataType = 0,
    data = container.photoDesc
  }
  if container.ownerInfo == nil then
    ret.ownerInfo = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.ownerInfo = {
      fieldId = 5,
      dataType = 1,
      data = container.ownerInfo:GetContainerElem()
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
    ownerInfo = require("zcontainer.photo_owner_data").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
