local openMapClockMapView = function(mapId)
  mapId = 7
  local mapBookConfig = Z.TableMgr.GetTable("MapBookTableMgr").GetDatas()
  for index, value in pairs(mapBookConfig) do
    if value.SceneId == mapId then
      local viewData = {}
      viewData.bookId = value.Id
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_Spot, "map_clock_window", function()
        Z.UIMgr:OpenView("map_clock_window", viewData)
      end, Z.ConstValue.UnrealSceneConfigPaths.Mapbook)
      return
    end
  end
  Z.TipsVM.ShowTipsLang("map_book_not_open")
end
local closeMapClockMapView = function()
  Z.UIMgr:CloseView("map_clock_window")
end
local checkTaskFinish = function(mapId, stickerId, taskId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return false
  end
  local stickerInfo = mapInfo.mapStickerMap[stickerId]
  if stickerInfo == nil then
    return false
  end
  for index, value in ipairs(stickerInfo.finishMap) do
    if value == taskId then
      return true
    end
  end
  return false
end
local getTaskFinishTargetNum = function(mapId, stickerId, taskId, targetId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return 0
  end
  local stickerInfo = mapInfo.mapStickerMap[stickerId]
  if stickerInfo == nil then
    return 0
  end
  for index, value in ipairs(stickerInfo.finishMap) do
    if value == taskId then
      return -1
    end
  end
  for index, value in pairs(stickerInfo.stickerMap) do
    if value.taskId == taskId then
      return value.targetNum[targetId]
    end
  end
  return 0
end
local checkStickAllTaskFinish = function(mapId, stickerId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return false
  end
  local stickerInfo = mapInfo.mapStickerMap[stickerId]
  if stickerInfo == nil then
    return false
  end
  local mapStickerTbl = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(stickerId)
  if mapStickerTbl then
    for _, taskId in ipairs(mapStickerTbl.TaskId) do
      if not table.zcontains(stickerInfo.finishMap, taskId) then
        return false
      end
    end
  end
  return true
end
local checkStickUnlock = function(mapId, stickerId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return false
  end
  local stickerInfo = mapInfo.mapStickerMap[stickerId]
  if stickerInfo == nil then
    return false
  end
  return stickerInfo.awardFlag == 1
end
local checkMapAllStickerUnlock = function(mapId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return false
  end
  for index, value in pairs(mapInfo.mapStickerMap) do
    if value.awardFlag == 0 then
      return false
    end
  end
  return true
end
local checkGetMapRewawrd = function(mapId)
  local mapInfo = Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap[mapId]
  if mapInfo == nil then
    return false
  end
  return mapInfo.awardFlag == 1
end
local refreshReddotInfo = function()
  local mapTable = Z.TableMgr.GetTable("MapBookTableMgr").GetDatas()
  local count = 0
  for _, mapData in pairs(mapTable) do
    for __, stickerId in ipairs(mapData.StickerId) do
      if checkStickAllTaskFinish(mapData.Id, stickerId) and not checkStickUnlock(mapData.Id, stickerId) then
        count = count + 1
      end
    end
  end
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.ScenicPhoto, count)
end
local getPhotoTask = function()
  local ret = {}
  local mapStickerTaskTbl = Z.TableMgr.GetTable("MapStickerTaskTableMgr")
  local mapStickerTartgetTbl = Z.TableMgr.GetTable("MapStickerTargetTableMgr")
  for _, mapBookInfo in pairs(Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap) do
    for __, mapStickerInfo in pairs(mapBookInfo.mapStickerMap) do
      for id, taskInfo in pairs(mapStickerInfo.stickerMap) do
        local config = mapStickerTaskTbl.GetRow(id)
        if config ~= nil then
          for ___, value in ipairs(config.TargetId) do
            local targetConfig = mapStickerTartgetTbl.GetRow(value)
            if targetConfig and targetConfig.TargetType == E.GoalType.TakePhoto and targetConfig.SceneId == Z.StageMgr.GetCurrentSceneId() then
              table.insert(ret, tonumber(targetConfig.Param[1]))
            end
          end
        end
      end
    end
  end
  return ret
end
local onQuestChange = function(container, dirtyKeys)
  if dirtyKeys.finishMap then
    for questId, value in pairs(dirtyKeys.stickerMap) do
      local taskTbl = Z.TableMgr.GetTable("MapStickerTaskTableMgr").GetRow(questId)
      if taskTbl == nil then
        break
      end
      for ___, targetId in ipairs(taskTbl.TargetId) do
        local targetConfig = Z.TableMgr.GetTable("MapStickerTargetTableMgr").GetRow(targetId)
        if targetConfig == nil then
          break
        end
        if targetConfig.TargetType == E.GoalType.TakePhoto or targetConfig.TargetType == E.GoalType.AutoPlayFlow then
          local param = {
            str = taskTbl.Title
          }
          Z.TipsVM.ShowTips(123001, param)
        end
      end
    end
    refreshReddotInfo()
  end
  if dirtyKeys.awardFlag then
    refreshReddotInfo()
  end
end
local watcherQuestChange = function()
  for _, mapBookInfo in pairs(Z.ContainerMgr.CharSerialize.mapBookList.mapBookMap) do
    for __, mapStickerInfo in pairs(mapBookInfo.mapStickerMap) do
      mapStickerInfo.Watcher:RegWatcher(onQuestChange)
    end
  end
end
local onSyncAllContainerData = function()
  watcherQuestChange()
  refreshReddotInfo()
end
local asyncGetMapReward = function(mapId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.GetBookAward(mapId, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.MapBook.GetMapBookReward)
  local config = Z.TableMgr.GetTable("MapBookTableMgr").GetRow(mapId)
  if config ~= nil then
    local rewardIds = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(config.AwardId)
    local data = {}
    for _, value in ipairs(rewardIds) do
      data[#data + 1] = {
        configId = value.awardId,
        count = value.awardNum
      }
    end
    Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
  end
  return true
end
local showAward = function(stickerId)
  local stickerConfig = Z.TableMgr.GetTable("MapStickerTableMgr").GetRow(stickerId)
  if not stickerConfig then
    return
  end
  local rewardIds = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(stickerConfig.AwardId)
  local data = {}
  for _, value in ipairs(rewardIds) do
    data[#data + 1] = {
      configId = value.awardId,
      count = value.awardNum
    }
  end
  Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
end
local asyncGetStickerReward = function(mapId, stickerId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.GetStickerAward(mapId, stickerId, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.MapBook.GetStickerReward)
  return true
end
local ret = {
  OpenMapClockMapView = openMapClockMapView,
  CloseMapClockMapView = closeMapClockMapView,
  AsyncGetMapReward = asyncGetMapReward,
  AsyncGetStickerReward = asyncGetStickerReward,
  CheckTaskFinish = checkTaskFinish,
  CheckStickAllTaskFinish = checkStickAllTaskFinish,
  CheckStickUnlock = checkStickUnlock,
  GetTaskFinishTargetNum = getTaskFinishTargetNum,
  CheckMapAllStickerUnlock = checkMapAllStickerUnlock,
  CheckGetMapRewawrd = checkGetMapRewawrd,
  RefreshReddotInfo = refreshReddotInfo,
  GetPhotoTask = getPhotoTask,
  ShowAward = showAward,
  OnSyncAllContainerData = onSyncAllContainerData
}
return ret
