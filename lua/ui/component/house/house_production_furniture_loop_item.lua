local super = require("ui.component.loop_grid_view_item")
local PlayerPortraitHgr = require("ui.component.role_info.common_player_portrait_item_mgr")
local itemClass = require("common.item_binder")
local HouseProductionFurnitureLoopItem = class("HouseProductionFurnitureLoopItem", super)

function HouseProductionFurnitureLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = itemClass.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.homeEditorData_ = Z.DataMgr.Get("home_editor_data")
  Z.EventMgr:Add(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
end

function HouseProductionFurnitureLoopItem:OnRefresh(data)
  self.data_ = data
  local count = self.homeEditorData_:GetFurnitureWarehouseItemCount(data.Id)
  local itemData = {}
  itemData.uiBinder = self.uiBinder
  itemData.configId = data.Id
  itemData.isClickOpenTips = false
  itemData.labType = E.ItemLabType.Str
  itemData.lab = count
  itemData.isShowZero = true
  self.itemClass_:RefreshByData(itemData)
end

function HouseProductionFurnitureLoopItem:OnSelected(OnSelected)
  self.itemClass_:SetSelected(OnSelected)
  if OnSelected then
    self.uiView_:OnSelectedFurnitureItem(self.data_)
  end
end

function HouseProductionFurnitureLoopItem:refreshCount()
  local count = self.homeEditorData_:GetFurnitureWarehouseItemCount(self.data_.Id)
  self.itemClass_:SetLab(count)
end

function HouseProductionFurnitureLoopItem:OnRecycle()
  Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
end

function HouseProductionFurnitureLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Home.RefreshWareHouseCount, self.refreshCount, self)
end

return HouseProductionFurnitureLoopItem
