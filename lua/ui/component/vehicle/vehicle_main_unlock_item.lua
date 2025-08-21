local super = require("ui.component.loop_list_view_item")
local VehicleMainUnlockItem = class("VehicleMainUnlockItem", super)
local itemBinder = require("common.item_binder")

function VehicleMainUnlockItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function VehicleMainUnlockItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data.configId,
    labType = E.ItemLabType.Expend,
    lab = self.itemsVM_.GetItemTotalCount(data.configId),
    expendCount = data.count,
    isSquareItem = true
  }
  self.itemBinder_:RefreshByData(itemData)
end

function VehicleMainUnlockItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return VehicleMainUnlockItem
