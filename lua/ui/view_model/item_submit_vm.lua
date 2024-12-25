local openItemSubmitView = function(submitType)
  local submitType = submitType or E.TalkItemSubmitType.Submit
  Z.UIMgr:OpenView("tips_item_submit_popup", {SubmitType = submitType})
end
local closeItemSubmitView = function()
  Z.UIMgr:CloseView("tips_item_submit_popup")
end
local ret = {OpenItemSubmitView = openItemSubmitView, CloseItemSubmitView = closeItemSubmitView}
return ret
