local UI = Z.UI
local super = require("ui.ui_subview_base")
local Tips_noticetip_captions_windowView = class("Tips_noticetip_captions_windowView", super)

function Tips_noticetip_captions_windowView:ctor()
  self.uiBinder = nil
  local assetPath = Z.IsPCUI and "tips/tips_noticetip_captions_window_pc" or "tips/tips_noticetip_captions_window"
  super.ctor(self, "tips_noticetip_captions_window", assetPath, UI.ECacheLv.High)
  self.data_ = Z.DataMgr.Get("noticetip_data")
end

function Tips_noticetip_captions_windowView:OnActive()
  self.uiBinder.Trans:SetAsFirstSibling()
  self.uiBinder.Trans:SetSizeDelta(0, 0)
end

function Tips_noticetip_captions_windowView:OnDeActive()
  self.data_.NpcShowingState = false
  if self.eventId_ then
    Z.AudioMgr:StopPlayingEvent(self.eventId_, 0.5)
  end
  self.isPlayingVoice_ = false
  self.eventId_ = nil
end

function Tips_noticetip_captions_windowView:OnRefresh()
  if not self.data_.NpcShowingState and not self.isPlayingVoice_ then
    self.data_.NpcShowingState = true
    self.uiBinder.anim:Pause()
    self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
    self.timerMgr:Clear()
    self:showNpcTip()
  end
end

function Tips_noticetip_captions_windowView:showNpcTip()
  local msgItem = self.data_:DequeueNpcData()
  local config = msgItem.config
  self:playVoice(config)
  local chatName = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(config.ChatName, msgItem.param))
  self.uiBinder.lab_name.text = chatName
  local content = Z.TableMgr.DecodeLineBreak(Z.Placeholder.Placeholder(config.Content, msgItem.param))
  self:setAlignmentByContent(content)
  self:setTextContent(content, config.TypewriterEffect)
  local repeatCount = config.RepeatPlay[1] or 1
  repeatCount = math.max(repeatCount, 1)
  local showInterval = (config.RepeatPlay[2] or 0) * 0.001
  local showOnceAction = function()
    repeatCount = repeatCount - 1
    self.timerMgr:StartTimer(function()
      if repeatCount <= 0 then
        if 0 < #self.data_.npc_msg_data then
          if not self.isPlayingVoice_ then
            self:showNpcTip()
          end
        else
          self:checkCloseView()
        end
      end
    end, config.DurationTime)
  end
  self.timerMgr:StartTimer(function()
    showOnceAction()
    if 0 < repeatCount then
      self.timerMgr:StartTimer(showOnceAction, config.DurationTime + showInterval, repeatCount)
    end
  end, config.Delay)
end

function Tips_noticetip_captions_windowView:setAlignmentByContent(content)
  self.uiBinder.lab_content.text = content
  local size = self.uiBinder.lab_content:GetPreferredValues(content)
  self.uiBinder.layout_group:ForceRebuildLayoutImmediate()
  if size.y > 50 then
    self.uiBinder.lab_content.alignment = TMPro.TextAlignmentOptions.TopLeft
  else
    self.uiBinder.lab_content.alignment = TMPro.TextAlignmentOptions.Top
  end
end

function Tips_noticetip_captions_windowView:setTextContent(content, isTypewriter)
  if isTypewriter then
    self.uiBinder.lab_content:DoTextByPreSec(content, 20, self.cancelSource:CreateToken())
  else
    self.uiBinder.lab_content.text = content
  end
end

function Tips_noticetip_captions_windowView:checkCloseView()
  if #self.data_.npc_msg_data == 0 and not self.isPlayingVoice_ then
    self.data_.NpcShowingState = false
    self.uiBinder.anim:CoroPlay(Z.DOTweenAnimType.Close, function()
      Z.EventMgr:Dispatch("ShowNoticeCaption")
    end, function(err)
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      logError("CoroPlay err={0}", err)
    end)
  end
end

function Tips_noticetip_captions_windowView:playVoice(config)
  if config and not string.zisEmpty(config.VoiceEventName) and not string.zisEmpty(config.VoiceControlEvent) then
    if config.WaitVoiceFinish then
      self.isPlayingVoice_ = true
      self.eventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(config.VoiceEventName, config.VoiceControlEvent, function()
        self.isPlayingVoice_ = false
        if #self.data_.npc_msg_data > 0 then
          self:showNpcTip()
        else
          self:checkCloseView()
        end
      end)
    else
      self.eventId_ = Z.AudioMgr:PlayExternalVoiceWithEndCallback(config.VoiceEventName, config.VoiceControlEvent)
    end
  end
end

return Tips_noticetip_captions_windowView
