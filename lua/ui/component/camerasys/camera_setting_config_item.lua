local super = require("ui.component.loopscrollrectitem")
local CameraSettingConfigItem = class("CameraSettingConfigItem", super)
local data = Z.DataMgr.Get("camerasys_data")

function CameraSettingConfigItem:ctor()
end

local MAX_Length = 12

function CameraSettingConfigItem:OnInit()
end

function CameraSettingConfigItem:onEditChange(value)
  local endText = value
  if Z.VMMgr.GetVM("camerasys").CameraSchemefIsRepeatName(endText) or string.zlenNormalize(endText) > MAX_Length then
    endText = self.endInputText_
  else
    self.endInputText_ = endText
    self.data_.schemeName = self.endInputText_
    Z.VMMgr.GetVM("camerasys").ReplaceCameraSchemeInfo(self.data_)
  end
end

function CameraSettingConfigItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.lab_name.TMPLab.text = self.data_.schemeName
end

function CameraSettingConfigItem:Selected(isSelected)
  if isSelected then
    data.CameraSchemeSelectIndex = self.component.Index
    data.CameraSchemeSelectInfo = self.data_
    data.CameraSchemeSelectId = self.data_.id
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.SchemeBtnUpdate, self.data_.cameraSchemeType)
    local camerasysVm = Z.VMMgr.GetVM("camerasys")
    camerasysVm.SetSchemoCameraValue(self.data_)
  end
  self.unit.img_select:SetVisible(isSelected)
  self.unit.lab_name.TMPLab.text = self.data_.schemeName
end

function CameraSettingConfigItem:OnReset()
end

function CameraSettingConfigItem:OnUnInit()
  self.data_ = nil
end

return CameraSettingConfigItem
