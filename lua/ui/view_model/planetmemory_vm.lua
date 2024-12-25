local refreshRedpointByAwardTag = false
local openPlanememoryFailureView = function()
  if Z.UIMgr:IsActive("planetmemory_battle_failure") then
    return
  end
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("planetmemory_battle_failure")
end
local closePlanememoryFailureView = function()
  Z.UIMgr:CloseView("planetmemory_battle_failure")
end
local openView = function()
  if Z.UIMgr:IsActive("planetmemory_main") then
    return
  end
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_Dmj, "planetmemory_main", function()
        Z.UIMgr:OpenView("planetmemory_main")
      end, Z.ConstValue.UnrealSceneConfigPaths.Planetmemory)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local isOpenePlanememoryView = function()
  local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
  if planetmemoryData:GetPlanetMemoryIsContinue() then
    local args = {
      EndCallback = function()
        Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_Dmj, "planetmemory_main", function()
          Z.UIMgr:OpenView("planetmemory_main")
        end, Z.ConstValue.UnrealSceneConfigPaths.Planetmemory)
      end
    }
    Z.UIMgr:FadeIn(args)
  end
end
local openMonsterTips = function(monsterData, gs, trans)
  local monsterTipsData = {}
  for _, monsterId in pairs(monsterData) do
    local data = {}
    data.monsterId = monsterId
    local monsterCfgData = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
    if monsterCfgData then
      data.monsterName = monsterCfgData.Name
    end
    local modelCfg = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterCfgData.ModelID)
    if modelCfg then
      data.monsterImgPath = modelCfg.Image
    end
    local param = {
      val = tostring(gs)
    }
    data.monsterGs = Lang("GSEqual", param)
    table.insert(monsterTipsData, data)
  end
  local viewData = {
    rect = trans,
    monsterDataArray = monsterTipsData,
    isRightFirst = false
  }
  Z.UIMgr:OpenView("tips_monsters", viewData)
end
local closeMonsterTips = function()
  Z.UIMgr:CloseView("tips_monsters")
end
local dispatchTipsChangeEvent = function(state)
  local showEventData = {
    type = E.PlanetMemoryTipsType.Monster,
    state = state
  }
  Z.EventMgr:Dispatch(Z.ConstValue.PlanetMemory.TipsChange, showEventData)
end
local isSpecialCopy = function(dungeonId)
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not cfg then
    return false
  end
  for _, value in pairs(cfg.Condition) do
    if value[1] == E.DungeonPrecondition.CondItem then
      local itemIdId = value[2]
      local itemIdNum = value[3]
      return true, itemIdId, itemIdNum
    end
  end
  return false
end
local isCanGoGo = function(roomId)
  local passRoom = Z.ContainerMgr.CharSerialize.planetMemory.passRoom
  local gogoList = {}
  for _, value in pairs(passRoom) do
    if roomId == value then
      return false
    end
    local unlockRoomData = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(value)
    if unlockRoomData and next(unlockRoomData.UnlockRoomId) then
      local unlockRoomIds = unlockRoomData.UnlockRoomId
      if unlockRoomIds and next(unlockRoomIds) then
        for _, unlockRoomId in pairs(unlockRoomIds) do
          gogoList[unlockRoomId] = unlockRoomId
        end
      end
    end
  end
  for _, value in pairs(gogoList) do
    if value == roomId then
      return true
    end
  end
  return false
end
local checkIsPassRoom = function(roomId)
  local passRoom = Z.ContainerMgr.CharSerialize.planetMemory.passRoom
  if not passRoom or not next(passRoom) then
    return false
  end
  for k, v in pairs(passRoom) do
    if roomId == v then
      return true
    end
  end
  return false
end
local getUnlockTime = function(roomId)
  local planetmemoryCfg = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(roomId)
  if not planetmemoryCfg then
    return
  end
  local unLockTimeCfg = planetmemoryCfg.UnlockTime
  if not unLockTimeCfg or not next(unLockTimeCfg) then
    return
  end
  local unLockTimeOffset = unLockTimeCfg
  local seasonId = Z.PlanetMemorySeasonConfig.SeasonId
  local seasonGlobalCfg = Z.TableMgr.GetTable("SeasonGlobalTableMgr").GetRow(seasonId)
  if not seasonGlobalCfg then
    return
  end
  local curServerTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  local seasonTimeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(seasonGlobalCfg.SeasonTimeId)
  local beginTime = Z.TimeTools.TimerTabaleTimeParse(seasonTimeCfg.starttime)
  local unLockTime = beginTime
  if unLockTimeOffset and seasonGlobalCfg.SeasonId == unLockTimeOffset[1] then
    unLockTime = beginTime + unLockTimeOffset[2] * 3600
  end
  return unLockTime, curServerTime
end
local checkIsUnlockByTime = function(roomId)
  local planetmemoryCfg = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(roomId)
  if not planetmemoryCfg then
    return
  end
  local unLockTimeCfg = planetmemoryCfg.UnlockTime
  if unLockTimeCfg and next(unLockTimeCfg) and unLockTimeCfg[2] == 0 then
    return true
  end
  local unLockTime, curServerTime = getUnlockTime(roomId)
  if not unLockTime or not curServerTime then
    return
  end
  local isUnlock = unLockTime < curServerTime
  return isUnlock
end
local initPlanetMenoryState = function()
  local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
  planetmemoryData:ClearPlanetMemoryState()
  planetmemoryData:ClearPlanetMemoryFogUnlockedState()
  local allItems = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetDatas()
  if not allItems or #allItems < 1 then
    return
  end
  local PlanetmemoryState = E.PlanetmemoryState.Close
  local planetmemoryFogUnlockedState = E.PlanetmemoryFogState.NotYetUnlocked
  for k, v in pairs(allItems) do
    if checkIsPassRoom(v.RoomId) then
      PlanetmemoryState = E.PlanetmemoryState.Pass
    elseif isCanGoGo(v.RoomId) and checkIsUnlockByTime(v.RoomId) then
      PlanetmemoryState = E.PlanetmemoryState.Open
    elseif v.RoomId == 1 then
      PlanetmemoryState = E.PlanetmemoryState.Open
    else
      PlanetmemoryState = E.PlanetmemoryState.Close
    end
    planetmemoryFogUnlockedState = checkIsUnlockByTime(v.RoomId) and E.PlanetmemoryFogState.Unlocked or E.PlanetmemoryFogState.NotYetUnlocked
    planetmemoryData:AddPlanetMemoryFogUnlockedState(v.RoomId, planetmemoryFogUnlockedState)
    planetmemoryData:AddPlanetMenoryState(v.RoomId, PlanetmemoryState)
  end
end
local getPlanetItemModelId = function(roomId, RoomType)
  local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
  local planetmemoryModel = {}
  if checkIsPassRoom(roomId) then
    planetmemoryModel = Z.PlanetMemorySeasonConfig.FinishedPointModel
  elseif isCanGoGo(roomId) then
    planetmemoryModel = Z.PlanetMemorySeasonConfig.UnlockPointModel
  else
    planetmemoryModel = Z.PlanetMemorySeasonConfig.LockedPointModel
  end
  if roomId == 1 and not checkIsPassRoom(roomId) then
    return Z.PlanetMemorySeasonConfig.StartPointModel
  elseif roomId == planetmemoryData:GetLastFinishedPlanetMemoryID() then
    return Z.PlanetMemorySeasonConfig.CurrentPointModel
  else
    local modelId = planetmemoryModel[RoomType][2]
    return modelId
  end
end
local isPlanetmemory = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return false
  end
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if not planetRoomInfo then
    return false
  end
  local roomId = planetRoomInfo.roomId
  if roomId and roomId ~= 0 then
    return true
  else
    return false
  end
end
local getCurPlanetmemoryInfo = function()
  local roomId = 1
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo and planetRoomInfo.roomId then
    roomId = planetRoomInfo.roomId
  end
  local nplanetMemroyTableData = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(roomId)
  return nplanetMemroyTableData
end
local getLastFinishedPlanetmemoryInfo = function()
  local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
  local roomId = planetmemoryData:GetLastFinishedPlanetMemoryID()
  local planetMemroyTableData = Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(roomId)
  return planetMemroyTableData
end
local getPlanetMemoryTargetState = function(targetId)
  local targetInfo = Z.ContainerMgr.CharSerialize.planetMemoryTarget.targetInfo[targetId]
  if not targetInfo or not next(targetInfo) then
    return E.DrawState.NoDraw
  end
  local awardState = targetInfo.awardState
  return awardState
end
local asyncEnterPlanetMemory = function(roomId, token)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.EnterPlanetMemoryRoom(roomId, token)
  if ret == 0 then
  else
  end
end
local asyncRestartPlanetMemory = function(token)
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if not planetRoomInfo then
    return nil
  end
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.EnterPlanetMemoryRoom(planetRoomInfo.roomId, token)
  if ret == 0 then
  else
  end
end
local getRoomInfoByRoomId = function(roomId)
  return Z.TableMgr.GetTable("PlanetMemoryTableMgr").GetRow(roomId)
end
local getPlanetMemoryUnlockTime = function(roomId)
  local unLockTime, curServerTime = getUnlockTime(roomId)
  if not unLockTime or not curServerTime then
    return
  end
  local offsetTime
  local param = {}
  if curServerTime < unLockTime then
    if Z.TimeTools.CheckIsSameDay(curServerTime, unLockTime) == false then
      param.val = math.ceil((unLockTime - curServerTime) / 86400)
      return Lang("UnlockAfterNumberDay", param)
    else
      param.val = math.ceil((unLockTime - curServerTime) / 3600)
      return Lang("UnlockAfterNumberHour", param)
    end
  end
  return offsetTime
end
local getPlanetMemoryNodeAssetPath = function(modelId)
  if not modelId then
    return
  end
  local modelSpecialTable = Z.TableMgr.GetTable("ModelSpecialTableMgr").GetRow(modelId)
  if not modelSpecialTable or string.len(modelSpecialTable.Skeleton) == 0 then
    return
  end
  return modelSpecialTable.Skeleton
end
local getModelConfigById = function(modelId)
  if not modelId then
    return
  end
  local modelCfg = Z.TableMgr.GetTable("ModelTableMgr").GetRow(modelId)
  if not modelCfg then
    return
  end
  return modelCfg
end
local setRedpointByAward = function(tag)
  refreshRedpointByAwardTag = tag
end
local onPlanetMemoryDataChanged = function()
  local award = Z.PlanetMemorySeasonConfig.SeasonAward
  local datas = Z.ContainerMgr.CharSerialize.planetMemoryTarget.targetInfo
  local count = 0
  for _, value in pairs(award) do
    local data = datas[value[2]]
    if data and next(data) and data.awardState == E.DrawState.CanDraw then
      count = count + 1
    end
  end
  if refreshRedpointByAwardTag then
    setRedpointByAward(false)
  else
  end
end
local initRedpoint = function()
  onPlanetMemoryDataChanged()
  Z.ContainerMgr.CharSerialize.planetMemoryTarget.Watcher:RegWatcher(onPlanetMemoryDataChanged)
end
local ret = {
  GetPlanetItemModelId = getPlanetItemModelId,
  OpenView = openView,
  IsPlanetmemory = isPlanetmemory,
  GetCurPlanetmemoryInfo = getCurPlanetmemoryInfo,
  AsyncEnterPlanetMemory = asyncEnterPlanetMemory,
  CheckIsPassRoom = checkIsPassRoom,
  GetPlanetMemoryTargetState = getPlanetMemoryTargetState,
  AsyncRestartPlanetMemory = asyncRestartPlanetMemory,
  IsSpecialCopy = isSpecialCopy,
  OpenPlanememoryFailureView = openPlanememoryFailureView,
  ClosePlanememoryFailureView = closePlanememoryFailureView,
  IsOpenePlanememoryView = isOpenePlanememoryView,
  GetPlanetMemoryUnlockTime = getPlanetMemoryUnlockTime,
  OpenMonsterTips = openMonsterTips,
  CloseMonsterTips = closeMonsterTips,
  GetRoomInfoByRoomId = getRoomInfoByRoomId,
  GetPlanetMemoryNodeAssetPath = getPlanetMemoryNodeAssetPath,
  InitPlanetMenoryState = initPlanetMenoryState,
  GetModelConfigById = getModelConfigById,
  GetLastFinishedPlanetmemoryInfo = getLastFinishedPlanetmemoryInfo,
  SetRedpointByAward = setRedpointByAward,
  InitRedpoint = initRedpoint
}
return ret
