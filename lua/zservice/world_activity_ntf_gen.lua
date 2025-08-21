local pb = require("pb2")
local impl = require("zservice/world_activity_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 368641 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldActivityNtf.WorldActivityInfoNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(936649811, 368641, cJson.encode(pbMsg), pbData, true)
      end
      impl:WorldActivityInfoNtf(call, pbMsg.info)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(936649811, "WorldActivityNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
