local closeCountdownView = function()
  Z.UIMgr:CloseView("tips_countdown_popup")
end
local openCountdownView = function(mark, configId, param, timeNum)
  if mark == true and configId and timeNum then
    local data = {
      cfgId = configId,
      placeholderParam = param,
      countdownTime = timeNum
    }
    Z.UIMgr:OpenView("tips_countdown_popup", data)
  else
    closeCountdownView()
  end
end
local ret = {OpenCountdownView = openCountdownView, CloseCountdownView = closeCountdownView}
return ret
