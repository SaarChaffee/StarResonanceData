local super = require("ui.model.data_base")
local Socialcontact = class("Socialcontact", super)

function Socialcontact:ctor()
  super.ctor(self)
  self.Type = E.SocialType.Chat
end

function Socialcontact:SetType(type)
  self.Type = type
end

function Socialcontact:GetType()
  return self.Type
end

function Socialcontact:Init()
end

function Socialcontact:UnInit()
end

return Socialcontact
