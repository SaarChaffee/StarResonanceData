local SkillFightLevelTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local SkillFightLevelTableMgr = class("SkillFightLevelTableMgr", super)

function SkillFightLevelTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function SkillFightLevelTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("SkillFightLevelTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function SkillFightLevelTableMgr:TryGetSkillIdLevel(SkillId, Level, notErrorWhenNotFound)
  local unionKey = SkillId << 32 | Level
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.SkillFightLevelTableTryGetSkillIdLevel(SkillId, Level)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("SkillFightLevelTableMgr:GetRow SkillId:{0} ,Level:{1}  failed  in scene:{2}", SkillId, Level, self.GetCurrentSceneId())
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

function SkillFightLevelTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = SkillFightLevelTableMgr.new(ptr, fields)
  end,
  TryGetSkillIdLevel = function(SkillId, Level, notErrorWhenNotFound)
    return wrapper:TryGetSkillIdLevel(SkillId, Level, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
