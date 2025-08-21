local closeDungeonTimerView = function()
  Z.UIMgr:CloseView("dungeon_timer_window")
end
local openDungeonTimerView = function(ignoreChange)
  local dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
  if dungeonTimerData.DungeonHideTag and dungeonTimerData.MainViewHideTag then
    local viewData = {ignoreChange = ignoreChange}
    Z.UIMgr:OpenView("dungeon_timer_window", viewData)
  elseif Z.UIMgr:IsActive("dungeon_timer_window") then
    Z.UIMgr:GetView("dungeon_timer_window"):Hide()
  end
end
local setMainViewHideTag = function(isVisible)
  local dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
  dungeonTimerData:SetMainViewHideTag(isVisible)
  openDungeonTimerView(true)
end
local setDungeonHideTag = function(isVisible)
  local dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
  dungeonTimerData:SetDungeonViewHideTag(isVisible)
  openDungeonTimerView()
end
local getEndTimeStamp = function()
  local timerInfo = Z.ContainerMgr.DungeonSyncData.timerInfo
  if not timerInfo then
    return
  end
  local t = timerInfo.startTime
  t = t + timerInfo.dungeonTimes
  if timerInfo.direction == E.DungeonTimerDirection.DungeonTimerDirectionDown then
    t = t + timerInfo.pauseTotalTime
  end
  return t * 1000
end
local ret = {
  OpenDungeonTimerView = openDungeonTimerView,
  CloseDungeonTimerView = closeDungeonTimerView,
  SetMainViewHideTag = setMainViewHideTag,
  SetDungeonHideTag = setDungeonHideTag,
  GetEndTimeStamp = getEndTimeStamp
}
return ret
