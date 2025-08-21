local super = require("ui.component.loop_list_view_item")
local LifeWorkAwardLoopItem = class("LifeWorkAwardLoopItem", super)
local item = require("common.item_binder")

function LifeWorkAwardLoopItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function LifeWorkAwardLoopItem:OnRefresh(data)
  if data == nil then
    return
  end
  local itemData = {}
  itemData.configId = data.configId
  itemData.uiBinder = self.uiBinder
  itemData.isShowZero = false
  itemData.isShowOne = true
  itemData.uuid = data.uuid
  itemData.labType = E.ItemLabType.Num
  itemData.lab = data.count
  itemData.isSquareItem = true
  self.itemClass_:RefreshByData(itemData)
end

function LifeWorkAwardLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return LifeWorkAwardLoopItem
