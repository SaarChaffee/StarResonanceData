local UI = Z.UI
local super = require("ui.view.shop_fashion_base_view")
local Shop_fashion_gift_subView = class("Shop_fashion_gift_subView", super)
local loopListView = require("ui.component.loop_list_view")
local shop_fashion_gift_loop_item = require("ui.component.shop.shop_fashion_gift_loop_item")

function Shop_fashion_gift_subView:ctor(parent)
  self.uiBinder = nil
  self.viewData = nil
  super.subCtor(self, "shop_fashion_gift_sub", "shop/shop_fashion_gift_sub", UI.ECacheLv.None, true)
end

function Shop_fashion_gift_subView:OnActive()
  super.OnActive(self)
  self:initShopList()
  self:refreshBtnState()
  self:refreshShopList()
end

function Shop_fashion_gift_subView:OnDeActive()
  super.OnDeActive(self)
  self.shopGridView_:UnInit()
end

function Shop_fashion_gift_subView:RefreshData(data)
  if data then
    self.viewData.shopData = data
  end
  self:refreshShopList()
end

function Shop_fashion_gift_subView:initShopList()
  if not self.viewData.mallTableRow then
    return
  end
  self.shopGridView_ = loopListView.new(self, self.uiBinder.loop_shop, shop_fashion_gift_loop_item, "shop_fashion_gift_item_tpl", true)
  self.shopGridView_:Init({})
end

function Shop_fashion_gift_subView:refreshBtnState()
  self.uiBinder.lab_goto.text = Lang("Fashion")
  self.uiBinder.img_goto:SetImage("ui/atlas/item/c_tab_icon/com_icon_tab_10")
end

function Shop_fashion_gift_subView:refreshShopList()
  local itemList = self:GetShopItemList(self.viewData.mallTableRow.Id)
  self.shopGridView_:RefreshListView(itemList, false)
  self.shopGridView_:ClearAllSelect()
  self:refreshItemSelect(itemList)
end

function Shop_fashion_gift_subView:refreshItemSelect(items)
  self.shopGridView_:ClearAllSelect()
  if self.viewData.configId then
    local index = 1
    for i = 1, #items do
      if items[i].cfg and items[i].cfg.ItemId == self.viewData.configId then
        index = i
        break
      end
    end
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
    self.viewData.configId = nil
  elseif self.viewData.shopItemIndex then
    local index = self.viewData.shopItemIndex
    self:clearShopItemIndex()
    self.shopGridView_:MovePanelToItemIndex(index)
    self.shopGridView_:SetSelected(index)
  end
end

function Shop_fashion_gift_subView:OnClickGiftItem(data, index, state)
  self:OpenBuyPopup(data, index, state)
end

function Shop_fashion_gift_subView:OnAddMallItem()
  self:RefreshPlayerWear()
  self.viewData.parentView:RefreshWearSetting()
end

function Shop_fashion_gift_subView:onClickFashion()
  if not self.curSelectData_ then
    self.fashionVM_.OpenFashionSystemView()
    return
  end
  if self.curSelectData_.fashoinId then
    if self.curSelectData_.mallItemRow and #self.curSelectData_.mallItemRow.FashionList > 0 then
      local fashinIdList = {}
      for i = 1, #self.curSelectData_.mallItemRow.FashionList do
        if self.fashionVM_.CheckIsFashion(self.curSelectData_.mallItemRow.FashionList[i]) then
          fashinIdList[#fashinIdList + 1] = self.curSelectData_.mallItemRow.FashionList[i]
        end
      end
      self.fashionVM_.OpenFashionSystemView({
        FashionId = self.curSelectData_.fashoinId,
        FashionIdList = fashinIdList
      })
    else
      self.fashionVM_.OpenFashionSystemView({
        FashionId = self.curSelectData_.fashoinId
      })
    end
  else
    self.fashionVM_.OpenFashionSystemView()
  end
end

return Shop_fashion_gift_subView
