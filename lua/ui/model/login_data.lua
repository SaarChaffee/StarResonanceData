local super = require("ui.model.data_base")
local LoginData = class("LoginData", super)

function LoginData:ctor()
  super.ctor(self)
end

function LoginData:Init()
  self.LastAccountData = nil
end

function LoginData:Uninit()
  self.LastAccountData = nil
end

function LoginData:Clear()
end

return LoginData
