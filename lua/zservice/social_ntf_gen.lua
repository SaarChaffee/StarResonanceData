local pb = require("pb2")
local impl = require("zservice/social_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.SocialNtf.NotifySocialData", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(625772963, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifySocialData(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(625772963, "SocialNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
