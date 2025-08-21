local pb = require("pb2")
local impl = require("zservice/match_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 4 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.MatchNtf.EnterMatchResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(822849903, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:EnterMatchResultNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.MatchNtf.CancelMatchResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(822849903, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:CancelMatchResultNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 6 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.MatchNtf.MatchReadyStatusNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(822849903, 6, cJson.encode(pbMsg), pbData, true)
      end
      impl:MatchReadyStatusNtf(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(822849903, "MatchNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
