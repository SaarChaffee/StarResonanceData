local UI = Z.UI
local super = require("ui.ui_view_base")
local Friends_group_popupView = class("Friends_group_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local friendGroupChangeItemPC = require("ui.component.friends_pc.friend_group_change_item_pc")

function Friends_group_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friends_group_popup")
end

function Friends_group_popupView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView("friends_group_popup")
  end)
  self:AddClick(self.uiBinder.btn_list, function()
    self:showGroopList()
  end)
  self.friendMainData_ = Z.DataMgr.Get("friend_main_data")
  self.friendMainVM_ = Z.VMMgr.GetVM("friends_main")
  self.curGroupId_ = self.viewData.groupId
  self:initGroupList()
  self:refreshGroupName()
end

function Friends_group_popupView:OnDeActive()
  self.groupListView_:UnInit()
end

function Friends_group_popupView:initGroupList()
  self.groupListView_ = loopListView.new(self, self.uiBinder.loop_list)
  self.groupListView_:SetGetItemClassFunc(function(data)
    if data.groupId == -1 then
      return friendGroupChangeItemPC
    else
      return friendGroupChangeItemPC
    end
  end)
  self.groupListView_:SetGetPrefabNameFunc(function(data)
    if data.groupId == -1 then
      return "friend_create_group_tpl"
    else
      return "friends_group_tpl"
    end
  end)
  self.groupListView_:Init({})
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
end

function Friends_group_popupView:refreshGroupName()
  self.uiBinder.lab_name.text = self.friendMainData_:GetGroupName(self.curGroupId_)
end

function Friends_group_popupView:showGroopList()
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, true)
  local groupList = self.friendMainData_:GetGroupSort()
  local groupDataList = {}
  for i = 1, #groupList do
    if groupList[i] ~= self.curGroupId_ and groupList[i] ~= E.FriendGroupType.Shield then
      local groupName = self.friendMainData_:GetGroupName(groupList[i])
      groupDataList[#groupDataList + 1] = {
        groupId = groupList[i],
        groupName = groupName
      }
    end
  end
  groupDataList[#groupDataList + 1] = {groupId = -1}
  if #groupDataList * 58 > 288 then
    self.uiBinder.loop_list_ref:SetHeight(288)
  else
    self.uiBinder.loop_list_ref:SetHeight(#groupDataList * 58)
  end
  self.groupListView_:RefreshListView(groupDataList, false)
  self.groupListView_:ClearAllSelect()
end

function Friends_group_popupView:OnSelectGroup(groupId)
  if groupId == -1 then
    self:createGroup()
  else
    self:changeGroup(groupId)
  end
end

function Friends_group_popupView:createGroup()
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
        return errCode
      end
      self.isCreating_ = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
    end,
    onCancel = function()
      self.isCreating_ = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
    end,
    stringLengthLimitNum = Z.Global.PlayerNameLimit,
    inputDesc = Lang("FriendGroupName")
  }
  Z.TipsVM.OpenCommonPopupInput(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
end

function Friends_group_popupView:changeGroup(groupId)
  Z.CoroUtil.create_coro_xpcall(function()
    local errCode = self.friendMainVM_.AsyncChangeGroup(self.viewData.charId, groupId, self.cancelSource:CreateToken())
    if errCode == 0 then
      self.curGroupId_ = groupId
      self.uiBinder.Ref:SetVisible(self.uiBinder.loop_list, false)
      Z.UIMgr:CloseView("friends_group_popup")
    else
      Z.TipsVM.ShowTips(errCode)
    end
  end)()
end

return Friends_group_popupView
