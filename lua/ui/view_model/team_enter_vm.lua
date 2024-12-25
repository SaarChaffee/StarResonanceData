local openEnterView = function(teamActivity)
  Z.UIMgr:OpenView("team_enter", teamActivity)
end
local closeEnterView = function()
  Z.UIMgr:CloseView("team_enter")
end
local openAffixInfoView = function(teamActivity)
  Z.UIMgr:OpenView("hero_dungeon_affix_item_tpl", teamActivity)
end
local closeAffixInfoView = function()
  Z.UIMgr:CloseView("hero_dungeon_affix_item_tpl")
end
local asyncTeamCancelActivity = function(cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  worldProxy.TeamCancelActivity(request, cancelToken)
end
local asyncReplyJoinActivity = function(agree, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.isAgree = agree
  worldProxy.ReplyJoinActivity(request, cancelToken)
end
local handleTeamActivity = function(teamActivity)
  if teamActivity.assignSceneParams and teamActivity.assignSceneParams.initParam.weeklyTowerInfo and teamActivity.assignSceneParams.initParam.weeklyTowerInfo.continuous then
    Z.CoroUtil.create_coro_xpcall(function()
      local teamData = Z.DataMgr.Get("team_data")
      asyncReplyJoinActivity(true, teamData.CancelSource:CreateToken())
    end)()
    return
  end
  if Z.PbEnum("ETeamActivityState", "ETeamActivity_Voting") == teamActivity.state then
    openEnterView(teamActivity)
  elseif Z.PbEnum("ETeamActivityState", "ETeamActivity_No") == teamActivity.state then
    closeEnterView()
  elseif Z.PbEnum("ETeamActivityState", "ETeamActivity_Doing") == teamActivity.state then
    Z.EventMgr:Dispatch(Z.ConstValue.Team.HideActivityLeaderCancelBtn)
  end
end
local ret = {
  OpenEnterView = openEnterView,
  CloseEnterView = closeEnterView,
  OpenAffixInfoView = openAffixInfoView,
  CloseAffixInfoView = closeAffixInfoView,
  AsyncTeamCancelActivity = asyncTeamCancelActivity,
  AsyncReplyJoinActivity = asyncReplyJoinActivity,
  HandleTeamActivity = handleTeamActivity
}
return ret
