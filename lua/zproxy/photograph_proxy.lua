local pb = require("pb2")
local coro_util = require("zutil/coro_util")
local pxy = ZCode.ZRpc.ZLuaProxy.New()
local zrpcCtrl = ZCode.ZRpc.ZRpcCtrl
local zrpcError = ZCode.ZRpc.ZRpcError
local zrpcCallRegister = ZCode.ZRpc.ZRpcCallRegister
pxy:Init(904190988, "Photograph")
zrpcCtrl.AddLuaProxy(pxy)
local channelType = zrpcCtrl.GetChannelTypeByProxyId(904190988)
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local PhotographProxy = {}

function PhotographProxy.GetPhotoUpToken(vRequest)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetPhotoUpToken", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 1, cJson.encode(pbMsg), pbData, true)
  end
  local err = zrpcCtrl.LuaProxyNotify(pxy, 1, pbData, true)
  if err ~= zrpcError.None then
    error(tostring(err))
  end
end

function PhotographProxy.DeletePhoto(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.DeletePhoto", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 2, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 2, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 2, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 2, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 2, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 2, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 2, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.DeletePhoto_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 2, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.GetAllAlbums(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetAllAlbums", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 3, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 3, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 3, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 3, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 3, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 3, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 3, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.GetAllAlbums_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 3, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.GetAlbumPhotos(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetAlbumPhotos", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 4, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 4, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 4, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 4, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 4, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 4, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 4, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.GetAlbumPhotos_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 4, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.CreateAlbum(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.CreateAlbum", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 5, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 5, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 5, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 5, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 5, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 5, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 5, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.CreateAlbum_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 5, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.DeleteAlbum(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.DeleteAlbum", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 6, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 6, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 6, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 6, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 6, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 6, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 6, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.DeleteAlbum_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 6, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.EditAlbumRight(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.EditAlbumRight", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 7, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 7, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 7, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 7, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 7, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 7, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 7, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.EditAlbumRight_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 7, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.EditAlbumName(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.EditAlbumName", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 8, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 8, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 8, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 8, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 8, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 8, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 8, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.EditAlbumName_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 8, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.SetAlbumCover(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.SetAlbumCover", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 9, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 9, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 9, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 9, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 9, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 9, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 9, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.SetAlbumCover_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 9, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.MovePhotoToAlbum(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.MovePhotoToAlbum", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 10, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 10, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 10, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 10, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 10, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 10, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 10, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.MovePhotoToAlbum_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 10, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.GetAvatarToken(vRequest)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetAvatarToken", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 11, cJson.encode(pbMsg), pbData, true)
  end
  local err = zrpcCtrl.LuaProxyNotify(pxy, 11, pbData, true)
  if err ~= zrpcError.None then
    error(tostring(err))
  end
end

function PhotographProxy.GetPhoto(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetPhoto", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 12, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 12, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 12, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 12, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 12, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 12, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 12, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.GetPhoto_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 12, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.UploadPhotoSuccessful(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.UploadPhotoSuccessful", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 13, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 13, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 13, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 13, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 13, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 13, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 13, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.UploadPhotoSuccessful_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 13, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.GetReviewAvatarInfo(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetReviewAvatarInfo", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 14, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 14, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 14, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 14, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 14, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 14, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 14, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.GetReviewAvatarInfo_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 14, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.GetFuncPhotoList(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.GetFuncPhotoList", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 15, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 15, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 15, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 15, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 15, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 15, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 15, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.GetFuncPhotoList_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 15, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

function PhotographProxy.DelFuncPhoto(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Photograph.DelFuncPhoto", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(904190988, 16, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 16, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 16, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 16, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 16, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 16, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 904190988, 16, errorId)
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
  local pbRet = pb.decode("zproto.Photograph.DelFuncPhoto_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(904190988, 16, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

return PhotographProxy
