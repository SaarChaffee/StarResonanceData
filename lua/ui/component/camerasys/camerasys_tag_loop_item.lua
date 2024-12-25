local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loopscrollrectitem")
local CamerasysTagItem = class("CamerasysTagItem", super)

function CamerasysTagItem:ctor()
end

function CamerasysTagItem:OnInit()
end

function CamerasysTagItem:Refresh()
  local index = self.component.Index + 1
  local data = self.parent:GetDataByIndex(index)
  local count = self.parent:GetCount()
  if count == index then
    self.unit.line:SetVisible(false)
  else
    self.unit.line:SetVisible(true)
  end
  self.unit.toggle.Tog.group = self.parent.uiView.node_toggle.TogGroup
  self.unit.toggle.Tog:AddListener(function()
    if self.unit.toggle.Tog.isOn then
      Z.VMMgr.GetVM("camerasys").SetNodeTagIndex(data)
    end
  end)
end

function CamerasysTagItem:OnUnInit()
end

return CamerasysTagItem
