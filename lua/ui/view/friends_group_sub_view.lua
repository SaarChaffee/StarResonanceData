local UI = Z.UI
local super = require("ui.ui_subview_base")
local Friends_group_subView = class("Friends_group_subView", super)
local groupItemPath = "ui/prefabs/friends/friends_group_item_tpl"

function Friends_group_subView:ctor()
  self.uiBinder = nil
  super.ctor(self, "friends_group_sub", "friends/friends_group_sub", UI.ECacheLv.None)
end

function Friends_group_subView:OnActive()
  self.friendsMainVm_ = Z.VMMgr.GetVM("friends_main")
  self.friendsMainData_ = Z.DataMgr.Get("friend_main_data")
  self.isCreating_ = false
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetWidth(766)
  self:AddClick(self.uiBinder.btn_startsort, function()
    self:changeInteractable(true)
  end)
  self:AddClick(self.uiBinder.btn_endsort, function()
    self:changeInteractable(false)
    self:saveGroupSort()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.friendsMainVm_.CloseSetView(E.FriendFunctionViewType.GroupManagement)
  end)
  self:AddClick(self.uiBinder.img_frame, function()
    self:createGroup()
  end)
  self:AddClick(self.uiBinder.btn_small_round, function()
    self:createGroup()
  end)
  self:BindEvents()
end

function Friends_group_subView:OnDeActive()
  self:UnBindEvents()
end

function Friends_group_subView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.Friend.FriendGroupRefresh, self.refreshGroup, self)
end

function Friends_group_subView:UnBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Friend.FriendGroupRefresh, self.refreshGroup, self)
end

function Friends_group_subView:OnRefresh()
  self.isChangeGroupSort_ = false
  self.funcOnInteractableChange_ = {}
  self:changeInteractable(false)
  self:refreshGroup()
end

function Friends_group_subView:createGroup()
  local data = {
    title = Lang("FriendCreateGroup"),
    inputContent = Lang("FriendCreateGroupDefaultName"),
    onConfirm = function(name)
      if self.isCreating_ == true then
        return
      end
      self.isCreating_ = true
      local errCode = self.friendsMainVm_.AsyncCreateGroup(name, self.cancelSource:CreateToken())
      if errCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
        self.isCreating_ = false
        return errCode
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

function Friends_group_subView:refreshGroup()
  self:ClearAllUnits()
  self.funcOnInteractableChange_ = {}
  local groupList = self.friendsMainData_:GetGroupList()
  if groupList then
    Z.CoroUtil.create_coro_xpcall(function()
      for _, group in pairs(groupList) do
        local unit = self:AsyncLoadUiUnit(groupItemPath, tostring(group:GetGroupId()), self.uiBinder.layout_group)
        self:refreshGroupItemUnit(unit, group:GetGroupId())
      end
    end)()
  end
end

function Friends_group_subView:refreshGroupItemUnit(unit, groupId)
  unit.lab_group_name.text = self.friendsMainData_:GetGroupName(groupId)
  unit.Trans.name = groupId
  self:refreshGroupItemBtn(unit, groupId)
  unit.Ref:SetVisible(unit.presscheck_pointpress, false)
  self:AddClick(unit.img_tips, function()
    unit.Ref:SetVisible(unit.img_dot, true)
    unit.Ref:SetVisible(unit.img_tips, false)
    unit.Ref:SetVisible(unit.img_set, false)
    unit.Ref:SetVisible(unit.img_delete, true)
    unit.Ref:SetVisible(unit.presscheck_pointpress, true)
    unit.presscheck_pointpress:StartCheck()
  end)
  self.funcOnInteractableChange_[groupId] = function()
    self:refreshGroupItemBtn(unit, groupId)
  end
  self:EventAddAsyncListener(unit.presscheck_pointpress.ContainGoEvent, function(isContain)
    if not isContain then
      self:refreshGroupItemBtn(unit, groupId)
      unit.presscheck_pointpress:StopCheck()
    else
      local friendList = self.friendsMainData_:GetGroupAndFriendData(groupId)
      if table.zcount(friendList) <= 0 then
        Z.CoroUtil.create_coro_xpcall(function()
          self.friendsMainVm_.AsyncDelectGroup(groupId, self.cancelSource:CreateToken())
        end)()
      else
        Z.DialogViewDataMgr:OpenNormalDialog(Lang("delectFriendGroup"), function()
          self.friendsMainVm_.AsyncDelectGroup(groupId, self.cancelSource:CreateToken())
        end)
      end
    end
  end, nil, nil)
  self:AddClick(unit.img_edit, function()
    local data = {
      title = Lang("FriendChangeGroupName"),
      inputContent = self.friendsMainData_:GetGroupName(groupId),
      onConfirm = function(name)
        local errCode = self.friendsMainVm_.AsyncChangeGroupName(groupId, name, self.cancelSource:CreateToken())
        if errCode == Z.PbEnum("EErrorCode", "ErrIllegalCharacter") then
          return errCode
        end
      end,
      stringLengthLimitNum = Z.Global.PlayerNameLimit,
      inputDesc = Lang("FriendGroupName")
    }
    Z.TipsVM.OpenCommonPopupInput(data)
  end)
end

function Friends_group_subView:saveGroupSort()
  local groupList = {}
  for i = 1, self.uiBinder.layout_group.childCount do
    local unit = self.uiBinder.layout_group:GetChild(i - 1)
    groupList[#groupList + 1] = tonumber(unit.name)
  end
  table.zunique(groupList)
  Z.CoroUtil.create_coro_xpcall(function()
    self.friendsMainVm_.AsyncSetGroupSort(groupList, self.cancelSource:CreateToken())
  end)()
end

function Friends_group_subView:changeInteractable(isOpenInteractable)
  if true == isOpenInteractable then
    self.isChangeGroupSort_ = true
    self.uiBinder.layout_group_drag.interactable = true
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_startsort, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_endsort, true)
  else
    self.isChangeGroupSort_ = false
    self.uiBinder.layout_group_drag.interactable = false
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_startsort, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_endsort, false)
  end
  for _, func in pairs(self.funcOnInteractableChange_) do
    func()
  end
end

function Friends_group_subView:refreshGroupItemBtn(unit, groupId)
  if true == self.isChangeGroupSort_ then
    unit.Ref:SetVisible(unit.img_dot, true)
    unit.Ref:SetVisible(unit.img_tips, false)
    unit.Ref:SetVisible(unit.img_edit, false)
    unit.Ref:SetVisible(unit.img_set, true)
  else
    local isSystemGroup = self.friendsMainData_:IsSystemGroup(groupId)
    if isSystemGroup then
      unit.Ref:SetVisible(unit.img_dot, true)
      unit.Ref:SetVisible(unit.img_tips, false)
      unit.Ref:SetVisible(unit.img_edit, false)
    else
      unit.Ref:SetVisible(unit.img_dot, false)
      unit.Ref:SetVisible(unit.img_tips, true)
      unit.Ref:SetVisible(unit.img_edit, true)
    end
    unit.Ref:SetVisible(unit.img_set, false)
  end
  unit.Ref:SetVisible(unit.img_delete, false)
end

return Friends_group_subView
