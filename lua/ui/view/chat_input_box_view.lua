local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chat_input_boxView = class("Chat_input_boxView", super)
local chat_channel_togPath = "ui/prefabs/chat/chat_channel_toggle_tpl"

function Chat_input_boxView:ctor()
  self.uiBinder = nil
  super.ctor(self, "chat_input_box_tpl", "chat/chat_input_box_tpl", UI.ECacheLv.None)
end

function Chat_input_boxView:OnActive()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_unsend)
  self:onInitData()
  self:BindEvents()
  self:onInitProp()
  self:onInitRed()
end

function Chat_input_boxView:OnRefresh()
  self.channelId_ = self.viewData.channelId
  self.charId_ = self.viewData.charId
  self:refreshChatInputBoxState()
end

function Chat_input_boxView:OnDeActive()
  self:UnBindEvents()
  self:clearRed()
  if self.openEmojiView_ then
    self.openEmojiView_ = false
    Z.UIMgr:CloseView("chat_emoji_container_popup")
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_unsend)
end

function Chat_input_boxView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatInputState, self.refreshChatInputBoxState, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.refreshChatInputBoxState, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatVoiceUpLoad, self.onVoiceRecordUploaded, self)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
end

function Chat_input_boxView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatInputState, self.refreshChatInputBoxState, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.refreshChatInputBoxState, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatVoiceUpLoad, self.onVoiceRecordUploaded, self)
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
end

function Chat_input_boxView:onInitData()
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.channelId_ = self.viewData.channelId
  self.charId_ = self.viewData.charId
  self.charMaxLimit_ = self.chatData_:GetCharLimit()
  self.charMiddleLimit_ = 10
  self.charMinLimit_ = 0
  self.curCharNum_ = 0
  self.isOutRangeLimit_ = false
  self.isOpenChannelList_ = false
  self.minNum_ = -100
  self.timer_ = nil
  self.channelList_ = {}
  self.btnMicDown_ = false
  self.startRecord_ = false
end

function Chat_input_boxView:onInitProp()
  self.uiBinder.chat_input_box_tpl:SetOffsetMax(0, 0)
  self.uiBinder.chat_input_box_tpl:SetOffsetMin(0, 0)
  self.uiBinder.input_field:AddListener(function(string)
    self:onValueChange(string)
  end)
  self:AddAsyncListener(self.uiBinder.input_field, self.uiBinder.input_field.AddSubmitListener, function()
    if Z.IsPCUI then
      self:onSendBtnClick()
    end
  end)
  self.uiBinder.input_field:AddEndEditListener(function(text)
    self:onEndEditChange(text)
  end)
  self:AddAsyncClick(self.uiBinder.node_btn_send, function()
    self:onSendBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_channel, function()
    self:onChannelBtnClick()
  end)
  self:AddClick(self.uiBinder.node_btn_more, function()
    self:onMoreBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_join, function()
    self:goToFunc()
  end)
  self.uiBinder.node_btn_mic.OnPointDownEvent:AddListener(function()
    self.btnMicDown_ = true
    if self:checkChannelLevelLimit() then
      return
    end
    Z.PermissionUtils.CheckOrRequestPermission(Panda.SDK.PlatformPermission.Microphone, function(isPermission)
      if isPermission then
        if not self.btnMicDown_ then
          return
        end
        self.startRecord_ = true
        Z.Voice.StartRecording(function(isSuccess)
          if not self.btnMicDown_ then
            self.startRecord_ = false
            if isSuccess then
              Z.Voice.StopRecording()
            end
            return
          end
          if isSuccess then
            self:showVoiceState()
            local channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
            self.chatData_.VoiceChannelId = channelId
            self:startCheckRecordTime()
          else
            self.startRecord_ = false
            Z.TipsVM.ShowTipsLang(1000105)
          end
        end)
      else
        Z.TipsVM.ShowTips(4401)
      end
    end)
  end)
  self.uiBinder.node_btn_mic.OnPointUpEvent:AddListener(function()
    self.btnMicDown_ = false
    if not self.startRecord_ then
      return
    end
    self.startRecord_ = false
    local voiceFilePath = Z.Voice.StopRecording()
    if self.voiceIsCancel_ then
    elseif voiceFilePath then
      self:upLoadRecord(voiceFilePath)
    else
      Z.TipsVM.ShowTipsLang(1000104)
    end
    self:stopCheckRecordTime()
  end)
  self.uiBinder.rayimg_cancel.onEnter:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel_red, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uncancel, true)
    self.voiceIsCancel_ = true
  end)
  self.uiBinder.rayimg_cancel.onExit:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel_red, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uncancel, false)
    self.voiceIsCancel_ = false
  end)
  self.uiBinder.rayimg_audition.onEnter:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition_green, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unaudition, true)
    self.voiceIsAudition_ = true
  end)
  self.uiBinder.rayimg_audition.onExit:AddListener(function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition_green, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unaudition, false)
    if self.startRecord_ then
      self.voiceIsAudition_ = false
    end
  end)
  self:AddClick(self.uiBinder.btn_play, function()
    if self.playChatDraft_ then
      self:playChatDraft(false)
      Z.Voice.StopPlayback()
      return
    end
    local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.viewData.windowType, self.charId_)
    self.chatMainVm_.VoicePlaybackRecording(chatDraft.filePath, function()
      self:playChatDraft(true)
    end, function()
      self:playChatDraft(false)
    end)
  end)
  self:AddClick(self.uiBinder.btn_limit_tips, function()
    local banEndTime = self.chatData_:GetBanEndTime()
    if banEndTime <= 0 then
      return
    end
    Z.DialogViewDataMgr:OpenOKDialog(Lang("chatLimitTips", {
      time = Z.TimeFormatTools.TicksFormatTime(banEndTime * 1000, E.TimeFormatType.YMDHMS)
    }))
  end)
  self:checkInputActive()
  self:AddClick(self.uiBinder.node_btn_delete, function()
    self.chatData_:SetChatDraft({msg = ""}, self.channelId_, self.viewData.windowType, self.charId_)
    self:RefreshChatDraft(true)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel_group, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_box_bg, self.viewData.showInputBg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_box_line, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, false)
  self.uiBinder.input_field_ref:SetHeight(56)
  self.chatDraftIsLong_ = false
  self:refreshChatInputBoxState()
  self.IsResponseInput = self.viewData.activeInputActions
end

function Chat_input_boxView:onInitRed()
  if self.viewData.isEmojiInput then
    return
  end
  Z.RedPointMgr.LoadRedDotItem(E.RedType.ChatInputBoxMoreBtn, self, self.uiBinder.node_more_red)
end

function Chat_input_boxView:onClickMoreRed()
  if self.viewData.isEmojiInput then
    return
  end
  Z.RedPointMgr.OnClickRedDot(E.RedType.ChatInputBoxMoreBtn)
end

function Chat_input_boxView:clearRed()
  if self.viewData.isEmojiInput then
    return
  end
  Z.RedPointMgr.RemoveNodeItem(E.RedType.ChatInputBoxMoreBtn)
end

function Chat_input_boxView:onVoiceRecordUploaded(isSuccess, errorCode, fileID, text, filePath)
  local voiceChannelId = self.chatData_:GetChatVoiceChannelId()
  self.chatData_:SetChatVoiceChannelId(nil)
  if not isSuccess and errorCode and errorCode ~= 0 then
    if errorCode == Z.ConstValue.Face.FaceVoiceCivilFailed then
      Z.TipsVM.ShowTips(1006045)
    else
      Z.TipsVM.ShowTips(1006046, {val = errorCode})
    end
  end
  if not self.upLoadRecord_ then
    return
  end
  self.upLoadRecord_ = false
  if self.voiceIsCancel_ then
    return
  end
  if not isSuccess then
    return
  end
  local curFileTime = math.floor(Z.Voice.GetRecordDuration(filePath) + 0.5)
  if self.voiceIsAudition_ then
    self.chatData_:SetChatDraft({
      msg = "",
      fileId = fileID,
      fileTime = curFileTime,
      filePath = filePath,
      voiceMsg = text
    }, voiceChannelId, self.viewData.windowType, self.charId_)
    self:RefreshChatDraft(true)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      self.chatMainVm_.AsyncSendMessage(voiceChannelId, self.charId_, "", E.ChitChatMsgType.EChatMsgVoice, nil, self.chatData_.CancelSource:CreateToken(), fileID, curFileTime, text)
    end)()
  end
end

function Chat_input_boxView:onSendBtnClick()
  if self:checkIsChatCD() then
    return
  end
  if self:checkChannelLevelLimit() then
    return
  end
  if self.isOutRangeLimit_ then
    Z.TipsVM.ShowTipsLang(1000103)
  else
    self:checkInputActive()
    local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.viewData.windowType, self.charId_)
    if not chatDraft then
      return
    end
    local msgType = E.ChitChatMsgType.EChatMsgTextMessage
    if chatDraft.fileId then
      msgType = E.ChitChatMsgType.EChatMsgVoice
    end
    if chatDraft.msg ~= self.uiBinder.input_field.text then
      chatDraft.msg = self.uiBinder.input_field.text
    end
    local hyperlinkType = self.chatData_:GetShareHyperLinkType()
    if self.chatData_:CheckShareData(chatDraft.msg) and hyperlinkType then
      if hyperlinkType == E.ChatHyperLinkType.ItemShare then
        if self:checkItemShareLimit() then
          Z.TipsVM.OpenMessageViewByContext(Lang("Thisitemcannotshared"), E.TipsType.MiddleTips)
        else
          self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
          if self.chatMainVm_.AsyncSendItemShare(self.channelId_, self.charId_, self.chatData_.CancelSource:CreateToken()) then
            self.chatData_:ClearShareData()
            self:clearChatInput()
            Z.EventMgr:Dispatch(Z.ConstValue.Chat.ClearItemShare)
          end
        end
      elseif hyperlinkType == E.ChatHyperLinkType.FishingArchives then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncSendFishingArchivesShare(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      elseif hyperlinkType == E.ChatHyperLinkType.FishingIllrate then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncSendFishingIllurateShare(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      elseif hyperlinkType == E.ChatHyperLinkType.FishingRank then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncSendFishingRankShare(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      elseif hyperlinkType == E.ChatHyperLinkType.PersonalZone then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncSendPersonalZone(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      elseif hyperlinkType == E.ChatHyperLinkType.MasterDungeonScore then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncSendMasterDungeonScoreShare(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      elseif hyperlinkType == E.ChatHyperLinkType.LocalPosition then
        self.chatData_:RefreshShareData(chatDraft.msg, self.chatData_:GetShareProtoData(), hyperlinkType)
        if self.chatMainVm_.AsyncLocalPosition(self.channelId_, self.chatData_.CancelSource:CreateToken()) then
          self.chatData_:ClearShareData()
          self:clearChatInput()
        end
      end
    else
      local ret = self.chatMainVm_.AsyncSendMessage(self.channelId_, self.charId_, chatDraft.msg, msgType, nil, self.chatData_.CancelSource:CreateToken(), chatDraft.fileId, chatDraft.fileTime, chatDraft.voiceMsg)
      if ret then
        self:clearChatInput()
      end
    end
  end
end

function Chat_input_boxView:checkChannelLevelLimit()
  local showChannelId = self.channelId_
  if E.ChatChannelType.EComprehensive == self.channelId_ then
    showChannelId = self.chatData_:GetComprehensiveId()
  end
  return self.chatMainVm_.CheckChannelLevelLimit(showChannelId)
end

function Chat_input_boxView:checkInputActive()
  if Z.IsPCUI then
    self.uiBinder.input_field:ActivateInputField()
  end
end

function Chat_input_boxView:checkItemShareLimit()
  if self.channelId_ == E.ChatChannelType.EChannelPrivate then
    return false
  end
  local chatChannel = Z.TableMgr.GetTable("ChannelTableMgr").GetRow(self.channelId_, true)
  if not chatChannel or not chatChannel.ItemShareLimit then
    return false
  end
  local item = self.chatData_:GetShareProtoData()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(item.configId)
  if not itemRow then
    return false
  end
  for i = 1, #chatChannel.ItemShareLimit do
    if chatChannel.ItemShareLimit[i] == itemRow.Type then
      return true
    end
  end
  return false
end

function Chat_input_boxView:clearChatInput()
  self.chatData_:SetChatDraft({msg = ""}, self.channelId_, self.viewData.windowType, self.charId_)
  self:RefreshChatDraft(true)
end

function Chat_input_boxView:onChannelBtnClick()
  if self.isOpenChannelList_ then
    self:destoryChannelList()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel_group, false)
  else
    self:asyncInitChannelList()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel_group, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_channel, true)
  self.isOpenChannelList_ = not self.isOpenChannelList_
end

function Chat_input_boxView:onMoreBtnClick()
  if self.viewData.isEmojiInput then
    return
  end
  self:onClickMoreRed()
  local channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
  local viewData = {
    parentView = self,
    channelId = channelId,
    charId = self.charId_,
    windowType = self.viewData.windowType
  }
  self.openEmojiView_ = true
  Z.UIMgr:OpenView("chat_emoji_container_popup", viewData)
  if self.viewData.onEmojiViewChange then
    self.viewData.onEmojiViewChange(true)
  end
end

function Chat_input_boxView:OnEmojiViewClose()
  if self.viewData and self.viewData.onEmojiViewChange and self.IsActive and self.IsLoaded then
    self.viewData.onEmojiViewChange(false)
  end
  self.openEmojiView_ = false
end

function Chat_input_boxView:onValueChange(text)
  text = Z.RichTextHelper.RmoveHrefTag(text)
  self:onCheckChar(text)
  self.chatData_:SetChatDraft({msg = text}, self.channelId_, self.viewData.windowType, self.charId_)
  if self.viewData.isEmojiInput then
    self.viewData.parentView:RefreshBackSpaceBtn()
    self.viewData.parentView:RefreshParentInput()
  end
  self:RefreshChatDraft(false)
end

function Chat_input_boxView:onCheckChar(msg)
  self.curCharNum_ = self.charMaxLimit_ - string.zlenNormalize(msg)
  self:checkCharNum()
end

function Chat_input_boxView:onEndEditChange(text)
  if not self.viewData then
    return
  end
  text = Z.RichTextHelper.RmoveHrefTag(text)
  self.chatData_:SetChatDraft({msg = text}, self.channelId_, self.viewData.windowType, self.charId_)
end

function Chat_input_boxView:checkCharNum()
  if self.curCharNum_ <= self.charMaxLimit_ and self.curCharNum_ > self.charMiddleLimit_ then
    self:refreshLimit(false, false, false)
    self.uiBinder.lab_num.text = ""
    self.isOutRangeLimit_ = false
    self:refreshInputLabHeight(false)
  elseif self.curCharNum_ <= self.charMiddleLimit_ and self.curCharNum_ > self.charMinLimit_ then
    self:refreshLimit(true, true, false)
    local str = Z.RichTextHelper.ApplyStyleTag(self.curCharNum_, E.TextStyleTag.ChannelMidLitMit)
    self.uiBinder.lab_num.text = str
    self.uiBinder.img_orange.fillAmount = self.curCharNum_ / self.charMiddleLimit_
    self.isOutRangeLimit_ = false
    self:refreshInputLabHeight(true)
  else
    self:refreshLimit(true, false, true)
    self.uiBinder.img_red.fillAmount = 1
    self.isOutRangeLimit_ = self.curCharNum_ < 0
    local content = ""
    if self.curCharNum_ <= self.minNum_ then
      content = string.format("%s...", string.sub(tostring(self.curCharNum_), 1, 2))
    else
      content = self.curCharNum_
    end
    local str = Z.RichTextHelper.ApplyStyleTag(content, E.TextStyleTag.ChannelLowLitMit)
    self.uiBinder.lab_num.text = str
    self:refreshInputLabHeight(true)
  end
end

function Chat_input_boxView:refreshInputLabHeight(isChange)
  if isChange then
    self.uiBinder.img_input_bg:SetOffsetMin(-18, -37)
    self.uiBinder.input_field_ref:SetOffsetMin(18, 36)
  else
    self.uiBinder.img_input_bg:SetOffsetMin(-18, -11)
    self.uiBinder.input_field_ref:SetOffsetMin(18, 10)
  end
end

function Chat_input_boxView:refreshCD()
  local curChannelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
  if curChannelId == E.ChatChannelType.ESystem or curChannelId == E.ChatChannelType.EChannelPrivate then
    self.uiBinder.lab_time.text = ""
    return
  else
    local cdTime = self.chatData_:GetChatCD(curChannelId)
    if cdTime and 0 < cdTime then
      local param = {
        time = {cd = cdTime}
      }
      self.uiBinder.lab_time.text = Lang("chatCDTime", param)
      self.uiBinder.node_btn_send.IsDisabled = true
      self.uiBinder.node_btn_send.interactable = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_limit_tips, false)
    else
      self.uiBinder.lab_time.text = ""
      self.uiBinder.node_btn_send.IsDisabled = false
      self.uiBinder.node_btn_send.interactable = true
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_limit_tips, true)
    end
  end
end

function Chat_input_boxView:checkIsChatCD()
  local channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
  return self.chatMainVm_.CheckIsChatCD(channelId)
end

function Chat_input_boxView:refreshChannelShow()
  local showChannelId = self.channelId_
  if E.ChatChannelType.EComprehensive == self.channelId_ then
    showChannelId = self.chatData_:GetComprehensiveId()
  end
  local config = self.chatData_:GetConfigData(showChannelId)
  if config then
    self.uiBinder.lab_channel.text = config.ChannelName
  else
    self.uiBinder.lab_channel.text = ""
  end
end

function Chat_input_boxView:visibleChannelBtn(isShowChannelBtn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.chat_input_channel, isShowChannelBtn)
  if isShowChannelBtn then
    self.uiBinder.group_input_field:SetOffsetMin(149, 0)
    self.uiBinder.group_input_field:SetOffsetMax(-262, 0)
    self.uiBinder.group_input_field:SetHeight(56)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_channel, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel_group, false)
    self:refreshChannelShow()
  else
    self.uiBinder.group_input_field:SetOffsetMin(10, 0)
    self.uiBinder.group_input_field:SetOffsetMax(-237, 0)
    self.uiBinder.node_btn:SetAnchorPosition(9, 0)
    self.uiBinder.group_input_field:SetHeight(56)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_channel, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_channel_group, false)
  end
end

function Chat_input_boxView:asyncInitChannelList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:destoryChannelList()
    local comprehensiveConfig = self.chatData_:GetExceptCurChannel()
    local chat_Setting_Data = Z.DataMgr.Get("chat_setting_data")
    for _, v in pairs(comprehensiveConfig) do
      local chatSettingData = chat_Setting_Data:GetSynthesis(v.Id)
      if chatSettingData and v.Id ~= E.ChatChannelType.ESystem then
        local item = self:AsyncLoadUiUnit(chat_channel_togPath, v.Id, self.uiBinder.btn_channel_group)
        item.lab_name.text = v.ChannelName
        self:AddClick(item.channel_btn, function()
          self:destoryChannelList()
          self.chatMainVm_.SetComprehensiveId(v.Id)
          self:visibleChannelBtn(true)
        end)
        self.channelList_[v.Id] = item
      end
    end
  end)()
end

function Chat_input_boxView:destoryChannelList()
  if table.zcount(self.channelList_) > 0 then
    for k, v in pairs(self.channelList_) do
      self:RemoveUiUnit(k)
    end
    self.channelList_ = {}
  end
end

function Chat_input_boxView:refreshLimit(isBg, isOrange, isRed)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, isBg)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_orange, isOrange)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, isRed)
end

function Chat_input_boxView:InputEmoji(emoji, isCover)
  local text = ""
  if isCover then
    text = emoji
  else
    text = string.format("%s%s", self.uiBinder.input_field.text, emoji)
  end
  self.uiBinder.input_field.text = text
  self.uiBinder.input_field:MoveTextEnd(false)
  self:RefreshChatDraft()
end

function Chat_input_boxView:InputItem(item)
  local text = self.uiBinder.input_field.text
  self.chatData_:RefreshShareData(text, item, E.ChatHyperLinkType.ItemShare)
  self.uiBinder.input_field.text = self.chatData_:GetHyperLinkShareContent()
end

function Chat_input_boxView:InputLocalPosition()
  local text = self.uiBinder.input_field.text
  self.chatData_:RefreshShareData(text, nil, E.ChatHyperLinkType.LocalPosition)
  self.uiBinder.input_field.text = self.chatData_:GetHyperLinkShareContent()
end

function Chat_input_boxView:goToFunc()
  if self.goToFunc_ == E.GoToFunc.chatSet then
    self.chatMainVm_.OpenChatSettingPopupView(E.ChatSetTab.MsgFilter)
  elseif self.goToFunc_ == E.GoToFunc.team then
    self.gotoFuncVM_.GoToFunc(E.TeamFuncId.Team)
  elseif self.goToFunc_ == E.GoToFunc.union then
    self.gotoFuncVM_.GoToFunc(E.UnionFuncId.Union)
  end
end

function Chat_input_boxView:DelMsg()
  self.uiBinder.input_field:Backspace()
  self.chatData_:SetChatDraft({
    msg = self.uiBinder.input_field.text
  }, self.channelId_, self.viewData.windowType, self.charId_)
end

function Chat_input_boxView:refreshChatInputBoxState()
  if self:checkIsBan() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_join, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, false)
    self:RefreshBanTxt()
    self:startBanTimeCD()
  elseif self:checkJoinState() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_join, self.chatMainVm_.GetUnionIsUnlock())
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, false)
    if self.viewData.windowType == E.ChatWindow.Main then
      self.uiBinder.img_line:SetOffsetMax(0, 2)
      self.uiBinder.img_line:SetOffsetMin(0, 0)
    else
      self.uiBinder.img_line:SetOffsetMax(0, 42)
      self.uiBinder.img_line:SetOffsetMin(0, 40)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_join, false)
    if self.channelId_ == E.ChatChannelType.ESystem then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, true)
      self:refreshChatInputChannel()
      self:RefreshChatDraft(true)
    end
  end
end

function Chat_input_boxView:checkIsBan()
  if not self.chatData_ then
    return false
  end
  local banTime = self.chatData_:GetBanTime()
  return 0 < banTime
end

function Chat_input_boxView:RefreshBanTxt()
  local banTime = self.chatData_:GetBanTime()
  if 0 < banTime then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, true)
    self.uiBinder.lab_mute.text = Lang("chat_block", {
      time = Z.TimeFormatTools.FormatToDHMS(banTime, true)
    })
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_mute, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_join, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_join, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, true)
  end
end

function Chat_input_boxView:startBanTimeCD()
  self.timerMgr:Clear()
  local banTime = self.chatData_:GetBanTime()
  if banTime <= 0 then
    return
  end
  local tmpTime = banTime
  self.timer_ = self.timerMgr:StartTimer(function()
    tmpTime = tmpTime - 1
    if tmpTime <= 0 then
      self:refreshChatInputBoxState()
    end
    self:RefreshBanTxt()
  end, 1, banTime)
end

function Chat_input_boxView:checkJoinState()
  if self.channelId_ == E.ChatChannelType.EComprehensive then
    if self.chatData_:GetComprehensiveId() == -1 then
      self:refreshBtnContent(Lang("chat_chatset"), E.GoToFunc.chatSet)
      return true
    else
      self.isOpenChannelList_ = false
    end
  elseif self.channelId_ == E.ChatChannelType.EChannelTeam then
    if self.teamVM_.CheckIsInTeam() == false then
      self:refreshBtnContent(Lang("chat_joinTeam"), E.GoToFunc.team)
      return true
    end
  elseif self.channelId_ == E.ChatChannelType.EChannelUnion then
    local unionVM = Z.VMMgr.GetVM("union")
    if unionVM:GetPlayerUnionId() == 0 then
      self:refreshBtnContent(Lang("chat_joinGuild"), E.GoToFunc.union)
      return true
    end
  end
  return false
end

function Chat_input_boxView:refreshBtnContent(content, func)
  self.uiBinder.lab_content_normal.text = content
  self.goToFunc_ = func
end

function Chat_input_boxView:refreshChatInputChannel()
  self:destoryChannelList()
  self:visibleChannelBtn(self.channelId_ == E.ChatChannelType.EComprehensive)
  self:refreshCD()
end

function Chat_input_boxView:RefreshChatDraft(isChangeInput)
  if not self.chatData_ or not self.viewData then
    return
  end
  local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.viewData.windowType, self.charId_)
  if not chatDraft or not chatDraft.fileId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.input_field_ref, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dragt_voice, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_bg, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_more, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_delete, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_limit_tips, true)
    local msg = ""
    if chatDraft and chatDraft.msg then
      msg = chatDraft.msg
    end
    msg = Z.RichTextHelper.RmoveHrefTag(msg)
    self:onCheckChar(msg)
    if isChangeInput then
      self.uiBinder.input_field.text = msg
    else
      self.uiBinder.input_field:SetTextWithoutNotify(msg)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.input_field_ref, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dragt_voice, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_bg, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_more, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_delete, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_limit_tips, false)
    self:refreshChatDraftState()
    self:refreshChatDraftWidth(chatDraft.fileTime)
    self:playChatDraft(false)
    self.uiBinder.lab_speaking_time.text = string.zconcat(chatDraft.fileTime, "\"")
  end
  self:refreshVoiceBtnState()
end

function Chat_input_boxView:onFuncDataChange(funcTable)
  if not funcTable then
    return
  end
  for funcId, isOpen in pairs(funcTable) do
    if funcId == E.FunctionID.ChatVoiceInput then
      self:refreshVoiceBtnState()
      break
    end
  end
end

function Chat_input_boxView:refreshVoiceBtnState()
  local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.viewData.windowType, self.charId_)
  local isShowVoice = self.viewData.isShowVoice and self.chatData_.VoiceIsInit and self.gotoFuncVM_.FuncIsOn(E.FunctionID.ChatVoiceInput, true)
  if chatDraft then
    if chatDraft.fileId and chatDraft.fileId ~= "" then
      isShowVoice = false
    elseif chatDraft.msg ~= nil and chatDraft.msg ~= "" then
      isShowVoice = false
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_send, not isShowVoice)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_mic, isShowVoice)
end

function Chat_input_boxView:showVoiceState()
  self.voiceIsCancel_ = false
  self.voiceIsAudition_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_uncancel, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unaudition, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel_red, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_cancel, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition_green, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_audition, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, true)
end

function Chat_input_boxView:refreshChatDraftState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_play, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_play_anim, false)
end

function Chat_input_boxView:playChatDraft(isPlay)
  self.playChatDraft_ = isPlay
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_play, not isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_play_anim, isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice, not self.chatDraftIsLong_ and not isPlay)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_long, self.chatDraftIsLong_ and not isPlay)
  if isPlay then
    self.uiBinder.anim_btn:PlayLoop("anim_chat_input_box_tpl_open")
    if self.chatDraftIsLong_ then
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice1, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice2, true)
      self.uiBinder.anim:PlayLoop("anim_chat_input_box_tpl_loop_long")
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice1, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice2, false)
      self.uiBinder.anim:PlayLoop("anim_chat_input_box_tpl_loop")
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice1, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice2, false)
    self.uiBinder.anim:Stop()
  end
end

function Chat_input_boxView:refreshChatDraftWidth(time)
  if time <= 5 then
    self.uiBinder.img_voice_ref:SetWidth(82)
    self.uiBinder.node_voice_draft:SetWidth(82)
    self.uiBinder.node_dragt_voice:SetWidth(182)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_long, false)
    self.chatDraftIsLong_ = false
  else
    self.uiBinder.img_voice_ref:SetWidth(168)
    self.uiBinder.node_voice_draft:SetWidth(168)
    self.uiBinder.node_dragt_voice:SetWidth(268)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice_long, true)
    self.chatDraftIsLong_ = true
  end
end

function Chat_input_boxView:startCheckRecordTime()
  local recordTime = Z.Global.ChatVoiceMsgMaxDuration
  self.startCheckTime_ = self.timerMgr:StartTimer(function()
    if not self.startRecord_ then
      return
    end
    self.startRecord_ = false
    local voiceFilePath = Z.Voice.StopRecording()
    if voiceFilePath then
      self:upLoadRecord(voiceFilePath)
    else
      Z.TipsVM.ShowTipsLang(1000104)
    end
    self.startCheckTime_ = nil
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, false)
  end, recordTime, 1)
end

function Chat_input_boxView:stopCheckRecordTime()
  if self.startCheckTime_ then
    self.timerMgr:StopTimer(self.startCheckTime_)
    self.startCheckTime_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, false)
end

function Chat_input_boxView:upLoadRecord(voiceFilePath)
  self.chatData_:SetChatVoiceChannelId(self.channelId_)
  self.upLoadRecord_ = Z.Voice.UploadRecord(voiceFilePath)
end

return Chat_input_boxView
