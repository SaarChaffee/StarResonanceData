local pb = require("pb2")
local impl = require("zservice/grpc_team_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NoticeUpdateTeamInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NoticeUpdateTeamInfo(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NoticeUpdateTeamMemberInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NoticeUpdateTeamMemberInfo(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyJoinTeam", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyJoinTeam(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 4 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyLeaveTeam", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyLeaveTeam(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyApplyJoin", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyApplyJoin(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 6 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyInvitation", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 6, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyInvitation(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 7 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyRefuseInvite", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 7, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRefuseInvite(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 8 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyLeaderApplyListSize", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 8, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyLeaderApplyListSize(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 9 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyApplyBeLeader", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 9, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyApplyBeLeader(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 10 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyRejectApplicant", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 10, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRejectApplicant(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 11 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyBeTransferLeader", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 11, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyBeTransferLeader(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 12 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyRefuseBeTransferLeader", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 12, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyRefuseBeTransferLeader(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 13 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NoticeTeamDissolve", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 13, cJson.encode(pbMsg), pbData, true)
      end
      impl:NoticeTeamDissolve(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 14 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamActivityState", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 14, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamActivityState(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 15 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.TeamActivityResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 15, cJson.encode(pbMsg), pbData, true)
      end
      impl:TeamActivityResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 16 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.TeamActivityListResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 16, cJson.encode(pbMsg), pbData, true)
      end
      impl:TeamActivityListResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 17 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.TeamActivityVoteResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 17, cJson.encode(pbMsg), pbData, true)
      end
      impl:TeamActivityVoteResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 18 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyCharMatchResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 18, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCharMatchResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 19 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMatchResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 19, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMatchResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 20 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyCharAbortMatch", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 20, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCharAbortMatch(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 21 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.UpdateTeamMemBeCall", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 21, cJson.encode(pbMsg), pbData, true)
      end
      impl:UpdateTeamMemBeCall(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 22 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMemBeCall", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 22, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMemBeCall(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 23 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMemBeCallResult", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 23, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMemBeCallResult(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 24 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamEnterErr", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 24, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamEnterErr(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 25 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMemMicrophoneStatusChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 25, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMemMicrophoneStatusChange(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 26 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMemsSpeakStatusChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 26, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMemsSpeakStatusChange(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 27 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.GrpcTeamNtf.NotifyTeamMemVoiceIdChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(966773353, 27, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyTeamMemVoiceIdChange(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(966773353, "GrpcTeamNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
