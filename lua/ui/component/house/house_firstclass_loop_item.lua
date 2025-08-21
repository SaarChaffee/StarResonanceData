local super = require("ui.component.toggleitem")
local HouseFirstClassLoopItem = class("HouseFirstClassLoopItem", super)
local bagRed = require("rednode.bag_red")

function HouseFirstClassLoopItem:ctor()
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function HouseFirstClassLoopItem:OnInit()
  self.backpackVm_ = Z.VMMgr.GetVM("backpack")
  self.houseData_ = Z.DataMgr.Get("house_data")
end

function HouseFirstClassLoopItem:Refresh()
  local groupId = self.houseData_.HousingItemGroupTypes[self.index]
  local housingItemsTypeGroupRow = Z.TableMgr.GetRow("HousingItemsTypeGroupMgr", groupId)
  if housingItemsTypeGroupRow then
    self.uiBinder.lab_off.text = housingItemsTypeGroupRow.GroupName
    self.uiBinder.lab_on.text = housingItemsTypeGroupRow.GroupName
  end
end

function HouseFirstClassLoopItem:refreshLines()
end

function HouseFirstClassLoopItem:UnInit()
  self.component.group = nil
  self.component.isOn = false
end

return HouseFirstClassLoopItem
