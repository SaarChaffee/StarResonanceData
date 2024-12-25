local clearDungeonGuideGoal = function()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.Dungeon, nil)
end
local getPosCfgList = function(targetId)
  local targetData = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
  if targetData == nil then
    return
  end
  local goalPosData = string.zsplit(targetData.TargetPos, "|")
  if goalPosData == nil or #goalPosData == 0 then
    return
  end
  local cfgList = {}
  for i = 1, #goalPosData do
    local goalPosArray = string.zsplit(goalPosData[i], "=")
    if goalPosArray == nil or #goalPosArray == 0 then
      return
    end
    local posType = Z.GoalPosType.IntToEnum(goalPosArray[1])
    local uid = tonumber(goalPosArray[2])
    local tbl
    if posType == Z.GoalPosType.Point then
      tbl = Z.TableMgr.GetTable("ScenePointInfoTableMgr")
    elseif posType == Z.GoalPosType.Npc then
      tbl = Z.TableMgr.GetTable("NpcEntityTableMgr")
    elseif posType == Z.GoalPosType.Monster then
      tbl = Z.TableMgr.GetTable("MonsterEntityTableMgr")
    elseif posType == Z.GoalPosType.Zone then
      tbl = Z.TableMgr.GetTable("ZoneEntityTableMgr")
    elseif posType == Z.GoalPosType.SceneObject then
      tbl = Z.TableMgr.GetTable("SceneObjectEntityTableMgr")
    end
    local posCfg = tbl.GetRow(uid)
    local pos
    if posCfg then
      local posArray = posCfg.Position
      pos = {
        x = posArray[1],
        y = posArray[2],
        z = posArray[3]
      }
    else
      logError("dungeon_track_vm getPosCfg pos error {0},{1}", posType, uid)
      pos = {
        x = 0,
        y = 0,
        z = 0
      }
    end
    local cfg = {
      pos = pos,
      uid = uid,
      posType = posType
    }
    cfgList[#cfgList + 1] = cfg
  end
  return cfgList
end
local updateDungeonGuideGoal = function()
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local posCfgList = dungeonData:GetDungeonTargetData("posCfg")
  local targetId = dungeonData:GetDungeonTargetData("trackId")
  local posCfg = posCfgList[targetId]
  if posCfg == nil then
    clearDungeonGuideGoal()
    return
  end
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local dataList = {}
  for i = 1, #posCfg do
    local info = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.Dungeon, sceneId, posCfg[i].uid, posCfg[i].posType, Vector3.New(posCfg[i].pos.x, posCfg[i].pos.y, posCfg[i].pos.z))
    table.insert(dataList, info)
  end
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.Dungeon, dataList)
end
local updateDungeonTrackData = function()
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local stepId = dungeonData:GetDungeonTargetData("step")
  if stepId == -1 then
    clearDungeonGuideGoal()
    return
  end
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if dungeonsTable then
    local targetArray = dungeonsTable.DungeonTarget[stepId]
    local posCfgList = {}
    for i = 1, #targetArray do
      posCfgList[targetArray[i]] = getPosCfgList(targetArray[i])
    end
    dungeonData:SetDungeonTargetData("posCfg", posCfgList)
    updateDungeonGuideGoal()
  end
end
local setDungeonStepAndTarget = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  if dungeonId == 0 then
    dungeonData:SetDungeonTargetData("step", -1)
    clearDungeonGuideGoal()
    return
  end
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local targetData = Z.ContainerMgr.DungeonSyncData.target.targetData
  if dungeonsTable then
    for i = 1, #dungeonsTable.DungeonTarget do
      local data = dungeonsTable.DungeonTarget[i]
      for j = 1, #data do
        local targetId = data[j]
        if targetData[targetId] and targetData[targetId].complete == 0 then
          dungeonData:SetDungeonTargetData("trackId", targetId)
          dungeonData:SetDungeonTargetData("step", i)
          updateDungeonTrackData()
          Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.TrackAnimPlay)
          return
        end
      end
    end
  end
  dungeonData:SetDungeonTargetData("step", -1)
  clearDungeonGuideGoal()
end
local onDungeonTargetDataChange = function(container, dirtyKeys)
  setDungeonStepAndTarget()
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateTrackView)
end
local onDungeonVarDataChange = function()
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateDungeonVar)
end
local watcherDungeonTargetChange = function()
  local target = Z.ContainerMgr.DungeonSyncData.target
  target.Watcher:RegWatcher(onDungeonTargetDataChange)
  local dungeonVar = Z.ContainerMgr.DungeonSyncData.dungeonVar
  dungeonVar.Watcher:RegWatcher(onDungeonVarDataChange)
end
local getTargetOfDungeonVar = function(targetId)
  local gungeonVarCont = Z.ContainerMgr.DungeonSyncData.dungeonVar
  if gungeonVarCont == nil then
    return {}
  end
  local varTbl = {}
  for _, data in pairs(gungeonVarCont.dungeonVarData) do
    varTbl[data.name] = data.value
  end
  local varShowDataTbl = {}
  local targetRow = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
  local varNames = targetRow.SpVariable
  local varVals = targetRow.SpVariableLimit
  local varLangs = targetRow.SpVariableName
  local bShowProgs = targetRow.IsShowSpVariableProgress
  for i, str in ipairs(varNames) do
    if varTbl[str] ~= nil then
      local param = {
        varName = varNames[i],
        varCurVal = varTbl[str],
        varMaxVal = varTbl[varVals[i]] or 0,
        varLang = varLangs[i],
        bShowProgs = bShowProgs[i]
      }
      table.insert(varShowDataTbl, param)
    end
  end
  return varShowDataTbl
end
local onEnterScene = function()
  setDungeonStepAndTarget()
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.TargetResetData)
end
local setDungeonTrackViewIsHide = function(isHide)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  dungeonData.TrackViewShow = isHide
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateTargetViewVisible)
end
local ret = {
  WatcherDungeonTargetChange = watcherDungeonTargetChange,
  UpdateDungeonGuideGoal = updateDungeonGuideGoal,
  GetTargetOfDungeonVar = getTargetOfDungeonVar,
  OnEnterScene = onEnterScene,
  SetDungeonTrackViewIsHide = setDungeonTrackViewIsHide
}
return ret
