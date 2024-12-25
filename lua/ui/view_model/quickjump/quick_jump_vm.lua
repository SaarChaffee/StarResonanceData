local quickJumpVm = {}
local goUnionTargetType = {
  [0] = Z.PbEnum("UnionEnterScene", "UnionEnterSceneNormal"),
  [1] = Z.PbEnum("UnionEnterScene", "UnionEnterSceneDance"),
  [2] = Z.PbEnum("UnionEnterScene", "UnionEnterSceneHunt")
}

function quickJumpVm.DoJumpByConfigParam(jumpType, jumpParam, extraParams)
  if jumpType == nil or jumpType == 0 or jumpParam == nil then
    return
  end
  local param = {extraParams = extraParams}
  if extraParams and extraParams.goalGuideSource then
    param.goalGuideSource = extraParams.goalGuideSource
  else
    param.goalGuideSource = E.GoalGuideSource.MapFlag
  end
  if jumpType == E.QuickJumpType.TraceSceneTarget and #jumpParam == 3 then
    param.sceneId = jumpParam[1]
    param.trackType = jumpParam[2]
    param.entityId = jumpParam[3]
  elseif jumpType == E.QuickJumpType.Function then
    param.funcId = jumpParam[1]
    param.otherParam = {}
    for i = 2, #jumpParam do
      table.insert(param.otherParam, jumpParam[i])
    end
  elseif jumpType == E.QuickJumpType.Message then
    param.messageId = jumpParam[1]
  elseif jumpType == E.QuickJumpType.TraceNearestTarget then
  elseif jumpType == E.QuickJumpType.GoUnionTarget then
    param.jumpUnionType = jumpParam[1]
  end
  quickJumpVm.Jump(jumpType, param)
end

function quickJumpVm.Jump(jumpType, jumpParam)
  if jumpType == nil then
    logError("jumpType is nil")
    return
  end
  local deadVM = Z.VMMgr.GetVM("dead")
  if deadVM.CheckPlayerIsDead() then
    Z.TipsVM.ShowTipsLang(100126)
    return
  end
  local func = quickJumpVm.jumpFuncs_[jumpType]
  if func ~= nil and type(func) == "function" then
    func(jumpParam)
  end
end

function quickJumpVm.showTips(jumpParam)
  if jumpParam == nil then
    logError("jumpParam is nil")
    return
  end
  Z.TipsVM.ShowTips(jumpParam.messageId, nil)
end

function quickJumpVm.goUnionTarget(jumpParam)
  if jumpParam == nil then
    logError("jumpParam is nil")
    return
  end
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  local unionFuncId = 500100
  if not funcVM.FuncIsOn(unionFuncId) then
    return
  end
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local hasGuild = unionId ~= 0
  if not hasGuild then
    Z.TipsVM.ShowTips(1000595)
    return
  end
  local isUnionSceneUnlock = unionVM:GetUnionSceneIsUnlock()
  if not isUnionSceneUnlock then
    Z.TipsVM.ShowTips(1000594)
    return
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local configData_ = Z.UnionActivityConfig.HuntDungeonCount
  for _, value in ipairs(configData_) do
    local sceneId = value[1]
    if sceneId == curSceneId then
      Z.TipsVM.ShowTips(100124)
      return
    end
  end
  local sceneTable = Z.TableMgr.GetTable("SceneTableMgr").GetRow(curSceneId)
  if sceneTable.SceneSubType == E.SceneSubType.Union then
    Z.TipsVM.ShowTips(1000555)
    return
  end
  local vRequest = {}
  vRequest.unionId = unionId
  vRequest.enterType = goUnionTargetType[jumpParam.jumpUnionType]
  local worldProxy_ = require("zproxy.world_proxy")
  Z.CoroUtil.create_coro_xpcall(function()
    local cancelSource = Z.CancelSource.Rent()
    worldProxy_.EnterUnionScene(vRequest, cancelSource:CreateToken())
    cancelSource:Recycle()
  end)()
end

function quickJumpVm.traceTarget(jumpParam)
  if jumpParam == nil then
    logError("jumpParam is nil")
    return
  end
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local targetSceneId = jumpParam.sceneId
  local mapInfoTableRow = Z.TableMgr.GetRow("MapInfoTableMgr", targetSceneId)
  if mapInfoTableRow == nil then
    return
  end
  local sceneTableRow = Z.TableMgr.GetRow("SceneTableMgr", targetSceneId)
  if sceneTableRow == nil then
    return
  end
  if targetSceneId ~= curSceneId and not mapInfoTableRow.IsExportGlobal then
    quickJumpVm.showTraceErrorMsg(sceneTableRow)
    return
  end
  local trackType = jumpParam.trackType
  local trackFunc = quickJumpVm.trackFuncs_[trackType]
  if trackFunc ~= nil and type(trackFunc) == "function" then
    trackFunc(jumpParam)
  end
end

function quickJumpVm.showTraceErrorMsg(sceneTableRow)
  if sceneTableRow.SceneSubType == E.SceneSubType.Union then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    if not gotoFuncVM.CheckFuncCanUse(E.UnionFuncId.Union) then
      return
    end
    local unionVM = Z.VMMgr.GetVM("union")
    if unionVM:GetPlayerUnionId() == 0 then
      Z.TipsVM.ShowTipsLang(1000595)
      gotoFuncVM.GoToFunc(E.UnionFuncId.Union)
    else
      Z.TipsVM.ShowTipsLang(140402)
    end
  else
    Z.TipsVM.ShowTipsLang(140401, {
      val = sceneTableRow.Name
    })
  end
end

function quickJumpVm.functionJump(jumpParam)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local funcId = jumpParam.funcId
  local param
  if type(jumpParam.otherParam) == "table" then
    gotoFuncVM.GoToFunc(funcId, table.unpack(jumpParam.otherParam))
  else
    gotoFuncVM.GoToFunc(funcId, jumpParam.otherParam)
  end
end

function quickJumpVm.traceNearestTarget(jumpParam)
  if jumpParam == nil then
    return
  end
  local targetType = jumpParam.nearTraceTargetType
  local func = quickJumpVm.nearTraceFuncs_[targetType]
  if func ~= nil and type(func) == "function" then
    func(jumpParam)
  end
end

function quickJumpVm.trackNpc(jumpParam)
  quickJumpVm.updateTrackingData(jumpParam.entityId, jumpParam.sceneId, Z.GoalPosType.Npc, jumpParam.goalGuideSource, jumpParam)
end

function quickJumpVm.trackEntityById(jumpParam)
  local sceneId = math.floor(jumpParam.sceneId)
  local trackType = jumpParam.trackType
  local uid = math.floor(jumpParam.entityId)
  local goalType = Z.GoalPosType.IntToEnum(trackType)
  quickJumpVm.updateTrackingData(uid, sceneId, goalType, jumpParam.goalGuideSource, jumpParam)
end

function quickJumpVm.trackNearNpcByFuncId(jumpParam)
  if jumpParam.funcId == nil then
    return
  end
  local npcId = Z.EntityTabManager.GetNpcIdByFunctionId(jumpParam.funcId)
  local sceneId, npcEntityData = Z.EntityTabManager.GetNpcEntityDataByNpcId(npcId)
  local uId = npcEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
  quickJumpVm.updateTrackingData(uId, sceneId, Z.GoalPosType.Npc, jumpParam.goalGuideSource, jumpParam)
end

function quickJumpVm.trackNearZoneByTagId(jumpParam)
  if jumpParam.tagId == nil then
    return
  end
  local sceneId, zoneEntityData = Z.EntityTabManager.GetZoneEntityDataBySceneTagId(jumpParam.tagId)
  local uId = zoneEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
  quickJumpVm.updateTrackingData(uId, sceneId, Z.GoalPosType.Zone, jumpParam.goalGuideSource, jumpParam)
end

function quickJumpVm.trackNearSceneObjByTagId(jumpParam)
  if jumpParam.tagId == nil then
    return
  end
  local sceneId, sceneEntityData = Z.EntityTabManager.GetSceneEntityDataBySceneTagId(jumpParam.tagId)
  local uId = sceneEntityData.UId % Z.ConstValue.GlobalLevelIdOffset
  quickJumpVm.updateTrackingData(uId, sceneId, Z.GoalPosType.SceneObject, jumpParam.goalGuideSource, jumpParam)
end

function quickJumpVm.updateTrackingData(uId, sceneId, goalType, goalGuideSource, jumpParam)
  if uId == nil then
    return
  end
  local mapData = Z.DataMgr.Get("map_data")
  local dynamicName
  local autoTrack = true
  local isShowRedInfo = false
  if jumpParam.extraParams then
    dynamicName = jumpParam.extraParams.DynamicFlagName
    if jumpParam.extraParams.AutoTrack ~= nil then
      autoTrack = jumpParam.extraParams.AutoTrack
    end
    isShowRedInfo = jumpParam.extraParams.isShowRedInfo
  end
  mapData:SaveDynamicTraceParam(goalGuideSource, goalType, uId, {Name = dynamicName})
  local miniMapVM = Z.VMMgr.GetVM("minimap")
  if not miniMapVM.ChecekSceneID(sceneId) then
    return
  end
  local mapVm = Z.VMMgr.GetVM("map")
  if autoTrack then
    mapVm.SetTraceEntity(goalGuideSource, sceneId, uId, goalType, false)
  end
  local globalCfg, flagDataId = mapVm.GetGlobalInfo(sceneId, goalType, uId)
  if globalCfg == nil or flagDataId == nil then
    return
  end
  mapVm.SetAutoSelect(flagDataId)
  mapVm.SetIsShowRedInfo(isShowRedInfo)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  gotoFuncVM.GoToFunc(E.FunctionID.Map, sceneId)
end

quickJumpVm.jumpFuncs_ = {
  [E.QuickJumpType.TraceSceneTarget] = quickJumpVm.traceTarget,
  [E.QuickJumpType.Function] = quickJumpVm.functionJump,
  [E.QuickJumpType.TraceNearestTarget] = quickJumpVm.traceNearestTarget,
  [E.QuickJumpType.Message] = quickJumpVm.showTips,
  [E.QuickJumpType.GoUnionTarget] = quickJumpVm.goUnionTarget
}
quickJumpVm.trackFuncs_ = {
  [E.TrackType.Point] = quickJumpVm.trackEntityById,
  [E.TrackType.Npc] = quickJumpVm.trackNpc,
  [E.TrackType.Monster] = quickJumpVm.trackEntityById,
  [E.TrackType.Zone] = quickJumpVm.trackEntityById,
  [E.TrackType.SceneObject] = quickJumpVm.trackEntityById
}
quickJumpVm.nearTraceFuncs_ = {
  [E.NearTraceTargetType.Npc] = quickJumpVm.trackNearNpcByFuncId,
  [E.NearTraceTargetType.Zone] = quickJumpVm.trackNearZoneByTagId,
  [E.NearTraceTargetType.SceneObject] = quickJumpVm.trackNearSceneObjByTagId
}
return quickJumpVm
