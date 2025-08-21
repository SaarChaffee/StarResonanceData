local UnionSDKGroup = class("UnionSDKGroup")
local TENCENT_DEFINE = require("ui.model.tencent_define")
local QQ_ICON_PATH = "ui/atlas/new_com/com_channel_qq"
local WECHAT_ICON_PATH = "ui/atlas/new_com/com_channel_wechat"

function UnionSDKGroup:ctor()
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
  self.accountData_ = Z.DataMgr.Get("account_data")
  self.serverData_ = Z.DataMgr.Get("server_data")
end

function UnionSDKGroup:Init(view)
  self.targetView_ = view
  self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
  self:refreshSDKGroupUI()
  self.targetView_:AddAsyncClick(self.targetView_.uiBinder.btn_group, function()
    self:onClickSDKGroup()
  end)
  if not Z.GameContext.IsPlayInMobile then
    return
  end
  if not self.unionVM_:CheckSDKGroupValid() then
    return
  end
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupState, self.onGetGroupState, self)
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupRelation, self.onGetGroupRelation, self)
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnCreateGroup, self.onCreateGroup, self)
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnJoinGroup, self.onJoinGroup, self)
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnBindGroup, self.onBindGroup, self)
  Z.EventMgr:Add(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnUnbindGroup, self.onUnbindGroup, self)
  self.unionVM_:CallGetGroupState()
end

function UnionSDKGroup:UnInit()
  self.targetView_ = nil
  if not Z.GameContext.IsPlayInMobile then
    return
  end
  if not self.unionVM_:CheckSDKGroupValid() then
    return
  end
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupState, self.onGetGroupState, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnGetGroupRelation, self.onGetGroupRelation, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnCreateGroup, self.onCreateGroup, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnJoinGroup, self.onJoinGroup, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnBindGroup, self.onBindGroup, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionSDKGroupEvent.UnionSDKGroup_OnUnbindGroup, self.onUnbindGroup, self)
end

function UnionSDKGroup:refreshSDKGroupUI()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if not gotoFuncVM.CheckFuncCanUse(E.FunctionID.TencentGroup, true) then
    self.targetView_:SetUIVisible(self.targetView_.uiBinder.node_group, false)
    return
  end
  if self.accountData_.LoginType == E.LoginType.Apple or self.accountData_.PlatformType ~= E.LoginPlatformType.TencentPlatform then
    self.targetView_:SetUIVisible(self.targetView_.uiBinder.node_group, false)
    return
  end
  local isPresident = self.unionVM_:IsPlayerUnionPresident()
  local curGroupType = self.unionVM_:GetBindGroupType()
  local groupIconPath
  if curGroupType == TENCENT_DEFINE.GROUP_CHANNEL.QQ then
    groupIconPath = QQ_ICON_PATH
  elseif curGroupType == TENCENT_DEFINE.GROUP_CHANNEL.WeChat then
    groupIconPath = WECHAT_ICON_PATH
  elseif isPresident and self.accountData_.LoginType == E.LoginType.QQ then
    groupIconPath = QQ_ICON_PATH
  elseif isPresident and self.accountData_.LoginType == E.LoginType.WeChat then
    groupIconPath = WECHAT_ICON_PATH
  end
  if groupIconPath then
    self.targetView_.uiBinder.img_group:SetImage(groupIconPath)
    self.targetView_:SetUIVisible(self.targetView_.uiBinder.img_group, true)
    self.targetView_.uiBinder.lab_group.alignment = TMPro.TextAlignmentOptions.Right
  else
    self.targetView_:SetUIVisible(self.targetView_.uiBinder.img_group, false)
    self.targetView_.uiBinder.lab_group.alignment = TMPro.TextAlignmentOptions.Center
  end
  if isPresident then
    self.targetView_.uiBinder.lab_group.text = self.unionVM_:IsBindGroup() and Lang("SetAssociationGroup") or Lang("CreateAssociationGroup")
  else
    self.targetView_.uiBinder.lab_group.text = Lang("JoinAssociationGroup")
  end
end

function UnionSDKGroup:onClickSDKGroup()
  if self.unionVM_:IsPlayerUnionPresident() then
    if not self.unionVM_:IsBindGroup() then
      if Z.GameContext.IsPlayInMobile then
        if self.unionVM_:CheckSDKGroupValid() then
          self.unionVM_:CallCreateGroup()
        else
          Z.TipsVM.ShowTips(1000573)
        end
      else
        Z.TipsVM.ShowTips(1000574)
      end
    else
      self:openGroupSettingView()
    end
  else
    self.unionVM_:MemberJoinGroup()
  end
end

function UnionSDKGroup:openGroupSettingView()
  local viewData = {
    GroupType = self.unionVM_:GetBindGroupType(),
    GroupName = self.unionData_.SDKGroupInfo.GroupName,
    UnbindCallback = function()
      self.unionVM_:CallUnbindGroup()
    end
  }
  Z.UIMgr:OpenView("union_group_popup", viewData)
end

function UnionSDKGroup:asyncBindGroupToServer()
  if not self.unionVM_:CheckSDKGroupValid() then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local groupType, groupId, token
    if self.accountData_.LoginType == E.LoginType.QQ then
      groupType = TENCENT_DEFINE.GROUP_CHANNEL.QQ
      groupId = self.unionData_.SDKGroupInfo.GroupId
      token = self.unionData_.CancelSource:CreateToken()
    elseif self.accountData_.LoginType == E.LoginType.WeChat then
      groupType = TENCENT_DEFINE.GROUP_CHANNEL.WeChat
      groupId = tostring(self.unionInfo_.baseInfo.Id)
      token = self.unionData_.CancelSource:CreateToken()
    end
    local errCode = self.unionVM_:AsyncBindGroupWithTencent(groupType, groupId, token)
    if errCode and errCode == 0 then
      self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
      self:refreshSDKGroupUI()
    end
  end)()
end

function UnionSDKGroup:asyncUnbindGroupToServer()
  Z.CoroUtil.create_coro_xpcall(function()
    local token = self.unionData_.CancelSource:CreateToken()
    local errCode = self.unionVM_:AsyncUnBindGroupWithTencent(token)
    if errCode and errCode == 0 then
      self.unionInfo_ = self.unionVM_:GetPlayerUnionInfo()
      self:refreshSDKGroupUI()
    end
  end)()
end

function UnionSDKGroup:onGetGroupState()
  if self.unionVM_:IsBindGroup() then
    self.unionVM_:CallGetGroupRelation()
  else
    self:refreshSDKGroupUI()
  end
end

function UnionSDKGroup:onGetGroupRelation()
  self:refreshSDKGroupUI()
end

function UnionSDKGroup:onCreateGroup()
  if self.accountData_.LoginType == E.LoginType.QQ then
    self.unionVM_:CallBindGroup()
  else
    self.unionVM_:CallGetGroupState()
    self:asyncBindGroupToServer()
  end
end

function UnionSDKGroup:onJoinGroup()
  self.unionVM_:CallGetGroupRelation()
end

function UnionSDKGroup:onBindGroup()
  self.unionVM_:CallGetGroupState()
  self:asyncBindGroupToServer()
end

function UnionSDKGroup:onUnbindGroup()
  self.unionVM_:CallGetGroupState()
  self:asyncUnbindGroupToServer()
end

return UnionSDKGroup
