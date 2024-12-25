local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photo_editor_container_moviescreen_subView = class("Photo_editor_container_moviescreen_subView", super)
Photo_editor_container_moviescreen_subView.CallBackFunctionType = {
  ChangeExposure = 1,
  ChangeContrast = 2,
  ChangeSaturation = 3,
  Reset = 4
}

function Photo_editor_container_moviescreen_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  self.parent_ = parent
  self.camerasysData_ = Z.DataMgr.Get("camerasys_data")
  self.camerasysVM_ = Z.VMMgr.GetVM("camerasys")
  super.ctor(self, "photoalbum_edit_container_moviescreen_sub", "photograph/photoalbum_edit_container_moviescreen_sub", UI.ECacheLv.None)
  self.tbData_exposure = self.camerasysData_:GetScreenBrightnessRange()
  self.tbData_contrast = self.camerasysData_:GetScreenContrastRange()
  self.tbData_saturation = self.camerasysData_:GetScreenSaturationRange()
end

function Photo_editor_container_moviescreen_subView:OnActive()
  self.uiBinder.rect_panel:SetOffsetMin(0, 0)
  self.uiBinder.rect_panel:SetOffsetMax(0, 0)
  self.uiBinder.slider_exposure:AddListener(function()
    local value = self.camerasysVM_.GetRangeValue(self.uiBinder.slider_exposure.value, self.tbData_exposure)
    self.uiBinder.lab_exposure_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, self.uiBinder.slider_exposure.value)
    self.viewData.callBack(Photo_editor_container_moviescreen_subView.CallBackFunctionType.ChangeExposure, value)
  end)
  self.uiBinder.slider_constrast:AddListener(function()
    local value = self.camerasysVM_.GetRangeValue(self.uiBinder.slider_constrast.value, self.tbData_contrast)
    self.uiBinder.lab_constrast_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, self.uiBinder.slider_constrast.value)
    self.viewData.callBack(Photo_editor_container_moviescreen_subView.CallBackFunctionType.ChangeContrast, value)
  end)
  self.uiBinder.slider_saturation:AddListener(function()
    local value = self.camerasysVM_.GetRangeValue(self.uiBinder.slider_saturation.value, self.tbData_saturation)
    self.uiBinder.lab_saturation_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, self.uiBinder.slider_saturation.value)
    self.viewData.callBack(Photo_editor_container_moviescreen_subView.CallBackFunctionType.ChangeSaturation, value)
  end)
  self:AddClick(self.uiBinder.btn_reset, function()
    self.viewData.callBack(Photo_editor_container_moviescreen_subView.CallBackFunctionType.Reset)
    self:refreshSlider()
  end)
  self:refreshSlider()
end

function Photo_editor_container_moviescreen_subView:OnDeActive()
end

function Photo_editor_container_moviescreen_subView:refreshSlider()
  local exposure = 0
  local contrast = 0
  local saturation = 0
  if self.viewData.operate then
    exposure, contrast, saturation = self.viewData.operate()
  end
  local tbData_exposureTemp = self.camerasysData_:GetTempRange(self.tbData_exposure)
  tbData_exposureTemp.value = exposure
  local tbData_contrastTemp = self.camerasysData_:GetTempRange(self.tbData_contrast)
  tbData_contrastTemp.value = contrast
  local tbData_saturationTemp = self.camerasysData_:GetTempRange(self.tbData_saturation)
  tbData_saturationTemp.value = saturation
  self.uiBinder.slider_exposure.value = self.camerasysVM_.GetRangePerc(tbData_exposureTemp, false)
  self.uiBinder.slider_constrast.value = self.camerasysVM_.GetRangePerc(tbData_contrastTemp, false)
  self.uiBinder.slider_saturation.value = self.camerasysVM_.GetRangePerc(tbData_saturationTemp, false)
  self.uiBinder.lab_exposure_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_exposure.showValueMin, self.tbData_exposure.showValueMax, self.uiBinder.slider_exposure.value)
  self.uiBinder.lab_constrast_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_contrast.showValueMin, self.tbData_contrast.showValueMax, self.uiBinder.slider_constrast.value)
  self.uiBinder.lab_saturation_num.text = self.camerasysVM_.CalculatePercentageValue(self.tbData_saturation.showValueMin, self.tbData_saturation.showValueMax, self.uiBinder.slider_saturation.value)
end

return Photo_editor_container_moviescreen_subView
