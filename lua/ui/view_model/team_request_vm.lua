local openRequestView = function()
  Z.UIMgr:OpenView("team_request")
end
local closeRequestView = function()
  Z.UIMgr:CloseView("team_request")
end
local getApplyList = function(applyInfo)
  local applyList = {}
  for i = 1, tonumber(Z.Global.TeamApplyShowNumMax) do
    local member = applyInfo[i]
    if member then
      table.insert(applyList, member)
    end
  end
  table.sort(applyList, function(a, b)
    return a.time < b.time
  end)
  return applyList
end
local ret = {
  OpenRequestView = openRequestView,
  CloseRequestView = closeRequestView,
  GetApplyList = getApplyList
}
return ret
