local CONST_DAY_SEC = 86400
local now = function()
  return Z.ServerTime:GetServerTime()
end
local checkIsSameDay = function(firstTime, secondTime)
  if firstTime == nil or secondTime == nil then
    return false
  end
  local allResetTime = 0
  local startTime = os.date("*t", firstTime)
  local startzerotime = firstTime - startTime.hour * 3600 - startTime.min * 60 - startTime.sec + allResetTime * 3600
  if allResetTime > startTime.hour then
    startzerotime = startzerotime - CONST_DAY_SEC
  end
  local nowTime = os.date("*t", secondTime)
  local nowZeroTime = secondTime - nowTime.hour * 3600 - nowTime.min * 60 - nowTime.sec + allResetTime * 3600
  if allResetTime > nowTime.hour then
    nowZeroTime = nowZeroTime - CONST_DAY_SEC
  end
  if startzerotime == nowZeroTime then
    return true
  end
  return false
end
local timeString2TpCache = {}
local timeString2Stamp = function(timeString)
  if timeString == nil or timeString == "" then
    return 0
  end
  if timeString2TpCache[timeString] then
    return timeString2TpCache[timeString]
  end
  local time = Panda.Util.ZTimeUtils.Format2Tp(timeString)
  timeString2TpCache[timeString] = time
  return time
end
local getDayEndTime = function(startTime_)
  local t = math.floor(Z.TimeTools.Now() / 1000) - startTime_
  if t <= 0 then
    return 86400
  end
  local sec = t % 86400
  if sec == 0 then
    return 86400
  end
  return 86400 - sec
end
local getCurDayEndTime = function()
  local curStamp = math.floor(now() / 1000)
  local curDayDate = os.date("*t", curStamp)
  local cDateTodayTime = os.time({
    year = curDayDate.year,
    month = curDayDate.month,
    day = curDayDate.day,
    hour = 24,
    min = 0,
    sec = 0
  })
  return cDateTodayTime - curStamp
end
local getWeekStartTime = function(timestamp)
  local dateTable = os.date("*t", timestamp)
  local daysToMonday = dateTable.wday == 1 and 6 or dateTable.wday - 2
  local weekStartOffset = daysToMonday * 86400
  local weekStartTimestamp = timestamp - weekStartOffset - dateTable.hour * 3600 - dateTable.min * 60 - dateTable.sec
  return weekStartTimestamp
end
local diffTime = function(leftTime, rightTime)
  if leftTime == nil then
    logError("leftTime is nil")
    return 0
  end
  if rightTime == nil then
    logError("rightTime is nil")
    return 0
  end
  if type(leftTime) ~= "number" then
    logError("leftTime is not number")
    return 0
  end
  if type(rightTime) ~= "number" then
    logError("rightTime is not number")
    return 0
  end
  return leftTime - rightTime
end
local offsetParaseCache = {}
local timerTabaleOffsetParse = function(offset)
  if offset == nil or offset == "" then
    return {}
  end
  if offsetParaseCache[offset] then
    return offsetParaseCache[offset].offsetTimeSec, offsetParaseCache[offset].totalSec
  end
  if type(offset) == "number" then
    return {offset}, offset
  end
  local offsetTimeSec = {}
  local totalSec = 0
  local offsetArr = string.split(offset, "=")
  for _, value in ipairs(offsetArr) do
    for number, letter in string.gmatch(value, "(%d+)([dhms])") do
      local sec = 0
      if letter == "d" then
        sec = sec + 86400 * number
      elseif letter == "h" then
        sec = sec + 3600 * number
      elseif letter == "m" then
        sec = sec + 60 * number
      elseif letter == "s" then
        sec = sec + number
      end
      totalSec = totalSec + sec
      table.insert(offsetTimeSec, sec)
    end
  end
  offsetParaseCache[offset] = {offsetTimeSec = offsetTimeSec, totalSec = totalSec}
  return offsetTimeSec, totalSec
end
local getLeftTimeByTimerId = function(Id)
  local nowTime = math.floor(now() / 1000)
  local hasend, startTime, endTime = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTime(Id, nil, nil, nil)
  if not hasend then
    return -1, startTime - nowTime
  end
  return endTime - nowTime, startTime - nowTime
end
local getTimeOffsetInfoByTimeId = function(timerId)
  local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(timerId)
  if not timerConfigItem then
    return ""
  end
  local timerType = timerConfigItem.TimerType
  local offsetDatas = {}
  if timerType == E.TimerType.Daily then
    for i = 0, timerConfigItem.Offset.count - 1 do
      local offsetData = {}
      offsetData.day = 0
      offsetData.hour = math.floor(timerConfigItem.Offset[i] / 3600)
      local second = timerConfigItem.Offset[i] % 3600
      local minute = math.floor(second / 60)
      offsetData.minute = minute
      table.insert(offsetDatas, offsetData)
    end
    return timerType, offsetDatas
  end
  if timerType == E.TimerType.Monthly or timerType == E.TimerType.Weekly then
    for i = 0, timerConfigItem.Offset.count - 1 do
      local dayNum = math.ceil(timerConfigItem.Offset[i] / 86400)
      local leftNum = timerConfigItem.Offset[i] - (dayNum - 1) * 86400
      local offsetData = {}
      offsetData.day = dayNum
      offsetData.hour = math.floor(leftNum / 3600)
      local second = leftNum % 3600
      local minute = math.floor(second / 60)
      offsetData.minute = minute
      table.insert(offsetDatas, offsetData)
    end
    return timerType, offsetDatas
  end
  return timerType, offsetDatas
end
local getTimeDescByTimerId = function(Id)
  local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(Id)
  if not timerConfigItem then
    return ""
  end
  local timerType = timerConfigItem.TimerType
  local timeDesc = ""
  if timerType == E.TimerType.FixedTime then
    local startStr = Z.TimeFormatTools.TicksFormatTime(timerConfigItem.StartTime, E.TimeFormatType.YMDHMS)
    local endStr = Z.TimeFormatTools.TicksFormatTime(timerConfigItem.EndTime, E.TimeFormatType.YMDHMS)
    return startStr .. "-" .. endStr
  elseif timerType == E.TimerType.Daily then
    timeDesc = ""
    for i = 0, timerConfigItem.Offset.count - 1 do
      local singleTimeDesc = Z.TimeFormatTools.FormatToDHMS(timerConfigItem.Offset[i], true, true)
      if timeDesc == "" then
        timeDesc = singleTimeDesc
      else
        timeDesc = string.format("%s\227\128\129%s", timeDesc, singleTimeDesc)
      end
    end
    return Lang("TimeRefreshDay", {val = timeDesc})
  elseif timerType == E.TimerType.Monthly then
    timeDesc = ""
    for i = 0, timerConfigItem.Offset.count - 1 do
      local dayNum = math.ceil(timerConfigItem.Offset[i] / 86400)
      local leftNum = timerConfigItem.Offset[i] - (dayNum - 1) * 86400
      local monthDayDeasc = Lang("MonthDayDesc", {val = dayNum})
      local singleTimeDesc = string.zconcat(monthDayDeasc, " ", Z.TimeFormatTools.FormatToDHMS(leftNum, true, true))
      if timeDesc == "" then
        timeDesc = singleTimeDesc
      else
        timeDesc = string.format("%s\227\128\129%s", timeDesc, singleTimeDesc)
      end
    end
    return Lang("TimeRefreshMonth", {val = timeDesc})
  elseif timerType == E.TimerType.Weekly then
    timeDesc = ""
    for i = 0, timerConfigItem.Offset.count - 1 do
      local dayNum = math.ceil(timerConfigItem.Offset[i] / 86400)
      local leftNum = timerConfigItem.Offset[i] - (dayNum - 1) * 86400
      local dayDesc = Lang("WeekNum" .. dayNum)
      local singleTimeDesc = string.zconcat(dayDesc, " ", Z.TimeFormatTools.FormatToDHMS(leftNum, true, true))
      if timeDesc == "" then
        timeDesc = singleTimeDesc
      else
        timeDesc = string.format("%s\227\128\129%s", timeDesc, singleTimeDesc)
      end
    end
    return Lang("TimeRefreshWeek", {val = timeDesc})
  elseif timerType == E.TimerType.Interval then
    timeDesc = ""
    for i = 0, timerConfigItem.Offset.count - 1 do
      local singleTimeDesc = Z.TimeFormatTools.FormatToDHMS(timerConfigItem.Offset[i], true)
      if timeDesc == "" then
        timeDesc = singleTimeDesc
      else
        timeDesc = string.format("%s\227\128\129%s", timeDesc, singleTimeDesc)
      end
    end
    return Lang("TimeRefreshInterval", {val = timeDesc})
  end
  return ""
end
local getDailyCycleTimeDataByTime = function(time, timerId)
  if timerId == 0 then
    return nil
  end
  local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(timerId)
  local offsetTimes = timerConfigItem.Offset
  if offsetTimes and offsetTimes.count >= 1 then
    local curDayTimeData = os.date("*t", time)
    curDayTimeData.hour = 0
    curDayTimeData.min = 0
    curDayTimeData.sec = 0
    local curDayTimeTp = os.time(curDayTimeData)
    if time - curDayTimeTp < offsetTimes[0] then
      local lastdayTimeData = os.date("*t", time - 86400)
      lastdayTimeData.hour = 0
      lastdayTimeData.min = 0
      lastdayTimeData.sec = 0
      return lastdayTimeData
    else
      return curDayTimeData
    end
  end
  return nil
end
local getStartEndTimeByTimerId = function(timerId, param)
  if param == nil then
    param = 0
  end
  return Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTimeByOffset(timerId, param, nil, nil)
end
local getCurTimeIsExceed = function(timerId)
  local startTime = getStartEndTimeByTimerId(timerId)
  local nowTime = math.floor(now() / 1000)
  local sub = startTime - nowTime
  return sub < 0, sub
end
local getCycleTimeListByTimeId = function(timerId)
  local startTime = {}
  local endTime = {}
  local timerInfo = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(timerId)
  if timerInfo == nil then
    return 0, 0
  end
  for i = 0, timerInfo.Offset.count - 1 do
    local startT, endT = getStartEndTimeByTimerId(timerId, i)
    table.insert(startTime, os.date("*t", startT))
    table.insert(endTime, os.date("*t", endT))
  end
  return startTime, endTime
end
local getCycleStartEndTimeByTimeId = function(timerId)
  local hasend, startTime, endTime = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTime(timerId, nil, nil, nil)
  return hasend, startTime, endTime
end
local checkIsInTimeByTimeId = function(timerId, curTime)
  local time = 0
  if curTime ~= nil then
    time = curTime
  end
  return Z.DIServiceMgr.ZCfgTimerService:IsInTimeValid(timerId, time)
end
local getWholeStartEndTimeByTimerId = function(id)
  return Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItemValue(id, nil, nil, nil)
end
local getCdTimeByEndStamp = function(cdTime)
  local serverTime = Z.ServerTime:GetServerTime()
  local diffTime = (cdTime - serverTime) / 1000
  if 0 < diffTime then
    local day = math.floor(diffTime / 86400)
    local hours = math.floor(diffTime / 3600)
    local min = math.floor(diffTime / 60)
    local sec = string.format("%.1f", diffTime)
    local time = {
      day = day,
      hours = hours,
      min = min,
      sec = sec
    }
    return time
  end
  return nil
end
local ret = {
  Now = now,
  CheckIsSameDay = checkIsSameDay,
  GetTimeOffsetInfoByTimeId = getTimeOffsetInfoByTimeId,
  GetCdTimeByEndStamp = getCdTimeByEndStamp,
  TimeString2Stamp = timeString2Stamp,
  DiffTime = diffTime,
  GetDayEndTime = getDayEndTime,
  GetCurDayEndTime = getCurDayEndTime,
  GetWeekStartTime = getWeekStartTime,
  GetTimeDescByTimerId = getTimeDescByTimerId,
  GetDailyCycleTimeDataByTime = getDailyCycleTimeDataByTime,
  TimerTabaleOffsetParse = timerTabaleOffsetParse,
  GetLeftTimeByTimerId = getLeftTimeByTimerId,
  GetStartEndTimeByTimerId = getStartEndTimeByTimerId,
  GetCurTimeIsExceed = getCurTimeIsExceed,
  GetCycleTimeListByTimeId = getCycleTimeListByTimeId,
  GetCycleStartEndTimeByTimeId = getCycleStartEndTimeByTimeId,
  CheckIsInTimeByTimeId = checkIsInTimeByTimeId,
  GetWholeStartEndTimeByTimerId = getWholeStartEndTimeByTimerId
}
return ret
