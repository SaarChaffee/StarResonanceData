local CounterHelper = {}

function CounterHelper.GetCounterLimitCount(counterId)
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(counterId, true)
  if counterCfgData then
    local limitCount = counterCfgData.Limit
    local accumulateLimit = counterCfgData.AccumulateLimit
    if accumulateLimit ~= 0 then
      local serverAccumulateLimit = 0
      if Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId] then
        serverAccumulateLimit = Z.ContainerMgr.CharSerialize.counterList.counterMap[counterId].accumulateLimit
      end
      accumulateLimit = math.max(serverAccumulateLimit, accumulateLimit)
      if limitCount > accumulateLimit then
        limitCount = accumulateLimit
      end
    end
    local monthlyCardVM = Z.VMMgr.GetVM("monthly_reward_card")
    if monthlyCardVM:GetIsBuyCurrentMonthCard() and counterCfgData.MonthCardLimit ~= 0 then
      return limitCount + counterCfgData.MonthCardLimit
    end
    return limitCount
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
  local isHideUTC = false
  if Z.SDKLogin.GetPlatform() == E.LoginPlatformType.TencentPlatform or Z.SDKLogin.GetPlatform() == E.LoginPlatformType.InnerPlatform then
    isHideUTC = true
  end
  local systemTimeZone = Panda.Util.ZTimeUtils.GetClienttSystemTimeZone()
  if Z.ServerTime.ServiceTimeZone == systemTimeZone then
    isHideUTC = true
  end
  if timeType == E.TimerType.Weekly and table.zcount(offsetDatas) == 1 then
    local weekStrRow = Z.Global.WeekText
    local weekDay = offsetDatas[1].day + 1
    if 7 < weekDay then
      weekDay = 1
    end
    local weekDayStr = Lang(weekStrRow[weekDay])
    local hourStr = Lang("clock", {
      hour = string.format("%02d", offsetDatas[1].hour)
    })
    local timeString = weekDayStr .. hourStr
    if not isHideUTC then
      local utc = Panda.Util.ZTimeUtils.GetUTCByStamp(Z.TimeTools.Now(), false)
      timeString = weekDayStr .. hourStr .. utc
    end
    desc = Lang("TimeRefreshInterval", {val = timeString})
  end
  return desc
end

return CounterHelper
