local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.accountUuid
    container.__data__.accountUuid = br.ReadString(buffer)
    container.Watcher:MarkDirty("accountUuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.openId
    container.__data__.openId = br.ReadString(buffer)
    container.Watcher:MarkDirty("openId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.accountId
    container.__data__.accountId = br.ReadString(buffer)
    container.Watcher:MarkDirty("accountId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.sdkType
    container.__data__.sdkType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sdkType", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.platformType
    container.__data__.platformType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("platformType", last)
  end,
  [7] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.faceUploadDataList
    container.__data__.faceUploadDataList = t
    for i = 1, count do
      local v = require("zcontainer.face_upload_data").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("faceUploadDataList", last)
    end
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
  if not pbData.accountUuid then
    container.__data__.accountUuid = ""
  end
  if not pbData.openId then
    container.__data__.openId = ""
  end
  if not pbData.accountId then
    container.__data__.accountId = ""
  end
  if not pbData.sdkType then
    container.__data__.sdkType = 0
  end
  if not pbData.platformType then
    container.__data__.platformType = 0
  end
  if not pbData.faceUploadDataList then
    container.__data__.faceUploadDataList = {}
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
  ret.accountUuid = {
    fieldId = 1,
    dataType = 0,
    data = container.accountUuid
  }
  ret.openId = {
    fieldId = 2,
    dataType = 0,
    data = container.openId
  }
  ret.accountId = {
    fieldId = 3,
    dataType = 0,
    data = container.accountId
  }
  ret.sdkType = {
    fieldId = 4,
    dataType = 0,
    data = container.sdkType
  }
  ret.platformType = {
    fieldId = 5,
    dataType = 0,
    data = container.platformType
  }
  if container.faceUploadDataList ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.faceUploadDataList) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 7,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 7,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.faceUploadDataList = {
      fieldId = 7,
      dataType = 3,
      data = data
    }
  else
    ret.faceUploadDataList = {
      fieldId = 7,
      dataType = 3,
      data = {}
    }
  end
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
