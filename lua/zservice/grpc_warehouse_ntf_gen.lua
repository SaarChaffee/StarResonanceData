local pb = require("pb2")
local impl = require("zservice/grpc_warehouse_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcWarehouseNtf.NotifyWarehouseInvite", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1406513963, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyWarehouseInvite(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcWarehouseNtf.NotifyWarehouseGridChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1406513963, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyWarehouseGridChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcWarehouseNtf.NotifyWarehousePassiveExist", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1406513963, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyWarehousePassiveExist(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 4 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcWarehouseNtf.NotifyWarehouseNewJoiner", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1406513963, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyWarehouseNewJoiner(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcWarehouseNtf.NotifyWarehouseRefuseToJoin", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1406513963, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyWarehouseRefuseToJoin(call, pbMsg.request)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(1406513963, "GrpcWarehouseNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
