local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_message_sub_pcView = class("Friends_message_sub_pcView", super)

function Friends_message_sub_pcView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.ctor(self, "friends_message_sub_pc", "friends_pc/friends_message_sub_pc", UI.ECacheLv.None)
end

function Friends_message_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initVMData()
  self:initFunc()
  self:refreshNodeList(false)
  self:refreshFriendNewMessage()
  self:BindEvents()
end

function Friends_message_sub_pcView:OnDeActive()
  self:UnBindEvents()
  if self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
  end
  if self.friends_tag_sub_pc_view_ then
    self.friends_tag_sub_pc_view_:DeActive()
  end
  self.chatMainData_:SetPrivateSelectId(0)
end

function Friends_message_sub_pcView:OnRefresh()
  self:RefreshViewData()
end

function Friends_message_sub_pcView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendRefresh, self.RefreshViewData, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.SocialDataUpdata, self.RefreshViewData, self)
  Z.EventMgr:Add(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshViewData, self)
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
end

function Friends_message_sub_pcView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendRefresh, self.RefreshViewData, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.SocialDataUpdata, self.RefreshViewData, self)
  Z.EventMgr:Remove(Z.ConstValue.Chat.PrivateChatRefresh, self.RefreshViewData, self)
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendNewMessage, self.refreshFriendNewMessage, self)
end

function Friends_message_sub_pcView:initVMData()
  self.friendMainVM_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVM_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.socialVM_ = Z.VMMgr.GetVM("socialcontact_main")
end

function Friends_message_sub_pcView:refreshDialogue()
  if self.friends_tag_sub_pc_view_ then
    self.friends_tag_sub_pc_view_:DeActive()
  end
  if not self.chat_dialogue_tpl_view_ then
    local chat_dialogue_tpl_view = require("ui.view.chat_dialogue_tpl_view")
    self.chat_dialogue_tpl_view_ = chat_dialogue_tpl_view.new()
  end
  if not self.chatDialogueViewData_ then
    self.chatDialogueViewData_ = {
      parentView = self,
      windowType = E.ChatWindow.Main,
      channelId = E.ChatChannelType.EChannelPrivate,
      charId = self.charId_
    }
  else
    self.chatDialogueViewData_.charId = self.charId_
  end
  self.chat_dialogue_tpl_view_:Active(self.chatDialogueViewData_, self.uiBinder.node_content, self.uiBinder)
end

function Friends_message_sub_pcView:refreshTagSub()
  if self.chat_dialogue_tpl_view_ then
    self.chat_dialogue_tpl_view_:DeActive()
  end
  if not self.friends_tag_sub_pc_view_ then
    local friends_tag_sub_pc_view = require("ui.view.friends_tag_sub_pc_view")
    self.friends_tag_sub_pc_view_ = friends_tag_sub_pc_view.new()
  end
  self.friends_tag_sub_pc_view_:Active({
    charId = self.charId_
  }, self.uiBinder.node_content)
end

function Friends_message_sub_pcView:refreshNodeList(isShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_btn_list, isShow)
  if isShow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set_top, not self.isTop_ and not self.isFriendData_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel_top, self.isTop_ and not self.isFriendData_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_remark, self.isFriend_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_set_group, self.isFriend_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_confirm_reminder, self.isFriend_ and not self.isRemind_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_cancel_reminder, self.isFriend_ and self.isRemind_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add_black, not self.isInBlack_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_remove_black, self.isInBlack_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete_friend, self.isFriend_)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete_chat, not self.isFriendData_)
    self.uiBinder.press_check:StartCheck()
  else
    self.uiBinder.press_check:StopCheck()
  end
end

function Friends_message_sub_pcView:RefreshViewData()
  if not self.IsActive or not self.IsLoaded then
    return
  end
  if self.viewData.friendData then
    self.charId_ = self.viewData.friendData:GetCharId()
    self.isFriend_ = self.friendMainData_:IsFriendByCharId(self.charId_)
    self.charName_ = self.viewData.friendData:GetPlayerName()
    if self.viewData.friendData:GetRemark() and self.viewData.friendData:GetRemark() ~= "" then
      self.charName_ = string.zconcat(self.viewData.friendData:GetRemark(), "(", self.viewData.friendData:GetPlayerName(), ")")
    end
    self.offlineTime_ = self.viewData.friendData:GetPlayerOffLineTime()
    self.isTop_ = self.viewData.friendData:GetIsTop()
    self.isRemind_ = self.viewData.friendData:GetIsRemind()
    self.groupId_ = self.viewData.friendData:GetGroupId()
    self.state_ = self.viewData.friendData:GetPlayerPersonalState()
    self.isFriendData_ = true
    self:refreshTagSub()
  elseif self.viewData.privateChatItem then
    self.charId_ = self.viewData.privateChatItem.charId
    self.isFriend_ = self.friendMainData_:IsFriendByCharId(self.charId_)
    if self.viewData.privateChatItem.socialData and self.viewData.privateChatItem.socialData.basicData then
      self.charName_ = self.viewData.privateChatItem.socialData.basicData.name
      self.offlineTime_ = self.viewData.privateChatItem.socialData.basicData.offlineTime
    else
      self.charName_ = ""
      self.offlineTime_ = 0
    end
    self.isRemind_ = false
    self.groupId_ = nil
    self.state_ = nil
    if self.isFriend_ then
      local friendData = self.friendMainData_:GetFriendDataByCharId(self.charId_)
      if friendData then
        self.isRemind_ = friendData:GetIsRemind()
        self.groupId_ = friendData:GetGroupId()
        self.state_ = friendData:GetPlayerPersonalState()
      end
    end
    self.isTop_ = self.viewData.privateChatItem.isTop
    self.isFriendData_ = false
    self:refreshDialogue()
    self.chatMainData_:SetPrivateSelectId(self.charId_)
  end
  self.isInBlack_ = self.chatMainData_:IsInBlack(self.charId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add_friend, not self.isFriend_ and not self.isInBlack_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.group_remind, self.isFriend_)
  self.uiBinder.lab_name.text = self.charName_
  self.uiBinder.tog_remind:SetIsOnWithoutCallBack(self.isRemind_)
  self:refreshTitleInfo()
  self:refreshFriendLiness()
end

function Friends_message_sub_pcView:refreshFriendNewMessage()
  local mainUIData = Z.DataMgr.Get("mainui_data")
  mainUIData.MainUIPCShowFriendMessage = false
end

function Friends_message_sub_pcView:initFunc()
  self:AddAsyncClick(self.uiBinder.btn_set_top, function()
    self:asyncChangeFriendMessageTop(true)
    self:refreshNodeList(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel_top, function()
    self:asyncChangeFriendMessageTop(false)
    self:refreshNodeList(false)
  end)
  self:AddClick(self.uiBinder.btn_remark, function()
    self:changeRemark()
    self:refreshNodeList(false)
  end)
  self:AddClick(self.uiBinder.btn_set_group, function()
    Z.UIMgr:OpenView("friends_group_popup", {
      charId = self.charId_,
      groupId = self.groupId_
    })
    self:refreshNodeList(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_confirm_reminder, function()
    self.friendMainVM_.AsyncSetRemind(self.charId_, true, self.cancelSource:CreateToken())
    self:refreshNodeList(false)
  end)
  self:AddAsyncClick(self.uiBinder.btn_cancel_reminder, function()
    self.friendMainVM_.AsyncSetRemind(self.charId_, false, self.cancelSource:CreateToken())
    self:refreshNodeList(false)
  end)
  self:AddClick(self.uiBinder.btn_add_black, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendAddBlackTipsContent"), function()
      local ret = self.chatMainVM_.AsyncSetBlack(self.charId_, true, self.friendMainData_.CancelSource)
      if ret then
        Z.TipsVM.ShowTipsLang(130104)
      end
    end)
  end)
  self:AddClick(self.uiBinder.btn_remove_black, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendRemoveBlackTipsContent"), function()
      local ret = self.chatMainVM_.AsyncSetBlack(self.charId_, false, self.friendMainData_.CancelSource)
      if ret then
        Z.TipsVM.ShowTipsLang(130105)
      end
    end)
  end)
  self:AddAsyncClick(self.uiBinder.btn_delete_friend, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendDelFriendTips"), function()
      self:refreshNodeList(false)
      self.friendMainVM_.DeleteFriend({
        self.charId_
      }, self.friendMainData_.CancelSource:CreateToken())
    end)
  end)
  self:AddClick(self.uiBinder.btn_option_list, function()
    self:refreshNodeList(true)
  end)
  self:AddAsyncClick(self.uiBinder.btn_add_friend, function()
    self.friendMainVM_.AsyncSendAddFriend(self.charId_, E.FriendAddSource.EPrivateChat, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_mini, function()
    self.chatMainVM_.CheckPrivateChatCharId(self.charId_)
    self.chatMainVM_.OpenMiniChat(E.ChatChannelType.EChannelPrivate, self.charId_, self.charName_, E.TextStyleTag.ChannelPrivate)
    self.socialVM_.CloseSocialContactView()
  end)
  self:AddAsyncClick(self.uiBinder.tog_remind, function()
    self.friendMainVM_.AsyncSetRemind(self.charId_, not self.isRemind_, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.btn_friend_degree, function()
    Z.UIMgr:OpenView("friend_degree_popup", {
      charId = self.charId_
    })
  end)
  self:AddAsyncClick(self.uiBinder.btn_delete_chat, function()
    local isOk = self.chatMainVM_.AsyncDeletePrivateChat(self.charId_, self.cancelSource:CreateToken())
    if isOk then
      self:refreshNodeList(false)
      self.viewData.parentView:ShowChatData()
    end
  end)
  self:EventAddAsyncListener(self.uiBinder.press_check.ContainGoEvent, function(isContain)
    if not isContain then
      self:refreshNodeList(false)
    end
  end, nil, nil)
end

function Friends_message_sub_pcView:asyncChangeFriendMessageTop(setTop)
  if self.isTop_ == setTop then
    return
  end
  local isOk = self.chatMainVM_.AsyncSetPrivateChatTop(self.charId_, setTop, self.cancelSource:CreateToken())
  if isOk then
    self.chatMainVM_.PrivateChatListSort(self.chatMainData_:GetPrivateChatList())
    self.viewData.parentView:ShowChatData()
  end
end

function Friends_message_sub_pcView:changeRemark()
  local friendData = self.friendMainData_:GetFriendDataByCharId(self.charId_)
  if not friendData then
    return
  end
  local defaultName = friendData:GetRemark()
  if defaultName == nil or defaultName == "" then
    defaultName = friendData:GetPlayerName()
  end
  local data = {
    title = Lang("ModifyRemarks"),
    inputContent = defaultName,
    onConfirm = function(name)
      local errCode = self.friendMainVM_.SetFriendRemarks(self.charId_, name, self.cancelSource:CreateToken())
      if errCode == 0 then
        friendData:SetRemark(name)
        local uuid = Z.EntityMgr:GetUuid(Z.PbEnum("EEntityType", "EntChar"), self.charId_)
        self.friendMainVM_.CheckFriendRemark(uuid)
      else
        return errCode
      end
    end,
    stringLengthLimitNum = Z.Global.PlayerNameLimit,
    inputDesc = Lang("FriendInputRemarkName"),
    isCanInputEmpty = true
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Friends_message_sub_pcView:refreshTitleInfo()
  local persData
  if self.state_ then
    persData = self.friendMainVM_.GetFriendsStatus(self.offlineTime_, self.state_)
  else
    local chatStatusTableMgr = Z.TableMgr.GetTable("ChatStatusTableMgr")
    if self.offlineTime_ == 0 then
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOnline)
    else
      persData = chatStatusTableMgr.GetRow(E.PersonalizationStatus.EStatusOutLine)
    end
  end
  if persData then
    self.uiBinder.lab_state.text = persData.StatusName
    self.uiBinder.img_state:SetImage(string.zconcat(Z.ConstValue.Friend.FriendIconPath, persData.Res))
  end
end

function Friends_message_sub_pcView:refreshFriendLiness()
  Z.CoroUtil.create_coro_xpcall(function()
    if self.friendMainData_:IsFriendByCharId(self.charId_) then
      local linessData = self.friendMainData_:GetFriendLinessData(self.charId_)
      if not linessData then
        self.friendMainVM_.UpdateFriendliness(self.charId_, self.cancelSource:CreateToken())
        linessData = self.friendMainData_:GetFriendLinessData(self.charId_)
      end
      if linessData then
        local param = {
          val = linessData.friendLinessLevel
        }
        self.uiBinder.lab_degree_level.text = Lang("Grade", param)
        self.uiBinder.Ref:SetVisible(self.uiBinder.group_degree, true)
      else
        self.uiBinder.Ref:SetVisible(self.uiBinder.group_degree, false)
      end
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.group_degree, false)
    end
  end)()
end

return Friends_message_sub_pcView
