local pb = require("pb2")
local impl = require("zservice/photograph_ntf_impl")
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
      local pbMsg = pb.decode("zproto.PhotographNtf.GetPhotoTokenNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(829259716, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:GetPhotoTokenNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.PhotographNtf.UploadPhotoResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(829259716, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:UploadPhotoResultNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.PhotographNtf.UploadPictureResultNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(829259716, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:UploadPictureResultNtf(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 4 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.PhotographNtf.RetAvatarToken", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(829259716, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:RetAvatarToken(call, pbMsg.vRequest)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.PhotographNtf.ReviewAvatarInfoNtf", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(829259716, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:ReviewAvatarInfoNtf(call, pbMsg.vRequest)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(829259716, "PhotographNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
