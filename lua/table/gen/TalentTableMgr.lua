local TalentTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local TalentTableMgr = class("TalentTableMgr", super)

function TalentTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function TalentTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("TalentTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function TalentTableMgr:TryGetTalentIdTalentLevel(TalentId, TalentLevel, notErrorWhenNotFound)
  local unionKey = TalentId << 32 | TalentLevel
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.TalentTableTryGetTalentIdTalentLevel(TalentId, TalentLevel)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("TalentTableMgr:GetRow TalentId:{0} ,TalentLevel:{1}  failed  in scene:{2}", TalentId, TalentLevel, self.GetCurrentSceneId())
    end
    return nil
  end
  local row = {}
  row.__field = self.fields
  row.__rowptr = rowptr
  setmetatable(row, mgr.table_row_mt)
  self.__rows[unionKey] = row
  return row
end

function TalentTableMgr:GetDatas()
  return super.GetDatas(self)
end

function TalentTableMgr:ClearCache()
  local mgr = require("utility.table_manager")
  self.__rows = {}
  setmetatable(self.__rows, mgr.table_manager_mt)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = TalentTableMgr.new(ptr, fields)
  end,
  TryGetTalentIdTalentLevel = function(TalentId, TalentLevel, notErrorWhenNotFound)
    return wrapper:TryGetTalentIdTalentLevel(TalentId, TalentLevel, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end,
  ClearCache = function()
    wrapper:ClearCache()
  end
}
