local pb = require("pb2")
local impl = require("zservice/questionnaire_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.QuestionnaireNtf.NotifyQuestionnaireFinish", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(194476713, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyQuestionnaireFinish(call, pbMsg.request)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(194476713, "QuestionnaireNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
