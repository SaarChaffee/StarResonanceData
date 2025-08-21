local LifeWorkVM = {}

function LifeWorkVM.IsWorkUnlocked(proID)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  local curLevel = lifeProfessionVM.GetLifeProfessionLv(proID)
  local lifeWorkTableRow = Z.TableMgr.GetTable("LifeWorkTableMgr").GetRow(proID)
  if lifeWorkTableRow == nil then
    return false
  end
  return curLevel >= lifeWorkTableRow.NeedLevel
end

function LifeWorkVM.GetCurWorkingPro()
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork
  if not professionInfo then
    return 0
  end
  local lifeProfessionWorkInfo = professionInfo.lifeProfessionWorkInfo
  if not lifeProfessionWorkInfo then
    return 0
  end
  return lifeProfessionWorkInfo.lifeProfessionId
end

function LifeWorkVM.IsCurWorkingEnd(proID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork
  if not professionInfo then
    return false
  end
  local lifeProfessionWorkInfo = professionInfo.lifeProfessionWorkInfo
  if not lifeProfessionWorkInfo then
    return false
  end
  if lifeProfessionWorkInfo.lifeProfessionId ~= proID then
    return false
  end
  return lifeProfessionWorkInfo.endTime < Z.TimeTools.Now() / 1000
end

function LifeWorkVM.HasWorkingEnd()
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork
  if not professionInfo then
    return false
  end
  local lifeProfessionWorkInfo = professionInfo.lifeProfessionWorkInfo
  if not lifeProfessionWorkInfo then
    return false
  end
  if lifeProfessionWorkInfo.lifeProfessionId == 0 then
    return false
  end
  return lifeProfessionWorkInfo.endTime < Z.TimeTools.Now() / 1000
end

function LifeWorkVM.GetWorkStartEndTime(proID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork
  if not professionInfo then
    return 0, 0
  end
  local lifeProfessionWorkInfo = professionInfo.lifeProfessionWorkInfo
  if not lifeProfessionWorkInfo then
    return 0, 0
  end
  if lifeProfessionWorkInfo.lifeProfessionId ~= proID then
    return 0, 0
  end
  return lifeProfessionWorkInfo.beginTime, lifeProfessionWorkInfo.endTime
end

function LifeWorkVM.GetCurProWorkingCount(proID)
  local professionInfo = Z.ContainerMgr.CharSerialize.lifeProfessionWork
  if not professionInfo then
    return 0
  end
  local lifeProfessionWorkInfo = professionInfo.lifeProfessionWorkInfo
  if not lifeProfessionWorkInfo then
    return 0
  end
  if lifeProfessionWorkInfo.lifeProfessionId ~= proID then
    return 0
  end
  return lifeProfessionWorkInfo.count
end

function LifeWorkVM.CloseLifeWorkView()
  Z.UIMgr:CloseView("lifework_main")
end

function LifeWorkVM.OpenLifeWorkView(proID)
  Z.UIMgr:OpenView("lifework_main", {proID = proID})
  if LifeWorkVM.HasWorkingEnd() then
    LifeWorkVM.OpenWorkRewardView()
  end
end

function LifeWorkVM.OpenWorkRecordView()
  Z.UIMgr:OpenView("lifework_record_popup")
end

function LifeWorkVM.CloseWorkRecordView()
  Z.UIMgr:CloseView("lifework_record_popup")
end

function LifeWorkVM.OpenWorkRewardView()
  Z.UIMgr:OpenView("lifework_settle_window")
end

function LifeWorkVM.CloseWorkRewardView()
  Z.UIMgr:CloseView("lifework_settle_window")
end

function LifeWorkVM.AsyncRequsetWork(proID, count)
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  local ret = worldProxy.LifeProfessionStartWork(proID, count, lifeProfessionWorkData_.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function LifeWorkVM.AsyncRequsetWorkFast()
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  local ret = worldProxy.LifeProfessionWorkEarlyEnd(lifeProfessionWorkData_.CancelSource:CreateToken())
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeWorkVM.AsyncRequsetStopWork()
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  local ret = worldProxy.LifeProfessionStopWork(lifeProfessionWorkData_.CancelSource:CreateToken())
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
end

function LifeWorkVM.AsyncRequsetGetReward()
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  local ret = worldProxy.LifeProfessionWorkReward(lifeProfessionWorkData_.CancelSource:CreateToken())
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function LifeWorkVM.AsyncRequsetGetWorkHistory()
  local worldProxy = require("zproxy.world_proxy")
  local lifeProfessionWorkData_ = Z.DataMgr.Get("life_profession_work_data")
  local ret = worldProxy.GetLifeProfessionWorkHistoryInfo(lifeProfessionWorkData_.CancelSource:CreateToken())
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return
  end
  lifeProfessionWorkData_:SetRecordData(ret.workInfos)
end

function LifeWorkVM.GetLifeWorkCost(lifeWorkTableRow)
  if Z.EntityMgr.PlayerEnt == nil then
    return lifeWorkTableRow.Cost
  end
  local workCostRate = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrLifeProfessionWorkCostRate, E.ETempAttrType.TempAttrLifeProfession, lifeWorkTableRow.Id)
  local workCost = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrLifeProfessionWorkCost, E.ETempAttrType.TempAttrLifeProfession, lifeWorkTableRow.Id)
  return math.floor(lifeWorkTableRow.Cost * (1 - workCostRate / 10000) - workCost)
end

function LifeWorkVM.GetLifeWorkTime(lifeWorkTableRow)
  if Z.EntityMgr.PlayerEnt == nil then
    return lifeWorkTableRow.Time
  end
  local workTimeRate = Z.EntityMgr.PlayerEnt:GetTempAttrByType(E.TempAttrEffectType.TempAttrLifeProfessionWorkTime, E.ETempAttrType.TempAttrLifeProfession, lifeWorkTableRow.Id)
  return lifeWorkTableRow.Time * (1 - workTimeRate / 10000)
end

return LifeWorkVM
