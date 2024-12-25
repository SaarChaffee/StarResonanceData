local super = require("ui.component.loop_list_view_item")
local EquipRefineConsumetItem = class("EquipRefineConsumetItem", super)
local item = require("common.item_binder")

function EquipRefineConsumetItem:ctor()
  self.itemData_ = nil
  super:ctor()
end

function EquipRefineConsumetItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function EquipRefineConsumetItem:OnRefresh(data)
  self.itemClass_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data[1],
    labType = E.ItemLabType.Expend,
    lab = self.itemsVm_.GetItemTotalCount(data[1]),
    expendCount = data[2],
    isSquareItem = true
  })
end

function EquipRefineConsumetItem:OnUnInit()
  self.itemClass_:UnInit()
end

return EquipRefineConsumetItem
