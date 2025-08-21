local pb = require("pb2")
local impl = require("zservice/world_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 14 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncPioneerInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 14, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncPioneerInfo(call, pbMsg.targetId, pbMsg.targetNum)
      return
    end
    if call:GetMethodId() == 18 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncSwitchChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 18, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncSwitchChange(call, pbMsg.id, pbMsg.onOff)
      return
    end
    if call:GetMethodId() == 19 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncSwitchInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 19, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncSwitchInfo(call, pbMsg.info)
      return
    end
    if call:GetMethodId() == 20 then
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 20, "No param", null, true)
      end
      impl:EnterGame(call)
      return
    end
    if call:GetMethodId() == 21 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncContainerData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 21, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncContainerData(call, pbMsg.vData)
      return
    end
    if call:GetMethodId() == 23 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncDungeonData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 23, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncDungeonData(call, pbMsg.vData)
      return
    end
    if call:GetMethodId() == 25 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.AwardNotify", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 25, cJson.encode(pbMsg), pbData, true)
      end
      impl:AwardNotify(call, pbMsg.award)
      return
    end
    if call:GetMethodId() == 26 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.CardInfoAck", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 26, cJson.encode(pbMsg), pbData, true)
      end
      impl:CardInfoAck(call, pbMsg.charId, pbMsg.info)
      return
    end
    if call:GetMethodId() == 27 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncSeason", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 27, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncSeason(call, pbMsg.vSeason)
      return
    end
    if call:GetMethodId() == 28 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.UserAction", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 28, cJson.encode(pbMsg), pbData, true)
      end
      impl:UserAction(call, pbMsg.vCharId, pbMsg.vActionId)
      return
    end
    if call:GetMethodId() == 29 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyDisplayPlayHelp", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 29, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyDisplayPlayHelp(call, pbMsg.vPlayHelpId)
      return
    end
    if call:GetMethodId() == 30 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyApplicationInteraction", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 30, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyApplicationInteraction(call, pbMsg.vOrigId, pbMsg.vActionId)
      return
    end
    if call:GetMethodId() == 31 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyIsAgree", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 31, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyIsAgree(call, pbMsg.vInviteeId, pbMsg.vActionId, pbMsg.vIsAgree)
      return
    end
    if call:GetMethodId() == 32 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyCancelAction", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 32, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCancelAction(call, pbMsg.vCancelCharId)
      return
    end
    if call:GetMethodId() == 33 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyUploadPictureResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 33, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUploadPictureResult(call, pbMsg.success, pbMsg.photoType, pbMsg.photoId, pbMsg.photoName)
      return
    end
    if call:GetMethodId() == 36 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SyncInvite", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 36, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncInvite(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 37 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyRedDotChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 37, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRedDotChange(call, pbMsg.vRedDotId, pbMsg.vValue)
      return
    end
    if call:GetMethodId() == 38 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.ChangeNameResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 38, cJson.encode(pbMsg), pbData, true)
      end
      impl:ChangeNameResultNtf(call, pbMsg.vCode)
      return
    end
    if call:GetMethodId() == 39 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyReviveUser", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 39, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyReviveUser(call, pbMsg.vActorUuid)
      return
    end
    if call:GetMethodId() == 40 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyParkourRankInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 40, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyParkourRankInfo(call, pbMsg.vRankId)
      return
    end
    if call:GetMethodId() == 41 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyParkourRecordInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 41, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyParkourRecordInfo(call, pbMsg.result, pbMsg.vRecord)
      return
    end
    if call:GetMethodId() == 42 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyShowTips", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 42, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyShowTips(call, pbMsg.vTips)
      return
    end
    if call:GetMethodId() == 44 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyNoticeInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 44, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyNoticeInfo(call, pbMsg.vInfo)
      return
    end
    if call:GetMethodId() == 49 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyClientKickOff", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 49, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyClientKickOff(call, pbMsg.errCode)
      return
    end
    if call:GetMethodId() == 51 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.PaymentResponse", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 51, cJson.encode(pbMsg), pbData, true)
      end
      impl:PaymentResponse(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 53 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyUnlockCookBook", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 53, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnlockCookBook(call, pbMsg.vInfo)
      return
    end
    if call:GetMethodId() == 54 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyCustomEvent", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 54, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCustomEvent(call, pbMsg.eventParams)
      return
    end
    if call:GetMethodId() == 55 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyStartPlayingDungeon", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 55, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyStartPlayingDungeon(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 56 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.ChangeShowIdResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 56, cJson.encode(pbMsg), pbData, true)
      end
      impl:ChangeShowIdResultNtf(call, pbMsg.errCode)
      return
    end
    if call:GetMethodId() == 57 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyShowItems", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 57, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyShowItems(call, pbMsg.vInfo)
      return
    end
    if call:GetMethodId() == 58 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifySeasonActivationTargetInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 58, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifySeasonActivationTargetInfo(call, pbMsg.vSeasonId, pbMsg.isRefresh)
      return
    end
    if call:GetMethodId() == 59 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyTextCheckResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 59, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTextCheckResult(call, pbMsg.errCode)
      return
    end
    if call:GetMethodId() == 61 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyDebugMessageTip", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 61, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyDebugMessageTip(call, pbMsg.vInfo)
      return
    end
    if call:GetMethodId() == 62 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyUserCloseFunction", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 62, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUserCloseFunction(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 63 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyServerCloseFunction", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 63, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyServerCloseFunction(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 69 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyAwardAllItems", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 69, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyAwardAllItems(call, pbMsg.vAllItem)
      return
    end
    if call:GetMethodId() == 70 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyAllMemberReady", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 70, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyAllMemberReady(call, pbMsg.vOpenOrClose)
      return
    end
    if call:GetMethodId() == 71 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyCaptainReady", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 71, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCaptainReady(call, pbMsg.vMemberName, pbMsg.vCharId, pbMsg.vReadyInfo)
      return
    end
    if call:GetMethodId() == 74 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyUserAllSourcePrivilegeEffectData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 74, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUserAllSourcePrivilegeEffectData(call, pbMsg.vAllPrivilegeEffects)
      return
    end
    if call:GetMethodId() == 75 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyQuestAccept", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 75, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyQuestAccept(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 76 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyQuestChangeStep", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 76, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyQuestChangeStep(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 77 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyQuestGiveUp", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 77, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyQuestGiveUp(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 78 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyQuestComplete", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 78, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyQuestComplete(call, pbMsg.vParam)
      return
    end
    if call:GetMethodId() == 79 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyUserAllValidBattlePassData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 79, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUserAllValidBattlePassData(call, pbMsg.validBattlePassData)
      return
    end
    if call:GetMethodId() == 12289 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.QteBegin", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 12289, cJson.encode(pbMsg), pbData, true)
      end
      impl:QteBegin(call, pbMsg.qteId)
      return
    end
    if call:GetMethodId() == 24577 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.QuestAbort", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 24577, cJson.encode(pbMsg), pbData, true)
      end
      impl:QuestAbort(call, pbMsg.questId)
      return
    end
    if call:GetMethodId() == 167937 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyBuyShopResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 167937, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyBuyShopResult(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 167938 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyShopItemCanBuy", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 167938, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyShopItemCanBuy(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 286721 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.WorldBossRankInfoNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 286721, cJson.encode(pbMsg), pbData, true)
      end
      impl:WorldBossRankInfoNtf(call, pbMsg.rankInfo)
      return
    end
    if call:GetMethodId() == 294913 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.EnterMatchResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 294913, cJson.encode(pbMsg), pbData, true)
      end
      impl:EnterMatchResultNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 315393 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyDriverApplyRide", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 315393, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyDriverApplyRide(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 315394 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyInviteApplyRide", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 315394, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyInviteApplyRide(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 315395 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyRideIsAgree", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 315395, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRideIsAgree(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 331777 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyPayInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 331777, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyPayInfo(call, pbMsg.param)
      return
    end
    if call:GetMethodId() == 335873 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyLifeProfessionWorkHistoryChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 335873, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyLifeProfessionWorkHistoryChange(call, pbMsg.info)
      return
    end
    if call:GetMethodId() == 335874 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.NotifyLifeProfessionUnlockRecipe", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 335874, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyLifeProfessionUnlockRecipe(call, pbMsg.info)
      return
    end
    if call:GetMethodId() == 385025 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldNtf.SignRewardNotify", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1664308034, 385025, cJson.encode(pbMsg), pbData, true)
      end
      impl:SignRewardNotify(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(1664308034, "WorldNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
