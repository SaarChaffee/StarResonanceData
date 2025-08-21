local super = require("ui.component.loop_list_view_item")
local WeaponSkillSkinAvtiveItem = class("WeaponSkillSkinAvtiveItem", super)
local item = require("common.item_binder")

function WeaponSkillSkinAvtiveItem:ctor()
end

function WeaponSkillSkinAvtiveItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function WeaponSkillSkinAvtiveItem:OnRefresh(data)
  self.configId_ = data[1]
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data[1]
  itemData.expendCount = data[2]
  itemData.labType = E.ItemLabType.Expend
  local totalCount = self.itemVm_.GetItemTotalCount(data[1])
  self.itemClass_:Init(itemData)
  self.itemClass_:SetExpendCount(totalCount, data[2])
end

function WeaponSkillSkinAvtiveItem:OnSelected(isSelected, isClick)
end

return WeaponSkillSkinAvtiveItem
