local getNpcName = function(configId)
  local npcTableMgr = Z.TableMgr.GetTable("NpcTableMgr")
  local npcTableRow = npcTableMgr.GetRow(configId)
  if npcTableRow == nil then
    return nil
  end
  local param = Z.Placeholder.SetPlayerSelfPronoun()
  local npcName = Z.Placeholder.Placeholder(npcTableRow.Name, param)
  return npcName
end
local getCollectName = function(configId)
  local collectTableMgr = Z.TableMgr.GetTable("CollectionTableMgr")
  local collectTableRow = collectTableMgr.GetRow(configId)
  if collectTableRow == nil then
    return nil
  end
  return collectTableRow.CollectionName
end
local getSceneObjName = function(configId)
  local sceneTableMgr = Z.TableMgr.GetTable("SceneObjectTableMgr")
  local sceneTableRow = sceneTableMgr.GetRow(configId)
  if sceneTableRow == nil then
    return nil
  end
  return sceneTableRow.Name
end
local uuidToEntId = function(uuid)
  return uuid >> 16
end
local entIdToUuid = function(entId, entType, isSummon, isClient)
  return entId << 16 | (isSummon and 1 or 0) << 15 | (isClient and 1 or 0) << 14 | entType << 6
end
local uuidToEntType = function(uuid)
  return uuid >> 6 & 31
end
local isSummonByUuid = function(uuid)
  return uuid >> 15 & 1 == 1
end
local isClientByUuid = function(uuid)
  return uuid >> 14 & 1 == 1
end
local checkIsAIByEntId = function(entId)
  return entId >> 10 & 1 ~= 0
end
local configIdToUUid = function(configId)
  if configId == nil then
    return 0
  end
  local entity = Z.EntityMgr:GetEntityByConfigId(Z.PbEnum("EEntityType", "EntNpc"), configId)
  if entity then
    return entity.Uuid
  else
    logError("not find NpcEntityDataByNpcId npcid ={0}", configId)
  end
  return 0
end
local ret = {
  GetNpcName = getNpcName,
  GetCollectName = getCollectName,
  GetSceneObjName = getSceneObjName,
  UuidToEntId = uuidToEntId,
  EntIdToUuid = entIdToUuid,
  UuidToEntType = uuidToEntType,
  IsSummonByUuid = isSummonByUuid,
  IsClientByUuid = isClientByUuid,
  CheckIsAIByEntId = checkIsAIByEntId,
  ConfigIdToUUid = configIdToUUid
}
return ret
