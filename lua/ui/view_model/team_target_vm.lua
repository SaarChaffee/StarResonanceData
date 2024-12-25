local openTeamTargetView = function()
  Z.UIMgr:OpenView("team_target")
end
local closeTeamTargetView = function()
  Z.UIMgr:CloseView("team_target")
end
local openCustomTextView = function(viewData)
  Z.UIMgr:OpenView("team_custom_text_popup", viewData)
end
local closeCustomTextView = function()
  Z.UIMgr:CloseView("team_custom_text_popup")
end
local ret = {
  OpenTeamTargetView = openTeamTargetView,
  CloseTeamTargetView = closeTeamTargetView,
  OpenCustomTextView = openCustomTextView,
  CloseCustomTextView = closeCustomTextView
}
return ret
