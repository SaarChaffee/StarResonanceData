local EquipRefineTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local EquipRefineTableMgr = class("EquipRefineTableMgr", super)

function EquipRefineTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function EquipRefineTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("EquipRefineTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function EquipRefineTableMgr:TryGetRefineIdRefineLevel(RefineId, RefineLevel, notErrorWhenNotFound)
  local unionKey = RefineId << 32 | RefineLevel
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.EquipRefineTableTryGetRefineIdRefineLevel(RefineId, RefineLevel)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("EquipRefineTableMgr:GetRow RefineId:{0} ,RefineLevel:{1}  failed  in scene:{2}", RefineId, RefineLevel, self.GetCurrentSceneId())
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

function EquipRefineTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = EquipRefineTableMgr.new(ptr, fields)
  end,
  TryGetRefineIdRefineLevel = function(RefineId, RefineLevel, notErrorWhenNotFound)
    return wrapper:TryGetRefineIdRefineLevel(RefineId, RefineLevel, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
