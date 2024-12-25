local awardState = E.SevenDayTargetAwardState
local getTaskConfig = function(id)
  local config = Z.TableMgr.GetTable("SeasonTaskTableMgr")
  return config.GetRow(id)
end
local getTaskTargetConfig = function(id)
  local config = Z.TableMgr.GetTable("SeasonTaskTargetTableMgr")
  return config.GetRow(id)
end
local getAllTaskConfig = function()
  local data = Z.DataMgr.Get("season_quest_sub_data")
  return data:GetAllTaskCfg()
end
local getWeekEndTime = function()
  local time = Z.ContainerMgr.CharSerialize.seasonQuestList.refreshTimeStamp
  local now = math.floor(Z.TimeTools.Now() / 1000)
  return time - now
end
local getCurDay = function()
  local startServerTime = Z.DataMgr.Get("season_quest_sub_data"):GetStartServerTime()
  local t = math.floor(Z.TimeTools.Now() / 1000) - startServerTime
  if t < 0 then
    return 0
  end
  return math.floor(t / 86400) + 1
end
local getTaskList = function(rebuild)
  local dataMgr = Z.DataMgr.Get("season_quest_sub_data")
  return dataMgr:GetTaskList(rebuild)
end
local asyncGetTaskAward = function(id, cancelSource)
  local getAwardTag = true
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetSeasonQuestAward(id, cancelSource:CreateToken())
  if 0 < ret then
    getAwardTag = false
  end
  return getAwardTag
end
local asyncGetAllTaskAward = function(cancelSource)
  local getAwardTag = true
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetSeasonQuestAward(0, cancelSource:CreateToken())
  if 0 < ret then
    getAwardTag = nil
  end
end
local getRefreshWeek = function()
  local week = Z.ContainerMgr.CharSerialize.seasonQuestList.RefreshWeek
  return week
end
local getDayEndTime = function()
  local startServerTime = Z.DataMgr.Get("season_quest_sub_data"):GetStartServerTime()
  return Z.TimeTools.GetDayEndTime(startServerTime)
end
local checkAwardGetAll = function()
  local data = Z.ContainerMgr.CharSerialize.seasonQuestList.seasonMap
  local day = getCurDay()
  for id, v in pairs(data) do
    local cfg = getTaskConfig(id)
    if cfg and day >= cfg.OpenDay and v.award == awardState.canGet then
      return true
    end
  end
  return false
end
local openWindow = function()
  Z.VMMgr.GetVM("season").OpenSeasonMainView()
end
local onDataChanged = function()
  Z.EventMgr:Dispatch(Z.ConstValue.SeasonWeekData)
end
local addTaskDataChangedListener = function()
  local container = Z.ContainerMgr.CharSerialize.seasonQuestList
  container.Watcher:RegWatcher(onDataChanged)
end
local removeTaskDataChangedListener = function()
  local container = Z.ContainerMgr.CharSerialize.seasonQuestList
  container.Watcher:UnregWatcher(onDataChanged)
end
local checkRedpointByDay = function(day)
  local cur = getCurDay()
  local count = 0
  if day > cur then
    return count
  end
  local list = getTaskList()[day]
  for i = 1, #list do
    if list[i].award == awardState.canGet then
      count = count + 1
    end
  end
  return count
end
local checkRedpointByWeek = function()
  local count = 0
  local tab = Z.DataMgr.Get("season_quest_sub_data"):GetDayTable()
  for _, day in ipairs(tab) do
    count = count + checkRedpointByDay(day)
  end
  return count
end
local onDataChangedWhole = function()
  local tasks_ = getTaskList(true)
  local sevendaysRed_ = require("rednode.sevendays_target_red")
  sevendaysRed_.RefreshOrInitSevenDaysTargetRed(tasks_)
end

local function onDayChanged()
  local day = getCurDay()
  local datas = Z.DataMgr.Get("season_quest_sub_data"):GetTaskList()
  if datas and datas[day] and table.zcount(datas[day]) > 0 then
    onDataChangedWhole()
  end
  local t = getDayEndTime()
  Z.DataMgr.Get("season_quest_sub_data"):OpenDayTimer(t, onDayChanged)
end

local openDayTimer = function()
  local t = getDayEndTime()
  Z.DataMgr.Get("season_quest_sub_data"):OpenDayTimer(t, onDayChanged)
end
local initCfgDayTable = function()
  local tab = {}
  local dayTable = {}
  local cfgs = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetDatas()
  for _, cfg in pairs(cfgs) do
    if not dayTable[cfg.OpenDay] then
      tab[#tab + 1] = cfg.OpenDay
      dayTable[cfg.OpenDay] = true
    end
  end
  table.sort(tab, function(a, b)
    return a < b
  end)
  local questSeasonData = Z.DataMgr.Get("season_quest_sub_data")
  questSeasonData:SetDayTable(tab)
end
local initQuestSeason = function()
  initCfgDayTable()
  local tasks_ = getTaskList(true)
  openDayTimer()
  local sevendaysRed_ = require("rednode.sevendays_target_red")
  sevendaysRed_.RefreshOrInitSevenDaysTargetRed(tasks_)
  sevendaysRed_.InitOrRefreshFuncPreviewRed(true)
end
local openSevenDayWindow = function(index)
  local showManual = false
  if index then
    showManual = tonumber(index) == 2
  end
  local showType = showManual and E.SevenDayFuncType.Manual and E.SevenDayFuncType.TitlePage
  Z.UIMgr:OpenView("sevendaystarget_main", {showType = showType})
end
local closeSevenDayWindow = function()
  Z.UIMgr:CloseView("sevendaystarget_main")
end
local getFinishCountByTaskId = function(day)
  local taskList_ = getTaskList()
  local finishCount_ = 0
  local taskCount_ = 0
  local seasontaskdataList_ = Z.TableMgr.GetTable("SeasonTaskTableMgr").GetDatas()
  for _, cfg_ in pairs(seasontaskdataList_) do
    if cfg_.OpenDay == day and cfg_.tab == E.SevenDayStargetType.Manual then
      local taskData = taskList_[day][cfg_.TargetId]
      if taskData and taskData.award == awardState.hasGet then
        finishCount_ = finishCount_ + 1
      end
      taskCount_ = taskCount_ + 1
    end
  end
  return finishCount_, taskCount_
end
local ret = {
  GetTaskList = getTaskList,
  AsyncGetTaskAward = asyncGetTaskAward,
  AsyncGetAllTaskAward = asyncGetAllTaskAward,
  GetRefreshWeek = getRefreshWeek,
  GetWeekEndTime = getWeekEndTime,
  GetTaskConfig = getTaskConfig,
  GetTaskTargetConfig = getTaskTargetConfig,
  GetAllTaskConfig = getAllTaskConfig,
  OpenWindow = openWindow,
  AddTaskDataChangedListener = addTaskDataChangedListener,
  RemoveTaskDataChangedListener = removeTaskDataChangedListener,
  CheckAwardGetAll = checkAwardGetAll,
  AwardState = awardState,
  GetCurDay = getCurDay,
  GetDayEndTime = getDayEndTime,
  CheckRedpointByDay = checkRedpointByDay,
  CheckRedpointByWeek = checkRedpointByWeek,
  InitQuestSeason = initQuestSeason,
  OpenSevenDayWindow = openSevenDayWindow,
  CloseSevenDayWindow = closeSevenDayWindow,
  GetFinishCountByTaskId = getFinishCountByTaskId
}
return ret
