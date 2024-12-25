local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.mailUuid
    container.__data__.mailUuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("mailUuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.mailConfigId
    container.__data__.mailConfigId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("mailConfigId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.createTime
    container.__data__.createTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("createTime", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.mailType
    container.__data__.mailType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("mailType", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.sendId
    container.__data__.sendId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("sendId", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.sendName
    container.__data__.sendName = br.ReadString(buffer)
    container.Watcher:MarkDirty("sendName", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.mailTitle
    container.__data__.mailTitle = br.ReadString(buffer)
    container.Watcher:MarkDirty("mailTitle", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.mailBody
    container.__data__.mailBody = br.ReadString(buffer)
    container.Watcher:MarkDirty("mailBody", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.timeoutMs
    container.__data__.timeoutMs = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("timeoutMs", last)
  end,
  [10] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.appendix
    container.__data__.appendix = t
    for i = 1, count do
      local v = require("zcontainer.item").New()
      v:MergeData(buffer, watcherList)
      t[#t + 1] = v
      container.Watcher:MarkDirty("appendix", last)
    end
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.mailState
    container.__data__.mailState = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("mailState", last)
  end,
  [12] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.titlePrams
    container.__data__.titlePrams = t
    for i = 1, count do
      local v = br.ReadString(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("titlePrams", last)
    end
  end,
  [13] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.bodyPrams
    container.__data__.bodyPrams = t
    for i = 1, count do
      local v = br.ReadString(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("bodyPrams", last)
    end
  end,
  [14] = function(container, buffer, watcherList)
    local last = container.__data__.acceptId
    container.__data__.acceptId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("acceptId", last)
  end,
  [15] = function(container, buffer, watcherList)
    local last = container.__data__.importance
    container.__data__.importance = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("importance", last)
  end,
  [16] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.awardIds
    container.__data__.awardIds = t
    for i = 1, count do
      local v = br.ReadUInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("awardIds", last)
    end
  end,
  [17] = function(container, buffer, watcherList)
    local last = container.__data__.RegisterBeforeTime
    container.__data__.RegisterBeforeTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("RegisterBeforeTime", last)
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
  if not pbData.mailUuid then
    container.__data__.mailUuid = 0
  end
  if not pbData.mailConfigId then
    container.__data__.mailConfigId = 0
  end
  if not pbData.createTime then
    container.__data__.createTime = 0
  end
  if not pbData.mailType then
    container.__data__.mailType = 0
  end
  if not pbData.sendId then
    container.__data__.sendId = 0
  end
  if not pbData.sendName then
    container.__data__.sendName = ""
  end
  if not pbData.mailTitle then
    container.__data__.mailTitle = ""
  end
  if not pbData.mailBody then
    container.__data__.mailBody = ""
  end
  if not pbData.timeoutMs then
    container.__data__.timeoutMs = 0
  end
  if not pbData.appendix then
    container.__data__.appendix = {}
  end
  if not pbData.mailState then
    container.__data__.mailState = 0
  end
  if not pbData.titlePrams then
    container.__data__.titlePrams = {}
  end
  if not pbData.bodyPrams then
    container.__data__.bodyPrams = {}
  end
  if not pbData.acceptId then
    container.__data__.acceptId = 0
  end
  if not pbData.importance then
    container.__data__.importance = 0
  end
  if not pbData.awardIds then
    container.__data__.awardIds = {}
  end
  if not pbData.RegisterBeforeTime then
    container.__data__.RegisterBeforeTime = 0
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
  ret.mailUuid = {
    fieldId = 1,
    dataType = 0,
    data = container.mailUuid
  }
  ret.mailConfigId = {
    fieldId = 2,
    dataType = 0,
    data = container.mailConfigId
  }
  ret.createTime = {
    fieldId = 3,
    dataType = 0,
    data = container.createTime
  }
  ret.mailType = {
    fieldId = 4,
    dataType = 0,
    data = container.mailType
  }
  ret.sendId = {
    fieldId = 5,
    dataType = 0,
    data = container.sendId
  }
  ret.sendName = {
    fieldId = 6,
    dataType = 0,
    data = container.sendName
  }
  ret.mailTitle = {
    fieldId = 7,
    dataType = 0,
    data = container.mailTitle
  }
  ret.mailBody = {
    fieldId = 8,
    dataType = 0,
    data = container.mailBody
  }
  ret.timeoutMs = {
    fieldId = 9,
    dataType = 0,
    data = container.timeoutMs
  }
  if container.appendix ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.appendix) do
      if repeatedItem == nil then
        data[index] = {
          fieldId = 10,
          dataType = 1,
          data = nil
        }
      else
        data[index] = {
          fieldId = 10,
          dataType = 1,
          data = repeatedItem:GetContainerElem()
        }
      end
    end
    ret.appendix = {
      fieldId = 10,
      dataType = 3,
      data = data
    }
  else
    ret.appendix = {
      fieldId = 10,
      dataType = 3,
      data = {}
    }
  end
  ret.mailState = {
    fieldId = 11,
    dataType = 0,
    data = container.mailState
  }
  if container.titlePrams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.titlePrams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.titlePrams = {
      fieldId = 12,
      dataType = 3,
      data = data
    }
  else
    ret.titlePrams = {
      fieldId = 12,
      dataType = 3,
      data = {}
    }
  end
  if container.bodyPrams ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.bodyPrams) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.bodyPrams = {
      fieldId = 13,
      dataType = 3,
      data = data
    }
  else
    ret.bodyPrams = {
      fieldId = 13,
      dataType = 3,
      data = {}
    }
  end
  ret.acceptId = {
    fieldId = 14,
    dataType = 0,
    data = container.acceptId
  }
  ret.importance = {
    fieldId = 15,
    dataType = 0,
    data = container.importance
  }
  if container.awardIds ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.awardIds) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.awardIds = {
      fieldId = 16,
      dataType = 3,
      data = data
    }
  else
    ret.awardIds = {
      fieldId = 16,
      dataType = 3,
      data = {}
    }
  end
  ret.RegisterBeforeTime = {
    fieldId = 17,
    dataType = 0,
    data = container.RegisterBeforeTime
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
