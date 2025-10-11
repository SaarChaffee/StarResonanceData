local SettlementNodeIndex = Panda.ZGame.SettlementNodeIndex
local playCallFunc = function(cutId, tab, teamMembers, showCount)
  local teamEntData = {}
  Z.UITimelineDisplay:Play(cutId)
  Z.UITimelineDisplay:SetGoPosByCutsceneId(cutId, Vector3.New(tab.ResultCurscenePos.X, tab.ResultCurscenePos.Y, tab.ResultCurscenePos.Z))
  local isPlay = Z.SettlementCutMgr:GetSettlementIsPlayByCutId(cutId)
  if isPlay then
    if 1 < showCount then
      local count = 0
      for index, value in ipairs(teamMembers) do
        if not value.isAi then
          count = count + 1
          local data = {}
          local nodeCountType = SettlementNodeIndex.IntToEnum(showCount - 2)
          data.posi = Z.SettlementCutMgr:GetSettlementMondelNodePosi(nodeCountType, count - 1)
          data.quaternion = Z.SettlementCutMgr:GetSettlementMondelNodeEulerAngle(nodeCountType, count - 1)
          teamEntData[value.charId] = data
        end
      end
    else
      local data = {}
      local indexType = SettlementNodeIndex.IntToEnum(0)
      data.posi = Z.SettlementCutMgr:GetSettlementMondelNodePosi(indexType, 0)
      data.quaternion = Z.SettlementCutMgr:GetSettlementMondelNodeEulerAngle(indexType, 0)
      teamEntData[Z.EntityMgr.PlayerEnt.CharId] = data
    end
  end
  local ret = {}
  ret.vUserPos = {}
  for charId, pos in pairs(teamEntData) do
    local tab = {}
    tab.pos = {
      x = pos.posi.x,
      y = pos.posi.y,
      z = pos.posi.z,
      dir = pos.quaternion.y
    }
    ret.vUserPos[charId] = tab
  end
  local dungeonData = Z.DataMgr.Get("hero_dungeon_main_data")
  dungeonData.TeamDisplayData = ret
  Z.TimerMgr:StartTimer(function()
    Z.UIMgr:DeActiveAll(false, "hero_dungeon_key")
    Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
    Z.UIMgr:OpenView("hero_dungeon_copy_window")
  end, 1, 1)
end
local playTimeLine = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local tab = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local teamVm = Z.VMMgr.GetVM("team")
  local teamMembers = teamVm.GetTeamMemData()
  local showCount = #teamMembers
  for index, value in ipairs(teamMembers) do
    if value.isAi then
      Z.LuaBridge.SetModelVisibleByEntId(value.charId)
      showCount = showCount - 1
    end
  end
  local cutId = showCount == 1 and 50100602 or 50100601
  local teamData = Z.DataMgr.Get("team_data")
  if tab and (tab.ResultCurscenePos.X ~= 0 or tab.ResultCurscenePos.Y ~= 0 or tab.ResultCurscenePos.Z ~= 0) then
    Z.UITimelineDisplay:AsyncPreLoadTimeline(cutId, teamData.CancelSource:CreateToken(), function()
      playCallFunc(cutId, tab, teamMembers, showCount)
    end, function()
    end)
  else
    Z.UIMgr:DeActiveAll(false, "hero_dungeon_key")
    Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
    Z.UIMgr:OpenView("hero_dungeon_copy_window")
  end
end
local openHeroView = function()
  Z.UIMgr:GotoMainView()
  playTimeLine()
end
local openOriginalHeroView = function()
  if Z.UIMgr:IsActive("camerasys") then
    Z.UIMgr:CloseView("camerasys")
  end
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Demo_yzh, "hero_dungeon_copy_window_ori", function()
    Z.UIMgr:OpenView("hero_dungeon_copy_window_ori")
  end)
end
local closeHeroView = function()
  Z.UIMgr:CloseView("hero_dungeon_copy_window")
end
local closeOriginalHeroView = function()
  Z.UIMgr:CloseView("hero_dungeon_copy_window_ori")
  Z.UnrealSceneMgr:CloseUnrealScene("hero_dungeon_copy_window_ori")
end
local onContinueExplore = function(token)
  Z.CoroUtil.create_coro_xpcall(function()
    local proxy = require("zproxy.world_proxy")
    proxy.LeaveScene(token)
  end)()
end
local playAction = function()
  local actionData = Z.Global.VictoryAction
  local index = math.random(1, #actionData)
  Z.ZAnimActionPlayMgr:PlayAction(actionData[index], true)
end
local quitDungeon = function(cancelToken)
  local proxy = require("zproxy.world_proxy")
  local visualLayerId = 0
  if Z.EntityMgr.PlayerEnt then
    visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
  end
  if 0 < visualLayerId then
    proxy.ExitVisualLayer()
  else
    proxy.LeaveScene(cancelToken)
  end
  closeHeroView()
end
local beginDungeonSettle = function()
  local dungeonData = Z.DataMgr.Get("hero_dungeon_main_data")
  local isHaveVote = false
  if dungeonData.IsBeginSettleTime == false then
    dungeonData.IsBeginSettleTime = true
    local times = Z.Global.VictoryToTeamTime
    local time = 0
    Z.GlobalTimerMgr:StartTimer(E.GlobalTimerTag.DungeonSettle, function()
      time = time + 1
      if time >= tonumber(times[2]) then
        Z.VMMgr.GetVM("hero_dungeon_praise_window").OpenHeroView()
      end
      Z.EventMgr:Dispatch(Z.ConstValue.HeroDungeonSettleTime, time)
    end, 1, tonumber(times[2]), nil, function()
      dungeonData.IsBeginSettleTime = false
    end)
  end
end
local openSettlementFailWindow = function()
  if Z.UIMgr:IsActive("trialroad_battle_failure_window") then
    return
  end
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("trialroad_battle_failure_window")
end
local openMasterDungeonFailWindow = function()
  if Z.UIMgr:IsActive("master_dungeon_failure_window") then
    return
  end
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("master_dungeon_failure_window")
end
local ret = {
  OpenHeroView = openHeroView,
  CloseHeroView = closeHeroView,
  OpenSettlementFailWindow = openSettlementFailWindow,
  OnContinueExplore = onContinueExplore,
  PlayModelAction = playAction,
  OpenOriginalHeroView = openOriginalHeroView,
  CloseOriginalHeroView = closeOriginalHeroView,
  QuitDungeon = quitDungeon,
  BeginDungeonSettle = beginDungeonSettle,
  OpenMasterDungeonFailWindow = openMasterDungeonFailWindow
}
return ret
