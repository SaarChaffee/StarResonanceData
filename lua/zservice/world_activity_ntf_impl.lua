local pb = require("pb2")
local WorldActivityNtfStubImpl = {}

function WorldActivityNtfStubImpl:OnCreateStub()
end

function WorldActivityNtfStubImpl:WorldActivityInfoNtf(call, info)
  local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
  for key, activity in pairs(rechargeActivityData.ServerData) do
    if activity.activityConfigId == info.activity.activityConfigId then
      rechargeActivityData.ServerData[key] = info.activity
      break
    end
  end
  Z.VMMgr.GetVM("recharge_activity").CheckRed()
  Z.EventMgr:Dispatch(Z.ConstValue.RechargeActivity.ActivityRefresh, info.activity.activityConfigId)
end

return WorldActivityNtfStubImpl
