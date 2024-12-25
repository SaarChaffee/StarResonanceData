local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_moviescreenView = class("Camera_menu_container_moviescreenView", super)
local cameraData_ = Z.DataMgr.Get("camerasys_data")
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")
local vm = Z.VMMgr.GetVM("camerasys")

function Camera_menu_container_moviescreenView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_moviescreen_sub", "photograph/camera_menu_container_moviescreen_sub", UI.ECacheLv.None)
  self.tbData_exposure = cameraData_:GetScreenBrightnessRange()
  self.tbData_contrast = cameraData_:GetScreenContrastRange()
  self.tbData_saturation = cameraData_:GetScreenSaturationRange()
end

function Camera_menu_container_moviescreenView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self.panel.cont_slider_exposure.slider_adjust.Slider:AddListener(function()
    local value = vm.GetRangeValue(self.panel.cont_slider_exposure.slider_adjust.Slider.value, self.tbData_exposure)
    self.panel.cont_slider_exposure.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, self.panel.cont_slider_exposure.slider_adjust.Slider.value)
    if self.isToEditing_ then
      secondaryData:GetMoviescreenData().exposure = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Exposure, value)
      secondaryData:GetMoviescreenData().exposure = value
    else
      cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_exposure.value = value
      Z.CameraFrameCtrl:SetExposure(self.tbData_exposure.value)
      decorateData:GetMoviescreenData().exposure = self.tbData_exposure.value
    end
  end)
  self.panel.cont_slider_constrast.slider_adjust.Slider:AddListener(function()
    local value = vm.GetRangeValue(self.panel.cont_slider_constrast.slider_adjust.Slider.value, self.tbData_contrast)
    self.panel.cont_slider_constrast.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, self.panel.cont_slider_constrast.slider_adjust.Slider.value)
    if self.isToEditing_ then
      secondaryData:GetMoviescreenData().contrast = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Contrast, value)
      secondaryData:GetMoviescreenData().contrast = value
    else
      cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_contrast.value = value
      Z.CameraFrameCtrl:SetContrast(self.tbData_contrast.value)
      decorateData:GetMoviescreenData().contrast = self.tbData_contrast.value
    end
  end)
  self.panel.cont_slider_saturation.slider_adjust.Slider:AddListener(function()
    local value = vm.GetRangeValue(self.panel.cont_slider_saturation.slider_adjust.Slider.value, self.tbData_saturation)
    self.panel.cont_slider_saturation.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, self.panel.cont_slider_saturation.slider_adjust.Slider.value)
    if self.isToEditing_ then
      secondaryData:GetMoviescreenData().saturation = value
      Z.CameraFrameCtrl:SetAlbumSecondEdit(E.AlbumSecondEditType.Saturation, value)
      secondaryData:GetMoviescreenData().saturation = value
    else
      cameraData_:SetIsSchemeParamUpdated(true)
      self.tbData_saturation.value = value
      Z.CameraFrameCtrl:SetSaturation(self.tbData_saturation.value)
      decorateData:GetMoviescreenData().saturation = self.tbData_saturation.value
    end
  end)
  self:AddClick(self.panel.cont_setting_title_item.btn_reset.Btn, function()
    local tbData_exposure = {}
    local tbData_contrast = {}
    local tbData_saturation = {}
    tbData_exposure = cameraData_:GetScreenBrightnessRange()
    tbData_contrast = cameraData_:GetScreenContrastRange()
    tbData_saturation = cameraData_:GetScreenSaturationRange()
    if self.isToEditing_ then
      local tbData_exposureTemp = cameraData_:GetTempRange(tbData_exposure)
      local tbData_contrastTemp = cameraData_:GetTempRange(tbData_contrast)
      local tbData_saturationTemp = cameraData_:GetTempRange(tbData_saturation)
      tbData_exposureTemp.value = secondaryData:GetMoviescreenOriData().exposure
      tbData_contrastTemp.value = secondaryData:GetMoviescreenOriData().contrast
      tbData_saturationTemp.value = secondaryData:GetMoviescreenOriData().saturation
      self.panel.cont_slider_exposure.slider_adjust.Slider.value = vm.GetRangePerc(tbData_exposureTemp, false)
      self.panel.cont_slider_constrast.slider_adjust.Slider.value = vm.GetRangePerc(tbData_contrastTemp, false)
      self.panel.cont_slider_saturation.slider_adjust.Slider.value = vm.GetRangePerc(tbData_saturationTemp, false)
    else
      self.panel.cont_slider_exposure.slider_adjust.Slider.value = vm.GetRangePerc(tbData_exposure, true)
      self.panel.cont_slider_constrast.slider_adjust.Slider.value = vm.GetRangePerc(tbData_contrast, true)
      self.panel.cont_slider_saturation.slider_adjust.Slider.value = vm.GetRangePerc(tbData_saturation, true)
      cameraData_:SetIsSchemeParamUpdated(true)
    end
  end)
end

function Camera_menu_container_moviescreenView:OnDeActive()
end

function Camera_menu_container_moviescreenView:OnRefresh()
  if not self.viewData then
    self.isToEditing_ = false
  else
    self.isToEditing_ = self.viewData.isToEditing
    self.viewData = {}
  end
  if self.isToEditing_ then
    local tbData_exposureTemp = cameraData_:GetTempRange(self.tbData_exposure)
    local tbData_contrastTemp = cameraData_:GetTempRange(self.tbData_contrast)
    local tbData_saturationTemp = cameraData_:GetTempRange(self.tbData_saturation)
    if cameraData_.SecondEditMoviescreenDirty then
      tbData_exposureTemp.value = secondaryData:GetMoviescreenOriData().exposure
      tbData_contrastTemp.value = secondaryData:GetMoviescreenOriData().contrast
      tbData_saturationTemp.value = secondaryData:GetMoviescreenOriData().saturation
    else
      tbData_exposureTemp.value = secondaryData:GetMoviescreenData().exposure
      tbData_contrastTemp.value = secondaryData:GetMoviescreenData().contrast
      tbData_saturationTemp.value = secondaryData:GetMoviescreenData().saturation
    end
    self.panel.cont_slider_exposure.slider_adjust.Slider.value = vm.GetRangePerc(tbData_exposureTemp, false)
    self.panel.cont_slider_constrast.slider_adjust.Slider.value = vm.GetRangePerc(tbData_contrastTemp, false)
    self.panel.cont_slider_saturation.slider_adjust.Slider.value = vm.GetRangePerc(tbData_saturationTemp, false)
    cameraData_.SecondEditMoviescreenDirty = false
  else
    self.panel.cont_slider_exposure.slider_adjust.Slider.value = vm.GetRangePerc(self.tbData_exposure, cameraData_.MenuContainerMoviescreenDirty)
    self.panel.cont_slider_constrast.slider_adjust.Slider.value = vm.GetRangePerc(self.tbData_contrast, cameraData_.MenuContainerMoviescreenDirty)
    self.panel.cont_slider_saturation.slider_adjust.Slider.value = vm.GetRangePerc(self.tbData_saturation, cameraData_.MenuContainerMoviescreenDirty)
    cameraData_.MenuContainerMoviescreenDirty = false
  end
  self:refreshSliderValueShowText()
end

function Camera_menu_container_moviescreenView:refreshSliderValueShowText()
  self.panel.cont_slider_exposure.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, self.panel.cont_slider_exposure.slider_adjust.Slider.value)
  self.panel.cont_slider_constrast.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, self.panel.cont_slider_constrast.slider_adjust.Slider.value)
  self.panel.cont_slider_saturation.lab_num.TMPLab.text = vm.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, self.panel.cont_slider_saturation.slider_adjust.Slider.value)
end

return Camera_menu_container_moviescreenView
