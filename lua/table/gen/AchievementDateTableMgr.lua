local AchievementDateTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local AchievementDateTableMgr = class("AchievementDateTableMgr", super)

function AchievementDateTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function AchievementDateTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("AchievementDateTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function AchievementDateTableMgr:TryGetAchievementIdAchievementLevel(AchievementId, AchievementLevel, notErrorWhenNotFound)
  local unionKey = AchievementId << 32 | AchievementLevel
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.AchievementDateTableTryGetAchievementIdAchievementLevel(AchievementId, AchievementLevel)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("AchievementDateTableMgr:GetRow AchievementId:{0} ,AchievementLevel:{1}  failed  in scene:{2}", AchievementId, AchievementLevel, self.GetCurrentSceneId())
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

function AchievementDateTableMgr:GetDatas()
  return super.GetDatas(self)
end

function AchievementDateTableMgr:ClearCache()
  local mgr = require("utility.table_manager")
  self.__rows = {}
  setmetatable(self.__rows, mgr.table_manager_mt)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = AchievementDateTableMgr.new(ptr, fields)
  end,
  TryGetAchievementIdAchievementLevel = function(AchievementId, AchievementLevel, notErrorWhenNotFound)
    return wrapper:TryGetAchievementIdAchievementLevel(AchievementId, AchievementLevel, notErrorWhenNotFound)
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
