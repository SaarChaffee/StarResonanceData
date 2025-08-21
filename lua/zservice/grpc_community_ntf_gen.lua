local pb = require("pb2")
local impl = require("zservice/grpc_community_ntf_impl")
local OnCreateStub = function()
  impl:OnCreateStub()
end
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local OnCallStub = function(call)
  xpcall(function()
    if call:GetMethodId() == 1 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyHomelandWarehouseGridChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 1, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyHomelandWarehouseGridChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 2 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityApplyUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 2, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityApplyUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 3 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityInfoUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 3, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityInfoUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 4 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityTransferInfoUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 4, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityTransferInfoUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 5 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityNameChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 5, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityNameChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 6 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityIntroductionChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 6, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityIntroductionChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 7 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityCheckInChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 7, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityCheckInChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 8 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyHomelandBuildFurnitureOp", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 8, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyHomelandBuildFurnitureOp(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 9 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityCohabitantInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 9, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityCohabitantInfo(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 10 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityTransferChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 10, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityTransferChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 12 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityGlobalAuthorityChange", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 12, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityGlobalAuthorityChange(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 13 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityLevelUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 13, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityLevelUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 14 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityCleanlinessUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 14, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityCleanlinessUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 15 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityHomeLandClutterInfoAdd", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 15, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityHomeLandClutterInfoAdd(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 16 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityHomeLandClutterInfoRemove", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 16, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityHomeLandClutterInfoRemove(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 17 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyHomeLandPlayerTaskInfoUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 17, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyHomeLandPlayerTaskInfoUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 18 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityHomeLandSellShopUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 18, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityHomeLandSellShopUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 19 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityHomeLandDecorationInfo", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 19, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityHomeLandDecorationInfo(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 20 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityItemUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 20, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityItemUpdate(call, pbMsg.request)
      return
    end
    if call:GetMethodId() == 23 then
      local pbData = call:GetCallData()
      local pbMsg = pb.decode("zproto.GrpcCommunityNtf.NotifyCommunityFurnitureItemUpdate", pbData)
      if MessageInspectBridge.InInspectState == true then
        MessageInspectBridge.HandleReceiveMessage(1453563045, 23, cJson.encode(pbMsg), pbData, true)
      end
      impl:NotifyCommunityFurnitureItemUpdate(call, pbMsg.request)
      return
    end
  end, function(err)
    logError([[
error={0}
, stacktrace={1}]], err, debug.traceback())
  end)
end
local stub = ZCode.ZRpc.ZLuaStub.New()
stub:Init(1453563045, "GrpcCommunityNtf", OnCreateStub, OnCallStub)
ZCode.ZRpc.ZRpcCtrl.AddLuaStub(stub)
