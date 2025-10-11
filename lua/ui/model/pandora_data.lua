local super = require("ui.model.data_base")
local PandoraData = class("PandoraData", super)
local PANDORA_DEFINE = require("ui.model.pandora_define")

function PandoraData:ctor()
end

function PandoraData:Init()
  self.resourceReadyDict_ = {}
  self.appIdCastAppName_ = {}
  self.appResourceDict_ = {}
  self.PopupOpenTag = false
  self.PopupQueryTag = false
  self.PopupQueryTagOnClose = false
end

function PandoraData:UnInit()
  self:Clear()
end

function PandoraData:Clear()
  self.resourceReadyDict_ = {}
  self.appIdCastAppName_ = {}
  self.appResourceDict_ = {}
  self.PopupOpenTag = false
  self.PopupQueryTag = false
  self.PopupQueryTagOnClose = false
end

function PandoraData:IsResourceReady(appName)
  return self.resourceReadyDict_[appName] == true
end

function PandoraData:SetResourceReady(appName, state)
  self.resourceReadyDict_[appName] = state
end

function PandoraData:GetAppNameByAppId(appId)
  return self.appIdCastAppName_[appId]
end

function PandoraData:SetAppNameByAppId(appId, appName)
  self.appIdCastAppName_[appId] = appName
end

function PandoraData:GetAppResource(appId)
  return self.appResourceDict_[appId]
end

function PandoraData:SetAppResource(appId, resource)
  self.appResourceDict_[appId] = resource
end

function PandoraData:GetPandoraUserdata()
  local accountData = Z.DataMgr.Get("account_data")
  local serverData = Z.DataMgr.Get("server_data")
  local userData = {}
  userData.sOpenId = accountData.OpenID
  userData.sRoleId = Z.ContainerMgr.CharSerialize.charId
  userData.sPlatID = self:GetPandoraPlatId()
  userData.sServerPlatID = userData.sPlatID
  userData.sArea = serverData:GetCurrentZoneId()
  userData.sPartition = ""
  userData.sAccessToken = accountData.Token
  userData.sGameVer = Z.GameContext.ResVersion
  userData.sServiceType = PANDORA_DEFINE.SERVER_TYPE
  userData.sLoginChannel = Z.SDKTencent.InstallChannel or ""
  userData.sChannelID = Z.SDKLogin.GetAccountExtInfo("RegChannelDis") or ""
  return userData
end

function PandoraData:GetPandoraPlatId()
  local os = Z.SDKDevices.RuntimeOS
  if os == E.OS.iOS then
    return PANDORA_DEFINE.PlatformId.iOS
  elseif os == E.OS.Android then
    return PANDORA_DEFINE.PlatformId.Android
  elseif os == E.OS.Windows then
    return PANDORA_DEFINE.PlatformId.PC
  else
    logError("undefine pandora platform id by os: " .. os)
    return nil
  end
end

return PandoraData
