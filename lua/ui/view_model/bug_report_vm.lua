local openBugReprotView = function(viewData)
  Z.UIMgr:OpenView("bug_window", viewData)
end
local closeBugReprotView = function()
  Z.UIMgr:CloseView("bug_window")
end
local submitBug = function(form, subEndCB)
  Z.BugReportMgr:Submit(form, subEndCB)
end
local ret = {
  OpenBugReprotView = openBugReprotView,
  CloseBugReprotView = closeBugReprotView,
  SubmitBug = submitBug
}
return ret
