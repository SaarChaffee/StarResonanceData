local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_gazeView = class("Camera_menu_container_gazeView", super)

function Camera_menu_container_gazeView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_gaze_sub", "photograph/camera_menu_container_gaze_sub", UI.ECacheLv.None)
end

function Camera_menu_container_gazeView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self:initBtn()
end

function Camera_menu_container_gazeView:initBtn()
  self:AddClick(self.panel.cont_setting_title_item.btn_reset.Btn, function()
    self.panel.cont_lookedat_camera.cont_switch.switch.Switch.IsOn = false
    self.panel.cont_freely_adjusted.cont_switch.switch.Switch.IsOn = false
  end)
  self.panel.cont_lookedat_camera.cont_switch.switch.Switch:AddListener(function(isOn)
    if self.panel.cont_freely_adjusted.cont_switch.switch.Switch.IsOn ~= false then
      self.panel.cont_freely_adjusted.cont_switch.switch.Switch:SetIsOnWithoutNotify(false)
      self:setLookAtFreeIsOn(false)
    end
    self:setLookAtCameraIsOn(isOn)
  end)
  self.panel.cont_single_pupil.cont_switch.switch.Switch:AddListener(function(isOn)
    self.cameraData_:SetIsSchemeParamUpdated(true)
    self.cameraData_.IsEyeFollow = isOn
    self.cameraVM_.SetEyesLookAt(isOn)
  end)
  self.panel.cont_freely_adjusted.cont_switch.switch.Switch:AddListener(function(isOn)
    if self.panel.cont_lookedat_camera.cont_switch.switch.Switch.IsOn ~= false then
      self.panel.cont_lookedat_camera.cont_switch.switch.Switch:SetIsOnWithoutNotify(false)
      self:setLookAtCameraIsOn(false)
    end
    self:setLookAtFreeIsOn(isOn)
  end)
end

function Camera_menu_container_gazeView:OnDeActive()
end

function Camera_menu_container_gazeView:OnRefresh()
  self:setLookAtDefault()
end

function Camera_menu_container_gazeView:setLookAtDefault()
  self.panel.cont_lookedat_camera.cont_switch.switch.Switch.IsOn = self.cameraData_.IsHeadFollow
  self.panel.cont_freely_adjusted.cont_switch.switch.Switch.IsOn = self.cameraData_.IsFreeFollow
  self.panel.node_3:SetVisible(self.cameraData_.IsHeadFollow)
  self.panel.cont_single_pupil.cont_switch.switch.Switch.IsOn = self.cameraData_.IsEyeFollow
end

function Camera_menu_container_gazeView:setLookAtCameraIsOn(isOn)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  self.panel.node_3:SetVisible(isOn)
  if isOn then
    self.cameraData_.IsHeadFollow = true
  else
    self.cameraData_.IsHeadFollow = false
    self.cameraData_.IsEyeFollow = false
    self.panel.cont_single_pupil.cont_switch.switch.Switch.IsOn = false
  end
  self.cameraVM_.SetHeadLookAt(isOn)
  self.panel.node_3.ZLayout:ForceRebuildLayoutImmediate()
end

function Camera_menu_container_gazeView:setLookAtFreeIsOn(isOn)
  self.cameraData_.IsFreeFollow = isOn
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SetFreeLookAt, isOn)
end

return Camera_menu_container_gazeView
