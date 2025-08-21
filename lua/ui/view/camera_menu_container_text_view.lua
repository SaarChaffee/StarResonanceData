local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_textView = class("Camera_menu_container_textView", super)
local decorateData = Z.DataMgr.Get("decorate_add_data")
local secondaryData = Z.DataMgr.Get("photo_secondary_data")
local colorPalette = require("ui/component/color_palette/color_palette")
local colorPaletteHandler = require("ui/component/color_palette/color_palette_handler")
local UIBinderToLua = UIBinderToLua

function Camera_menu_container_textView:ctor(parent)
  self.panel = nil
  super.ctor(self, "camera_menu_container_text_sub", "photograph/camera_menu_container_text_sub", UI.ECacheLv.None)
  self.parent_ = parent
  self.viewType_ = E.DecorateLayerType.AlbumType
  self.cameraVM = Z.VMMgr.GetVM("camerasys")
  self.cameraData = Z.DataMgr.Get("camerasys_data")
  self.addViewData_ = nil
  self.colorPalette_ = colorPalette.new(self, colorPaletteHandler.new())
end

function Camera_menu_container_textView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self.textsMgr_ = {}
  self.textIndex_ = 0
  self:AddClick(self.panel.btn_camera_add.Btn, function()
    local num = self.addViewData_:GetDecoreateNum()
    local textCurrentNum = self.addViewData_.DecorationTextNum
    local maxNum = self.cameraData:GetDecoreateMaxNum()
    local textMaxNum = self.cameraData:GetDecorativeTextMaxNum()
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
  self:AddClick(self.panel.btn_camera_edit.Btn, function()
    if not (self.cameraData.ActiveItem and self.cameraData.ActiveItem.decorateType) or self.cameraData.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
      Z.TipsVM.ShowTipsLang(1000000)
      return
    end
    self:openTextInput(self.cameraData.ActiveItem.lab_input.text, E.CameraTextViewType.Revise, "ModifyText")
  end)
  self:initSlider()
  self.colorItems_ = {}
  self.selectColorItem_ = nil
  self.faceCommonColorBinder_ = UIBinderToLua(self.panel.face_common_color.Go)
  self.colorPalette_:Init(self.faceCommonColorBinder_)
  self.colorPalette_:SetColorChangeCB(function(hsv)
    self.cameraData.ColorPaletteColor = Color.HSVToRGB(hsv.h, hsv.s, hsv.v)
    if not self.cameraData.ActiveItem then
      return
    end
    self.cameraData.ActiveItem.lab_input.color = self.cameraData.ColorPaletteColor
  end)
  self.colorPalette_:SetColorResetCB(function()
    self.colorPalette_:ResetSelectHSVWithoutNotify()
  end)
  self.colorPalette_:SetResetBtn(true)
  self:bindEvents()
end

function Camera_menu_container_textView:openTextInput(textVale, operationType, titleTextKey)
  local data = {
    title = Lang(titleTextKey),
    inputContent = textVale,
    onConfirm = function(text)
      local vm = Z.VMMgr.GetVM("screenword")
      vm.CheckScreenWord(text, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
        self:setInputTextData(text, operationType)
      end)
    end,
    stringLengthLimitNum = self.cameraData:GetDecoreateTextMaxLength(),
    isMultiLine = true
  }
  Z.TipsVM.OpenCommonPopupInput(data)
end

function Camera_menu_container_textView:setInputTextData(txt, operationType)
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

function Camera_menu_container_textView:initSlider()
  local sizeRange = self.cameraData:GetCameraFontSizeRange()
  self.panel.cont_slider_size.slider_size.Slider.value = self.cameraVM.GetRangeDefinePerc(sizeRange)
  self.cameraData:SetTextFontSize(sizeRange.define)
  self.panel.cont_slider_size.lab_num.TMPLab.text = sizeRange.define
  self.panel.cont_slider_size.slider_size.Slider:AddListener(function()
    local fontSize = self.cameraVM.GetRangeValue(self.panel.cont_slider_size.slider_size.Slider.value, sizeRange)
    local cfs = math.ceil(fontSize)
    self.cameraData:SetTextFontSize(cfs)
    if not (self.cameraData.ActiveItem and self.cameraData.ActiveItem.decorateType) or self.cameraData.ActiveItem.decorateType ~= E.CamerasysFuncType.Text then
      return
    end
    self.panel.cont_slider_size.lab_num.TMPLab.text = cfs
    self.cameraData.ActiveItem.lab_input.fontSize = cfs
    if not self.addViewData_ then
      return
    end
    self.addViewData_:GetDecorateData(self.cameraData.ActiveItem).textSize = cfs
  end)
end

function Camera_menu_container_textView:OnDeActive()
  self.faceCommonColorBinder_ = nil
  self.textsMgr_ = {}
  self.cameraData.ColorPaletteColor = Color.New(1, 1, 1, 1)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateLayerDown, self.camerasysDecorateLayerDown, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.TextViewChange, self.camerasysTextViewChange, self)
end

function Camera_menu_container_textView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateLayerDown, self.camerasysDecorateLayerDown, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.TextViewChange, self.camerasysTextViewChange, self)
end

function Camera_menu_container_textView:camerasysTextViewChange(valueData)
  if not valueData or not next(valueData) then
    return
  end
  self.panel.cont_slider_size.slider_size.Slider.value = self.cameraVM.GetRangePercEX(valueData.fontSize, valueData.sizeRange)
end

function Camera_menu_container_textView:camerasysDecorateLayerDown()
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateDeActive)
end

function Camera_menu_container_textView:setNumber()
  self.panel.lab_current.TMPLab.text = self.addViewData_:GetDecoreateNum()
  self.panel.lab_max.TMPLab.text = string.format("/%s", self.cameraData:GetDecoreateMaxNum())
  if self.cameraData.ActiveItem then
    local th, ts, tv = Color.RGBToHSV(self.cameraData.ActiveItem.lab_input.color)
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

function Camera_menu_container_textView:setTextSliderSize()
  if not self.cameraData.ActiveItem then
    return
  end
  if self.cameraData.ActiveItem.decorateType ~= E.CamerasysFuncType.Text or not self.addViewData_:GetDecorateData(self.cameraData.ActiveItem) then
    return
  end
  local textSize = self.addViewData_:GetDecorateData(self.cameraData.ActiveItem).textSize
  local valueData = self.cameraData:GetCameraFontSizeRange()
  self.panel.cont_slider_size.slider_size.Slider.value = self.cameraVM.GetRangePercEX(textSize, valueData)
end

function Camera_menu_container_textView:OnRefresh()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.viewData = {}
    self.addViewData_ = secondaryData
    self.viewType_ = E.DecorateLayerType.AlbumType
  else
    self.isToEditing_ = false
    self.addViewData_ = decorateData
    self.viewType_ = E.DecorateLayerType.CamerasysType
  end
  self.colorPalette_:RefreshPaletteByColorGroupId(8, true)
  self:setNumber()
  self:setTextSliderSize()
end

return Camera_menu_container_textView
