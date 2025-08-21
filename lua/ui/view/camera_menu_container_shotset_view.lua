local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_shotsetView = class("Camera_menu_container_shotsetView", super)
local cameraData_ = Z.DataMgr.Get("camerasys_data")
local vm = Z.VMMgr.GetVM("camerasys")

function Camera_menu_container_shotsetView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_shotset_sub", "photograph/camera_menu_container_shotset_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.dayAndNightMaxTime = 24
end

function Camera_menu_container_shotsetView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self:initZWidget()
  self:initVariable()
  self:checkFuncSwitch()
  self:initListener()
end

function Camera_menu_container_shotsetView:initZWidget()
  self.dayAndNightNode_ = self.uiBinder.node_weather
  self.dayAndNightSwitch_ = self.uiBinder.switch_weather
  self.dayAndNightSlider = self.uiBinder.slider_weather
end

function Camera_menu_container_shotsetView:initVariable()
  self.isUseDefine_ = true
  self.depthFuncId_ = 102007
  self.tbDatarAperture_ = cameraData_:GetDOFApertureFactorRange()
  self.tbDatarFocus_ = cameraData_:GetDOFFocalLengthRange()
  self.tbDatarAngle_ = cameraData_:GetCameraAngleRange()
  self.nearBlendRange_ = cameraData_:GetNearBlendRange()
  self.farBlendRange_ = cameraData_:GetFarBlendRange()
end

function Camera_menu_container_shotsetView:refHVVariable()
  if cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    self.tbDatarHorizontal_ = cameraData_:GetCameraSelfHorizontalRange()
    self.tbDatarVertical_ = cameraData_:GetCameraSelfVerticalRange()
  else
    self.tbDatarHorizontal_ = cameraData_:GetCameraHorizontalRange()
    self.tbDatarVertical_ = cameraData_:GetCameraVerticalRange()
  end
end

function Camera_menu_container_shotsetView:checkFuncSwitch()
  local switchVM = Z.VMMgr.GetVM("switch")
  local isDepth = switchVM.CheckFuncSwitch(self.depthFuncId_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_camera_setting_extra, isDepth)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_depth, not isDepth)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_setting_switch_depth, isDepth)
end

function Camera_menu_container_shotsetView:initListener()
  self:AddClick(self.uiBinder.btn_reset, function()
    cameraData_:SetIsSchemeParamUpdated(true)
    self:ResetBtn()
  end)
  self.uiBinder.slider_aperture:AddListener(function(value)
    if not self.uiBinder.switch_depth.IsOn then
      return
    end
    cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarAperture_.value = vm.GetRangeValue(value, self.tbDatarAperture_)
    self.uiBinder.aperture_lab_num.text = vm.CalculatePercentageValue(self.tbDatarAperture_.showValueMin, self.tbDatarAperture_.showValueMax, value)
    self:SetAperture(self.tbDatarAperture_.value)
  end)
  self.uiBinder.slider_near_blend:AddListener(function(value)
    if not self.uiBinder.switch_depth.IsOn then
      return
    end
    cameraData_:SetIsSchemeParamUpdated(true)
    self.nearBlendRange_.value = vm.GetRangeValue(value, self.nearBlendRange_)
    self.uiBinder.lab_near_blend_val.text = vm.CalculatePercentageValue(self.nearBlendRange_.showValueMin, self.nearBlendRange_.showValueMax, value)
    self:SetNearBlend(self.nearBlendRange_.value)
  end)
  self.uiBinder.slider_far_blend:AddListener(function(value)
    if not self.uiBinder.switch_depth.IsOn then
      return
    end
    cameraData_:SetIsSchemeParamUpdated(true)
    self.farBlendRange_.value = vm.GetRangeValue(value, self.farBlendRange_)
    self.uiBinder.lab_far_blend_val.text = vm.CalculatePercentageValue(self.farBlendRange_.showValueMin, self.farBlendRange_.showValueMax, value)
    self:SetFarBlend(self.farBlendRange_.value)
  end)
  self.uiBinder.switch_depth:AddListener(function(isOn)
    cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarAperture_ = cameraData_:GetDOFApertureFactorRange()
    self.tbDatarAperture_.isOpen = isOn
    self:SetDepthTog(self.tbDatarAperture_.isOpen)
    if isOn then
      self.uiBinder.slider_aperture.value = vm.GetRangePerc(self.tbDatarAperture_, cameraData_.MenuContainerShotsetDirty)
      self.tbDatarAperture_.value = vm.GetRangeValue(self.uiBinder.slider_aperture.value, self.tbDatarAperture_)
      self:SetAperture(self.tbDatarAperture_.value)
      self.uiBinder.slider_near_blend.value = vm.GetRangePerc(self.nearBlendRange_, cameraData_.MenuContainerShotsetDirty)
      self.nearBlendRange_.value = vm.GetRangeValue(self.uiBinder.slider_near_blend.value, self.nearBlendRange_)
      self:SetNearBlend(self.nearBlendRange_.value)
      self.uiBinder.slider_far_blend.value = vm.GetRangePerc(self.farBlendRange_, cameraData_.MenuContainerShotsetDirty)
      self.farBlendRange_.value = vm.GetRangeValue(self.uiBinder.slider_far_blend.value, self.farBlendRange_)
      self:SetFarBlend(self.farBlendRange_.value)
      if not self.uiBinder.switch_focus.IsOn then
        self:SetIsFocusTarget(not self.uiBinder.switch_focus.IsOn)
        if Z.EntityMgr.PlayerEnt then
          local playerPos_ = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
          self:SetFocusTargetPos(playerPos_.x, playerPos_.y, playerPos_.z)
        end
      end
      self.uiBinder.layout_node:ForceRebuildLayoutImmediate()
    end
    cameraData_.IsDepthTag = isOn
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_depth, not self.tbDatarAperture_.isOpen)
    self.uiBinder.Ref:SetVisible(self.uiBinder.layout_camera_setting_extra, self.tbDatarAperture_.isOpen)
  end)
  self.uiBinder.switch_focus:AddListener(function(isOn)
    cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarFocus_.isOpen = isOn
    self:SetIsFocusTarget(not isOn)
    if isOn then
      self.uiBinder.slider_focus.value = vm.GetRangePerc(self.tbDatarFocus_, cameraData_.MenuContainerShotsetDirty)
      self.tbDatarFocus_.value = vm.GetRangeValue(self.uiBinder.slider_focus.value, self.tbDatarFocus_)
      self:SetFocus(self.tbDatarFocus_.value)
    end
    cameraData_.IsFocusTag = isOn
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_focus, self.tbDatarFocus_.isOpen)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_focus_line, self.tbDatarFocus_.isOpen)
    self:SetFocusTog(self.tbDatarFocus_.isOpen)
    self.uiBinder.layout_node:ForceRebuildLayoutImmediate()
  end)
  self.uiBinder.slider_focus:AddListener(function(value)
    if not self.uiBinder.switch_focus.IsOn then
      return
    end
    cameraData_:SetIsSchemeParamUpdated(true)
    self.tbDatarFocus_.value = vm.GetRangeValue(value, self.tbDatarFocus_)
    self.uiBinder.focus_lab_num.text = vm.CalculatePercentageValue(self.tbDatarFocus_.showValueMin, self.tbDatarFocus_.showValueMax, value)
    self:SetFocus(self.tbDatarFocus_.value)
  end)
  self.uiBinder.slider_horizontal:AddListener(function(value)
    cameraData_:SetIsSchemeParamUpdated(true)
    local horizontal
    if cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
      horizontal = cameraData_:GetCameraSelfHorizontalRange()
    else
      horizontal = cameraData_:GetCameraHorizontalRange()
    end
    horizontal.value = vm.GetRangeValue(value, horizontal)
    self.uiBinder.horizontal_lab_num.text = vm.CalculatePercentageValue(horizontal.showValueMin, horizontal.showValueMax, value)
    self:SetHorizontal(horizontal.value)
  end)
  self.uiBinder.slider_vertical:AddListener(function(value)
    cameraData_:SetIsSchemeParamUpdated(true)
    local vertical
    if cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
      vertical = cameraData_:GetCameraSelfVerticalRange()
    else
      vertical = cameraData_:GetCameraVerticalRange()
    end
    vertical.value = vm.GetRangeValue(value, vertical)
    self.uiBinder.vertical_lab_num.text = vm.CalculatePercentageValue(vertical.showValueMin, vertical.showValueMax, value)
    self:SetVertical(vertical.value)
  end)
  self.dayAndNightSwitch_:AddListener(function(isOn)
    cameraData_:SetIsSchemeParamUpdated(true)
    self.uiBinder.Ref:SetVisible(self.dayAndNightNode_, isOn)
    vm.IsUpdateWeatherByServer(not isOn)
    if isOn then
      local currentTime = Z.LuaBridge.GetCurWeatherTime24()
      if not currentTime then
        return
      end
      self.dayAndNightSlider.value = currentTime / self.dayAndNightMaxTime
    else
      cameraData_.WorldTime = -1
    end
    self.uiBinder.layout_weather_node:ForceRebuildLayoutImmediate()
  end)
  self.dayAndNightSlider:AddListener(function(value)
    cameraData_:SetIsSchemeParamUpdated(true)
    local resultTime = value * self.dayAndNightMaxTime
    self.uiBinder.time_lab_num.text = math.floor(resultTime)
    cameraData_.WorldTime = resultTime
    Z.LuaBridge.SetCurWeatherTime(resultTime)
  end)
end

function Camera_menu_container_shotsetView:initSwitchState()
  self.uiBinder.switch_focus:SetIsOnWithoutNotify(cameraData_.IsFocusTag)
  self.uiBinder.switch_depth.IsOn = cameraData_.IsDepthTag
  self.dayAndNightSwitch_.IsOn = cameraData_.WorldTime ~= -1
end

function Camera_menu_container_shotsetView:OnDeActive()
end

function Camera_menu_container_shotsetView:OnRefresh()
  self:initSwitchState()
  self:refHVVariable()
  self:UpdateTog()
  self:SetDepthTog(self.tbDatarAperture_.isOpen)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_focus, self.uiBinder.switch_focus.IsOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_focus_line, self.uiBinder.switch_focus.IsOn)
  self:refreshSliderValue()
  cameraData_.MenuContainerShotsetDirty = false
end

function Camera_menu_container_shotsetView:refreshSliderValue()
  if cameraData_.MenuContainerShotsetDirty then
    self.uiBinder.switch_depth.IsOn = false
    self.dayAndNightSwitch_.IsOn = false
    self.uiBinder.switch_focus.IsOn = false
    self.uiBinder.slider_aperture.value = vm.GetRangePerc(self.tbDatarAperture_, cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_near_blend.value = vm.GetRangePerc(self.nearBlendRange_, cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_far_blend.value = vm.GetRangePerc(self.farBlendRange_, cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_focus.value = vm.GetRangePerc(self.tbDatarFocus_, cameraData_.MenuContainerShotsetDirty)
  end
  if self.uiBinder.switch_depth.IsOn then
    self.uiBinder.slider_aperture.value = vm.GetRangePerc(self.tbDatarAperture_, cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_near_blend.value = vm.GetRangePerc(self.nearBlendRange_, cameraData_.MenuContainerShotsetDirty)
    self.uiBinder.slider_far_blend.value = vm.GetRangePerc(self.farBlendRange_, cameraData_.MenuContainerShotsetDirty)
  end
  if self.uiBinder.switch_focus.IsOn then
    self.uiBinder.slider_focus.value = vm.GetRangePerc(self.tbDatarFocus_, cameraData_.MenuContainerShotsetDirty)
  end
  self.uiBinder.slider_horizontal.value = vm.GetRangePerc(self.tbDatarHorizontal_, cameraData_.MenuContainerShotsetDirty)
  self.uiBinder.slider_vertical.value = vm.GetRangePerc(self.tbDatarVertical_, cameraData_.MenuContainerShotsetDirty)
  if cameraData_.WorldTime then
    if self.dayAndNightSwitch_.IsOn then
      self.dayAndNightSlider.value = cameraData_.WorldTime / self.dayAndNightMaxTime
      self.uiBinder.time_lab_num.text = math.floor(cameraData_.WorldTime)
    end
  else
    self.dayAndNightSwitch_.IsOn = false
  end
  self:refreshSliderValueShowText()
end

function Camera_menu_container_shotsetView:refreshSliderValueShowText()
  self.uiBinder.aperture_lab_num.text = vm.CalculatePercentageValue(self.tbDatarAperture_.showValueMin, self.tbDatarAperture_.showValueMax, self.uiBinder.slider_aperture.value)
  self.uiBinder.lab_near_blend_val.text = vm.CalculatePercentageValue(self.nearBlendRange_.showValueMin, self.nearBlendRange_.showValueMax, self.uiBinder.slider_near_blend.value)
  self.uiBinder.lab_far_blend_val.text = vm.CalculatePercentageValue(self.farBlendRange_.showValueMin, self.farBlendRange_.showValueMax, self.uiBinder.slider_far_blend.value)
  self.uiBinder.focus_lab_num.text = vm.CalculatePercentageValue(self.tbDatarFocus_.showValueMin, self.tbDatarFocus_.showValueMax, self.uiBinder.slider_focus.value)
  self.uiBinder.horizontal_lab_num.text = vm.CalculatePercentageValue(self.tbDatarHorizontal_.showValueMin, self.tbDatarHorizontal_.showValueMax, self.uiBinder.slider_horizontal.value)
  self.uiBinder.vertical_lab_num.text = vm.CalculatePercentageValue(self.tbDatarVertical_.showValueMin, self.tbDatarVertical_.showValueMax, self.uiBinder.slider_vertical.value)
end

function Camera_menu_container_shotsetView:UpdateTog()
  local typeShow = false
  local tyangleShow = false
  if cameraData_.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    typeShow = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_horizontal, typeShow)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_vertical, typeShow)
  if cameraData_.CameraPatternType == E.TakePhotoSate.Default then
    tyangleShow = true
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line_depth, not self.uiBinder.switch_depth.IsOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_camera_setting_extra, self.uiBinder.switch_depth.IsOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_focus, self.uiBinder.switch_focus.IsOn)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_focus_line, self.uiBinder.switch_focus.IsOn)
  self.uiBinder.Ref:SetVisible(self.dayAndNightNode_, self.dayAndNightSwitch_.IsOn)
  if cameraData_.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    self.uiBinder.Ref:SetVisible(self.dayAndNightNode_, false)
  end
end

function Camera_menu_container_shotsetView:ResetBtn()
  self.uiBinder.slider_horizontal.value = vm.GetRangeDefinePerc(self.tbDatarHorizontal_)
  self.uiBinder.slider_vertical.value = vm.GetRangeDefinePerc(self.tbDatarVertical_)
  self.uiBinder.slider_aperture.value = vm.GetRangePerc(self.tbDatarAperture_, true)
  self.uiBinder.slider_near_blend.value = vm.GetRangePerc(self.nearBlendRange_, true)
  self.uiBinder.slider_far_blend.value = vm.GetRangePerc(self.farBlendRange_, true)
  self.uiBinder.switch_depth.IsOn = false
  self.uiBinder.switch_focus.IsOn = false
  self.uiBinder.slider_focus.value = vm.GetRangePerc(self.tbDatarFocus_, true)
  self.dayAndNightSwitch_.IsOn = false
end

function Camera_menu_container_shotsetView:SetAngle(value)
  Z.CameraFrameCtrl:SetAngle(value)
end

function Camera_menu_container_shotsetView:SetVertical(value)
  Z.CameraFrameCtrl:SetVertical(value)
end

function Camera_menu_container_shotsetView:SetHorizontal(value)
  Z.CameraFrameCtrl:SetHorizontal(value)
end

function Camera_menu_container_shotsetView:SetFocus(value)
  Z.CameraFrameCtrl:SetFocus(value)
end

function Camera_menu_container_shotsetView:SetFocusTog(value)
  if not value and Z.EntityMgr.PlayerEnt then
    local playerPos = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
    self:SetFocusTargetPos(playerPos.x, playerPos.y, playerPos.z)
    Z.CameraFrameCtrl:SetFocusTog(value)
  else
    Z.CameraFrameCtrl:SetFocusTog(not value)
    self:SetFocus(self.tbDatarFocus_.value)
  end
end

function Camera_menu_container_shotsetView:SetFocusTargetPos(x, y, z)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetFocusTargetPos(x, y, z)
end

function Camera_menu_container_shotsetView:SetIsFocusTarget(value)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetIsFocusTarget(value)
end

function Camera_menu_container_shotsetView:SetDepthTog(value)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetDepthTog(value)
end

function Camera_menu_container_shotsetView:SetAperture(value)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetAperture(value)
end

function Camera_menu_container_shotsetView:SetNearBlend(value)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetNearBlend(value)
end

function Camera_menu_container_shotsetView:SetFarBlend(value)
  cameraData_:SetIsSchemeParamUpdated(true)
  Z.CameraFrameCtrl:SetFarBlend(value)
end

return Camera_menu_container_shotsetView
