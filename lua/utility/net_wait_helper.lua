local zrpcError = ZCode.ZRpc.ZRpcError
local zrpcCtrl = ZCode.ZRpc.ZRpcCtrl
local ErrorCode = {
  Timeout = zrpcError.Timeout:ToInt(),
  ProxyCallCanceled = zrpcError.ProxyCallCanceled:ToInt(),
  ReenterForbidden = zrpcError.ReenterForbidden:ToInt(),
  NoEnterScene = 1023,
  ModIDNotOpen = 1024
}
E.WaitingType = {
  None = 0,
  Rpc = 1,
  Sync = 2,
  Connecting = 3,
  Switching = 4,
  Pandora = 5
}
Z.RpcErrorCode = ErrorCode
local NetWaitHelper = class("NetWaitHelper")
local rpcMsgIdDic_ = {}
local syncMsgIdDic_ = {}
local worldConnectingTag_ = false
local gatewayConnectingTag_ = false
local sceneSwitchingTag_ = false
local pandoraWaitingTag_ = false

function NetWaitHelper.Init()
  NetWaitHelper.Clear()
  NetWaitHelper.RegisterRpcCallBack()
end

function NetWaitHelper.Clear()
  rpcMsgIdDic_ = {}
  syncMsgIdDic_ = {}
  worldConnectingTag_ = false
  gatewayConnectingTag_ = false
  sceneSwitchingTag_ = false
  pandoraWaitingTag_ = false
end

function NetWaitHelper.RegisterRpcCallBack()
  Z.RpcCallRegister.RegisterRpcBeginCall(function(serviceId, methodId)
    if rpcMsgIdDic_[serviceId] == nil then
      rpcMsgIdDic_[serviceId] = {}
    end
    rpcMsgIdDic_[serviceId][methodId] = true
    NetWaitHelper.checkLoadingView()
  end)
  Z.RpcCallRegister.RegisterRpcFinishCall(function(serviceId, methodId)
    if rpcMsgIdDic_[serviceId] == nil then
      rpcMsgIdDic_[serviceId] = {}
    end
    rpcMsgIdDic_[serviceId][methodId] = nil
    NetWaitHelper.checkLoadingView()
  end)
  Z.RpcCallRegister.RegisterRpcErrorHandler(function(serviceId, methodId, errorId)
    xpcall(function()
      if 0 < errorId then
        if errorId == ErrorCode.ProxyCallCanceled then
          error(ZUtil.ZCancelSource.CancelException)
        elseif errorId == ErrorCode.Timeout then
          zrpcCtrl.Disconnect(zrpcCtrl.GetChannelTypeByProxyId(serviceId))
          error(errorId)
        elseif errorId == ErrorCode.NoEnterScene then
          error(errorId)
        elseif errorId == ErrorCode.ModIDNotOpen then
          error(errorId)
        else
          zrpcCtrl.Disconnect(zrpcCtrl.GetChannelTypeByProxyId(serviceId))
          error(errorId)
        end
      end
    end, function(exception)
      if exception ~= ZUtil.ZCancelSource.CancelException then
        logError("[RpcException][serviceId={0}][methodId={1}][errorId={2}]{3}", serviceId, methodId, errorId, exception)
      end
    end)
  end)
end

function NetWaitHelper.AddSyncMsgId(mainKey, msgId)
  if syncMsgIdDic_[mainKey] == nil then
    syncMsgIdDic_[mainKey] = {}
  end
  syncMsgIdDic_[mainKey][msgId] = true
  NetWaitHelper.checkLoadingView()
end

function NetWaitHelper.RemoveSyncMsgId(mainKey, msgId)
  if syncMsgIdDic_[mainKey] == nil then
    syncMsgIdDic_[mainKey] = {}
  end
  syncMsgIdDic_[mainKey][msgId] = nil
  NetWaitHelper.checkLoadingView()
end

function NetWaitHelper.SetConnectingTag(channelType, isConnecting)
  if channelType == E.RpcChannelType.World then
    worldConnectingTag_ = isConnecting
  elseif channelType == E.RpcChannelType.Gateway then
    gatewayConnectingTag_ = isConnecting
  end
  NetWaitHelper.checkLoadingView()
end

function NetWaitHelper.IsConnecting()
  return worldConnectingTag_ or gatewayConnectingTag_
end

function NetWaitHelper.SetSwitchingTag(isSwitching)
  sceneSwitchingTag_ = isSwitching
  NetWaitHelper.checkLoadingView()
end

function NetWaitHelper.IsSwitching()
  return sceneSwitchingTag_
end

function NetWaitHelper.SetPandoraWaitingTag(isWaiting)
  pandoraWaitingTag_ = isWaiting
  NetWaitHelper.checkLoadingView()
end

function NetWaitHelper.IsPandoraWaiting()
  return pandoraWaitingTag_
end

function NetWaitHelper.checkLoadingView()
  local isWaitMsg, waitingType = NetWaitHelper.isWaitMsg()
  if isWaitMsg then
    Z.UIMgr:OpenView("main_waiting_tips", {WaitingType = waitingType})
  else
    Z.UIMgr:CloseView("main_waiting_tips")
  end
end

function NetWaitHelper.WaitingErrorHandler()
  Z.NetWaitHelper.Clear()
  Z.UIMgr:CloseView("main_waiting_tips")
  local vm = Z.VMMgr.GetVM("login")
  vm:KickOffByClient(E.KickOffClientErrCode.NetWaitHelper)
end

function NetWaitHelper.isWaitMsg()
  if NetWaitHelper.IsConnecting() then
    return true, E.WaitingType.Connecting
  end
  if NetWaitHelper.IsSwitching() then
    return true, E.WaitingType.Switching
  end
  if NetWaitHelper.IsPandoraWaiting() then
    return true, E.WaitingType.Pandora
  end
  for k, v in pairs(rpcMsgIdDic_) do
    if next(v) ~= nil then
      return true, E.WaitingType.Rpc
    end
  end
  for k, v in pairs(syncMsgIdDic_) do
    if next(v) ~= nil then
      return true, E.WaitingType.Sync
    end
  end
  return false, E.WaitingType.None
end

function NetWaitHelper.LogCurrentInfo()
  local rpcMsgIdDicLog = ""
  local syncMsgIdDicLog = ""
  for k, v in pairs(rpcMsgIdDic_) do
    for k1, v1 in pairs(v) do
      rpcMsgIdDicLog = string.zconcat(rpcMsgIdDicLog, "serviceId=", tostring(k), ", methodId=", tostring(k1), "||")
    end
  end
  for k, v in pairs(syncMsgIdDic_) do
    for k1, v1 in pairs(v) do
      syncMsgIdDicLog = string.zconcat(syncMsgIdDicLog, "mainKey=", tostring(k), ", msgId=", tostring(k1), "||")
    end
  end
  if rpcMsgIdDicLog ~= "" then
    logError("[WAITING_TIPS]" .. rpcMsgIdDicLog)
  end
  if syncMsgIdDicLog ~= "" then
    logError("[WAITING_TIPS]" .. syncMsgIdDicLog)
  end
  if gatewayConnectingTag_ == true or worldConnectingTag_ == true or sceneSwitchingTag_ == true or pandoraWaitingTag_ == true then
    logError(string.zconcat("[WAITING_TIPS]GateWayConnectingTag=", tostring(gatewayConnectingTag_), ", WorldConnectingTag=", tostring(worldConnectingTag_), ", SceneSwitchingTag=", tostring(sceneSwitchingTag_), ", PandoraWaitingTag=", tostring(pandoraWaitingTag_)))
  end
end

return NetWaitHelper
