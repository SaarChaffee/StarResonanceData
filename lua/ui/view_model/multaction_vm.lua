local MultActionVM = {}
local multActionData = Z.DataMgr.Get("multaction_data")
local worldProxy = require("zproxy.world_proxy")

function MultActionVM.getOtherId()
  if multActionData.BeInviteId == 0 then
    return multActionData.SelectInviteId
  end
  if multActionData.SelectInviteId == 0 then
    return multActionData.BeInviteId
  end
  return 0
end

function MultActionVM.cancelAction(tipsId)
  multActionData.SelectInviteId = 0
  multActionData.BeInviteId = 0
  multActionData.ActionType = E.MultActionType.Null
  Z.PlayerInputController:PlayMultAction(false)
  Z.MultActionMgr:EndAction()
end

function MultActionVM.checkStageType()
  local currentStageType = Z.StageMgr.GetCurrentStageType()
  if currentStageType == Z.EStageType.City or currentStageType == Z.EStageType.Wild or currentStageType == Z.EStageType.CommunityDungeon or currentStageType == Z.EStageType.HomelandDungeon or currentStageType == Z.EStageType.UnionDungeon then
    return true
  end
  return false
end

function MultActionVM.NotifyIsAgree(vInviteeId, vActionId, vIsAgree)
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

function MultActionVM.getCheckCode(id)
  local charId = id
  if id == nil or id == 0 then
    id = multActionData.SelectInviteId
  end
  local checkCode = Z.MultActionMgr:GetCheckCode(charId)
  return checkCode
end

function MultActionVM.asyncCheckandSendInvite(charId, actionId, cancelToken)
  if not Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.StatusHoldHand) then
    return
  end
  local checkCode = MultActionVM.getCheckCode(charId)
  if checkCode == 0 then
    Z.IgnoreMgr:SetInputIgnore(4294967295, true, Panda.ZGame.EIgnoreMaskSource.EUIMultiAction)
    multActionData.ActionType = E.MultActionType.ActionInvite
    local ret = worldProxy.ApplicationInteraction(charId, actionId, cancelToken)
    if ret == 0 then
      local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), charId)
      if ent then
        local name = ent:GetLuaAttr(Z.PbAttrEnum("AttrName")).Value
        local param = {
          player = {name = name}
        }
        Z.TipsVM.ShowTipsLang(1000021, param)
      end
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

function MultActionVM.PlayMultAction(actionId, cancelSource)
  if Z.EntityMgr.PlayerEnt == nil then
    logError("PlayerEnt is nil")
    return
  end
  if not MultActionVM.checkStageType() then
    Z.TipsVM.ShowTipsLang(1000051)
    return
  end
  if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EMultiActionState).Value == 0 then
    Z.CoroUtil.create_coro_xpcall(function()
      if multActionData.SelectInviteId ~= 0 then
        MultActionVM.asyncCheckandSendInvite(multActionData.SelectInviteId, actionId, cancelSource:CreateToken())
      else
        Z.TipsVM.ShowTipsLang(1000022)
      end
    end)()
  else
    Z.TipsVM.ShowTipsLang(1000023)
  end
end

function MultActionVM.SetInviteId(charId)
  if multActionData.ActionType == E.MultActionType.ActionIng then
    return
  end
  multActionData.SelectInviteId = charId
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.RefreshMultiAction)
end

function MultActionVM.ResetInviteId()
  if multActionData.ActionType ~= E.MultActionType.Null then
    return
  end
  multActionData.SelectInviteId = 0
  Z.EventMgr:Dispatch(Z.ConstValue.Expression.RefreshMultiAction)
end

function MultActionVM.asyncCheckandReplyInvite(vOrigId, vActionId, vIsAgree, cancelToken)
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return false
  end
  if not MultActionVM.checkStageType() then
    return false
  end
  local stateID = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if Z.PbEnum("EActorState", "ActorStateDefault") ~= stateID and Z.PbEnum("EActorState", "ActorStateAction") ~= stateID then
    Z.TipsVM.ShowTipsLang(1000023)
    return false
  end
  if not Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.StatusHoldHand) then
    Z.TipsVM.ShowTipsLang(1000023)
    return false
  end
  local ent = Z.EntityMgr:GetEntity(Z.PbEnum("EEntityType", "EntChar"), vOrigId)
  local entStateID = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  if vIsAgree and ent ~= nil and Z.PbEnum("EActorState", "ActorStateDefault") == entStateID then
    Z.PlayerInputController:PlayMultAction(true)
    multActionData.BeInviteId = vOrigId
    multActionData.ActionType = E.MultActionType.ActionIng
    local ret = worldProxy.ReplyApplicationResult(vOrigId, vActionId, vIsAgree, cancelToken)
    if ret ~= 0 then
      MultActionVM.cancelAction()
      Z.TipsVM.ShowTips(ret)
    end
  else
    MultActionVM.cancelAction()
    local ret = worldProxy.ReplyApplicationResult(vOrigId, vActionId, vIsAgree, cancelToken)
    Z.TipsVM.ShowTips(ret)
  end
  return true
end

function MultActionVM.applyMultActionTipsCall(callData, flag, cancelSource)
  MultActionVM.asyncCheckandReplyInvite(callData.vOrigId, callData.vActionId, flag, cancelSource:CreateToken())
end

function MultActionVM.applyMultActionTips(vOrigId, vActionId)
  local info = {
    charId = vOrigId,
    tipsType = E.InvitationTipsType.MultActionInvite,
    content = Lang("EmoteInvitationTitle"),
    cd = Z.Global.EmoteMPInvitationTime,
    func = MultActionVM.applyMultActionTipsCall,
    funcParam = {vOrigId = vOrigId, vActionId = vActionId}
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function MultActionVM.NotifyInvite(vOrigId, vActionId)
  if not MultActionVM.checkStageType() then
    return
  end
  local chatSettingVm = Z.VMMgr.GetVM("chat_setting")
  if not chatSettingVm.CheckApplyType(E.ESocialApplyType.EInteractiveApply, vOrigId) then
    return
  end
  Z.MultActionMgr:SetBeInviteId(vOrigId, vActionId)
  MultActionVM.applyMultActionTips(vOrigId, vActionId)
end

function MultActionVM.NotVaildMultAction(vOrigId, vActionId)
  Z.CoroUtil.create_coro_xpcall(function()
    local unitName = string.zconcat(E.InvitationTipsType.MultActionInvite, "_", vOrigId, "_", Lang("EmoteInvitationTitle"))
    Z.EventMgr:Dispatch(Z.ConstValue.InvitationClearTipsUnit, unitName)
    local cancelSource = Z.CancelSource.Rent()
    MultActionVM.asyncCheckandReplyInvite(vOrigId, vActionId, false, cancelSource:CreateToken())
    cancelSource:Recycle()
    Z.MultActionMgr:RemoveBeInviteId(vOrigId)
  end)()
end

function MultActionVM.AsyncCancelAction(cancelToken)
  worldProxy.CancelAction(cancelToken)
end

function MultActionVM.NotifyCancelAction(vCancelCharId)
  MultActionVM.cancelAction()
end

return MultActionVM
