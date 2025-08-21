local deadStateId = Z.PbEnum("EActorState", "ActorStateDead")
local openDeadView = function()
  if Z.UIMgr:IsActive("dead") then
    return
  end
  local showBoss = Z.UIMgr:IsActive("bossbattle")
  Z.UIMgr:GotoMainView()
  Z.UIMgr:OpenView("dead")
  if showBoss then
    Z.UIMgr:OpenView("bossbattle")
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Dead)
end
local closeDeadView = function()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if deadStateId ~= stateId then
    Z.UIMgr:CloseView("dead")
  end
end
local asyncRevive = function(vReviveId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.UserResurrection(vReviveId, cancelToken)
  if ret ~= 0 and Z.PbEnum("EErrorCode", "ErrAsynchronousReturn") ~= ret then
    Z.TipsVM.ShowTips(ret)
  end
end
local checkPlayerIsDead = function()
  if Z.EntityMgr.PlayerEnt then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
    if deadStateId == stateId then
      return true
    end
  end
  return false
end
local getPlayerReviveInfo = function(reviveId)
  local info = {
    PersonReviveCount = 0,
    PersonReviveLimit = -1,
    TotalReviveCount = 0,
    TotalReviveLimit = -1
  }
  if Z.EntityMgr.PlayerEnt then
    info.PersonReviveCount = Z.EntityHelper.GetReviveCount(Z.EntityMgr.PlayerEnt, reviveId)
  end
  if Z.ContainerMgr.DungeonSyncData.reviveInfo and Z.ContainerMgr.DungeonSyncData.reviveInfo.reviveMap then
    info.TotalReviveCount = Z.ContainerMgr.DungeonSyncData.reviveInfo.reviveMap[reviveId] or 0
  end
  local reviveRow = Z.TableMgr.GetRow("ReviveTableMgr", reviveId)
  if reviveRow and 0 < #reviveRow.ReviveCount then
    for i, v in ipairs(reviveRow.ReviveCount) do
      local type = v[1]
      local count = v[2]
      if type == 1 then
        info.PersonReviveLimit = count
      elseif type == 2 then
        info.TotalReviveLimit = count
      end
    end
  end
  return info
end
local checkReviveCount = function(reviveId, isShowTips)
  local reviveInfo = getPlayerReviveInfo(reviveId)
  if reviveInfo.PersonReviveLimit >= 0 and reviveInfo.PersonReviveCount >= reviveInfo.PersonReviveLimit then
    if isShowTips then
      Z.TipsVM.ShowTipsLang(1050002, {
        val = reviveInfo.PersonReviveCount
      })
    end
    return false
  elseif 0 <= reviveInfo.TotalReviveLimit and reviveInfo.TotalReviveCount >= reviveInfo.TotalReviveLimit then
    if isShowTips then
      Z.TipsVM.ShowTipsLang(1050003, {
        val = reviveInfo.TotalReviveCount
      })
    end
    return false
  else
    return true
  end
end
local getCurReviveIdList = function()
  local reviveids = {}
  local serverReviveInfo = Z.ContainerMgr.DungeonSyncData.reviveInfo
  if serverReviveInfo and serverReviveInfo.reviveIds and #serverReviveInfo.reviveIds > 0 then
    reviveids = serverReviveInfo.reviveIds
  else
    local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    if 0 < visualLayerId then
      local visualLayerCfg = Z.TableMgr.GetTable("VisualLayerMgr").GetRow(visualLayerId)
      if visualLayerCfg == nil then
        return
      end
      reviveids = visualLayerCfg.ReviveTableId
    else
      local scenceId = Z.StageMgr.GetCurrentSceneId()
      local scenceData = Z.TableMgr.GetTable("SceneTableMgr").GetRow(scenceId)
      if scenceData == nil then
        return
      end
      reviveids = scenceData.ReviveTableId
    end
  end
  return reviveids
end
local ret = {
  OpenDeadView = openDeadView,
  CloseDeadView = closeDeadView,
  AsyncRevive = asyncRevive,
  CheckPlayerIsDead = checkPlayerIsDead,
  GetPlayerReviveInfo = getPlayerReviveInfo,
  CheckReviveCount = checkReviveCount,
  GetCurReviveIdList = getCurReviveIdList
}
return ret
