local super = require("ui.component.loop_list_view_item")
local SeasonShopBuySingleItem = class("SeasonShopBuySingleItem", super)
local item = require("common.item_binder")
local regionTab = {
  [E.FashionRegion.Suit] = "Suit",
  [E.FashionRegion.UpperClothes] = "Jacket",
  [E.FashionRegion.Pants] = "Bottoms",
  [E.FashionRegion.Gloves] = "Handguard",
  [E.FashionRegion.Shoes] = "Shoe",
  [E.FashionRegion.Tail] = "Tail",
  [E.FashionRegion.Headwear] = "Headgear",
  [E.FashionRegion.FaceMask] = "SurfaceDecoration",
  [E.FashionRegion.MouthMask] = "MouthDecoration",
  [E.FashionRegion.Earrings] = "Earring",
  [E.FashionRegion.Necklace] = "Necklace",
  [E.FashionRegion.Ring] = "Ring"
}

function SeasonShopBuySingleItem:OnInit()
  self.itemClass_ = item.new(self.parent.UIView)
  self.itemVM_ = Z.VMMgr.GetVM("items")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.shopData_ = Z.DataMgr.Get("shop_data")
  for i = 1, 2 do
    local uibinder = self.uiBinder[string.zconcat("shop_buy_item", i)]
    uibinder.btn_coupon:AddListener(function()
      if self.data_[i] == nil then
        return
      end
      Z.UIMgr:OpenView("shop_coupon_popup", {
        MailItemId = self.data_[i].mallItemRow.Id,
        data = self.data_[i].data
      })
    end)
    uibinder.btn_minus:AddListener(function()
      self.shopData_:RemoveShopBuyItemByMallItemId(self.data_[i].mallItemRow.Id)
      self.shopVm_.RefreshCost()
      Z.EventMgr:Dispatch(Z.ConstValue.Shop.FashionSelectItemDataChange, self.data_[i])
    end)
  end
end

function SeasonShopBuySingleItem:OnUnInit()
  self.itemClass_:UnInit()
end

function SeasonShopBuySingleItem:OnRefresh(data)
  self.data_ = data
  for i = 1, 2 do
    self:refreshItemInfo(self.data_[i], self.uiBinder[string.zconcat("shop_buy_item", i)])
  end
  self.loopListView:OnItemSizeChanged(self.Index)
end

function SeasonShopBuySingleItem:refreshItemInfo(data, item)
  if not data then
    item.Ref.UIComp:SetVisible(false)
    return
  end
  item.Ref.UIComp:SetVisible(true)
  local itemData = {
    configId = data.mallItemRow.ItemId,
    uiBinder = item.node_item,
    isSquareItem = true
  }
  self.itemClass_:Init(itemData)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.mallItemRow.ItemId)
  item.lab_name.text = itemRow.Name
  item.lab_have.text = ""
  local costItemId
  for id, _ in pairs(data.mallItemRow.Cost) do
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      item.rimg_price:SetImage(self.itemVM_.GetItemIcon(id))
      costItemId = id
    end
    break
  end
  local originalPrice = self.shopVm_.GetShopMallItemPrice(data.mallItemRow)
  local curPrice = originalPrice
  if costItemId and data.couponsList and #data.couponsList > 0 then
    curPrice = math.floor(self.shopVm_.CalculateCouponsCostByCouponsList(costItemId, originalPrice, data.couponsList))
  end
  item.lab_original.text = originalPrice
  item.lab_price.text = curPrice
  item.Ref:SetVisible(item.node_original, 0 < originalPrice and originalPrice ~= curPrice)
  self:refreshCoupons(data, item)
end

function SeasonShopBuySingleItem:refreshCoupons(data, item)
  local couponsData
  if data.couponsList and data.couponsList[1] then
    couponsData = data.couponsList[1]
  end
  if couponsData then
    item.Ref:SetVisible(item.btn_coupon, true)
    item.Ref:SetVisible(item.rimg_coupon_icon, true)
    item.rimg_coupon_icon:SetImage(self.itemVM_.GetItemIcon(couponsData.configId))
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(couponsData.configId)
    if itemcfg then
      item.lab_coupon.text = itemcfg.Name
    end
  else
    local allCouponsDataCount = 0
    local couponsData = self.shopData_:GetShopCouponsDataByMallItemTable(data.mallItemRow)
    if 0 < table.zcount(couponsData) then
      for _, row in pairs(couponsData) do
        if self.shopVm_.CheckCouponsCanUse(data.mallItemRow, row) then
          local count = self.itemVM_.GetItemTotalCount(row.Id)
          if 0 < count then
            allCouponsDataCount = allCouponsDataCount + 1
          end
        end
      end
    end
    if 0 < allCouponsDataCount then
      item.Ref:SetVisible(item.rimg_coupon_icon, false)
      item.lab_coupon.text = Lang("FashionShopNoUse")
    else
      item.Ref:SetVisible(item.btn_coupon, false)
    end
  end
end

return SeasonShopBuySingleItem
