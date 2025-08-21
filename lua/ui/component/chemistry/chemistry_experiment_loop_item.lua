local super = require("ui.component.loop_grid_view_item")
local ChemistryExperimentLoopItem = class("ChemistryExperimentLoopItem", super)
local itemBinder = require("common.item_binder")

function ChemistryExperimentLoopItem:ctor()
  self.itemVm_ = Z.VMMgr.GetVM("items")
end

function ChemistryExperimentLoopItem:OnInit()
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function ChemistryExperimentLoopItem:OnRefresh(data)
  self.data = data
  local itemData = {
    uuid = data.itemUuid,
    configId = data.configId,
    itemInfo = data.itemInfo
  }
  self.itemBinder_:RefreshByData(itemData)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_nature, not self.data.condition)
  self.itemBinder_:SetSelected(self.IsSelected, self.IsSelected)
end

function ChemistryExperimentLoopItem:OnSelected(isSelected)
  self.itemBinder_:SetSelected(isSelected, isSelected)
  if isSelected then
    self.parent.UIView:SetSelectItem(self.data)
  end
end

function ChemistryExperimentLoopItem:OnUnInit()
  self.itemBinder_:UnInit()
end

return ChemistryExperimentLoopItem
