local UI = Z.UI
local super = require("ui.ui_subview_base")
local Photo_editor_container_text_subView = class("Photo_editor_container_text_subView", super)
local colorPalette = require("ui/component/color_palette/color_palette")
local colorPaletteHandler = require("ui/component/color_palette/color_palette_handler")
local UIBinderToLua = UIBinderToLua
Photo_editor_container_text_subView.OperateType = {
  CheckCreate = 1,
  CheckEditor = 2,
  GetFontSize = 3,
  GetFontColor = 4,
  GetDecorateCount = 5,
  GetFontText = 6
}
Photo_editor_container_text_subView.CallBackFunctionType = {
  CreateText = 1,
  EditorText = 2,
  ChangeFontSize = 3,
  ChangeFontColor = 4
}

function Photo_editor_container_text_subView:ctor(parent)
  self.panel = nil
  self.viewData = nil
  self.parent_ = parent
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.camcameraData_ = Z.DataMgr.Get("camerasys_data")
  super.ctor(self, "photoalbum_edit_container_text_sub", "photograph/photoalbum_edit_container_text_sub", UI.ECacheLv.None)
  self.colorPalette_ = colorPalette.new(self, colorPaletteHandler.new())
  self.fontSize_ = 0
  self.color_ = nil
end

function Photo_editor_container_text_subView:OnActive()
  self.panel.Ref:SetOffSetMin(0, 0)
  self.panel.Ref:SetOffSetMax(0, 0)
  self:initUI()
end

function Photo_editor_container_text_subView:OnRefresh()
  self.colorPalette_:RefreshPaletteByColorGroupId(8, true)
  self:refreshFontColorRing()
  self:refreshTextSizeSlider()
  self:refreshDecorateCount()
end

function Photo_editor_container_text_subView:OnDeActive()
  self.faceCommonColorBinder_ = nil
end

function Photo_editor_container_text_subView:initUI()
  self:AddClick(self.panel.btn_camera_add.Btn, function()
    if self.viewData.operate and self.viewData.operate(Photo_editor_container_text_subView.OperateType.CheckCreate) then
      local data = {
        title = Lang("AddText"),
        inputContent = "",
        onConfirm = function(text)
          if self.viewData.operate(Photo_editor_container_text_subView.OperateType.CheckCreate) then
            local vm = Z.VMMgr.GetVM("screenword")
            vm.CheckScreenWord(text, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
              self.viewData.callBack(Photo_editor_container_text_subView.CallBackFunctionType.CreateText, {
                textColor = self.color_,
                textSize = self.fontSize_,
                textValue = text
              })
            end)
          end
        end,
        stringLengthLimitNum = self.camcameraData_:GetDecoreateTextMaxLength(),
        isMultiLine = true
      }
      Z.TipsVM.OpenCommonPopupInput(data)
    end
  end)
  self:AddClick(self.panel.btn_camera_edit.Btn, function()
    if self.viewData.operate and self.viewData.operate(Photo_editor_container_text_subView.OperateType.CheckEditor) then
      local data = {
        title = Lang("ModifyText"),
        inputContent = self.viewData.operate(Photo_editor_container_text_subView.OperateType.GetFontText),
        onConfirm = function(text)
          if self.viewData.operate(Photo_editor_container_text_subView.OperateType.CheckEditor) then
            local vm = Z.VMMgr.GetVM("screenword")
            vm.CheckScreenWord(text, E.TextCheckSceneType.TextCheckAlbumPhotoEditText, self.cancelSource:CreateToken(), function()
              self.viewData.callBack(Photo_editor_container_text_subView.CallBackFunctionType.EditorText, text)
            end)
          end
        end,
        stringLengthLimitNum = self.camcameraData_:GetDecoreateTextMaxLength(),
        isMultiLine = true
      }
      Z.TipsVM.OpenCommonPopupInput(data)
    end
  end)
  local sizeRange = self.camcameraData_:GetCameraFontSizeRange()
  self.fontSize_ = self.cameraVM_.GetRangeDefinePerc(sizeRange)
  self.panel.cont_slider_size.slider_size.Slider.value = self.fontSize_
  self.panel.cont_slider_size.slider_size.Slider:AddListener(function()
    local fontSize = self.cameraVM_.GetRangeValue(self.panel.cont_slider_size.slider_size.Slider.value, sizeRange)
    self.fontSize_ = math.ceil(fontSize)
    self.viewData.callBack(Photo_editor_container_text_subView.CallBackFunctionType.ChangeFontSize, self.fontSize_)
    self.panel.cont_slider_size.lab_num.TMPLab.text = self.fontSize_
  end)
  self.faceCommonColorBinder_ = UIBinderToLua(self.panel.face_common_color.Go)
  self.colorPalette_:Init(self.faceCommonColorBinder_)
  self.colorPalette_:SetColorChangeCB(function(hsv)
    local fontColor = Color.HSVToRGB(hsv.h, hsv.s, hsv.v)
    self.color_ = {
      x = fontColor.r,
      y = fontColor.g,
      z = fontColor.b
    }
    self.viewData.callBack(Photo_editor_container_text_subView.CallBackFunctionType.ChangeFontColor, self.color_)
  end)
  self.colorPalette_:SetColorResetCB(function()
    self.colorPalette_:ResetSelectHSVWithoutNotify()
  end)
  self.colorPalette_:SetResetBtn(true)
end

function Photo_editor_container_text_subView:refreshFontColorRing()
  self.color_ = Color.New(1, 1, 1, 1)
  if self.viewData.operate then
    local getColor = self.viewData.operate(Photo_editor_container_text_subView.OperateType.GetFontColor)
    if getColor then
      self.color_.r = getColor.x
      self.color_.g = getColor.y
      self.color_.b = getColor.z
    end
  end
  local th, ts, tv = Color.RGBToHSV(self.color_)
  self.colorPalette_:SetServerColor({
    h = th,
    s = ts,
    v = tv
  })
  self.colorPalette_:ResetSelectHSVWithoutNotify()
end

function Photo_editor_container_text_subView:refreshTextSizeSlider()
  local sizeRange = self.camcameraData_:GetCameraFontSizeRange()
  self.fontSize_ = sizeRange.define
  if self.viewData.operate then
    local size = self.viewData.operate(Photo_editor_container_text_subView.OperateType.GetFontSize)
    if size then
      self.fontSize_ = size
    end
  end
  self.panel.cont_slider_size.lab_num.TMPLab.text = sizeRange.define
  self.panel.cont_slider_size.slider_size.Slider.value = self.cameraVM_.GetRangePercEX(self.fontSize_, sizeRange)
end

function Photo_editor_container_text_subView:refreshDecorateCount()
  local stickCount = 0
  local maxCount = 0
  if self.viewData.operate then
    stickCount, maxCount = self.viewData.operate(Photo_editor_container_text_subView.OperateType.GetDecorateCount)
  end
  self.panel.lab_max.TMPLab.text = string.format("%s/%s", stickCount, maxCount)
end

return Photo_editor_container_text_subView
