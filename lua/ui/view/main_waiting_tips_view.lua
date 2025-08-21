local UI = Z.UI
local super = require("ui.ui_view_base")
local main_waiting_tips_view = class("main_waiting_tips_view", super)
local ANIM_TIME = 0.3
local DELAY_SHOW_TIME = 2
local PROTECT_TIME = 60

function main_waiting_tips_view:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_waiting_tips")
end

function main_waiting_tips_view:OnActive()
  self.isMaskShow_ = false
  self:SetUIVisible(self.uiBinder.dotween_wait, false)
  self:SetUIVisible(self.uiBinder.raycast_img, false)
  self:createShowTimer()
end

function main_waiting_tips_view:OnDeActive()
  if self.isMaskShow_ then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  end
  self.uiBinder.anim_wait:ResetAniState("anim_waiting_tips_loop")
  self.uiBinder.canvas_group_wait.alpha = 0
  self:clearShowTimer()
  self:clearProtectTimer()
end

function main_waiting_tips_view:OnRefresh()
  if self.viewData and self.viewData.WaitingType then
    local type = self.viewData.WaitingType
    if type == E.WaitingType.Switching then
      self:clearShowTimer()
      self:SetUIVisible(self.uiBinder.dotween_wait, false)
      self:SetUIVisible(self.uiBinder.raycast_img, true)
    elseif type == E.WaitingType.Sync then
      self:clearShowTimer()
      self:showMask()
    end
  end
end

function main_waiting_tips_view:showMask()
  if Z.UIMgr:GetUIViewInputIgnore(self.viewConfigKey) == 0 then
    Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  end
  self.isMaskShow_ = true
  self:SetUIVisible(self.uiBinder.raycast_img, true)
  self.uiBinder.anim_wait:PlayLoop("anim_waiting_tips_loop")
  self.uiBinder.dotween_wait:DoCanvasGroup(1, ANIM_TIME)
end

function main_waiting_tips_view:createShowTimer()
  self:clearShowTimer()
  self.showTimer_ = self.timerMgr:StartTimer(function()
    self:showMask()
    Z.NetWaitHelper.LogCurrentInfo()
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
