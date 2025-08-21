local pb = require("pb2")
local impl = require("zservice/ace_sdk_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 2 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.AceSdkNtf.NotifyLoginAntiData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1239299317, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyLoginAntiData(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(1239299317, "AceSdkNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
