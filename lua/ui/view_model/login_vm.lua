local charactorProxy = require("zproxy.grpc_charactor_proxy")
local cjson = require("cjson")
local SDK_DEFINE = require("ui.model.sdk_define")
E.LoginState = {
  Init = "Init",
  AutoLoginAccount = "AutoLoginAccount",
  LoginAccount = "LoginAccount",
  GetServerList = "GetServerList",
  EnterGame = "EnterGame",
  WaitingConnect = "WaitingConnect"
}
E.ServerStatus = {
  Normal = 1,
  NotOpen = 2,
  Maintain = 3
}
E.KickOffClientErrCode = {
  NormalReturn = 0,
  Common = 50000,
  SocketConnectError = 50001,
  NotFoundServer = 50002,
  NetWaitHelper = 50003,
  LoginError = 50004,
  RepeatCreateChar = 50005,
  UnderageLimit = 50006,
  NoCharDisConnect = 50007,
  Reconnect = 50008,
  Teleport = 50009,
  BeginSwitch = 50010,
  Switch = 50011,
  EndSwitch = 50012,
  AntiCheating = 50013,
  SwitchTimeout = 50014,
  ConnectWorldFailed = 50015,
  WebViewCallBack = 50016,
  SelectCharFailed = 50017
}
E.SDKZoneId = {
  TencentProduct = "1001",
  TencentProductTest = "1002",
  TencentPreview = "1003",
  TencentExperience = "1004",
  TencentTest = "1005"
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
    accountData.BoundProviders = data.BoundProviders
    local loginData = Z.DataMgr.Get("login_data")
    loginData.LastAccountData = table.zclone(accountData)
    Z.SDKReport.SetInfo("GameUserID", data.OpenID)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSDKAutoLogin, data)
end

function LoginVM:SDKLogin(loginType, isQRCode, accountName)
  if loginType == E.LoginType.None then
    local data = {}
    data.ErrorCode = 0
    data.SDKType = 0
    data.LoginTypeID = 0
    data.OpenID = accountName
    data.Platform = E.LoginPlatformType.InnerPlatform
    data.OS = Z.SDKDevices.RuntimeOS
    self:OnSDKLogin(data)
  else
    Z.SDKLogin.Login(loginType, isQRCode)
  end
end

function LoginVM:OnSDKLogin(data)
  if data == nil then
    Z.TipsVM.ShowTips(Lang("SDKLoginError"))
    self:Logout(true)
    return
  end
  if data ~= nil and data.ErrorCode == 0 then
    local accountData = Z.DataMgr.Get("account_data")
    accountData.SDKType = data.SDKType
    accountData.LoginType = data.LoginTypeID
    accountData.OpenID = data.OpenID
    accountData.Token = data.Token
    accountData.Expire = data.Expire
    accountData.OS = data.OS
    accountData.PlatformType = data.Platform
    accountData.BoundProviders = data.BoundProviders
    local loginData = Z.DataMgr.Get("login_data")
    loginData.LastAccountData = table.zclone(accountData)
    Z.SDKReport.SetInfo("GameUserID", data.OpenID)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSDKLogin, data)
end

function LoginVM:GetDeviceInfo()
  local deviceInfo = {}
  deviceInfo.clientVersion = Z.GameContext.Version
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
  deviceInfo.channel = Z.SDKTencent.InstallChannel
  deviceInfo.deviceId = Z.SDKReport.GetReportInfo("DeviceID")
  deviceInfo.ANDROID_OAID = Z.SDKReport.GetReportInfo("OAID")
  deviceInfo.IOS_CAID = Z.SDKReport.GetReportInfo("CAID")
  deviceInfo.OLD_CAID = Z.SDKReport.GetReportInfo("OLDCAID")
  deviceInfo.userAgent = Z.SDKReport.GetReportInfo("UserAgent")
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
  local sdkData = Z.DataMgr.Get("sdk_data")
  local curTime = os.time()
  local interval = curTime - serverData.LastGetTime
  if interval < 3 then
    return true
  end
  local cancelSource = Z.CancelSource.Rent()
  local request = Z.HttpRequest.Rent()
  request.Url = Z.GameContext.Domain
  request:AddHeader("version", Z.GameContext.Version)
  request:AddHeader("res_version", Z.GameContext.ResVersion)
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
    local content = cjson.decode(response.Value)
    parameter = content.serverList
    sdkData:SetHttpNoticeUrl(content.noticeUrl, content.noticePreviewUrl)
  end, function(msg)
    logError("[LoginVM] AsyncGetServerList Error : " .. msg)
  end)
  response:Recycle()
  request:Recycle()
  cancelSource:Recycle()
  if parameter == nil then
    logError("[LoginVM]serverList is null")
    return false
  end
  serverData.LastGetTime = os.time()
  serverData:SetServerData(parameter)
  return true
end

function LoginVM:AsyncLogin()
  local accountData = Z.DataMgr.Get("account_data")
  local sdkVM = Z.VMMgr.GetVM("sdk")
  local request = {}
  request.openId = accountData.OpenID
  request.token = accountData.Token
  request.platformType = accountData.PlatformType
  request.sdkType = accountData.SDKType
  request.channelId = accountData.LoginType
  request.os = accountData.OS
  request.boundProviders = accountData.BoundProviders
  request.deviceInfo = self:GetDeviceInfo()
  request.clientVersion = Z.GameContext.Version
  request.clientResourceVersion = Z.GameContext.ResVersion
  request.protocolVersion = Z.Version.ProtocolVersion
  request.configVersion = Z.Version.ConfigVersion
  request.areaId = Z.GameContext.InstallChannel
  request.areaIdToken = Z.GameContext.InstallChannelEncryption
  request.iOSAdServiceToken = Z.SDKReport.GetReportInfo("AdServiceToken")
  request.payExtData = Z.VMMgr.GetVM("payment"):GetExtData()
  request.launchParam = sdkVM.DeserializeWakeUpData(Z.SDKTencent.GetLastWakeUpData())
  request.distinctID = Z.SDKReport.GetReportInfo("DistinctID")
  if not Z.IsOfficalVersion then
    logError("Login Request={0}", table.ztostring(request))
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
    if reply.accountInfo.deleteCharIdsLeftTime == nil then
      playerData.DeleteCharIdsLeftTime = {}
      playerData.GetDeleteCharTimestamp = {}
    else
      playerData.DeleteCharIdsLeftTime = reply.accountInfo.deleteCharIdsLeftTime
      playerData.GetDeleteCharTimestamp = {}
      for charId, leftTime in pairs(playerData.DeleteCharIdsLeftTime) do
        playerData.GetDeleteCharTimestamp[charId] = os.time()
      end
    end
    if reply.timeZone ~= nil then
      Z.ServerTime.ServiceTimeZone = reply.timeZone
    else
      Z.ServerTime.ServiceTimeZone = "Asia/Shanghai"
    end
    Z.Voice.Init(accountData.OpenID)
    local platformConfig = reply.platformConfig
    Z.DataMgr.Get("sdk_data"):DeserialConfig(platformConfig)
    if Z.SDKTencent.InstallChannelEncryption and Z.SDKTencent.InstallChannelEncryption ~= "" then
      Z.SDKTencent.InstallChannel = reply.installChannelDis
    end
    local serverData = Z.DataMgr.Get("server_data")
    Z.SDKReport.SetInfo("ServerID", serverData:GetCurrentZoneId())
    Z.SDKReport.Report(Z.SDKReportEvent.ServerConnected)
  else
    playerData:Clear()
  end
  if reply.isChangeAccount then
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameNormal, E.ESysDialogGameNormalOrder.TencentChangeAccount, nil, Lang("QQGameStartOtherAccountTipsDes"), function()
      Z.SDKTencent.GetLastWakeUpData().ShouldSwitchAccount = true
      Z.VMMgr.GetVM("login"):Logout(true)
    end, function()
      Z.SDKTencent.CleanLastWakeUpData()
    end, true)
  else
    Z.SDKTencent.CleanLastWakeUpData()
  end
  return reply
end

function LoginVM:AsyncCreateChar(name, gender, bodySize, faceData, weaponId)
  local playerData = Z.DataMgr.Get("player_data")
  local request = {}
  request.token = playerData.AccountInfo.token
  request.name = name
  request.gender = gender
  request.vBodySize = bodySize
  request.faceData = faceData
  request.initProfessionId = weaponId
  request.deviceInfo = self:GetDeviceInfo()
  request.areaId = Z.SDKTencent.InstallChannel
  local reply = charactorProxy.CreateChar(request, ZUtil.ZCancelSource.NeverCancelToken)
  return reply
end

function LoginVM:AsyncSelectChar(charId)
  local data = Z.DataMgr.Get("player_data")
  local request = {}
  request.charId = charId
  request.token = data.AccountInfo.token
  request.areaId = Z.SDKTencent.InstallChannel
  local reply
  for i = 1, 3 do
    xpcall(function()
      reply = charactorProxy.SelectChar(request, ZUtil.ZCancelSource.NeverCancelToken)
    end, function(err)
      logError("[LoginVM:SelectChar]error msg = " .. err)
    end)
    if reply == nil or reply.errCode == Z.PbErrCode("ErrChangeMapErr") or reply.errCode == Z.PbErrCode("ErrSelectCharDoing") then
      logError("recv ErrChangeMapErr on SelectChar, retryCount=" .. tostring(i))
      Z.Delay(i, ZUtil.ZCancelSource.NeverCancelToken)
    else
      break
    end
  end
  return reply
end

function LoginVM:AsyncDeleteChar(charId)
  local request = {}
  request.charId = charId
  local reply = charactorProxy.DeleteChar(request, ZUtil.ZCancelSource.NeverCancelToken)
  if reply.errCode == 0 then
    local charId = reply.charId
    local playerData = Z.DataMgr.Get("player_data")
    playerData.DeleteCharIdsLeftTime[charId] = reply.deleteLeftTime
    playerData.GetDeleteCharTimestamp[charId] = os.time()
  else
    Z.TipsVM.ShowTips(reply.errCode)
  end
  return reply
end

function LoginVM:AsyncCancelDeleteChar(charId)
  local request = {}
  request.charId = charId
  local reply = charactorProxy.CancelDeleteChar(request, ZUtil.ZCancelSource.NeverCancelToken)
  if reply.errCode == 0 then
    local playerData = Z.DataMgr.Get("player_data")
    playerData.DeleteCharIdsLeftTime[charId] = nil
    playerData.GetDeleteCharTimestamp[charId] = nil
  else
    Z.TipsVM.ShowTips(reply.errCode)
  end
  return reply
end

function LoginVM:AsyncReconnect()
  local data = Z.DataMgr.Get("player_data")
  local accountData = Z.DataMgr.Get("account_data")
  local sdkVM = Z.VMMgr.GetVM("sdk")
  local request = {}
  request.accountId = data.AccountInfo.accountId
  request.token = data.AccountInfo.token
  request.clientVersion = Z.GameContext.Version
  request.clientResourceVersion = Z.GameContext.ResVersion
  request.os = accountData.OS
  request.launchParam = sdkVM.DeserializeWakeUpData(Z.SDKTencent.GetLastWakeUpData())
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
    logError("reconnect failed, errCode={0}", reply.errCode)
    self:KickOffByServer(reply.errCode)
    return false
  end
  if reply.isChangeAccount then
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameNormal, E.ESysDialogGameNormalOrder.TencentChangeAccount, nil, Lang("QQGameStartOtherAccountTipsDes"), function()
      Z.SDKTencent.GetLastWakeUpData().ShouldSwitchAccount = true
      Z.VMMgr.GetVM("login"):Logout(true)
    end, function()
      Z.SDKTencent.CleanLastWakeUpData()
    end, true)
  else
    Z.EventMgr:Dispatch(Z.ConstValue.SDK.TencentPrivilegeRefresh, reply.isPrivilege)
    Z.SDKTencent.CleanLastWakeUpData()
  end
  local isSelectedChar = reply.charId and reply.charId ~= 0
  if isSelectedChar then
    data.CurrentCharId = reply.charId
  end
  logGreen("reconnect success")
  Z.Game.OnReconnect(isSelectedChar)
  return true
end

function LoginVM:Logout(clearSDK)
  logYellow("logout, currentStage={0}", Z.StageMgr.GetCurrentStageType())
  Z.SDKAntiCheating.Logout()
  xpcall(function()
    Z.Game.OnLogout()
  end, function(err)
    logError("[LoginVM:Logout] error for Z.Game.OnLogout, msg = " .. err)
  end)
  if clearSDK then
    xpcall(function()
      Z.SDKLogin.Logout()
    end, function(err)
      logError("[LoginVM:Logout] error for Z.SDKLogin.Logout, msg = " .. err)
    end)
  end
  Z.ConnectMgr:Disconnect(E.RpcChannelType.Gateway)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.World)
  Z.DataMgr.Clear()
  Z.NetWaitHelper.Clear()
  Z.GlobalTimerMgr:Clear()
  Z.GuideMgr:Clear()
  if Z.StageMgr.GetIsInLogin() and not Z.UIMgr:IsActive("login") then
    Z.UIMgr:DeActiveAll(true)
    Z.UIMgr:OpenView("login")
  end
  xpcall(function()
    Z.LuaBridge.CharExit()
  end, function(err)
    logError("[LoginVM:Logout] error for Z.LuaBridge.CharExit, msg = " .. err)
  end)
  xpcall(function()
    Z.LuaBridge.Logout()
  end, function(err)
    logError("[LoginVM:Logout] error for Z.LuaBridge.Logout, msg = " .. err)
  end)
  Z.DialogViewDataMgr:ClearAll()
  Z.SysDialogViewDataManager:ClearAll(true)
  Z.ContainerMgr:Reset()
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.SwitchLoginState, E.LoginState.Init)
end

function LoginVM:KickOffByClient(clientErrCode, hideDialog)
  if clientErrCode ~= E.KickOffClientErrCode.NormalReturn then
    logError("KickOffByClient, errCode={0}", clientErrCode)
  end
  local clearSDK = false
  if clientErrCode == E.KickOffClientErrCode.UnderageLimit then
    clearSDK = true
  end
  if hideDialog then
    self:Logout(clearSDK)
    return
  end
  local param = {errCode = clientErrCode}
  local desc = Z.TipsVM.GetMessageContent(clientErrCode, param)
  if desc == nil or desc == "" then
    desc = Z.TipsVM.GetMessageContent(E.KickOffClientErrCode.Common, param)
  end
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.KickOff, nil, desc, function()
    self:Logout(clearSDK)
  end)
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
  local desc
  if errCode ~= 0 then
    local errConfig = Z.TableMgr.GetTable("MessageTableMgr").GetRow(errCode)
    if errConfig ~= nil then
      desc = errConfig.Content
    end
  end
  if desc == nil then
    desc = string.zconcat(Lang("DescDisconnect"), string.format(Lang("ErrcodeCommonTipsTitle"), errCode))
  end
  Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.KickOff, nil, desc, function()
    self:Logout(errCode == Z.PbEnum("EErrorCode", "ErrSdkTokenExpired"))
  end)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.Gateway)
  Z.ConnectMgr:Disconnect(E.RpcChannelType.World)
  Z.NetWaitHelper.Clear()
  Z.UIMgr:CloseView("main_waiting_tips")
end

function LoginVM:BeginCreateChar()
  local args = {}
  
  function args.EndCallback()
    local faceVM = Z.VMMgr.GetVM("face")
    faceVM.OpenFaceCreateView()
  end
  
  Z.UIMgr:FadeIn(args)
end

function LoginVM:BeginSelectChar(charId, errorFunc)
  Z.LocalUserDataMgr.InitCharacterLocalUserData(charId)
  local reply = self:AsyncSelectChar(charId)
  if reply == nil then
    logError("[Account]SelectChar failed with nil reply")
    local config = Z.TableMgr.GetTable("MessageTableMgr").GetRow(E.KickOffClientErrCode.SelectCharFailed)
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.LoginError, nil, config.Content, function()
      if errorFunc then
        errorFunc()
      end
    end)
    return
  end
  if reply.errCode ~= 0 then
    logError("[Account]SelectChar failed with return:{0}", table.ztostring(reply))
    local config = Z.TableMgr.GetTable("MessageTableMgr").GetRow(reply.errCode)
    if config then
      Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.LoginError, nil, config.Content, function()
        if errorFunc then
          errorFunc()
        end
      end)
    end
    return
  end
  logGreen("[Account]SelectChar success with return:{0}", table.ztostring(reply))
  local data = Z.DataMgr.Get("player_data")
  data.CurrentCharId = charId
  xpcall(function()
    Z.LuaBridge.CharEnter(charId)
  end, function(err)
    logError("[Account] error for Z.LuaBridge.CharEnter, msg = " .. err)
  end)
  Z.EventMgr:Dispatch(Z.ConstValue.LoginEvt.OnSelectChar, charId)
  local serverData = Z.DataMgr.Get("server_data")
  local serverId = serverData.NowSelectServerId
  Z.SDKReport.SetInfo("RoleID", charId)
  Z.SDKReport.SetInfo("AreaID", serverId)
  Z.SDKReport.Report(Z.SDKReportEvent.CharacterSelected)
end

function LoginVM:OpenSelectCharView()
  local viewConfigKey = "face_rolechoose_window"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
    Z.UIMgr:OpenView(viewConfigKey)
  end)
end

function LoginVM:AsyncCheckServerStatus(serverAddr)
  local serverData = Z.DataMgr.Get("server_data")
  local serverId = serverData:GetServerId(serverAddr)
  if serverId == 0 then
    return true
  end
  self:AsyncGetServerList()
  local openTime = serverData.ServerMap[serverId].open_time
  local startTime = serverData.ServerMap[serverId].maintain_start_time
  local stopTime = serverData.ServerMap[serverId].maintain_stop_time
  local serverStatus = serverData.ServerMap[serverId].status
  if openTime == nil and startTime == nil and stopTime == nil then
    return true
  elseif openTime ~= nil and (startTime == nil and stopTime ~= nil or startTime ~= nil and stopTime == nil) then
    return false
  end
  if serverStatus == nil then
    return true
  end
  local sdkVM = Z.VMMgr.GetVM("sdk")
  local showAnnouncementBtn = self:ShowAnnouncementBtn()
  if serverStatus == E.ServerStatus.Normal then
    return true
  elseif serverStatus == E.ServerStatus.NotOpen then
    local param = {open_time = openTime}
    local labDesc = Lang("ErrServerNotOpen", param)
    local switchLabel = sdkVM.GetCommunityLabel()
    if switchLabel ~= "" then
      labDesc = labDesc .. switchLabel
    end
    self:ShowServerDialogTip(labDesc, showAnnouncementBtn)
  elseif serverStatus == E.ServerStatus.Maintain then
    local param = {start_time = startTime, stop_time = stopTime}
    local labDesc = Lang("ErrServerDownWithTime", param)
    local switchLabel = sdkVM.GetCommunityLabel()
    if switchLabel ~= "" then
      labDesc = labDesc .. switchLabel
    end
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
  end
  if showAnnouncementBtn then
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Normal, nil, labDesc, onConfirm, nil, true, Lang("JumpToAnnouncement"))
  else
    Z.SysDialogViewDataManager:ShowSysDialogView(E.ESysDialogViewType.GameImportant, E.ESysDialogGameImportantOrder.Normal, nil, labDesc, onConfirm)
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
          logError("[Account]Login failed with return:{0}", table.ztostring(reply))
          self:KickOffByClient(E.KickOffClientErrCode.LoginError)
          Z.NetWaitHelper.SetConnectingTag(E.RpcChannelType.Gateway, false)
          return
        end
        logGreen("[Account]Login success with return:{0}", table.ztostring(reply))
        Z.LocalUserDataMgr.InitAccountLocalUserData(reply.accountInfo.accountId)
        Z.GameContext.ServerAddr = serverAddr
        local serverData = Z.DataMgr.Get("server_data")
        local serverInfo = string.format("%s=%s", serverData:GetDescriptionByAddr(serverAddr), serverAddr)
        Z.SDKReport.SetInfo("ServerInfo", serverInfo)
        self:SaveLocalAccountInfo(accountName)
        self:SaveLastLoginAddr(serverAddr)
        xpcall(function()
          Z.LuaBridge.Login()
        end, function(err)
          logError("[LoginVM:Login] error for Z.LuaBridge.Login, msg = " .. err)
        end)
        xpcall(function()
          Z.Game.OnLogin()
        end, function(err)
          logError("[LoginVM:Login] error for Z.Game.OnLogin, msg = " .. err)
        end)
        local chars = reply.accountInfo.chars
        data.CharDataList = chars
        data:SortCharDataList()
        if 0 < #chars then
          self:OpenSelectCharView()
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
      serverData:SetNowSelectServerId(serverData:GetServerId(serverAddr))
      return
    end
  end
  local serverInfo = {}
  local strs = string.split(serverAddr, ":")
  serverInfo.serverUrl = strs[1]
  serverInfo.host = tonumber(strs[2])
  serverInfo.zoneId = 9999
  serverData:SetNowSelectData(serverInfo)
  serverData:SetNowSelectServerId(serverData:GetServerId(serverAddr))
end

function LoginVM:LoadLocalAccountInfo()
  if Z.IsOfficalVersion then
    return ""
  end
  local accountName
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    accountName = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT" .. hash, "")
  else
    accountName = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT", "")
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
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT" .. hash, value)
  else
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT", value)
  end
end

function LoginVM:DeleteLocalAccountInfo()
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT" .. hash)
  else
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Device, "BKL_ACCOUNT")
  end
end

function LoginVM:LoadLastLoginAddr()
  if not Z.GameContext.IsEditor then
    return ""
  end
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    return Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR" .. hash, "")
  else
    return Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR", "")
  end
end

function LoginVM:SaveLastLoginAddr(value)
  if Z.IsOfficalVersion then
    return
  end
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR" .. hash, value)
  else
    Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR", value)
  end
end

function LoginVM:DeleteLastLoginAddr()
  if Z.GameContext.IsPC then
    local path = UnityEngine.Application.dataPath
    local hash = Z.Hash33(path)
    return Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR" .. hash)
  else
    return Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Device, "BKR_LAST_LOGIN_ADDR")
  end
end

return LoginVM
