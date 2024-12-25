local ConnectManager = class("ConnectManager")
local MAX_AUTO_RETRY_COUNT = 99999

function ConnectManager:ctor()
  self.connectInfos = {}
  self.timerMgr = Z.TimerMgr.new()
  self.channelTimerDict_ = {}
  Z.Rpc.SetOpenConnectFailedPanelFunc(function(onConfirm)
    self:openConnectFailedDlg(onConfirm)
  end)
  Z.Rpc.SetSetConnectionFlagFunc(function(channelType, isConnecting)
    Z.NetWaitHelper.SetConnectingTag(channelType, isConnecting)
  end)
end

function ConnectManager:getConnectInfo(channelType)
  local info = self.connectInfos[channelType]
  if not info then
    info = {
      ip = "",
      port = 0,
      retryCount = 0,
      reconnectEnabled = true
    }
    self.connectInfos[channelType] = info
  end
  return info
end

function ConnectManager:asyncReconnect(channelType)
  local connectInfo = self:getConnectInfo(channelType)
  if not connectInfo.reconnectEnabled then
    return
  end
  connectInfo.retryCount = connectInfo.retryCount + 1
  if connectInfo.retryCount > MAX_AUTO_RETRY_COUNT then
    connectInfo.retryCount = MAX_AUTO_RETRY_COUNT
  end
  local vm = Z.VMMgr.GetVM("login")
  if connectInfo.ip == "" or connectInfo.port == 0 then
    vm:KickOffByClient(E.KickOffClientErrCode.NotFoundServer)
    return
  end
  logGreen("begin reconnect retryCount={0}", connectInfo.retryCount)
  local res = self:AsyncConnect(channelType, connectInfo.ip, connectInfo.port)
  if res then
    Z.NetWaitHelper.SetConnectingTag(channelType, false)
    if vm:AsyncReconnect() then
      connectInfo.retryCount = 0
    end
  end
end

function ConnectManager:onDisconnect(channelType)
  local data = Z.DataMgr.Get("player_data")
  if not data.CharInfo then
    local vm = Z.VMMgr.GetVM("login")
    vm:KickOffByClient(E.KickOffClientErrCode.NoCharDisConnect)
    return
  end
  local connectInfo = self:getConnectInfo(channelType)
  if connectInfo.retryCount < MAX_AUTO_RETRY_COUNT then
    Z.NetWaitHelper.SetConnectingTag(channelType, true)
    self:createReconnectTimer(channelType)
  else
    self:openDisconnectDlg(channelType)
  end
end

function ConnectManager:createReconnectTimer(channelType)
  local curChannelType = channelType
  if self.channelTimerDict_[curChannelType] then
    return
  end
  self.channelTimerDict_[curChannelType] = self.timerMgr:StartTimer(function()
    self:clearReconnectTimer(curChannelType)
    Z.CoroUtil.coro_xpcall(function()
      self:asyncReconnect(curChannelType)
    end)
  end, 1)
end

function ConnectManager:clearReconnectTimer(channelType)
  if self.channelTimerDict_[channelType] then
    self.channelTimerDict_[channelType]:Stop()
    self.channelTimerDict_[channelType] = nil
  end
end

function ConnectManager:openDisconnectDlg(channelType)
  Z.NetWaitHelper.SetConnectingTag(channelType, false)
  local onConfirm = function()
    Z.DialogViewDataMgr:CloseDialogView()
    Z.NetWaitHelper.SetConnectingTag(channelType, true)
    self:asyncReconnect(channelType)
  end
  local onCancel = function()
    Z.DialogViewDataMgr:CloseDialogView()
    self:Disconnect(channelType)
    local vm = Z.VMMgr.GetVM("login")
    vm:Logout()
  end
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescReconnect"), onConfirm, onCancel, E.EDialogViewDataType.System, false)
end

function ConnectManager:openConnectFailedDlg(onConfirm)
  local abortReconnect = function()
    Z.DialogViewDataMgr:CloseDialogView()
    local vm = Z.VMMgr.GetVM("login")
    vm:Logout()
  end
  if onConfirm == nil then
    Z.DialogViewDataMgr:OpenOKDialog(Lang("DescDisconnect"), abortReconnect, E.EDialogViewDataType.System, false)
  else
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("DescReconnect"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      onConfirm:Invoke()
    end, abortReconnect, E.EDialogViewDataType.System, false)
  end
end

function ConnectManager:Disconnect(channelType)
  local connectInfo = self:getConnectInfo(channelType)
  connectInfo.ip = ""
  connectInfo.port = 0
  Z.Rpc.Disconnect(channelType, true)
end

function ConnectManager:SetReconnectEnabled(channelType, enabled)
  self:getConnectInfo(channelType).reconnectEnabled = enabled
end

function ConnectManager:AsyncConnect(channelType, ip, port)
  self:SetReconnectEnabled(channelType, true)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.Rpc.LuaConnect)
  local ret = false
  local status, err = pcall(function()
    ret = asyncCall(channelType, ip, port, 262144, 131072, 2000, function()
      self:onDisconnect(channelType)
    end)
    local connectInfo = self:getConnectInfo(channelType)
    connectInfo.ip = ip
    connectInfo.port = port
  end)
  if not status then
    logError("connect {0}:{1} failed, err={2}", ip, port, table.ztostring(err))
  end
  return ret
end

return ConnectManager
