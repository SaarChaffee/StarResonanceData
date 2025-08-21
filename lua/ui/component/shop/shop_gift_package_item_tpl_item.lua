local super = require("ui.component.loop_grid_view_item")
local ShopGiftPackageItemTplItem = class("ShopGiftPackageItemTplItem", super)
local itemBinder = require("common.item_binder")

function ShopGiftPackageItemTplItem:ctor()
end

function ShopGiftPackageItemTplItem:OnInit()
  self.itemBinder_ = itemBinder.new(self.parent.UIView)
  self.itemBinder_:Init({
    uiBinder = self.uiBinder
  })
end

function ShopGiftPackageItemTplItem:OnUnInit()
  self.itemBinder_:UnInit()
  self.itemBinder_ = nil
end

function ShopGiftPackageItemTplItem:OnRefresh(data)
  self.itemBinder_:RefreshByData({
    uiBinder = self.uiBinder,
    configId = data.awardId,
    lab = data.awardNum,
    isShowReceive = false,
    isSquareItem = true
  })
end

return ShopGiftPackageItemTplItem
