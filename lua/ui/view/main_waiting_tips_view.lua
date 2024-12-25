local UI = Z.UI
local super = require("ui.ui_view_base")
local main_waiting_tips_view = class("main_waiting_tips_view", super)
local ANIM_TIME = 0.3
local DELAY_SHOW_TIME = 2
local PROTECT_TIME = 60

function main_waiting_tips_view:ctor()
  self.panel = nil
  super.ctor(self, "main_waiting_tips")
end

function main_waiting_tips_view:OnActive()
  self.isMaskShow_ = false
  self.panel.node_wait:SetVisible(false)
  self.panel.rayimg_mask:SetVisible(false)
  self:createShowTimer()
end

function main_waiting_tips_view:OnDeActive()
  if self.isMaskShow_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  end
  self.panel.node_wait.anim:ResetAniState("anim_waiting_tips_loop")
  self:clearShowTimer()
  self:clearProtectTimer()
end

function main_waiting_tips_view:OnRefresh()
  if self.viewData and self.viewData.WaitingType then
    local type = self.viewData.WaitingType
    if type == E.WaitingType.Switching then
      self:clearShowTimer()
      self.panel.node_wait:SetVisible(false)
      self.panel.rayimg_mask:SetVisible(true)
    end
  end
end

function main_waiting_tips_view:showMask()
  Z.NetWaitHelper.LogCurrentInfo()
  self.isMaskShow_ = true
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.panel.rayimg_mask:SetVisible(true)
  self.panel.node_wait.anim:PlayLoop("anim_waiting_tips_loop")
  self.panel.node_wait.doTween:DoCanvasGroup(1, ANIM_TIME)
end

function main_waiting_tips_view:createShowTimer()
  self:clearShowTimer()
  self.showTimer_ = self.timerMgr:StartTimer(function()
    self:showMask()
  end, DELAY_SHOW_TIME - ANIM_TIME)
end

function main_waiting_tips_view:clearShowTimer()
  if self.showTimer_ then
    self.showTimer_:Stop()
    self.showTimer_ = nil
  end
end

function main_waiting_tips_view:createProtectTimer()
  self:clearProtectTimer()
  self.protectTimer_ = self.timerMgr:StartTimer(function()
    Z.NetWaitHelper.WaitingErrorHandler()
  end, PROTECT_TIME, 1)
end

function main_waiting_tips_view:clearProtectTimer()
  if self.protectTimer_ then
    self.protectTimer_:Stop()
    self.protectTimer_ = nil
  end
end

return main_waiting_tips_view
