local super = require("ui.model.data_base")
local RechargeActivityData = class("RechargeActivityData", super)

function RechargeActivityData:ctor()
  super.ctor(self)
  self.RechargeActivityMallConfig = {}
  self.ServerData = {}
end

function RechargeActivityData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  local mallConfigs = Z.TableMgr.GetTable("MallTableMgr").GetDatas()
  for _, config in pairs(mallConfigs) do
    if config.FunctionId == E.FunctionID.RechargeActivityBuyGiftA then
      self.RechargeActivityMallConfig[E.FunctionID.RechargeActivityBuyGiftA] = config
    elseif config.FunctionId == E.FunctionID.RechargeActivityBuyGiftB then
      self.RechargeActivityMallConfig[E.FunctionID.RechargeActivityBuyGiftB] = config
    end
  end
end

function RechargeActivityData:UnInit()
  self.CancelSource:Recycle()
end

function RechargeActivityData:SetServerData(data)
  self.ServerData = data
end

function RechargeActivityData:GetActivityDatas(functionId)
  local mgr = Z.TableMgr.GetTable("PayRechargeTableMgr")
  local activities = {}
  local index = 0
  for _, activity in pairs(self.ServerData) do
    local config = mgr.GetRow(activity.activityConfigId)
    if config and config.FunctionId == functionId then
      index = index + 1
      activities[index] = activity
    end
  end
  return activities
end

return RechargeActivityData
