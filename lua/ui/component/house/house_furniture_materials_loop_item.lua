local super = require("ui.component.loop_grid_view_item")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local itemClass = require("common.item_binder")
local HouseMaterialsLoopItem = class("HouseMaterialsLoopItem", super)

function HouseMaterialsLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = itemClass.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function HouseMaterialsLoopItem:OnRefresh(data)
  local curSelectedCount = self.uiView_:GetCurSelectedCount() or 1
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data[1]
  itemData.labType = E.ItemLabType.Expend
  itemData.lab = self.itemsVm_.GetItemTotalCount(data[1])
  itemData.expendCount = data[2] * math.max(curSelectedCount, 1)
  self.itemClass_:RefreshByData(itemData)
end

function HouseMaterialsLoopItem:OnSelected(OnSelected)
end

function HouseMaterialsLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return HouseMaterialsLoopItem
