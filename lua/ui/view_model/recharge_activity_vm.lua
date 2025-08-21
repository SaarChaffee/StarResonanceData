local RechargeActivityVM = {}
local worldProxy = require("zproxy.world_proxy")
local rechargeActivityDefine = require("ui.model.recharge_activity_define")

function RechargeActivityVM.IsShowRechargeActivityBuyGifts(functionId)
  local isRechargeActivityBuyGiftUnlock = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.RechargeActivityBuyGift, true)
  if not isRechargeActivityBuyGiftUnlock then
    return false
  end
  local isRechargeActivityBuyGiftUnlock = Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(functionId, true)
  if not isRechargeActivityBuyGiftUnlock then
    return false
  end
  local count = 0
  local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
  local activityDatas = rechargeActivityData:GetActivityDatas(functionId)
  for _, activityData in ipairs(activityDatas) do
    if activityData.status == rechargeActivityDefine.EActivityStatus.ActivityStatusOnline then
      for _, award in pairs(activityData.awardList) do
        count = count + 1
      end
    end
  end
  return 0 < count
end

function RechargeActivityVM.CheckRed()
  local nowTime = Z.TimeTools.Now() / 1000
  local isHaveFreeGift = false
  local payRechargePackageMgr = Z.TableMgr.GetTable("PayRechargePackageTableMgr")
  local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
  for _, activity in pairs(rechargeActivityData.ServerData) do
    if activity.status == rechargeActivityDefine.EActivityStatus.ActivityStatusOnline then
      for _, award in pairs(activity.awardList) do
        local activityAward = award
        if (activityAward.reward_show_begintime == 0 or nowTime >= activityAward.reward_show_begintime) and (activityAward.reward_show_endtime == 0 or nowTime <= activityAward.reward_show_endtime) then
          local payRechargeConfig = payRechargePackageMgr.GetRow(activityAward.awardId)
          if payRechargeConfig.ProductId and payRechargeConfig.ProductId[1] and payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Free then
            local isReceived = false
            for _, value in ipairs(activityAward.rewardInfo.limitTimes) do
              if value.times == value.maxTimes then
                isReceived = true
                break
              end
            end
            isHaveFreeGift = not isReceived
          end
        end
      end
    end
  end
  if isHaveFreeGift then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.RechargeActivityBuyGift, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.RechargeActivityBuyGift, 0)
  end
end

function RechargeActivityVM.AsyncGetActivityList(cancelToken)
  local reply = worldProxy.GetActivityList(cancelToken)
  if reply.errCode and reply.errCode ~= 0 then
    Z.TipsVM.ShowTips(reply.errCode)
    return false
  end
  local rechargeActivityData = Z.DataMgr.Get("recharge_activity_data")
  rechargeActivityData:SetServerData(reply.activityList)
  return true
end

function RechargeActivityVM.AsyncGetActivityReward(uuid, rewardId, cancelToken)
  local request = {activityUuid = uuid, rewardId = rewardId}
  local reply = worldProxy.GetActivityReward(request, cancelToken)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  end
  return true
end

return RechargeActivityVM
