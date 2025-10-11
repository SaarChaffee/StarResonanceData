local super = require("ui.model.data_base")
local AccountData = class("AccountData", super)

function AccountData:ctor()
  super.ctor(self)
end

function AccountData:Init()
  self:Clear()
end

function AccountData:Uninit()
  self:Clear()
end

function AccountData:Clear()
  self.PlatformType = nil
  self.SDKType = nil
  self.LoginType = nil
  self.OpenID = nil
  self.Token = nil
  self.Expire = nil
  self.OS = nil
  self.BoundProviders = nil
end

return AccountData
