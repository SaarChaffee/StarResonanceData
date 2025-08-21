local super = require("ui.service.service_base")
local RechargeActivityService = class("RechargeActivityService", super)

function RechargeActivityService:OnInit()
end

function RechargeActivityService:OnUnInit()
end

function RechargeActivityService:OnLogin()
end

function RechargeActivityService:OnLeaveScene()
end

function RechargeActivityService:OnLogout()
end

function RechargeActivityService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    Z.CoroUtil.create_coro_xpcall(function()
      local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
      local rechargeActivityVm = Z.VMMgr.GetVM("recharge_activity")
      rechargeActivityVm.AsyncGetActivityList(rechargeActivityData.CancelSource:CreateToken())
      rechargeActivityVm.CheckRed()
    end)()
  end
end

return RechargeActivityService
