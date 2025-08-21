local super = require("ui.component.loop_list_view_item")
local HouseFarmManureLoopItem = class("HouseFarmManureLoopItem", super)
local item = require("common.item_binder")

function HouseFarmManureLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_binder
  })
end

function HouseFarmManureLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function HouseFarmManureLoopItem:OnRefresh(data)
  local itemData = {}
  itemData.configId = data[1]
  itemData.uiBinder = self.uiBinder.item_binder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", data[1])
  if itemRow then
    self.uiBinder.lab_name.text = itemRow.Name
  end
end

function HouseFarmManureLoopItem:OnSelected()
end

return HouseFarmManureLoopItem
