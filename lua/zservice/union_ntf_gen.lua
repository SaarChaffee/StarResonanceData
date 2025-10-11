local pb = require("pb2")
local impl = require("zservice/union_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionInfo(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyOfficialLimitUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyOfficialLimitUpdate(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUpdateMember", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUpdateMember(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 6 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyRequestListNum", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 6, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRequestListNum(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 7 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyInviteJoinUnion", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 7, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyInviteJoinUnion(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 8 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionActivity", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 8, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionActivity(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 9 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionActivityProgress", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 9, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionActivityProgress(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 10 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionResourceChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 10, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionResourceChange(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 11 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyBuildingUpgradeEnd", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 11, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyBuildingUpgradeEnd(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 12 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyEffectBufChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 12, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyEffectBufChange(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 13 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionOfficialChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 13, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionOfficialChange(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 14 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyUnionSubFuncUnlock", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 14, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyUnionSubFuncUnlock(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 15 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.UnionNtf.NotifyMemberOnline", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(504281929, 15, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyMemberOnline(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(504281929, "UnionNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
