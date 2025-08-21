local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_info_windowView = class("Talk_info_windowView", super)

function Talk_info_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talk_info_window")
end

function Talk_info_windowView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("talk_info_window")
  end)
  if Z.IsPCUI then
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePC")
  else
    self.uiBinder.lab_click_close.text = Lang("ClickOnBlankSpaceClosePhone")
  end
  local msgItem = self.viewData
  local messageRow = msgItem.config
  self.uiBinder.lab_title.text = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.ChatName, msgItem.param))
  self.uiBinder.lab_content.text = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(messageRow.Content, msgItem.param))
  self.uiBinder.scrollview_content.verticalNormalizedPosition = 1
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
