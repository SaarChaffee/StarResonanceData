local PhotoQuestMgr = class("PhotoQuestMgr")
local PhotoTargetType = Panda.ZGame.PhotoTargetType
local PhotoQuestMgrIns = Panda.ZGame.PhotoQuestMgr.Instance
local EPhotoTargetType = {
  Npc = 1,
  Monster = 2,
  SceneObject = 3,
  Collection = 4,
  Zone = 5,
  Point = 6
}
local EEntityConfigs = {
  [EPhotoTargetType.Npc] = "NpcEntityTableMgr",
  [EPhotoTargetType.Monster] = "MonsterEntityTableMgr",
  [EPhotoTargetType.SceneObject] = "SceneObjectEntityTableMgr",
  [EPhotoTargetType.Collection] = "CollectionEntityTableMgr",
  [EPhotoTargetType.Zone] = "ZoneEntityTableMgr",
  [EPhotoTargetType.Point] = "ScenePointInfoTableMgr"
}

function PhotoQuestMgr:getPhotoTaskData(photoParamId, type, uid)
  local photoParamTbl = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(photoParamId)
  if photoParamTbl then
    local config = Z.TableMgr.GetTable(EEntityConfigs[type])
    if not config then
      return
    end
    local pointInfo
    if uid then
      pointInfo = config.GetRow(uid)
    else
      pointInfo = config.GetRow(photoParamTbl.PointId)
    end
    if pointInfo then
      return pointInfo
    end
  end
  return nil
end

function PhotoQuestMgr:GetPhotoTask()
  local mapClockVm = Z.VMMgr.GetVM("map_clock")
  local tb = {}
  for index, value in ipairs(table.zunique(mapClockVm.GetPhotoTask())) do
    local pointInfo = PhotoQuestMgr:getPhotoTaskData(value, EPhotoTargetType.Point)
    if pointInfo then
      tb[value] = {}
      tb[value].data = pointInfo
      tb[value].func = function()
        local goalVm = Z.VMMgr.GetVM("goal")
        goalVm.SetGoalFinish(E.GoalType.TakePhoto, value)
      end
    end
  end
  local questVm = Z.VMMgr.GetVM("quest")
  local quests = questVm.GetPhotoQuestStepIds()
  for index, value in ipairs(quests) do
    local pointInfo = PhotoQuestMgr:getPhotoTaskData(value.id, value.entityType, value.entityUid)
    if pointInfo then
      tb[value.id] = {}
      tb[value.id].data = pointInfo
      tb[value.id].func = function()
        local goalVm = Z.VMMgr.GetVM("goal")
        goalVm.SetGoalFinish(E.GoalType.TargetEntityPhoto, value.entityType, value.entityUid, value.id)
        Z.TipsVM.ShowTipsLang(140101)
      end
    end
  end
  return tb
end

function PhotoQuestMgr:GetNearestPhotoTaskId(posInfoList)
  local photoTaskId = 0
  local nearestDistance = 0
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return photoTaskId, nearestDistance
  end
  local playerPos = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
  for photoId, value in pairs(posInfoList) do
    if value.data then
      local photoParamConfig = Z.TableMgr.GetTable("PhotoParamTableMgr").GetRow(photoId)
      local pointPos = Vector3.New(value.data.Position[1], value.data.Position[2], value.data.Position[3])
      local distance = (pointPos - playerPos):Magnitude()
      if distance >= photoParamConfig.DistanceHint.X and distance <= photoParamConfig.DistanceHint.Y and nearestDistance < distance then
        nearestDistance = distance
        photoTaskId = photoId
      end
    end
  end
  return photoTaskId, nearestDistance
end

function PhotoQuestMgr:CheckPhotoQuestConditions(targetId)
  local targetConfig = Z.TableMgr.GetTable("PhotoTargetTableMgr").GetRow(targetId)
  local suffice = false
  if targetConfig then
    suffice = PhotoQuestMgrIns:CheckPhotoQuestConditions(targetId)
  end
  return suffice
end

function PhotoQuestMgr:GetPhotoQuestFinishNum(targetId)
  local targetConfig = Z.TableMgr.GetTable("PhotoTargetTableMgr").GetRow(targetId)
  local count = 0
  if targetConfig and targetConfig.TargetType == PhotoTargetType.EDayOrNight:ToInt() and self:CheckPhotoQuestConditions(targetId) then
    count = 1
  end
  return count
end

return PhotoQuestMgr
