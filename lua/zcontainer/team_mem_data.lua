local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.enterTime
    container.__data__.enterTime = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("enterTime", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.callStatus
    container.__data__.callStatus = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("callStatus", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.talentId
    container.__data__.talentId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("talentId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.onlineStatus
    container.__data__.onlineStatus = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("onlineStatus", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.sceneId
    container.__data__.sceneId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sceneId", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.voiceIsOpen
    container.__data__.voiceIsOpen = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("voiceIsOpen", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.groupId
    container.__data__.groupId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("groupId", last)
  end,
  [9] = function(container, buffer, watcherList)
    container.socialData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("socialData", {})
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
  if not pbData.charId then
    container.__data__.charId = 0
  end
  if not pbData.enterTime then
    container.__data__.enterTime = 0
  end
  if not pbData.callStatus then
    container.__data__.callStatus = 0
  end
  if not pbData.talentId then
    container.__data__.talentId = 0
  end
  if not pbData.onlineStatus then
    container.__data__.onlineStatus = 0
  end
  if not pbData.sceneId then
    container.__data__.sceneId = 0
  end
  if not pbData.voiceIsOpen then
    container.__data__.voiceIsOpen = false
  end
  if not pbData.groupId then
    container.__data__.groupId = 0
  end
  if not pbData.socialData then
    container.__data__.socialData = {}
  end
  setForbidenMt(container)
  container.socialData:ResetData(pbData.socialData)
  container.__data__.socialData = nil
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
  ret.charId = {
    fieldId = 1,
    dataType = 0,
    data = container.charId
  }
  ret.enterTime = {
    fieldId = 2,
    dataType = 0,
    data = container.enterTime
  }
  ret.callStatus = {
    fieldId = 3,
    dataType = 0,
    data = container.callStatus
  }
  ret.talentId = {
    fieldId = 4,
    dataType = 0,
    data = container.talentId
  }
  ret.onlineStatus = {
    fieldId = 5,
    dataType = 0,
    data = container.onlineStatus
  }
  ret.sceneId = {
    fieldId = 6,
    dataType = 0,
    data = container.sceneId
  }
  ret.voiceIsOpen = {
    fieldId = 7,
    dataType = 0,
    data = container.voiceIsOpen
  }
  ret.groupId = {
    fieldId = 8,
    dataType = 0,
    data = container.groupId
  }
  if container.socialData == nil then
    ret.socialData = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.socialData = {
      fieldId = 9,
      dataType = 1,
      data = container.socialData:GetContainerElem()
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
    socialData = require("zcontainer.team_member_social_data").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
