local super = require("ui.component.loop_list_view_item")
local EquipBreakLoopItem = class("EquipBreakLoopItem", super)
local item = require("common.item_binder")

function EquipBreakLoopItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function EquipBreakLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.uiView_)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function EquipBreakLoopItem:OnRefresh(data)
  local itemData = {
    uiBinder = self.uiBinder,
    configId = data[1],
    labType = E.ItemLabType.Expend,
    expendCount = data[2],
    lab = self.itemVm_.GetItemTotalCount(data[1]),
    isSquareItem = true
  }
  self.itemClass_:RefreshByData(itemData)
end

function EquipBreakLoopItem:OnSelected(isSelected)
end

function EquipBreakLoopItem:OnRecycle()
end

function EquipBreakLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function EquipBreakLoopItem:OnBeforePlayAnim()
end

return EquipBreakLoopItem
