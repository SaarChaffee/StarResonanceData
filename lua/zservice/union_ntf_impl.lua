local pb = require("pb2")
local UnionNtfStubImpl = {}

function UnionNtfStubImpl:OnCreateStub()
end

function UnionNtfStubImpl:NotifyUnionInfo(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyUnionInfo(vRequest)
end

function UnionNtfStubImpl:NotifyOfficialLimitUpdate(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyOfficialLimitUpdate(vRequest)
end

function UnionNtfStubImpl:NotifyUnionChangeName(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyUnionChangeName(vRequest)
end

function UnionNtfStubImpl:NotifyCreateUnionResult(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyCreateUnionResult(vRequest)
end

function UnionNtfStubImpl:NotifyUpdateMember(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyUpdateMember(vRequest)
end

function UnionNtfStubImpl:NotifyRequestListNum(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyRequestListNum(vRequest)
end

function UnionNtfStubImpl:NotifyInviteJoinUnion(call, vRequest)
  local unionInviteFunc = function(callData, flag, cancelSource)
    local unionVM = Z.VMMgr.GetVM("union")
    if flag then
      unionVM:AsyncReqJoinUnions({
        callData.unionId
      }, false, cancelSource:CreateToken())
    else
      unionVM:AsyncReqRefuseUnionInvite(callData.inviteId, cancelSource:CreateToken())
    end
  end
  local placeHolderParam = {
    guild = {
      name = vRequest.unionName
    }
  }
  local info = {
    charId = vRequest.InviteId,
    tipsType = E.InvitationTipsType.Invite,
    content = Lang("RequestToJoinUnion", placeHolderParam),
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {
      inviteId = vRequest.InviteId,
      unionId = vRequest.unionId
    }
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function UnionNtfStubImpl:NotifyUnionActivity(call, vRequest)
  local unionInviteFunc = function(callData, flag, cancelSource)
    local unionVM = Z.VMMgr.GetVM("union")
    if flag then
      unionVM:EnterUnionSceneHunt()
    end
  end
  local teamTipData_ = Z.DataMgr.Get("team_tip_data")
  local content_ = ""
  if vRequest.activityId == E.UnionActivityType.UnionHunt then
    if vRequest.notifyType == 1 then
      content_ = Lang("UnionHuntEnterNotice")
    elseif vRequest.notifyType == 2 or vRequest.notifyType == 3 then
      content_ = Lang("UnionHuntStartNotice")
    end
  elseif vRequest.activityId == E.UnionActivityType.UnionDance then
  end
  local info = {
    charId = "",
    tipsType = E.InvitationTipsType.UnionHunt,
    content = content_,
    cd = Z.Global.TeamInviteLastTime,
    func = unionInviteFunc,
    funcParam = {}
  }
  teamTipData_:SetCacheData(info)
end

function UnionNtfStubImpl:NotifyUnionActivityProgress(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  unionVM:OnNotifyHuntProgressAward(vRequest)
end

function UnionNtfStubImpl:NotifyUnionResourceChange(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  local isShowTip = vRequest.donorMemId and vRequest.donorMemId == Z.ContainerMgr.CharSerialize.charBase.charId
  unionVM:CacheResourceInfo(vRequest.changeResourceLib, isShowTip)
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionResourceChange)
end

function UnionNtfStubImpl:NotifyUnionSubFuncUnlock(call, vRequest)
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionSceneUnLock)
end

function UnionNtfStubImpl:NotifyBuildingUpgradeEnd(call, vRequest)
  local unionData = Z.DataMgr.Get("union_data")
  local buildId = vRequest.buildingId
  local buildLv = vRequest.buildLevel
  if unionData.BuildInfo[buildId] == nil then
    unionData.BuildInfo[buildId] = {}
  end
  unionData.BuildInfo[buildId].buildingId = buildId
  unionData.BuildInfo[buildId].buildingLevel = buildLv
  unionData.BuildInfo[buildId].upgradeFinishTime = 0
  unionData.BuildInfo[buildId].hasSpeedUpSec = 0
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildInfoChange)
end

function UnionNtfStubImpl:NotifyEffectBufChange(call, vRequest)
  local unionData = Z.DataMgr.Get("union_data")
  if vRequest.setEffectBuff then
    unionData.BuildBuffInfo[vRequest.setEffectBuff.buffPos + 1] = vRequest.setEffectBuff
  end
  if vRequest.cancelEffectBuff then
    unionData.BuildBuffInfo[vRequest.cancelEffectBuff.buffPos + 1] = nil
  end
  Z.EventMgr:Dispatch(Z.ConstValue.UnionActionEvt.UnionBuildBuffInfoChange, true)
end

function UnionNtfStubImpl:NotifyUnionOfficialChange(call, vRequest)
  local unionVM = Z.VMMgr.GetVM("union")
  if vRequest.unionOfficial then
    unionVM:UpdateUnionOfficialsByNotify(vRequest.unionOfficial)
  end
end

return UnionNtfStubImpl
