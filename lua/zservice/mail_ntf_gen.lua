local pb = require("pb2")
local impl = require("zservice/mail_ntf_impl")
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
      local pbMsg = pb.decode("zproto.MailNtf.SyncMailInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1753654261, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncMailInfo(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.MailNtf.SyncMailListNum", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1753654261, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncMailListNum(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.MailNtf.SyncNewMail", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1753654261, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:SyncNewMail(call, pbMsg.request)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(1753654261, "MailNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
