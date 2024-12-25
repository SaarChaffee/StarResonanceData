local SeasonNodeDataTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local SeasonNodeDataTableMgr = class("SeasonNodeDataTableMgr", super)

function SeasonNodeDataTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function SeasonNodeDataTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("SeasonNodeDataTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function SeasonNodeDataTableMgr:TryGetNodeIdNodeLevel(NodeId, NodeLevel, notErrorWhenNotFound)
  local unionKey = NodeId << 32 | NodeLevel
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.SeasonNodeDataTableTryGetNodeIdNodeLevel(NodeId, NodeLevel)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("SeasonNodeDataTableMgr:GetRow NodeId:{0} ,NodeLevel:{1}  failed  in scene:{2}", NodeId, NodeLevel, self.GetCurrentSceneId())
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

function SeasonNodeDataTableMgr:GetDatas()
  return super.GetDatas(self)
end

function SeasonNodeDataTableMgr:ClearCache()
  local mgr = require("utility.table_manager")
  self.__rows = {}
  setmetatable(self.__rows, mgr.table_manager_mt)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = SeasonNodeDataTableMgr.new(ptr, fields)
  end,
  TryGetNodeIdNodeLevel = function(NodeId, NodeLevel, notErrorWhenNotFound)
    return wrapper:TryGetNodeIdNodeLevel(NodeId, NodeLevel, notErrorWhenNotFound)
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
