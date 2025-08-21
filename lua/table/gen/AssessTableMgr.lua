local AssessTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local AssessTableMgr = class("AssessTableMgr", super)

function AssessTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function AssessTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("AssessTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function AssessTableMgr:TryGetIdAssessId(Id, AssessId, notErrorWhenNotFound)
  local unionKey = Id << 32 | AssessId
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.AssessTableTryGetIdAssessId(Id, AssessId)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("AssessTableMgr:GetRow Id:{0} ,AssessId:{1}  failed  in scene:{2}", Id, AssessId, self.GetCurrentSceneId())
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

function AssessTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = AssessTableMgr.new(ptr, fields)
  end,
  TryGetIdAssessId = function(Id, AssessId, notErrorWhenNotFound)
    return wrapper:TryGetIdAssessId(Id, AssessId, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
