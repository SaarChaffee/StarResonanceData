local super = require("ui.component.loop_list_view_item")
local CameraSettingConfigItemPcTpl = class("CameraSettingConfigItemPcTpl", super)
local MAX_LENGTH = 12

function CameraSettingConfigItemPcTpl:ctor()
  super:ctor()
  self.cameraData_ = Z.DataMgr.Get("camerasys_data")
  self.cameraVM_ = Z.VMMgr.GetVM("camerasys")
end

function CameraSettingConfigItemPcTpl:OnInit()
  self.parentView_ = self.parent.UIView
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function CameraSettingConfigItemPcTpl:OnRefresh(data)
  self.data_ = data
  self.uiBinder.lab_name.text = self.data_.schemeName
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function CameraSettingConfigItemPcTpl:OnUnInit()
end

function CameraSettingConfigItemPcTpl:OnSelected(isSelected, isClick)
  if isSelected then
    self.cameraData_.CameraSchemeSelectIndex = self.Index
    self.cameraData_.CameraSchemeSelectInfo = self.data_
    self.cameraData_.CameraSchemeSelectId = self.data_.id
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.SchemeBtnUpdate, self.data_.cameraSchemeType)
    self.cameraVM_.SetSchemoCameraValue(self.data_)
    self.parentView_:SetSchemeCanControls(self.Index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  self.uiBinder.lab_name.text = self.data_.schemeName
end

function CameraSettingConfigItemPcTpl:onEditChange(value)
  local endText = value
  if self.cameraVM_.CameraSchemefIsRepeatName(endText) or string.zlenNormalize(endText) > MAX_LENGTH then
    endText = self.endInputText_
  else
    self.endInputText_ = endText
    self.data_.schemeName = self.endInputText_
    self.cameraVM_.ReplaceCameraSchemeInfo(self.data_)
  end
end

return CameraSettingConfigItemPcTpl
