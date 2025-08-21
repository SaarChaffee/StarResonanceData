local super = require("ui.component.loop_list_view_item")
local GashaDetailsLoopItem = class("GashaDetailsLoopItem", super)
local item = require("common.item_binder")

function GashaDetailsLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function GashaDetailsLoopItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemData = {}
  itemData.configId = data.awardId
  itemData.uiBinder = self.uiBinder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.labType = E.ItemLabType.Num
  itemData.lab = data.awardNum
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
end

function GashaDetailsLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return GashaDetailsLoopItem
