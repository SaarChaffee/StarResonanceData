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
local getCurDay = function()
  local startServerTime = Z.DataMgr.Get("season_quest_sub_data"):GetStartServerTime()
  local curStamp = math.floor(Z.TimeTools.Now() / 1000)
  if curStamp - startServerTime < 0 then
    return 0
  end
  local timerConfigItem = Z.DIServiceMgr.ZCfgTimerService:GetZCfgTimerItem(901)
  local hour = timerConfigItem.Offset[0] / 3600
  local startDateTime = os.date("*t", startServerTime)
  local startDataTime5Stamp = os.time({
    year = startDateTime.year,
    month = startDateTime.month,
    day = startDateTime.day,
    hour = hour,
    min = 0,
    sec = 0
  })
  local sub5Stamp = curStamp - startDataTime5Stamp
  local subDay = math.floor(sub5Stamp / 86400) + 1
  if hour > startDateTime.hour then
    return subDay + 1
  else
    return subDay
  end
end
local getTaskList = function(rebuild)
  local dataMgr = Z.DataMgr.Get("season_quest_sub_data")
  return dataMgr:GetTaskList(rebuild)
end
local asyncGetTaskAward = function(id, cancelSource)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetSeasonQuestAward(id, cancelSource:CreateToken())
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
end
local asyncGetAllTaskAward = function(cancelSource)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetSeasonQuestAward(0, cancelSource:CreateToken())
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode == 0 then
    return true
  else
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
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
  if datas and datas[day] and next(datas[day]) then
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
  if taskList_ and next(taskList_) ~= nil then
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
  end
  return finishCount_, taskCount_
end
local checkHasSevenDayShow = function()
  local isShow = false
  local switchVm = Z.VMMgr.GetVM("switch")
  local pageFuncOpen = switchVm.CheckFuncSwitch(E.FunctionID.SevendayTargetTitlePage)
  if pageFuncOpen then
    local taskCfgs = getAllTaskConfig()
    local taskList = getTaskList()
    for _, cfg in pairs(taskCfgs) do
      if cfg.tab == E.SevenDayStargetType.TitlePage and taskList[cfg.OpenDay] and taskList[cfg.OpenDay][cfg.TargetId] then
        local taskData = taskList[cfg.OpenDay][cfg.TargetId]
        if taskData.award ~= awardState.hasGet then
          isShow = true
        end
      end
    end
    if isShow then
      return isShow
    end
  end
  local manualFuncOpen = switchVm.CheckFuncSwitch(E.FunctionID.SevendayTargetManual)
  if manualFuncOpen then
    local dataMgr = Z.DataMgr.Get("season_quest_sub_data")
    local dayArray = dataMgr:GetDayArray()
    for _, v in ipairs(dayArray) do
      local finishCount, taskCount = getFinishCountByTaskId(v)
      if finishCount < taskCount then
        isShow = true
        break
      end
    end
  end
  return isShow
end
local ret = {
  GetTaskList = getTaskList,
  AsyncGetTaskAward = asyncGetTaskAward,
  AsyncGetAllTaskAward = asyncGetAllTaskAward,
  GetTaskConfig = getTaskConfig,
  GetTaskTargetConfig = getTaskTargetConfig,
  GetAllTaskConfig = getAllTaskConfig,
  OpenWindow = openWindow,
  CheckAwardGetAll = checkAwardGetAll,
  AwardState = awardState,
  GetCurDay = getCurDay,
  GetDayEndTime = getDayEndTime,
  CheckRedpointByDay = checkRedpointByDay,
  CheckRedpointByWeek = checkRedpointByWeek,
  InitQuestSeason = initQuestSeason,
  OpenSevenDayWindow = openSevenDayWindow,
  CloseSevenDayWindow = closeSevenDayWindow,
  GetFinishCountByTaskId = getFinishCountByTaskId,
  CheckHasSevenDayShow = checkHasSevenDayShow
}
return ret
