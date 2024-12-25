local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_setting_subView = class("Friends_setting_subView", super)
local playerProtraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")

function Friends_setting_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_setting_sub", "friends/friends_setting_sub", UI.ECacheLv.None)
end

function Friends_setting_subView:OnActive()
  self:onInitData()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
end

function Friends_setting_subView:OnDeActive()
end

function Friends_setting_subView:onInitData()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainVm_ = Z.VMMgr.GetVM("chat_main")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.SetFriend)
  end)
  self:AddClick(self.uiBinder.btn_delete, function()
    self:onDelFriends()
  end)
  self:AddClick(self.uiBinder.btn_changegroup, function()
    local viewData = {}
    viewData.IsNeedReturn = false
    viewData.CharId = self.curCharId_
    self.friendsMainVm_.OpenSetView(E.FriendFunctionViewType.FriendManagement, viewData)
  end)
  self:AddClick(self.uiBinder.btn_inputname, function()
    local limitNum = Z.Global.PlayerNameLimit
    local defaultName = self.selectData_:GetRemark()
    if defaultName == nil or defaultName == "" then
      defaultName = self.selectData_:GetPlayerName()
    end
    local data = {
      title = Lang("ModifyRemarks"),
      inputContent = defaultName,
      onConfirm = function(name)
        local ret = self.friendsMainVm_.SetFriendRemarks(self.curCharId_, name, self.cancelSource:CreateToken())
        if ret.errorCode == 0 then
          self.selectData_:SetRemark(name)
          local uuid = Z.EntityMgr:GetUuid(Z.PbEnum("EEntityType", "EntChar"), self.curCharId_)
          self.friendsMainVm_.CheckFriendRemark(uuid)
          self:refreshFriendInfo()
        else
          return ret.errorCode
        end
      end,
      stringLengthLimitNum = Z.Global.PlayerNameLimit,
      inputDesc = Lang("FriendInputRemarkName"),
      isCanInputEmpty = true
    }
    Z.TipsVM.OpenCommonPopupInput(data)
  end)
  self.uiBinder.switch_messagetips:AddListener(function(IsOn)
    if IsOn == self.selectData_:GetIsRemind() then
      return
    end
    Z.CoroUtil.create_coro_xpcall(function()
      self.friendsMainVm_.AsyncSetRemind(self.curCharId_, IsOn, self.cancelSource:CreateToken())
    end)()
  end)
  self.uiBinder.switch_messagetop:AddListener(function(IsOn)
    Z.CoroUtil.create_coro_xpcall(function()
      local ret = self.chatMainVm_.AsyncSetPrivateChatTop(self.curCharId_, IsOn, self.cancelSource:CreateToken())
      if ret then
        self.chatMainVm_.PrivateChatListSort(self.chatMainData_:GetPrivateChatList())
        self.viewData.parentView:RefreshChatPrivateChatList()
      end
    end)()
  end)
  self:AddClick(self.uiBinder.btn_setblick, function()
    Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendAddBlackTipsContent"), function()
      local ret = self.chatMainVm_.AsyncSetBlack(self.curCharId_, true, self.cancelSource)
      if ret then
        self.uiBinder.switch_black.IsOn = true
        self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.SetFriend)
      end
      Z.DialogViewDataMgr:CloseDialogView()
    end)
  end)
end

function Friends_setting_subView:OnRefresh()
  if not self.viewData then
    return
  end
  self:refreshFriendInfo()
end

function Friends_setting_subView:refreshFriendInfo()
  self.curCharId_ = self.viewData.CharId
  if self.friendMainData_:IsFriendByCharId(self.curCharId_) == false then
    return
  end
  self.selectData_ = self.friendMainData_:GetFriendDataByCharId(self.curCharId_)
  if self.selectData_ == nil then
    return
  end
  self.uiBinder.switch_messagetips:SetIsOnWithoutNotify(self.selectData_:GetIsRemind())
  local privateChatItem = self.chatMainData_:GetPrivateChatItemByCharId(self.curCharId_)
  if privateChatItem then
    self.uiBinder.switch_messagetop:SetIsOnWithoutNotify(privateChatItem.isTop)
  end
  self.uiBinder.switch_black:SetIsOnWithoutNotify(self.selectData_:GetIsBlack())
  self.uiBinder.lab_chat_info.text = self.friendMainData_:GetGroupName(self.selectData_:GetGroupId())
  if self.selectData_:GetRemark() == "" then
    self.uiBinder.lab_play_name.text = self.selectData_:GetPlayerName()
  else
    self.uiBinder.lab_play_name.text = string.zconcat(self.selectData_:GetRemark(), "(", self.selectData_:GetPlayerName(), ")")
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_remark_info, true)
  self.uiBinder.lab_remark_info.text = self.selectData_:GetRemark()
  local persData = self.friendsMainVm_.GetFriendsStatus(self.selectData_:GetPlayerOffLineTime(), self.selectData_:GetPlayerPersonalState())
  if persData then
    self.uiBinder.lab_state.text = persData.StatusName
    self.uiBinder.img_con:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
  end
  playerProtraitMgr.InsertNewPortraitBySocialData(self.uiBinder.cont_play_head, self.selectData_:GetSocialData())
  if self.friendMainData_:GetFriendViewType() == E.FriendViewType.Chat then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_friends_messagetop, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_friends_messagetop, false)
  end
end

function Friends_setting_subView:onDelFriends()
  Z.DialogViewDataMgr:OpenNormalDialog(Lang("FriendDelFriendTips"), function()
    if self.curCharId_ > 0 then
      self.friendsMainVm_.DeleteFriend({
        self.curCharId_
      }, self.cancelSource:CreateToken())
    end
    self.friendMainData_:SetAddressSelectCharId(0)
    self.friendsMainVm_.OpenSetView(E.FriendFunctionViewType.None, {}, true)
    Z.DialogViewDataMgr:CloseDialogView()
  end)
end

return Friends_setting_subView
