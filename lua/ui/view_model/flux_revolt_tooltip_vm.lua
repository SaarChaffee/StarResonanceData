local closeTooltipView = function()
  Z.UIMgr:CloseView("flux_revolt_tooltip_window")
end
local openTooltipView = function()
  local fluxData = Z.DataMgr.Get("flux_revolt_tooltip_data")
  if fluxData.DungeonHideTag and fluxData.MainViewHideTag then
    Z.UIMgr:OpenView("flux_revolt_tooltip_window")
  elseif Z.UIMgr:IsActive("flux_revolt_tooltip_window") then
    Z.UIMgr:GetView("flux_revolt_tooltip_window"):Hide()
  end
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
