local teamVm = Z.VMMgr.GetVM("team")
local openHeroView = function()
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.DungeonSettle)
  Z.VMMgr.GetVM("hero_dungeon_copy_window").CloseHeroView()
  local state = Z.ContainerMgr.DungeonSyncData.flowInfo.state
  if teamVm.GetTeamMembersNum() and state == Z.PbEnum("EDungeonState", "DungeonStateVote") then
    Z.UIMgr:OpenView("hero_dungeon_praise_window")
  else
    Z.UITimelineDisplay:ClearTimeLine()
  end
end
local closeHeroView = function()
  Z.UIMgr:CloseView("hero_dungeon_praise_window")
end
local asyncDungeonVote = function(vUuid, cancelSource)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.DungeonVote(vUuid, cancelSource:CreateToken())
  Z.TipsVM.ShowTips(ret)
end
local getLikedAction = function()
  local data = Z.Global.LikedAction
  local values = string.split(data, "|")
  local tab = {}
  for key, value in pairs(values) do
    local str = string.split(value, "=")
    table.insert(tab, str)
  end
  return tab
end
local asyncUserAction = function(actionid, cancelSource)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.UserAction(actionid, cancelSource:CreateToken())
  Z.TipsVM.ShowTips(ret)
end
local quitDungeon = function(cancelToken)
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local proxy = require("zproxy.world_proxy")
  local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  if 0 < visualLayerId then
    proxy.ExitVisualLayer()
  else
    proxy.LeaveScene(cancelToken)
  end
  closeHeroView()
end
local ret = {
  OpenHeroView = openHeroView,
  CloseHeroView = closeHeroView,
  AsyncDungeonVote = asyncDungeonVote,
  GetLikedAction = getLikedAction,
  AsyncUserAction = asyncUserAction,
  QuitDungeon = quitDungeon
}
return ret
