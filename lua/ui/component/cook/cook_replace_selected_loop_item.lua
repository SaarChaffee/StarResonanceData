local super = require("ui.component.loop_grid_view_item")
local CookReplaceSelectedLoopItem = class("CookReplaceSelectedLoopItem", super)
local itemClass = require("common.item_binder")

function CookReplaceSelectedLoopItem:ctor()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function CookReplaceSelectedLoopItem:OnInit()
  self.uiView_ = self.parent.UIView
  self.itemClass_ = itemClass.new(self.uiView_)
  self.itemClass_:Init({
    uiBinder = self.uiBinder
  })
end

function CookReplaceSelectedLoopItem:OnRefresh(data)
  self.data_ = data
  local itemPreviewData = {
    uiBinder = self.uiBinder,
    configId = self.data_.Id,
    isSquareItem = true,
    isClickOpenTips = false,
    lab = self.itemsVM_.GetItemTotalCount(self.data_.Id)
  }
  itemPreviewData.labType = E.ItemLabType.Num
  self.itemClass_:RefreshByData(itemPreviewData)
end

function CookReplaceSelectedLoopItem:OnBeforePlayAnim()
end

function CookReplaceSelectedLoopItem:OnPointerClick(go, eventData)
  self.uiView_:OnSelected(self.data_)
end

function CookReplaceSelectedLoopItem:OnUnInit()
  self.itemClass_:UnInit()
end

return CookReplaceSelectedLoopItem
