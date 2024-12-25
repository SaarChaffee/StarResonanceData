local super = require("ui.component.chat.chat_bubble_base")
local ChatBubbleVoice = class("ChatBubbleVoice", super)

function ChatBubbleVoice:OnInit()
  super.OnInit(self)
  self:AddAsyncListener(self.uiBinder.btn_voice_content, function()
    self:onChangeVoice()
  end)
  self:AddAsyncListener(self.uiBinder.btn_voice_content.OnLongPressEvent, function()
    self.parent.UIView:OpenChatTips(self.uiBinder.node_content_tips, E.ChatDialogueFuncType.VoiceType, function()
      self:onVoiceToText()
    end)
  end, nil, nil)
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_voice1)
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_voice2)
end

function ChatBubbleVoice:OnUnInit()
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_voice1)
  self.parent.UIView.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_voice2)
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
    local width = 584
    if isSelf then
      width = 285
    end
    local size = self.uiBinder.lab_voice_text:GetPreferredValues(voiceText, width, 31)
    self.uiBinder.lab_voice_text_ref:SetWidth(size.x)
    self.uiBinder.lab_voice_text_ref:SetHeight(size.y)
    self.uiBinder.img_voice_text:SetWidth(size.x + 32)
    self.uiBinder.img_voice_text:SetHeight(size.y + 32)
    self.uiBinder.Trans:SetHeight(size.y + 162)
  else
    self.uiBinder.lab_voice_text.text = ""
    self.uiBinder.Trans:SetHeight(130)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
  local voiceSecond = Z.ChatMsgHelper.GetVoiceSeconds(self.data_)
  self.uiBinder.lab_speaking_time.text = string.zconcat(voiceSecond, "\"")
  self:refreshChatDraftWidth(voiceSecond)
  self:setVoiceState(Z.ChatMsgHelper.GetVoiceIsPlay(self.data_))
end

function ChatBubbleVoice:setVoiceState(isPlay)
  self.isPlayVoice_ = isPlay
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_normal, not isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_img_voice, isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_voice1, isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_voice2, self.chatDraftIsLong_ and isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice, not self.chatDraftIsLong_ and not isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_long, self.chatDraftIsLong_ and not isPlay)
  if isPlay then
    self.uiBinder.anim:PlayLoop("anim_chat_input_box_tpl_close")
  else
    self.uiBinder.anim:Stop()
  end
end

function ChatBubbleVoice:onVoiceToText()
  Z.ChatMsgHelper.SetVoiceTextShow(self.data_)
  self:refreshVoice()
end

function ChatBubbleVoice:refreshChatDraftWidth(time)
  if time <= 5 then
    self.uiBinder.btn_voice_content_ref:SetWidth(182)
    self.chatDraftIsLong_ = false
  else
    self.uiBinder.btn_voice_content_ref:SetWidth(266)
    self.chatDraftIsLong_ = true
  end
end

function ChatBubbleVoice:onChangeVoice()
  self.isPlayVoice_ = not self.isPlayVoice_
  if not self.isPlayVoice_ then
    Z.Voice.StopPlayback()
    self:setVoiceState(false)
    return
  end
  local voicePath = Z.ChatMsgHelper.GetVoiceFilePath(self.data_)
  if voicePath and voicePath ~= "" then
    self.chatMainVm_.VoicePlaybackRecording(voicePath, function()
      self:setVoiceState(true)
    end, function()
      self:setVoiceState(false)
    end)
    return
  end
  if Z.ChatMsgHelper.GetVoiceFileId(self.data_) then
    table.insert(self.chatMainData_.DownVoiceList, {
      msgId = Z.ChatMsgHelper.GetMsgId(self.data_),
      channelId = Z.ChatMsgHelper.GetChannelId(self.data_),
      targetId = Z.ChatMsgHelper.GetTargetCharId(self.data_),
      isComprehensive = self.chatMainData_:GetChannelId() == E.ChatChannelType.EComprehensive
    })
    local isSuccess = Z.Voice.DownloadRecord(Z.ChatMsgHelper.GetVoiceFileId(self.data_))
    if not isSuccess then
      table.remove(self.chatMainData_.DownVoiceList, 1)
    end
  end
end

return ChatBubbleVoice
