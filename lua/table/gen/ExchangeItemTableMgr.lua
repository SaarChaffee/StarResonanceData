local ExchangeItemTableRow
local mgr = require("utility.table_manager")
local TableInitUtility = Panda.TableInitUtility
local super = require("table.table_manager_base")
local ExchangeItemTableMgr = class("ExchangeItemTableMgr", super)

function ExchangeItemTableMgr:ctor(ptr, fields)
  super.ctor(self, ptr, fields)
end

function ExchangeItemTableMgr:GetRow(key, notErrorWhenNotFound)
  local ret = self.__rows[key]
  if ret ~= nil then
    return ret
  end
  ret = super.GetRow(self, key, "int")
  if not ret then
    if not notErrorWhenNotFound then
      logError("ExchangeItemTableMgr:GetRow key:{0} failed  in scene:{1}", key, self.GetCurrentSceneId())
    end
    return nil
  end
  return ret
end

function ExchangeItemTableMgr:TryGetExchangeIDGetItemId(ExchangeID, GetItemId, notErrorWhenNotFound)
  local unionKey = ExchangeID << 32 | GetItemId
  local ret = self.__rows[unionKey]
  if ret ~= nil then
    return ret
  end
  local rowptr
  rowptr = TableInitUtility.ExchangeItemTableTryGetExchangeIDGetItemId(ExchangeID, GetItemId)
  if not rowptr then
    if not notErrorWhenNotFound then
      logError("ExchangeItemTableMgr:GetRow ExchangeID:{0} ,GetItemId:{1}  failed  in scene:{2}", ExchangeID, GetItemId, self.GetCurrentSceneId())
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

function ExchangeItemTableMgr:GetDatas()
  return super.GetDatas(self)
end

local wrapper
return {
  __init = function(ptr, fields)
    wrapper = ExchangeItemTableMgr.new(ptr, fields)
  end,
  TryGetExchangeIDGetItemId = function(ExchangeID, GetItemId, notErrorWhenNotFound)
    return wrapper:TryGetExchangeIDGetItemId(ExchangeID, GetItemId, notErrorWhenNotFound)
  end,
  GetRow = function(key, notErrorWhenNotFound)
    return wrapper:GetRow(key, notErrorWhenNotFound)
  end,
  GetDatas = function()
    return wrapper:GetDatas()
  end
}
