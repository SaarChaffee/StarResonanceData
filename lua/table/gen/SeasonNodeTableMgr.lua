local SeasonNodeTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local SeasonNodeTableMgr = class("SeasonNodeTableMgr", super)

function SeasonNodeTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function SeasonNodeTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("SeasonNodeTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function SeasonNodeTableMgr:TryGetHoleIdHoleLevel(HoleId, HoleLevel, notErrorWhenNotFound)
  local unionKey = HoleId << 32 | HoleLevel
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.SeasonNodeTableTryGetHoleIdHoleLevel(HoleId, HoleLevel)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("SeasonNodeTableMgr:GetRow HoleId:{0} ,HoleLevel:{1}  failed  in scene:{2}", HoleId, HoleLevel, self.GetCurrentSceneId())
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

function SeasonNodeTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = SeasonNodeTableMgr.new(ptr, fields)
  end,
  TryGetHoleIdHoleLevel = function(HoleId, HoleLevel, notErrorWhenNotFound)
    return wrapper:TryGetHoleIdHoleLevel(HoleId, HoleLevel, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
