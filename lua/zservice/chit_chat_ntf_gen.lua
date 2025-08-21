local pb = require("pb2")
local impl = require("zservice/chit_chat_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.ChitChatNtf.NotifyNewestChitChatMsgs", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(164931432, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyNewestChitChatMsgs(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.ChitChatNtf.NotifyBeMuted", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(164931432, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyBeMuted(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.ChitChatNtf.NotifyAddPrivateChatSession", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(164931432, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyAddPrivateChatSession(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 4 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.ChitChatNtf.NotifyClearChatHistory", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(164931432, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyClearChatHistory(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(164931432, "ChitChatNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
