local closeTooltipView = function()
end
local openTooltipView = function()
end
local setMainViewHideTag = function(isVisible)
  local fluxData = Z.DataMgr.Get("flux_revolt_tooltip_data")
  fluxData:SetMainViewHideTag(isVisible)
  openTooltipView()
end
local setDungeonHideTag = function(isVisible)
  local fluxData = Z.DataMgr.Get("flux_revolt_tooltip_data")
  fluxData:SetDungeonViewHideTag(isVisible)
  openTooltipView()
end
local getDungeonTimerData = function(timerType)
  local timerData = {}
  if timerType == E.DungeonTimerType.DungeonTimerTypeMiddlerCommon then
    local limitTime = Z.Global.TimeLimitQuestAlert
    if not string.zisEmpty(limitTime) then
      limitTime = tonumber(limitTime)
    end
    timerData.timeLimitNumber = limitTime
    timerData.isShowZeroSecond = true
  end
  return timerData
end
local ret = {
  OpenTooltipView = openTooltipView,
  CloseTooltipView = closeTooltipView,
  SetMainViewHideTag = setMainViewHideTag,
  SetDungeonHideTag = setDungeonHideTag,
  GetDungeonTimerData = getDungeonTimerData
}
return ret
