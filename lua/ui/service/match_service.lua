local super = require("ui.service.service_base")
local MatchService = class("MatchService", super)

function MatchService:OnReconnect()
  local matchVm = Z.VMMgr.GetVM("match")
  matchVm.CloseMatchView()
  Z.CoroUtil.create_coro_xpcall(function()
    local matchVm = Z.VMMgr.GetVM("match")
    matchVm.AsyncGetMatchInfo()
  end)()
end

function MatchService:OnLogout()
  local matchVm = Z.VMMgr.GetVM("match")
  matchVm.CloseMatchView()
end

return MatchService
