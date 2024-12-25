local super = require("ui.component.loopscrollrectitem")
local item = require("common.item_binder")
local DialogLoopItem = class("DialogLoopItem", super)

function DialogLoopItem:OnInit()
  self.showItemId_ = 0
  self.itemClass_ = item.new(self.parent.uiView)
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function DialogLoopItem:OnReset()
end

function DialogLoopItem:Refresh()
  local index = self.component.Index + 1
  self.data_ = self.parent:GetDataByIndex(index)
  if self.data_ == nil then
    return
  end
  if self.showItemId_ ~= self.data_.ItemId then
    self.showItemId_ = self.data_.ItemId
    local itemData = {
      uiBinder = self.uiBinder,
      configId = self.data_.ItemId,
      lab = self.data_.ItemNum,
      isShowReceive = self.data_.received,
      PrevDropType = self.data_.PrevDropType,
      isSquareItem = true
    }
    itemData.labType = self.data_.LabType or E.ItemLabType.Num
    if self.data_.LabType == E.ItemLabType.Expend then
      if self.data_.OverrideItemNum then
        itemData.lab = self.data_.OverrideItemNum
      else
        itemData.lab = self.itemsVM_.GetItemTotalCount(self.data_.ItemId)
      end
      itemData.expendCount = self.data_.ItemNum
    end
    self.itemClass_:RefreshByData(itemData)
  end
end

function DialogLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return DialogLoopItem
