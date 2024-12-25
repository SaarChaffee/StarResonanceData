local super = require("ui.model.data_base")
local UnionActivityData = class("UnionActivityData", super)

function UnionActivityData:ctor()
end

function UnionActivityData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function UnionActivityData:Clear()
end

function UnionActivityData:UnInit()
  self.CancelSource:Recycle()
end

function UnionActivityData:GetCounterByFuncID(functionId)
  if self.activityDatas == nil then
    local activityTableMgr = Z.TableMgr.GetTable("UnionActivityTableMgr")
    self.activityDatas = activityTableMgr:GetDatas()
  end
  for k, v in ipairs(self.activityDatas) do
    if v.FunctionId == functionId then
      return v.CounterId
    end
  end
  return 0
end

function UnionActivityData:OnLanguageChange()
  local activityTableMgr = Z.TableMgr.GetTable("UnionActivityTableMgr")
  self.activityDatas = activityTableMgr:GetDatas()
end

return UnionActivityData
