local refreshSeasonData = function(seasonId)
  logGreen("[Season] \229\189\147\229\137\141\232\181\155\229\173\163Id: " .. seasonId)
  local seasonData = Z.DataMgr.Get("season_data")
  seasonData.CurSeasonId = seasonId
  local seasonAchievement = Z.DataMgr.Get("season_achievement_data")
  seasonAchievement:SetSeason(seasonId)
  local seasonCultivateData = Z.DataMgr.Get("season_cultivate_data")
  seasonCultivateData:SetSeason(seasonId)
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  seasonTitleData:SetCurSeasonId(seasonId)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  recommendedPlayData:SetSeasonId(seasonId)
  if seasonId ~= 0 then
    local seasonGlobalTableMgr = Z.TableMgr.GetTable("SeasonGlobalTableMgr")
    local seasonGlobalTableRow = seasonGlobalTableMgr.GetRow(seasonData.CurSeasonId)
    if seasonGlobalTableRow then
      seasonData.MaxEquipLevel = seasonGlobalTableRow.MaxEquipLevel
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.SeasonIdChange)
end
local getCurrentSeasonId = function()
  local seasonData = Z.DataMgr.Get("season_data")
  return seasonData.CurSeasonId
end
local getCurSeasonTimeShow = function()
  local seasonName, seasonTimeStr
  local seasonData = Z.DataMgr.Get("season_data")
  local seasonGlobalRow = Z.TableMgr.GetTable("SeasonGlobalTableMgr").GetRow(seasonData.CurSeasonId)
  if seasonGlobalRow then
    seasonName = seasonGlobalRow.SeasonName
    local timerCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(seasonGlobalRow.SeasonTimeId)
    if timerCfg then
      local startTimestamp = Z.TimeTools.TimerTabaleTimeParse(timerCfg.starttime)
      local endTimestamp = Z.TimeTools.TimerTabaleTimeParse(timerCfg.endtime)
      local startTimeData = Z.TimeTools.Tp2YMDHMS(math.floor(startTimestamp))
      local endTimeData = Z.TimeTools.Tp2YMDHMS(math.floor(endTimestamp))
      seasonTimeStr = string.format("%d.%d.%d ~ %d.%d.%d", startTimeData.year, startTimeData.month, startTimeData.day, endTimeData.year, endTimeData.month, endTimeData.day)
    end
  end
  return seasonName, seasonTimeStr
end
local openSeasonMainView = function(id, subId)
  local data = Z.DataMgr.Get("season_data")
  local pageIndex = data:GetPageSortByFuncId(tonumber(id))
  data:SetCurShowPage(pageIndex)
  data:SetSubPageId(tonumber(subId))
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "season_main", function()
        Z.UIMgr:OpenView("season_main")
      end)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local closeSeasonMainView = function()
  Z.UIMgr:CloseView("season_main")
end
local openSeasonActivityView = function(activityId)
  local data = Z.DataMgr.Get("season_data")
  data:SetCurShowPage(2)
  data:SetSeasonActFuncId(activityId and tonumber(activityId) or 0)
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "season_main", function()
        Z.UIMgr:OpenView("season_main")
      end)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local getSeasonPagesIndex = function()
  local ids = {}
  local data = Z.DataMgr.Get("season_data")
  local pages = data:GetAllPages()
  local switchVM = Z.VMMgr.GetVM("switch")
  for i = 1, #pages do
    if switchVM.CheckFuncSwitch(pages[i]) then
      ids[#ids + 1] = i
    end
  end
  return ids
end
local getCurChoosePage = function()
  return Z.DataMgr.Get("season_data"):GetCurShowPage()
end
local asyncGetCurSeason = function()
  Z.CoroUtil.create_coro_xpcall(function()
    local seasonData = Z.DataMgr.Get("season_data")
    local proxy = require("zproxy.world_proxy")
    local ret = proxy.GetCurSeason(seasonData.CancelSource:CreateToken())
    if ret.errCode == 0 then
      local planetData = Z.DataMgr.Get("planetmemory_data")
      planetData:SetSeasonData(ret.seasonId, ret.day)
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  end)()
end
local getSeasonByTime = function(time)
  if time == nil then
    time = Z.TimeTools.Now() / 1000
  end
  local seasonData = Z.DataMgr.Get("season_data")
  for seasonId, cfg in pairs(seasonData.SeasonGlobalTableDatas) do
    local seasonTimeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(cfg.SeasonTimeId)
    local startTime = Z.TimeTools.TimerTabaleTimeParse(seasonTimeCfg.starttime)
    local endTime = Z.TimeTools.TimerTabaleTimeParse(seasonTimeCfg.endtime)
    if time >= startTime and time <= endTime then
      local diffTime = time - startTime
      local day = math.ceil(diffTime / 3600 / 24)
      return seasonId, day
    end
  end
  return nil, nil
end
local getSeasonStartEndTime = function(seasonId)
  local now = Z.TimeTools.Now() / 1000
  if seasonId == nil then
    seasonId = getSeasonByTime(now)
  end
  if seasonId == nil then
    return nil, nil
  end
  local seasonCfg = Z.TableMgr.GetTable("SeasonGlobalTableMgr").GetRow(seasonId)
  if seasonCfg then
    local seasonTimeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(seasonCfg.SeasonTimeId)
    local startTime = Z.TimeTools.TimerTabaleTimeParse(seasonTimeCfg.starttime)
    local endTime = Z.TimeTools.TimerTabaleTimeParse(seasonTimeCfg.endtime)
    return startTime, endTime
  end
  return nil, nil
end
local getSeasonWeekBySevenDays = function()
  local seasonStartTime = getSeasonStartEndTime()
  if seasonStartTime == nil then
    return nil
  end
  local now = Z.TimeTools.Now() / 1000
  local diff = now - seasonStartTime
  local diffInWeeks = diff / 86400
  return diffInWeeks
end
local getSeasonWeekBySunday = function()
  local seasonStartTime = getSeasonStartEndTime()
  if seasonStartTime == nil then
    return nil
  end
  local now = Z.TimeTools.Now() / 1000
  local seasonWeekStart = Z.TimeTools.GetWeekStartTime(os.date("*t", seasonStartTime))
  local nowWeekStart = Z.TimeTools.GetWeekStartTime(os.date("*t", now))
  local diffInSeconds = nowWeekStart - seasonWeekStart
  local diffInWeeks = diffInSeconds / 604800
  return math.floor(diffInWeeks)
end
local getSeasonEquipGs = function()
  local planetData = Z.DataMgr.Get("planetmemory_data")
  local seasonId = planetData:GetNowSeasonId()
  local day = planetData:GetSeasonDay()
  if seasonId == 0 or day == 0 then
    return 0
  end
  local seasonData = Z.DataMgr.Get("season_data")
  for id, seasonCfgData in pairs(seasonData.SeasonDailyTableDatas) do
    if seasonCfgData.Season == seasonId and seasonCfgData.Day == day then
      return seasonCfgData.DailyEquipLevel
    end
  end
  return 0
end
local getSeasonTimeText = function(seasonId)
  local seasonGlobalTableMgr = Z.TableMgr.GetTable("SeasonGlobalTableMgr")
  local seasonConfig = seasonGlobalTableMgr.GetRow(seasonId)
  if seasonConfig then
    local seasonTimeCfg = Z.TableMgr.GetTable("TimerTableMgr").GetRow(seasonConfig.SeasonTimeId)
    if seasonTimeCfg then
      return seasonTimeCfg.starttime .. "-" .. seasonTimeCfg.endtime
    end
  end
  return ""
end
local getSeasonActConfigByFuncId = function(funcId)
  local seasonData = Z.DataMgr.Get("season_data")
  for _, cfg in pairs(seasonData.SeasonActTableDatas) do
    if cfg.FunctionId == funcId then
      return cfg
    end
  end
  return nil
end
local ret = {
  RefreshSeasonData = refreshSeasonData,
  OpenSeasonMainView = openSeasonMainView,
  CloseSeasonMainView = closeSeasonMainView,
  OpenSeasonActivityView = openSeasonActivityView,
  GetCurChoosePage = getCurChoosePage,
  GetSeasonPagesIndex = getSeasonPagesIndex,
  AsyncGetCurSeason = asyncGetCurSeason,
  GetSeasonByTime = getSeasonByTime,
  GetSeasonWeekBySevenDays = getSeasonWeekBySevenDays,
  GetSeasonWeekBySunday = getSeasonWeekBySunday,
  GetSeasonEquipGs = getSeasonEquipGs,
  GetSeasonTimeText = getSeasonTimeText,
  GetSeasonStartEndTime = getSeasonStartEndTime,
  GetCurrentSeasonId = getCurrentSeasonId,
  GetSeasonActConfigByFuncId = getSeasonActConfigByFuncId,
  GetCurSeasonTimeShow = getCurSeasonTimeShow
}
return ret
