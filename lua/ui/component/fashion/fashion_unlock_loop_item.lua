local super = require("ui.component.loop_list_view_item")
local FashionUnlockLoopItem = class("FashionUnlockLoopItem", super)
local item = require("common.item_binder")

function FashionUnlockLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self.parent.UIView)
end

function FashionUnlockLoopItem:OnRefresh(data)
  if not data then
    return
  end
  local itemId = data.ItemId
  local unlockNum = data.UnlockNum
  local ownNum = self.itemsVM_.GetItemTotalCount(itemId)
  self.itemClass_:Init({
    uiBinder = self.uiBinder,
    configId = itemId,
    lab = ownNum,
    expendCount = unlockNum,
    labType = E.ItemLabType.Expend,
    isSquareItem = true
  })
end

function FashionUnlockLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return FashionUnlockLoopItem
