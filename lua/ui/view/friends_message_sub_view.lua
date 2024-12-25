local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_message_subView = class("Friends_message_subView", super)
local chat_input_box_view = require("ui.view.chat_input_box_view")
local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")
local maskHeight = 340

function Friends_message_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_message_sub", "friends/friends_message_sub", UI.ECacheLv.None)
end

function Friends_message_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(776, 0)
  self:onInitData()
  self:onInitComp()
  self:refreshMessage()
  self:BindEvents()
end

function Friends_message_subView:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.chatMainData_:SetPrivateSelectId(self.viewData.CharId)
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  local chatDialogueViewData = {}
  chatDialogueViewData.parentView = self
  chatDialogueViewData.chatChannelId = E.ChatChannelType.EChannelPrivate
  chatDialogueViewData.windowType = E.ChatWindow.Main
  self.chat_dialogue_tpl_view_:Active(chatDialogueViewData, self.uiBinder.node_msg_parent, self.uiBinder)
  self.chat_input_box_view_ = chat_input_box_view.new()
  self:setInputBox(true)
end

function Friends_message_subView:onInitComp()
  self.curCharId_ = self.viewData.CharId
  self.chatMainVm_.CheckPrivateChatCharId(self.curCharId_)
  self:AddClick(self.uiBinder.btn_else, function()
    local viewData = {}
    viewData.IsNeedReturn = true
    viewData.CharId = self.curCharId_
    self.friendsMainVm_.OpenSetView(E.FriendFunctionViewType.SetFriend, viewData)
  end)
  self.uiBinder.tog_remind:AddListener(function(isOn)
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncSetRemind(self.curCharId_, isOn, self.cancelSource:CreateToken())
    end)()
  end)
  self:AddAsyncClick(self.uiBinder.btn_friend, function()
    self.friendsMainVm_.AsyncSendAddFriend(self.curCharId_, E.FriendAddSource.EPrivateChat, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_friend_degree, function()
    local viewData = {
      charId = self.curCharId_
    }
    Z.UIMgr:OpenView("friend_degree_popup", viewData)
  end)
end

function Friends_message_subView:OnDeActive()
  self:UnBindEvents()
  if self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
  end
  if self.chat_input_box_view_ then
    self.chat_input_box_view_:DeActive()
  end
  self:setInputBox(false)
  self.chatMainData_:SetPrivateSelectId(0)
end

function Friends_message_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendRefresh, self.refreshPlayerInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.PrivateChatRefresh, self.refreshPlayerInfo, self)
end

function Friends_message_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendRefresh, self.refreshPlayerInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.PrivateChatRefresh, self.refreshPlayerInfo, self)
end

function Friends_message_subView:OnRefresh()
  if self.curCharId_ and self.curCharId_ == self.viewData.CharId then
    return
  end
  self.curCharId_ = self.viewData.CharId
  if self.curCharId_ == nil or self.curCharId_ == Z.ContainerMgr.CharSerialize.charId then
    return
  end
  self.chatMainVm_.CheckPrivateChatCharId(self.curCharId_)
  self.chatMainData_:SetPrivateSelectId(self.curCharId_)
  if self.chat_input_box_view_ and self.chat_input_box_view_.IsActive and self.chat_input_box_view_.IsLoaded then
    self.chat_input_box_view_:RefreshChatDraft(true)
  end
  if self.chat_dialogue_tpl_view_ and self.chat_dialogue_tpl_view_.IsActive and self.chat_dialogue_tpl_view_.IsLoaded then
    self.chat_dialogue_tpl_view_:RefreshMsgList(true)
  end
  self:refreshMessage()
end

function Friends_message_subView:refreshMessage()
  self:refreshReturnBtn()
  self:refreshPlayerInfo()
  self:refreshFriendLiness()
  self:updatePrivateChatCharId()
end

function Friends_message_subView:refreshFriendLiness()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.friendsMainData_:IsFriendByCharId(self.curCharId_) then
      local linessData = self.friendsMainData_:GetFriendLinessData(self.curCharId_)
      if not linessData then
        self:asyncGetFriendLiness(self.curCharId_)
        linessData = self.friendsMainData_:GetFriendLinessData(self.curCharId_)
      end
      if linessData then
        local param = {
          val = linessData.friendLinessLevel
        }
        self.uiBinder.lab_grade.text = Lang("Grade", param)
        self.uiBinder.Ref:SetVisible(self.uiBinder.group_friend_degree, true)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.group_friend_degree, false)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_friend_degree, false)
    end
  end)()
end

function Friends_message_subView:asyncGetFriendLiness(charId)
  self.friendsMainVm_.UpdateFriendliness(charId, self.cancelSource:CreateToken())
end

function Friends_message_subView:updatePrivateChatCharId()
  if self.chatMainData_:GetNewPrivateChatMessageTipsCharId() ~= self.curCharId_ then
    self.chatMainData_:ClearNewPrivateChatMessageTipsCharId()
    self.chatMainData_:SetNewPrivateChatMessageTipsCharId(0)
  end
end

function Friends_message_subView:refreshReturnBtn()
  if self.viewData and true == self.viewData.IsNeedReturn then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_close, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_close, false)
  end
end

function Friends_message_subView:refreshPlayerInfo()
  local friendData = self.friendsMainData_:GetFriendDataByCharId(self.curCharId_)
  if self.friendsMainData_:IsFriendByCharId(self.curCharId_) and friendData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_else, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_remind, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_friend, false)
    self.uiBinder.tog_remind.isOn = friendData:GetIsRemind()
    local showName = friendData:GetPlayerName()
    if friendData:GetRemark() and friendData:GetRemark() ~= "" then
      showName = friendData:GetRemark() .. "(" .. friendData:GetPlayerName() .. ")"
    end
    self:refreshTitleInfo(showName, friendData:GetPlayerOffLineTime(), friendData:GetPlayerPersonalState())
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_else, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_remind, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_friend, true)
    local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(self.curCharId_)
    if privateChat and privateChat.socialData and privateChat.socialData.basicData then
      self:refreshTitleInfo(privateChat.socialData.basicData.name, privateChat.socialData.basicData.offlineTime)
    end
  end
end

function Friends_message_subView:refreshTitleInfo(showName, offlineTime, personalState)
  self.uiBinder.lab_title.text = showName
  local persData
  if personalState then
    persData = self.friendsMainVm_.GetFriendsStatus(offlineTime, personalState)
  else
    local chatStatusTableMgr = Z.TableMgr.GetTable("ChatStatusTableMgr")
    if offlineTime == 0 then
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOnline)
    else
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOutLine)
    end
  end
  if persData then
    self.uiBinder.lab_state.text = persData.StatusName
    self.uiBinder.img_state:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
  end
end

function Friends_message_subView:onEmojiViewShow(isShowEmoji)
  if isShowEmoji then
    self.uiBinder.node_msg_parent:SetOffsetMin(0, maskHeight)
  else
    self.uiBinder.node_msg_parent:SetOffsetMin(0, 0)
  end
  self:setInputBoxVisible(not isShowEmoji)
  self.chat_dialogue_tpl_view_:RefreshMsgList(true)
end

function Friends_message_subView:setInputBox(isShowInput)
  if isShowInput then
    local inputViewData = {}
    inputViewData.parentView = self
    inputViewData.windowType = E.ChatWindow.Main
    inputViewData.channelId = E.ChatChannelType.EChannelPrivate
    inputViewData.showInputBg = false
    inputViewData.isShowVoice = true
    
    function inputViewData.onEmojiViewChange(isShow)
      self:onEmojiViewShow(isShow)
    end
    
    self.chat_input_box_view_:Active(inputViewData, self.uiBinder.node_bottom_container, self.uiBinder)
  elseif self.chat_input_box_view_ then
    self.chat_input_box_view_:DeActive()
  end
end

function Friends_message_subView:setInputBoxVisible(isShowInput)
  if isShowInput then
    if self.chat_input_box_view_ then
      self.chat_input_box_view_:SetVisible(true)
      self.chat_input_box_view_:RefreshChatDraft(true)
    else
      self:setInputBox(true)
    end
  elseif self.chat_input_box_view_ then
    self.chat_input_box_view_:SetVisible(false)
  end
end

return Friends_message_subView
