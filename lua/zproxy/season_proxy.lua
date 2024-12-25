local pb = require("pb2")
local coro_util = require("zutil/coro_util")
local pxy = ZCode.ZRpc.ZLuaProxy.New()
local zrpcCtrl = ZCode.ZRpc.ZRpcCtrl
local zrpcError = ZCode.ZRpc.ZRpcError
local zrpcCallRegister = ZCode.ZRpc.ZRpcCallRegister
pxy:Init(99295807, "Season")
zrpcCtrl.AddLuaProxy(pxy)
local channelType = zrpcCtrl.GetChannelTypeByProxyId(99295807)
local cJson = require("cjson")
cJson.encode_sparse_array(true)
local SeasonProxy = {}

function SeasonProxy.GetSeasonDungeonList(vRequest, cancelToken)
  local pbMsg = {}
  pbMsg.vRequest = vRequest
  local pbData = pb.encode("zproto.Season.GetSeasonDungeonList", pbMsg)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleSendMessage(99295807, 1, cJson.encode(pbMsg), pbData, true)
  end
  local pxyCallFunc = coro_util.async_to_sync(zrpcCtrl.LuaProxyCall, 6)
  local pxyRet = pxyCallFunc(pxy, 1, pbData, true, true, cancelToken)
  local errorId = pxyRet:GetErrorId()
  if 0 < errorId then
    if errorId == zrpcError.ProxyCallCanceled:ToInt() then
      error(ZUtil.ZCancelSource.CancelException)
    elseif errorId == zrpcError.MethodNotFound:ToInt() then
      logError("[RpcError][MethodNotFound][serviceId={0}][methodId={1}][errorId={2}]", 99295807, 1, errorId)
      error(errorId)
    elseif errorId == zrpcError.Timeout:ToInt() then
      logError("[RpcError][Timeout][serviceId={0}][methodId={1}][errorId={2}]", 99295807, 1, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("NoEnterScene") then
      logError("[RpcError][NoEnterScene][serviceId={0}][methodId={1}][errorId={2}]", 99295807, 1, errorId)
      error(errorId)
    elseif errorId == Z.PbErrCode("ModIDNotOpen") then
      logError("[RpcError][ModIDNotOpen][serviceId={0}][methodId={1}][errorId={2}]", 99295807, 1, errorId)
      error(errorId)
    else
      logError("[RpcError][serviceId={0}][methodId={1}][errorId={2}]", 99295807, 1, errorId)
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
  local pbRet = pb.decode("zproto.Season.GetSeasonDungeonList_Ret", retData)
  if MessageInspectBridge.InInspectState == true then
    MessageInspectBridge.HandleReceiveMessage(99295807, 1, cJson.encode(pbRet), retData, true)
  end
  return pbRet.ret
end

return SeasonProxy
