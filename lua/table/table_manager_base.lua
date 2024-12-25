local mgr = require("utility.table_manager")
local CSTableBridge = Bokura.CSTableBridge
local TableManagerBase = class("TableManagerBase")

function TableManagerBase:ctor(tableptr, fields)
  self.__tableptr = tableptr
  self.__rows = {}
  self.fields = fields
  setmetatable(self.__rows, mgr.table_manager_mt)
end

function TableManagerBase:GetRow(key, keyType)
  local rowptr
  if keyType == "int" then
    rowptr = CSTableBridge.GetRowInt(self.__tableptr, key)
  elseif keyType == "long" then
    rowptr = CSTableBridge.GetRowLong(self.__tableptr, key)
  else
    logError("TableManagerBase:GetRow keyType:{0} not support", keyType)
    return nil
  end
  if not rowptr then
    return nil
  end
  local row = {}
  row.__field = self.fields
  row.__rowptr = rowptr
  setmetatable(row, mgr.table_row_mt)
  self.__rows[key] = row
  return row
end

function TableManagerBase:ClearCache()
  self.__rows = {}
  setmetatable(self.__rows, mgr.table_manager_mt)
end

function TableManagerBase:GetDatas()
  local tbl = CSTableBridge.GetDatas(self.__tableptr)
  local datas = {}
  for k, ptr in pairs(tbl) do
    local row = {
      __field = self.fields,
      __rowptr = ptr
    }
    setmetatable(row, mgr.table_row_mt)
    self.__rows[k] = row
    datas[k] = row
  end
  return datas
end

function TableManagerBase.GetCurrentSceneId()
  return Z.StageMgr.GetCurrentSceneId()
end

return TableManagerBase
