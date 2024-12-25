local openView = function()
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  trialroadData:InitTrialRoadRoomDict()
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_05, "trialroad_main", function()
    Z.UIMgr:OpenView("trialroad_main")
  end)
end
local closeView = function()
  Z.UIMgr:CloseView("trialroad_main")
end
local closeTrialRoadWindow = function()
end
local isSpecialCopy = function(dungeonId)
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if not cfg then
    return false
  end
  for _, value in pairs(cfg.Condition) do
    if value[1] == E.DungeonPrecondition.CondItem then
      local itemIdId = value[2]
      local itemIdNum = value[3]
      return true, itemIdId, itemIdNum
    end
  end
  return false
end
local asyncEnterTrialRoad = function(roomId, token)
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.EnterPlanetMemoryRoom(roomId, token)
  if ret == 0 then
  else
    Z.TipsVM.ShowTips(ret)
  end
end
local isTrialRoad = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return false
  end
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if not planetRoomInfo then
    return false
  end
  local roomId = planetRoomInfo.roomId
  if roomId and roomId ~= 0 then
    return true
  else
    return false
  end
end
local refreshRoomTargetState = function(roomId)
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  trialroadData:RefreshRoomTargetState(roomId)
end
local reqestGetTargetReward = function(roomId, targetId, token)
  local request = {}
  request.roomId = roomId
  request.targetId = targetId
  local worldProxy_ = require("zproxy.world_proxy")
  local ret = worldProxy_.GetRoomAward(request, token)
  if ret == 0 then
    refreshRoomTargetState(roomId)
    Z.EventMgr:Dispatch(Z.ConstValue.TrialRoad.RefreshRoomTarget)
    local trialRoadRed_ = require("rednode.trialroad_red")
    trialRoadRed_.RefreshTrialRoadRoomTargetItemRed(roomId)
    return true
  else
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
end
local reqestGetTrialTargetReward = function(targetId, token)
  local request = {}
  request.targetId = targetId
  local worldProxy_ = require("zproxy.world_proxy")
  local ret = worldProxy_.GetTrialRoadAward(request, token)
  if ret == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.TrialRoad.RefreshTrialRoadTarget)
    local trialRoadRed_ = require("rednode.trialroad_red")
    trialRoadRed_.RefreshTrialRoadGradeTargetItemRed()
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local refreshRoomRestOpenTime = function(roomData)
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  local restTimeStr_ = trialroadData:RefreshTrialRoadRoomDataUnlockTime(roomData)
  return restTimeStr_
end
local getGradeTargetProgress = function(targetId)
  local trialRoadTargetRow_ = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
  local progress = Z.ContainerMgr.CharSerialize.trialRoad.targetAward.targetProgress[targetId]
  local curProgress = 0
  local targetProgress = 0
  if progress then
    curProgress = progress.targetProgress
  end
  if trialRoadTargetRow_ then
    targetProgress = trialRoadTargetRow_.Num
  end
  return curProgress, targetProgress
end
local getRoomTargetProgress = function(roomId, targetId)
  local trialRoadTargetRow_ = Z.TableMgr.GetTable("TargetTableMgr").GetRow(targetId)
  local progress
  if Z.ContainerMgr.CharSerialize.trialRoad.roomTargetAward and Z.ContainerMgr.CharSerialize.trialRoad.roomTargetAward[roomId] then
    progress = Z.ContainerMgr.CharSerialize.trialRoad.roomTargetAward[roomId].targetProgress[targetId]
  end
  local curProgress = 0
  local targetProgress = 0
  if progress then
    curProgress = progress.targetProgress
  end
  if trialRoadTargetRow_ then
    targetProgress = trialRoadTargetRow_.Num
  end
  return curProgress, targetProgress
end
local switchUnrealSceneStyle = function(type)
  local trialroadData = Z.DataMgr.Get("trialroad_data")
  local style = trialroadData.DictUnrealSceneStyle[type]
  Z.UnrealSceneMgr:SwicthVirtualStyle(style)
end
local openGradePopup = function()
  Z.UIMgr:OpenView("trialroad_grade_popup")
end
local closeGradePopup = function()
  Z.UIMgr:CloseView("trialroad_grade_popup")
end
local playCallFunc = function(cutId, tab)
  local teamEntData = {}
  Z.UITimelineDisplay:Play(cutId)
  Z.UITimelineDisplay:SetGoPosByCutsceneId(cutId, Vector3.New(tab.ResultCurscenePos.X, tab.ResultCurscenePos.Y, tab.ResultCurscenePos.Z))
  local isPlay = Z.SettlementCutMgr:GetSettlementIsPlayByCutId(cutId)
  if isPlay then
    local data = {}
    data.posi = Z.SettlementCutMgr:GetSettlementMondelNodePosi(0, 0)
    data.quaternion = Z.SettlementCutMgr:GetSettlementMondelNodeEulerAngle(0, 0)
    teamEntData[Z.EntityMgr.PlayerEnt.EntId] = data
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
  local teamData = Z.DataMgr.Get("team_data")
  Z.CoroUtil.create_coro_xpcall(function()
    local proxy = require("zproxy.world_proxy")
    proxy.ReportSettlementPosition(ret, teamData.CancelSource:CreateToken())
  end)()
  Z.UIMgr:OpenView("trialroad_closing_window")
end
local playTimeLine = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local tab = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  local cutId = 50100601
  local teamData = Z.DataMgr.Get("team_data")
  if tab and (tab.ResultCurscenePos.X ~= 0 or tab.ResultCurscenePos.Y ~= 0 or tab.ResultCurscenePos.Z ~= 0) then
    Z.UITimelineDisplay:AsyncPreLoadTimeline(cutId, teamData.CancelSource:CreateToken(), function()
      playCallFunc(cutId, tab)
    end, function()
    end)
  else
    Z.UIMgr:GotoMainView()
    Z.UIMgr:OpenView("trialroad_closing_window")
  end
end
local openSettlementSuccessWindow = function()
  if Z.UIMgr:IsActive("camerasys") then
    Z.UIMgr:CloseView("camerasys")
  end
  playTimeLine()
end
local closeSettlementSuccessWindow = function()
  Z.UIMgr:CloseView("trialroad_closing_window")
end
local openSettlementFailWindow = function()
  if Z.UIMgr:IsActive("trialroad_battle_failure_window") then
    return
  end
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("trialroad_battle_failure_window")
end
local gotoNextLevel = function()
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo and planetRoomInfo.roomId > 0 then
    local trialroadData = Z.DataMgr.Get("trialroad_data")
    local nextRoom = trialroadData:GetNextRoomData(planetRoomInfo.roomId)
    if nextRoom ~= nil then
      Z.CoroUtil.create_coro_xpcall(function()
        asyncEnterTrialRoad(nextRoom.RoomId, trialroadData.CancelSource:CreateToken())
      end)()
    else
      Z.TipsVM.ShowTips(15001040)
    end
  end
end
local reChallengeLevel = function()
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo and planetRoomInfo.roomId > 0 then
    local trialroadData = Z.DataMgr.Get("trialroad_data")
    Z.CoroUtil.create_coro_xpcall(function()
      asyncEnterTrialRoad(planetRoomInfo.roomId, trialroadData.CancelSource:CreateToken())
    end)()
  end
end
local returnTrialRoadUI = function()
  openView()
end
local leaveDuplicate = function()
  Z.CoroUtil.create_coro_xpcall(function()
    local trialroadData = Z.DataMgr.Get("trialroad_data")
    local proxy = require("zproxy.world_proxy")
    local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    if 0 < visualLayerId then
      proxy.ExitVisualLayer()
    else
      proxy.LeaveScene(trialroadData.CancelSource:CreateToken())
    end
    closeView()
  end)()
end
local refreshTrialRoadRed = function(roomId)
  local trialRoadRed_ = require("rednode.trialroad_red")
  trialRoadRed_.RefreshTrialRoadGradeTargetItemRed()
  trialRoadRed_.RefreshTrialRoadRoomTargetItemRed(roomId)
end
local closeTrialRoadFailureView = function()
  Z.UIMgr:CloseView("trialroad_battle_failure_window")
end
local ret = {
  OpenView = openView,
  CloseView = closeView,
  CloseTrialRoadWindow = closeTrialRoadWindow,
  IsSpecialCopy = isSpecialCopy,
  AsyncEnterTrialRoad = asyncEnterTrialRoad,
  ReqestGetTargetReward = reqestGetTargetReward,
  ReqestGetTrialTargetReward = reqestGetTrialTargetReward,
  RefreshRoomRestOpenTime = refreshRoomRestOpenTime,
  SwitchUnrealSceneStyle = switchUnrealSceneStyle,
  GetGradeTargetProgress = getGradeTargetProgress,
  GetRoomTargetProgress = getRoomTargetProgress,
  OpenGradePopup = openGradePopup,
  CloseGradePopup = closeGradePopup,
  IsTrialRoad = isTrialRoad,
  RefreshRoomTargetState = refreshRoomTargetState,
  OpenSettlementSuccessWindow = openSettlementSuccessWindow,
  CloseSettlementSuccessWindow = closeSettlementSuccessWindow,
  OpenSettlementFailWindow = openSettlementFailWindow,
  RefreshTrialRoadRed = refreshTrialRoadRed,
  CloseTrialRoadFailureView = closeTrialRoadFailureView,
  GotoNextLevel = gotoNextLevel,
  ReChallengeLevel = reChallengeLevel,
  ReturnTrialRoadUI = returnTrialRoadUI,
  LeaveDuplicate = leaveDuplicate
}
return ret
