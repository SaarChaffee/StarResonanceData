local super = require("ui.service.service_base")
local GmService = class("GmService", super)

function GmService:OnInit()
  local gmVM = Z.VMMgr.GetVM("gm")
  if gmVM then
    gmVM.InitHistoryInfo()
  end
end

function GmService:OnLateInit()
end

function GmService:OnUnInit()
end

function GmService:OnLogin()
end

function GmService:OnLogout()
end

return GmService
