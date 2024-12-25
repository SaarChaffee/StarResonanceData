local multActionData = Z.DataMgr.Get("multaction_data")
local worldProxy = require("zproxy.world_proxy")
local getOtherId = function()
  if multActionData.BeInviteId == 0 then
    return multActionData.SelectInviteId
  end
  if multActionData.SelectInviteId == 0 then
    return multActionData.BeInviteId
  end
  return 0
end
local cancelAction = function(tipsId)
  multActionData.SelectInviteId = 0
  multActionData.BeInviteId = 0
  multActionData.ActionType = E.MultActionType.Null
  Z.PlayerInputController:PlayMultAction(false)
  Z.MultActionMgr:EndAction()
end
local notifyIsAgree = function(vInviteeId, vActionId, vIsAgree)
  Z.GlobalTimerMgr:StopTimer(E.GlobalTimerTag.MultActionInvite)
  if vIsAgree then
    multActionData.ActionType = E.MultActionType.ActionIng
    Z.MultActionMgr:SetInvite(vInviteeId, vActionId)
    if Z.UIMgr:IsActive("expression") then
      Z.LuaBridge.BakeMesh(true)
      Z.UIMgr:CloseView("expression")
    end
    Z.IgnoreMgr:SetInputIgnore(4294967295, false, Panda.ZGame.EIgnoreMaskSource.EUIMultiAction)
  else
    multActionData.ActionType = E.MultActionType.Null
    Z.IgnoreMgr:SetInputIgnore(4294967295, false, Panda.ZGame.EIgnoreMaskSource.EUIMultiAction)
    Z.TipsVM.ShowTipsLang(1000020)
  end
end
local getCheckCode = function(id)
  local charId = id
  if id == nil or id == 0 then
    id = multActionData.SelectInviteId
  end
  local checkCode = Z.MultActionMgr:GetCheckCode(charId)
  return checkCode
end
local asyncCheckandSendInvite = function(charId, actionid, cancelkToken)
  if not Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.StatusHoldHand) then
    return
  end
  local checkCode = getCheckCode(charId)
  if checkCode == 0 then
    Z.IgnoreMgr:SetInputIgnore(4294967295, true, Panda.ZGame.EIgnoreMaskSource.EUIMultiAction)
    multActionData.ActionType = E.MultActionType.ActionInvite
    local ret = worldProxy.ApplicationInteraction(charId, actionid, cancelkToken)
    if ret == 0 then
      local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
      local name = ent:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
      local param = {
        player = {name = name}
      }
      Z.TipsVM.ShowTipsLang(1000021, param)
    else
      Z.IgnoreMgr:SetInputIgnore(4294967295, false, Panda.ZGame.EIgnoreMaskSource.EUIMultiAction)
      multActionData.ActionType = E.MultActionType.Null
      Z.TipsVM.ShowTips(ret)
    end
  elseif checkCode == 1 then
    Z.TipsVM.ShowTipsLang(1000023)
  else
    Z.TipsVM.ShowTipsLang(1000042)
  end
end
local setInviteId = function(charId)
  if multActionData.ActionType == E.MultActionType.ActionIng then
    return
  end
  multActionData.SelectInviteId = charId
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.RefreshMultiAction)
end
local resetInviteId = function()
  if multActionData.ActionType ~= E.MultActionType.Null then
    return
  end
  multActionData.SelectInviteId = 0
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.RefreshMultiAction)
end
local asyncCheckandReplyInvite = function(vOrigId, vActionId, vIsAgree, cancelkToken)
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if Z.PbEnum("EActorState", "ActorStateDefault") ~= stateID and Z.PbEnum("EActorState", "ActorStateAction") ~= stateID then
    Z.TipsVM.ShowTipsLang(1000023)
    return false
  end
  if not Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.StatusHoldHand) then
    Z.TipsVM.ShowTipsLang(1000023)
    return false
  end
  local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), vOrigId)
  local entStateID = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrState")).Value
  if vIsAgree and ent ~= nil and Z.PbEnum("EActorState", "ActorStateDefault") == entStateID then
    Z.PlayerInputController:PlayMultAction(true)
    multActionData.BeInviteId = vOrigId
    multActionData.ActionType = E.MultActionType.ActionIng
    local ret = worldProxy.ReplyApplicationResult(vOrigId, vActionId, vIsAgree, cancelkToken)
    if ret ~= 0 then
      cancelAction()
      Z.TipsVM.ShowTips(ret)
    end
  else
    cancelAction()
    local ret = worldProxy.ReplyApplicationResult(vOrigId, vActionId, vIsAgree, cancelkToken)
    Z.TipsVM.ShowTips(ret)
  end
  return true
end
local applyMultAcionTipsCall = function(callData, flag, cancelSource)
  asyncCheckandReplyInvite(callData.vOrigId, callData.vActionId, flag, cancelSource:CreateToken())
end
local applyMultAcionTips = function(vOrigId, vActionId)
  local info = {
    charId = vOrigId,
    tipsType = E.InvitationTipsType.MultActionInvite,
    content = Lang("EmoteInvitationTitle"),
    cd = Z.Global.EmoteMPInvitationTime,
    func = applyMultAcionTipsCall,
    path = GetLoadAssetPath(Z.ConstValue.ActionTipsInviteTpl),
    funcParam = {vOrigId = vOrigId, vActionId = vActionId}
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end
local notifyInvite = function(vOrigId, vActionId)
  Z.MultActionMgr:SetBeInviteId(vOrigId, vActionId)
  applyMultAcionTips(vOrigId, vActionId)
end
local notVaildMultAction = function(vOrigId, vActionId)
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = E.InvitationTipsType.MultActionInvite .. "_" .. vOrigId
    Z.EventMgr:Dispatch(Z.ConstValue.InvitationClearTipsUnit, unitName)
    local cancelSource = Z.CancelSource.Rent()
    asyncCheckandReplyInvite(vOrigId, vActionId, false, cancelSource:CreateToken())
    cancelSource:Recycle()
    Z.MultActionMgr:RemoveBeInviteId(vOrigId)
  end)()
end
local asyncCancelAction = function(cancelToken)
  worldProxy.CancelAction(cancelToken)
end
local notifyCancelAction = function(vCancelCharId)
  cancelAction()
end
local ret = {
  AsyncCheckandSendInvite = asyncCheckandSendInvite,
  NotifyIsAgree = notifyIsAgree,
  SetInviteId = setInviteId,
  ResetInviteId = resetInviteId,
  AsyncCheckandReplyInvite = asyncCheckandReplyInvite,
  NotifyInvite = notifyInvite,
  NotVaildMultAction = notVaildMultAction,
  AsyncCancelAction = asyncCancelAction,
  NotifyCancelAction = notifyCancelAction
}
return ret
