local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_main_sub_pcView = class("Friends_main_sub_pcView", super)
local loopListView = require("ui.component.loop_list_view")
local friendChatItemPC = require("ui.component.friends_pc.friend_chat_item_pc")
local friendDataItemPC = require("ui.component.friends_pc.friend_data_item_pc")
local friendGroupItemPC = require("ui.component.friends_pc.friend_group_item_pc")
local friendGroupNameItemPC = require("ui.component.friends_pc.friend_group_name_item_pc")

function Friends_main_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_main_sub_pc", "friends_pc/friends_main_sub_pc", UI.ECacheLv.None)
end

function Friends_main_sub_pcView:OnActive()
  self:initVMData()
  self:initFunc()
  self:onInitRed()
  self:refreshLeftLoopRef()
  self:showRightView(E.FriendMainPCRightViewType.Empty)
  self:RefreshViewData()
  self:BindEvents()
end

function Friends_main_sub_pcView:OnDeActive()
  self.loopList_:UnInit()
  self:clearTogFunction()
  self:clearRed()
  if self.curView_ then
    self.curView_:DeActive()
    self.curView_ = nil
  end
  if self.chat_input_box_tpl_pc_view_ then
    self.chat_input_box_tpl_pc_view_:DeActive()
    self.chat_input_box_tpl_pc_view_ = nil
  end
  self:UnBindEvents()
  Z.Voice.StopPlayback()
end

function Friends_main_sub_pcView:initVMData()
  local friends_message_sub_pc_view = require("ui.view.friends_message_sub_pc_view")
  self.friends_message_sub_pc_view_ = friends_message_sub_pc_view.new()
  local chat_input_box_tpl_pc_view = require("ui.view.chat_input_box_tpl_pc_view")
  self.chat_input_box_tpl_pc_view_ = chat_input_box_tpl_pc_view.new()
  local friends_apply_sub_pc_view = require("ui.view.friends_apply_sub_pc_view")
  self.friends_apply_sub_pc_view_ = friends_apply_sub_pc_view.new()
  self.friendMainVM_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.showFriendApply_ = false
  self.showGroup_ = false
  self.showChatInput_ = false
end

function Friends_main_sub_pcView:initFunc()
  self.uiBinder.tog_chat.isOn = false
  self.uiBinder.tog_friend.isOn = false
  self.uiBinder.tog_chat.group = self.uiBinder.togs_friend
  self.uiBinder.tog_friend.group = self.uiBinder.togs_friend
  self.uiBinder.tog_chat:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.friendMainData_:SetFriendViewType(E.FriendViewType.Chat)
    self.chatMainData_:SortPrivateChatList()
    self:ShowChatData()
    self:onClickChatRed()
  end)
  self.uiBinder.tog_friend:AddListener(function(isOn)
    if not isOn then
      return
    end
    self.friendMainData_:SetFriendViewType(E.FriendViewType.Friend)
    self:showFriendData()
    self:onClickAddressRed()
  end)
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_list)
  self.loopList_:SetGetItemClassFunc(function(data)
    if data.loopItemType == E.FriendLoopItemType.EPrivateChat then
      return friendChatItemPC
    elseif data.loopItemType == E.FriendLoopItemType.EFriendGroup then
      return friendGroupItemPC
    elseif data.loopItemType == E.FriendLoopItemType.EFriendGroupName then
      return friendGroupNameItemPC
    else
      return friendDataItemPC
    end
  end)
  self.loopList_:SetGetPrefabNameFunc(function(data)
    if data.loopItemType == E.FriendLoopItemType.EPrivateChat then
      return "friend_chat_tpl_pc"
    elseif data.loopItemType == E.FriendLoopItemType.EFriendGroup then
      return "friend_group_tpl_pc"
    elseif data.loopItemType == E.FriendLoopItemType.EFriendGroupName then
      return "friend_group_name_tpl_pc"
    else
      return "friend_item_tpl_pc"
    end
  end)
  self.loopList_:Init({})
  self.isSearching_ = false
  self.uiBinder.input_search.text = ""
  self.uiBinder.input_search:AddListener(function(searchContext)
    if searchContext ~= "" then
      return
    end
    self.isSearching_ = false
    self:refreshAsyncEmptySearch()
  end)
  self.uiBinder.input_search:AddSubmitListener(function(searchContext)
    if searchContext == "" then
      self.isSearching_ = false
      self:refreshAsyncEmptySearch()
    else
      self.isSearching_ = true
      self:refreshAsyncStringSearch(searchContext)
    end
  end)
  self:AddClick(self.uiBinder.btn_search, function()
    if self.uiBinder.input_search.text == "" then
      Z.TipsVM.ShowTips(100004)
    else
      self.isSearching_ = true
      self:refreshAsyncStringSearch(self.uiBinder.input_search.text)
    end
  end)
  self:AddClick(self.uiBinder.btn_close_search, function()
    self.uiBinder.input_search.text = ""
    self.isSearching_ = false
    self:refreshAsyncEmptySearch()
  end)
  self:AddClick(self.uiBinder.btn_add_friend, function()
    Z.UIMgr:OpenView("friends_add_popup")
  end)
  self:AddClick(self.uiBinder.btn_apply, function()
    self:showRightView(E.FriendMainPCRightViewType.FriendApply)
  end)
  self:AddClick(self.uiBinder.btn_group_set, function()
    self:changeGroupList(not self.showGroupList_)
  end)
  self:AddClick(self.uiBinder.btn_group_create, function()
    self:createGroup()
  end)
  self:AddClick(self.uiBinder.btn_group_change, function()
    self:changeGroupName()
  end)
  self:AddClick(self.uiBinder.btn_group_delete, function()
    self:deleteGroup()
  end)
  self:AddClick(self.uiBinder.btn_friendship, function()
    Z.UIMgr:OpenView("friend_degree_window")
  end)
  self:EventAddAsyncListener(self.uiBinder.press_check.ContainGoEvent, function(isContainer)
    if not isContainer then
      self:changeGroupList(false)
    end
  end, nil, nil)
end

function Friends_main_sub_pcView:clearTogFunction()
  self.uiBinder.tog_chat.group = nil
  self.uiBinder.tog_friend.group = nil
  self.uiBinder.tog_chat:RemoveAllListeners()
  self.uiBinder.tog_friend:RemoveAllListeners()
  self.uiBinder.tog_chat.isOn = false
  self.uiBinder.tog_friend.isOn = false
end

function Friends_main_sub_pcView:RefreshViewData()
  local friendViewType = self.friendMainData_:GetFriendViewType()
  if friendViewType == E.FriendViewType.Chat then
    self.uiBinder.tog_chat.isOn = true
  else
    self.uiBinder.tog_friend.isOn = true
  end
end

function Friends_main_sub_pcView:onInitRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FriendChatTab, self, self.uiBinder.node_red_chat)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FriendAddressTab, self, self.uiBinder.node_red_address)
end

function Friends_main_sub_pcView:onClickChatRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FriendChatTab)
end

function Friends_main_sub_pcView:onClickAddressRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FriendAddressTab)
end

function Friends_main_sub_pcView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FriendChatTab)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FriendAddressTab)
end

function Friends_main_sub_pcView:initFriendsMessage(viewData)
  self.friends_message_sub_pc_view_:Active(viewData, self.uiBinder.node_right, self.uiBinder)
end

function Friends_main_sub_pcView:showChatInput(charId)
  if not self.chatInputViewData_ then
    self.chatInputViewData_ = {
      parentView = self,
      windowType = E.ChatWindow.Main,
      channelId = E.ChatChannelType.EChannelPrivate,
      charId = charId,
      isShowVoice = true
    }
  else
    self.chatInputViewData_.charId = charId
  end
  self.chat_input_box_tpl_pc_view_:Active(self.chatInputViewData_, self.uiBinder.node_chat_input, self.uiBinder)
  self.showChatInput_ = true
  self:refreshLeftLoopRef()
end

function Friends_main_sub_pcView:hideChatInput()
  self.chat_input_box_tpl_pc_view_:DeActive()
  self.showChatInput_ = false
  self:refreshLeftLoopRef()
end

function Friends_main_sub_pcView:showRightView(rightType, viewData)
  if self.curRightViewType_ == rightType then
    return
  end
  if self.curView_ then
    self.curView_:DeActive()
    self.curView_ = nil
  end
  self.curRightViewType_ = rightType
  if rightType == E.FriendMainPCRightViewType.Empty then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, false)
    self:hideChatInput()
  elseif rightType == E.FriendMainPCRightViewType.Message then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
    self:initFriendsMessage(viewData)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
    self.curView_ = self.friends_message_sub_pc_view_
  elseif rightType == E.FriendMainPCRightViewType.FriendApply then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_new, false)
    self:initFriendApply()
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_right, true)
    self:hideChatInput()
    self.curView_ = self.friends_apply_sub_pc_view_
  end
end

function Friends_main_sub_pcView:refreshLeftLoopRef()
  local leftBottom = self.showChatInput_ and 80 or 0
  self.uiBinder.node_left_ref:SetOffsetMin(0, leftBottom)
  local top = self.showFriendApply_ and -72 or -46
  local bottom = self.showGroup_ and 80 or 0
  self.uiBinder.loop_list_ref:SetOffsetMin(0, bottom)
  self.uiBinder.loop_list_ref:SetOffsetMax(0, top)
end

function Friends_main_sub_pcView:showPrivateChat()
  self.uiBinder.tog_chat.isOn = true
  self:RefreshView()
end

function Friends_main_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendRefresh, self.RefreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendBlackGroupRefresh, self.RefreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshFriendApplyNode, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.showPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.BubbleMsg, self.RefreshView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.ChatSelfSendNewMessage, self.refreshSelfSendNewMsg, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.ChatPrivateNewMessage, self.refreshPrivateSendNewMsg, self)
end

function Friends_main_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendRefresh, self.RefreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendBlackGroupRefresh, self.RefreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshFriendApplyNode, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.showPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.BubbleMsg, self.RefreshView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.ChatSelfSendNewMessage, self.refreshSelfSendNewMsg, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.ChatPrivateNewMessage, self.refreshPrivateSendNewMsg, self)
end

function Friends_main_sub_pcView:RefreshView()
  if self.isSearching_ then
    self:refreshAsyncStringSearch(self.uiBinder.input_search.text)
  else
    self:refreshAsyncEmptySearch()
  end
end

function Friends_main_sub_pcView:refreshSelfSendNewMsg(targetCharId)
  local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(targetCharId)
  if not privateChat then
    return
  end
  privateChat.maxReadMsgId = privateChat.latestMsg.msgId
  Z.CoroUtil.create_coro_xpcall(function()
    self.chatMainVM_.AsyncSetPrivateChatHasRead(targetCharId, privateChat.latestMsg.msgId, self.cancelSource:CreateToken())
  end)()
end

function Friends_main_sub_pcView:refreshPrivateSendNewMsg(targetCharId)
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Friend then
    return
  end
  if targetCharId == self.chatMainData_:GetPrivateSelectId() then
    local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(targetCharId)
    if privateChat then
      privateChat.maxReadMsgId = privateChat.latestMsg.msgId
      Z.CoroUtil.create_coro_xpcall(function()
        self.chatMainVM_.AsyncSetPrivateChatHasRead(targetCharId, privateChat.latestMsg.msgId, self.cancelSource:CreateToken())
      end)()
    end
  end
  if self.isSearching_ then
    local list = self.chatMainVM_.GetSearchDataList(self.uiBinder.input_search.text)
    self.loopList_:RefreshListView(list, false)
  else
    self.loopList_:RefreshListView(self.chatMainData_:GetPrivateChatList(), false)
  end
end

function Friends_main_sub_pcView:refreshAsyncEmptySearch()
  self.isSearching_ = false
  local friendViewType = self.friendMainData_:GetFriendViewType()
  if friendViewType == E.FriendViewType.Chat then
    self:ShowChatData()
  else
    self:showFriendData()
  end
end

function Friends_main_sub_pcView:refreshAsyncStringSearch(searchContext)
  local friendViewType = self.friendMainData_:GetFriendViewType()
  if friendViewType == E.FriendViewType.Chat then
    local list = self.chatMainVM_.GetSearchDataList(searchContext)
    self:refreshChatList(list)
  else
    local list = self.friendMainVM_.GetSearchDataList(searchContext)
    self:refreshFriendList(list)
  end
end

function Friends_main_sub_pcView:ShowChatData()
  self:refreshFriendApplyNode()
  self:refreshGroupNode(false)
  local chatList = self.chatMainData_:GetPrivateChatList()
  self:refreshChatList(chatList)
end

function Friends_main_sub_pcView:refreshChatList(chatList)
  self.loopList_:ClearAllSelect()
  self.loopList_:RefreshListView(chatList, false)
  local chatSelectCharId = self.friendMainData_:GetChatSelectCharId()
  local selectIndex = self:getPrivateChatCharIdIndex(chatSelectCharId, chatList)
  if 0 < selectIndex then
    self.loopList_:SetSelected(selectIndex)
    self.loopList_:MovePanelToItemIndex(selectIndex)
  else
    self.loopList_:ClearAllSelect()
    self:showRightView(E.FriendMainPCRightViewType.Empty)
  end
end

function Friends_main_sub_pcView:getPrivateChatCharIdIndex(charId, chatList)
  if not charId or not chatList then
    return 0
  end
  if 0 < charId and 0 < #chatList then
    for i = 1, #chatList do
      if chatList[i].charId == charId then
        return i
      end
    end
  end
  return 0
end

function Friends_main_sub_pcView:OnSelectChatItemPC(data)
  local messageViewData = {parentView = self, privateChatItem = data}
  self:showRightView(E.FriendMainPCRightViewType.Message, messageViewData)
  self.friends_message_sub_pc_view_.viewData = messageViewData
  self.friends_message_sub_pc_view_:RefreshViewData()
  self:showChatInput(data.charId)
end

function Friends_main_sub_pcView:showFriendData()
  self:refreshFriendApplyNode()
  self:showFriendList()
  self:refreshGroupNode(true)
  self:hideChatInput()
end

function Friends_main_sub_pcView:refreshFriendApplyNode()
  local friendViewType = self.friendMainData_:GetFriendViewType()
  if friendViewType == E.FriendViewType.Chat then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_apply, false)
    self.showFriendApply_ = false
  else
    local applicationList = self.friendMainData_:GetApplicationList()
    local count = table.zcount(applicationList)
    if count == 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_apply, false)
      self.showFriendApply_ = false
      if self.curRightViewType_ == E.FriendMainPCRightViewType.FriendApply then
        self:showRightView(E.FriendMainPCRightViewType.Empty)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_apply, true)
      self.uiBinder.lab_apply.text = count
      self.showFriendApply_ = true
    end
  end
  self:refreshLeftLoopRef()
end

function Friends_main_sub_pcView:initFriendApply()
  self.friends_apply_sub_pc_view_:Active({}, self.uiBinder.node_right)
end

function Friends_main_sub_pcView:showFriendList()
  local friendList = self.friendMainData_:GetFriendPCListData()
  self:refreshFriendList(friendList)
end

function Friends_main_sub_pcView:OnSelectFriendGroup(groupIdList, isSelect, isDefault)
  if isSelect and not isDefault then
    self.curFriendGroupId_ = groupIdList
    self.uiBinder.btn_group_set.IsDisabled = false
    self.uiBinder.btn_group_set.interactable = true
  else
    self.curFriendGroupId_ = nil
    self.uiBinder.btn_group_set.IsDisabled = true
    self.uiBinder.btn_group_set.interactable = false
  end
end

function Friends_main_sub_pcView:OnSelectFriend(data)
  local messageViewData = {parentView = self, friendData = data}
  self.friendMainData_:SetAddressSelectCharId(data:GetCharId())
  self:showRightView(E.FriendMainPCRightViewType.Message, messageViewData)
  self.friends_message_sub_pc_view_.viewData = messageViewData
  self.friends_message_sub_pc_view_:RefreshViewData()
end

function Friends_main_sub_pcView:refreshFriendList(list)
  self.loopList_:RefreshListView(list, false)
  if not self.isSearching_ then
    local seletCharId = self.friendMainData_:GetAddressSelectCharId()
    local index = self:getFriendItemCharIdIndex(seletCharId, list)
    if 0 < index then
      self.loopList_:SetSelected(index)
      return
    end
  else
    self.loopList_:ClearAllSelect()
  end
  if self.curRightViewType_ == E.FriendMainPCRightViewType.Message then
    self:showRightView(E.FriendMainPCRightViewType.Empty)
  end
end

function Friends_main_sub_pcView:getFriendItemCharIdIndex(charId, chatList)
  if not charId or not chatList then
    return 0
  end
  if 0 < charId and 0 < #chatList then
    for i = 1, #chatList do
      if chatList[i].friendData and chatList[i].friendData:GetCharId() == charId then
        return i
      end
    end
  end
  return 0
end

function Friends_main_sub_pcView:refreshGroupNode(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group, isShow)
  self.showGroup_ = isShow
  self:changeGroupList(false)
  self:refreshLeftLoopRef()
end

function Friends_main_sub_pcView:changeGroupList(isShow)
  self.showGroupList_ = isShow
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_group_list, self.showGroupList_)
  if isShow then
    self.uiBinder.press_check:StartCheck()
  else
    self.uiBinder.press_check:StopCheck()
  end
end

function Friends_main_sub_pcView:createGroup()
  local data = {
    title = Lang("FriendCreateGroup"),
    inputContent = Lang("FriendCreateGroupDefaultName"),
    onConfirm = function(name)
      if self.isCreating_ == true then
        return
      end
      self.isCreating_ = true
      local errCode = self.friendMainVM_.AsyncCreateGroup(name, self.cancelSource:CreateToken())
      if errCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
        self.isCreating_ = false
        return
      end
      self:showFriendList()
      self.isCreating_ = false
    end,
    onCancel = function()
      self.isCreating_ = false
    end,
    stringLengthLimitNum = Z.Global.PlayerNameLimit,
    inputDesc = Lang("FriendGroupName")
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Friends_main_sub_pcView:changeGroupName()
  local data = {
    title = Lang("FriendChangeGroupName"),
    inputContent = self.friendMainData_:GetGroupName(self.curFriendGroupId_),
    onConfirm = function(name)
      local errCode = self.friendMainVM_.AsyncChangeGroupName(self.curFriendGroupId_, name, self.cancelSource:CreateToken())
      if errCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
        return
      end
      self:showFriendList()
    end,
    stringLengthLimitNum = Z.Global.PlayerNameLimit,
    inputDesc = Lang("FriendGroupName")
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Friends_main_sub_pcView:deleteGroup()
  if not self.curFriendGroupId_ then
    return
  end
  local friendList = self.friendMainData_:GetGroupAndFriendData(self.curFriendGroupId_)
  if table.zcount(friendList) <= 0 then
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendMainVM_.AsyncDelectGroup(self.curFriendGroupId_, self.cancelSource:CreateToken())
    end)()
  else
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("delectFriendGroup"), function()
      local errCode = self.friendMainVM_.AsyncDelectGroup(self.curFriendGroupId_, self.cancelSource:CreateToken())
      if errCode == 0 then
        self:showFriendList()
      end
    end)
  end
end

return Friends_main_sub_pcView
