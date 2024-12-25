local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.charId
    container.__data__.charId = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("charId", last)
  end,
  [2] = function(container, buffer, watcherList)
    local last = container.__data__.accountId
    container.__data__.accountId = br.ReadString(buffer)
    container.Watcher:MarkDirty("accountId", last)
  end,
  [3] = function(container, buffer, watcherList)
    local last = container.__data__.showId
    container.__data__.showId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("showId", last)
  end,
  [4] = function(container, buffer, watcherList)
    local last = container.__data__.serverId
    container.__data__.serverId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("serverId", last)
  end,
  [5] = function(container, buffer, watcherList)
    local last = container.__data__.name
    container.__data__.name = br.ReadString(buffer)
    container.Watcher:MarkDirty("name", last)
  end,
  [6] = function(container, buffer, watcherList)
    local last = container.__data__.gender
    container.__data__.gender = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("gender", last)
  end,
  [7] = function(container, buffer, watcherList)
    local last = container.__data__.isDeleted
    container.__data__.isDeleted = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isDeleted", last)
  end,
  [8] = function(container, buffer, watcherList)
    local last = container.__data__.isForbid
    container.__data__.isForbid = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isForbid", last)
  end,
  [9] = function(container, buffer, watcherList)
    local last = container.__data__.isMute
    container.__data__.isMute = br.ReadBoolean(buffer)
    container.Watcher:MarkDirty("isMute", last)
  end,
  [10] = function(container, buffer, watcherList)
    local last = container.__data__.x
    container.__data__.x = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("x", last)
  end,
  [11] = function(container, buffer, watcherList)
    local last = container.__data__.y
    container.__data__.y = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("y", last)
  end,
  [12] = function(container, buffer, watcherList)
    local last = container.__data__.Z
    container.__data__.Z = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("Z", last)
  end,
  [13] = function(container, buffer, watcherList)
    local last = container.__data__.dir
    container.__data__.dir = br.ReadSingle(buffer)
    container.Watcher:MarkDirty("dir", last)
  end,
  [14] = function(container, buffer, watcherList)
    container.faceData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("faceData", {})
  end,
  [15] = function(container, buffer, watcherList)
    local last = container.__data__.cardId
    container.__data__.cardId = br.ReadUInt32(buffer)
    container.Watcher:MarkDirty("cardId", last)
  end,
  [16] = function(container, buffer, watcherList)
    local last = container.__data__.createTime
    container.__data__.createTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("createTime", last)
  end,
  [17] = function(container, buffer, watcherList)
    local last = container.__data__.onlineTime
    container.__data__.onlineTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("onlineTime", last)
  end,
  [18] = function(container, buffer, watcherList)
    local last = container.__data__.offlineTime
    container.__data__.offlineTime = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("offlineTime", last)
  end,
  [19] = function(container, buffer, watcherList)
    container.profileInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("profileInfo", {})
  end,
  [21] = function(container, buffer, watcherList)
    local last = container.__data__.CharState
    container.__data__.CharState = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("CharState", last)
  end,
  [22] = function(container, buffer, watcherList)
    local last = container.__data__.bodySize
    container.__data__.bodySize = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("bodySize", last)
  end,
  [23] = function(container, buffer, watcherList)
    container.unionInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("unionInfo", {})
  end,
  [24] = function(container, buffer, watcherList)
    local count = br.ReadInt32(buffer)
    if count == -4 then
      return
    end
    local t = {}
    local last = container.__data__.personalState
    container.__data__.personalState = t
    for i = 1, count do
      local v = br.ReadInt32(buffer)
      t[#t + 1] = v
      container.Watcher:MarkDirty("personalState", last)
    end
  end,
  [25] = function(container, buffer, watcherList)
    container.avatarInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("avatarInfo", {})
  end,
  [26] = function(container, buffer, watcherList)
    local last = container.__data__.totalOnlineTime
    container.__data__.totalOnlineTime = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("totalOnlineTime", last)
  end,
  [27] = function(container, buffer, watcherList)
    local last = container.__data__.openId
    container.__data__.openId = br.ReadString(buffer)
    container.Watcher:MarkDirty("openId", last)
  end,
  [28] = function(container, buffer, watcherList)
    local last = container.__data__.sdkType
    container.__data__.sdkType = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("sdkType", last)
  end,
  [29] = function(container, buffer, watcherList)
    local last = container.__data__.os
    container.__data__.os = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("os", last)
  end,
  [31] = function(container, buffer, watcherList)
    local last = container.__data__.initProfessionId
    container.__data__.initProfessionId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("initProfessionId", last)
  end,
  [32] = function(container, buffer, watcherList)
    local last = container.__data__.lastCalTotalTime
    container.__data__.lastCalTotalTime = br.ReadUInt64(buffer)
    container.Watcher:MarkDirty("lastCalTotalTime", last)
  end,
  [33] = function(container, buffer, watcherList)
    local last = container.__data__.areaId
    container.__data__.areaId = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("areaId", last)
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
  if not pbData.accountId then
    container.__data__.accountId = ""
  end
  if not pbData.showId then
    container.__data__.showId = 0
  end
  if not pbData.serverId then
    container.__data__.serverId = 0
  end
  if not pbData.name then
    container.__data__.name = ""
  end
  if not pbData.gender then
    container.__data__.gender = 0
  end
  if not pbData.isDeleted then
    container.__data__.isDeleted = false
  end
  if not pbData.isForbid then
    container.__data__.isForbid = false
  end
  if not pbData.isMute then
    container.__data__.isMute = false
  end
  if not pbData.x then
    container.__data__.x = 0
  end
  if not pbData.y then
    container.__data__.y = 0
  end
  if not pbData.Z then
    container.__data__.Z = 0
  end
  if not pbData.dir then
    container.__data__.dir = 0
  end
  if not pbData.faceData then
    container.__data__.faceData = {}
  end
  if not pbData.cardId then
    container.__data__.cardId = 0
  end
  if not pbData.createTime then
    container.__data__.createTime = 0
  end
  if not pbData.onlineTime then
    container.__data__.onlineTime = 0
  end
  if not pbData.offlineTime then
    container.__data__.offlineTime = 0
  end
  if not pbData.profileInfo then
    container.__data__.profileInfo = {}
  end
  if not pbData.teamInfo then
    container.__data__.teamInfo = {}
  end
  if not pbData.CharState then
    container.__data__.CharState = 0
  end
  if not pbData.bodySize then
    container.__data__.bodySize = 0
  end
  if not pbData.unionInfo then
    container.__data__.unionInfo = {}
  end
  if not pbData.personalState then
    container.__data__.personalState = {}
  end
  if not pbData.avatarInfo then
    container.__data__.avatarInfo = {}
  end
  if not pbData.totalOnlineTime then
    container.__data__.totalOnlineTime = 0
  end
  if not pbData.openId then
    container.__data__.openId = ""
  end
  if not pbData.sdkType then
    container.__data__.sdkType = 0
  end
  if not pbData.os then
    container.__data__.os = 0
  end
  if not pbData.initProfessionId then
    container.__data__.initProfessionId = 0
  end
  if not pbData.lastCalTotalTime then
    container.__data__.lastCalTotalTime = 0
  end
  if not pbData.areaId then
    container.__data__.areaId = 0
  end
  setForbidenMt(container)
  container.faceData:ResetData(pbData.faceData)
  container.__data__.faceData = nil
  container.profileInfo:ResetData(pbData.profileInfo)
  container.__data__.profileInfo = nil
  container.teamInfo:ResetData(pbData.teamInfo)
  container.__data__.teamInfo = nil
  container.unionInfo:ResetData(pbData.unionInfo)
  container.__data__.unionInfo = nil
  container.avatarInfo:ResetData(pbData.avatarInfo)
  container.__data__.avatarInfo = nil
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
  ret.accountId = {
    fieldId = 2,
    dataType = 0,
    data = container.accountId
  }
  ret.showId = {
    fieldId = 3,
    dataType = 0,
    data = container.showId
  }
  ret.serverId = {
    fieldId = 4,
    dataType = 0,
    data = container.serverId
  }
  ret.name = {
    fieldId = 5,
    dataType = 0,
    data = container.name
  }
  ret.gender = {
    fieldId = 6,
    dataType = 0,
    data = container.gender
  }
  ret.isDeleted = {
    fieldId = 7,
    dataType = 0,
    data = container.isDeleted
  }
  ret.isForbid = {
    fieldId = 8,
    dataType = 0,
    data = container.isForbid
  }
  ret.isMute = {
    fieldId = 9,
    dataType = 0,
    data = container.isMute
  }
  ret.x = {
    fieldId = 10,
    dataType = 0,
    data = container.x
  }
  ret.y = {
    fieldId = 11,
    dataType = 0,
    data = container.y
  }
  ret.Z = {
    fieldId = 12,
    dataType = 0,
    data = container.Z
  }
  ret.dir = {
    fieldId = 13,
    dataType = 0,
    data = container.dir
  }
  if container.faceData == nil then
    ret.faceData = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.faceData = {
      fieldId = 14,
      dataType = 1,
      data = container.faceData:GetContainerElem()
    }
  end
  ret.cardId = {
    fieldId = 15,
    dataType = 0,
    data = container.cardId
  }
  ret.createTime = {
    fieldId = 16,
    dataType = 0,
    data = container.createTime
  }
  ret.onlineTime = {
    fieldId = 17,
    dataType = 0,
    data = container.onlineTime
  }
  ret.offlineTime = {
    fieldId = 18,
    dataType = 0,
    data = container.offlineTime
  }
  if container.profileInfo == nil then
    ret.profileInfo = {
      fieldId = 19,
      dataType = 1,
      data = nil
    }
  else
    ret.profileInfo = {
      fieldId = 19,
      dataType = 1,
      data = container.profileInfo:GetContainerElem()
    }
  end
  if container.teamInfo == nil then
    ret.teamInfo = {
      fieldId = 20,
      dataType = 1,
      data = nil
    }
  else
    ret.teamInfo = {
      fieldId = 20,
      dataType = 1,
      data = container.teamInfo:GetContainerElem()
    }
  end
  ret.CharState = {
    fieldId = 21,
    dataType = 0,
    data = container.CharState
  }
  ret.bodySize = {
    fieldId = 22,
    dataType = 0,
    data = container.bodySize
  }
  if container.unionInfo == nil then
    ret.unionInfo = {
      fieldId = 23,
      dataType = 1,
      data = nil
    }
  else
    ret.unionInfo = {
      fieldId = 23,
      dataType = 1,
      data = container.unionInfo:GetContainerElem()
    }
  end
  if container.personalState ~= nil then
    local data = {}
    for index, repeatedItem in pairs(container.personalState) do
      data[index] = {
        fieldId = 0,
        dataType = 0,
        data = repeatedItem
      }
    end
    ret.personalState = {
      fieldId = 24,
      dataType = 3,
      data = data
    }
  else
    ret.personalState = {
      fieldId = 24,
      dataType = 3,
      data = {}
    }
  end
  if container.avatarInfo == nil then
    ret.avatarInfo = {
      fieldId = 25,
      dataType = 1,
      data = nil
    }
  else
    ret.avatarInfo = {
      fieldId = 25,
      dataType = 1,
      data = container.avatarInfo:GetContainerElem()
    }
  end
  ret.totalOnlineTime = {
    fieldId = 26,
    dataType = 0,
    data = container.totalOnlineTime
  }
  ret.openId = {
    fieldId = 27,
    dataType = 0,
    data = container.openId
  }
  ret.sdkType = {
    fieldId = 28,
    dataType = 0,
    data = container.sdkType
  }
  ret.os = {
    fieldId = 29,
    dataType = 0,
    data = container.os
  }
  ret.initProfessionId = {
    fieldId = 31,
    dataType = 0,
    data = container.initProfessionId
  }
  ret.lastCalTotalTime = {
    fieldId = 32,
    dataType = 0,
    data = container.lastCalTotalTime
  }
  ret.areaId = {
    fieldId = 33,
    dataType = 0,
    data = container.areaId
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    faceData = require("zcontainer.face_data").New(),
    profileInfo = require("zcontainer.profile_info").New(),
    teamInfo = require("zcontainer.char_team").New(),
    unionInfo = require("zcontainer.user_union").New(),
    avatarInfo = require("zcontainer.avatar_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
