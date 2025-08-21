local super = require("ui.component.loop_list_view_item")
local playerPortraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FriendFrameItem = class("FriendFrameItem", super)

function FriendFrameItem:OnInit()
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
  self.loopListViewItem.OnLongPressEvent:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local isFriend = not self.chatMainData_:IsInBlack(self.data_:GetCharId())
      self.parent.UIView:AsyncShowBtnFunctionTips(self.data_:GetCharId(), self.uiBinder.node_tips.position, false, isFriend)
    end)()
  end)
  self.uiBinder.img_bg:AddListener(function()
    Z.CoroUtil.create_coro_xpcall(function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_:GetCharId(), self.parent.UIView.cancelSource:CreateToken())
    end)()
  end)
end

function FriendFrameItem:OnRefresh(data)
  self.data_ = data
  if self.data_:GetIsGroup() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_head, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, false)
    self.uiBinder.lab_label.text = self.friendMainData_:GetGroupName(self.data_:GetGroupId())
    self:refreshArrow()
    self:refreshOnlineNum()
    self.uiBinder.Trans:SetHeight(70)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_head, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.IsSelected)
    self:refreshPlayerInfo()
    self.uiBinder.Trans:SetHeight(124)
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

function FriendFrameItem:OnSelected(isSelected, isClick)
  if self.data_:GetIsGroup() then
    if isClick then
      self:onSelectedGroup()
    end
  else
    self:onSelectedFriend(isSelected)
  end
end

function FriendFrameItem:onSelectedGroup()
  local isShow = self.data_:GetIsGroupShow()
  if isShow == 0 then
    self.data_:SetIsGroupShow(1)
  else
    self.data_:SetIsGroupShow(0)
  end
  self:refreshArrow()
  self.parent.UIView:RefreshFriendsData()
end

function FriendFrameItem:refreshArrow()
  local isShow = self.data_:GetIsGroupShow()
  if isShow == 0 then
    self.uiBinder.img_arrow:SetScale(1, 1, 1)
  else
    self.uiBinder.img_arrow:SetScale(1, -1, 1)
  end
end

function FriendFrameItem:refreshOnlineNum()
  local friendList = self.friendMainData_:GetGroupAndFriendData(self.data_:GetGroupId())
  local totalNum = table.zcount(friendList)
  local onLineNum = 0
  for _, friend in pairs(friendList) do
    if friend:GetPlayerOffLineTime() == 0 then
      onLineNum = onLineNum + 1
    end
  end
  self.uiBinder.lab_num.text = onLineNum .. "/" .. totalNum
end

function FriendFrameItem:onSelectedFriend(isSelected)
  self.data_:SetIsSelect(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, isSelected)
  if isSelected then
    if self.friendMainData_:GetAddressSelectCharId() == self.data_:GetCharId() then
      local rightList = self.friendMainData_:GetRightSubViewList()
      if table.zcount(rightList) > 0 then
        self.parent.UIView:ShowRightNodeByCacheList()
        return
      end
    end
    self.friendMainData_:SetAddressSelectCharId(self.data_:GetCharId())
    if self.chatMainData_:IsInBlack(self.data_:GetCharId()) then
      self.parent.UIView:ShowNodeRightSubView(E.FriendFunctionViewType.None, {}, true)
    else
      local viewData = {}
      viewData.IsNeedReturn = false
      viewData.CharId = self.data_:GetCharId()
      self.parent.UIView:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, viewData, true)
    end
    Z.CoroUtil.create_coro_xpcall(function()
      self:asyncInitInfo()
    end)()
  end
end

function FriendFrameItem:checkBlackOffTime(oldOffTime, nowOffTime)
  if oldOffTime == 0 and nowOffTime ~= 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendBlackGroupRefresh)
  elseif oldOffTime ~= 0 and nowOffTime == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Friend.FriendBlackGroupRefresh)
  end
end

function FriendFrameItem:refreshName(name)
  self.uiBinder.lab_play_name.text = name
end

function FriendFrameItem:refreshShowState(offTime, scenenId, personalState)
  if offTime == 0 then
    self.uiBinder.lab_time.text = ""
    if scenenId and scenenId ~= 0 then
      local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(scenenId)
      if sceneRow then
        self.uiBinder.lab_time.text = sceneRow.Name
      end
    end
    local persData
    if personalState then
      persData = self.friendsMainVm_.GetFriendsStatus(offTime, personalState)
    else
      persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOnline)
    end
    if persData then
      self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
  else
    self.uiBinder.lab_time.text = Z.VMMgr.GetVM("union"):GetLastTimeDesignText(offTime)
    local persData = Z.TableMgr.GetTable("ChatStatusTableMgr").GetRow(E.PersonalizationStatus.EStatusOutLine)
    if persData then
      self.uiBinder.img_icon:SetImage(Z.ConstValue.Friend.FriendIconPath .. persData.Res)
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
  end
end

function FriendFrameItem:refreshHead(socialData)
  playerPortraitMgr.InsertNewPortraitBySocialData(self.uiBinder.cont_friend_select_head_tpl, socialData, nil, self.parent.UIView.cancelSource:CreateToken())
end

function FriendFrameItem:asyncInitInfo()
  local oldTime = self.data_:GetPlayerOffLineTime()
  self.friendsMainVm_.AsyncInitInfo(self.data_)
  self:checkBlackOffTime(oldTime, self.data_:GetPlayerOffLineTime())
  self:refreshPlayerInfo()
  Z.EventMgr:Dispatch(Z.ConstValue.Chat.SocialDataUpdata)
end

function FriendFrameItem:refreshPlayerInfo()
  local name = ""
  if self.data_:GetRemark() == "" then
    name = self.data_:GetPlayerName()
  else
    name = self.data_:GetRemark()
  end
  self:refreshName(name)
  self:refreshShowState(self.data_:GetPlayerOffLineTime(), self.data_:GetPlayerSceneId(), self.data_:GetPlayerPersonalState())
  self:refreshHead(self.data_:GetSocialData())
end

return FriendFrameItem
