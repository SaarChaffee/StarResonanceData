local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_manage_subView = class("Friends_manage_subView", super)
local loopScrollRect = require("ui/component/loopscrollrect")
local friend_group_item = require("ui.component.friends.friend_group_select_item")
local allFriendGroupId = 1

function Friends_manage_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "friends_manage_sub", "friends/friends_manage_sub", UI.ECacheLv.None)
end

function Friends_manage_subView:OnActive()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.FriendManagement)
  end)
  self.isCreating_ = false
  self:AddClick(self.uiBinder.img_frame, function()
    self:createGroup()
  end)
  self:AddClick(self.uiBinder.btn_small_round, function()
    self:createGroup()
  end)
  self.groupList_ = {}
  self.friendGroupScrollRect_ = loopScrollRect.new(self.uiBinder.loopscroll_group, self, friend_group_item)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
  self:BindEvents()
end

function Friends_manage_subView:OnDeActive()
  self.groupList_ = {}
end

function Friends_manage_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendGroupRefresh, self.refeshGruoupList, self)
end

function Friends_manage_subView:OnRefresh()
  self:refeshGruoupList()
end

function Friends_manage_subView:createGroup()
  if self.isCreating_ == true then
    return
  end
  self.isCreating_ = true
  local data = {
    title = Lang("FriendCreateGroup"),
    inputContent = Lang("FriendCreateGroupDefaultName"),
    onConfirm = function(name)
      local ret = self.friendsMainVm_.AsyncCreateGroup(name, self.cancelSource:CreateToken())
      if ret.errorCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
        self.isCreating_ = false
        return ret.errorCode
      end
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

function Friends_manage_subView:refeshGruoupList()
  local groupList = {}
  self.friendGroupScrollRect_:ClearSelected()
  local chatGroupCfg = self.friendsMainData_:GetGroupTableData()
  if #chatGroupCfg < 1 then
    return
  end
  local allFriendGroup = chatGroupCfg[allFriendGroupId]
  local groupInfo = {}
  groupInfo.GroupId = allFriendGroup.Id
  groupInfo.GroupName = allFriendGroup.GroupName
  table.insert(groupList, 1, groupInfo)
  local customGroup = self.friendsMainData_:GetCustomGroup()
  for groupId, groupName in pairs(customGroup) do
    local groupInfo = {}
    groupInfo.GroupId = groupId
    groupInfo.GroupName = groupName
    table.insert(groupList, groupInfo)
  end
  local index = 1
  local friendData = self.friendsMainData_:GetFriendDataByCharId(self.viewData.CharId)
  if friendData then
    for i = 1, #groupList do
      if groupList[i].GroupId == friendData:GetGroupId() then
        index = i
        break
      end
    end
  end
  self.friendGroupScrollRect_:SetData(groupList, false, false, index - 1)
  self.friendGroupScrollRect_:SetSelected(index - 1)
end

function Friends_manage_subView:ChangeGroup(groupId)
  local friendData = self.friendsMainData_:GetFriendDataByCharId(self.viewData.CharId)
  if friendData and friendData:GetGroupId() == groupId then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncChangeGroup(self.viewData.CharId, groupId, self.cancelSource:CreateToken())
  end)()
end

return Friends_manage_subView
