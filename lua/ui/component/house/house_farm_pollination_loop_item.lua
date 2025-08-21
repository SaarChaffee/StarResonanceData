local super = require("ui.component.loop_list_view_item")
local HouseFarmPollinationLoopItem = class("HouseFarmPollinationLoopItem", super)
local item = require("common.item_binder")

function HouseFarmPollinationLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder.item_binder
  })
end

function HouseFarmPollinationLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

function HouseFarmPollinationLoopItem:OnRefresh(data)
  self.data_ = data
  local itemData = {}
  itemData.configId = data.ConfigId
  itemData.uiBinder = self.uiBinder.item_binder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.isSquareItem = true
  local count = 0
  for key, item in pairs(data.ownerToStackMap) do
    count = count + item.count
  end
  itemData.labType = E.ItemLabType.Str
  itemData.lab = count
  self.itemClass_:RefreshByData(itemData)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", data.ConfigId)
  if itemRow then
    self.uiBinder.lab_name.text = itemRow.Name
  end
end

function HouseFarmPollinationLoopItem:OnSelected()
end

return HouseFarmPollinationLoopItem
