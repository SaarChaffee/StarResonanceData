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
    container.basicData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("basicData", {})
  end,
  [4] = function(container, buffer, watcherList)
    container.avatarInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("avatarInfo", {})
  end,
  [5] = function(container, buffer, watcherList)
    container.faceData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("faceData", {})
  end,
  [6] = function(container, buffer, watcherList)
    container.professionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("professionData", {})
  end,
  [7] = function(container, buffer, watcherList)
    container.equipData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("equipData", {})
  end,
  [8] = function(container, buffer, watcherList)
    container.fashionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fashionData", {})
  end,
  [9] = function(container, buffer, watcherList)
    container.settingData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("settingData", {})
  end,
  [10] = function(container, buffer, watcherList)
    container.sceneData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("sceneData", {})
  end,
  [11] = function(container, buffer, watcherList)
    container.userAttrData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("userAttrData", {})
  end,
  [12] = function(container, buffer, watcherList)
    container.teamData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("teamData", {})
  end,
  [13] = function(container, buffer, watcherList)
    container.unionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("unionData", {})
  end,
  [14] = function(container, buffer, watcherList)
    container.accountData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("accountData", {})
  end,
  [15] = function(container, buffer, watcherList)
    container.functionData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("functionData", {})
  end,
  [16] = function(container, buffer, watcherList)
    container.personalZone:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("personalZone", {})
  end,
  [17] = function(container, buffer, watcherList)
    container.warehouse:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("warehouse", {})
  end,
  [18] = function(container, buffer, watcherList)
    container.seasonRank:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("seasonRank", {})
  end,
  [19] = function(container, buffer, watcherList)
    container.fishData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("fishData", {})
  end,
  [20] = function(container, buffer, watcherList)
    container.communityData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("communityData", {})
  end,
  [21] = function(container, buffer, watcherList)
    container.privilegeData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("privilegeData", {})
  end,
  [22] = function(container, buffer, watcherList)
    container.masterModeDungeonData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("masterModeDungeonData", {})
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
  if not pbData.settingData then
    container.__data__.settingData = {}
  end
  if not pbData.sceneData then
    container.__data__.sceneData = {}
  end
  if not pbData.userAttrData then
    container.__data__.userAttrData = {}
  end
  if not pbData.teamData then
    container.__data__.teamData = {}
  end
  if not pbData.unionData then
    container.__data__.unionData = {}
  end
  if not pbData.accountData then
    container.__data__.accountData = {}
  end
  if not pbData.functionData then
    container.__data__.functionData = {}
  end
  if not pbData.personalZone then
    container.__data__.personalZone = {}
  end
  if not pbData.warehouse then
    container.__data__.warehouse = {}
  end
  if not pbData.seasonRank then
    container.__data__.seasonRank = {}
  end
  if not pbData.fishData then
    container.__data__.fishData = {}
  end
  if not pbData.communityData then
    container.__data__.communityData = {}
  end
  if not pbData.privilegeData then
    container.__data__.privilegeData = {}
  end
  if not pbData.masterModeDungeonData then
    container.__data__.masterModeDungeonData = {}
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
  container.settingData:ResetData(pbData.settingData)
  container.__data__.settingData = nil
  container.sceneData:ResetData(pbData.sceneData)
  container.__data__.sceneData = nil
  container.userAttrData:ResetData(pbData.userAttrData)
  container.__data__.userAttrData = nil
  container.teamData:ResetData(pbData.teamData)
  container.__data__.teamData = nil
  container.unionData:ResetData(pbData.unionData)
  container.__data__.unionData = nil
  container.accountData:ResetData(pbData.accountData)
  container.__data__.accountData = nil
  container.functionData:ResetData(pbData.functionData)
  container.__data__.functionData = nil
  container.personalZone:ResetData(pbData.personalZone)
  container.__data__.personalZone = nil
  container.warehouse:ResetData(pbData.warehouse)
  container.__data__.warehouse = nil
  container.seasonRank:ResetData(pbData.seasonRank)
  container.__data__.seasonRank = nil
  container.fishData:ResetData(pbData.fishData)
  container.__data__.fishData = nil
  container.communityData:ResetData(pbData.communityData)
  container.__data__.communityData = nil
  container.privilegeData:ResetData(pbData.privilegeData)
  container.__data__.privilegeData = nil
  container.masterModeDungeonData:ResetData(pbData.masterModeDungeonData)
  container.__data__.masterModeDungeonData = nil
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
  if container.basicData == nil then
    ret.basicData = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.basicData = {
      fieldId = 3,
      dataType = 1,
      data = container.basicData:GetContainerElem()
    }
  end
  if container.avatarInfo == nil then
    ret.avatarInfo = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.avatarInfo = {
      fieldId = 4,
      dataType = 1,
      data = container.avatarInfo:GetContainerElem()
    }
  end
  if container.faceData == nil then
    ret.faceData = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.faceData = {
      fieldId = 5,
      dataType = 1,
      data = container.faceData:GetContainerElem()
    }
  end
  if container.professionData == nil then
    ret.professionData = {
      fieldId = 6,
      dataType = 1,
      data = nil
    }
  else
    ret.professionData = {
      fieldId = 6,
      dataType = 1,
      data = container.professionData:GetContainerElem()
    }
  end
  if container.equipData == nil then
    ret.equipData = {
      fieldId = 7,
      dataType = 1,
      data = nil
    }
  else
    ret.equipData = {
      fieldId = 7,
      dataType = 1,
      data = container.equipData:GetContainerElem()
    }
  end
  if container.fashionData == nil then
    ret.fashionData = {
      fieldId = 8,
      dataType = 1,
      data = nil
    }
  else
    ret.fashionData = {
      fieldId = 8,
      dataType = 1,
      data = container.fashionData:GetContainerElem()
    }
  end
  if container.settingData == nil then
    ret.settingData = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.settingData = {
      fieldId = 9,
      dataType = 1,
      data = container.settingData:GetContainerElem()
    }
  end
  if container.sceneData == nil then
    ret.sceneData = {
      fieldId = 10,
      dataType = 1,
      data = nil
    }
  else
    ret.sceneData = {
      fieldId = 10,
      dataType = 1,
      data = container.sceneData:GetContainerElem()
    }
  end
  if container.userAttrData == nil then
    ret.userAttrData = {
      fieldId = 11,
      dataType = 1,
      data = nil
    }
  else
    ret.userAttrData = {
      fieldId = 11,
      dataType = 1,
      data = container.userAttrData:GetContainerElem()
    }
  end
  if container.teamData == nil then
    ret.teamData = {
      fieldId = 12,
      dataType = 1,
      data = nil
    }
  else
    ret.teamData = {
      fieldId = 12,
      dataType = 1,
      data = container.teamData:GetContainerElem()
    }
  end
  if container.unionData == nil then
    ret.unionData = {
      fieldId = 13,
      dataType = 1,
      data = nil
    }
  else
    ret.unionData = {
      fieldId = 13,
      dataType = 1,
      data = container.unionData:GetContainerElem()
    }
  end
  if container.accountData == nil then
    ret.accountData = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.accountData = {
      fieldId = 14,
      dataType = 1,
      data = container.accountData:GetContainerElem()
    }
  end
  if container.functionData == nil then
    ret.functionData = {
      fieldId = 15,
      dataType = 1,
      data = nil
    }
  else
    ret.functionData = {
      fieldId = 15,
      dataType = 1,
      data = container.functionData:GetContainerElem()
    }
  end
  if container.personalZone == nil then
    ret.personalZone = {
      fieldId = 16,
      dataType = 1,
      data = nil
    }
  else
    ret.personalZone = {
      fieldId = 16,
      dataType = 1,
      data = container.personalZone:GetContainerElem()
    }
  end
  if container.warehouse == nil then
    ret.warehouse = {
      fieldId = 17,
      dataType = 1,
      data = nil
    }
  else
    ret.warehouse = {
      fieldId = 17,
      dataType = 1,
      data = container.warehouse:GetContainerElem()
    }
  end
  if container.seasonRank == nil then
    ret.seasonRank = {
      fieldId = 18,
      dataType = 1,
      data = nil
    }
  else
    ret.seasonRank = {
      fieldId = 18,
      dataType = 1,
      data = container.seasonRank:GetContainerElem()
    }
  end
  if container.fishData == nil then
    ret.fishData = {
      fieldId = 19,
      dataType = 1,
      data = nil
    }
  else
    ret.fishData = {
      fieldId = 19,
      dataType = 1,
      data = container.fishData:GetContainerElem()
    }
  end
  if container.communityData == nil then
    ret.communityData = {
      fieldId = 20,
      dataType = 1,
      data = nil
    }
  else
    ret.communityData = {
      fieldId = 20,
      dataType = 1,
      data = container.communityData:GetContainerElem()
    }
  end
  if container.privilegeData == nil then
    ret.privilegeData = {
      fieldId = 21,
      dataType = 1,
      data = nil
    }
  else
    ret.privilegeData = {
      fieldId = 21,
      dataType = 1,
      data = container.privilegeData:GetContainerElem()
    }
  end
  if container.masterModeDungeonData == nil then
    ret.masterModeDungeonData = {
      fieldId = 22,
      dataType = 1,
      data = nil
    }
  else
    ret.masterModeDungeonData = {
      fieldId = 22,
      dataType = 1,
      data = container.masterModeDungeonData:GetContainerElem()
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
    settingData = require("zcontainer.setting_data").New(),
    sceneData = require("zcontainer.scene_data").New(),
    userAttrData = require("zcontainer.user_attr_data").New(),
    teamData = require("zcontainer.char_team").New(),
    unionData = require("zcontainer.union_data").New(),
    accountData = require("zcontainer.account_data").New(),
    functionData = require("zcontainer.function_data").New(),
    personalZone = require("zcontainer.personal_zone").New(),
    warehouse = require("zcontainer.warehouse_data").New(),
    seasonRank = require("zcontainer.season_rank_data").New(),
    fishData = require("zcontainer.fish_social_data").New(),
    communityData = require("zcontainer.community_data").New(),
    privilegeData = require("zcontainer.privilege_data").New(),
    masterModeDungeonData = require("zcontainer.master_mode_dungeon_data").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
