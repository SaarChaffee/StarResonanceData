local PivotVM = {}

function PivotVM.OpenPivotRewardView(pivotId, isMap, uuid)
  local viewData = {}
  viewData.pivotId = pivotId
  viewData.isMap = isMap
  viewData.uuid = uuid
  Z.UIMgr:OpenView("pivot_reward_empty", viewData)
end

function PivotVM.ClosePivotRewardView()
  Z.UIMgr:CloseView("pivot_reward_empty")
end

function PivotVM.OpenPivotProgressView(sceneId)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId, function()
    Z.EventMgr:Dispatch(Z.ConstValue.MapOpenSubView, E.MapSubViewType.PivotProgress)
  end)
end

function PivotVM.CheckPivotUnlock(pivotId)
  return Z.ContainerMgr.CharSerialize.pivot.pivots[pivotId] ~= nil
end

function PivotVM.GetPivotAllPort(pivotId)
  local ports = {}
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId == nil then
    logError("\229\156\186\230\153\175id\228\184\186\231\169\186")
    return
  end
  local sceneObjectTableMgr = Z.TableMgr.GetTable("SceneObjectTableMgr")
  local settingOffTableMgr = Z.TableMgr.GetTable("SettingOffTableMgr")
  local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  for id, value in pairs(sceneObjectEntityGlobalDataDict) do
    local sceneTbl = sceneObjectTableMgr.GetRow(value.Id, true)
    if sceneTbl and sceneTbl.SceneObjType == E.SceneObjType.PivotPort then
      local protTbl = settingOffTableMgr.GetRow(value.Id)
      if protTbl and protTbl.PivotId == pivotId then
        table.insert(ports, value)
      end
    end
  end
  return ports
end

function PivotVM.GetPivotPortUnlockCount(pivotId)
  local pivotInfo = Z.ContainerMgr.CharSerialize.pivot.pivots[pivotId]
  if pivotInfo == nil or pivotInfo.breakPoint == nil then
    return 0
  end
  return #pivotInfo.breakPoint
end

function PivotVM.GetScenePivotPortCountInfo(sceneId)
  local totalCount = 0
  local unlockCount = 0
  local pivotTbl = Z.TableMgr.GetTable("PivotTableMgr").GetDatas()
  for index, value in pairs(pivotTbl) do
    if value.MapID == sceneId then
      local pivotCount = #PivotVM.GetPivotAllPort(value.Id)
      local unlockPivotCount = PivotVM.GetPivotPortUnlockCount(value.Id)
      totalCount = totalCount + pivotCount
      unlockCount = unlockCount + unlockPivotCount
    end
  end
  return totalCount, unlockCount
end

function PivotVM.GetPivotRewardState(pivotId)
  local pivotInfo = Z.ContainerMgr.CharSerialize.pivot.pivots[pivotId]
  local data = {
    false,
    false,
    false
  }
  if pivotInfo == nil or pivotInfo.rewardStage == nil then
    return data
  end
  for index, value in ipairs(pivotInfo.rewardStage) do
    data[value + 1] = true
  end
  return data
end

function PivotVM.GetScenePivotRewardState(sceneId)
  local pivotInfo = Z.ContainerMgr.CharSerialize.pivot.mapPivots[sceneId]
  local resultDict = {}
  if pivotInfo and pivotInfo.rewardStage then
    for index, value in ipairs(pivotInfo.rewardStage) do
      resultDict[value + 1] = true
    end
  end
  return resultDict
end

function PivotVM.AddPortGuideData(id, distance)
  local pivotData = Z.DataMgr.Get("pivot_data")
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId == nil then
    logError("\229\156\186\230\153\175id\228\184\186\231\169\186")
    return
  end
  local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  local settingOffTableMgr = Z.TableMgr.GetTable("SettingOffTableMgr")
  local tblId = sceneId * Z.ConstValue.GlobalLevelIdOffset + id
  local row = sceneObjectEntityGlobalDataDict[tblId]
  if row then
    local portRow = settingOffTableMgr.GetRow(row.Id)
    if portRow ~= nil and PivotVM.CheckPivotUnlock(portRow.PivotId) then
      pivotData:AddPortGuideData(id, distance)
    end
  end
end

function PivotVM.ClearTracePort()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.MapFlag, nil)
end

function PivotVM.UpdateTracePort()
  local pivotData = Z.DataMgr.Get("pivot_data")
  local exist, uid = pivotData:GetPortGuideData()
  if exist then
    if uid ~= -1 then
      local sceneId = Z.StageMgr.GetCurrentSceneId()
      if sceneId == nil then
        logError("\229\156\186\230\153\175id\228\184\186\231\169\186")
        return
      end
      local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
      local tblId = sceneId * Z.ConstValue.GlobalLevelIdOffset + uid
      local row = sceneObjectEntityGlobalDataDict[tblId]
      if row then
        local pos = {
          x = row.Position[1],
          y = row.Position[2],
          z = row.Position[3]
        }
        local info = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.MapFlag, sceneId, uid, Z.GoalPosType.Point, Vector3.New(pos.x, pos.y, pos.z))
        local guideVM = Z.VMMgr.GetVM("goal_guide")
        guideVM.SetGuideGoals(E.GoalGuideSource.MapFlag, {info})
      end
    end
  else
    PivotVM.ClearTracePort()
  end
end

function PivotVM.AsyncGetPivotReward(pivotId, index, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.PivotStateGetReward(pivotId, index, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GetPivotReward)
  return true
end

function PivotVM.AsyncGetTotalPivotReward(sceneId, stage, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ScenePivotStageGetReward(sceneId, stage, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.GetPivotReward)
  return true
end

function PivotVM.AsyncPivotResonance(uuid, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ActivatePivot(uuid, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  else
    local uuid = tonumber(uuid)
    local mapVm = Z.VMMgr.GetVM("map")
    if mapVm.CheckIsTraceEntityBySrc(E.GoalGuideSource.MapFlag, Z.StageMgr.GetCurrentSceneId(), uuid) then
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      guideVM.SetGuideGoals(E.GoalGuideSource.MapFlag, nil)
    end
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.GoToFunc(E.FunctionID.Map)
    return true
  end
end

function PivotVM.PivotInteraction(uuid)
  local entity = Z.EntityMgr:GetEntity(uuid)
  if entity == nil then
    return
  end
  local configId = entity:GetLuaAttr(Z.PbAttrEnum("AttrId")).Value
  if PivotVM.CheckPivotUnlock(configId) then
    PivotVM.OpenPivotRewardView(configId, false, uuid)
  end
end

function PivotVM.GetCurPivotState(pivotId)
  local pivotTableRow = Z.TableMgr.GetTable("PivotTableMgr").GetRow(pivotId)
  if pivotTableRow == nil then
    return 0
  end
  local curCount = PivotVM.GetPivotPortUnlockCount(pivotId)
  for i, targetCount in ipairs(pivotTableRow.SettingOffNum) do
    if targetCount > curCount then
      return i - 1
    end
  end
  return #pivotTableRow.SettingOffNum
end

function PivotVM.GetCurPivotAwardId(pivotId, state)
  local pivotTableRow = Z.TableMgr.GetTable("PivotTableMgr").GetRow(pivotId)
  if pivotTableRow == nil then
    return
  end
  return pivotTableRow.CirculateAward[state]
end

function PivotVM.IsCanGetPivotAward(pivotId, targetState)
  local awardStateDict = PivotVM.GetPivotRewardState(pivotId)
  local curState = PivotVM.GetCurPivotState(pivotId)
  return targetState <= curState and not awardStateDict[targetState]
end

function PivotVM.FindPivotUidInSceneTable(pivotId, curSceneId)
  local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  local sceneObjectTableMgr = Z.TableMgr.GetTable("SceneObjectTableMgr")
  for id, row in pairs(sceneObjectEntityGlobalDataDict) do
    local sceneId = math.floor(id / Z.ConstValue.GlobalLevelIdOffset)
    if sceneId == curSceneId then
      local sceneObjId = row.Id
      if sceneObjId == pivotId then
        local sceneObjData = sceneObjectTableMgr.GetRow(sceneObjId)
        if sceneObjData and sceneObjData.SceneObjType == E.SceneObjType.Pivot then
          return id % Z.ConstValue.GlobalLevelIdOffset
        end
      end
    end
  end
end

function PivotVM.GetTransferIdByUid(uid, sceneId)
  local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  local globalUid = sceneId * Z.ConstValue.GlobalLevelIdOffset + uid
  local globalRow = sceneObjectEntityGlobalDataDict[globalUid]
  if globalRow then
    return globalRow.Id
  end
end

function PivotVM.GetPivotRedId(sceneId, pivotId)
  return string.zconcat(E.RedType.PivotProgress, "_", sceneId, "_", pivotId)
end

function PivotVM.GetProgressRedId(sceneId, awardId)
  return string.zconcat(E.RedType.PivotProgress, "_", sceneId, "_", awardId)
end

function PivotVM.CheckPivotRedDot()
  local pivotTableMgr = Z.TableMgr.GetTable("PivotTableMgr")
  local pivotTableDict = pivotTableMgr.GetDatas()
  for id, config in pairs(pivotTableDict) do
    local nodeId = PivotVM.GetPivotRedId(config.MapID, id)
    local isCanGetReward = false
    for i = 1, #config.SettingOffNum do
      if PivotVM.IsCanGetPivotAward(id, i) then
        isCanGetReward = true
        break
      end
    end
    Z.RedPointMgr.RefreshServerNodeCount(nodeId, isCanGetReward and 1 or 0)
  end
end

function PivotVM.CheckPointRedDot()
  local pivotAwardTableMgr = Z.TableMgr.GetTable("PivotAwardTableMgr")
  for sceneId, data in pairs(pivotAwardTableMgr.GetDatas()) do
    local totalCount, unlockCount = PivotVM.GetScenePivotPortCountInfo(sceneId)
    local curProgress = unlockCount / totalCount
    local rewardStateDict = PivotVM.GetScenePivotRewardState(sceneId)
    local rewardCount = #data.AwardId
    for i = 1, rewardCount do
      local progressNum = math.floor(100 / rewardCount * i)
      local progress = progressNum * 0.01
      local awardId = data.AwardId[i]
      local nodeId = PivotVM.GetProgressRedId(sceneId, awardId)
      if curProgress >= progress and not rewardStateDict[i] then
        Z.RedPointMgr.RefreshServerNodeCount(nodeId, 1)
      else
        Z.RedPointMgr.RefreshServerNodeCount(nodeId, 0)
      end
    end
  end
end

local mapFuncShowSceneDict

function PivotVM.GetPivotMapFuncShowSceneDict()
  if mapFuncShowSceneDict == nil then
    mapFuncShowSceneDict = {}
    local MapActivityTableDatas = Z.TableMgr.GetTable("MapActivityTableMgr").GetDatas()
    for _, config in pairs(MapActivityTableDatas) do
      if config.FunctionId == E.FunctionID.PivotManual then
        for i, sceneId in ipairs(config.Scene) do
          mapFuncShowSceneDict[sceneId] = true
        end
      end
    end
  end
  return mapFuncShowSceneDict
end

function PivotVM.GetScenePivotAreaState(sceneId, ignoreUnlocking)
  local lockList = {}
  local unlockList = {}
  local unlockingList = {}
  local pivotData = Z.DataMgr.Get("pivot_data")
  local curUnlockPivotId = pivotData:GetUnlockPivotId()
  local pivotTableDict = Z.TableMgr.GetTable("PivotTableMgr").GetDatas()
  for id, config in pairs(pivotTableDict) do
    if config.MapID == sceneId then
      local isUnlock = PivotVM.CheckPivotUnlock(id)
      if isUnlock then
        if not ignoreUnlocking and curUnlockPivotId and curUnlockPivotId == id then
          table.insert(unlockingList, config)
        else
          table.insert(unlockList, config)
        end
      else
        table.insert(lockList, config)
      end
    end
  end
  return lockList, unlockList, unlockingList
end

function PivotVM.GetPivotWorldPos(sceneId, pivotId)
  local sceneObjectEntityGlobalDataDict = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  for id, v in pairs(sceneObjectEntityGlobalDataDict) do
    if Z.TableMgr.GetRow("PivotTableMgr", v.Id, true) then
      local curSceneId = math.floor(id / Z.ConstValue.GlobalLevelIdOffset)
      if curSceneId == sceneId and v.Id == pivotId then
        return v.Position
      end
    end
  end
end

function PivotVM.IsTransferAreaUnlock(transferId)
  local transferTableMgr = Z.TableMgr.GetTable("TransferTableMgr")
  local transferTableRow = transferTableMgr.GetRow(transferId)
  if transferTableRow == nil then
    return false
  end
  if transferTableRow.PivotId == 0 then
    return true
  end
  return PivotVM.CheckPivotUnlock(transferTableRow.PivotId)
end

return PivotVM
