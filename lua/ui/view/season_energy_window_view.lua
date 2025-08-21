local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_energy_windowView = class("Season_energy_windowView", super)

function Season_energy_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_energy_window")
end

function Season_energy_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_ItemGet_S")
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_effect_1)
  self.uiBinder.node_lv.lab_tips.text = Lang("GetSeasonEchoPoint", {
    val = self.viewData.num
  })
  Z.CoroUtil.create_coro_xpcall(function()
    local asyncCall = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlayOnce)
    asyncCall(self.uiBinder.anim, "season_energy_window_node_lv_an_001_start", self.cancelSource:CreateToken())
    asyncCall(self.uiBinder.anim, "season_energy_window_node_lv_an_001_end", self.cancelSource:CreateToken())
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)()
end

function Season_energy_windowView:OnDeActive()
end

function Season_energy_windowView:OnRefresh()
end

return Season_energy_windowView
