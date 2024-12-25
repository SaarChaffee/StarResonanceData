local pb = require("pb2")
local impl = require("zservice/level_ntf_impl")
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
      local pbMsg = pb.decode("zproto.LevelNtf.DisplayBossUI", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(656251580, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:DisplayBossUI(call, pbMsg.isEnter, pbMsg.bossUuid)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = ""
      if call:GetCallDataSize() > 0 then
        pbData = string.sub(call:GetCallData(), 0, call:GetCallDataSize())
      end
      local pbMsg = pb.decode("zproto.LevelNtf.DisplayBossOutOverdriveUI", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(656251580, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:DisplayBossOutOverdriveUI(call, pbMsg.isBreak, pbMsg.isWeak)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(656251580, "LevelNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
