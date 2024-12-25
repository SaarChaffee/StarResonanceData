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
    local last = container.__data__.platformType
    container.__data__.platformType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("platformType", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.accountId
    container.__data__.accountId = br.ReadString(buffer)
    container.Watcher:MarkDirty("accountId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.privilege
    container.__data__.privilege = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("privilege", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.blackEndTime
    container.__data__.blackEndTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("blackEndTime", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.banReason
    container.__data__.banReason = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("banReason", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.muteEndTime
    container.__data__.muteEndTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("muteEndTime", last)
  end,
  [9] = function(container, buffer, watcherList)
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
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadString(buffer)
      container.device.__data__[dk] = dv
      container.Watcher:MarkMapDirty("device", dk, nil)
    end
    for i = 1, remove do
      local dk = br.ReadInt32(buffer)
      local last = container.device.__data__[dk]
      container.device.__data__[dk] = nil
      container.Watcher:MarkMapDirty("device", dk, last)
    end
    for i = 1, update do
      local dk = br.ReadInt32(buffer)
      local dv = br.ReadString(buffer)
      local last = container.device.__data__[dk]
      container.device.__data__[dk] = dv
      container.Watcher:MarkMapDirty("device", dk, last)
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
  if not pbData.platformType then
    container.__data__.platformType = 0
  end
  if not pbData.accountId then
    container.__data__.accountId = ""
  end
  if not pbData.privilege then
    container.__data__.privilege = 0
  end
  if not pbData.blackEndTime then
    container.__data__.blackEndTime = 0
  end
  if not pbData.banReason then
    container.__data__.banReason = 0
  end
  if not pbData.muteEndTime then
    container.__data__.muteEndTime = 0
  end
  if not pbData.device then
    container.__data__.device = {}
  end
  setForbidenMt(container)
  container.device.__data__ = pbData.device
  setForbidenMt(container.device)
  container.__data__.device = nil
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
  ret.platformType = {
    fieldId = 3,
    dataType = 0,
    data = container.platformType
  }
  ret.accountId = {
    fieldId = 4,
    dataType = 0,
    data = container.accountId
  }
  ret.privilege = {
    fieldId = 5,
    dataType = 0,
    data = container.privilege
  }
  ret.blackEndTime = {
    fieldId = 6,
    dataType = 0,
    data = container.blackEndTime
  }
  ret.banReason = {
    fieldId = 7,
    dataType = 0,
    data = container.banReason
  }
  ret.muteEndTime = {
    fieldId = 8,
    dataType = 0,
    data = container.muteEndTime
  }
  if container.device ~= nil then
    local data = {}
    for key, repeatedItem in pairs(container.device) do
      data[key] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.device = {
      fieldId = 9,
      dataType = 2,
      data = data
    }
  else
    ret.device = {
      fieldId = 9,
      dataType = 2,
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
    GetContainerElem = getContainerElem,
    device = {
      __data__ = {}
    }
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  setForbidenMt(ret.device)
  return ret
end
return {New = new}
