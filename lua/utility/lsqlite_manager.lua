local lsqlite3 = require("lsqlite")
local template = require("zutil.template")
local pb = require("pb2")
local dbName = "brk_panda.db"
local db
local createTableSql = [[
    CREATE TABLE IF NOT EXISTS {{dbTableName}} (key PRIMARY KEY ,value blob);

]]
local insertSql = "    REPLACE INTO {{dbTableName}} VALUES ({{key}},?);\n"
local selectSqlByKey = "     SELECT * FROM {{dbTableName}} WHERE key = {{key}};\n"
local selectAllSql = "     SELECT * FROM {{dbTableName}} ORDER BY key;\n"
local deleteDataByKeySql = "     DELETE FROM {{dbTableName}} WHERE key ={{key}};\n"
local deleteAllDataSql = "    DELETE FROM {{dbTableName}}\n"
local existSql = "    SELECT count(*) FROM sqlite_master WHERE type=\"table\" AND name = \"{{dbTableName}}\"\n"
local errorFunc = function(e)
  logError("[lsqlite3]" .. e)
end
local dbPath
local closedb = function()
  if db and db:isopen() then
    xpcall(db.close, errorFunc, db)
  end
end
local openDb = function()
  if db == nil or not db:isopen() then
    closedb()
    db = lsqlite3.open(dbPath, lsqlite3.OPEN_READWRITE + lsqlite3.OPEN_CREATE + lsqlite3.OPEN_SHAREDCACHE)
  end
end
local init = function()
  closedb()
  local dir = string.format("%s/db", UnityEngine.Application.persistentDataPath)
  Z.LuaBridge.MakeDirectoryExist(dir)
  dbPath = string.format("%s/%s", dir, dbName)
  openDb()
end
local uninit = function()
  closedb()
end
local isExistTab = function(dbTableName)
  local v = template.new(existSql)
  v.dbTableName = dbTableName
  local sql = tostring(v)
  local ret
  db:exec(sql)
  if ret ~= lsqlite3.OK then
    local errStr = string.format("[lsqlite3] exec '%s' failed ,errorCode is %d", sql, ret)
    logError(errStr)
  end
end
local createTable = function(dbTableName)
  local v = template.new(createTableSql)
  v.dbTableName = dbTableName
  local sql = tostring(v)
  openDb()
  local ret = db:exec(sql)
  if ret ~= lsqlite3.OK then
    local errStr = string.format("[lsqlite3] exec '%s' failed ,error is %s", sql, db:errmsg())
    logError(errStr)
    return false
  end
  return true
end
local updataData = function(dbTableName, pbName, key, data)
  local v = template.new(insertSql)
  v.dbTableName = dbTableName
  v.key = key
  local value = pb.encode(pbName, data)
  local sql = tostring(v)
  openDb()
  local stmt = db:prepare(sql)
  if stmt == nil then
    local errStr = string.format("[lsqlite3] prepare '%s' failed ,error is %s", sql, db:errmsg())
    logError(errStr)
    return false
  end
  stmt:bind_blob(1, value)
  local res = stmt:step()
  if res ~= lsqlite3.ROW and res ~= lsqlite3.DONE then
    logError("[lsqlite3]" .. res)
    local errStr = string.format("[lsqlite3] step updataData failed ,error is %s", db:errmsg())
    logError(errStr)
    stmt:finalize()
    return false
  end
  stmt:finalize()
  return true
end
local getDataByKey = function(dbTableName, pbName, key)
  local v = template.new(selectSqlByKey)
  v.dbTableName = dbTableName
  v.key = key
  local sql = tostring(v)
  openDb()
  local stmt = db:prepare(sql)
  if not stmt then
    return {}
  end
  local ret = stmt:step()
  if ret ~= lsqlite3.ROW and ret ~= lsqlite3.DONE then
    logError("[lsqlite3]" .. ret)
    local errStr = string.format("[lsqlite3] step getDataByKey failed ,error is %s", db:errmsg())
    logError(errStr)
    stmt:finalize()
    return nil
  end
  if ret == lsqlite3.DONE then
    stmt:finalize()
    return nil
  end
  local pbData = stmt:get_value(1)
  if pbData == nil then
    stmt:finalize()
    return nil
  end
  local data = pb.decode(pbName, pbData)
  stmt:finalize()
  return data
end
local getAllDatas = function(dbTableName, pbName)
  local v = template.new(selectAllSql)
  v.dbTableName = dbTableName
  local sql = tostring(v)
  openDb()
  local stmt = db:prepare(sql)
  local ret = stmt:step()
  if ret ~= lsqlite3.ROW and ret ~= lsqlite3.DONE then
    local errStr = string.format("[lsqlite3] step getAllDatas failed ,error is %s", db:errmsg())
    logError(errStr)
    stmt:finalize()
    return nil
  end
  if ret == lsqlite3.DONE then
    stmt:finalize()
    return nil
  end
  local data = {}
  for key, value in stmt:urows() do
    data[key] = pb.decode(pbName, value)
  end
  stmt:finalize()
  return data
end
local deleteByKey = function(dbTableName, key)
  local v = template.new(deleteDataByKeySql)
  v.dbTableName = dbTableName
  v.key = key
  local sql = tostring(v)
  openDb()
  local ret = db:exec(sql)
  if ret ~= lsqlite3.OK then
    local errStr = string.format("[lsqlite3] step deleteByKey failed ,error is %s", db:errmsg())
    logError(errStr)
    return false
  end
  return true
end
local deleteAllData = function(dbTableName)
  local v = template.new(deleteAllDataSql)
  v.dbTableName = dbTableName
  local sql = tostring(v)
  openDb()
  local ret = db:exec(sql)
  if ret ~= lsqlite3.OK then
    local errStr = string.format("[lsqlite3] step deleteByKey failed ,error is %s", db:errmsg())
    logError(errStr)
    return false
  end
  return true
end
local lsqliteMgr = {
  Init = init,
  UnInit = uninit,
  CreateTable = createTable,
  UpdataData = updataData,
  GetDataByKey = getDataByKey,
  GetAllDatas = getAllDatas,
  DeleteByKey = deleteByKey,
  DeleteAllData = deleteAllData
}
return lsqliteMgr
