local super = require("ui.component.loopscrollrectitem")
local playerPortraitMgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local FriendFrameItem = class("FriendFrameItem", super)

function FriendFrameItem:ctor()
  self.uiBinder = nil
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.chatMainData_ = Z.DataMgr.Get("chat_main_data")
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.socialVm_ = Z.VMMgr.GetVM("social")
end

function FriendFrameItem:OnInit()
end

function FriendFrameItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if self.data_:GetIsGroup() then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_head, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, true)
    self.uiBinder.lab_label.text = self.friendMainData_:GetGroupName(self.data_:GetGroupId())
    self.uiBinder.btn_item.interactable = true
    self:refreshArrow()
    self:refreshOnlineNum()
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_head, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_content, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_on, self.isSelected_)
    self.uiBinder.btn_item.interactable = false
    if self.uiBinder == nil then
      return
    end
    self:refreshPlayerInfo()
    self:EventAddAsyncListener(self.uiBinder.btn_item.OnLongPressEvent, function()
      local isFriend = not self.chatMainData_:IsInBlack(self.data_:GetCharId())
      self.parent.uiView:ShowBtnFunctionTips(self.data_:GetCharId(), self.uiBinder.node_tips.position, false, isFriend)
    end)
    self:AddAsyncClick(self.uiBinder.img_bg, function()
      local idCardVM = Z.VMMgr.GetVM("idcard")
      idCardVM.AsyncGetCardData(self.data_:GetCharId(), self.parent.uiView.cancelSource:CreateToken())
    end)
  end
  self:AddClick(self.uiBinder.btn_item, function()
    self:onSelectedGroup()
  end)
end

function FriendFrameItem:OnPointerClick()
end

function FriendFrameItem:Selected(isSelected)
  if self.data_:GetIsGroup() then
    return
  end
  self:onSelectedFriend(isSelected)
end

function FriendFrameItem:onSelectedGroup()
  if not self.data_:GetIsGroup() then
    return
  end
  local isShow = self.data_:GetIsGroupShow()
  if isShow == 0 then
    self.data_:SetIsGroupShow(1)
  else
    self.data_:SetIsGroupShow(0)
  end
  self:refreshArrow()
  self.parent.uiView:RefreshFriendsData()
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
  self.isSelected_ = isSelected
  if true == isSelected then
    if self.friendMainData_:GetAddressSelectCharId() == self.data_:GetCharId() then
      local rightList = self.friendMainData_:GetRightSubViewList()
      if table.zcount(rightList) > 0 then
        self.parent.uiView:ShowRightNodeByCacheList()
        return
      end
    end
    self.friendMainData_:SetAddressSelectCharId(self.data_:GetCharId())
    if self.chatMainData_:IsInBlack(self.data_:GetCharId()) then
      Z.CoroUtil.create_coro_xpcall(function()
        self.friendsMainVm_.AsyncRefreshBlacks({
          self.data_:GetCharId()
        })
      end)()
      self.parent.uiView:ShowNodeRightSubView(E.FriendFunctionViewType.None, {}, true)
    else
      local viewData = {}
      viewData.IsNeedReturn = false
      viewData.CharId = self.data_:GetCharId()
      self.parent.uiView:ShowNodeRightSubView(E.FriendFunctionViewType.SendMessage, viewData, true)
    end
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
  playerPortraitMgr.InsertNewPortraitBySocialData(self.uiBinder.cont_friend_select_head_tpl, socialData)
end

function FriendFrameItem:asyncInitInfo()
  local oldTime = self.data_:GetPlayerOffLineTime()
  self.friendsMainVm_.AsyncInitInfo(self.data_)
  self:checkBlackOffTime(oldTime, self.data_:GetPlayerOffLineTime())
  self:refreshPlayerInfo()
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

function FriendFrameItem:OnUnInit()
  self.isSelected_ = false
end

function FriendFrameItem:OnReset()
  self.isSelected_ = false
end

return FriendFrameItem
