local UI = Z.UI
local super = require("ui.ui_view_base")
local Main_chat_pcView = class("Main_chat_pcView", super)
local loop_list_view = require("ui.component.loop_list_view")
local main_chat_channel_input_item = require("ui.component.chat.mainchat_channel_item")
local main_chat_channel_show_item = require("ui.component.chat.mainchat_channel_show_item")
local main_chat_bubble_content_item = require("ui.component.chat.mainchat_bubble_content_item")
local main_chat_bubble_picture_item = require("ui.component.chat.mainchat_bubble_picture_item")
local main_chat_bubble_tips_item = require("ui.component.chat.mainchat_bubble_tips_item")
local mainChatChannelItemHeight = 30
local inputKeyDescComp = require("input.input_key_desc_comp")

function Main_chat_pcView:ctor()
  self.uiBinder = nil
  super.ctor(self, "main_chat_pc")
  self.inputKeyDescComp_ = inputKeyDescComp.new()
end

function Main_chat_pcView:OnActive()
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatSettingData_ = Z.DataMgr.Get("chat_setting_data")
  self.mailData_ = Z.DataMgr.Get("mail_data")
  self.mainUIData_ = Z.DataMgr.Get("mainui_data")
  self.socialVM_ = Z.VMMgr.GetVM("socialcontact_main")
  self.inputChannelList_ = loop_list_view.new(self, self.uiBinder.loop_list, main_chat_channel_input_item, "main_channel_tpl")
  self.inputChannelList_:Init({})
  self.chatList_ = loop_list_view.new(self, self.uiBinder.loop_chat_list)
  self.chatList_:Init({})
  self.chatList_:SetGetItemClassFunc(function(data)
    local msgType = Z.ChatMsgHelper.GetMsgType(data)
    local content = Z.ChatMsgHelper.GetEmojiText(data)
    if msgType == E.ChitChatMsgType.EChatMsgPictureEmoji and content == "" then
      return main_chat_bubble_picture_item
    elseif msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice or msgType == E.ChitChatMsgType.EChatMsgClientTips then
      return main_chat_bubble_tips_item
    else
      return main_chat_bubble_content_item
    end
  end)
  self.chatList_:SetGetPrefabNameFunc(function(data)
    local msgType = Z.ChatMsgHelper.GetMsgType(data)
    local content = Z.ChatMsgHelper.GetEmojiText(data)
    local isSelfMessage = Z.ChatMsgHelper.GetIsSelfMessage(data)
    if msgType == E.ChitChatMsgType.EChatMsgPictureEmoji and content == "" then
      if isSelfMessage then
        return "main_bubble_self_picture"
      else
        return "main_bubble_other_picture"
      end
    elseif msgType == E.ChitChatMsgType.EChatMsgMultiLangNotice or msgType == E.ChitChatMsgType.EChatMsgClientTips then
      return "main_bubble_system_tips"
    elseif isSelfMessage then
      return "main_bubble_self_content"
    else
      return "main_bubble_other_content"
    end
  end)
  self.showChannelList_ = loop_list_view.new(self, self.uiBinder.loop_channel_list, main_chat_channel_show_item, "main_chat_channel_tpl_pc")
  self.showChannelList_:Init({})
  self:AddClick(self.uiBinder.btn_channel, function()
    self:changeChannelListState()
  end)
  self:AddClick(self.uiBinder.btn_news, function()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_news, false)
    self:refreshMainChatList()
  end)
  self.uiBinder.input_field:AddListener(function(text)
    self:onEditorChatData(text)
  end)
  self.uiBinder.input_field:AddEndEditListener(function(text)
    self:onEditorChatData(text)
  end)
  self:AddAsyncListener(self.uiBinder.input_field, self.uiBinder.input_field.AddSubmitListener, function()
    if self.uiBinder.input_field.text == "" then
      self:changeActiveState(false)
    else
      self:onClickSend()
    end
  end)
  self.uiBinder.node_list_event_trigger.onBeginDrag:AddListener(function(go, eventData)
    self.startDrag_ = true
  end)
  self.uiBinder.node_list_event_trigger.onEndDrag:AddListener(function(go, eventData)
    self.startDrag_ = false
  end)
  self:AddClick(self.uiBinder.btn_chat, function()
    self.socialVM_.OpenSocialContactView()
  end)
  self:AddClick(self.uiBinder.btn_friend, function()
    self.socialVM_.OpenFriendView()
  end)
  self:AddClick(self.uiBinder.btn_mail, function()
    self.socialVM_.OpenMailView()
  end)
  if not Z.IsPCUI then
    local channelId = self.chatMainData_:GetChannelId()
    self.chatMainData_:SetChatDataFlg(channelId, E.ChatWindow.Main, true, false)
  end
  self.checkDataListTimer_ = self.timerMgr:StartTimer(function()
    self:checkMainChatList()
  end, 1, -1)
  self:refreshMainChatList()
  self.uiBinder.press_check:StartCheck()
  self:AddClick(self.uiBinder.press_check.ContainGoEvent, function(isPointGo)
    if isPointGo then
      if self.chatMainData_.ActiveMainChatInput then
        return
      end
      self:changeActiveState(true)
    else
      if not self.chatMainData_.ActiveMainChatInput then
        return
      end
      self:changeActiveState(false)
    end
  end, nil, nil)
  self.inputKeyDescComp_:Init(102, self.uiBinder.node_key)
  self:changeActiveState(false)
  self:showView()
  self:startCheckMainUIHide()
  local channelId = self.chatMainData_:GetMainChatInputChannel()
  local config = self.chatMainData_:GetConfigData(channelId)
  self:refreshMainChatInputChannel(config)
  self:refreshInputState()
  self:hideChannelList()
  self:refreshChannelList()
  self:refreshMessageState()
  self:refreshMessageNum()
  self:updateMainUIMainChat()
  self:refreshViewInfo()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_news, false)
  self.uiBinder.input_field:AddEscCancelListener(function(text)
    if not self.chatMainData_.ActiveMainChatInput then
      return
    end
    self:changeActiveState(false)
  end)
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.refreshMainChatInputChannel, self)
  Z.EventMgr:Add(Z.ConstValue.Mail.ReceiveNewMal, self.refreshMailNum, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendMsgNum, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendMainChatNum, self.refreshFriendMsgNum, self)
  Z.EventMgr:Add(Z.ConstValue.MainUI.UpdateMainUIMainChat, self.updateMainUIMainChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.ChatInputState, self.refreshInputState, self)
  Z.EventMgr:Add(Z.ConstValue.Device.DeviceTypeChange, self.refreshKeyCodeDesc, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.RefreshChatChannel, self.refreshChannelList, self)
end

function Main_chat_pcView:OnDeActive()
  self.inputKeyDescComp_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.LanguageChange, self.refreshMainChatInputChannel, self)
  Z.EventMgr:Remove(Z.ConstValue.Mail.ReceiveNewMal, self.refreshMailNum, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendMsgNum, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendMainChatNum, self.refreshFriendMsgNum, self)
  Z.EventMgr:Remove(Z.ConstValue.MainUI.UpdateMainUIMainChat, self.updateMainUIMainChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.ChatInputState, self.refreshInputState, self)
  Z.EventMgr:Remove(Z.ConstValue.Device.DeviceTypeChange, self.refreshKeyCodeDesc, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.RefreshChatChannel, self.refreshChannelList, self)
  self:changeActiveState(false)
  self.inputChannelList_:UnInit()
  self.showChannelList_:UnInit()
  self.chatList_:UnInit()
  self.uiBinder.press_check:StopCheck()
  self:stopCheckMainUIHide()
  self.timerMgr:StopTimer(self.checkDataListTimer_)
  self.uiBinder.do_tween:ClearAll()
end

function Main_chat_pcView:OnTriggerInputAction(inputActionEventData)
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
    return
  end
  if inputActionEventData.ActionId == Z.InputActionIds.Chat and Z.PlayerInputController:CheckChatAndMapAction(inputActionEventData) then
    self.chatMainVM_.OpenChatMainPCView()
  elseif inputActionEventData.ActionId == Z.InputActionIds.OpenChat then
    self:activeChatInput()
  elseif inputActionEventData.ActionId == Z.InputActionIds.ExitUI then
    self:changeActiveState(false)
  elseif inputActionEventData.ActionId == Z.InputActionIds.InputChannelUp then
    self:moveChatChannelIndex(-1)
  elseif inputActionEventData.ActionId == Z.InputActionIds.InputChannelDown then
    self:moveChatChannelIndex(1)
  elseif inputActionEventData.ActionId == Z.InputActionIds.ChatChannelUp then
    self:changeChannelId(-1)
  elseif inputActionEventData.ActionId == Z.InputActionIds.ChatChannelDown then
    self:changeChannelId(1)
  end
end

function Main_chat_pcView:activeChatInput()
  if self.chatMainData_.ActiveMainChatInput then
    return
  end
  local funcVM = Z.VMMgr.GetVM("gotofunc")
  if not funcVM.CheckFuncCanUse(E.FunctionID.MainChat, false) then
    return
  end
  self:changeActiveState(true)
end

function Main_chat_pcView:startCheckMainUIHide()
  if not self.chatSettingData_:GetMainChatPCViewAutoHide() then
    return
  end
  if self.chatMainData_.ActiveMainChatInput then
    return
  end
  if self.checkViewShowHideTimer_ then
    self.timerMgr:StopTimer(self.checkViewShowHideTimer_)
  end
  local time = self.chatSettingData_:GetMainChatPCViewAutoHideTime()
  if time <= 0 then
    return
  end
  self.checkViewShowHideTimer_ = self.timerMgr:StartTimer(function()
    self:hideView()
  end, time, 1)
end

function Main_chat_pcView:stopCheckMainUIHide()
  self.timerMgr:StopTimer(self.checkViewShowHideTimer_)
  self.checkViewShowHideTimer_ = nil
end

function Main_chat_pcView:refreshViewInfo()
  self:refreshMailNum()
  self:refreshFriendMsgNum()
end

function Main_chat_pcView:hideChannelList()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_ref, false)
  if not self.isShowList_ then
    return
  end
  self.isShowList_ = false
  self:refreshShowHideState()
end

function Main_chat_pcView:refreshMainChatInputChannel(config)
  if not config then
    return
  end
  local channelName = Z.RichTextHelper.ApplyStyleTag(string.format("[%s]", config.ChannelName), config.ChannelStyle)
  self.uiBinder.lab_channel.text = channelName
end

function Main_chat_pcView:changeChannelListState()
  self.isShowList_ = not self.isShowList_
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list_ref, self.isShowList_)
  self:refreshShowHideState()
  if not self.isShowList_ then
    return
  end
  self:refreshChatChannelList()
  if #self.chatChannelList_ == 0 then
    return
  end
  self.selectChannelIndex_ = 1
  self.uiBinder.loop_list_ref:SetHeight(#self.chatChannelList_ * mainChatChannelItemHeight)
  self.inputChannelList_:ClearAllSelect()
  self.inputChannelList_:RefreshListView(self.chatChannelList_, false)
end

function Main_chat_pcView:refreshChatChannelList()
  self.chatChannelList_ = {}
  local channelId = self.chatMainData_:GetMainChatInputChannel()
  local channelList = self.chatMainData_:GetChannelList()
  self.chatMainData_:GetExceptCurChannel(channelId)
  for i = 1, #channelList do
    if channelList[i].Id == E.ChatChannelType.EChannelTeam then
      local teamVM = Z.VMMgr.GetVM("team")
      if teamVM.CheckIsInTeam() then
        table.insert(self.chatChannelList_, channelList[i])
      end
    elseif channelList[i].Id == E.ChatChannelType.EChannelUnion then
      local unionVM = Z.VMMgr.GetVM("union")
      if unionVM:GetPlayerUnionId() > 0 then
        table.insert(self.chatChannelList_, channelList[i])
      end
    elseif channelList[i].Id == E.ChatChannelType.EChannelWorld or channelList[i].Id == E.ChatChannelType.EChannelScene then
      table.insert(self.chatChannelList_, channelList[i])
    end
  end
end

function Main_chat_pcView:chooseChatChannel()
  if self.selectChannelIndex_ > 0 and self.selectChannelIndex_ <= #self.chatChannelList_ then
    self:OnSelectChannel(self.chatChannelList_[self.selectChannelIndex_])
  else
    self:hideChannelList()
  end
end

function Main_chat_pcView:moveChatChannelIndex(index)
  self:refreshChatChannelList()
  if not self.selectChannelIndex_ then
    self.selectChannelIndex_ = 1
  end
  self.selectChannelIndex_ = self.selectChannelIndex_ + index
  if self.selectChannelIndex_ <= 0 then
    self.selectChannelIndex_ = #self.chatChannelList_
  end
  if self.selectChannelIndex_ > #self.chatChannelList_ then
    self.selectChannelIndex_ = 1
  end
  self:OnSelectChannel(self.chatChannelList_[self.selectChannelIndex_])
end

function Main_chat_pcView:OnSelectChannel(channelChatRow)
  self.chatMainData_:SetMainChatInputChannel(channelChatRow.Id)
  self:refreshMainChatInputChannel(channelChatRow)
  self:hideChannelList()
  self:refreshInputState()
end

function Main_chat_pcView:refreshChannelList()
  local list = self.chatMainData_:GetChannelList()
  self.showChannelList_:RefreshListView(list, false)
  local channelId = self.chatMainData_:GetChannelId()
  local index = 1
  for i = 1, #list do
    if channelId == list[i].Id then
      index = i
      break
    end
  end
  self.showChannelList_:SetSelected(index)
end

function Main_chat_pcView:OnSelectShowChannel(channelTableRow)
  self.chatMainData_:SetChannelId(channelTableRow.Id)
  self:refreshMainChatList()
end

function Main_chat_pcView:changeChannelId(changeIndex)
  local list = self.chatMainData_:GetChannelList()
  local channelId = self.chatMainData_:GetChannelId()
  local index = 1
  for i = 1, #list do
    if channelId == list[i].Id then
      index = i
      break
    end
  end
  index = index + changeIndex
  if index > #list then
    index = 1
  end
  if index <= 0 then
    index = #list
  end
  self.showChannelList_:SetSelected(index)
  self:OnSelectShowChannel(list[index])
end

function Main_chat_pcView:refreshMessageState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_friend, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_system, false)
end

function Main_chat_pcView:refreshMessageNum(chatMsgCount)
  if self:getIsEnd() or not chatMsgCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_news, false)
    return
  end
  self.uiBinder.lab_news.text = Lang("MainChatPCNewMessageTips", {val = chatMsgCount})
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_news, true)
end

function Main_chat_pcView:getIsEnd()
  local _, y = self.uiBinder.node_content:GetAnchorPosition(nil, nil)
  local height = self.uiBinder.loop_chat_list.ViewPortHeight
  local _, allHeight = self.uiBinder.node_content:GetSizeDelta(nil, nil)
  if allHeight - (y + height) < height * 0.05 then
    return true
  else
    return false
  end
end

function Main_chat_pcView:checkMainChatList()
  if self.startDrag_ or not self:getIsEnd() then
    return
  end
  local channelId = self.chatMainData_:GetChannelId()
  local dataFlg = self.chatMainData_:GetChatDataFlg(channelId, E.ChatWindow.Main)
  if dataFlg.flg then
    self.chatMainData_:SetChatDataFlg(channelId, E.ChatWindow.Main, false, false)
  else
    return
  end
  self:showView()
  self:startCheckMainUIHide()
  self:refreshMainChatList()
end

function Main_chat_pcView:refreshMainChatList()
  local channelId = self.chatMainData_:GetChannelId()
  local msgList = self.chatMainData_:GetChannelQueueByChannelId(channelId, nil, true)
  self.chatList_:RefreshListView(msgList, false)
  self.chatList_:MovePanelToItemIndex(#msgList)
end

function Main_chat_pcView:onEditorChatData(text)
  local channelId = self.chatMainData_:GetMainChatInputChannel()
  self.chatMainData_:SetChatDraft({msg = text}, channelId, E.ChatWindow.Main)
end

function Main_chat_pcView:onClickSend()
  local channelId = self.chatMainData_:GetMainChatInputChannel()
  if self.chatMainVM_.CheckIsChatCD(channelId) then
    return
  end
  if self.chatMainVM_.CheckChannelLevelLimit(channelId) then
    return
  end
  local chatDraft = self.chatMainData_:GetChatDraft(channelId, E.ChatWindow.Main)
  if not chatDraft or chatDraft.msg == "" or not self.chatMainVM_.CheckChatNum(chatDraft.msg) then
    return
  end
  local ret = self.chatMainVM_.AsyncSendMessage(channelId, nil, chatDraft.msg, E.ChitChatMsgType.EChatMsgTextMessage, nil, self.cancelSource:CreateToken())
  if ret then
    self.uiBinder.input_field.text = ""
    self.chatMainData_:SetChatDraft({msg = ""}, channelId, E.ChatWindow.Main)
    self:refreshInputState()
  end
end

function Main_chat_pcView:refreshKeyCodeDesc()
  self:refreshMailNum()
  self:refreshFriendMsgNum()
  self.inputKeyDescComp_:Init(102, self.uiBinder.node_key)
end

function Main_chat_pcView:refreshMailNum()
  local newMailCount = self.mailData_:GetNewMailCount()
  if self.mainUIData_.MainUIPCShowMail and 0 < newMailCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_system, true)
    local keyCodeDesc = self:getChatKeyCodeDesc()
    self.uiBinder.lab_system.text = Lang("MainChatPCMailNumTips", {val = newMailCount, keyCode = keyCodeDesc})
    self:updateShowChatView()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_system, false)
  end
end

function Main_chat_pcView:refreshFriendMsgNum()
  if self.mainUIData_.MainUIPCShowFriendMessage then
    local chatMsgCount = self.chatMainData_:GetPrivateChatUnReadCount(true)
    if chatMsgCount <= 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_friend, false)
      return
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_friend, true)
    local keyCodeDesc = self:getChatKeyCodeDesc()
    self.uiBinder.lab_friend.text = Lang("MainChatPCFriendMsgNumTips", {val = chatMsgCount, keyCode = keyCodeDesc})
    self:refreshMessageNum(chatMsgCount)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_friend, false)
  end
end

function Main_chat_pcView:getChatKeyCodeDesc()
  local keyVM = Z.VMMgr.GetVM("setting_key")
  local keyCodeDesc = keyVM.GetKeyCodeDescListByKeyId(102)[1]
  return keyCodeDesc
end

function Main_chat_pcView:updateMainUIMainChat()
  self:updateShowChatView()
  self:updateActiveState()
  self:refreshViewInfo()
end

function Main_chat_pcView:updateShowChatView()
  if not self.mainUIData_:GetIsShowMainChat() then
    return
  end
  if not self.chatMainData_.ActiveMainChatInput and not self.mainUIData_.MainUIPCShowMail then
    return
  end
  self:showView()
  self:startCheckMainUIHide()
end

function Main_chat_pcView:updateActiveState()
  if self.chatMainData_.ActiveMainChatInput then
    self.uiBinder.canvas_channel.alpha = 1
    self.uiBinder.canvas_input.alpha = 1
    Z.UIMgr:AddShowMouseView("main_chat_pc")
  else
    self.uiBinder.canvas_channel.alpha = 0.5
    self.uiBinder.canvas_input.alpha = 0.5
    Z.UIMgr:RemoveShowMouseView("main_chat_pc")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_input, not self.chatMainData_.ActiveMainChatInput)
end

function Main_chat_pcView:refreshInputState()
  if self:refreshBanState() then
    return
  end
  if self:refreshCDState() then
    return
  end
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.uiBinder.lab_cd.text = ""
  self.uiBinder.lab_input.text = Lang("MainPCPleaseEnterChatContent")
  self.uiBinder.input_field.interactable = true
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_input, not self.chatMainData_.ActiveMainChatInput)
  if self.chatMainData_.ActiveMainChatInput then
    self.uiBinder.input_field:ActivateInputField()
  end
end

function Main_chat_pcView:refreshBanState()
  local banTime = self.chatMainData_:GetBanTime()
  if banTime <= 0 then
    return
  end
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  self.timer_ = self.timerMgr:StartTimer(function()
    local banTime = self.chatMainData_:GetBanTime()
    if banTime <= 0 then
      self:refreshInputState()
    else
      self:refreshBanLab(banTime)
    end
  end, 1, banTime)
  self:refreshBanLab(banTime)
  return true
end

function Main_chat_pcView:refreshBanLab(banTime)
  self.uiBinder.lab_cd.text = Lang("chat_block", {time = banTime})
  self.uiBinder.lab_input.text = ""
  self.uiBinder.input_field.interactable = false
end

function Main_chat_pcView:refreshCDState()
  local channelId = self.chatMainData_:GetMainChatInputChannel()
  local cdTime = self.chatMainData_:GetChatCD(channelId)
  if not cdTime or cdTime <= 0 then
    return
  end
  if self.timer_ then
    self.timerMgr:StopTimer(self.timer_)
    self.timer_ = nil
  end
  local tmpTime = cdTime
  self.timer_ = self.timerMgr:StartTimer(function()
    tmpTime = tmpTime - 1
    self.chatMainData_:SetChatCD(channelId, tmpTime)
    if tmpTime <= 0 then
      self:refreshInputState()
    else
      self:refreshCDLab(tmpTime)
    end
  end, 1, cdTime)
  self:refreshCDLab(tmpTime)
  return true
end

function Main_chat_pcView:refreshCDLab(tmpTime)
  self.uiBinder.lab_cd.text = Lang("MainPCInputCDTips", {val = tmpTime})
  self.uiBinder.lab_input.text = ""
  self.uiBinder.input_field.interactable = false
end

function Main_chat_pcView:changeActiveState(isActive)
  if isActive == self.chatMainData_.ActiveMainChatInput then
    return
  end
  self.chatMainData_.ActiveMainChatInput = isActive
  if isActive then
    self.refreshMainChatChannelList_ = true
    self.uiBinder.input_field.interactable = true
    self.uiBinder.input_field:ActivateInputField()
  else
    self.refreshMainChatChannelList_ = false
    self.uiBinder.input_field:DeactivateInputField(true)
    self.uiBinder.input_field.interactable = false
  end
  self:refreshShowHideState()
  self:updateActiveState()
end

function Main_chat_pcView:refreshShowHideState()
  if self.chatMainData_.ActiveMainChatInput or self.isShowList_ then
    self:showView()
    self:stopCheckMainUIHide()
  else
    self:startCheckMainUIHide()
  end
end

function Main_chat_pcView:hideView()
  self.uiBinder.do_tween:DoCanvasGroup(0, 0.1)
end

function Main_chat_pcView:showView()
  self.uiBinder.do_tween:DoCanvasGroup(1, 0.1)
end

return Main_chat_pcView
