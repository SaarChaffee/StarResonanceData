local UI = Z.UI
local super = require("ui.ui_subview_base")
local Chat_input_box_tpl_pcView = class("Chat_input_box_tpl_pcView", super)

function Chat_input_box_tpl_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "chat_input_box_tpl_pc", "chat_pc/chat_input_box_tpl_pc", UI.ECacheLv.None)
end

function Chat_input_box_tpl_pcView:OnActive()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.effect_unsend)
  self:onInitData()
  self:BindEvents()
  self:onInitProp()
  self:onInitRed()
end

function Chat_input_box_tpl_pcView:OnRefresh()
  self.channelId_ = self.viewData.channelId
  self.charId_ = self.viewData.charId
  self.windowType_ = self.viewData.windowType
  self:refreshChatInputBoxState()
end

function Chat_input_box_tpl_pcView:OnDeActive()
  self:UnBindEvents()
  self:clearRed()
  if self.openEmojiView_ then
    self.openEmojiView_ = false
    Z.UIMgr:CloseView("chat_emoji_container_popup")
  end
  self.channelId_ = nil
  self.charId_ = nil
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.effect_unsend)
end

function Chat_input_box_tpl_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatInputState, self.refreshChatInputBoxState, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.refreshChatInputBoxState, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatVoiceUpLoad, self.onVoiceRecordUploaded, self)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
end

function Chat_input_box_tpl_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatInputState, self.refreshChatInputBoxState, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.refreshChatInputBoxState, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatVoiceUpLoad, self.onVoiceRecordUploaded, self)
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
end

function Chat_input_box_tpl_pcView:onInitData()
  self.chatData_ = Z.DataMgr.Get("chat_main_data")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.teamVM_ = Z.VMMgr.GetVM("team")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.channelId_ = self.viewData.channelId
  self.charId_ = self.viewData.charId
  self.windowType_ = self.viewData.windowType
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

function Chat_input_box_tpl_pcView:onInitProp()
  self.uiBinder.chat_input_box_tpl:SetOffsetMax(0, 0)
  self.uiBinder.chat_input_box_tpl:SetOffsetMin(0, 0)
  self.uiBinder.chat_input_box_tpl:SetHeight(80)
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
  self:AddClick(self.uiBinder.node_btn_more, function()
    local viewData = {
      parentView = self,
      channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_,
      charId = self.charId_,
      windowType = E.ChatWindow.Main,
      isHideChatInputBox = true
    }
    Z.UIMgr:OpenView("chat_emoji_container_popup", viewData)
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
    local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.windowType_, self.charId_)
    self.chatMainVm_.VoicePlaybackRecording(chatDraft.filePath, function()
      self:playChatDraft(true)
    end, function()
      self:playChatDraft(false)
    end)
  end)
  self:AddClick(self.uiBinder.node_btn_delete, function()
    self.chatData_:SetChatDraft({msg = ""}, self.channelId_, self.windowType_, self.charId_)
    self:RefreshChatDraft(true)
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
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, false)
  self.uiBinder.input_field_ref:SetHeight(40)
  self:checkInputActive()
  self.chatDraftIsLong_ = false
  self:refreshChatInputBoxState()
end

function Chat_input_box_tpl_pcView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.ChatInputBoxMoreBtn, self, self.uiBinder.node_more_red)
end

function Chat_input_box_tpl_pcView:onClickMoreRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.ChatInputBoxMoreBtn)
end

function Chat_input_box_tpl_pcView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.ChatInputBoxMoreBtn)
end

function Chat_input_box_tpl_pcView:onVoiceRecordUploaded(isSuccess, errorCode, fileID, text, filePath)
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
    }, voiceChannelId, self.windowType_, self.charId_)
    self:RefreshChatDraft(true)
  else
    Z.CoroUtil.create_coro_xpcall(function()
      self.chatMainVm_.AsyncSendMessage(voiceChannelId, self.charId_, "", E.ChitChatMsgType.EChatMsgVoice, nil, self.chatData_.CancelSource:CreateToken(), fileID, curFileTime, text)
    end)()
  end
end

function Chat_input_box_tpl_pcView:onSendBtnClick()
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
    local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.windowType_, self.charId_)
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
      end
    else
      local ret = self.chatMainVm_.AsyncSendMessage(self.channelId_, self.charId_, chatDraft.msg, msgType, nil, self.chatData_.CancelSource:CreateToken(), chatDraft.fileId, chatDraft.fileTime, chatDraft.voiceMsg)
      if ret then
        self:clearChatInput()
      end
    end
  end
end

function Chat_input_box_tpl_pcView:checkChannelLevelLimit()
  local showChannelId = self.channelId_
  if E.ChatChannelType.EComprehensive == self.channelId_ then
    showChannelId = self.chatData_:GetComprehensiveId()
  end
  return self.chatMainVm_.CheckChannelLevelLimit(showChannelId)
end

function Chat_input_box_tpl_pcView:checkInputActive()
  if Z.IsPCUI then
    self.uiBinder.input_field:ActivateInputField()
  end
end

function Chat_input_box_tpl_pcView:checkItemShareLimit()
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

function Chat_input_box_tpl_pcView:clearChatInput()
  self.chatData_:SetChatDraft({msg = ""}, self.channelId_, self.windowType_, self.charId_)
  self:RefreshChatDraft(true)
end

function Chat_input_box_tpl_pcView:onChannelBtnClick()
  if self.isOpenChannelList_ then
  else
  end
  self.isOpenChannelList_ = not self.isOpenChannelList_
end

function Chat_input_box_tpl_pcView:onMoreBtnClick()
  if self.viewData.isEmojiInput then
    return
  end
  self:onClickMoreRed()
  local channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
  local viewData = {
    parentView = self,
    channelId = channelId,
    charId = self.charId_,
    windowType = self.windowType_
  }
  self.openEmojiView_ = true
  Z.UIMgr:OpenView("chat_emoji_container_popup", viewData)
end

function Chat_input_box_tpl_pcView:onValueChange(text)
  text = string.gsub(text, "\n", "")
  text = string.gsub(text, "\r", "")
  text = Z.RichTextHelper.RmoveHrefTag(text)
  self:onCheckChar(text)
  self.chatData_:SetChatDraft({msg = text}, self.channelId_, self.windowType_, self.charId_)
  self:RefreshChatDraft(false)
end

function Chat_input_box_tpl_pcView:onCheckChar(msg)
  local curCount = string.zlenNormalize(msg)
  if curCount <= self.charMaxLimit_ - self.charMiddleLimit_ then
    self.isOutRangeLimit_ = false
  elseif curCount <= self.charMaxLimit_ then
    curCount = Z.RichTextHelper.ApplyStyleTag(curCount, E.TextStyleTag.ChannelMidLitMit)
    self.isOutRangeLimit_ = false
  else
    curCount = Z.RichTextHelper.ApplyStyleTag(curCount, E.TextStyleTag.ChannelLowLitMit)
    self.isOutRangeLimit_ = true
  end
  self.uiBinder.lab_num.text = string.zconcat(curCount, "/", self.charMaxLimit_)
end

function Chat_input_box_tpl_pcView:onEndEditChange(text)
  if not self.viewData then
    return
  end
  text = Z.RichTextHelper.RmoveHrefTag(text)
  self.chatData_:SetChatDraft({msg = text}, self.channelId_, self.windowType_, self.charId_)
end

function Chat_input_box_tpl_pcView:refreshCD()
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
    else
      self.uiBinder.lab_time.text = ""
      self.uiBinder.node_btn_send.IsDisabled = false
      self.uiBinder.node_btn_send.interactable = true
    end
  end
end

function Chat_input_box_tpl_pcView:checkIsChatCD()
  local channelId = self.channelId_ == E.ChatChannelType.EComprehensive and self.chatData_:GetComprehensiveId() or self.channelId_
  return self.chatMainVm_.CheckIsChatCD(channelId)
end

function Chat_input_box_tpl_pcView:InputEmoji(emoji, isCover)
  local text = ""
  if isCover then
    text = emoji
  else
    text = string.format("%s%s", self.uiBinder.input_field.text, emoji)
  end
  self.uiBinder.input_field.text = text
  self.uiBinder.input_field:MoveTextEnd(false)
  self.chatData_:SetChatDraft({
    msg = self.uiBinder.input_field.text
  }, self.channelId_, self.windowType_, self.charId_)
end

function Chat_input_box_tpl_pcView:InputItem(item)
  local text = self.uiBinder.input_field.text
  self.chatData_:RefreshShareData(text, item, E.ChatHyperLinkType.ItemShare)
  self.uiBinder.input_field.text = self.chatData_:GetHyperLinkShareContent()
end

function Chat_input_box_tpl_pcView:goToFunc()
  if self.goToFunc_ == E.GoToFunc.chatSet then
    self.chatMainVm_.OpenChatSettingPopupView(E.ChatSetTab.MsgFilter)
  elseif self.goToFunc_ == E.GoToFunc.team then
    self.gotoFuncVM_.GoToFunc(E.TeamFuncId.Team)
  elseif self.goToFunc_ == E.GoToFunc.union then
    self.gotoFuncVM_.GoToFunc(E.UnionFuncId.Union)
  end
end

function Chat_input_box_tpl_pcView:DelMsg()
  self.uiBinder.input_field:Backspace()
  self.chatData_:SetChatDraft({
    msg = self.uiBinder.input_field.text
  }, self.channelId_, self.windowType_, self.charId_)
end

function Chat_input_box_tpl_pcView:refreshChatInputBoxState()
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
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_mute, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_join, false)
    self:refreshChatInputChannel()
    if self.channelId_ == E.ChatChannelType.ESystem then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_input_box, true)
      self:RefreshChatDraft(true)
    end
  end
end

function Chat_input_box_tpl_pcView:checkIsBan()
  if not self.chatData_ then
    return false
  end
  local banTime = self.chatData_:GetBanTime()
  return 0 < banTime
end

function Chat_input_box_tpl_pcView:RefreshBanTxt()
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

function Chat_input_box_tpl_pcView:startBanTimeCD()
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

function Chat_input_box_tpl_pcView:checkJoinState()
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

function Chat_input_box_tpl_pcView:refreshBtnContent(content, func)
  self.uiBinder.lab_content_normal.text = content
  self.goToFunc_ = func
end

function Chat_input_box_tpl_pcView:refreshChatInputChannel()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_channel, self.channelId_ == E.ChatChannelType.EComprehensive)
  if self.channelId_ == E.ChatChannelType.EComprehensive then
    self:refreshchannelDpdFunction()
  end
  self:refreshCD()
end

function Chat_input_box_tpl_pcView:refreshchannelDpdFunction()
  self.channelIdList_ = {}
  self.channelNameList_ = {}
  local comprehensiveConfig = self.chatData_:GetExceptCurChannel()
  for i = 1, #comprehensiveConfig do
    local config = comprehensiveConfig[i]
    local chatSettingData = self.chatSettingData_:GetSynthesis(config.Id)
    if chatSettingData and config.Id ~= E.ChatChannelType.ESystem then
      self.channelNameList_[#self.channelNameList_ + 1] = config.ChannelName
      self.channelIdList_[#self.channelIdList_ + 1] = config.Id
    end
  end
  local curChannelId = self.chatData_:GetComprehensiveId()
  local curChannelTable = self.chatData_:GetConfigData(curChannelId)
  self.channelNameList_[#self.channelNameList_ + 1] = curChannelTable.ChannelName
  self.channelIdList_[#self.channelIdList_ + 1] = curChannelId
  self.uiBinder.dpd_channel:ClearOptions()
  self.uiBinder.dpd_channel:AddOptions(self.channelNameList_)
  self.uiBinder.dpd_channel:AddListener(function(index)
    if 0 <= index then
      self.chatMainVm_.SetComprehensiveId(self.channelIdList_[index + 1])
      self:refreshChannelIcon()
    end
  end, true)
  self.uiBinder.dpd_channel:SetValueWithoutNotify(#self.channelNameList_ - 1)
  self:refreshChannelIcon()
end

function Chat_input_box_tpl_pcView:refreshChannelIcon()
  local curChannelId = self.chatData_:GetComprehensiveId()
  self.uiBinder.img_channel:SetImage(Z.ChatMsgHelper.GetChatChannelIconByChannelId(curChannelId))
end

function Chat_input_box_tpl_pcView:RefreshChatDraft(isChangeInput)
  if not self.chatData_ or not self.viewData then
    return
  end
  local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.windowType_, self.charId_)
  if not chatDraft or not chatDraft.fileId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.input_field_ref, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_dragt_voice, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_more, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_delete, false)
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
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_more, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_delete, true)
    self:refreshChatDraftState()
    self:refreshChatDraftWidth(chatDraft.fileTime)
    self:playChatDraft(false)
    self.uiBinder.lab_speaking_time.text = string.zconcat(chatDraft.fileTime, "\"")
  end
  self:refreshVoiceBtnState()
end

function Chat_input_box_tpl_pcView:onFuncDataChange(funcTable)
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

function Chat_input_box_tpl_pcView:refreshVoiceBtnState()
  local chatDraft = self.chatData_:GetChatDraft(self.channelId_, self.windowType_, self.charId_)
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

function Chat_input_box_tpl_pcView:showVoiceState()
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

function Chat_input_box_tpl_pcView:refreshChatDraftState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_play, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_play, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_play_anim, false)
end

function Chat_input_box_tpl_pcView:playChatDraft(isPlay)
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
    self.uiBinder.anim:Stop()
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice1, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_voice2, false)
  end
end

function Chat_input_box_tpl_pcView:refreshChatDraftWidth(time)
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

function Chat_input_box_tpl_pcView:startCheckRecordTime()
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

function Chat_input_box_tpl_pcView:stopCheckRecordTime()
  if self.startCheckTime_ then
    self.timerMgr:StopTimer(self.startCheckTime_)
    self.startCheckTime_ = nil
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_voice, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.effect_unsend, false)
end

function Chat_input_box_tpl_pcView:upLoadRecord(voiceFilePath)
  self.chatData_:SetChatVoiceChannelId(self.channelId_)
  self.upLoadRecord_ = Z.Voice.UploadRecord(voiceFilePath)
end

return Chat_input_box_tpl_pcView
