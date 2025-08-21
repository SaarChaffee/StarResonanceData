local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_main_subView = class("Friends_main_subView", super)
local loopListView = require("ui.component.loop_list_view")
local friends_dropdown_tips_tpl = "ui/prefabs/friends/friends_dropdown_tips_tpl"
local friend_frame_item = require("ui.component.friends.friend_frame_item")
local friend_chat_item = require("ui.component.friends.friend_chat_item")
local friends_message_subView = require("ui.view.friends_message_sub_view")
local friends_apply_subView = require("ui/view/friends_apply_sub_view")
local friends_manage_subView = require("ui/view/friends_manage_sub_view")
local friends_group_subView = require("ui/view/friends_group_sub_view")
local friends_setting_subView = require("ui/view/friends_setting_sub_view")
local friends_add_subView = require("ui/view/friends_add_sub_view")
local functionBtnTipsMinHeight = 120

function Friends_main_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_main_sub", "friends/friends_main_sub", UI.ECacheLv.None)
end

function Friends_main_subView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initData()
  self:initFunc()
  self:initRed()
  self:BindEvents()
  self:startAnimatedShow()
  self:updateSearchNodeState(false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_function_tips, false)
  self:refreshViewType()
  self:refreshFriendNewMessage()
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.chatMainVm_ then
      return
    end
    self.chatMainVm_.AsyncUpdatePrivateChatCharInfo(true, self.cancelSource)
    self:RefreshChatPrivateChatList()
  end)()
end

function Friends_main_subView:clearTogData()
  self.uiBinder.tog_important.group = nil
  self.uiBinder.tog_normal.group = nil
  self.uiBinder.tog_important:RemoveAllListeners()
  self.uiBinder.tog_normal:RemoveAllListeners()
  self.uiBinder.tog_important.isOn = false
  self.uiBinder.tog_normal.isOn = false
end

function Friends_main_subView:initData()
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_list)
  self.loopList_:SetGetItemClassFunc(function(data)
    if self.isChatList_ then
      return friend_chat_item
    else
      return friend_frame_item
    end
  end)
  self.loopList_:SetGetPrefabNameFunc(function(data)
    if self.isChatList_ then
      return "friend_head_list_tpl"
    else
      return "friend_play_frame_tpl"
    end
  end)
  self.loopList_:Init({})
  self.friendsMessageSubView_ = friends_message_subView.new()
  self.friendsApplySubView_ = friends_apply_subView.new()
  self.friendsManageSubView_ = friends_manage_subView.new()
  self.friendsGroupSubView_ = friends_group_subView.new()
  self.friendsSettingSubView_ = friends_setting_subView.new()
  self.friendsAddSubView_ = friends_add_subView.new()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.chatRightSubViewLsit_ = {}
  self.friendsRightSubViewLsit_ = {}
  self.selfFuncBtnTipsCharId_ = 0
  self.isInitFuncBtnTips_ = false
  self.isSearching_ = false
  self.chatList_ = {}
  self.uiBinder.tog_important.isOn = false
  self.uiBinder.tog_normal.isOn = false
  self.uiBinder.tog_important.group = self.uiBinder.togs_tab
  self.uiBinder.tog_normal.group = self.uiBinder.togs_tab
  self.friendMainData_:SetFriendViewOpen(true)
end

function Friends_main_subView:initFunc()
  self.uiBinder.input_search:AddListener(function(searchContext)
    if searchContext == "" then
      self:refreshAsyncEmptySearch()
    end
  end)
  self.uiBinder.input_search:AddSubmitListener(function(searchContext)
    if searchContext == "" then
      self.isSearching = false
      self:refreshAsyncEmptySearch()
    else
      self.isSearching_ = true
      self:refreshAsyncStringSearch(searchContext)
    end
  end)
  self:AddClick(self.uiBinder.btn_apply, function()
    self:ShowNodeRightSubView(E.FriendFunctionViewType.ApplyFriend)
  end)
  self.uiBinder.tog_important:AddListener(function(isOn)
    if isOn then
      self.chatMainData_:SortPrivateChatList()
      self.friendMainData_:SetFriendViewType(E.FriendViewType.Chat)
      self.isSearching_ = false
      self:clickChatAnimatedShow()
      self.uiBinder.input_search.text = ""
      self:refreshChat()
      self:onClickChatRed()
    end
  end)
  self.uiBinder.tog_normal:AddListener(function(isOn)
    if isOn then
      self.friendMainData_:SetFriendViewType(E.FriendViewType.Friend)
      self.isSearching_ = false
      self:clickAddressBookAnimatedShow()
      self.uiBinder.input_search.text = ""
      self:checkFriendBaseDataCache()
      self:refreshAddressBook()
      self:onClickAddressRed()
    end
  end)
  self:AddClick(self.uiBinder.btn_return, function()
    Z.VMMgr.GetVM("socialcontact_main").CloseSocialContactView()
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    local viewData = {}
    viewData.refreshShow = true
    self:ShowNodeRightSubView(E.FriendFunctionViewType.AddFriend, viewData)
  end)
  self:AddClick(self.uiBinder.btn_degree, function()
    Z.UIMgr:OpenView("friend_degree_window")
  end)
  self:AddClick(self.uiBinder.btn_group, function()
    self:ShowNodeRightSubView(E.FriendFunctionViewType.GroupManagement)
  end)
  self:AddClick(self.uiBinder.btn_open_search, function()
    self:updateSearchNodeState(true)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self:updateSearchNodeState(false)
    self.uiBinder.input_search.text = ""
    if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
      self:refreshChat()
    else
      self:refreshAddressBook()
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
end

function Friends_main_subView:OnDeActive()
  if self.friendsMessageSubView_ then
    self.friendsMessageSubView_:DeActive()
  end
  if self.friendsApplySubView_ then
    self.friendsApplySubView_:DeActive()
  end
  if self.friendsManageSubView_ then
    self.friendsManageSubView_:DeActive()
  end
  if self.friendsGroupSubView_ then
    self.friendsGroupSubView_:DeActive()
  end
  if self.friendsSettingSubView_ then
    self.friendsSettingSubView_:DeActive()
  end
  if self.friendsAddSubView_ then
    self.friendsAddSubView_:DeActive()
  end
  self:UnBindEvents()
  self:clearRed()
  self:clearTogData()
  self.loopList_:UnInit()
  self.friendMainData_:SetFriendViewOpen(false)
  self.friendMainData_:SetIsShowFriendChat(false)
  Z.Voice.StopPlayback()
end

function Friends_main_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshChatPrivateChatList, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendRefresh, self.RefreshFriendsData, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendBlackGroupRefresh, self.RefreshBlackGroup, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendOpenFuncSubView, self.ShowNodeRightSubView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendCloseFuncSubView, self.closeNodeRightSubView, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplicationInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.BubbleMsg, self.OnRefreshChatMsg, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.refreshOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.NewPrivateChatMsg, self.onReceiveNewPrivateChatMsg, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.RefreshFriendBaseDataCache, self.onFriendBaseDataRefresh, self)
end

function Friends_main_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshChatPrivateChatList, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendRefresh, self.RefreshFriendsData, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendBlackGroupRefresh, self.RefreshBlackGroup, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendOpenFuncSubView, self.ShowNodeRightSubView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendCloseFuncSubView, self.closeNodeRightSubView, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendApplicationRefresh, self.refreshApplicationInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.BubbleMsg, self.OnRefreshChatMsg, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.refreshOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.NewPrivateChatMsg, self.onReceiveNewPrivateChatMsg, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.RefreshFriendBaseDataCache, self.onFriendBaseDataRefresh, self)
end

function Friends_main_subView:refreshViewType()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    self.uiBinder.tog_important.isOn = true
  else
    self.uiBinder.tog_normal.isOn = true
  end
end

function Friends_main_subView:initRed()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FriendChatTab, self, self.uiBinder.node_red_import)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.FriendAddressTab, self, self.uiBinder.node_red_normal)
end

function Friends_main_subView:onClickChatRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FriendChatTab)
end

function Friends_main_subView:onClickAddressRed()
  Z.RedPointMgr.OnClickRedDot(E.RedType.FriendAddressTab)
end

function Friends_main_subView:clearRed()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FriendChatTab)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.FriendAddressTab)
end

function Friends_main_subView:getPrivateChatCharIdIndex(charId, chatList)
  if 0 < charId and 0 < #chatList then
    for i = 1, #chatList do
      if chatList[i].charId == charId then
        return i
      end
    end
  end
  return 0
end

function Friends_main_subView:updateSearchNodeState(isShowSearchInput)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_item, not isShowSearchInput)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, isShowSearchInput)
  if isShowSearchInput then
    self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_3)
  end
end

function Friends_main_subView:refreshChat()
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_apply_frame, false)
  self.uiBinder.loop_list_ref:SetOffsetMax(0, -190)
  self:RefreshChatPrivateChatList()
end

function Friends_main_subView:refreshChatList(chatList, isSearch)
  if self.friendMainData_:GetFriendViewType() ~= E.FriendViewType.Chat then
    return
  end
  self.loopList_:ClearAllSelect()
  self.chatMainData_:GetPrivateSelectId()
  local chatSelectCharId = self.friendMainData_:GetChatSelectCharId()
  self.chatList_ = chatList
  self.isChatList_ = true
  self.loopList_:RefreshListView(chatList, false)
  local selectIndex = self:getPrivateChatCharIdIndex(chatSelectCharId, chatList)
  if 0 < selectIndex then
    self.loopList_:SetSelected(selectIndex)
    self.loopList_:MovePanelToItemIndex(selectIndex)
  elseif isSearch == false then
    self:ShowRightNodeByCacheList()
  end
end

function Friends_main_subView:RefreshChatPrivateChatList()
  if self.isSearching_ then
    self:refreshAsyncStringSearch(self.uiBinder.input_search.text)
  else
    local chatList = self.chatMainData_:GetPrivateChatList()
    self:refreshChatList(chatList, false)
  end
end

function Friends_main_subView:OnRefreshChatMsg(chatMsgData)
  if self.friendMainData_:GetFriendViewType() ~= E.FriendViewType.Chat then
    return
  end
  if Z.ChatMsgHelper.GetChannelId(chatMsgData) ~= E.ChatChannelType.EChannelPrivate then
    return
  end
  if table.zcount(self.chatList_) == 0 then
    return
  end
  local targetCharId = chatMsgData:GetCharId()
  local selectIndex = self:getPrivateChatCharIdIndex(targetCharId, self.chatList_)
  self.loopList_:UpDateByIndex(selectIndex, self.chatList_[selectIndex])
end

function Friends_main_subView:getSelectCharIndexInChatList(charId, chatList)
  local selcetIndex = -1
  if 0 < charId and 0 < #chatList then
    for i = 1, #chatList do
      if chatList[i].charId == charId then
        selcetIndex = i - 1
        break
      end
    end
  end
  return selcetIndex
end

function Friends_main_subView:refreshOpenPrivateChat(charId)
  self.uiBinder.tog_important.isOn = true
  self:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, {CharId = charId}, true)
end

function Friends_main_subView:refreshFriendNewMessage()
  local mainUIData = Z.DataMgr.Get("mainui_data")
  mainUIData.MainUIPCShowFriendMessage = false
end

function Friends_main_subView:onReceiveNewPrivateChatMsg()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    self:RefreshChatPrivateChatList()
  else
    self:checkNewMessageRed()
  end
end

function Friends_main_subView:checkNewMessageRed()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    return
  end
  if self.curRightViewType_ ~= E.FriendFunctionViewType.SendMessage then
    return
  end
  local charId = self.friendMainData_:GetAddressSelectCharId()
  if charId == 0 then
    return
  end
  local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(charId)
  if not privateChat then
    return
  end
  local maxRead = privateChat.maxReadMsgId or 0
  if not privateChat.latestMsg or maxRead >= privateChat.latestMsg.msgId then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local isSuccess = self.chatMainVm_.AsyncSetPrivateChatHasRead(privateChat.charId, privateChat.latestMsg.msgId, self.cancelSource:CreateToken())
    if isSuccess then
      Z.RedPointMgr.UpdateNodeCount(E.RedType.FriendChatTab, self.chatMainData_:GetPrivateChatUnReadCount(), true)
    end
  end)()
end

function Friends_main_subView:refreshAddressBook()
  self:refreshApplicationInfo()
  self.friendsMainVm_.UpdateGroupShowList()
  self.isChatList_ = false
  self.loopList_:RefreshListView(self.friendMainData_.AllList, false)
  local leftSelect = self.friendMainData_:GetAddressSelectCharId()
  if leftSelect == Z.ContainerMgr.CharSerialize.charId then
    local viewData = {}
    viewData.IsNeedReturn = false
    viewData.CharId = leftSelect
    self:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, viewData, true)
    self.loopList_:ClearAllSelect()
  elseif leftSelect ~= 0 then
    local index = self:getFriendIndexInList(self.friendMainData_.AllList, leftSelect)
    if index ~= 0 then
      self.loopList_:SetSelected(index)
      self.loopList_:MovePanelToItemIndex(index)
    else
      self.friendMainData_:SetAddressSelectCharId(0)
      self:refreshNodeRightSubView(E.FriendFunctionViewType.None)
      self.loopList_:ClearAllSelect()
    end
  else
    self:ShowRightNodeByCacheList()
    self.loopList_:ClearAllSelect()
  end
end

function Friends_main_subView:checkFriendBaseDataCache()
  if self.friendMainData_.IsCache then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncGetFriendBaseData()
  end)()
end

function Friends_main_subView:onFriendBaseDataRefresh()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    return
  end
  self:refreshAddressBook()
end

function Friends_main_subView:getFriendIndexInList(list, charId)
  if list == nil or table.zcount(list) == 0 then
    return 0
  end
  for i = 1, table.zcount(list) do
    if false == list[i]:GetIsGroup() and charId == list[i]:GetCharId() then
      return i
    end
  end
  return 0
end

function Friends_main_subView:refreshApplicationInfo()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    return
  end
  local applicationList = self.friendMainData_:GetApplicationList()
  local count = table.zcount(applicationList)
  if count == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_apply_frame, false)
    self.uiBinder.loop_list_ref:SetOffsetMax(0, -190)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_apply_frame, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_red, true)
    self.uiBinder.loop_list_ref:SetOffsetMax(0, -256)
    self.uiBinder.lab_num.text = tostring(count)
  end
end

function Friends_main_subView:refreshAsyncEmptySearch()
  self.isSearching_ = false
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    self:refreshChatList(self.chatMainData_:GetPrivateChatList(), false)
  else
    self:refreshAyncFriendList(self.friendMainData_.AllList)
  end
end

function Friends_main_subView:refreshAsyncStringSearch(searchContext)
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    local list = self.chatMainVm_.GetSearchDataList(searchContext)
    self:refreshChatList(list, true)
  else
    local list = self.friendsMainVm_.GetSearchDataList(searchContext)
    self:refreshAyncFriendList(list)
  end
end

function Friends_main_subView:refreshAyncFriendList(list)
  self.loopList_:RefreshListView(list, false)
  local index = 0
  for k, friendData in pairs(list) do
    if friendData:GetIsGroup() == false and friendData:GetCharId() == self.friendMainData_:GetAddressSelectCharId() then
      index = k
      break
    end
  end
  if index == 0 then
    self.loopList_:ClearAllSelect()
  else
    self.loopList_:SetSelected(index)
    self.loopList_:MovePanelToItemIndex(index)
  end
end

function Friends_main_subView:RefreshFriendsData()
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Friend then
    self.friendsMainVm_.UpdateGroupShowList()
  end
  if self.isSearching_ then
    self:refreshAsyncStringSearch(self.uiBinder.input_search.text)
  else
    self:refreshAsyncEmptySearch()
  end
end

function Friends_main_subView:RefreshBlackGroup()
  if self.friendMainData_:GetFriendViewType() ~= E.FriendViewType.Friend then
    return
  end
  if self.isSearching_ then
    return
  end
  for i = 1, #self.friendMainData_.AllList do
    if self.friendMainData_.AllList[i]:GetIsGroup() == true and self.friendMainData_.AllList[i]:GetGroupId() == E.FriendGroupType.Shield then
      self.loopList_:RefreshDataByIndex(i, self.friendMainData_.AllList[i])
      break
    end
  end
end

function Friends_main_subView:clearRightViewList()
  if self.friendViewType_ == E.FriendViewType.Chat then
    self.chatRightSubViewLsit_ = {}
  else
    self.friendsRightSubViewLsit_ = {}
  end
end

function Friends_main_subView:ShowRightNodeByCacheList()
  local rightList = self.friendMainData_:GetRightSubViewList()
  if table.zcount(rightList) > 0 then
    local showType = rightList[table.zcount(rightList)].showType
    local viewData = rightList[table.zcount(rightList)].viewData
    self:refreshNodeRightSubView(showType, viewData)
  else
    self:refreshNodeRightSubView(E.FriendFunctionViewType.None)
  end
end

function Friends_main_subView:ShowNodeRightSubView(type, viewData, clearRightSubView)
  if true == clearRightSubView then
    self.friendMainData_:ClearRightSubViewList()
  end
  if type == E.FriendFunctionViewType.AddFriend or type == E.FriendFunctionViewType.GroupManagement or type == E.FriendFunctionViewType.ApplyFriend then
    self:removeCacheRightSubView(type)
  end
  local rightList = self.friendMainData_:GetRightSubViewList()
  local rightViewCacheData = {}
  rightViewCacheData.showType = type
  rightViewCacheData.viewData = viewData
  table.insert(rightList, rightViewCacheData)
  self:refreshNodeRightSubView(type, viewData)
end

function Friends_main_subView:closeNodeRightSubView(type)
  local rightList = self.friendMainData_:GetRightSubViewList()
  if table.zcount(rightList) > 0 then
    local showType = rightList[table.zcount(rightList)].showType
    if showType == type then
      table.remove(rightList, table.zcount(rightList))
    else
      return
    end
  end
  if table.zcount(rightList) > 0 then
    local showType = rightList[table.zcount(rightList)].showType
    local viewData = rightList[table.zcount(rightList)].viewData
    self:refreshNodeRightSubView(showType, viewData)
  else
    self:refreshNodeRightSubView(E.FriendFunctionViewType.None)
  end
end

function Friends_main_subView:removeCacheRightSubView(type)
  local rightList = self.friendMainData_:GetRightSubViewList()
  local count = table.zcount(rightList)
  if 0 < count then
    for i = count, 1, -1 do
      if rightList[i].showType == type then
        table.remove(rightList, i)
      end
    end
  end
end

function Friends_main_subView:refreshNodeRightSubView(type, viewData)
  self.curRightViewType_ = type
  self.friendMainData_:SetIsShowFriendChat(type == E.FriendFunctionViewType.SendMessage)
  self:hideNodeRightSubView(type)
  if type == E.FriendFunctionViewType.None then
    self.uiBinder.Ref:SetVisible(self.uiBinder.cont_empty, true)
  elseif type == E.FriendFunctionViewType.ApplyFriend then
    self.friendsApplySubView_:Active(viewData, self.uiBinder.node_right)
    self.friendsApplySubView_:SetVisible(true)
  elseif type == E.FriendFunctionViewType.SetFriend then
    if viewData then
      viewData.parentView = self
    end
    self.friendsSettingSubView_:Active(viewData, self.uiBinder.node_right)
    self.friendsSettingSubView_:SetVisible(true)
  elseif type == E.FriendFunctionViewType.SendMessage then
    if viewData then
      viewData.parentView = self
    end
    if self.friendsMessageSubView_.IsActive and self.friendsMessageSubView_.IsLoaded then
      self.friendsMessageSubView_:SetViewData(viewData)
      self.friendsMessageSubView_:OnRefresh()
    else
      self.friendsMessageSubView_:Active(viewData, self.uiBinder.node_right, self.uiBinder)
    end
    self.friendsMessageSubView_:SetVisible(true)
  elseif type == E.FriendFunctionViewType.AddFriend then
    self.friendsAddSubView_:Active(viewData, self.uiBinder.node_right)
    self.friendsAddSubView_:SetVisible(true)
  elseif type == E.FriendFunctionViewType.FriendManagement then
    self.friendsManageSubView_:Active(viewData, self.uiBinder.node_right)
    self.friendsManageSubView_:SetVisible(true)
  elseif type == E.FriendFunctionViewType.GroupManagement then
    self.friendsGroupSubView_:Active(viewData, self.uiBinder.node_right)
    self.friendsGroupSubView_:SetVisible(true)
  end
  if type ~= E.FriendFunctionViewType.SendMessage then
    self.friendsMessageSubView_:DeActive()
  end
  self:checkNewMessageRed()
end

function Friends_main_subView:hideNodeRightSubView(type)
  self.uiBinder.Ref:SetVisible(self.uiBinder.cont_empty, type == E.FriendFunctionViewType.None)
  if self.friendsApplySubView_ and type ~= E.FriendFunctionViewType.ApplyFriend then
    self.friendsApplySubView_:SetVisible(false)
  end
  if self.friendsSettingSubView_ and type ~= E.FriendFunctionViewType.SetFriend then
    self.friendsSettingSubView_:SetVisible(false)
  end
  if self.friendsMessageSubView_ and type ~= E.FriendFunctionViewType.SendMessage then
    self.friendsMessageSubView_:SetVisible(false)
  end
  if self.friendsAddSubView_ and type ~= E.FriendFunctionViewType.AddFriend then
    self.friendsAddSubView_:SetVisible(false)
  end
  if self.friendsManageSubView_ and type ~= E.FriendFunctionViewType.FriendManagement then
    self.friendsManageSubView_:SetVisible(false)
  end
  if self.friendsGroupSubView_ and type ~= E.FriendFunctionViewType.GroupManagement then
    self.friendsGroupSubView_:SetVisible(false)
  end
end

function Friends_main_subView:initFunctionBtnTips()
  if self.isInitFuncBtnTips_ then
    return
  end
  self.isInitFuncBtnTips_ = true
  local func = function()
    local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(self.selfFuncBtnTipsCharId_)
    if privateChat.isTop == true then
      return
    end
    local isOk = self.chatMainVm_.AsyncSetPrivateChatTop(self.selfFuncBtnTipsCharId_, true, self.cancelSource:CreateToken())
    if isOk then
      self.chatMainVm_.PrivateChatListSort(self.chatMainData_:GetPrivateChatList())
      self:refreshChat()
    end
    self:closeBtnTips()
  end
  self.functionTipsBtnSetTop_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.ChatSetTop, self.uiBinder.node_function_content, func)
  local func = function()
    local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(self.selfFuncBtnTipsCharId_)
    if privateChat.isTop == false then
      return
    end
    local isOk = self.chatMainVm_.AsyncSetPrivateChatTop(self.selfFuncBtnTipsCharId_, false, self.cancelSource:CreateToken())
    if isOk then
      self.chatMainVm_.PrivateChatListSort(self.chatMainData_:GetPrivateChatList())
      self:refreshChat()
    end
    self:closeBtnTips()
  end
  self.functionTipsBtnCancelTop_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.ChatCancelTop, self.uiBinder.node_function_content, func)
  local func = function()
    self.friendsMainVm_.AsyncSetRemind(self.selfFuncBtnTipsCharId_, true, self.cancelSource:CreateToken())
    self:closeBtnTips()
  end
  self.functionTipsBtnSetRemind_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.OpenMessageTip, self.uiBinder.node_function_content, func)
  local func = function()
    self.friendsMainVm_.AsyncSetRemind(self.selfFuncBtnTipsCharId_, false, self.cancelSource:CreateToken())
    self:closeBtnTips()
  end
  self.functionTipsBtnCancelRemind_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.CancelMessageTip, self.uiBinder.node_function_content, func)
  local func = function()
    self.friendsMainVm_.DeleteFriend({
      self.selfFuncBtnTipsCharId_
    }, self.cancelSource:CreateToken())
    self:closeBtnTips()
  end
  self.functionTipsBtnDelFriend_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.DelFriend, self.uiBinder.node_function_content, func)
  local func = function()
    local isOk = self.chatMainVm_.AsyncDeletePrivateChat(self.selfFuncBtnTipsCharId_, self.cancelSource:CreateToken())
    if isOk then
      self:refreshChat()
    end
    self:closeBtnTips()
  end
  self.functionTipsBtnDelChat_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.DelChat, self.uiBinder.node_function_content, func)
  local func = function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendAddBlackTipsContent"), function()
      local ret = self.chatMainVm_.AsyncSetBlack(self.selfFuncBtnTipsCharId_, true, self.cancelSource)
      if ret then
        Z.TipsVM.ShowTipsLang(130104)
      end
    end)
    self:closeBtnTips()
  end
  self.functionTipsBtnSetBlack_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.SetBlack, self.uiBinder.node_function_content, func)
  local func = function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendRemoveBlackTipsContent"), function()
      local ret = self.chatMainVm_.AsyncSetBlack(self.selfFuncBtnTipsCharId_, false, self.cancelSource)
      if ret then
        Z.TipsVM.ShowTipsLang(130105)
      end
    end)
    self:closeBtnTips()
  end
  self.functionTipsBtnCancelBlack_ = self:asyncAddFriendFunctionBtnByType(E.FriendFunctionBtnType.CancelBlack, self.uiBinder.node_function_content, func)
  self:EventAddAsyncListener(self.uiBinder.presscheck_pointpress.ContainGoEvent, function(isContain)
    if not isContain then
      self:closeBtnTips()
    end
  end, nil, nil)
end

function Friends_main_subView:asyncAddFriendFunctionBtnByType(type, addNode, func)
  local config = Z.TableMgr.GetTable("FunctionTableMgr").GetRow(type)
  if config and config.OnOff == 0 then
    local unit = self:AsyncLoadUiUnit(friends_dropdown_tips_tpl, "friends_dropdown_tips_tpl" .. type, addNode)
    if type == E.FriendFunctionBtnType.DelChat then
      unit.lab_name.text = Z.RichTextHelper.ApplyStyleTag(config.Name, E.TextStyleTag.EmphRb)
    else
      unit.lab_name.text = config.Name
    end
    self:AddAsyncClick(unit.btn_click, func)
    unit.Ref:SetVisible(unit.img_line, type ~= E.FriendFunctionBtnType.SetBlack and type ~= E.FriendFunctionBtnType.CancelBlack)
    return unit
  end
end

function Friends_main_subView:AsyncShowBtnFunctionTips(charId, position, isFriendChat, isFriend)
  if not charId then
    return
  end
  self.selfFuncBtnTipsCharId_ = charId
  self:initFunctionBtnTips()
  self:checkTopBtnShow(isFriendChat)
  self:checkRemindBtnShow()
  self:checkDelBtnShow(isFriendChat, isFriend)
  self:checkBlackBtnShow()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_function_tips, true)
  self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_4)
  self.uiBinder.node_function_tips.position = position
  if self.uiBinder.node_function_tips.anchoredPosition.y < functionBtnTipsMinHeight then
    self.uiBinder.node_function_tips:SetAnchorPosition(self.uiBinder.node_function_tips.anchoredPosition.x, functionBtnTipsMinHeight)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.presscheck_pointpress_ref, true)
  self.uiBinder.presscheck_pointpress:StartCheck()
end

function Friends_main_subView:checkTopBtnShow(isFriendChat)
  if self.functionTipsBtnSetTop_ then
    self.functionTipsBtnSetTop_.Ref:SetVisible(self.functionTipsBtnSetTop_.friends_tips_item, false)
  end
  if self.functionTipsBtnCancelTop_ then
    self.functionTipsBtnCancelTop_.Ref:SetVisible(self.functionTipsBtnCancelTop_.friends_tips_item, false)
  end
  if not isFriendChat then
    return
  end
  local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(self.selfFuncBtnTipsCharId_)
  if privateChat then
    if privateChat.isTop == false then
      if self.functionTipsBtnSetTop_ then
        self.functionTipsBtnSetTop_.Ref:SetVisible(self.functionTipsBtnSetTop_.friends_tips_item, true)
      end
    elseif self.functionTipsBtnCancelTop_ then
      self.functionTipsBtnCancelTop_.Ref:SetVisible(self.functionTipsBtnCancelTop_.friends_tips_item, true)
    end
  end
end

function Friends_main_subView:checkRemindBtnShow()
  if self.functionTipsBtnSetRemind_ then
    self.functionTipsBtnSetRemind_.Ref:SetVisible(self.functionTipsBtnSetRemind_.friends_tips_item, false)
  end
  if self.functionTipsBtnCancelRemind_ then
    self.functionTipsBtnCancelRemind_.Ref:SetVisible(self.functionTipsBtnCancelRemind_.friends_tips_item, false)
  end
  if self.friendMainData_:IsFriendByCharId(self.selfFuncBtnTipsCharId_) then
    local friendData = self.friendMainData_:GetFriendDataByCharId(self.selfFuncBtnTipsCharId_)
    if friendData and friendData:GetIsRemind() == false then
      if self.functionTipsBtnSetRemind_ then
        self.functionTipsBtnSetRemind_.Ref:SetVisible(self.functionTipsBtnSetRemind_.friends_tips_item, true)
      end
    elseif self.functionTipsBtnCancelRemind_ then
      self.functionTipsBtnCancelRemind_.Ref:SetVisible(self.functionTipsBtnCancelRemind_.friends_tips_item, true)
    end
  end
end

function Friends_main_subView:checkDelBtnShow(isFriendChat, isFriend)
  if isFriendChat then
    if self.functionTipsBtnDelChat_ then
      self.functionTipsBtnDelChat_.Ref:SetVisible(self.functionTipsBtnDelChat_.friends_tips_item, true)
    end
    if self.functionTipsBtnDelFriend_ then
      self.functionTipsBtnDelFriend_.Ref:SetVisible(self.functionTipsBtnDelFriend_.friends_tips_item, false)
    end
  else
    if self.functionTipsBtnDelChat_ then
      self.functionTipsBtnDelChat_.Ref:SetVisible(self.functionTipsBtnDelChat_.friends_tips_item, false)
    end
    if self.functionTipsBtnDelFriend_ then
      self.functionTipsBtnDelFriend_.Ref:SetVisible(self.functionTipsBtnDelFriend_.friends_tips_item, isFriend)
    end
  end
end

function Friends_main_subView:checkBlackBtnShow()
  if self.functionTipsBtnSetBlack_ then
    self.functionTipsBtnSetBlack_.Ref:SetVisible(self.functionTipsBtnSetBlack_.friends_tips_item, false)
  end
  if self.functionTipsBtnCancelBlack_ then
    self.functionTipsBtnCancelBlack_.Ref:SetVisible(self.functionTipsBtnCancelBlack_.friends_tips_item, false)
  end
  if self.chatMainData_:IsInBlack(self.selfFuncBtnTipsCharId_) == false then
    if self.functionTipsBtnSetBlack_ then
      self.functionTipsBtnSetBlack_.Ref:SetVisible(self.functionTipsBtnSetBlack_.friends_tips_item, true)
    end
  elseif self.functionTipsBtnCancelBlack_ then
    self.functionTipsBtnCancelBlack_.Ref:SetVisible(self.functionTipsBtnCancelBlack_.friends_tips_item, true)
  end
end

function Friends_main_subView:clickChatAnimatedShow()
  self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_1)
end

function Friends_main_subView:clickAddressBookAnimatedShow()
  self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_2)
end

function Friends_main_subView:closeBtnTips()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_function_tips, false)
  self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_5)
  self.uiBinder.Ref:SetVisible(self.uiBinder.presscheck_pointpress_ref, false)
  self.uiBinder.presscheck_pointpress:StopCheck()
end

function Friends_main_subView:startAnimatedShow()
  if self.viewData.isFirstOpen then
    self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Open)
    self.uiBinder.anim_friends:Restart(Z.DOTweenAnimType.Tween_0)
  end
end

return Friends_main_subView
