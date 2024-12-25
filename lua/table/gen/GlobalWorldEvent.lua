local read_onlyHelper = require("utility.readonly_helper")
local GlobalWorldEvent = {
  MultiParkour_loadMapCountdown = 5,
  MultiParkour_minPlayerNum = 1,
  MultiParkour_maxPlayerNum = 10,
  MultiParkour_perTurnMatchingTime = {60, 60},
  MultiParkour_finalTipsShowingTime = 5,
  MultiParkour_exitTipsDelayTime = 2
}
return read_onlyHelper.Read_only(GlobalWorldEvent)
