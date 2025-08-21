local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleVoice = class("ChatBubbleVoice", super)

function ChatBubbleVoice:OnInit()
  super.OnInit(self)
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.reportVM_ = Z.VMMgr.GetVM("report")
  self:AddAsyncListener(self.uiBinder.btn_voice_content, function()
    self:onChangeVoice()
  end)
  self:AddAsyncListener(self.uiBinder.btn_voice_content.OnLongPressEvent, function()
    if not self.parent or not self.parent.UIView then
      return
    end
    local isOpenVoiceText = self.gotoFuncVM_.FuncIsOn(E.FunctionID.ChatVoiceText, true)
    if (Z.ChatMsgHelper.GetIsSelfMessage(self.data_) or not self.reportVM_.IsReportOpen(true)) and not isOpenVoiceText then
      return
    end
    local type = isOpenVoiceText and E.ChatDialogueFuncType.VoiceType or E.ChatDialogueFuncType.None
    self.parent.UIView:OpenChatTips(self.uiBinder.node_content_tips, type, function()
      self:onVoiceToText()
    end, Z.ChatMsgHelper.GetIsSelfMessage(self.data_), self.data_)
  end, nil, nil)
  self:refreshContentOffest()
end

function ChatBubbleVoice:refreshContentOffest()
  if Z.IsPCUI then
    self.imgOffestWidth_ = 20
    self.imgOffestHeight_ = 15
    self.heightOffest_ = 100
    self.rootHeight_ = 80
    self.voiceShortWidth_ = 150
    self.voiceLongWidth_ = 235
    self.voiceBgOffest_ = 38
    self.voiceTextWidth_ = 380
    self.selfVoiceTextWidth_ = 220
  else
    self.imgOffestWidth_ = 32
    self.imgOffestHeight_ = 32
    self.heightOffest_ = 162
    self.rootHeight_ = 130
    self.voiceShortWidth_ = 182
    self.voiceLongWidth_ = 266
    self.voiceBgOffest_ = 38
    self.voiceTextWidth_ = 584
    self.selfVoiceTextWidth_ = 285
  end
end

function ChatBubbleVoice:OnRefresh(data)
  super.OnRefresh(self, data)
  self:refreshVoice()
end

function ChatBubbleVoice:refreshVoice()
  local isShowVoiceText = Z.ChatMsgHelper.GetVoiceTextShow(self.data_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_text, isShowVoiceText)
  if isShowVoiceText then
    local voiceText = Z.ChatMsgHelper.GetVoiceText(self.data_)
    self.uiBinder.lab_voice_text.text = voiceText
    local isSelf = Z.ChatMsgHelper.GetIsSelfMessage(self.data_)
    local size = self.uiBinder.lab_voice_text:GetPreferredValues(voiceText, isSelf and self.selfVoiceTextWidth_ or self.voiceTextWidth_, 31)
    self.uiBinder.lab_voice_text_ref:SetWidth(size.x)
    self.uiBinder.lab_voice_text_ref:SetHeight(size.y)
    self.uiBinder.img_voice_text:SetWidth(size.x + self.imgOffestWidth_)
    self.uiBinder.img_voice_text:SetHeight(size.y + self.imgOffestHeight_)
    self.uiBinder.Trans:SetHeight(size.y + self.heightOffest_)
  else
    self.uiBinder.lab_voice_text.text = ""
    self.uiBinder.Trans:SetHeight(self.rootHeight_)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
  local voiceSecond = Z.ChatMsgHelper.GetVoiceSeconds(self.data_)
  self.uiBinder.lab_speaking_time.text = string.zconcat(voiceSecond, "\"")
  self:refreshChatDraftWidth(voiceSecond)
  self:setVoiceState(Z.ChatMsgHelper.GetVoiceIsPlay(self.data_))
end

function ChatBubbleVoice:setVoiceState(isPlay)
  if not self.uiBinder then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_normal, not isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_img_voice, isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice1, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice2, self.chatDraftIsLong_)
  if isPlay then
    local animName = self.chatDraftIsLong_ and "anim_chat_bubble_loop_long" or "anim_chat_bubble_loop"
    self.uiBinder.anim_voice:PlayLoop(animName)
    self.uiBinder.anim:PlayLoop("anim_chat_bubble_other_voice")
  else
    self.uiBinder.anim_voice:Stop()
    self.uiBinder.anim:Stop()
  end
end

function ChatBubbleVoice:onVoiceToText()
  Z.ChatMsgHelper.SetVoiceTextShow(self.data_)
  self:refreshVoice()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.Refresh)
end

function ChatBubbleVoice:refreshChatDraftWidth(time)
  if time <= 5 then
    self.uiBinder.btn_voice_content_ref:SetWidth(self.voiceShortWidth_)
    if self.uiBinder.img_bg_ref then
      self.uiBinder.img_bg_ref:SetWidth(self.voiceShortWidth_ + self.voiceBgOffest_)
    end
    self.chatDraftIsLong_ = false
  else
    self.uiBinder.btn_voice_content_ref:SetWidth(self.voiceLongWidth_)
    if self.uiBinder.img_bg_ref then
      self.uiBinder.img_bg_ref:SetWidth(self.voiceLongWidth_ + self.voiceBgOffest_)
    end
    self.chatDraftIsLong_ = true
  end
end

function ChatBubbleVoice:onChangeVoice()
  local isPlay = Z.ChatMsgHelper.GetVoiceIsPlay(self.data_)
  if isPlay then
    Z.Voice.StopPlayback()
    return
  end
  local voicePath = Z.ChatMsgHelper.GetVoiceFilePath(self.data_)
  if voicePath and voicePath ~= "" then
    self.chatMainVm_.VoicePlaybackRecording(voicePath, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(self.data_, true)
      self:setVoiceState(true)
    end, function()
      Z.ChatMsgHelper.SetVoiceIsPlay(self.data_, false)
      self:setVoiceState(false)
    end)
    return
  else
    if not self.parent or not self.parent.UIView then
      return
    end
    local fileId = Z.ChatMsgHelper.GetVoiceFileId(self.data_)
    if fileId then
      local voiceData = {
        msgId = Z.ChatMsgHelper.GetMsgId(self.data_),
        channelId = Z.ChatMsgHelper.GetChannelId(self.data_),
        targetId = Z.ChatMsgHelper.GetPrivateChatTargetId(self.data_),
        isComprehensive = self.parent.UIView:IsComprehensive(),
        fileId = fileId
      }
      table.insert(self.chatMainData_.DownVoiceList, voiceData)
      local isSuccess = Z.Voice.DownloadRecord(fileId)
      if not isSuccess then
        table.remove(self.chatMainData_.DownVoiceList, 1)
      end
    end
  end
end

return ChatBubbleVoice
