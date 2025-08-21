local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_moviescreen_sub_pcView = class("Camera_menu_container_moviescreen_sub_pcView", super)

function Camera_menu_container_moviescreen_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_moviescreen_sub_pc", "photograph_pc/camera_menu_container_moviescreen_sub_pc", UI.ECacheLv.None)
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
  self.dayAndNightMaxTime_ = 24
  self.tbData_exposure = self.cameraData_:GetScreenBrightnessRange()
  self.tbData_contrast = self.cameraData_:GetScreenContrastRange()
  self.tbData_saturation = self.cameraData_:GetScreenSaturationRange()
end

function Camera_menu_container_moviescreen_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:initSliderStepVal()
  self.uiBinder.slider_exposure_adjust:AddListener(function(val)
    local value = self.cameraVM_.GetRangeValue(val, self.tbData_exposure)
    self.uiBinder.lab_exposure_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, val)
    if self.isToEditing_ then
      self.secondaryData_:GetMoviescreenData().exposure = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Exposure, value)
      self.secondaryData_:GetMoviescreenData().exposure = value
    else
      self.cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_exposure.value = value
      Z.CameraFrameCtrl:SetExposure(self.tbData_exposure.value)
      self.decorateData_:GetMoviescreenData().exposure = self.tbData_exposure.value
    end
  end)
  self.uiBinder.slider_constrast_adjust:AddListener(function(val)
    local value = self.cameraVM_.GetRangeValue(val, self.tbData_contrast)
    self.uiBinder.lab_constrast_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, val)
    if self.isToEditing_ then
      self.secondaryData_:GetMoviescreenData().contrast = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Contrast, value)
      self.secondaryData_:GetMoviescreenData().contrast = value
    else
      self.cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_contrast.value = value
      Z.CameraFrameCtrl:SetContrast(self.tbData_contrast.value)
      self.decorateData_:GetMoviescreenData().contrast = self.tbData_contrast.value
    end
  end)
  self.uiBinder.slider_saturation_adjust:AddListener(function(val)
    local value = self.cameraVM_.GetRangeValue(val, self.tbData_saturation)
    self.uiBinder.lab_saturation_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, val)
    if self.isToEditing_ then
      self.secondaryData_:GetMoviescreenData().saturation = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Saturation, value)
      self.secondaryData_:GetMoviescreenData().saturation = value
    else
      self.cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_saturation.value = value
      Z.CameraFrameCtrl:SetSaturation(self.tbData_saturation.value)
      self.decorateData_:GetMoviescreenData().saturation = self.tbData_saturation.value
    end
  end)
  self:AddClick(self.uiBinder.btn_reset, function()
    local tbData_exposure = {}
    local tbData_contrast = {}
    local tbData_saturation = {}
    tbData_exposure = self.cameraData_:GetScreenBrightnessRange()
    tbData_contrast = self.cameraData_:GetScreenContrastRange()
    tbData_saturation = self.cameraData_:GetScreenSaturationRange()
    self.uiBinder.tog_time.isOn = false
    if self.isToEditing_ then
      local tbData_exposureTemp = self.cameraData_:GetTempRange(tbData_exposure)
      local tbData_contrastTemp = self.cameraData_:GetTempRange(tbData_contrast)
      local tbData_saturationTemp = self.cameraData_:GetTempRange(tbData_saturation)
      tbData_exposureTemp.value = self.secondaryData_:GetMoviescreenOriData().exposure
      tbData_contrastTemp.value = self.secondaryData_:GetMoviescreenOriData().contrast
      tbData_saturationTemp.value = self.secondaryData_:GetMoviescreenOriData().saturation
      self.uiBinder.slider_exposure_adjust.value = self.cameraVM_.GetRangePerc(tbData_exposureTemp, false)
      self.uiBinder.slider_constrast_adjust.value = self.cameraVM_.GetRangePerc(tbData_contrastTemp, false)
      self.uiBinder.slider_saturation_adjust.value = self.cameraVM_.GetRangePerc(tbData_saturationTemp, false)
    else
      self.uiBinder.slider_exposure_adjust.value = self.cameraVM_.GetRangePerc(tbData_exposure, true)
      self.uiBinder.slider_constrast_adjust.value = self.cameraVM_.GetRangePerc(tbData_contrast, true)
      self.uiBinder.slider_saturation_adjust.value = self.cameraVM_.GetRangePerc(tbData_saturation, true)
      self.cameraData_:SetIsSchemeParamUpdated(true)
    end
  end)
  self.uiBinder.tog_time:AddListener(function(isOn)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_time, isOn)
    self.cameraData_:SetIsSchemeParamUpdated(true)
    self.cameraVM_.IsUpdateWeatherByServer(not isOn)
    if isOn then
      local currentTime = Z.LuaBridge.GetCurWeatherTime24()
      if not currentTime then
        return
      end
      self.uiBinder.slider_time.value = currentTime / self.dayAndNightMaxTime_
    else
      self.cameraData_.WorldTime = -1
    end
  end)
  self.uiBinder.slider_time:AddListener(function(value)
    self.cameraData_:SetIsSchemeParamUpdated(true)
    local resultTime = value * self.dayAndNightMaxTime_
    self.uiBinder.lab_time.text = math.floor(resultTime)
    self.cameraData_.WorldTime = resultTime
    Z.LuaBridge.SetCurWeatherTime(resultTime)
  end)
  self:initSliderBtn()
  self.uiBinder.tog_time.isOn = self.cameraData_.WorldTime ~= -1
end

function Camera_menu_container_moviescreen_sub_pcView:OnDeActive()
end

function Camera_menu_container_moviescreen_sub_pcView:initSliderStepVal()
  self.exposure_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Brightness)
  self.saturation_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Saturation)
  self.contrast_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.Contrast)
  self.time_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.DayTime)
end

function Camera_menu_container_moviescreen_sub_pcView:initSliderBtn()
  self:AddClick(self.uiBinder.btn_exposure_left, function()
    local value = self.uiBinder.slider_exposure_adjust.value - self.exposure_step_val_
    self.uiBinder.slider_exposure_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_exposure_right, function()
    local value = self.uiBinder.slider_exposure_adjust.value + self.exposure_step_val_
    self.uiBinder.slider_exposure_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_constrast_left, function()
    local value = self.uiBinder.slider_constrast_adjust.value - self.contrast_step_val_
    self.uiBinder.slider_constrast_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_constrast_right, function()
    local value = self.uiBinder.slider_constrast_adjust.value + self.contrast_step_val_
    self.uiBinder.slider_constrast_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_saturation_left, function()
    local value = self.uiBinder.slider_saturation_adjust.value - self.saturation_step_val_
    self.uiBinder.slider_saturation_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_saturation_right, function()
    local value = self.uiBinder.slider_saturation_adjust.value + self.saturation_step_val_
    self.uiBinder.slider_saturation_adjust.value = value
  end)
  self:AddClick(self.uiBinder.btn_time_left, function()
    local value = self.uiBinder.slider_time.value - self.time_step_val_
    self.uiBinder.slider_time.value = value
  end)
  self:AddClick(self.uiBinder.btn_time_right, function()
    local value = self.uiBinder.slider_time.value + self.time_step_val_
    self.uiBinder.slider_time.value = value
  end)
end

function Camera_menu_container_moviescreen_sub_pcView:OnRefresh()
  if not self.viewData then
    self.isToEditing_ = false
  else
    self.isToEditing_ = self.viewData.isToEditing
    self.viewData = {}
  end
  if self.isToEditing_ then
    local tbData_exposureTemp = self.cameraData_:GetTempRange(self.tbData_exposure)
    local tbData_contrastTemp = self.cameraData_:GetTempRange(self.tbData_contrast)
    local tbData_saturationTemp = self.cameraData_:GetTempRange(self.tbData_saturation)
    if self.cameraData_.SecondEditMoviescreenDirty then
      tbData_exposureTemp.value = self.secondaryData_:GetMoviescreenOriData().exposure
      tbData_contrastTemp.value = self.secondaryData_:GetMoviescreenOriData().contrast
      tbData_saturationTemp.value = self.secondaryData_:GetMoviescreenOriData().saturation
    else
      tbData_exposureTemp.value = self.secondaryData_:GetMoviescreenData().exposure
      tbData_contrastTemp.value = self.secondaryData_:GetMoviescreenData().contrast
      tbData_saturationTemp.value = self.secondaryData_:GetMoviescreenData().saturation
    end
    self.uiBinder.slider_exposure_adjust.value = self.cameraVM_.GetRangePerc(tbData_exposureTemp, false)
    self.uiBinder.slider_constrast_adjust.value = self.cameraVM_.GetRangePerc(tbData_contrastTemp, false)
    self.uiBinder.slider_saturation_adjust.value = self.cameraVM_.GetRangePerc(tbData_saturationTemp, false)
    self.cameraData_.SecondEditMoviescreenDirty = false
  else
    self.uiBinder.slider_exposure_adjust.value = self.cameraVM_.GetRangePerc(self.tbData_exposure, self.cameraData_.MenuContainerMoviescreenDirty)
    self.uiBinder.slider_constrast_adjust.value = self.cameraVM_.GetRangePerc(self.tbData_contrast, self.cameraData_.MenuContainerMoviescreenDirty)
    self.uiBinder.slider_saturation_adjust.value = self.cameraVM_.GetRangePerc(self.tbData_saturation, self.cameraData_.MenuContainerMoviescreenDirty)
    self.cameraData_.MenuContainerMoviescreenDirty = false
  end
  self:refreshSliderValueShowText()
  if self.cameraData_.WorldTime then
    if self.uiBinder.tog_time.isOn then
      self.uiBinder.slider_time.value = self.cameraData_.WorldTime / self.dayAndNightMaxTime_
      self.uiBinder.lab_time.text = math.floor(self.cameraData_.WorldTime)
    end
  else
    self.uiBinder.tog_time.isOn = false
  end
  local isEnable = self.cameraData_.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto
  self.uiBinder.node_weather.interactable = isEnable
  self.uiBinder.node_weather.alpha = isEnable and 1 or 0.5
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_time, self.cameraData_.WorldTime ~= -1)
end

function Camera_menu_container_moviescreen_sub_pcView:refreshSliderValueShowText()
  self.uiBinder.lab_exposure_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, self.uiBinder.slider_exposure_adjust.value)
  self.uiBinder.lab_constrast_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, self.uiBinder.slider_constrast_adjust.value)
  self.uiBinder.lab_saturation_num.text = self.cameraVM_.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, self.uiBinder.slider_saturation_adjust.value)
end

return Camera_menu_container_moviescreen_sub_pcView
