local super = require("ui.model.data_base")
local PlayerData = class("PlayerData", super)

function PlayerData:ctor()
  super.ctor(self)
end

function PlayerData:Init()
  self:Clear()
end

function PlayerData:Uninit()
  self:Clear()
end

function PlayerData:Clear()
  self.SDKType = nil
  self.SDKToken = nil
  self.Token = nil
  self.AccountInfo = nil
  self.CharInfo = nil
  self.AccountName = nil
  self.LastUnstuckTime = nil
end

return PlayerData
