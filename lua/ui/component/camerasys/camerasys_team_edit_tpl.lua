local super = require("ui.component.loop_list_view_item")
local CamerasysTeamEditTplItem = class("CamerasysTeamEditTplItem", super)
local playerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local ActionHelper = require("camera_action.action_helper")

function CamerasysTeamEditTplItem:ctor()
  super:ctor()
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
end

function CamerasysTeamEditTplItem:OnInit()
  self.leftLimitTime_ = 0
  self.rightLimitTime_ = 0
  self.rotationStep_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.PlayerRotation)
  self.parentView_ = self.parent.UIView
  self.actionHelper_ = ActionHelper.new(self.parentView_)
  self:initBtn()
  Z.EventMgr:Add(Z.ConstValue.Expression.ClickAction, self.onActionPlay, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PlayerStateChanged, self.onPlayerStateChange, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.ActionReset, self.resetAction, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeChange, self.onCameraPatternChanged, self)
end

function CamerasysTeamEditTplItem:onPlayerStateChange()
  if not (Z.EntityMgr.PlayerEnt and self.data_) or not self.data_.baseData.isSelf then
    return
  end
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  local isEnable = stateId == Z.PbEnum("EActorState", "ActorStateAction")
  self.uiBinder.node_action.interactable = isEnable
  self.uiBinder.node_action.alpha = isEnable and 1 or 0.5
  if not isEnable then
    self.actionHelper_:RefreshSliderPlay(false, true)
  end
end

function CamerasysTeamEditTplItem:resetAction()
  if self.actionHelper_ and self.data_ and self.data_.baseData.isSelf then
    self.actionHelper_:ResetExpression()
  end
end

function CamerasysTeamEditTplItem:initBtn()
  self.uiBinder.tog_eye_lock.isOn = false
  self.uiBinder.tog_face_lock.isOn = false
  self.parentView_:AddClick(self.uiBinder.btn_refresh_bg, function()
    self.cameraMemberVM_:UpdateMemberListData(self.data_.charId, self.data_.socialData, self.Index)
  end)
  self.parentView_:AddClick(self.uiBinder.btn_arrow_left_bg, function()
    self:setModelRotation(true)
  end)
  self.parentView_:AddClick(self.uiBinder.btn_arrow_right_bg, function()
    self:setModelRotation(false)
  end)
  self.parentView_:EventAddAsyncListener(self.uiBinder.btn_arrow_left_bg.OnLongPressUpdateEvent, function(deltaTime)
    if self.leftLimitTime_ >= 0.03 then
      self:setModelRotation(true)
      self.leftLimitTime_ = 0
    else
      self.leftLimitTime_ = self.leftLimitTime_ + deltaTime
    end
  end)
  self.parentView_:EventAddAsyncListener(self.uiBinder.btn_arrow_right_bg.OnLongPressUpdateEvent, function(deltaTime)
    if self.rightLimitTime_ >= 0.03 then
      self:setModelRotation(false)
      self.rightLimitTime_ = 0
    else
      self.rightLimitTime_ = self.rightLimitTime_ + deltaTime
    end
  end)
  self.parentView_:AddClick(self.uiBinder.btn_face_state, function()
    self:setModelLookAtChange(true)
  end)
  self.parentView_:AddClick(self.uiBinder.btn_eye_state, function()
    self:setModelLookAtChange(false)
  end)
  self.uiBinder.tog_eye_lock:AddListener(function(isOn)
    local selectMemberData = self.cameraMemberData_:GetMemberDataByCharId(self.data_.charId)
    if not selectMemberData then
      self.uiBinder.tog_eye_lock:SetIsOnWithoutCallBack(false)
      return
    end
    self.cameraData_.EyesLock = isOn
    self:setEyesLookAt(E.CameraPlayerLookAtType.Lock, isOn, selectMemberData)
  end)
  self.uiBinder.tog_face_lock:AddListener(function(isOn)
    local selectMemberData = self.cameraMemberData_:GetMemberDataByCharId(self.data_.charId)
    if not selectMemberData then
      self.uiBinder.tog_face_lock:SetIsOnWithoutCallBack(false)
      return
    end
    self.cameraData_.HeadLock = isOn
    self:setHeadLookAt(E.CameraPlayerLookAtType.Lock, isOn, selectMemberData)
  end)
end

function CamerasysTeamEditTplItem:onActionPlay(actionCfgId)
  if not self.data_.baseData.isSelf then
    return
  end
  self.actionHelper_:Refresh()
end

function CamerasysTeamEditTplItem:OnRefresh(data)
  self.data_ = data.info
  self.isShowRefreshBtn_ = data.isShowRefreshBtn
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_newbie, Z.VMMgr.GetVM("player"):IsShowNewbie(self.data_.socialData.basicData.isNewbie))
  self.uiBinder.lab_char_name.text = self.data_.socialData.basicData.name
  self:setHead()
  local isNearby = self.cameraMemberVM_:CheckMemberIsNearby(self.data_.charId)
  local stateImg = not isNearby and Z.Global.PhotoMultiStateIcon[2][2] or Z.Global.PhotoMultiStateIcon[1][2]
  self.uiBinder.img_state:SetImage(stateImg)
  if self.data_.baseData.isSelf then
    self.uiBinder.btn_refresh_bg.interactable = false
    self.uiBinder.btn_refresh_bg.IsDisabled = true
  else
    local isShowRefreshBtn = data.isShowRefreshBtn == true
    self.uiBinder.btn_refresh_bg.interactable = isShowRefreshBtn
    self.uiBinder.btn_refresh_bg.IsDisabled = not isShowRefreshBtn
  end
  self:setLookAtShow()
  if self.actionHelper_ then
    self.actionHelper_:UnInit()
  end
  local actionData = {
    memberListData = self.data_,
    uiBinder = self.uiBinder
  }
  self.actionHelper_:Init(actionData)
  if not self.data_.baseData.isSelf then
    self.actionHelper_:Refresh()
  end
  self:setNodeIsDisabled()
end

function CamerasysTeamEditTplItem:setNodeIsDisabled()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_medium_pause, self.data_.baseData.isActionState)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_medium_play, not self.data_.baseData.isActionState)
  if self.data_.baseData.isSelf then
    local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
    local isEnable = stateId == Z.PbEnum("EActorState", "ActorStateAction")
    self.uiBinder.node_action.interactable = isEnable
    self.uiBinder.node_action.alpha = isEnable and 1 or 0.5
    self.uiBinder.node_rotation.interactable = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.Battle
    self.uiBinder.node_rotation.alpha = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.Battle and 1 or 0.5
    self.uiBinder.node_lookAt.interactable = true
    self.uiBinder.node_lookAt.alpha = 1
  else
    self.uiBinder.node_rotation.interactable = self.data_.baseData.model ~= nil
    self.uiBinder.node_lookAt.interactable = self.data_.baseData.model ~= nil
    self.uiBinder.node_rotation.alpha = self.data_.baseData.model and 1 or 0.5
    self.uiBinder.node_lookAt.alpha = self.data_.baseData.model and 1 or 0.5
    self.uiBinder.node_action.interactable = self.data_.baseData.isActionState
    self.uiBinder.node_action.alpha = self.data_.baseData.isActionState and 1 or 0.5
  end
end

function CamerasysTeamEditTplItem:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.Expression.ClickAction, self.onActionPlay, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PlayerStateChanged, self.onPlayerStateChange, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.ActionReset, self.resetAction, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeChange, self.onCameraPatternChanged, self)
  self.isShowRefreshBtn_ = nil
  self:releaseActionHelper()
end

function CamerasysTeamEditTplItem:onCameraPatternChanged()
  if not self.data_.baseData.isSelf then
    return
  end
  self.uiBinder.node_rotation.interactable = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.Battle
  self.uiBinder.node_rotation.alpha = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.Battle and 1 or 0.5
end

function CamerasysTeamEditTplItem:releaseActionHelper()
  if self.actionHelper_ then
    self.actionHelper_:UnInit()
    self.actionHelper_ = nil
  end
end

function CamerasysTeamEditTplItem:setHead()
  playerPortraitHgr.InsertNewPortraitBySocialData(self.uiBinder.binder_head, self.data_.socialData, nil, self.parentView_.cancelSource:CreateToken())
end

function CamerasysTeamEditTplItem:setModelRotation(isLeft)
  local model = self.data_.baseData.isSelf and Z.EntityMgr.MainEnt.Model or self.data_.baseData.model
  if not model then
    return
  end
  local curRotation = self.cameraVM_.GetModelDefaultRotation(model)
  local rotationY = isLeft and curRotation + self.rotationStep_ or curRotation - self.rotationStep_
  local newRotation = Quaternion.Euler(Vector3.New(0, rotationY, 0))
  if self.data_.baseData.isSelf then
    Z.LuaBridge.SetEntityRotation(Z.EntityMgr.MainEnt, newRotation)
  else
    model:SetAttrGoRotation(newRotation)
  end
end

function CamerasysTeamEditTplItem:setLookAtShow()
  if self.data_.lookAtData.headMode ~= E.CameraPlayerLookAtType.Lock then
    self.uiBinder.lab_face_name.text = self.cameraData_.LookAtShowText[self.data_.lookAtData.headMode]
  end
  if self.data_.lookAtData.eyesMode ~= E.CameraPlayerLookAtType.Lock then
    self.uiBinder.lab_eye_name.text = self.cameraData_.LookAtShowText[self.data_.lookAtData.eyesMode]
  end
end

function CamerasysTeamEditTplItem:setModelLookAtChange(isHead)
  local selectMemberData = self.cameraMemberData_:GetMemberDataByCharId(self.data_.charId)
  if not selectMemberData then
    return
  end
  self.cameraMemberData_:SetSelectMemberCharId(self.data_.charId)
  if isHead then
    local type = selectMemberData.lookAtData.headMode + 1
    if type >= E.CameraPlayerLookAtType.Lock then
      type = E.CameraPlayerLookAtType.Default
    end
    self:setHeadLookAt(type, nil, selectMemberData)
  else
    local type = selectMemberData.lookAtData.eyesMode + 1
    if type >= E.CameraPlayerLookAtType.Lock then
      type = E.CameraPlayerLookAtType.Default
    end
    self:setEyesLookAt(type, nil, selectMemberData)
  end
end

function CamerasysTeamEditTplItem:setEyesLookAt(type, isOn, selectMemberData)
  local model = selectMemberData.baseData.model
  model:SetLuaAttrLookAtEyeOpen(type ~= E.CameraPlayerLookAtType.Default)
  if type == E.CameraPlayerLookAtType.Camera then
    local mainCamTrans = Z.CameraMgr.MainCamTrans
    if mainCamTrans then
      Z.ModelHelper.SetLookAtTransform(model, mainCamTrans, false, false)
    end
  elseif type == E.CameraPlayerLookAtType.Lock then
    self:setLockPos(isOn, selectMemberData)
  end
  if type ~= E.CameraPlayerLookAtType.Lock and selectMemberData.lookAtData.eyesMode == E.CameraPlayerLookAtType.Lock then
    self.uiBinder.tog_eye_lock:SetIsOnWithoutCallBack(false)
  end
  selectMemberData.lookAtData.eyesMode = type
  self.cameraData_.IsEyeFollow = type == E.CameraPlayerLookAtType.Free
  self:setLookAtFreeIsOn(type == E.CameraPlayerLookAtType.Free, false)
  if type == E.CameraPlayerLookAtType.Lock and isOn == false then
    self:setEyesLookAt(E.CameraPlayerLookAtType.Default, nil, selectMemberData)
  end
  self:setLookAtShow()
end

function CamerasysTeamEditTplItem:setHeadLookAt(type, isOn, selectMemberData)
  local model = selectMemberData.baseData.model
  model:SetLuaAttrLookAtHeadClose(type == E.CameraPlayerLookAtType.Default)
  if type == E.CameraPlayerLookAtType.Default then
    Z.ModelHelper.ResetLookAtIKParam(model)
    Z.ModelHelper.SetLookAtTransform(model, nil)
  elseif type == E.CameraPlayerLookAtType.Camera then
    self.cameraVM_.SetHeadLookAt(true, model)
  elseif type == E.CameraPlayerLookAtType.Lock then
    self:setLockPos(isOn, selectMemberData)
  end
  if type ~= E.CameraPlayerLookAtType.Lock and selectMemberData.lookAtData.headMode == E.CameraPlayerLookAtType.Lock then
    self.uiBinder.tog_face_lock:SetIsOnWithoutCallBack(false)
  end
  selectMemberData.lookAtData.headMode = type
  self.cameraData_.IsHeadFollow = type == E.CameraPlayerLookAtType.Free
  self:setLookAtFreeIsOn(type == E.CameraPlayerLookAtType.Free, true)
  if type == E.CameraPlayerLookAtType.Lock and isOn == false then
    self:setHeadLookAt(E.CameraPlayerLookAtType.Default, nil, selectMemberData)
  end
  self:setLookAtShow()
end

function CamerasysTeamEditTplItem:setLookAtFreeIsOn(isOn, isFace)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetFreeLookAt, isOn, isFace)
end

function CamerasysTeamEditTplItem:setLockPos(isOn, selectMemberData)
  if isOn then
    local model = selectMemberData.baseData.model
    local mainCamTrans = Z.CameraMgr.MainCamTrans
    local localPosition = Z.ModelHelper.LuaWorldPosToLocal(model, mainCamTrans.position)
    if self.cameraData_.HeadLock then
      local lookAtModel = selectMemberData.lookAtData.headMode
      if lookAtModel == E.CameraPlayerLookAtType.Camera then
        Z.ModelHelper.SetLookAtPos(model, localPosition, true)
      end
    end
    if self.cameraData_.EyesLock then
      local lookAtModel = selectMemberData.lookAtData.eyesMode
      if lookAtModel == E.CameraPlayerLookAtType.Camera then
        Z.ModelHelper.SetLookAtPos(model, localPosition, false)
      end
    end
  end
end

return CamerasysTeamEditTplItem
