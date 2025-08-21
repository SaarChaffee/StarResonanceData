local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_coupon_popupView = class("Shop_coupon_popupView", super)
local loopListView = require("ui.component.loop_list_view")
local seasonShopCouponLoopItem = require("ui.component.season.season_shop_coupon_loop_item")
local seasonShopItemTplHelper = require("ui.component.season.season_shop_item_tpl_helper")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Shop_coupon_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_coupon_popup")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.shopData_ = Z.DataMgr.Get("shop_data")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
end

function Shop_coupon_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, Z.SystemItem.DefaultCurrencyDisplay)
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_confirmed, function()
    if self.selectShopItem_ ~= nil then
      self.shopData_:ChangeShopBuyItemCoupons(self.selectShopItem_.mallItemRow.Id, self.coupons_)
    end
    self.shopVm_.RefreshCost()
    Z.EventMgr:Dispatch(Z.ConstValue.FashionShopChangeCoupon)
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
  self.selectShopItem_ = nil
  self.coupons_ = {}
  self.useCouponsUuids_ = {}
  self.costItemId_ = nil
  for _, mallData in pairs(self.shopData_.ShopBuyItemInfoList) do
    for _, shopItemData in pairs(mallData) do
      if shopItemData.mallItemRow.Id == self.viewData.MailItemId then
        self.selectShopItem_ = shopItemData
        if self.selectShopItem_.couponsList ~= nil then
          self.coupons_ = table.zdeepCopy(self.selectShopItem_.couponsList)
        end
      end
    end
  end
  if self.selectShopItem_ == nil then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
    return
  end
  self.allCouponList_ = {}
  local allCouponsDataCount = 0
  for _, value in ipairs(self.coupons_) do
    self.useCouponsUuids_[value.uuid] = value.count
  end
  local couponsData = self.shopData_:GetShopCouponsDataByMallItemTable(self.selectShopItem_.mallItemRow)
  for _, row in pairs(couponsData) do
    if self.shopVm_.CheckCouponsCanUse(self.selectShopItem_.mallItemRow, row) then
      local uuids, count = self:getCanUseCouponsItem(row.Id)
      if 0 < count then
        for _, uuidInfo in ipairs(uuids) do
          allCouponsDataCount = allCouponsDataCount + 1
          self.allCouponList_[allCouponsDataCount] = {
            configId = row.Id,
            uuid = uuidInfo.uuid,
            maxCount = uuidInfo.count,
            count = self.useCouponsUuids_[uuidInfo.uuid] == nil and 0 or self.useCouponsUuids_[uuidInfo.uuid]
          }
        end
      end
    end
  end
  if allCouponsDataCount == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_empty, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_info, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_line, true)
  self.loopList_ = loopListView.new(self, self.uiBinder.scrollview, seasonShopCouponLoopItem, "shop_coupon_item_tpl")
  self.loopList_:Init(self.allCouponList_)
  local itemHelper = seasonShopItemTplHelper.new(self.uiBinder.season_shop_item_tpl)
  itemHelper:Refresh(self.viewData.data)
  for id, _ in pairs(self.selectShopItem_.mallItemRow.Cost) do
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      local itemsVM = Z.VMMgr.GetVM("items")
      local address = itemsVM.GetItemIcon(id)
      self.uiBinder.rimg_original_price_icon:SetImage(address)
      self.uiBinder.rimg_all_price_icon:SetImage(address)
      self.costItemId_ = id
    end
    break
  end
  self:refreshCost()
end

function Shop_coupon_popupView:OnDeActive()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  self.selectShopItem_ = nil
  self.coupons_ = {}
  self.costItemId_ = nil
  if self.loopList_ then
    self.loopList_:UnInit()
  end
end

function Shop_coupon_popupView:OnRefresh()
end

function Shop_coupon_popupView:ChangeCoupon(data)
  local addCoupons = true
  local delKey
  for key, value in ipairs(self.coupons_) do
    if data.configId == value.configId and data.uuid == value.uuid then
      value.count = data.count
      addCoupons = false
      if value.count == 0 then
        delKey = key
      end
      break
    end
  end
  if delKey then
    table.remove(self.coupons_, delKey)
  end
  if addCoupons then
    self.coupons_[#self.coupons_ + 1] = {
      configId = data.configId,
      uuid = data.uuid,
      count = data.count
    }
  end
  self.useCouponsUuids_[data.uuid] = data.count
  for key, value in ipairs(self.allCouponList_) do
    self.allCouponList_[key].count = self.useCouponsUuids_[value.uuid] == nil and 0 or self.useCouponsUuids_[value.uuid]
  end
  self.loopList_:RefreshListView(self.allCouponList_)
  self:refreshCost()
end

function Shop_coupon_popupView:refreshCost()
  if self.selectShopItem_ == nil then
    return
  end
  local originalPrice
  for id, num in pairs(self.selectShopItem_.mallItemRow.OriginalPrice) do
    if id ~= 0 then
      originalPrice = Z.NumTools.FormatNumberWithCommas(num)
      self.uiBinder.lab_original_num.text = originalPrice
    end
    break
  end
  local showPrice = self.shopVm_.GetShopMallItemPrice(self.selectShopItem_.mallItemRow)
  if originalPrice == nil then
    self.uiBinder.lab_original_num.text = showPrice
  end
  self.uiBinder.lab_all_num.text = showPrice
  if 0 < #self.coupons_ and self.costItemId_ ~= nil then
    local costValue = math.floor(self.shopVm_.CalculateCouponsCostByCouponsList(self.costItemId_, showPrice, self.coupons_))
    self.uiBinder.lab_all_num.text = costValue
  else
    self.uiBinder.lab_all_num.text = showPrice
  end
end

function Shop_coupon_popupView:getCanUseCouponsItem(itemId)
  local useCoupons = {}
  local shopBuyItemInfoList = self.shopData_.ShopBuyItemInfoList
  for _, mallData in pairs(shopBuyItemInfoList) do
    for _, data in pairs(mallData) do
      if data.mallItemRow.Id ~= self.viewData.MailItemId and data.couponsList then
        for _, couponsData in ipairs(data.couponsList) do
          if useCoupons[couponsData.uuid] == nil then
            useCoupons[couponsData.uuid] = {}
          end
          useCoupons[couponsData.uuid] = couponsData.count
        end
      end
    end
  end
  local unUseUuids = {}
  local unUseUuidCount = 0
  local itemData = Z.DataMgr.Get("items_data")
  local uuidList = itemData:GetItemUuidsByConfigId(itemId)
  if uuidList then
    for i = 1, #uuidList do
      local uuid = uuidList[i]
      local itemInfo = self.itemVm_.GetItemInfo(uuid, E.BackPackItemPackageType.Item)
      if itemInfo then
        local useCount = 0
        if useCoupons[uuid] then
          useCount = useCoupons[uuid]
        end
        if useCount < itemInfo.count then
          unUseUuidCount = unUseUuidCount + 1
          unUseUuids[unUseUuidCount] = {
            uuid = uuidList[i],
            count = itemInfo.count - useCount
          }
        end
      end
    end
  end
  return unUseUuids, unUseUuidCount
end

function Shop_coupon_popupView:GetCanUseCouponsCount(data)
  local isExist = false
  local useCouponsCount = 0
  local surpluseCouponsCount = 0
  if self.coupons_ then
    for _, value in ipairs(self.coupons_) do
      if 0 < value.count then
        useCouponsCount = useCouponsCount + 1
        if value.configId == data.configId then
          isExist = true
          surpluseCouponsCount = surpluseCouponsCount + value.count
        end
      end
    end
  end
  if not isExist and 0 < useCouponsCount then
    return 0
  end
  local config = Z.TableMgr.GetTable("MallCouponsTableMgr").GetRow(data.configId)
  if config == nil then
    return 0
  end
  return config.LimitNum - surpluseCouponsCount
end

return Shop_coupon_popupView
