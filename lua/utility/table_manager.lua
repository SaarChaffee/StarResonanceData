local CSTableBridge = Bokura.CSTableBridge
local table_row_mt = {
  __index = function(t, k)
    local field = t.__field
    local order = field[k]
    if not order then
      return nil
    end
    CSTableBridge.FillRow(t, order)
    local ret = rawget(t, k)
    if ret == nil then
      logError("Attempt to read undeclare field:{0}, maybe c# table code not matched lua table code", k)
    end
    return ret
  end
}
local table_manager_mt = {__mode = "v"}
local cached_tbl = {}
local reg_manager = function(ptr, name, fields)
  local proxy = require("table.gen." .. name)
  proxy.__init(ptr, fields)
  cached_tbl[name] = proxy
end
local clearCache = function(name)
  local t = cached_tbl[name]
  if t ~= nil then
    t:ClearCache()
  end
end
local getTable = function(name)
  return cached_tbl[name]
end
local getRow = function(tabName, key, notErrorWhenNotFound)
  local tab = getTable(tabName)
  if tab then
    return tab.GetRow(key, notErrorWhenNotFound)
  end
end
local decodeLineBreak = function(content)
  if content ~= nil then
    return string.gsub(tostring(content), "<br>", "\n")
  end
end
local tableTypeToName = {
  [E.LevelTableType.Npc] = {
    tblName = "NpcEntityTableMgr",
    globalTblName = "NpcEntityGlobalTableMgr"
  },
  [E.LevelTableType.Zone] = {
    tblName = "ZoneEntityTableMgr",
    globalTblName = "ZoneEntityGlobalTableMgr"
  },
  [E.LevelTableType.Monster] = {
    tblName = "MonsterEntityTableMgr",
    globalTblName = "MonsterEntityGlobalTableMgr"
  },
  [E.LevelTableType.Point] = {
    tblName = "ScenePointInfoTableMgr",
    globalTblName = "ScenePointInfoGlobalTableMgr"
  },
  [E.LevelTableType.SceneObject] = {
    tblName = "SceneObjectEntityTableMgr",
    globalTblName = "SceneObjectEntityGlobalTableMgr"
  }
}
local getLevelTableRow = function(tableType, sceneId, uid)
  local nameDict = tableTypeToName[tableType]
  if not nameDict then
    logError("[TableMgr] \228\184\141\229\173\152\229\156\168\231\154\132\229\133\179\229\141\161\232\161\168\231\177\187\229\158\139 tableType = {0}", tableType)
    return
  end
  local row
  if sceneId == Z.StageMgr.GetCurrentSceneId() then
    row = getTable(nameDict.tblName).GetRow(uid)
  else
    local id = sceneId * Z.ConstValue.GlobalLevelIdOffset + uid
    row = getTable(nameDict.globalTblName).GetRow(id)
  end
  return row
end
local levelGlobalTableDatas = {}
local getLevelGlobalTableDatas = function(tableType)
  local nameDict = tableTypeToName[tableType]
  if not nameDict then
    logError("[TableMgr] \228\184\141\229\173\152\229\156\168\231\154\132\229\133\179\229\141\161\232\161\168\231\177\187\229\158\139 tableType = {0}", tableType)
    return {}
  end
  if levelGlobalTableDatas[tableType] == nil then
    levelGlobalTableDatas[tableType] = getTable(nameDict.globalTblName).GetDatas()
  end
  return levelGlobalTableDatas[tableType]
end
local getLevelTableDatas = function(tableType, sceneId)
  local nameDict = tableTypeToName[tableType]
  if not nameDict then
    logError("[TableMgr] \228\184\141\229\173\152\229\156\168\231\154\132\229\133\179\229\141\161\232\161\168\231\177\187\229\158\139 tableType = {0}", tableType)
    return {}
  end
  local rowDict = {}
  if sceneId == Z.StageMgr.GetCurrentSceneId() then
    rowDict = getTable(nameDict.tblName).GetDatas()
  else
    local globalTableDatas = getLevelGlobalTableDatas(tableType)
    for id, row in pairs(globalTableDatas) do
      local configSceneId = math.floor(id / Z.ConstValue.GlobalLevelIdOffset)
      if configSceneId == sceneId then
        local uid = id % Z.ConstValue.GlobalLevelIdOffset
        rowDict[uid] = row
      end
    end
  end
  return rowDict
end
local table_manager = {
  table_row_mt = table_row_mt,
  table_manager_mt = table_manager_mt,
  reg_manager = reg_manager,
  ClearCache = clearCache,
  DecodeLineBreak = decodeLineBreak,
  GetTable = getTable,
  GetRow = getRow,
  GetLevelTableRow = getLevelTableRow,
  GetLevelGlobalTableDatas = getLevelGlobalTableDatas,
  GetLevelTableDatas = getLevelTableDatas
}
return table_manager
