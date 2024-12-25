local UI = Z.UI
local super = require("ui.ui_subview_base")
local World_boss_sign_upView = class("World_boss_sign_upView", super)

function World_boss_sign_upView:ctor(parent)
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "worldboss/world_boss_sign_up_pc" or "worldboss/world_boss_sign_up"
  super.ctor(self, "world_boss_sign_up", assetPath, UI.ECacheLv.None)
  self.worldBossData_ = Z.DataMgr.Get("world_boss_data")
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
end

function World_boss_sign_upView:OnActive()
  self:BindEvents()
  self:AddClick(self.uiBinder.btn_arrow, function()
    self.worldBossVM_.OpenWorldBossMainView()
  end)
end

function World_boss_sign_upView:OnDeActive()
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
end

function World_boss_sign_upView:OnRefresh()
  self:refreshState(E.MatchType.WorldBoss)
end

function World_boss_sign_upView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Match.MatchStartTimeChange, self.refreshState, self)
end

function World_boss_sign_upView:refreshState(matchType)
  if matchType ~= E.MatchType.WorldBoss then
    return
  end
  local matchData_ = Z.DataMgr.Get("match_data")
  local matchTime = matchData_:GetMatchStartTime()
  if matchTime <= 0 then
    self:DeActive()
  else
    if self.timer_ then
      self.timerMgr:StopTimer(self.timer_)
      self.timer_ = nil
    end
    local time2 = (Z.TimeTools.Now() - matchTime) / 1000
    self.uiBinder.lab_time.text = Z.TimeTools.S2HMSFormat(time2)
    self.timer_ = self.timerMgr:StartTimer(function()
      local time = (Z.TimeTools.Now() - matchTime) / 1000
      self.uiBinder.lab_time.text = Z.TimeTools.S2HMSFormat(time)
    end, 1, -1)
  end
end

return World_boss_sign_upView
