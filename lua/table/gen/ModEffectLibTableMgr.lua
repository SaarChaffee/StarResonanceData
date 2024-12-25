local ModEffectLibTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local ModEffectLibTableMgr = class("ModEffectLibTableMgr", super)

function ModEffectLibTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function ModEffectLibTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("ModEffectLibTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function ModEffectLibTableMgr:TryGetEffectLibIDEffectConfig(EffectLibID, EffectConfig, notErrorWhenNotFound)
  local unionKey = EffectLibID << 32 | EffectConfig
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.ModEffectLibTableTryGetEffectLibIDEffectConfig(EffectLibID, EffectConfig)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("ModEffectLibTableMgr:GetRow EffectLibID:{0} ,EffectConfig:{1}  failed  in scene:{2}", EffectLibID, EffectConfig, self.GetCurrentSceneId())
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

function ModEffectLibTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = ModEffectLibTableMgr.new(ptr, fields)
  end,
  TryGetEffectLibIDEffectConfig = function(EffectLibID, EffectConfig, notErrorWhenNotFound)
    return wrapper:TryGetEffectLibIDEffectConfig(EffectLibID, EffectConfig, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
