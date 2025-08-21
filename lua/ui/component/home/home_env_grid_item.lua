local super = require("ui.component.toggleitem")
local HomeEnvGridItem = class("HomeEnvGridItem", super)

function HomeEnvGridItem:OnInit()
  self.nameLab_ = self.uiBinder.lab_name
  self.toggle_ = self.uiBinder.toggle
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function HomeEnvGridItem:Refresh(data)
  self.nameLab_.text = data.name
  self.toggle_:SetIsOnWithoutCallBack(data.isOn)
  self.toggle_.IsDisabled = not data.isOn and not self.houseData_:CheckPlayerFurnitureEditLimit()
end

function HomeEnvGridItem:OnPointerClick(go, eventData)
end

function HomeEnvGridItem:OnUnInit()
end

return HomeEnvGridItem
