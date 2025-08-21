local pb = require("pb2")
local impl = require("zservice/world_login_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 4 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.WorldLoginNtf.NotifyInstructionInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(78136601, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyInstructionInfo(call, pbMsg.vInfo)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(78136601, "WorldLoginNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
