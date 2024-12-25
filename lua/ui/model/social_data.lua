local super = require("ui.model.data_base")
local SocialData = class("SocialData", super)

function SocialData:ctor()
  super.ctor(self)
  self.selfSocialData_ = {}
end

function SocialData:Init()
end

function SocialData:OnReconnect()
end

function SocialData:SetSocialData(data)
  self.selfSocialData_ = data
end

function SocialData:GetSocialData()
  return self.selfSocialData_
end

function SocialData:Clear()
  self.socialData_ = {}
end

function SocialData:UnInit()
end

return SocialData
