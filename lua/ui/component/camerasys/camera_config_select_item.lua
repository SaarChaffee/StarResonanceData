local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local CameraConfigSelectItem = class("CameraConfigSelectItem", super)
local data = Z.DataMgr.Get("camerasys_data")

function CameraConfigSelectItem:ctor()
end

function CameraConfigSelectItem:OnInit()
  self.unit.tog_select.Tog:AddListener(function()
    if self.unit.tog_select.Tog.isOn then
      data.CameraSchemeReplaceInfo = {}
      data.CameraSchemeReplaceInfo.data = self.data_
      data.CameraSchemeReplaceInfo.index = self.index_
    else
    end
  end)
end

function CameraConfigSelectItem:Refresh()
  self.index_ = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(self.index_)
  self.unit.tog_select.Tog.group = self.parent.uiView.uiBinder.tog_group_config
  self.unit.lab_scheme.TMPLab.text = self.data_.schemeName
  self.unit.lab_scheme_off.TMPLab.text = self.data_.schemeName
  self.unit.tog_select.Tog.isOn = false
end

function CameraConfigSelectItem:OnReset()
end

function CameraConfigSelectItem:OnUnInit()
end

return CameraConfigSelectItem
