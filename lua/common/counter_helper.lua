local CounterHelper = {}

function CounterHelper.GetCounterLimitCount(counterId)
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(counterId, true)
  if counterCfgData then
    local monthlyCardVM = Z.VMMgr.GetVM("monthly_reward_card")
    if monthlyCardVM:GetIsBuyCurrentMonthCard() and counterCfgData.MonthCardLimit ~= 0 then
      return counterCfgData.Limit + counterCfgData.MonthCardLimit
    end
    return counterCfgData.Limit
  end
  return 0
end

function CounterHelper.GetOwnCount(counterId)
  if Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId] then
    return Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId].counter
  end
  return 0
end

function CounterHelper.GetCounterResidueLimitCount(counterId, limitCount)
  local residueLimitCount = limitCount - CounterHelper.GetOwnCount(counterId)
  if residueLimitCount < 0 then
    residueLimitCount = 0
  end
  return residueLimitCount
end

function CounterHelper.GetResidueLimitCountByCounterId(counterId)
  local limitCount = CounterHelper.GetCounterLimitCount(counterId)
  return CounterHelper.GetCounterResidueLimitCount(counterId, limitCount)
end

function CounterHelper.GetCounterTimerId(counterId)
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(counterId, true)
  if counterCfgData then
    return counterCfgData.TimeTableId
  end
  return 0
end

function CounterHelper.GetCounterTimerDes(counterId)
  local timerId = CounterHelper.GetCounterTimerId(counterId)
  local timeType, offsetDatas = Z.TimeTools.GetTimeOffsetInfoByTimeId(timerId)
  local desc = ""
  if timeType == E.TimerType.Weekly and table.zcount(offsetDatas) == 1 then
    local weekStrRow = Z.Global.WeekText
    local weekDay = offsetDatas[1].day + 1
    if 7 < weekDay then
      weekDay = 1
    end
    local weekDayStr = weekStrRow[weekDay]
    local hourStr = Lang("clock", {
      hour = offsetDatas[1].hour
    })
    desc = Lang("TimeRefreshInterval", {
      val = weekDayStr .. hourStr
    })
  end
  return desc
end

return CounterHelper
