local ModEffectTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local ModEffectTableMgr = class("ModEffectTableMgr", super)

function ModEffectTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function ModEffectTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("ModEffectTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function ModEffectTableMgr:TryGetEffectIDLevel(EffectID, Level, notErrorWhenNotFound)
  local unionKey = EffectID << 32 | Level
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.ModEffectTableTryGetEffectIDLevel(EffectID, Level)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("ModEffectTableMgr:GetRow EffectID:{0} ,Level:{1}  failed  in scene:{2}", EffectID, Level, self.GetCurrentSceneId())
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

function ModEffectTableMgr:GetDatas()
  return super.GetDatas(self)
end

function ModEffectTableMgr:ClearCache()
  local mgr = require("utility.table_manager")
  self.__rows = {}
  setmetatable(self.__rows, mgr.table_manager_mt)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = ModEffectTableMgr.new(ptr, fields)
  end,
  TryGetEffectIDLevel = function(EffectID, Level, notErrorWhenNotFound)
    return wrapper:TryGetEffectIDLevel(EffectID, Level, notErrorWhenNotFound)
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
