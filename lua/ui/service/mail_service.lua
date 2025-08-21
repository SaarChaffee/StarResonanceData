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
  if not Z.StageMgr.GetIsInGameScene() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local mailData = Z.DataMgr.Get("mail_data")
    if mailData:GetIsInit() then
      local mailVm = Z.VMMgr.GetVM("mail")
      mailVm.AsyncCheckMailList()
    else
      local mailVM = Z.VMMgr.GetVM("mail")
      mailVM.AsyncGetMailNum()
      mailVM.UpdateMailRedNum()
    end
  end)()
end

return MailService
