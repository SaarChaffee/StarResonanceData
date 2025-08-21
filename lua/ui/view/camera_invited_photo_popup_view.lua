local super = require("ui.ui_view_base")
local Camera_invited_photo_popupView = class("Camera_invited_photo_popupView", super)
local loopScrollRect_ = require("ui.component.loop_list_view")
local loopGridScrollRect_ = require("ui.component.loop_grid_view")
local camera_invited_item_ = require("ui/component/camerasys/camera_invited_item")
local camera_invited_add_item_tpl_ = require("ui/component/camerasys/camera_invited_add_item_tpl")

function Camera_invited_photo_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "camera_invited_photo_popup")
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
end

function Camera_invited_photo_popupView:OnActive()
  self.relationshipType_ = E.CameraCharacterRelationship.Friend
  self:bindEvent()
  self:initBtn()
  self:initView()
end

function Camera_invited_photo_popupView:OnDeActive()
  self:unBindEvent()
  self.leftLoopScrollRect_:UnInit()
  self.leftLoopScrollRect_ = nil
  self.rightGridScrollRect_:UnInit()
  self.rightGridScrollRect_ = nil
end

function Camera_invited_photo_popupView:OnRefresh()
end

function Camera_invited_photo_popupView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshListLoopData, self)
end

function Camera_invited_photo_popupView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.CameraMemberListUpdate, self.refreshListLoopData, self)
end

function Camera_invited_photo_popupView:initView()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.viewConfigKey)
  self.leftLoopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.looplist_left, camera_invited_item_, "camera_invited_item_tpl")
  self.rightGridScrollRect_ = loopGridScrollRect_.new(self, self.uiBinder.looplist_right, camera_invited_add_item_tpl_, "camera_invited_add_item_tpl")
  self.leftLoopScrollRect_:Init({})
  self.rightGridScrollRect_:Init({})
  self:refreshListLoopData()
end

function Camera_invited_photo_popupView:initBtn()
  self:AddClick(self.uiBinder.btn_return, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_refresh, function()
    self:refreshGridLoopData(self.relationshipType_)
  end)
  self.uiBinder.tog_union:AddListener(function(isOn)
    if isOn then
      self:refreshGridLoopData(E.CameraCharacterRelationship.Union)
    end
  end)
  self.uiBinder.tog_team:AddListener(function(isOn)
    if isOn then
      self:refreshGridLoopData(E.CameraCharacterRelationship.Team)
    end
  end)
  self.uiBinder.tog_friend:AddListener(function(isOn)
    if isOn then
      self:refreshGridLoopData(E.CameraCharacterRelationship.Friend)
    end
  end)
  self.uiBinder.tog_union:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_team:SetIsOnWithoutCallBack(false)
  self.uiBinder.tog_friend:SetIsOnWithoutCallBack(true)
  self.relationshipType_ = E.CameraCharacterRelationship.Friend
end

function Camera_invited_photo_popupView:refreshGridLoopData(relationshipType)
  self.relationshipType_ = relationshipType
  local nearlyPeopleList = self.cameraMemberVM_:GetPeopleNearby(relationshipType)
  self.rightGridScrollRect_:RefreshListView(nearlyPeopleList)
end

function Camera_invited_photo_popupView:refreshListLoopData()
  local memberData = self.cameraMemberData_:AssemblyMemberListData()
  self.leftLoopScrollRect_:RefreshListView(memberData)
  self:refreshGridLoopData(self.relationshipType_)
end

return Camera_invited_photo_popupView
