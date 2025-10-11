local super = require("ui.model.data_base")
local SDKData = class("SDKData", super)
local SDKDefine = require("ui.model.sdk_define")
local cjson = require("cjson")

function SDKData:ctor()
  super.ctor(self)
end

function SDKData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.SDKBlackList = {}
  self.SDKFriends = {}
  self.SDKURL = {}
  self.DefaultAvator = ""
  self.LegalSchemePrefix = {}
  self.HttpNoticeUrl = nil
  self.HttpNoticePreviewUrl = nil
end

function SDKData:UnInit()
  self.CancelSource:Recycle()
end

function SDKData:Clear()
end

function SDKData:OnReconnect()
end

function SDKData:DeserialConfig(config)
  if config == nil then
    self:initData()
    return
  end
  xpcall(function()
    self.DefaultAvator = ""
    if config[SDKDefine.PlatformConfig.PlatformConfigDefaultAvatar] then
      self.DefaultAvator = cjson.decode(config[SDKDefine.PlatformConfig.PlatformConfigDefaultAvatar])
    end
    self.LegalSchemePrefix = {}
    if config[SDKDefine.PlatformConfig.PlatformConfigLegalSchemePrefix] then
      self.LegalSchemePrefix = cjson.decode(config[SDKDefine.PlatformConfig.PlatformConfigLegalSchemePrefix])
    end
    self.SDKBlackList = {}
    if config[SDKDefine.PlatformConfig.PlatformConfigAreaBlacklist] then
      local blackList = cjson.decode(config[SDKDefine.PlatformConfig.PlatformConfigAreaBlacklist])
      for _, v in pairs(blackList) do
        table.insert(self.SDKBlackList, v)
      end
    end
    self.SDKURL = {}
    if config[SDKDefine.PlatformConfig.PlatformConfigUrl] then
      self.SDKURL = cjson.decode(config[SDKDefine.PlatformConfig.PlatformConfigUrl])
    end
  end, function(msg)
    logError("SDKData.DeserialConfig error : " .. msg)
  end)
end

function SDKData:initData()
  self.DefaultAvator = ""
  self.LegalSchemePrefix = {}
  self.SDKBlackList = {}
  self.SDKURL = {}
end

function SDKData:SetHttpNoticeUrl(url, previewUrl)
  self.HttpNoticeUrl = url
  self.HttpNoticePreviewUrl = previewUrl
end

return SDKData
