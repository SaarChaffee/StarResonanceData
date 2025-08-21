local UI = Z.UI
local super = require("ui.ui_subview_base")
local Camera_menu_container_sticker_sub_pcView = class("Camera_menu_container_sticker_sub_pcView", super)
local loopScrollRect_ = require("ui.component.loop_grid_view")
local camera_menu_sticker_item_tpl_ = require("ui/component/camerasys/camera_menu_sticker_item_tpl_pc")

function Camera_menu_container_sticker_sub_pcView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "camera_menu_container_sticker_sub_pc", "photograph_pc/camera_menu_container_frame_sub_pc", UI.ECacheLv.None)
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.decorateData_ = Z.DataMgr.Get("decorate_add_data")
  self.secondaryData_ = Z.DataMgr.Get("photo_secondary_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
  self.isToEditing_ = false
end

function Camera_menu_container_sticker_sub_pcView:OnActive()
  self.uiBinder.Trans:SetOffsetMin(0, 0)
  self.uiBinder.Trans:SetOffsetMax(0, 0)
  self:bindEvents()
  local pcPhotographUiTableRow = self.cameraVM_.GetPcPhotographUiTableRow(E.CameraSystemSubFunctionType.Sticker)
  if pcPhotographUiTableRow then
    self.uiBinder.lab_name.text = Lang(pcPhotographUiTableRow.Name)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_slider_transparency, true)
  self.loopScrollRect_ = loopScrollRect_.new(self, self.uiBinder.scrollview_frame_item, camera_menu_sticker_item_tpl_, "camera_setting_frame_item_tpl_pc")
  self.loopScrollRect_:Init({})
  self:initSliderStepVal()
  self:initSlider()
  self:initSliderBtn()
end

function Camera_menu_container_sticker_sub_pcView:initSlider()
  local alpha = 1
  if self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType == E.CamerasysFuncType.Sticker then
    alpha = self.cameraData_.ActiveItem.rimg_decorate_icon.color.a
  end
  self.uiBinder.slider_transparency.value = alpha
  self.uiBinder.slider_transparency:AddListener(function(val)
    if not (self.cameraData_.ActiveItem and self.cameraData_.ActiveItem.decorateType) or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Sticker then
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

function Camera_menu_container_sticker_sub_pcView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
  Z.EventMgr:Add(Z.ConstValue.Camera.TextViewChange, self.setTransparencyValue, self)
end

function Camera_menu_container_sticker_sub_pcView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Camera.TextViewChange, self.setTransparencyValue, self)
  Z.EventMgr:Remove(Z.ConstValue.Camera.DecorateNumberUpdate, self.setNumber, self)
end

function Camera_menu_container_sticker_sub_pcView:setTransparencyValue()
  if not self.cameraData_.ActiveItem or self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Sticker then
    return
  end
  local alpha = self.cameraData_.ActiveItem.rimg_decorate_icon.color.a
  self.uiBinder.slider_transparency.value = alpha
end

function Camera_menu_container_sticker_sub_pcView:OnDeActive()
  if self.loopScrollRect_ then
    self.loopScrollRect_:UnInit()
    self.loopScrollRect_ = nil
  end
  self:unBindEvents()
end

function Camera_menu_container_sticker_sub_pcView:OnRefresh()
  if self.viewData and next(self.viewData) and self.viewData.isToEditing then
    self.isToEditing_ = true
    self.viewData = {}
    self.addViewData_ = self.secondaryData_
    self.viewType_ = E.DecorateLayerType.AlbumType
  else
    self.isToEditing_ = false
    self.addViewData_ = self.decorateData_
    self.viewType_ = E.DecorateLayerType.CamerasysType
  end
  self:refreshLoopList()
  self:setNumber()
  if not self.cameraData_.ActiveItem then
    return
  end
  if self.cameraData_.ActiveItem.decorateType ~= E.CamerasysFuncType.Text or not self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem) then
    return
  end
  self.uiBinder.slider_transparency.value = self.addViewData_:GetDecorateData(self.cameraData_.ActiveItem).transparency
end

function Camera_menu_container_sticker_sub_pcView:refreshLoopList()
  local data = self.cameraData_:GetDecorateStickerCfg()
  if not data or #data <= 0 then
    return
  end
  self.loopScrollRect_:RefreshListView(data)
end

function Camera_menu_container_sticker_sub_pcView:setNumber()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_current, true)
  self.uiBinder.lab_current.text = string.format("%s/%s", self.addViewData_:GetDecoreateNum(), self.cameraData_:GetDecoreateMaxNum())
  self:setTransparencyValue()
end

function Camera_menu_container_sticker_sub_pcView:initSliderStepVal()
  self.alpha_step_val_ = self.cameraData_:GetPcSliderStepVal(E.CameraPcSliderEnum.StickerAlpha)
end

function Camera_menu_container_sticker_sub_pcView:initSliderBtn()
  self:AddClick(self.uiBinder.btn_transparency_left, function()
    local value = self.uiBinder.slider_transparency.value - self.alpha_step_val_
    self.uiBinder.slider_transparency.value = value
  end)
  self:AddClick(self.uiBinder.btn_transparency_right, function()
    local value = self.uiBinder.slider_transparency.value + self.alpha_step_val_
    self.uiBinder.slider_transparency.value = value
  end)
end

return Camera_menu_container_sticker_sub_pcView
