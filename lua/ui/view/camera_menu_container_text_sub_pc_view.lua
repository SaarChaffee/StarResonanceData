local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_text_sub_pcView = class("Camera_menu_container_text_sub_pcView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorPaletteHandler = require("ui/component/color_palette/color_palette_handler")

function Camera_menu_container_text_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_text_sub_pc", "photograph_pc/camera_menu_container_text_sub_pc", UI.ECacheLv.None)
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.decorateOriData_ = Z.DataMgr.Get("decorate_add_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.parent_ = parent
  self.viewType_ = E.DecorateLayerType.AlbumType
  self.addViewData_ = nil
  self.colorPalette_ = colorPalette.new(self, colorPaletteHandler.new())
end

function Camera_menu_container_text_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.textsMgr_ = {}
  self.textIndex_ = 0
  self:AddClick(self.uiBinder.btn_camera_add, function()
    local num = self.addViewData_:GetDecoreateNum()
    local textCurrentNum = self.addViewData_.DecorationTextNum
    local maxNum = self.cameraData_:GetDecoreateMaxNum()
    local textMaxNum = self.cameraData_:GetDecorativeTextMaxNum()
    if textCurrentNum >= textMaxNum then
      Z.TipsVM.ShowTipsLang(1000032)
      return
    end
    if num >= tonumber(maxNum) then
      Z.TipsVM.ShowTipsLang(1000029)
      return
    end
    self:openTextInput("", E.CameraTextViewType.Create, "AddText")
  end)
  self:AddClick(self.uiBinder.btn_camera_edit, function()
    if not (self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType) or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
      Z.TipsVM.ShowTipsLang(1000000)
      return
    end
    self:openTextInput(self.cameraData_.ActiveItem.lab_input.text, E.CameraTextViewType.Revise, "ModifyText")
  end)
  self:initSliderStepVal()
  self:initSlider()
  self:initSliderBtn()
  self.colorItems_ = {}
  self.selectColorItem_ = nil
  self.colorPalette_:Init(self.uiBinder.face_common_color)
  self.colorPalette_:SetColorChangeCB(function(hsv)
    self.cameraData_.ColorPaletteColor = Color.HSVToRGB(hsv.h, hsv.s, hsv.v)
    if not self.cameraData_.ActiveItem then
      return
    end
    self.cameraData_.ColorPaletteColor.a = self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).transparency
    self.cameraData_.ActiveItem.lab_input.color = self.cameraData_.ColorPaletteColor
  end)
  self.colorPalette_:SetColorResetCB(function()
    self.colorPalette_:ResetSelectHSVWithoutNotify()
  end)
  self.colorPalette_:SetResetBtn(true)
  self:bindEvents()
end

function Camera_menu_container_text_sub_pcView:OnDeActive()
  self.faceCommonColorBinder_ = nil
  self.textsMgr_ = {}
  self.cameraData_.ColorPaletteColor = Color.New(1, 1, 1, 1)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerDown, self.camerasysDecorateLayerDown, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.TextViewChange, self.camerasysTextViewChange, self)
end

function Camera_menu_container_text_sub_pcView:openTextInput(textVale, operationType, titleTextKey)
  local data = {
    title = Lang(titleTextKey),
    inputContent = textVale,
    onConfirm = function(text)
      local vm = Z.VMMgr.GetVM("screenword")
      vm.CheckScreenWord(text, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
        self:setInputTextData(text, operationType)
      end)
    end,
    stringLengthLimitNum = self.cameraData_:GetDecoreateTextMaxLength(),
    isMultiLine = true
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Camera_menu_container_text_sub_pcView:setInputTextData(txt, operationType)
  local valueData = {}
  valueData.value = txt
  valueData.type = operationType
  valueData.viewType = self.viewType_
  if not valueData.value or string.zlenNormalize(#valueData.value) <= 0 then
    Z.TipsVM.ShowTipsLang(1000012)
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateTextCreate, valueData)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateLayerDown)
end

function Camera_menu_container_text_sub_pcView:initSlider()
  local sizeRange = self.cameraData_:GetCameraFontSizeRange()
  self.uiBinder.slider_size.value = self.cameraVM_.GetRangeDefinePerc(sizeRange)
  self.cameraData_:SetTextFontSize(sizeRange.define)
  self.uiBinder.lab_num.text = sizeRange.define
  local alpha = 1
  if self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType == E.CamerasysFuncType.Text then
    alpha = self.cameraData_.ActiveItem.lab_input.color.a
  end
  self.uiBinder.slider_transparency.value = alpha
  self.uiBinder.slider_size:AddListener(function(val)
    local fontSize = self.cameraVM_.GetRangeValue(val, sizeRange)
    local cfs = math.ceil(fontSize)
    self.cameraData_:SetTextFontSize(cfs)
    if not (self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType) or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
      return
    end
    self.uiBinder.lab_num.text = cfs
    self.cameraData_.ActiveItem.lab_input.fontSize = cfs
    if not self.addViewData_ then
      return
    end
    self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).textSize = cfs
  end)
  self.uiBinder.slider_transparency:AddListener(function(val)
    if not (self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType) or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
      return
    end
    local color = self.cameraData_.ActiveItem.lab_input.color
    color.a = val
    self.cameraData_.ActiveItem.lab_input.color = color
    self.cameraData_.ActiveItem.rimg_decorate_icon:SetColor(Color.New(1, 1, 1, val))
    if not self.addViewData_ then
      return
    end
    self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).transparency = val
  end)
end

function Camera_menu_container_text_sub_pcView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerDown, self.camerasysDecorateLayerDown, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.TextViewChange, self.camerasysTextViewChange, self)
end

function Camera_menu_container_text_sub_pcView:camerasysTextViewChange(valueData)
  self:setTransparencyValue()
  if not valueData or not next(valueData) then
    return
  end
  self.uiBinder.slider_size.value = self.cameraVM_.GetRangePercEX(valueData.fontSize, valueData.sizeRange)
end

function Camera_menu_container_text_sub_pcView:camerasysDecorateLayerDown()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
end

function Camera_menu_container_text_sub_pcView:setNumber()
  self:setTransparencyValue()
  self.uiBinder.lab_current.text = string.format("%s/%s", self.addViewData_:GetDecoreateNum(), self.cameraData_:GetDecoreateMaxNum())
  if self.cameraData_.ActiveItem then
    local th, ts, tv = Color.RGBToHSV(self.cameraData_.ActiveItem.lab_input.color)
    self.colorPalette_:SetServerColor({
      h = th,
      s = ts,
      v = tv
    })
  else
    self.colorPalette_:SetServerColor({
      h = 0,
      s = 0,
      v = 100
    })
  end
  self.colorPalette_:ResetSelectHSVWithoutNotify()
end

function Camera_menu_container_text_sub_pcView:setTransparencyValue()
  if not self.cameraData_.ActiveItem or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
    return
  end
  local alpha = self.cameraData_.ActiveItem.rimg_decorate_icon.color.a
  self.uiBinder.slider_transparency.value = alpha
end

function Camera_menu_container_text_sub_pcView:setTextSliderSize()
  if not self.cameraData_.ActiveItem then
    return
  end
  if self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text or not self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem) then
    return
  end
  local textSize = self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).textSize
  local valueData = self.cameraData_:GetCameraFontSizeRange()
  self.uiBinder.slider_size.value = self.cameraVM_.GetRangePercEX(textSize, valueData)
  self.uiBinder.slider_transparency.value = self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).transparency
end

function Camera_menu_container_text_sub_pcView:OnRefresh()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.viewData = {}
    self.addViewData_ = self.secondaryData_
    self.viewType_ = E.DecorateLayerType.AlbumType
  else
    self.isToEditing_ = false
    self.addViewData_ = self.decorateOriData_
    self.viewType_ = E.DecorateLayerType.CamerasysType
  end
  self.colorPalette_:RefreshPaletteByColorGroupId(8, true)
  self:setNumber()
  self:setTextSliderSize()
end

function Camera_menu_container_text_sub_pcView:initSliderStepVal()
  self.alpha_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.TextAlpha)
  self.size_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.TextSize)
  self.hue_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.TextHue)
end

function Camera_menu_container_text_sub_pcView:initSliderBtn()
  self:AddClick(self.uiBinder.btn_alpha_left, function()
    local value = self.uiBinder.slider_transparency.value - self.alpha_step_val_
    self.uiBinder.slider_transparency.value = value
  end)
  self:AddClick(self.uiBinder.btn_alpha_right, function()
    local value = self.uiBinder.slider_transparency.value + self.alpha_step_val_
    self.uiBinder.slider_transparency.value = value
  end)
  self:AddClick(self.uiBinder.btn_size_left, function()
    local value = self.uiBinder.slider_size.value - self.size_step_val_
    self.uiBinder.slider_size.value = value
  end)
  self:AddClick(self.uiBinder.btn_size_right, function()
    local value = self.uiBinder.slider_size.value + self.size_step_val_
    self.uiBinder.slider_size.value = value
  end)
  self:AddClick(self.uiBinder.btn_color_left, function()
    local value = self.uiBinder.face_common_color.silder_hue.value - self.hue_step_val_
    self.uiBinder.face_common_color.silder_hue.value = value
  end)
  self:AddClick(self.uiBinder.btn_color_right, function()
    local value = self.uiBinder.face_common_color.silder_hue.value + self.hue_step_val_
    self.uiBinder.face_common_color.silder_hue.value = value
  end)
end

return Camera_menu_container_text_sub_pcView
