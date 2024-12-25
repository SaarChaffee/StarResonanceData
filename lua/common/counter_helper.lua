local CounterHelper = {}

function CounterHelper.GetCounterLimitCount(counterId)
  local counterCfgData = Z.TableMgr.GetTable("CounterTableMgr").GetRow(counterId, true)
  if counterCfgData then
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
  return Z.TimeTools.GetTimeDescByTimerId(timerId)
end

return CounterHelper
