local super = require("ui.component.loop_list_view_item")
local FaceUnlockLoopItem = class("FaceUnlockLoopItem", super)
local item = require("common.item_binder")

function FaceUnlockLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_ = item.new(self.parent.UIView)
end

function FaceUnlockLoopItem:OnRefresh(data)
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

function FaceUnlockLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return FaceUnlockLoopItem
