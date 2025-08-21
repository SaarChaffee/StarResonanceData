local super = require("ui.component.loop_list_view_item")
local CameraInvitedLoopItem = class("CameraInvitedLoopItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local SelfColor = Color.New(0.9882352941176471, 0.8862745098039215, 0.6745098039215687, 1)
local NormalColor = Color.New(1, 1, 1, 1)

function CameraInvitedLoopItem:ctor()
  super:ctor()
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
end

function CameraInvitedLoopItem:OnInit()
  self.parentView_ = self.parent.UIView
  self:initBtn()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
  self:bindEvents()
end

function CameraInvitedLoopItem:bindEvents()
end

function CameraInvitedLoopItem:unBindEvents()
end

function CameraInvitedLoopItem:initBtn()
  self.parentView_:AddClick(self.uiBinder.btn_exit, function()
    self.cameraMemberData_:RemoveMemberListData(self.data_.charId)
  end)
  self.parentView_:AddClick(self.uiBinder.btn_refresh, function()
    self.cameraMemberVM_:UpdateMemberListData(self.data_.charId, self.data_.socialData, self.Index)
  end)
end

function CameraInvitedLoopItem:OnRefresh(data)
  self.data_ = data.info
  self.isShowRefreshBtn_ = data.isShowRefreshBtn
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data_.socialData.basicData.isNewbie))
  self.uiBinder.lab_name.text = self.data_.socialData.basicData.name
  self:setHead()
  self.uiBinder.lab_name.color = self.data_.baseData.isSelf and SelfColor or NormalColor
  local isNearby = self.cameraMemberVM_:CheckMemberIsNearby(self.data_.charId)
  local state = not isNearby and Lang("PhotoTeamMemberState4") or Lang("PhotoTeamMemberState1")
  self.uiBinder.lab_state.text = state
  local stateImg = not isNearby and Z.Global.PhotoMultiStateIcon[2][2] or Z.Global.PhotoMultiStateIcon[1][2]
  self.uiBinder.img_state:SetImage(stateImg)
  if self.data_.baseData.isSelf then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_refresh, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_exit, false)
    return
  end
  local isShowRefreshBtn = data.isShowRefreshBtn == true
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_refresh, isShowRefreshBtn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_exit, not isShowRefreshBtn)
  if self.IsSelected and self.data_.actionData.actionId == 0 then
    self.parentView_.parent:SetActionSliderTransVisible(false)
  end
  if not self.data_.baseData.model then
    self:SetCanSelect(false)
    if self.Index ~= 1 and self.cameraMemberData_.SelectLoopIndex == self.Index then
      self.parentView_:OnSelectedItem()
    end
  else
    self:SetCanSelect(true)
  end
end

function CameraInvitedLoopItem:OnUnInit()
  self:unBindEvents()
  self.isShowRefreshBtn_ = nil
end

function CameraInvitedLoopItem:setHead()
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, self.data_.socialData, nil, self.parent.UIView.cancelSource:CreateToken())
end

function CameraInvitedLoopItem:OnSelected(isSelected, isClick)
  if not self.isShowRefreshBtn_ then
    return
  end
  if isSelected then
    self.cameraMemberData_.SelectLoopIndex = self.Index
    self.cameraMemberData_:SetSelectMemberCharId(self.data_.charId)
    local curModel = self.data_.baseData.model
    self.parentView_.parent:RefreshActionSlider(curModel, self.data_, self.data_.baseData.isActionState)
    Z.EventMgr:Dispatch(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.data_.charId == Z.ContainerMgr.CharSerialize.charBase.charId)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

return CameraInvitedLoopItem
