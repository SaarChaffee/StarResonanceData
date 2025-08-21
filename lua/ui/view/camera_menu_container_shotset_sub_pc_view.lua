local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_shotset_sub_pcView = class("Camera_menu_container_shotset_sub_pcView", super)

function Camera_menu_container_shotset_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_shotset_sub_pc", "photograph_pc/camera_menu_container_shotset_sub_pc", UI.ECacheLv.None)
  self.parent_ = parent
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
end

function Camera_menu_container_shotset_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initSliderStepVal()
  self:initVariable()
  self:initListener()
  self:bindEvent()
end

function Camera_menu_container_shotset_sub_pcView:bindEvent()
  Z.EventMgr:Add(Z.ConstValue.Camera.PatternTypeChange, self.updateFovRange, self)
end

function Camera_menu_container_shotset_sub_pcView:unBindEvent()
  Z.EventMgr:Remove(Z.ConstValue.Camera.PatternTypeChange, self.updateFovRange, self)
end

function Camera_menu_container_shotset_sub_pcView:OnDeActive()
  self:unBindEvent()
end

function Camera_menu_container_shotset_sub_pcView:initVariable()
  self.tbDatarAperture_ = self.cameraData_:GetDOFApertureFactorRange()
  self.tbDatarFocus_ = self.cameraData_:GetDOFFocalLengthRange()
  self.nearBlendRange_ = self.cameraData_:GetNearBlendRange()
  self.farBlendRange_ = self.cameraData_:GetFarBlendRange()
  self.tempAngle_ = self.cameraData_:GetCameraAngleRange()
  self:updateFovRange()
end

function Camera_menu_container_shotset_sub_pcView:refHVVariable()
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    self.tbDatarHorizontal_ = self.cameraData_:GetCameraSelfHorizontalRange()
    self.tbDatarVertical_ = self.cameraData_:GetCameraSelfVerticalRange()
  else
    self.tbDatarHorizontal_ = self.cameraData_:GetCameraHorizontalRange()
    self.tbDatarVertical_ = self.cameraData_:GetCameraVerticalRange()
  end
end

function Camera_menu_container_shotset_sub_pcView:initSliderBtn()
  self:AddClick(self.uiBinder.btn_horizontal_left, function()
    local value = self.uiBinder.slider_lens_horizontal.value - self.horizontal_step_val_
    self.uiBinder.slider_lens_horizontal.value = value
  end)
  self:AddClick(self.uiBinder.btn_horizontal_right, function()
    local value = self.uiBinder.slider_lens_horizontal.value + self.horizontal_step_val_
    self.uiBinder.slider_lens_horizontal.value = value
  end)
  self:AddClick(self.uiBinder.btn_vertical_left, function()
    local value = self.uiBinder.slider_lens_vertical.value - self.vertical_step_val_
    self.uiBinder.slider_lens_vertical.value = value
  end)
  self:AddClick(self.uiBinder.btn_vertical_right, function()
    local value = self.uiBinder.slider_lens_vertical.value + self.vertical_step_val_
    self.uiBinder.slider_lens_vertical.value = value
  end)
  self:AddClick(self.uiBinder.btn_rotation_left, function()
    local value = self.uiBinder.slider_lens_rotation.value - self.angle_step_val_
    self.uiBinder.slider_lens_rotation.value = value
  end)
  self:AddClick(self.uiBinder.btn_rotation_right, function()
    local value = self.uiBinder.slider_lens_rotation.value + self.angle_step_val_
    self.uiBinder.slider_lens_rotation.value = value
  end)
  self:AddClick(self.uiBinder.btn_visibility_left, function()
    local value = self.uiBinder.slider_visibility.value - self.fov_step_val_
    self.uiBinder.slider_visibility.value = value
  end)
  self:AddClick(self.uiBinder.btn_visibility_right, function()
    local value = self.uiBinder.slider_visibility.value + self.fov_step_val_
    self.uiBinder.slider_visibility.value = value
  end)
  self:AddClick(self.uiBinder.btn_aperture_left, function()
    local value = self.uiBinder.slider_aperture.value - self.aperture_step_val_
    self.uiBinder.slider_aperture.value = value
  end)
  self:AddClick(self.uiBinder.btn_aperture_right, function()
    local value = self.uiBinder.slider_aperture.value + self.aperture_step_val_
    self.uiBinder.slider_aperture.value = value
  end)
  self:AddClick(self.uiBinder.btn_near_left, function()
    local value = self.uiBinder.slider_near_blend.value - self.near_blend_step_val_
    self.uiBinder.slider_near_blend.value = value
  end)
  self:AddClick(self.uiBinder.btn_near_right, function()
    local value = self.uiBinder.slider_near_blend.value + self.near_blend_step_val_
    self.uiBinder.slider_near_blend.value = value
  end)
  self:AddClick(self.uiBinder.btn_far_left, function()
    local value = self.uiBinder.slider_far_blend.value - self.far_blend_step_val_
    self.uiBinder.slider_far_blend.value = value
  end)
  self:AddClick(self.uiBinder.btn_far_right, function()
    local value = self.uiBinder.slider_far_blend.value + self.far_blend_step_val_
    self.uiBinder.slider_far_blend.value = value
  end)
  self:AddClick(self.uiBinder.btn_focus_left, function()
    local value = self.uiBinder.slider_focus.value - self.focus_step_val_
    self.uiBinder.slider_focus.value = value
  end)
  self:AddClick(self.uiBinder.btn_focus_right, function()
    local value = self.uiBinder.slider_focus.value + self.focus_step_val_
    self.uiBinder.slider_focus.value = value
  end)
end

function Camera_menu_container_shotset_sub_pcView:initSliderStepVal()
  self.horizontal_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Horizontal)
  self.vertical_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Vertical)
  self.angle_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.CameraTilt)
  self.fov_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Fov)
  self.aperture_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Aperture)
  self.near_blend_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Near)
  self.far_blend_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Far)
  self.focus_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Focus)
end

function Camera_menu_container_shotset_sub_pcView:initSwitchState()
  self.uiBinder.tog_focus:SetIsOnWithoutNotify(self.cameraData_.IsFocusTag)
  self.uiBinder.tog_depth.isOn = self.cameraData_.IsDepthTag
end

function Camera_menu_container_shotset_sub_pcView:OnRefresh()
  self:initSwitchState()
  self:refHVVariable()
  self:updateTog()
  self:SetDepthTog(self.tbDatarAperture_.isOpen)
  self:refreshSliderValue()
  self.cameraData_.MenuContainerShotsetDirty = false
end

function Camera_menu_container_shotset_sub_pcView:refreshSliderValue()
  if self.cameraData_.MenuContainerShotsetDirty then
    self.uiBinder.tog_depth.isOn = false
    self.uiBinder.tog_focus.isOn = false
    self.uiBinder.slider_aperture.value = self.cameraVM_.GetRangePerc(self.tbDatarAperture_, self.cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_near_blend.value = self.cameraVM_.GetRangePerc(self.nearBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_far_blend.value = self.cameraVM_.GetRangePerc(self.farBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_focus.value = self.cameraVM_.GetRangePerc(self.tbDatarFocus_, self.cameraData_.MenuContainerShotsetDirty)
  end
  if self.uiBinder.tog_depth.isOn then
    self.uiBinder.slider_aperture.value = self.cameraVM_.GetRangePerc(self.tbDatarAperture_, self.cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_near_blend.value = self.cameraVM_.GetRangePerc(self.nearBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_far_blend.value = self.cameraVM_.GetRangePerc(self.farBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
  end
  if self.uiBinder.tog_focus.isOn then
    self.uiBinder.slider_focus.value = self.cameraVM_.GetRangePerc(self.tbDatarFocus_, self.cameraData_.MenuContainerShotsetDirty)
  end
  self.uiBinder.slider_lens_horizontal.value = self.cameraVM_.GetRangePerc(self.tbDatarHorizontal_, self.cameraData_.MenuContainerShotsetDirty)
  self.uiBinder.slider_lens_vertical.value = self.cameraVM_.GetRangePerc(self.tbDatarVertical_, self.cameraData_.MenuContainerShotsetDirty)
  self.uiBinder.slider_lens_rotation.value = self.cameraVM_.GetRangePerc(self.tempAngle_, self.cameraData_.MenuContainerShotsetDirty)
  self.uiBinder.slider_visibility.value = self.cameraVM_.GetRangePerc(self.tempFov_, self.cameraData_.MenuContainerShotsetDirty)
  self:refreshSliderValueShowText()
  self:refreshDepthSliderIsEnable(self.uiBinder.tog_depth.isOn)
end

function Camera_menu_container_shotset_sub_pcView:refreshDepthSliderIsEnable(isEnable)
  self.uiBinder.node_canvas.interactable = isEnable
  self.uiBinder.node_canvas.alpha = isEnable and 1 or 0.5
  self.uiBinder.tog_focus.interactable = isEnable
  self.uiBinder.node_slider_focus.interactable = self.uiBinder.tog_focus.isOn
  self.uiBinder.node_slider_focus.alpha = self.uiBinder.tog_focus.isOn and 1 or 0.5
end

function Camera_menu_container_shotset_sub_pcView:refreshSliderValueShowText()
  self.uiBinder.aperture_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarAperture_.showValueMin, self.tbDatarAperture_.showValueMax, self.uiBinder.slider_aperture.value)
  self.uiBinder.lab_near_blend_val.text = self.cameraVM_.CalculatePercentageValue(self.nearBlendRange_.showValueMin, self.nearBlendRange_.showValueMax, self.uiBinder.slider_near_blend.value)
  self.uiBinder.lab_far_blend_val.text = self.cameraVM_.CalculatePercentageValue(self.farBlendRange_.showValueMin, self.farBlendRange_.showValueMax, self.uiBinder.slider_far_blend.value)
  self.uiBinder.focus_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarFocus_.showValueMin, self.tbDatarFocus_.showValueMax, self.uiBinder.slider_focus.value)
  self.uiBinder.horizontal_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarHorizontal_.showValueMin, self.tbDatarHorizontal_.showValueMax, self.uiBinder.slider_lens_horizontal.value)
  self.uiBinder.vertical_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarVertical_.showValueMin, self.tbDatarVertical_.showValueMax, self.uiBinder.slider_lens_vertical.value)
  self.uiBinder.lab_rotation_val.text = self.cameraVM_.CalculatePercentageValue(self.tempAngle_.showValueMin, self.tempAngle_.showValueMax, self.uiBinder.slider_lens_rotation.value)
  self.uiBinder.lab_fov_val.text = self.cameraVM_.CalculatePercentageValue(self.tempFov_.showValueMin, self.tempFov_.showValueMax, self.uiBinder.slider_visibility.value)
end

function Camera_menu_container_shotset_sub_pcView:updateTog()
  local typeShow = false
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    typeShow = true
  end
  self.uiBinder.node_vertical_slider.interactable = typeShow
  self.uiBinder.node_vertical_slider.alpha = typeShow and 1 or 0.5
  self.uiBinder.node_horizontal_slider.interactable = typeShow
  self.uiBinder.node_horizontal_slider.alpha = typeShow and 1 or 0.5
end

function Camera_menu_container_shotset_sub_pcView:ResetBtn()
  self.uiBinder.slider_lens_rotation.value = self.cameraVM_.GetRangeDefinePerc(self.tempAngle_)
  self.uiBinder.slider_visibility.value = self.cameraVM_.GetRangeDefinePerc(self.tempAngle_)
  self.uiBinder.slider_lens_horizontal.value = self.cameraVM_.GetRangeDefinePerc(self.tbDatarHorizontal_)
  self.uiBinder.slider_lens_vertical.value = self.cameraVM_.GetRangeDefinePerc(self.tbDatarVertical_)
  self.uiBinder.slider_aperture.value = self.cameraVM_.GetRangePerc(self.tbDatarAperture_, true)
  self.uiBinder.slider_near_blend.value = self.cameraVM_.GetRangePerc(self.nearBlendRange_, true)
  self.uiBinder.slider_far_blend.value = self.cameraVM_.GetRangePerc(self.farBlendRange_, true)
  self.uiBinder.tog_depth.isOn = false
  self.uiBinder.tog_focus.isOn = false
  self.uiBinder.slider_focus.value = self.cameraVM_.GetRangePerc(self.tbDatarFocus_, true)
  self.tempFov_ = self.cameraData_:GetCurCameraFovRange()
  self.uiBinder.slider_visibility.value = self.cameraVM_.GetRangePerc(self.tempFov_, true)
end

function Camera_menu_container_shotset_sub_pcView:SetAngle(value)
  Z.CameraFrameCtrl:SetAngle(value)
end

function Camera_menu_container_shotset_sub_pcView:SetVertical(value)
  Z.CameraFrameCtrl:SetVertical(value)
end

function Camera_menu_container_shotset_sub_pcView:SetHorizontal(value)
  Z.CameraFrameCtrl:SetHorizontal(value)
end

function Camera_menu_container_shotset_sub_pcView:SetFocus(value)
  Z.CameraFrameCtrl:SetFocus(value)
end

function Camera_menu_container_shotset_sub_pcView:SetFocusTog(value)
  if not value and Z.EntityMgr.PlayerEnt then
    local playerPosX, playerPosY, playerPosZ = self.cameraVM_.GetPlayerPos()
    self:SetFocusTargetPos(playerPosX, playerPosY, playerPosZ)
    Z.CameraFrameCtrl:SetFocusTog(value)
  else
    Z.CameraFrameCtrl:SetFocusTog(not value)
    self:SetFocus(self.tbDatarFocus_.value)
  end
end

function Camera_menu_container_shotset_sub_pcView:SetFocusTargetPos(x, y, z)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetFocusTargetPos(x, y, z)
end

function Camera_menu_container_shotset_sub_pcView:SetIsFocusTarget(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetIsFocusTarget(value)
end

function Camera_menu_container_shotset_sub_pcView:SetDepthTog(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetDepthTog(value)
end

function Camera_menu_container_shotset_sub_pcView:SetAperture(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetAperture(value)
end

function Camera_menu_container_shotset_sub_pcView:SetNearBlend(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetNearBlend(value)
end

function Camera_menu_container_shotset_sub_pcView:SetFarBlend(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetFarBlend(value)
end

function Camera_menu_container_shotset_sub_pcView:updateFovRange()
  self.tempFov_ = self.cameraData_:GetCurCameraFovRange()
  local isEnable = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.SelfPhoto and self.cameraData_.CameraPatternType ~= E.TakePhotoSate.AR
  self.uiBinder.node_rotation_slider.interactable = isEnable
  self.uiBinder.node_rotation_slider.alpha = isEnable and 1 or 0.5
  self.uiBinder.slider_lens_rotation.value = self.cameraVM_.GetRangePerc(self.tempAngle_, not isEnable)
end

function Camera_menu_container_shotset_sub_pcView:initListener()
  self:AddClick(self.uiBinder.btn_reset, function()
    self.cameraData_:SetIsSchemeParamUpdated(true)
    self:ResetBtn()
  end)
  self.uiBinder.slider_aperture:RemoveAllListeners()
  self.uiBinder.slider_aperture:AddListener(function(value)
    self:setApertureVal(value)
  end)
  self.uiBinder.slider_near_blend:RemoveAllListeners()
  self.uiBinder.slider_near_blend:AddListener(function(value)
    self:setNearBlendVal(value)
  end)
  self.uiBinder.slider_far_blend:RemoveAllListeners()
  self.uiBinder.slider_far_blend:AddListener(function(value)
    self:setFarBlendVal(value)
  end)
  self.uiBinder.tog_depth:RemoveAllListeners()
  self.uiBinder.tog_depth:AddListener(function(isOn)
    self.cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarAperture_ = self.cameraData_:GetDOFApertureFactorRange()
    self.tbDatarAperture_.isOpen = isOn
    self:SetDepthTog(self.tbDatarAperture_.isOpen)
    if isOn then
      self.uiBinder.slider_aperture.value = self.cameraVM_.GetRangePerc(self.tbDatarAperture_, self.cameraData_.MenuContainerShotsetDirty)
      self.tbDatarAperture_.value = self.cameraVM_.GetRangeValue(self.uiBinder.slider_aperture.value, self.tbDatarAperture_)
      self:SetAperture(self.tbDatarAperture_.value)
      self.uiBinder.slider_near_blend.value = self.cameraVM_.GetRangePerc(self.nearBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
      self.nearBlendRange_.value = self.cameraVM_.GetRangeValue(self.uiBinder.slider_near_blend.value, self.nearBlendRange_)
      self:SetNearBlend(self.nearBlendRange_.value)
      self.uiBinder.slider_far_blend.value = self.cameraVM_.GetRangePerc(self.farBlendRange_, self.cameraData_.MenuContainerShotsetDirty)
      self.farBlendRange_.value = self.cameraVM_.GetRangeValue(self.uiBinder.slider_far_blend.value, self.farBlendRange_)
      self:SetFarBlend(self.farBlendRange_.value)
      if not self.uiBinder.tog_focus.isOn then
        self:SetIsFocusTarget(not self.uiBinder.tog_focus.isOn)
        if Z.EntityMgr.PlayerEnt then
          local playerPosX, playerPosY, playerPosZ = self.cameraVM_.GetPlayerPos()
          self:SetFocusTargetPos(playerPosX, playerPosY, playerPosZ)
        end
      end
    end
    self.cameraData_.IsDepthTag = isOn
    self:refreshDepthSliderIsEnable(isOn)
  end)
  self.uiBinder.tog_focus:RemoveAllListeners()
  self.uiBinder.tog_focus:AddListener(function(isOn)
    self.cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarFocus_.isOpen = isOn
    self:SetIsFocusTarget(not isOn)
    if isOn then
      self.uiBinder.slider_focus.value = self.cameraVM_.GetRangePerc(self.tbDatarFocus_, self.cameraData_.MenuContainerShotsetDirty)
      self.tbDatarFocus_.value = self.cameraVM_.GetRangeValue(self.uiBinder.slider_focus.value, self.tbDatarFocus_)
      self:SetFocus(self.tbDatarFocus_.value)
    end
    self.uiBinder.node_slider_focus.interactable = isOn
    self.uiBinder.node_slider_focus.alpha = isOn and 1 or 0.5
    self.cameraData_.IsFocusTag = isOn
    self:SetFocusTog(self.tbDatarFocus_.isOpen)
    self.uiBinder.slider_focus.interactable = isOn
  end)
  self.uiBinder.slider_focus:RemoveAllListeners()
  self.uiBinder.slider_focus:AddListener(function(value)
    self:setFocusVal(value)
  end)
  self.uiBinder.slider_lens_horizontal:RemoveAllListeners()
  self.uiBinder.slider_lens_horizontal:AddListener(function(value)
    self:setHorizontalVal(value)
  end)
  self.uiBinder.slider_lens_vertical:RemoveAllListeners()
  self.uiBinder.slider_lens_vertical:AddListener(function(value)
    self:setVerticalVal(value)
  end)
  self.uiBinder.slider_lens_rotation:RemoveAllListeners()
  self.uiBinder.slider_lens_rotation:AddListener(function(value)
    self:setRotationVal(value)
  end)
  self.uiBinder.slider_visibility:RemoveAllListeners()
  self.uiBinder.slider_visibility:AddListener(function(value)
    self:setVisibilityVal(value)
  end)
  self:initSliderBtn()
end

function Camera_menu_container_shotset_sub_pcView:setHorizontalVal(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  local horizontal
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    horizontal = self.cameraData_:GetCameraSelfHorizontalRange()
  else
    horizontal = self.cameraData_:GetCameraHorizontalRange()
  end
  horizontal.value = self.cameraVM_.GetRangeValue(value, horizontal)
  self.uiBinder.horizontal_lab_num.text = self.cameraVM_.CalculatePercentageValue(horizontal.showValueMin, horizontal.showValueMax, value)
  self:SetHorizontal(horizontal.value)
end

function Camera_menu_container_shotset_sub_pcView:setVerticalVal(value)
  self.cameraData_:SetIsSchemeParamUpdated(true)
  local vertical
  if self.cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    vertical = self.cameraData_:GetCameraSelfVerticalRange()
  else
    vertical = self.cameraData_:GetCameraVerticalRange()
  end
  vertical.value = self.cameraVM_.GetRangeValue(value, vertical)
  self.uiBinder.vertical_lab_num.text = self.cameraVM_.CalculatePercentageValue(vertical.showValueMin, vertical.showValueMax, value)
  self:SetVertical(vertical.value)
end

function Camera_menu_container_shotset_sub_pcView:setVisibilityVal(value)
  self.tempFov_.value = self.cameraVM_.GetRangeValue(value, self.tempFov_)
  self.uiBinder.lab_fov_val.text = self.cameraVM_.CalculatePercentageValue(self.tempFov_.showValueMin, self.tempFov_.showValueMax, value)
  Z.CameraFrameCtrl:SetCameraSize(self.tempFov_.value)
end

function Camera_menu_container_shotset_sub_pcView:setRotationVal(value)
  self.tempAngle_.value = self.cameraVM_.GetRangeValue(value, self.tempAngle_)
  self.uiBinder.lab_rotation_val.text = self.cameraVM_.CalculatePercentageValue(self.tempAngle_.showValueMin, self.tempAngle_.showValueMax, value)
  Z.CameraFrameCtrl:SetAngle(self.tempAngle_.value)
end

function Camera_menu_container_shotset_sub_pcView:setFocusVal(value)
  if not self.uiBinder.tog_focus.isOn then
    return
  end
  self.cameraData_:SetIsSchemeParamUpdated(true)
  self.tbDatarFocus_.value = self.cameraVM_.GetRangeValue(value, self.tbDatarFocus_)
  self.uiBinder.focus_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarFocus_.showValueMin, self.tbDatarFocus_.showValueMax, value)
  self:SetFocus(self.tbDatarFocus_.value)
end

function Camera_menu_container_shotset_sub_pcView:setFarBlendVal(value)
  if not self.uiBinder.tog_depth.isOn then
    return
  end
  self.cameraData_:SetIsSchemeParamUpdated(true)
  self.farBlendRange_.value = self.cameraVM_.GetRangeValue(value, self.farBlendRange_)
  self.uiBinder.lab_far_blend_val.text = self.cameraVM_.CalculatePercentageValue(self.farBlendRange_.showValueMin, self.farBlendRange_.showValueMax, value)
  self:SetFarBlend(self.farBlendRange_.value)
end

function Camera_menu_container_shotset_sub_pcView:setNearBlendVal(value)
  if not self.uiBinder.tog_depth.isOn then
    return
  end
  self.cameraData_:SetIsSchemeParamUpdated(true)
  self.nearBlendRange_.value = self.cameraVM_.GetRangeValue(value, self.nearBlendRange_)
  self.uiBinder.lab_near_blend_val.text = self.cameraVM_.CalculatePercentageValue(self.nearBlendRange_.showValueMin, self.nearBlendRange_.showValueMax, value)
  self:SetNearBlend(self.nearBlendRange_.value)
end

function Camera_menu_container_shotset_sub_pcView:setApertureVal(value)
  if not self.uiBinder.tog_depth.isOn then
    return
  end
  self.cameraData_:SetIsSchemeParamUpdated(true)
  self.tbDatarAperture_.value = self.cameraVM_.GetRangeValue(value, self.tbDatarAperture_)
  self.uiBinder.aperture_lab_num.text = self.cameraVM_.CalculatePercentageValue(self.tbDatarAperture_.showValueMin, self.tbDatarAperture_.showValueMax, value)
  self:SetAperture(self.tbDatarAperture_.value)
end

return Camera_menu_container_shotset_sub_pcView
