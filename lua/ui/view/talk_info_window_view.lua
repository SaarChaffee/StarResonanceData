local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_info_windowView = class("Talk_info_windowView", super)

function Talk_info_windowView:ctor()
  self.panel = nil
  super.ctor(self, "talk_info_window")
end

function Talk_info_windowView:OnActive()
  self.panel.scenemask.SceneMask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.panel.btn_close.Btn, function()
    Z.UIMgr:CloseView("talk_info_window")
  end)
  local msgItem = self.viewData
  local messageRow = msgItem.config
  self.panel.lab_title.TMPLab.text = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.ChatName, msgItem.param))
  self.panel.lab_content.TMPLab.text = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.Content, msgItem.param))
  self.panel.scrollview_content.Scroll.verticalNormalizedPosition = 1
end

function Talk_info_windowView:OnDeActive()
  if self.eventId_ then
    Z.AudioMgr:StopPlayingEvent(self.eventId_, 0.5)
  end
  self.eventId_ = nil
end

function Talk_info_windowView:OnRefresh()
  local msgItem = self.viewData
  local config = msgItem.config
  if config and config.VoiceEventName and config.VoiceControlEvent then
    self.eventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(config.VoiceEventName, config.VoiceControlEvent)
  end
end

return Talk_info_windowView
