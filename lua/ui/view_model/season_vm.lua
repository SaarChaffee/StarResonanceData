local refreshSeasonData = function(seasonId)
  logGreen("[Season] \229\189\147\229\137\141\232\181\155\229\173\163Id: " .. seasonId)
  local seasonData = Z.DataMgr.Get("season_data")
  seasonData.CurSeasonId = seasonId
  local achievement = Z.DataMgr.Get("achievement_data")
  achievement:SetSeason(seasonId)
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
    local startTime, endTime, _ = Z.TimeTools.GetWholeStartEndTimeByTimerId(seasonGlobalRow.SeasonTimeId)
    if startTime and endTime then
      local startTimeData = Z.TimeFormatTools.TicksFormatTime(startTime * 1000, E.TimeFormatType.YMD, false, true)
      local endTimeData = Z.TimeFormatTools.TicksFormatTime(endTime * 1000, E.TimeFormatType.YMD, false, true)
      seasonTimeStr = string.zconcat(startTimeData, " ~ ", endTimeData)
    end
  end
  return seasonName, seasonTimeStr
end
local openSeasonMainView = function(id, subId, configID)
  local data = Z.DataMgr.Get("season_data")
  local pageIndex = data:GetPageSortByFuncId(tonumber(id))
  data:SetCurShowPage(pageIndex)
  data:SetSubPageId(tonumber(subId))
  if configID then
    data:SetCurSelectItem(configID)
  end
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
      seasonData:SetSeasonData(ret.seasonId, ret.day)
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
    local startTime, endTime, _ = Z.TimeTools.GetWholeStartEndTimeByTimerId(cfg.SeasonTimeId)
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
    local startTime, endTime, _ = Z.TimeTools.GetWholeStartEndTimeByTimerId(seasonCfg.SeasonTimeId)
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
  local diffInWeeks = math.floor(diff / 86400)
  return diffInWeeks
end
local getSeasonWeekBySunday = function()
  local seasonStartTime = getSeasonStartEndTime()
  if seasonStartTime == nil then
    return nil
  end
  local now = math.floor(Z.TimeTools.Now() / 1000)
  local seasonWeekStart = Z.TimeTools.GetWeekStartTime(seasonStartTime)
  local nowWeekStart = Z.TimeTools.GetWeekStartTime(now)
  local diffSeconds = nowWeekStart - seasonWeekStart
  return math.floor(diffSeconds / 604800) + 1
end
local getSeasonEquipGs = function()
  local seasonData = Z.DataMgr.Get("season_data")
  local seasonId = seasonData:GetNowSeasonId()
  local day = seasonData:GetSeasonDay()
  if seasonId == 0 or day == 0 then
    return 0
  end
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
    return Z.TimeTools.GetTimeOpenDesc(seasonConfig.SeasonTimeId)
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
local getSeasonShowConfig = function()
  local temp = {}
  local curSeasonId = getCurrentSeasonId()
  if not curSeasonId or curSeasonId == 0 then
    return temp
  end
  local seasonPreviewDatas = Z.TableMgr.GetTable("SeasonlPreviewTableMgr").GetDatas()
  for k, v in pairs(seasonPreviewDatas) do
    if v.SeasonId == curSeasonId then
      temp[#temp + 1] = v
    end
  end
  table.sort(temp, function(a, b)
    return a.Sort < b.Sort
  end)
  return temp
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
  GetCurSeasonTimeShow = getCurSeasonTimeShow,
  GetSeasonShowConfig = getSeasonShowConfig
}
return ret
