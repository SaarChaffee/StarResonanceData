local super = require("ui.component.loop_grid_view_item")
local SeasonShopBuySuitSingleItem = class("SeasonShopBuySuitSingleItem", super)
local item = require("common.item_binder")

function SeasonShopBuySuitSingleItem:OnInit()
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
end

function SeasonShopBuySuitSingleItem:OnUnInit()
  self.itemClass_:UnInit()
end

function SeasonShopBuySuitSingleItem:OnRefresh(data)
  self.itemClass_ = item.new(data.parent)
  local itemData = {
    configId = data.row.ItemId,
    uiBinder = self.uiBinder.node_item,
    isSquareItem = true
  }
  self.itemClass_:Init(itemData)
  local originalValue = self.shopVm_.GetShopMallItemOriginal(data.row)
  self.uiBinder.lab_original.text = originalValue
  for id, _ in pairs(data.row.Cost) do
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      self.uiBinder.rimg_price:SetImage(self.itemVM_.GetItemIcon(id))
    end
    break
  end
  local haveCount = self.itemVM_.GetItemTotalCount(data.row.ItemId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_get, 0 < haveCount)
  if 0 < haveCount then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_have, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_price, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_have, false)
    self.uiBinder.lab_price.text = self.shopVm_.GetShopMallItemPrice(data.row)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_all_price, true)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_original, 0 < originalValue)
end

return SeasonShopBuySuitSingleItem
