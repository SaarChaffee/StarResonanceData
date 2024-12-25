local UI = Z.UI
local super = require("ui.ui_view_base")
local Fishing_acquire_windowView = class("Fishing_acquire_windowView", super)

function Fishing_acquire_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "fishing_acquire_window")
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
end

function Fishing_acquire_windowView:OnActive()
  self.uiBinder.lab_lv.text = self.fishingData_.FishingLevel
  self:onStartAnimatedShow()
  Z.AudioMgr:Play("UI_Event_Magic_B")
end

function Fishing_acquire_windowView:OnDeActive()
  self.timerMgr:Clear()
end

function Fishing_acquire_windowView:OnRefresh()
end

function Fishing_acquire_windowView:onStartAnimatedShow()
  self.uiBinder.node_eff:SetEffectGoVisible(true)
  self.uiBinder.anim:CoroPlayOnce("fishing_acquire_window_an_start", self.cancelSource:CreateToken(), function()
    self.timerMgr:StartTimer(function()
      self.uiBinder.node_eff:SetEffectGoVisible(false)
      Z.UIMgr:CloseView(self.viewConfigKey)
    end, 1)
  end, function(err)
    if err == ZUtil.ZCancelSource.CancelException then
      return
    end
    logError(err)
  end)
end

return Fishing_acquire_windowView
