local language2CultureMap = {
  [1] = "zh-CN",
  [2] = "en-US",
  [3] = "ja-JP",
  [4] = "zh-TW",
  [5] = "ko-KR"
}
local timeFormatTypeTable = {
  [E.TimeFormatType.YMDHMS] = {"F", "G"},
  [E.TimeFormatType.YMD] = {"D", "d"},
  [E.TimeFormatType.HMS] = {"T", "T"},
  [E.TimeFormatType.MD] = {"MD", "MD"}
}
local ticksFormatTime = function(tick, timeFormatType, isFull, isHideUTC)
  local curLangIdx = Z.LocalizationMgr:GetCurrentLanguage()
  local culture = language2CultureMap[curLangIdx + 1]
  if Z.SDKLogin.GetPlatform() == E.LoginPlatformType.TencentPlatform or Z.SDKLogin.GetPlatform() == E.LoginPlatformType.InnerPlatform then
    isHideUTC = true
  end
  local systemTimeZone = Panda.Util.ZTimeUtils.GetClienttSystemTimeZone()
  if Z.ServerTime.ServiceTimeZone == systemTimeZone then
    isHideUTC = true
  end
  local formatType = timeFormatTypeTable[timeFormatType][1]
  if not isFull then
    formatType = timeFormatTypeTable[timeFormatType][2]
  end
  if isHideUTC then
    return Panda.Util.ZTimeUtils.FormatTimestamp(tick, formatType, culture)
  end
  local utc = Panda.Util.ZTimeUtils.GetUTCByStamp(tick)
  return Panda.Util.ZTimeUtils.FormatTimestamp(tick, formatType, culture) .. utc
end
local tp2YMDHMS = function(timePoint)
  local timeTbl = os.date("*t", timePoint)
  return timeTbl
end
local formatToDHMS = function(second, showAll, number)
  second = math.floor(second)
  local timeStr = ""
  if showAll then
    local needShow = false
    local timeTable = {}
    local day = math.floor(second / 86400)
    if 0 < day then
      if number then
        table.insert(timeTable, tostring(day))
      else
        table.insert(timeTable, Lang("Day", {val = day}))
      end
      needShow = true
    end
    second = second % 86400
    local hour = math.floor(second / 3600)
    if 0 < hour or needShow then
      if number then
        table.insert(timeTable, string.format("%02d", hour))
      else
        table.insert(timeTable, Lang("Hour", {val = hour}))
      end
      needShow = true
    end
    second = second % 3600
    local minute = math.floor(second / 60)
    if minute <= 0 then
      minute = 0
    end
    if not number then
      if 0 < minute or needShow then
        table.insert(timeTable, minute .. Lang("Minute"))
      end
    else
      table.insert(timeTable, string.format("%02d", minute))
    end
    second = second % 60
    if second <= 0 then
      second = 0
    end
    if not number then
      if 0 < second or needShow then
        table.insert(timeTable, Lang("Second", {val = second}))
      end
    else
      table.insert(timeTable, string.format("%02d", second))
    end
    if number then
      timeStr = table.concat(timeTable, ":")
    else
      timeStr = table.concat(timeTable)
    end
  elseif 86400 <= second then
    local day = math.floor(second / 86400)
    local hour = math.floor((second - day * 86400) / 3600)
    if number then
      timeStr = string.format("%d:%02d", day, hour)
    else
      timeStr = Lang("DayAndHour", {
        item = {day = day, hour = hour}
      })
    end
  elseif 3600 <= second then
    local hour = math.floor(second / 3600)
    local min = math.floor((second - hour * 3600) / 60)
    if number then
      timeStr = string.format("%02d:%02d", hour, min)
    else
      timeStr = Lang("HourAndMinute", {
        item = {min = min, hour = hour}
      })
    end
  elseif 60 <= second then
    local min = math.floor(second / 60)
    local sec = math.floor(second % 60)
    if number then
      timeStr = string.format("%02d:%02d", min, sec)
    else
      timeStr = Lang("MinuteAndSecond", {
        item = {min = min, sec = sec}
      })
    end
  else
    second = math.floor(second)
    if number then
      timeStr = second
    else
      timeStr = Lang("Second", {val = second})
    end
  end
  return timeStr
end
local formatToHMSNum = function(second, showAll)
  second = math.floor(second)
  local timeStr = ""
  if showAll then
    local timeTable = {}
    local hour = math.floor(second / 3600)
    if 0 < hour then
      table.insert(timeTable, hour)
    end
    second = second % 3600
    local minute = math.floor(second / 60)
    if 0 < minute then
      table.insert(timeTable, minute)
    end
    second = second % 60
    if 0 < second then
      table.insert(timeTable, second)
    end
    timeStr = table.concat(timeTable, ":")
  end
  return timeStr
end
local ret = {
  TicksFormatTime = ticksFormatTime,
  Tp2YMDHMS = tp2YMDHMS,
  FormatToDHMS = formatToDHMS,
  FormatToHMSNum = formatToHMSNum
}
return ret
