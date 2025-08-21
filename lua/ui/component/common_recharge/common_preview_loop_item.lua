local super = require("ui.component.loop_list_view_item")
local CommonPreviewLoopItem = class("CommonPreviewLoopItem", super)
local itemBinder = require("common.item_binder")

function CommonPreviewLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVm_ = Z.VMMgr.GetVM("awardpreview")
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function CommonPreviewLoopItem:OnRefresh(data)
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.awardId,
    lab = data.awardNum,
    isShowReceive = false,
    isSquareItem = true
  })
end

function CommonPreviewLoopItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

return CommonPreviewLoopItem
