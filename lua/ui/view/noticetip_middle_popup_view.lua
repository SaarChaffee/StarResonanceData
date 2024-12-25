local UI = Z.UI
local super = require("ui.ui_view_base")
local Tips_noticetip_middle_popupView = class("Tips_noticetip_middle_popupView", super)

function Tips_noticetip_middle_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "noticetip_middle_popup")
end

function Tips_noticetip_middle_popupView:OnActive()
  self.closeTimer_ = nil
  self.data_ = Z.DataMgr.Get("noticetip_data")
end

function Tips_noticetip_middle_popupView:OnRefresh()
  self:checkTips()
end

function Tips_noticetip_middle_popupView:showTips()
  local data = self.data_:DequeueMiddlePopData()
  self.uiBinder.lab_info.text = data.content
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
  return data.config
end

function Tips_noticetip_middle_popupView:checkTips()
  local count = self.data_:GetMiddlePopDataCount()
  if 0 < count then
    local config = self:showTips()
    if self.closeTimer_ then
      self.timerMgr:StopTimer(self.closeTimer_)
      self.closeTimer_ = nil
    end
    local duration = 5
    if config then
      duration = config.DurationTime
    end
    self.closeTimer_ = self.timerMgr:StartTimer(function()
      self:checkTips()
    end, duration, 1)
  else
    Z.UIMgr:CloseView("noticetip_middle_popup")
  end
end

function Tips_noticetip_middle_popupView:OnDeActive()
  self.closeTimer_ = nil
end

return Tips_noticetip_middle_popupView
