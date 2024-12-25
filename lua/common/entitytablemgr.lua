local ret = {
  npcEntityDataCache = {},
  zoneEntityTagDataCache = {},
  sceneEntityTagDataCache = {},
  npcFunctionDataCache = {}
}
local sourceSceneIdList = {}

function ret.Init()
  ret.initSourceSceneIdList()
  ret.updateCacheData()
end

function ret.updateCacheData()
  ret.updateNpcEntityDataCache()
  ret.updateZoneEntityDataCache()
  ret.updateSceneEntityDataCache()
  ret.updateNpcFunctionDataCache()
end

function ret.initSourceSceneIdList()
  sourceSceneIdList = {}
  local mapInfoTableMgr = Z.TableMgr.GetTable("MapInfoTableMgr")
  local allMapInfoRow = mapInfoTableMgr.GetDatas()
  for sceneId, info in pairs(allMapInfoRow) do
    if info.IsExportGlobal then
      table.insert(sourceSceneIdList, sceneId)
    end
  end
end

function ret.GetNpcIdByFunctionId(funcId)
  local npcIds = ret.npcFunctionDataCache[funcId]
  if npcIds ~= nil and 0 < #npcIds then
    return npcIds[1]
  end
  return nil
end

function ret.GetNpcEntityDataByNpcId(npcId, findSceneId)
  local uIds = ret.npcEntityDataCache[npcId]
  if uIds == nil then
    return nil
  end
  for _, curSceneId in ipairs(sourceSceneIdList) do
    for _, uId in ipairs(uIds) do
      local sceneId = math.floor(uId / Z.ConstValue.GlobalLevelIdOffset)
      if findSceneId ~= nil and findSceneId == sceneId or findSceneId == nil and curSceneId == sceneId then
        local npcEntityGlobalTableMgr = Z.TableMgr.GetTable("NpcEntityGlobalTableMgr")
        local npcEntityCfgData = npcEntityGlobalTableMgr.GetRow(uId)
        return curSceneId, npcEntityCfgData
      end
    end
  end
end

function ret.GetZoneEntityDataBySceneTagId(tagId)
  local uIds = ret.zoneEntityTagDataCache[tagId]
  if uIds == nil then
    return nil
  end
  for _, curSceneId in ipairs(sourceSceneIdList) do
    for index, uid in ipairs(uIds) do
      local sceneId = math.floor(uid / Z.ConstValue.GlobalLevelIdOffset)
      if curSceneId == sceneId then
        local zoneEntityGlobalTableMgr = Z.TableMgr.GetTable("ZoneEntityGlobalTableMgr")
        local zoneEntityCfgData = zoneEntityGlobalTableMgr.GetRow(uid)
        return curSceneId, zoneEntityCfgData
      end
    end
  end
end

function ret.GetSceneEntityDataBySceneTagId(tagId)
  local uIds = ret.sceneEntityTagDataCache[tagId]
  if uIds == nil then
    return nil
  end
  for _, curSceneId in ipairs(sourceSceneIdList) do
    for _, uid in ipairs(uIds) do
      local sceneId = math.floor(uid / Z.ConstValue.GlobalLevelIdOffset)
      if curSceneId == sceneId then
        local sceneEntityGlobalTableMgr = Z.TableMgr.GetTable("SceneObjectEntityGlobalTableMgr")
        local sceneEntityCfgData = sceneEntityGlobalTableMgr.GetRow(uid)
        return curSceneId, sceneEntityCfgData
      end
    end
  end
end

function ret.updateNpcEntityDataCache()
  local npcEntityGlobalTableMgr = Z.TableMgr.GetTable("NpcEntityGlobalTableMgr")
  ret.npcEntityDataCache = {}
  for key, value in pairs(npcEntityGlobalTableMgr:GetDatas()) do
    local uIds = ret.npcEntityDataCache[value.Id]
    if uIds == nil then
      uIds = {}
      ret.npcEntityDataCache[value.Id] = uIds
    end
    uIds[#uIds + 1] = key
  end
end

function ret.updateZoneEntityDataCache()
  local zoneEntityGlobalTableMgr = Z.TableMgr.GetTable("ZoneEntityGlobalTableMgr")
  ret.zoneEntityTagDataCache = {}
  for key, value in pairs(zoneEntityGlobalTableMgr:GetDatas()) do
    if value.OptionData and value.OptionData ~= "" then
      local tbl = load("return " .. value.OptionData)()
      if type(tbl) == "table" and tbl.IconId then
        local tagId = tonumber(tbl.IconId)
        if tagId ~= nil then
          local uIds = ret.zoneEntityTagDataCache[tagId]
          if uIds == nil then
            uIds = {}
            ret.zoneEntityTagDataCache[tagId] = uIds
          end
          uIds[#uIds + 1] = key
        end
      end
    end
  end
end

function ret.updateSceneEntityDataCache()
  local sceneEntityGlobalDatas = Z.TableMgr.GetLevelGlobalTableDatas(E.LevelTableType.SceneObject)
  ret.sceneEntityTagDataCache = {}
  for key, value in pairs(sceneEntityGlobalDatas) do
    if value.OptionData and value.OptionData ~= "" then
      local tbl = load("return " .. value.OptionData)()
      if type(tbl) == "table" and tbl.IconId then
        local tagId = tonumber(tbl.IconId)
        if tagId ~= nil then
          local uIds = ret.sceneEntityTagDataCache[tagId]
          if uIds == nil then
            uIds = {}
            ret.sceneEntityTagDataCache[tagId] = uIds
          end
          uIds[#uIds + 1] = key
        end
      end
    end
  end
end

function ret.updateNpcFunctionDataCache()
  for npcId, npcCfgData in pairs(Z.TableMgr.GetTable("NpcTableMgr"):GetDatas()) do
    local value = npcCfgData.NpcFunctionID
    if 0 < #value then
      for _, v in ipairs(value) do
        if 2 <= #v then
          local funcId = tonumber(v[2])
          if funcId then
            local npcIds = ret.npcFunctionDataCache[funcId]
            if npcIds == nil then
              npcIds = {}
              ret.npcFunctionDataCache[funcId] = npcIds
            end
            npcIds[#npcIds + 1] = npcId
          end
        end
      end
    end
  end
end

return ret
