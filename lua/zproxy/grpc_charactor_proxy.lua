local pb = require("pb2")
local coro_util = require("zutil/coro_util")
local pxy = ZCode.ZRpc.ZLuaProxy.New()
local zrpcCtrl = ZCode.ZRpc.ZRpcCtrl
local zrpcError = ZCode.ZRpc.ZRpcError
local zrpcCallRegister = ZCode.ZRpc.ZRpcCallRegister
pxy:Init(1232729813, "GrpcCharactor")
zrpcCtrl.AddLuaProxy(pxy)
local channelType = zrpcCtrl.GetChannelTypeByProxyId(1232729813)
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local GrpcCharactorProxy = {}

function GrpcCharactorProxy.Login(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.Login", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 1, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 1, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 1, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 1, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 1, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 1, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 1, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.Login_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 1, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.CreateChar(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.CreateChar", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 2, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 2, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 2, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 2, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 2, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 2, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 2, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.CreateChar_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 2, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.SelectChar(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.SelectChar", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 3, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 3, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 3, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 3, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 3, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 3, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 3, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.SelectChar_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 3, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.DeleteChar(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.DeleteChar", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 4, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 4, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 4, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 4, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 4, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 4, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 4, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.DeleteChar_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 4, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.Reconnect(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.Reconnect", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 5, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 5, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 5, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 5, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 5, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 5, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 5, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.Reconnect_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 5, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.ExitGame(vRequest)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.ExitGame", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 6, cJson.encode(pbMsg), pbData, true)
  end
  local err = zrpcCtrl.LuaProxyNotify(pxy, 6, pbData, true)
  if err ~= zrpcError.None then
    error(tostring(err))
  end
end

function GrpcCharactorProxy.SelectRunEditorChar(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.SelectRunEditorChar", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 7, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 7, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 7, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 7, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 7, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 7, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 7, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.SelectRunEditorChar_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 7, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.ReportMSdk(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.ReportMSdk", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 10, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 10, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 10, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 10, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 10, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 10, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 10, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.ReportMSdk_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 10, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.GetFaceUpToken(vRequest)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.GetFaceUpToken", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 17, cJson.encode(pbMsg), pbData, true)
  end
  local err = zrpcCtrl.LuaProxyNotify(pxy, 17, pbData, true)
  if err ~= zrpcError.None then
    error(tostring(err))
  end
end

function GrpcCharactorProxy.UploadFaceSuccess(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.UploadFaceSuccess", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 18, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 18, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 18, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 18, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 18, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 18, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 18, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.UploadFaceSuccess_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 18, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.GetFaceUploadData(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.GetFaceUploadData", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 19, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 19, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 19, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 19, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 19, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 19, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 19, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.GetFaceUploadData_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 19, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function GrpcCharactorProxy.GetFaceDataUrl(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.GrpcCharactor.GetFaceDataUrl", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(1232729813, 20, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 20, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 20, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 20, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 20, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 20, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 1232729813, 20, errorId)
      if errorId < 1000 then
        zrpcCtrl.Disconnect(channelType)
      end
      error(errorId)
    end
  end
  local retData = ""
  if 0 < pxyRet:GetRetDataSize() then
    retData = string.sub(pxyRet:GetRetData(), 0, pxyRet:GetRetDataSize())
  end
  local pbRet = pb.decode("zproto.GrpcCharactor.GetFaceDataUrl_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(1232729813, 20, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

return GrpcCharactorProxy
