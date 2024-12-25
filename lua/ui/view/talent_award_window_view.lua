local UI = Z.UI
local super = require("ui.ui_view_base")
local Talent_award_windowView = class("Talent_award_windowView", super)

function Talent_award_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talent_award_window")
end

function Talent_award_windowView:OnActive()
  Z.CoroUtil.create_coro_xpcall(function()
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, "rolelevel_talent_award_window_node_talent_an_001_start", self.cancelSource:CreateToken())
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(90, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
    asyncCall(self.uiBinder.anim, "rolelevel_talent_award_window_node_talent_an_001_end", self.cancelSource:CreateToken())
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)()
end

function Talent_award_windowView:OnDeActive()
end

function Talent_award_windowView:OnRefresh()
end

return Talent_award_windowView
