local worldproxy_ = require("zproxy.world_proxy")
local openInsight = function(cancelToken)
  local insightData = Z.DataMgr.Get("insight_data")
  local lastOpenInsightTime = insightData:GetLastOpenInsightTime()
  local nowTime = Z.NumTools.GetPreciseDecimal(Z.ServerTime:GetServerTime() / 1000, 1)
  local cdTime = Z.Global.InsightCD
  local insightEnergyLimit = 0
  if Z.Global.ParkourInsightOriginEnergyLimit then
    insightEnergyLimit = Z.Global.ParkourInsightOriginEnergyLimit
  end
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local isEnergyEnough = insightEnergyLimit < Z.EntityMgr.PlayerEnt:GetLuaOriginEnergy()
  if nowTime < lastOpenInsightTime + cdTime or not isEnergyEnough then
    Z.TipsVM.ShowTipsLang(700001)
  else
    local ret = worldproxy_.ReqInsight(cancelToken)
    if ret and ret ~= 0 then
      logError("openInsight\229\188\130\229\184\184:{0}", ret)
    else
      insightData:SetLastOpenInsightTime(nowTime)
      local dataMgr = Z.DataMgr.Get("explore_monster_data")
      dataMgr:SetInsightFlag(true)
    end
  end
end
local closeInsight = function(cancelToken)
  local insightData = Z.DataMgr.Get("insight_data")
  local lastOpenInsightTime = insightData:GetLastOpenInsightTime()
  local nowTime = Z.NumTools.GetPreciseDecimal(Z.ServerTime:GetServerTime() / 1000, 1)
  local cdTime = Z.Global.InsightShutdownCD
  if nowTime < lastOpenInsightTime + cdTime then
    Z.TipsVM.ShowTipsLang(700002)
  else
    local ret = worldproxy_.ReqInsight(cancelToken)
    if ret and ret ~= 0 then
      logError("closeInsight\229\188\130\229\184\184:{0}", ret)
    end
  end
end
local ret = {OpenInsight = openInsight, CloseInsight = closeInsight}
return ret
