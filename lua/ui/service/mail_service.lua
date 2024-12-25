local super = require("ui.service.service_base")
local MailService = class("MailService", super)

function MailService:OnInit()
end

function MailService:OnUnInit()
end

function MailService:OnLogin()
end

function MailService:OnLogout()
end

function MailService:OnReconnect()
  self:checkMailList()
end

function MailService:OnEnterScene()
  self:checkMailList()
end

function MailService:checkMailList()
  if Z.StageMgr.GetIsInGameScene() then
    local mailVm = Z.VMMgr.GetVM("mail")
    mailVm.AsyncCheckMailList()
  end
end

return MailService
