local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_buy_popupView = class("Shop_buy_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local season_shop_buy_single_item = require("ui.component.season.season_shop_buy_single_item")
local season_shop_buy_suit_item = require("ui.component.season.season_shop_buy_suit_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Shop_buy_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_buy_popup")
  self.shopData_ = Z.DataMgr.Get("shop_data")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.itemVM_ = Z.VMMgr.GetVM("items")
end

function Shop_buy_popupView:OnActive()
  self.uiBinder.scene_mask:SetSceneMaskByKey(self.SceneMaskKey)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.DefaultCurrencyDisplay)
  self.loopList_ = loopListView.new(self, self.uiBinder.loop_list)
  self.loopList_:SetGetItemClassFunc(function(data)
    if data.IsSuit then
      return season_shop_buy_suit_item
    else
      return season_shop_buy_single_item
    end
  end)
  self.loopList_:SetGetPrefabNameFunc(function(data)
    if data.IsSuit then
      return "shop_buy_suit_item_tpl"
    else
      return "shop_buy_single_item_list"
    end
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    self.shopVm_.CloseShopBuyPopup()
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    self.shopVm_.CloseShopBuyPopup()
  end)
  self:AddAsyncClick(self.uiBinder.btn_buy, function()
    for i = 1, #self.shopData_.ShopCostList do
      local costData = self.shopData_.ShopCostList[1]
      if costData.costId > 0 then
        local haveCount = self.itemVM_.GetItemTotalCount(costData.costId)
        if self:showCountTips(costData.costValue, haveCount, costData.costId) then
          return
        end
      end
    end
    if self:checkWeaponSkinLimit() then
      local dialogViewData = {
        dlgType = E.DlgType.YesNo,
        labDesc = Lang("DescFashionShopWeaponSkinLimit"),
        onConfirm = function()
          self:confirmBuy()
        end
      }
      Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
      return
    end
    self:confirmBuy()
  end)
  self.uiBinder.lab_num.text = self.shopData_:GetShopBuyItemInfoListCount()
  self:refreshLoopList(true)
  self:refreshCost()
  Z.EventMgr:Add(Z.ConstValue.Shop.FashionSelectItemDataChange, self.fashionShopChangeCoupon, self)
  Z.EventMgr:Add(Z.ConstValue.FashionShopChangeCoupon, self.fashionShopChangeCoupon, self)
end

function Shop_buy_popupView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Shop.FashionSelectItemDataChange, self.fashionShopChangeCoupon, self)
  Z.EventMgr:Remove(Z.ConstValue.FashionShopChangeCoupon, self.fashionShopChangeCoupon, self)
  self.loopList_:UnInit()
  self.currencyItemList_:UnInit()
  self.currencyItemList_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
end

function Shop_buy_popupView:refreshLoopList(isFirst)
  local showList = {}
  local curDataIndex
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      local group = data.mallItemRow.Group
      if group and 0 < #group then
        table.insert(showList, 1, {data = data, IsSuit = true})
      else
        curDataIndex = curDataIndex or #showList + 1
        if not showList[curDataIndex] then
          showList[curDataIndex] = {}
          showList[curDataIndex].IsSuit = false
        end
        if not showList[curDataIndex][1] then
          showList[curDataIndex][1] = data
        elseif not showList[curDataIndex][2] then
          showList[curDataIndex][2] = data
          curDataIndex = nil
        end
      end
    end
  end
  if isFirst then
    self.loopList_:Init(showList)
  else
    self.loopList_:RefreshListView(showList)
  end
end

function Shop_buy_popupView:fashionShopChangeCoupon()
  if self.shopData_:GetShopBuyItemInfoListCount() == 0 then
    self.shopVm_.CloseShopBuyPopup()
    return
  end
  self:refreshLoopList(false)
  self:refreshCost()
end

function Shop_buy_popupView:refreshCost()
  local costList = self.shopData_.ShopCostList
  local costTypeCount = 0
  for i = 1, #costList do
    if 0 < costList[i].costId then
      costTypeCount = costTypeCount + 1
    end
  end
  if 1 < costTypeCount then
    self:refreshPriceData(1, costList[1])
    self:refreshPriceData(2, costList[2])
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_price, true)
  else
    self:refreshPriceData(2, costList[1])
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_price, false)
  end
end

function Shop_buy_popupView:refreshPriceData(index, costData)
  local original = costData.originalValue
  local all = costData.costValue
  self.uiBinder.Ref:SetVisible(self.uiBinder[string.zconcat("node_original", index)], false)
  self.uiBinder[string.zconcat("lab_original", index)].text = original
  self.uiBinder[string.zconcat("lab_all", index)].text = all
  local icon = self.itemVM_.GetItemIcon(costData.costId)
  self.uiBinder[string.zconcat("rimg_price", index)]:SetImage(icon)
  self.uiBinder[string.zconcat("rimg_all_price", index)]:SetImage(icon)
end

function Shop_buy_popupView:showCountTips(price, have, costType)
  if 0 < price and have < price then
    local costItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costType)
    if costItemRow then
      Z.TipsVM.ShowTips(100010, {
        item = {
          name = costItemRow.Name
        }
      })
    else
      Z.TipsVM.ShowTips(4801)
    end
    if costType == Z.SystemItem.ItemDiamond or costType == Z.SystemItem.ItemEnergyPoint then
      self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.node_tips, costType)
    end
    return true
  end
  return false
end

function Shop_buy_popupView:checkWeaponSkinLimit()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local curProfessionId = weaponVm.GetCurWeapon()
  local weaponData = Z.TableMgr.GetTable("WeaponSkinTableMgr")
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      if data.mallItemRow.FunctionId == E.FunctionID.WeaponShop or data.mallItemRow.FunctionId == E.FunctionID.WeaponShop2 then
        local row = weaponData.GetRow(data.mallItemRow.Id, true)
        if row and row.ProfessionId ~= curProfessionId then
          return true
        end
      end
    end
  end
  return false
end

function Shop_buy_popupView:confirmBuy()
  local buyList = {}
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      local itemId = data.mallItemRow.Id
      local couponsList = {}
      if data.couponsList then
        for _, couponsData in pairs(data.couponsList) do
          couponsList[couponsData.configId] = couponsData.count
        end
      end
      buyList[itemId] = {buyNum = 1, couponInfo = couponsList}
    end
  end
  self.shopVm_.AsyncShopBuyItemList(buyList, self.cancelSource:CreateToken())
  self.shopVm_.CloseShopBuyPopup()
  Z.EventMgr:Dispatch(Z.ConstValue.FashionShopBuyItem)
end

return Shop_buy_popupView
