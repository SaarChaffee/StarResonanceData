local super = require("ui.component.loop_list_view_item")
local HouseFarmSeedLoopItem = class("HouseFarmSeedLoopItem", super)
local item = require("common.item_binder")

function HouseFarmSeedLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = item.new(self.uiView_)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_binder
  })
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function HouseFarmSeedLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function HouseFarmSeedLoopItem:OnRefresh(data)
  local isManureState = self.uiView_:GetIsManureState()
  self.data_ = data
  local configId = isManureState and data or data.ConfigId
  local itemData = {}
  itemData.configId = configId
  itemData.uiBinder = self.uiBinder.item_binder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  itemData.isClickOpenTips = false
  local count = 0
  if not isManureState then
    for key, item in pairs(data.ownerToStackMap) do
      count = count + item.count
    end
  else
    count = self.itemsVm_.GetItemTotalCount(configId)
  end
  itemData.labType = E.ItemLabType.Str
  itemData.lab = count
  self.itemClass_:RefreshByData(itemData)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if itemRow then
    self.uiBinder.lab_name.text = itemRow.Name
  end
  self.itemClass_:SetSelected(self.IsSelected)
end

function HouseFarmSeedLoopItem:OnSelected(isSelected)
  if isSelected then
    self.uiView_:OnSelectedItem(self.data_)
  end
  self.itemClass_:SetSelected(isSelected)
end

return HouseFarmSeedLoopItem
