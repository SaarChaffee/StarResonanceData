local br = require("sync.blob_reader")
local mergeDataFuncs = {
  [1] = function(container, buffer, watcherList)
    local last = container.__data__.sceneUuid
    container.__data__.sceneUuid = br.ReadInt64(buffer)
    container.Watcher:MarkDirty("sceneUuid", last)
  end,
  [2] = function(container, buffer, watcherList)
    container.flowInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("flowInfo", {})
  end,
  [3] = function(container, buffer, watcherList)
    container.title:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("title", {})
  end,
  [4] = function(container, buffer, watcherList)
    container.target:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("target", {})
  end,
  [5] = function(container, buffer, watcherList)
    container.damage:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("damage", {})
  end,
  [6] = function(container, buffer, watcherList)
    container.vote:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("vote", {})
  end,
  [7] = function(container, buffer, watcherList)
    container.settlement:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("settlement", {})
  end,
  [8] = function(container, buffer, watcherList)
    container.DungeonPioneer:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("DungeonPioneer", {})
  end,
  [9] = function(container, buffer, watcherList)
    container.planetRoomInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("planetRoomInfo", {})
  end,
  [10] = function(container, buffer, watcherList)
    container.dungeonVar:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonVar", {})
  end,
  [11] = function(container, buffer, watcherList)
    container.dungeonRank:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonRank", {})
  end,
  [12] = function(container, buffer, watcherList)
    container.dungeonAffixData:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonAffixData", {})
  end,
  [13] = function(container, buffer, watcherList)
    container.dungeonEvent:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonEvent", {})
  end,
  [14] = function(container, buffer, watcherList)
    container.dungeonScore:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonScore", {})
  end,
  [15] = function(container, buffer, watcherList)
    container.timerInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("timerInfo", {})
  end,
  [16] = function(container, buffer, watcherList)
    container.heroKey:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("heroKey", {})
  end,
  [17] = function(container, buffer, watcherList)
    container.dungeonUnionInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonUnionInfo", {})
  end,
  [18] = function(container, buffer, watcherList)
    container.dungeonPlayerList:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonPlayerList", {})
  end,
  [19] = function(container, buffer, watcherList)
    container.reviveInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("reviveInfo", {})
  end,
  [20] = function(container, buffer, watcherList)
    container.randomEntityConfigIdInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("randomEntityConfigIdInfo", {})
  end,
  [21] = function(container, buffer, watcherList)
    container.dungeonSceneInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonSceneInfo", {})
  end,
  [22] = function(container, buffer, watcherList)
    container.dungeonVarAll:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonVarAll", {})
  end,
  [23] = function(container, buffer, watcherList)
    container.dungeonRaidInfo:MergeData(buffer, watcherList)
    container.Watcher:MarkDirty("dungeonRaidInfo", {})
  end,
  [24] = function(container, buffer, watcherList)
    local last = container.__data__.errCode
    container.__data__.errCode = br.ReadInt32(buffer)
    container.Watcher:MarkDirty("errCode", last)
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
  if not pbData.sceneUuid then
    container.__data__.sceneUuid = 0
  end
  if not pbData.flowInfo then
    container.__data__.flowInfo = {}
  end
  if not pbData.title then
    container.__data__.title = {}
  end
  if not pbData.target then
    container.__data__.target = {}
  end
  if not pbData.damage then
    container.__data__.damage = {}
  end
  if not pbData.vote then
    container.__data__.vote = {}
  end
  if not pbData.settlement then
    container.__data__.settlement = {}
  end
  if not pbData.DungeonPioneer then
    container.__data__.DungeonPioneer = {}
  end
  if not pbData.planetRoomInfo then
    container.__data__.planetRoomInfo = {}
  end
  if not pbData.dungeonVar then
    container.__data__.dungeonVar = {}
  end
  if not pbData.dungeonRank then
    container.__data__.dungeonRank = {}
  end
  if not pbData.dungeonAffixData then
    container.__data__.dungeonAffixData = {}
  end
  if not pbData.dungeonEvent then
    container.__data__.dungeonEvent = {}
  end
  if not pbData.dungeonScore then
    container.__data__.dungeonScore = {}
  end
  if not pbData.timerInfo then
    container.__data__.timerInfo = {}
  end
  if not pbData.heroKey then
    container.__data__.heroKey = {}
  end
  if not pbData.dungeonUnionInfo then
    container.__data__.dungeonUnionInfo = {}
  end
  if not pbData.dungeonPlayerList then
    container.__data__.dungeonPlayerList = {}
  end
  if not pbData.reviveInfo then
    container.__data__.reviveInfo = {}
  end
  if not pbData.randomEntityConfigIdInfo then
    container.__data__.randomEntityConfigIdInfo = {}
  end
  if not pbData.dungeonSceneInfo then
    container.__data__.dungeonSceneInfo = {}
  end
  if not pbData.dungeonVarAll then
    container.__data__.dungeonVarAll = {}
  end
  if not pbData.dungeonRaidInfo then
    container.__data__.dungeonRaidInfo = {}
  end
  if not pbData.errCode then
    container.__data__.errCode = 0
  end
  setForbidenMt(container)
  container.flowInfo:ResetData(pbData.flowInfo)
  container.__data__.flowInfo = nil
  container.title:ResetData(pbData.title)
  container.__data__.title = nil
  container.target:ResetData(pbData.target)
  container.__data__.target = nil
  container.damage:ResetData(pbData.damage)
  container.__data__.damage = nil
  container.vote:ResetData(pbData.vote)
  container.__data__.vote = nil
  container.settlement:ResetData(pbData.settlement)
  container.__data__.settlement = nil
  container.DungeonPioneer:ResetData(pbData.DungeonPioneer)
  container.__data__.DungeonPioneer = nil
  container.planetRoomInfo:ResetData(pbData.planetRoomInfo)
  container.__data__.planetRoomInfo = nil
  container.dungeonVar:ResetData(pbData.dungeonVar)
  container.__data__.dungeonVar = nil
  container.dungeonRank:ResetData(pbData.dungeonRank)
  container.__data__.dungeonRank = nil
  container.dungeonAffixData:ResetData(pbData.dungeonAffixData)
  container.__data__.dungeonAffixData = nil
  container.dungeonEvent:ResetData(pbData.dungeonEvent)
  container.__data__.dungeonEvent = nil
  container.dungeonScore:ResetData(pbData.dungeonScore)
  container.__data__.dungeonScore = nil
  container.timerInfo:ResetData(pbData.timerInfo)
  container.__data__.timerInfo = nil
  container.heroKey:ResetData(pbData.heroKey)
  container.__data__.heroKey = nil
  container.dungeonUnionInfo:ResetData(pbData.dungeonUnionInfo)
  container.__data__.dungeonUnionInfo = nil
  container.dungeonPlayerList:ResetData(pbData.dungeonPlayerList)
  container.__data__.dungeonPlayerList = nil
  container.reviveInfo:ResetData(pbData.reviveInfo)
  container.__data__.reviveInfo = nil
  container.randomEntityConfigIdInfo:ResetData(pbData.randomEntityConfigIdInfo)
  container.__data__.randomEntityConfigIdInfo = nil
  container.dungeonSceneInfo:ResetData(pbData.dungeonSceneInfo)
  container.__data__.dungeonSceneInfo = nil
  container.dungeonVarAll:ResetData(pbData.dungeonVarAll)
  container.__data__.dungeonVarAll = nil
  container.dungeonRaidInfo:ResetData(pbData.dungeonRaidInfo)
  container.__data__.dungeonRaidInfo = nil
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
  ret.sceneUuid = {
    fieldId = 1,
    dataType = 0,
    data = container.sceneUuid
  }
  if container.flowInfo == nil then
    ret.flowInfo = {
      fieldId = 2,
      dataType = 1,
      data = nil
    }
  else
    ret.flowInfo = {
      fieldId = 2,
      dataType = 1,
      data = container.flowInfo:GetContainerElem()
    }
  end
  if container.title == nil then
    ret.title = {
      fieldId = 3,
      dataType = 1,
      data = nil
    }
  else
    ret.title = {
      fieldId = 3,
      dataType = 1,
      data = container.title:GetContainerElem()
    }
  end
  if container.target == nil then
    ret.target = {
      fieldId = 4,
      dataType = 1,
      data = nil
    }
  else
    ret.target = {
      fieldId = 4,
      dataType = 1,
      data = container.target:GetContainerElem()
    }
  end
  if container.damage == nil then
    ret.damage = {
      fieldId = 5,
      dataType = 1,
      data = nil
    }
  else
    ret.damage = {
      fieldId = 5,
      dataType = 1,
      data = container.damage:GetContainerElem()
    }
  end
  if container.vote == nil then
    ret.vote = {
      fieldId = 6,
      dataType = 1,
      data = nil
    }
  else
    ret.vote = {
      fieldId = 6,
      dataType = 1,
      data = container.vote:GetContainerElem()
    }
  end
  if container.settlement == nil then
    ret.settlement = {
      fieldId = 7,
      dataType = 1,
      data = nil
    }
  else
    ret.settlement = {
      fieldId = 7,
      dataType = 1,
      data = container.settlement:GetContainerElem()
    }
  end
  if container.DungeonPioneer == nil then
    ret.DungeonPioneer = {
      fieldId = 8,
      dataType = 1,
      data = nil
    }
  else
    ret.DungeonPioneer = {
      fieldId = 8,
      dataType = 1,
      data = container.DungeonPioneer:GetContainerElem()
    }
  end
  if container.planetRoomInfo == nil then
    ret.planetRoomInfo = {
      fieldId = 9,
      dataType = 1,
      data = nil
    }
  else
    ret.planetRoomInfo = {
      fieldId = 9,
      dataType = 1,
      data = container.planetRoomInfo:GetContainerElem()
    }
  end
  if container.dungeonVar == nil then
    ret.dungeonVar = {
      fieldId = 10,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonVar = {
      fieldId = 10,
      dataType = 1,
      data = container.dungeonVar:GetContainerElem()
    }
  end
  if container.dungeonRank == nil then
    ret.dungeonRank = {
      fieldId = 11,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonRank = {
      fieldId = 11,
      dataType = 1,
      data = container.dungeonRank:GetContainerElem()
    }
  end
  if container.dungeonAffixData == nil then
    ret.dungeonAffixData = {
      fieldId = 12,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonAffixData = {
      fieldId = 12,
      dataType = 1,
      data = container.dungeonAffixData:GetContainerElem()
    }
  end
  if container.dungeonEvent == nil then
    ret.dungeonEvent = {
      fieldId = 13,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonEvent = {
      fieldId = 13,
      dataType = 1,
      data = container.dungeonEvent:GetContainerElem()
    }
  end
  if container.dungeonScore == nil then
    ret.dungeonScore = {
      fieldId = 14,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonScore = {
      fieldId = 14,
      dataType = 1,
      data = container.dungeonScore:GetContainerElem()
    }
  end
  if container.timerInfo == nil then
    ret.timerInfo = {
      fieldId = 15,
      dataType = 1,
      data = nil
    }
  else
    ret.timerInfo = {
      fieldId = 15,
      dataType = 1,
      data = container.timerInfo:GetContainerElem()
    }
  end
  if container.heroKey == nil then
    ret.heroKey = {
      fieldId = 16,
      dataType = 1,
      data = nil
    }
  else
    ret.heroKey = {
      fieldId = 16,
      dataType = 1,
      data = container.heroKey:GetContainerElem()
    }
  end
  if container.dungeonUnionInfo == nil then
    ret.dungeonUnionInfo = {
      fieldId = 17,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonUnionInfo = {
      fieldId = 17,
      dataType = 1,
      data = container.dungeonUnionInfo:GetContainerElem()
    }
  end
  if container.dungeonPlayerList == nil then
    ret.dungeonPlayerList = {
      fieldId = 18,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonPlayerList = {
      fieldId = 18,
      dataType = 1,
      data = container.dungeonPlayerList:GetContainerElem()
    }
  end
  if container.reviveInfo == nil then
    ret.reviveInfo = {
      fieldId = 19,
      dataType = 1,
      data = nil
    }
  else
    ret.reviveInfo = {
      fieldId = 19,
      dataType = 1,
      data = container.reviveInfo:GetContainerElem()
    }
  end
  if container.randomEntityConfigIdInfo == nil then
    ret.randomEntityConfigIdInfo = {
      fieldId = 20,
      dataType = 1,
      data = nil
    }
  else
    ret.randomEntityConfigIdInfo = {
      fieldId = 20,
      dataType = 1,
      data = container.randomEntityConfigIdInfo:GetContainerElem()
    }
  end
  if container.dungeonSceneInfo == nil then
    ret.dungeonSceneInfo = {
      fieldId = 21,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonSceneInfo = {
      fieldId = 21,
      dataType = 1,
      data = container.dungeonSceneInfo:GetContainerElem()
    }
  end
  if container.dungeonVarAll == nil then
    ret.dungeonVarAll = {
      fieldId = 22,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonVarAll = {
      fieldId = 22,
      dataType = 1,
      data = container.dungeonVarAll:GetContainerElem()
    }
  end
  if container.dungeonRaidInfo == nil then
    ret.dungeonRaidInfo = {
      fieldId = 23,
      dataType = 1,
      data = nil
    }
  else
    ret.dungeonRaidInfo = {
      fieldId = 23,
      dataType = 1,
      data = container.dungeonRaidInfo:GetContainerElem()
    }
  end
  ret.errCode = {
    fieldId = 24,
    dataType = 0,
    data = container.errCode
  }
  return ret
end
local new = function()
  local ret = {
    __data__ = {},
    ResetData = resetData,
    MergeData = mergeData,
    GetContainerElem = getContainerElem,
    flowInfo = require("zcontainer.dungeon_flow_info").New(),
    title = require("zcontainer.dungeon_title").New(),
    target = require("zcontainer.dungeon_target").New(),
    damage = require("zcontainer.dungeon_damage").New(),
    vote = require("zcontainer.dungeon_vote").New(),
    settlement = require("zcontainer.dungeon_settlement").New(),
    DungeonPioneer = require("zcontainer.dungeon_pioneer").New(),
    planetRoomInfo = require("zcontainer.dungeon_planet_memory_room").New(),
    dungeonVar = require("zcontainer.dungeon_var").New(),
    dungeonRank = require("zcontainer.dungeon_rank_list").New(),
    dungeonAffixData = require("zcontainer.dungeon_affix_data").New(),
    dungeonEvent = require("zcontainer.dungeon_event").New(),
    dungeonScore = require("zcontainer.dungeon_score").New(),
    timerInfo = require("zcontainer.dungeon_timer_info").New(),
    heroKey = require("zcontainer.dungeon_hero_key_info").New(),
    dungeonUnionInfo = require("zcontainer.dungeon_union_info").New(),
    dungeonPlayerList = require("zcontainer.dungeon_player_list").New(),
    reviveInfo = require("zcontainer.dungeon_revive_info").New(),
    randomEntityConfigIdInfo = require("zcontainer.dungeon_random_entity_config_id_info").New(),
    dungeonSceneInfo = require("zcontainer.dungeon_scene_info").New(),
    dungeonVarAll = require("zcontainer.dungeon_var_all").New(),
    dungeonRaidInfo = require("zcontainer.dungeon_raid_info").New()
  }
  ret.Watcher = require("zcontainer.container_watcher").new(ret)
  setForbidenMt(ret)
  return ret
end
return {New = new}
