local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_gazeView = class("Camera_menu_container_gazeView", super)

function Camera_menu_container_gazeView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_gaze_sub", "photograph/camera_menu_container_gaze_sub", UI.ECacheLv.None)
end

function Camera_menu_container_gazeView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraMemberData_ = Z.DataMgr.Get("camerasys_member_data")
  self.cameraMemberVM_ = Z.VMMgr.GetVM("camera_member")
  self:initBtn()
  self:bindEvents()
  self:initParam()
end

function Camera_menu_container_gazeView:initParam()
  self.selectMemberData_ = self.cameraMemberVM_:AssembledLookAtMemberData()
  self.headTogList_ = {
    [E.CameraPlayerLookAtType.Default] = self.uiBinder.tog_default_toward_face,
    [E.CameraPlayerLookAtType.Camera] = self.uiBinder.tog_camera_toward_face,
    [E.CameraPlayerLookAtType.Free] = self.uiBinder.tog_free_toward_face
  }
  self.eyesTogList_ = {
    [E.CameraPlayerLookAtType.Default] = self.uiBinder.tog_default_toward_eye,
    [E.CameraPlayerLookAtType.Camera] = self.uiBinder.tog_camera_toward_eye,
    [E.CameraPlayerLookAtType.Free] = self.uiBinder.tog_free_toward_eye
  }
end

function Camera_menu_container_gazeView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onSelectCameraMemberChanged, self)
end

function Camera_menu_container_gazeView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.CameraMember.SelectCameraMemberChanged, self.onSelectCameraMemberChanged, self)
end

function Camera_menu_container_gazeView:onSelectCameraMemberChanged()
  self.selectMemberData_ = self.cameraMemberVM_:AssembledLookAtMemberData()
  self:refreshTogState()
end

function Camera_menu_container_gazeView:initBtn()
  self.uiBinder.tog_head_lock.isOn = false
  self.uiBinder.tog_head_lock:AddListener(function(isOn)
    self.cameraData_.HeadLock = isOn
    self:setHeadLookAt(E.CameraPlayerLookAtType.Lock, isOn)
  end)
  self.uiBinder.tog_eye_lock.isOn = false
  self.uiBinder.tog_eye_lock:AddListener(function(isOn)
    self.cameraData_.EyesLock = isOn
    self:setEyesLookAt(E.CameraPlayerLookAtType.Lock, isOn)
  end)
  self.uiBinder.tog_control_everyone.isOn = false
  self.uiBinder.tog_control_everyone:AddListener(function(isOn)
    self.cameraData_.IsControlEveryOne = isOn
    self:onSelectCameraMemberChanged()
  end)
  self.uiBinder.tog_default_toward_face:AddListener(function(isOn)
    if isOn then
      self:setHeadLookAt(E.CameraPlayerLookAtType.Default)
    end
  end)
  self.uiBinder.tog_camera_toward_face:AddListener(function(isOn)
    if isOn then
      self:setHeadLookAt(E.CameraPlayerLookAtType.Camera)
    end
  end)
  self.uiBinder.tog_free_toward_face:AddListener(function(isOn)
    if isOn then
      self:setHeadLookAt(E.CameraPlayerLookAtType.Free)
    end
  end)
  self.uiBinder.tog_default_toward_eye:AddListener(function(isOn)
    if isOn then
      self:setEyesLookAt(E.CameraPlayerLookAtType.Default)
    end
  end)
  self.uiBinder.tog_camera_toward_eye:AddListener(function(isOn)
    if isOn then
      self:setEyesLookAt(E.CameraPlayerLookAtType.Camera)
    end
  end)
  self.uiBinder.tog_free_toward_eye:AddListener(function(isOn)
    if isOn then
      self:setEyesLookAt(E.CameraPlayerLookAtType.Free)
    end
  end)
end

function Camera_menu_container_gazeView:OnDeActive()
  self:unBindEvents()
  self.selectMemberData_ = nil
end

function Camera_menu_container_gazeView:OnRefresh()
  self:refreshTogState()
end

function Camera_menu_container_gazeView:refreshTogState()
  local memberData = self.cameraMemberData_:GetSelectMemberData()
  if not memberData then
    return
  end
  for k, v in pairs(self.headTogList_) do
    v:SetIsOnWithoutCallBack(false)
  end
  for k, v in pairs(self.eyesTogList_) do
    v:SetIsOnWithoutCallBack(false)
  end
  self.headTogList_[memberData.lookAtData.headMode]:SetIsOnWithoutCallBack(true)
  self.eyesTogList_[memberData.lookAtData.eyesMode]:SetIsOnWithoutCallBack(true)
end

function Camera_menu_container_gazeView:setLookAtFreeIsOn(isOn, isFace)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetFreeLookAt, isOn, isFace)
end

function Camera_menu_container_gazeView:setHeadLookAt(type, isOn)
  if not self.selectMemberData_ then
    return
  end
  for k, v in pairs(self.selectMemberData_) do
    local model = v.baseData.model
    model:SetLuaAttrLookAtHeadClose(type == E.CameraPlayerLookAtType.Default)
    if type == E.CameraPlayerLookAtType.Default then
      Z.ModelHelper.ResetLookAtIKParam(model)
      Z.ModelHelper.SetLookAtTransform(model, nil)
    elseif type == E.CameraPlayerLookAtType.Camera then
      self.cameraVM_.SetHeadLookAt(true, model)
    elseif type == E.CameraPlayerLookAtType.Lock then
      self:setLockPos(isOn)
    end
    v.lookAtData.headMode = type
  end
  self.cameraData_.IsHeadFollow = type == E.CameraPlayerLookAtType.Free
  self.uiBinder.tog_head_lock:SetIsOnWithoutCallBack(type == E.CameraPlayerLookAtType.Lock)
  self:setLookAtFreeIsOn(type == E.CameraPlayerLookAtType.Free, true)
  if type == E.CameraPlayerLookAtType.Lock and isOn == false then
    self.uiBinder.tog_default_toward_face.isOn = true
  end
end

function Camera_menu_container_gazeView:setEyesLookAt(type, isOn)
  if not self.selectMemberData_ then
    return
  end
  for k, v in pairs(self.selectMemberData_) do
    local model = v.baseData.model
    model:SetLuaAttrLookAtEyeOpen(type ~= E.CameraPlayerLookAtType.Default)
    if type == E.CameraPlayerLookAtType.Camera then
      local mainCamTrans = Z.CameraMgr.MainCamTrans
      if mainCamTrans then
        Z.ModelHelper.SetLookAtTransform(model, mainCamTrans, false, false)
      end
    elseif type == E.CameraPlayerLookAtType.Lock then
      self:setLockPos(isOn)
    end
    v.lookAtData.eyesMode = type
  end
  self.cameraData_.IsEyeFollow = type == E.CameraPlayerLookAtType.Free
  self.uiBinder.tog_eye_lock:SetIsOnWithoutCallBack(type == E.CameraPlayerLookAtType.Lock)
  self:setLookAtFreeIsOn(type == E.CameraPlayerLookAtType.Free, false)
  if type == E.CameraPlayerLookAtType.Lock and isOn == false then
    self.uiBinder.tog_default_toward_eye.isOn = true
  end
end

function Camera_menu_container_gazeView:setLockPos(isOn)
  if isOn then
    for k, v in pairs(self.selectMemberData_) do
      local model = v.baseData.model
      local mainCamTrans = Z.CameraMgr.MainCamTrans
      local localPosition = Z.ModelHelper.LuaWorldPosToLocal(model, mainCamTrans.position)
      if self.cameraData_.HeadLock then
        local lookAtModel = v.lookAtData.headMode
        if lookAtModel == E.CameraPlayerLookAtType.Camera then
          Z.ModelHelper.SetLookAtPos(model, localPosition, true)
        end
      end
      if self.cameraData_.EyesLock then
        local lookAtModel = v.lookAtData.eyesMode
        if lookAtModel == E.CameraPlayerLookAtType.Camera then
          Z.ModelHelper.SetLookAtPos(model, localPosition, false)
        end
      end
    end
    self:setTogIsOn(self.cameraData_.HeadLock)
  end
end

function Camera_menu_container_gazeView:setTogIsOn(isHead)
  if isHead then
    self.uiBinder.tog_default_toward_face:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_camera_toward_face:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_free_toward_face:SetIsOnWithoutCallBack(false)
  else
    self.uiBinder.tog_default_toward_eye:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_camera_toward_eye:SetIsOnWithoutCallBack(false)
    self.uiBinder.tog_free_toward_eye:SetIsOnWithoutCallBack(false)
  end
end

return Camera_menu_container_gazeView
