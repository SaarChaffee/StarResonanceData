local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_message_subView = class("Friends_message_subView", super)
local chat_input_box_view = require("ui.view.chat_input_box_view")
local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")
local SDKDefine = require("ui.model.sdk_define")
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
  self.socialVm_ = Z.VMMgr.GetVM("socialcontact_main")
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.curCharId_ = self.viewData.CharId
  self.chatMainData_:SetPrivateSelectId(self.curCharId_)
  self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  self.chatDialogueViewData_ = {
    parentView = self,
    windowType = E.ChatWindow.Main,
    channelId = E.ChatChannelType.EChannelPrivate,
    charId = self.curCharId_
  }
  self.chat_dialogue_tpl_view_:Active(self.chatDialogueViewData_, self.uiBinder.node_msg_parent, self.uiBinder)
  self.chat_input_box_view_ = chat_input_box_view.new()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqark, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, false)
end

function Friends_message_subView:onInitComp()
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
  end)
  self:AddClick(self.uiBinder.btn_mini, function()
    self.chatMainVm_.OpenMiniChat(E.ChatChannelType.EChannelPrivate, self.curCharId_, self.showName_, E.TextStyleTag.ChannelPrivate)
    self.socialVm_.CloseSocialContactView()
  end)
  self:AddClick(self.uiBinder.btn_wechatprivilege, function()
    self.sdkVM_.PrivilegeBtnClick(self.curCharId_)
  end)
  self:AddClick(self.uiBinder.btn_qqprivilege, function()
    self.sdkVM_.PrivilegeBtnClick()
  end)
  self:AddAsyncClick(self.uiBinder.btn_qqark, function()
    self.chatMainVm_.AsyncArkShareWithTencent(self.curCharId_, self.cancelSource:CreateToken())
  end)
  self:setInputBox(true)
  self:onEmojiViewShow(false)
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
  Z.EventMgr:Add(Z.ConstValue.Chat.PrivateChatRefresh, self.refreshPlayerInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.SocialDataUpdata, self.refreshPlayerInfo, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
end

function Friends_message_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendRefresh, self.refreshPlayerInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.PrivateChatRefresh, self.refreshPlayerInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.SocialDataUpdata, self.refreshPlayerInfo, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendLinessChange, self.refreshFriendLiness, self)
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
  self.inputViewData_.charId = self.curCharId_
  self.chat_input_box_view_:Active(self.inputViewData_, self.uiBinder.node_bottom_container, self.uiBinder)
  self.chatDialogueViewData_.charId = self.curCharId_
  self.chat_dialogue_tpl_view_:Active(self.chatDialogueViewData_, self.uiBinder.node_msg_parent, self.uiBinder)
  if self.chat_input_box_view_ then
    self.chat_input_box_view_:RefreshChatDraft(true)
  end
  if self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:RefreshMsgList(true)
  end
  self:refreshMessage()
end

function Friends_message_subView:refreshMessage()
  self:refreshReturnBtn()
  self:refreshPlayerInfo(true)
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
    self:refreshTitleInfo(showName, friendData:GetPlayerOffLineTime(), friendData:GetPlayerPersonalState(), friendData:GetSocialData())
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_else, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.group_remind, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_friend, true)
    local privateChat = self.chatMainData_:GetPrivateChatItemByCharId(self.curCharId_)
    if privateChat and privateChat.socialData and privateChat.socialData.basicData then
      self:refreshTitleInfo(privateChat.socialData.basicData.name, privateChat.socialData.basicData.offlineTime, nil, privateChat.socialData)
    end
  end
end

function Friends_message_subView:refreshTitleInfo(showName, offlineTime, personalState, socialData)
  self.showName_ = showName
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
    self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, persData.Res))
    self:refreshSDKState(persData, socialData)
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
    self.inputViewData_ = {
      parentView = self,
      windowType = E.ChatWindow.Main,
      channelId = E.ChatChannelType.EChannelPrivate,
      charId = self.curCharId_,
      showInputBg = false,
      isShowVoice = true,
      activeInputActions = true,
      onEmojiViewChange = function(isShow)
        self:onEmojiViewShow(isShow)
      end
    }
    self.chat_input_box_view_:Active(self.inputViewData_, self.uiBinder.node_bottom_container, self.uiBinder)
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

function Friends_message_subView:refreshSDKState(config, socialData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqark, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, false)
  if E.PersonalizationStatus.EStatusOutLine == config.Id then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqark, self:isShowQQServerArkShare())
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqark, false)
  end
  if socialData and socialData.privilegeData and socialData.privilegeData.isPrivilege then
    if socialData.privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege) then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqprivilege, true)
    elseif socialData.privilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin and self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege) then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatprivilege, true)
    end
  end
end

function Friends_message_subView:isShowQQServerArkShare()
  if not self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQArk) then
    return false
  end
  local friends = Z.DataMgr.Get("sdk_data").SDKFriends
  for _, data in ipairs(friends) do
    if data.roleInfos then
      for _, roleInfo in ipairs(data.roleInfos) do
        local charId = tonumber(roleInfo.charId)
        if charId and charId == self.curCharId_ then
          return true
        end
      end
    end
  end
  return false
end

return Friends_message_subView
