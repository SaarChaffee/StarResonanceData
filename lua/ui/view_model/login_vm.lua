local charactorProxy = require("zproxy.grpc_charactor_proxy")
local cjson = require("cjson")
local SDK_DEFINE = require("ui.model.sdk_define")
E.LoginState = {
  Init = "Init",
  AutoLoginAccount = "AutoLoginAccount",
  LoginAccount = "LoginAccount",
  GetServerList = "GetServerList",
  EnterGame = "EnterGame",
  CheckVersion = "CheckVersion",
  WaitingConnect = "WaitingConnect"
}
E.ServerStatus = {
  Normal = 1,
  NotOpen = 2,
  Maintain = 3
}
E.KickOffClientErrCode = {
  Unknown = 0,
  NormalReturn = 1,
  SocketConnectError = 2,
  NotFoundServer = 3,
  NetWaitHelper = 4,
  LoginError = 5,
  RepeatCreateChar = 6,
  UnderageLimit = 7,
  NoCharDisConnect = 8,
  Reconnect = 9,
  Teleport = 10,
  BeginSwitch = 11,
  Switch = 12,
  EndSwitch = 13,
  AntiCheating = 14
}
local LoginVM = {}

function LoginVM:SDKAutoLogin()
  local sdkRoot = Z.UIRoot:GetSDKRootLayer()
  Z.SDKLogin.SetUIRoot(sdkRoot)
  Z.SDKLogin.AutoLogin()
end

function LoginVM:OnSDKAutoLogin(data)
  if data ~= nil and data.ErrorCode == 0 then
    local accountData = Z.DataMgr.Get("account_data")
    accountData.SDKType = data.SDKType
    accountData.LoginType = data.LoginTypeID
    accountData.OpenID = data.OpenID
    accountData.Token = data.Token
    accountData.Expire = data.Expire
    accountData.OS = data.OS
    accountData.PlatformType = data.Platform
    Z.SDKReport.SetInfo("GameUserID", data.OpenID)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSDKAutoLogin, data)
end

function LoginVM:SDKLogin(loginType, accountName)
  if loginType == E.LoginType.None then
    local data = {}
    data.ErrorCode = 0
    data.SDKType = 0
    data.LoginTypeID = 0
    data.OpenID = accountName
    data.Platform = E.LoginPlatformType.InnerPlatform
    data.Expire = data.Expire
    self:OnSDKLogin(data)
  else
    Z.SDKLogin.Login(loginType)
  end
end

function LoginVM:OnSDKLogin(data)
  if data == nil then
    Z.TipsVM.ShowTips(Lang("SDKLoginError"))
    self:Logout()
    return
  end
  if data ~= nil and data.ErrorCode == 0 then
    local accountData = Z.DataMgr.Get("account_data")
    accountData.SDKType = data.SDKType
    accountData.LoginType = data.LoginTypeID
    accountData.OpenID = data.OpenID
    accountData.Token = data.Token
    accountData.OS = data.OS
    accountData.PlatformType = data.Platform
    accountData.Expire = data.Expire
    Z.SDKReport.SetInfo("GameUserID", data.OpenID)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSDKLogin, data)
end

function LoginVM:GetDeviceInfo()
  local deviceInfo = {}
  deviceInfo.clientVersion = Z.GameContext.ResVersion
  deviceInfo.systemSoftware = UnityEngine.SystemInfo.operatingSystem
  deviceInfo.systemHardware = UnityEngine.SystemInfo.deviceModel
  deviceInfo.network = tostring(UnityEngine.Application.internetReachability)
  deviceInfo.screenWidth = UnityEngine.Screen.width
  deviceInfo.screenHight = UnityEngine.Screen.height
  deviceInfo.density = UnityEngine.Screen.dpi
  deviceInfo.cpuHardware = UnityEngine.SystemInfo.processorType .. "-" .. UnityEngine.SystemInfo.processorFrequency .. "-" .. UnityEngine.SystemInfo.processorCount
  deviceInfo.memory = UnityEngine.SystemInfo.systemMemorySize
  deviceInfo.glRender = UnityEngine.SystemInfo.graphicsDeviceName
  deviceInfo.gLVersion = UnityEngine.SystemInfo.graphicsDeviceVersion
  deviceInfo.deviceId = Z.SDKReport.DeviceID
  deviceInfo.channel = Z.SDKLogin.InstallChannel
  return deviceInfo
end

function LoginVM:AsyncReportMSDK(openId, ruleName, traceId)
  local request = {}
  request.openId = openId
  request.ruleName = ruleName
  request.traceId = traceId
  request.execTime = 0
  charactorProxy.ReportMSdk(request, ZUtil.ZCancelSource.NeverCancelToken)
end

function LoginVM:AsyncGetServerList()
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local curTime = os.time()
  local interval = curTime - serverData.LastGetTime
  if interval < 3 then
    return true
  end
  local cancelSource = Z.CancelSource.Rent()
  local request = Z.HttpRequest.Rent()
  request.Url = Panda.Core.GameContext.Domain
  request:AddHeader("version", Z.GameContext.Version)
  request:AddHeader("res_version", Z.GameContext.Version)
  request:AddHeader("openid", accountData.OpenID)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.HttpMgr.Get)
  local response = asyncCall(Z.HttpMgr, request, cancelSource:CreateToken())
  if response == nil or response.HasError or response.Value == "" then
    if response ~= nil then
      response:Recycle()
    end
    request:Recycle()
    cancelSource:Recycle()
    return false
  end
  local parameter
  xpcall(function()
    parameter = cjson.decode(response.Value).serverList
  end, function(msg)
    logError("[LoginVM] AsyncGetServerList Error : " .. msg)
  end)
  response:Recycle()
  request:Recycle()
  cancelSource:Recycle()
  if parameter == nil then
    return false
  end
  serverData.LastGetTime = os.time()
  serverData:SetServerData(parameter)
  Z.SDKReport.ReportEvent(Z.SDKReportEvent.GetServerList)
  return true
end

function LoginVM:AsyncLogin()
  local accountData = Z.DataMgr.Get("account_data")
  local request = {}
  request.openId = accountData.OpenID
  request.token = accountData.Token
  request.platformType = accountData.PlatformType
  request.sdkType = accountData.SDKType
  request.channelId = accountData.LoginType
  request.os = accountData.OS
  request.clientVersion = Z.GameContext.ResVersion
  request.deviceInfo = self:GetDeviceInfo()
  request.configVersion = Z.Version.ConfigVersion
  request.protocolVersion = Z.Version.ProtocolVersion
  request.areaId = Z.SDKLogin.InstallChannel
  if not Z.IsOfficalVersion then
    logError("Login Request={0}", table.ztostring(request))
  end
  if request.deviceInfo.deviceId == nil or request.deviceInfo.deviceId == UnityEngine.SystemInfo.unsupportedIdentifier then
    Z.DialogViewDataMgr:OpenOKDialog(Lang("DeviceIdError"), function()
      Z.DialogViewDataMgr:CloseDialogView()
      Z.GameContext.QuitGame()
    end, E.EDialogViewDataType.System, true)
    return
  end
  local reply
  for i = 1, 4 do
    reply = charactorProxy.Login(request, ZUtil.ZCancelSource.NeverCancelToken)
    if reply.errCode == Z.PbErrCode("ErrChangeMapErr") then
      logError("recv ErrChangeMapErr on Login, retryCount=" .. tostring(i))
      Z.Delay(i, ZUtil.ZCancelSource.NeverCancelToken)
    else
      break
    end
  end
  local playerData = Z.DataMgr.Get("player_data")
  if reply ~= nil and reply.errCode == 0 then
    playerData.AccountInfo = reply.accountInfo
    if reply.timeZone ~= nil then
      Z.ServerTime.ServiceTimeZone = reply.timeZone
    else
      Z.ServerTime.ServiceTimeZone = "Asia/Shanghai"
    end
    Z.SDKReport.ReportEvent(Z.SDKReportEvent.ServerConnected)
  else
    playerData:Clear()
  end
  return reply
end

function LoginVM:AsyncCreateChar(name, gender, bodySize, faceData, weaponId)
  local accountData = Z.DataMgr.Get("account_data")
  local playerData = Z.DataMgr.Get("player_data")
  local request = {}
  request.platformType = accountData.PlatformType
  request.openId = accountData.OpenID
  request.accountId = playerData.AccountInfo.accountId
  request.token = playerData.AccountInfo.token
  request.name = name
  request.gender = gender
  request.vBodySize = bodySize
  request.faceData = faceData
  request.initProfessionId = weaponId
  request.deviceInfo = self:GetDeviceInfo()
  request.areaId = Z.SDKLogin.InstallChannel
  local reply = charactorProxy.CreateChar(request, ZUtil.ZCancelSource.NeverCancelToken)
  return reply
end

function LoginVM:AsyncSelectChar(charId)
  local data = Z.DataMgr.Get("player_data")
  local request = {}
  request.charId = charId
  request.accountId = data.AccountInfo.accountId
  request.token = data.AccountInfo.token
  request.areaId = Z.SDKLogin.InstallChannel
  local reply
  for i = 1, 4 do
    if Z.GameContext.IsInRuntimeEditor then
      reply = charactorProxy.SelectRunEditorChar(request, ZUtil.ZCancelSource.NeverCancelToken)
    else
      reply = charactorProxy.SelectChar(request, ZUtil.ZCancelSource.NeverCancelToken)
    end
    if reply.errCode == Z.PbErrCode("ErrChangeMapErr") then
      logError("recv ErrChangeMapErr on SelectChar, retryCount=" .. tostring(i))
      Z.Delay(i, ZUtil.ZCancelSource.NeverCancelToken)
    else
      break
    end
  end
  return reply
end

function LoginVM:AsyncReconnect()
  local data = Z.DataMgr.Get("player_data")
  local request = {}
  request.charId = data.CharInfo.baseInfo.charId
  request.accountId = data.AccountInfo.accountId
  request.token = data.AccountInfo.token
  local reply = {}
  local status, err = pcall(function()
    for i = 1, 4 do
      reply = charactorProxy.Reconnect(request, ZUtil.ZCancelSource.NeverCancelToken)
      if reply.errCode == Z.PbErrCode("ErrChangeMapErr") then
        logError("recv ErrChangeMapErr on SelectChar, retryCount=" .. tostring(i))
        Z.Delay(i, ZUtil.ZCancelSource.NeverCancelToken)
      else
        break
      end
    end
  end)
  if reply.errCode == nil then
    logError("reconnect failed")
    self:KickOffByClient(E.KickOffClientErrCode.Reconnect)
    return false
  elseif reply.errCode ~= 0 then
    logError("reconnect failed, errcode={0}", reply.errCode)
    self:KickOffByServer(reply.errCode)
    return false
  end
  logGreen("reconnect success")
  Z.Game.OnReconnect()
  return true
end

function LoginVM:Logout(clearSDK)
  logYellow("logout, currentStage={0}", Z.StageMgr.GetCurrentStageType())
  Z.Game.OnLogout()
  if clearSDK then
    Z.SDKLogin.Logout()
  end
  Z.SDKAntiCheating.Logout()
  Z.ConnectMgr:Disconnect(E.RpcChannelType.Gateway)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.World)
  Z.DataMgr.Clear()
  Z.NetWaitHelper.Clear()
  Z.GlobalTimerMgr:Clear()
  Z.GuideMgr:Clear()
  if Z.StageMgr.GetIsInLogin() then
    if not Z.UIMgr:IsActive("login") then
      Z.UIMgr:DeActiveAll(true)
      Z.UIMgr:OpenView("login")
    end
    local needShowMark = Z.ScreenMark
    if needShowMark then
      local deviceInfo = self:GetDeviceInfo()
      Z.UIMgr:OpenView("mark_main", {
        key = deviceInfo.deviceId
      })
    end
  end
  Z.LuaBridge.Logout()
  Z.DialogViewDataMgr:ClearAll()
  Z.ContainerMgr:Reset()
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.SwitchLoginState, E.LoginState.Init)
  Z.SDKReport.SetInfo("GameUserID", "")
end

function LoginVM:KickOffByClient(clientErrCode, hideDialog)
  if clientErrCode ~= E.KickOffClientErrCode.NormalReturn then
    logError("KickOffByClient, errCode={0}", clientErrCode)
  end
  if hideDialog then
    self:Logout()
    return
  end
  local tempErrCode = string.zconcat("C", clientErrCode)
  Z.DialogViewDataMgr:OpenOKDialog(string.zconcat(Lang("DescDisconnect"), string.format(Lang("ErrcodeCommonTipsTitle"), tempErrCode)), function()
    Z.DialogViewDataMgr:CloseDialogView()
    self:Logout()
  end, E.EDialogViewDataType.System, true)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.Gateway)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.World)
  Z.NetWaitHelper.Clear()
  Z.UIMgr:CloseView("main_waiting_tips")
end

function LoginVM:KickOffByServer(errCode)
  if errCode == Z.PbEnum("EErrorCode", "ErrHopeKick") then
    return
  end
  logError("KickOffByServer, errCode={0}", errCode)
  local desc = ""
  if errCode ~= 0 then
    local errConfig = Z.TableMgr.GetTable("MessageTableMgr").GetRow(errCode)
    local tempErrCode = string.zconcat("S", errCode)
    if errConfig ~= nil then
      desc = string.zconcat(errConfig.Content, string.format(Lang("ErrcodeCommonTipsTitle"), tempErrCode))
    else
      desc = string.zconcat(Lang("DescDisconnect"), string.format(Lang("ErrcodeCommonTipsTitle"), tempErrCode))
    end
  end
  Z.DialogViewDataMgr:OpenOKDialog(desc, function()
    Z.DialogViewDataMgr:CloseDialogView()
    self:Logout()
  end, E.EDialogViewDataType.System, true)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.Gateway)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.World)
  Z.NetWaitHelper.Clear()
  Z.UIMgr:CloseView("main_waiting_tips")
end

function LoginVM:BeginCreateChar()
  local args = {}
  
  function args.EndCallback()
    Z.UIMgr:CloseView("login")
    local faceVM = Z.VMMgr.GetVM("face")
    faceVM.OpenFaceCreateView()
  end
  
  Z.UIMgr:FadeIn(args)
end

function LoginVM:BeginSelectChar(charId, errorFunc)
  local accountData = Z.DataMgr.Get("account_data")
  local success = Z.SDKAntiCheating.Login(accountData.OpenID, accountData.LoginType)
  if not success then
    self:KickOffByClient(E.KickOffClientErrCode.AntiCheating)
    return
  end
  local reply = self:AsyncSelectChar(charId)
  if reply.errCode ~= 0 then
    self:KickOffByServer(reply.errCode)
    if errorFunc then
      errorFunc()
    end
    return
  end
  local data = Z.DataMgr.Get("player_data")
  data.CharInfo = reply.charInfo
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSelectChar, charId)
  Z.Voice.Init(accountData.OpenID)
  logGreen("[Account]SelectChar success with return:{0}", table.ztostring(reply))
  Z.LuaBridge.Login()
end

function LoginVM:CheckServerStatus(serverAddr)
  local serverData = Z.DataMgr.Get("server_data")
  local serverId = serverData:GetServerId(serverAddr)
  if serverId == 0 then
    return true
  end
  local openTime = serverData.ServerMap[serverId].open_time
  local startTime = serverData.ServerMap[serverId].maintain_start_time
  local stopTime = serverData.ServerMap[serverId].maintain_stop_time
  if openTime == nil and startTime == nil and stopTime == nil then
    return true
  elseif openTime ~= nil and (startTime == nil or stopTime == nil) then
    return false
  end
  local serverStatus = E.ServerStatus.Normal
  local timeDiff = 3
  local localTime = os.time()
  if localTime < openTime + timeDiff then
    serverStatus = E.ServerStatus.NotOpen
  elseif localTime > startTime - timeDiff and localTime < stopTime + timeDiff then
    serverStatus = E.ServerStatus.Maintain
  end
  local showAnnouncementBtn = self:ShowAnnouncementBtn()
  if serverStatus == E.ServerStatus.Normal then
    return true
  elseif serverStatus == E.ServerStatus.NotOpen then
    local param = {open_time = openTime}
    local labDesc = Lang("ErrServerNotOpen", param)
    self:ShowServerDialogTip(labDesc, showAnnouncementBtn)
  elseif serverStatus == E.ServerStatus.Maintain then
    local param = {start_time = startTime, stop_time = stopTime}
    local labDesc = Lang("ErrServerDownWithTime", param)
    self:ShowServerDialogTip(labDesc, showAnnouncementBtn)
  end
  return false
end

function LoginVM:ShowAnnouncementBtn()
  local accountData = Z.DataMgr.Get("account_data")
  return accountData.SDKType ~= E.LoginSDKType.GLauncher
end

function LoginVM:ShowServerDialogTip(labDesc, showAnnouncementBtn)
  local onConfirm = function()
    if showAnnouncementBtn then
      local afficheVM = Z.VMMgr.GetVM("affiche")
      afficheVM.OpenAfficheView()
    end
    Z.DialogViewDataMgr:CloseDialogView()
  end
  local onCancel = function()
    Z.DialogViewDataMgr:CloseDialogView()
  end
  if showAnnouncementBtn then
    local dialogViewData = {
      dlgType = E.DlgType.YesNo,
      labDesc = labDesc,
      onConfirm = onConfirm,
      onCancel = onCancel,
      labYes = Lang("JumpToAnnouncement")
    }
    Z.DialogViewDataMgr:OpenDialogView(dialogViewData, E.EDialogViewDataType.System, true)
  else
    Z.DialogViewDataMgr:OpenOKDialog(labDesc, onConfirm, E.EDialogViewDataType.System, true)
  end
end

function LoginVM:AsyncAuth(serverAddr, accountName)
  Z.NetWaitHelper.SetConnectingTag(E.RpcChannelType.Gateway, true)
  self:SelectServerData(serverAddr)
  local data = Z.DataMgr.Get("player_data")
  data.AccountName = accountName
  local addrArr = string.zsplit(serverAddr, ":")
  local ip = addrArr[1]
  local port = tonumber(addrArr[2])
  logGreen("[Account]Begin Connect to {0}:{1}", ip, port)
  local success = Z.ConnectMgr:AsyncConnect(E.RpcChannelType.Gateway, ip, port)
  if success then
    xpcall(function()
      logGreen("[Account]Connect to {0}:{1} success", ip, port)
      local reply = self:AsyncLogin(accountName)
      if reply.errCode == 0 then
        if reply.accountInfo == nil then
          logError("[Account]Login faild with return:{0}", table.ztostring(reply))
          self:KickOffByClient(E.KickOffClientErrCode.LoginError)
          Z.NetWaitHelper.SetConnectingTag(E.RpcChannelType.Gateway, false)
          return
        end
        logGreen("[Account]Login success with return:{0}", table.ztostring(reply))
        Z.GameContext.ServerAddr = serverAddr
        local serverData = Z.DataMgr.Get("server_data")
        local serverInfo = string.format("%s=%s", serverData:GetDescriptionByAddr(serverAddr), serverAddr)
        Z.SDKReport.SetInfo("ServerInfo", serverInfo)
        self:SaveLocalAccountInfo(accountName)
        self:SaveLastLoginAddr(serverAddr)
        Z.Game.OnLogin()
        Z.LocalUserDataMgr.InitCurPlayerLocalUserData(reply.accountInfo.accountId)
        if 0 < #reply.accountInfo.chars then
          local charId = reply.accountInfo.chars[1].baseInfo.charId
          logGreen("[Account]Begin SelectChar with account:{0}, charId:{1}, token:{2}", reply.accountInfo.accountId, charId, reply.accountInfo.token)
          self:BeginSelectChar(charId)
        else
          logGreen("[Account]Begin CreateChar with account:{0}, accountName:{1}, token:{2}", reply.accountInfo.accountId, accountName, reply.accountInfo.token)
          self:BeginCreateChar()
        end
      else
        logError("[Account]Login faild with return:{0}", reply.errCode)
        self:KickOffByServer(reply.errCode)
      end
    end, function(err)
      logError("login failed, err={0}", err)
      self:KickOffByClient(E.KickOffClientErrCode.LoginError)
    end)
  else
    logError("connect: {0}:{1} failed", ip, port)
    self:KickOffByClient(E.KickOffClientErrCode.SocketConnectError)
  end
  Z.NetWaitHelper.SetConnectingTag(E.RpcChannelType.Gateway, false)
end

function LoginVM:AsyncExitGame()
  Z.ConnectMgr:SetReconnectEnabled(E.RpcChannelType.Gateway, false)
  Z.World:LuaFireWorldEvent(Panda.ZGame.EEventLocalType.KickOff, Z.PbErrCode("ErrExitGame"))
  local request = {}
  request.deviceInfo = self:GetDeviceInfo()
  charactorProxy.ExitGame(request, ZUtil.ZCancelSource.NeverCancelToken)
end

function LoginVM:InputMatchingOptions(inputValue, nameToIp, options)
  for key, value in pairs(nameToIp) do
    if value == inputValue then
      for index, name in pairs(options) do
        if name == key then
          return index
        end
      end
    end
  end
  return nil
end

function LoginVM:SelectServerData(serverAddr)
  local serverData = Z.DataMgr.Get("server_data")
  local serverInfoList = serverData.ServerList
  if serverInfoList == nil then
    logError("serverList is nil")
    return
  end
  for _, info in pairs(serverInfoList) do
    local ipAddr = info.serverUrl .. ":" .. math.floor(info.host)
    if serverAddr == ipAddr then
      serverData:SetNowSelectData(info)
      return
    end
  end
  local serverInfo = {}
  local strs = string.split(serverAddr, ":")
  serverInfo.serverUrl = strs[1]
  serverInfo.host = tonumber(strs[2])
  serverData:SetNowSelectData(serverInfo)
end

function LoginVM:LoadLocalAccountInfo()
  if Z.IsOfficalVersion then
    return ""
  end
  local accountName
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    accountName = Z.LocalUserDataMgr.GetString("BKL_ACCOUNT" .. hash, "", 0, true)
  else
    accountName = Z.LocalUserDataMgr.GetString("BKL_ACCOUNT", "", 0, true)
  end
  if accountName == nil or accountName == "" then
    math.randomseed(os.time())
    accountName = os.time() .. tostring(math.random(9999))
  end
  return accountName
end

function LoginVM:SaveLocalAccountInfo(value)
  if Z.IsOfficalVersion then
    return
  end
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    Z.LocalUserDataMgr.SetString("BKL_ACCOUNT" .. hash, value, 0, true)
  else
    Z.LocalUserDataMgr.SetString("BKL_ACCOUNT", value, 0, true)
  end
end

function LoginVM:DeleteLocalAccountInfo()
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    Z.LocalUserDataMgr.RemoveKey("BKL_ACCOUNT" .. hash, true)
  else
    Z.LocalUserDataMgr.RemoveKey("BKL_ACCOUNT", true)
  end
end

function LoginVM:LoadLastLoginAddr()
  if Z.IsOfficalVersion then
    return ""
  end
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    return Z.LocalUserDataMgr.GetString("BKR_LAST_LOGIN_ADDR" .. hash, "", 0, true)
  else
    return Z.LocalUserDataMgr.GetString("BKR_LAST_LOGIN_ADDR", "", 0, true)
  end
end

function LoginVM:SaveLastLoginAddr(value)
  if Z.IsOfficalVersion then
    return
  end
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    Z.LocalUserDataMgr.SetString("BKR_LAST_LOGIN_ADDR" .. hash, value, 0, true)
  else
    Z.LocalUserDataMgr.SetString("BKR_LAST_LOGIN_ADDR", value, 0, true)
  end
end

function LoginVM:DeleteLastLoginAddr()
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    return Z.LocalUserDataMgr.RemoveKey("BKR_LAST_LOGIN_ADDR" .. hash, true)
  else
    return Z.LocalUserDataMgr.RemoveKey("BKR_LAST_LOGIN_ADDR", true)
  end
end

return LoginVM
