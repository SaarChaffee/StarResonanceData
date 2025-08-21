local super = require("ui.component.loop_grid_view_item")
local CameraConfigSelectItem = class("CameraConfigSelectItem", super)
local data = Z.DataMgr.Get("camerasys_data")

function CameraConfigSelectItem:ctor()
  self.uiBinder = nil
end

function CameraConfigSelectItem:OnInit()
  self.uiBinder.tog_select:AddListener(function(isOn)
    if isOn then
      data.CameraSchemeReplaceInfo = {}
      data.CameraSchemeReplaceInfo.data = self.data_
      data.CameraSchemeReplaceInfo.index = self.Index
    end
  end)
end

function CameraConfigSelectItem:Refresh(data)
  self.data_ = data
  self.uiBinder.tog_select.group = self.parent.UIView.uiBinder.tog_group_config
  self.uiBinder.lab_scheme.text = self.data_.schemeName
  self.uiBinder.lab_scheme_off.text = self.data_.schemeName
  self.uiBinder.tog_select.isOn = false
end

function CameraConfigSelectItem:OnReset()
end

function CameraConfigSelectItem:OnUnInit()
end

return CameraConfigSelectItem
