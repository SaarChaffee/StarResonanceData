local LanguageTypeIndex = {
  [-1] = "CN",
  [0] = "EN",
  [1] = "JA",
  [2] = "KO"
}
local CONST_DAY_SEC = 86400
local functionOpenTimeType = {
  YearMonthDay = 1,
  DailyCycle = 2,
  MonthCycle = 3,
  WeekCycle = 4
}
local now = function()
  return Z.ServerTime:GetServerTime()
end
local getTimeZone = function()
  local now = now()
  return os.difftime(now, os.time(os.date("!*t", now))) / 3600
end
local timePastWithoutFormat = function(pastTime)
  local timeLeft = math.floor((now() - pastTime) / 60)
  if timeLeft < 60 then
  else
    timeLeft = math.floor(timeLeft / 60)
    if timeLeft < 60 then
    else
      timeLeft = math.floor(timeLeft / 24)
    end
  end
  return timeLeft
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
local s2dhFormat = function(second)
  local hours = second / 3600
  local days = math.modf(hours / 24)
  local remainderHours = math.ceil(math.fmod(hours, 24))
  return string.format("%02d:%02d", days, remainderHours)
end
local s2dh = function(second)
  local hours = second / 3600
  local days = math.modf(hours / 24)
  local remainderHours = math.modf(hours % 24)
  return days, remainderHours
end
local s2hmsFormat = function(second)
  local all = 0
  if second <= 0 then
    all = 0
  else
    all = math.floor(second + 0.5)
  end
  local hours = math.floor(all / 3600)
  all = all - hours * 3600
  local minutes = math.floor(all / 60)
  local seconds = all - minutes * 60
  return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end
local s2hms = function(second)
  local all = 0
  if second <= 0 then
    all = 0
  else
    all = math.floor(second + 0.5)
  end
  local hours = math.floor(all / 3600)
  all = all - hours * 3600
  local minutes = math.floor(all / 60)
  local seconds = all - minutes * 60
  return hours, minutes, seconds
end
local tp2YMDHMS = function(timePoint)
  local timeTbl = os.date("*t", timePoint)
  return timeTbl
end
local s2msFormat = function(second)
  local all = 0
  if 0 < second then
    all = math.floor(second + 0.5)
  end
  local min = math.floor(all / 60)
  local sec = all - min * 60
  return string.format("%02d:%02d", min, sec)
end
local s2ms = function(second)
  local all = 0
  if 0 < second then
    all = math.floor(second + 0.5)
  end
  local min = math.floor(all / 60)
  local sec = all - min * 60
  return min, sec
end
local s2hmFormat = function(second)
  local all = 0
  if 0 < second then
    all = math.floor(second + 0.5)
  end
  local hours = math.floor(all / 3600)
  all = all - hours * 3600
  local min = math.floor(all / 60)
  return string.format("%02d:%02d", hours, min)
end
local s2hm = function(second)
  local all = 0
  if 0 < second then
    all = math.floor(second + 0.5)
  end
  local hours = math.floor(all / 3600)
  all = all - hours * 3600
  local min = math.floor(all / 60)
  return hours, min
end
local getLocalShowRuleTableRow = function()
  local tableMgr = Z.TableMgr.GetTable("LocalShowRuleMgr")
  local curLangIdx = Z.LocalizationMgr:GetCurrentLanguage()
  local table = tableMgr.GetRow(curLangIdx + 1)
  return table
end
local formatTime = function(tick, formatType)
  local TableRow = getLocalShowRuleTableRow()
  if TableRow == nil then
    return nil
  end
  local format = TableRow[formatType]
  return Panda.Util.ZTimeUtils.FormatTimestamp(tick, format)
end
local formatTimeToYMDHMS = function(tick)
  local formaType = "YMD"
  local YMD = formatTime(tick, formaType)
  formaType = "HMS"
  local HMS = formatTime(tick, formaType)
  return string.zconcat(YMD, " ", HMS)
end
local formatTimeToYMD = function(tick)
  local formaType = "YMD"
  return formatTime(tick, formaType)
end
local formatTimeToMD = function(tick)
  local formaType = "MD"
  return formatTime(tick, formaType)
end
local formatTimeToHMS = function(tick)
  local formaType = "HMS"
  return formatTime(tick, formaType)
end
local formatTimeToHM = function(tick)
  local formaType = "HM"
  return formatTime(tick, formaType)
end
local formatToYMDtoYMD = function(tick1, tick2)
  local str1 = formatTimeToYMD(tick1)
  local str2 = formatTimeToYMD(tick2)
  return string.zconcat(str1, "-", str2)
end
local formatToMDtoMD = function(tick1, tick2)
  local str1 = formatTimeToMD(tick1)
  local str2 = formatTimeToMD(tick2)
  return string.zconcat(str1, "-", str2)
end
local formatToDHM = function(second)
  local timeStr
  if 86400 <= second then
    local day = math.floor(second / 86400)
    local hour = math.floor((second - day * 86400) / 3600)
    timeStr = Lang("DayAndHour", {
      item = {day = day, hour = hour}
    })
  elseif 3600 <= second then
    local hour = math.floor(second / 3600)
    local min = math.floor((second - hour * 3600) / 60)
    timeStr = Lang("HourAndMinute", {
      item = {min = min, hour = hour}
    })
  else
    local min = math.floor(second / 60)
    timeStr = min .. Lang("Minute")
  end
  return timeStr
end
local formatToDHMS = function(second, ignoreMin)
  local timeStr
  if 86400 <= second then
    local day = math.floor(second / 86400)
    timeStr = Lang("Day", {val = day})
  elseif 3600 <= second then
    local hour = math.floor(second / 3600)
    timeStr = Lang("Hour", {val = hour})
  elseif ignoreMin and second < 60 then
    timeStr = Lang("Second", {val = second})
  else
    local min = math.floor(second / 60)
    local sec = second - min * 60
    timeStr = Lang("MinuteAndSecond", {
      item = {min = min, sec = sec}
    })
  end
  return timeStr
end
local formatToDHMSStr = function(second, ignoreMin)
  local timeStr
  if 86400 <= second then
    local day = math.floor(second / 86400)
    local hour = math.floor((second - day * 86400) / 3600)
    timeStr = Lang("DayAndHour", {
      item = {day = day, hour = hour}
    })
  elseif 3600 <= second then
    local hour = math.floor(second / 3600)
    local min = math.floor((second - hour * 3600) / 60)
    timeStr = Lang("HourAndMinute", {
      item = {min = min, hour = hour}
    })
  elseif ignoreMin and second < 60 then
    timeStr = Lang("Second", {val = second})
  else
    local min = math.floor(second / 60)
    local sec = math.floor(second - min * 60)
    timeStr = Lang("MinuteAndSecond", {
      item = {min = min, sec = sec}
    })
  end
  return timeStr
end
local formatToHMS = function(totalSeconds)
  local hour = math.floor(totalSeconds / 3600)
  local min = math.floor((totalSeconds - hour * 3600) / 60)
  local sec = totalSeconds - hour * 3600 - min * 60
  return Lang("TimeFormatHMS", {
    hour = hour,
    min = min,
    sec = sec
  })
end
local formatCdTime = function(cdTime)
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
local timeString2TpCache = {}
local format2Tp = function(timeString)
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
local getCurDayStartTime = function()
  local currentDate = os.date("*t", math.floor(now() / 1000))
  currentDate.hour = 0
  currentDate.min = 0
  currentDate.sec = 0
  return os.time(currentDate)
end
local getCurWeekStartTime = function()
  local curStamp = math.floor(now() / 1000)
  local currentDayOfWeek = tonumber(os.date("%w", curStamp))
  if currentDayOfWeek == 0 then
    currentDayOfWeek = 7
  end
  local beginningOfWeek = curStamp - (currentDayOfWeek - 1) * 24 * 60 * 60
  local beginningOfDay = os.date("*t", beginningOfWeek)
  beginningOfDay.hour = 0
  beginningOfDay.min = 0
  beginningOfDay.sec = 0
  return os.time(beginningOfDay)
end
local getWeekStartTime = function(timestamp)
  local dateTable = os.date("*t", timestamp)
  local weekDay = dateTable.wday
  local weekStartOffset = (weekDay - 1) * 86400
  local weekStartTimestamp = timestamp - weekStartOffset - dateTable.hour * 3600 - dateTable.min * 60 - dateTable.sec
  return weekStartTimestamp
end
local getCurMonthStartTime = function()
  local currentDate = os.date("*t", now())
  currentDate.day = 1
  currentDate.hour = 0
  currentDate.min = 0
  currentDate.sec = 0
  local startOfMonthTimestamp = os.time(currentDate)
  return startOfMonthTimestamp
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
local timerParseCache = {}
local timerTabaleTimeParse = function(timer)
  if timer == nil or timer == "" then
    return
  end
  if timerParseCache[timer] then
    return timerParseCache[timer]
  end
  local YMD = string.split(string.sub(timer, 1, 10), "-")
  local HMS = string.split(string.sub(timer, -8), ":")
  local Timestamp = os.time({
    year = tonumber(YMD[1]),
    month = tonumber(YMD[2]),
    day = tonumber(YMD[3]),
    hour = tonumber(HMS[1]),
    min = tonumber(HMS[2]),
    sec = tonumber(HMS[3])
  })
  timerParseCache[timer] = Timestamp
  return Timestamp
end
local getLeftTimeInSpecifiedTimeByYearMonthDay = function(timerConfig)
  local now = math.floor(now() / 1000)
  if timerConfig.starttime and timerConfig.endtime then
    local startTimestamp = timerTabaleTimeParse(timerConfig.starttime)
    local endTimestamp = timerTabaleTimeParse(timerConfig.endtime)
    if not endTimestamp then
      return 0
    end
    if now >= startTimestamp and now < endTimestamp then
      return endTimestamp - now
    end
    if now < startTimestamp then
      return -1
    end
    return 0
  end
  return 0
end
local getTimeLeftInSpecifiedTime = function(Id)
  local nowTime = math.floor(now() / 1000)
  local hasend, startTime, endTime = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTime(Id, nil, nil, nil)
  if not hasend then
    return -1, startTime / 1000 - nowTime
  end
  return endTime / 1000 - nowTime, startTime / 1000 - nowTime
end
local checkTimeInSpecifiedTime = function(Id)
  local nowTime = math.floor(now() / 1000)
  local hasend, startTime, endTime = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTime(Id, nil, nil, nil)
  if not hasend then
    return true
  end
  if nowTime >= startTime / 1000 and nowTime <= endTime / 1000 then
    return true
  end
  return false
end
local getTimeDescByTimerId = function(Id)
  local timerConfig = Z.TableMgr.GetTable("TimerTableMgr").GetRow(Id)
  if timerConfig == nil then
    return ""
  end
  local totalOffsetTime = 0
  for i, v in ipairs(timerConfig.offset) do
    totalOffsetTime = totalOffsetTime + v
  end
  local timeDesc
  if timerConfig.type == functionOpenTimeType.YearMonthDay then
    return timerConfig.starttime .. "-" .. timerConfig.endtime
  elseif timerConfig.type == functionOpenTimeType.DailyCycle then
    timeDesc = s2hmsFormat(totalOffsetTime)
    return Lang("TimeRefreshDay", {val = timeDesc})
  elseif timerConfig.type == functionOpenTimeType.MonthCycle then
    local dayNum = math.ceil(totalOffsetTime / 86400)
    local leftNum = totalOffsetTime - (dayNum - 1) * 86400
    if 0 < dayNum then
      leftNum = 0
    end
    local monthDayDeasc = Lang("MonthDayDesc", {val = dayNum})
    timeDesc = string.zconcat(monthDayDeasc, " ", s2hmsFormat(leftNum))
    return Lang("TimeRefreshMonth", {val = timeDesc})
  elseif timerConfig.type == functionOpenTimeType.WeekCycle then
    local dayNum = math.ceil(totalOffsetTime / 86400)
    local leftNum = totalOffsetTime - (dayNum - 1) * 86400
    if leftNum < 0 then
      leftNum = 0
    end
    local dayDesc = Lang("WeekNum" .. dayNum)
    timeDesc = string.zconcat(dayDesc, " ", s2hmsFormat(leftNum))
    return Lang("TimeRefreshWeek", {val = timeDesc})
  end
  return timerConfig.command
end
local getDailyCycleTimeDataByTime = function(time)
  local timerId = Z.Global.AwardNextLevelDailyCount
  if timerId == 0 then
    return nil
  end
  local timerConfig = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timerId)
  local offsetTimes = timerConfig.offset
  if offsetTimes and 1 <= #offsetTimes then
    local curDayTimeData = os.date("*t", time)
    curDayTimeData.hour = 0
    curDayTimeData.min = 0
    curDayTimeData.sec = 0
    local curDayTimeTp = os.time(curDayTimeData)
    if time - curDayTimeTp < offsetTimes[1] then
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
local formatToWDHM = function(timeData)
  local weekStrRow = Z.Global.WeekText
  local weekDayStr = weekStrRow[timeData.wday]
  local hour = timeData.hour
  local min = timeData.min
  return string.format("%s %02d:%02d", weekDayStr, hour, min)
end
local getStartTimeByTimerId = function(timerId, param)
  if param == nil then
    param = 0
  end
  return Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerStartEndTimeByOffset(timerId, param, nil, nil)
end
local getCurTimeIsExceed = function(timerId)
  local startTime, _ = getStartTimeByTimerId(timerId) / 1000
  local nowTime = math.floor(now() / 1000)
  local sub = startTime - nowTime
  return sub < 0, sub
end
local getCycleTimeDataByTimeId = function(timerId)
  local startTime = {}
  local endTime = {}
  local timerConfig = Z.TableMgr.GetTable("TimerTableMgr").GetRow(timerId)
  for i = 1, #timerConfig.offset do
    local startT, endT = getStartTimeByTimerId(timerId, i - 1)
    table.insert(startTime, os.date("*t", startT / 1000))
    table.insert(endTime, os.date("*t", endT / 1000))
  end
  return startTime, endTime
end
local getCycleEndTimeByTimeId = function(timerId)
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
local getCfgTimerItem = function(id)
  return Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItemValue(id, nil, nil, nil)
end
local ret = {
  Now = now,
  GetTimeZone = getTimeZone,
  TimePastWithoutFormat = timePastWithoutFormat,
  CheckIsSameDay = checkIsSameDay,
  S2HMSFormat = s2hmsFormat,
  S2HMS = s2hms,
  S2DHFormat = s2dhFormat,
  S2DH = s2dh,
  S2HMFormat = s2hmFormat,
  S2HM = s2hm,
  FormatTimeToYMDHMS = formatTimeToYMDHMS,
  FormatTimeToYMD = formatTimeToYMD,
  FormatTimeToMD = formatTimeToMD,
  FormatTimeToHMS = formatTimeToHMS,
  FormatTimeToHM = formatTimeToHM,
  FormatToYMDtoYMD = formatToYMDtoYMD,
  FormatToMDtoMD = formatToMDtoMD,
  Tp2YMDHMS = tp2YMDHMS,
  S2MS = s2ms,
  S2MSFormat = s2msFormat,
  FormatToDHM = formatToDHM,
  FormatCdTime = formatCdTime,
  Format2Tp = format2Tp,
  GetDayEndTime = getDayEndTime,
  DiffTime = diffTime,
  FormatToDHMS = formatToDHMS,
  GetCurDayEndTime = getCurDayEndTime,
  CheckTimeInSpecifiedTime = checkTimeInSpecifiedTime,
  GetTimeDescByTimerId = getTimeDescByTimerId,
  GetDailyCycleTimeDataByTime = getDailyCycleTimeDataByTime,
  TimerTabaleTimeParse = timerTabaleTimeParse,
  TimerTabaleOffsetParse = timerTabaleOffsetParse,
  GetWeekStartTime = getWeekStartTime,
  GetTimeLeftInSpecifiedTime = getTimeLeftInSpecifiedTime,
  FormatToWDHM = formatToWDHM,
  FormatToDHMSStr = formatToDHMSStr,
  FormatToHMS = formatToHMS,
  GetStartTimeByTimerId = getStartTimeByTimerId,
  GetCurTimeIsExceed = getCurTimeIsExceed,
  GetCycleTimeDataByTimeId = getCycleTimeDataByTimeId,
  GetCycleEndTimeByTimeId = getCycleEndTimeByTimeId,
  CheckIsInTimeByTimeId = checkIsInTimeByTimeId,
  GetCfgTimerItem = getCfgTimerItem,
  FunctionOpenTimeType = functionOpenTimeType
}
return ret
