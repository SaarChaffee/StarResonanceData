local super = require("ui.component.loop_list_view_item")
local ShopGiftLoopItem = class("ShopGiftLoopItem", super)
local rechargeActivityDefine = require("ui.model.recharge_activity_define")

function ShopGiftLoopItem:ctor()
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.paymentVM_ = Z.VMMgr.GetVM("payment")
end

function ShopGiftLoopItem:OnInit()
end

function ShopGiftLoopItem:OnUnInit()
end

function ShopGiftLoopItem:OnRefresh(data)
  self.data_ = data
  if self.data_ == nil then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.uiBinder.lab_name.text = data.payRechargeConfig.Name
  self.uiBinder.img_char:SetImage(data.payRechargeConfig.PackageIcon)
  self.uiBinder.rimg_bg:SetImage(data.payRechargeConfig.BaseIcon)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_purchase, #data.limitTimes > 0)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_discount, false)
  local nowTime = Z.TimeTools.Now() / 1000
  if nowTime <= data.rewardBeginTime then
    self.uiBinder.canvas_bg.alpha = 0.5
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_expired, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_open_time, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_sell_out, false)
    local tempTime = data.rewardBeginTime - nowTime
    self.uiBinder.lab_open_time.text = string.zconcat(Z.TimeFormatTools.Tp2YMDHMS(tempTime), Lang("OnTheShelf"))
  elseif (data.rewardBeginTime == 0 or nowTime >= data.rewardBeginTime) and (data.rewardEndTime == 0 or nowTime <= data.rewardEndTime) then
    self.uiBinder.canvas_bg.alpha = 1
    local isReceived = false
    for _, value in ipairs(data.limitTimes) do
      if value.times == value.maxTimes then
        isReceived = true
        break
      end
    end
    if isReceived then
      self.uiBinder.canvas_bg.alpha = 0.5
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_expired, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_open_time, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_sell_out, true)
    else
      self.uiBinder.canvas_bg.alpha = 1
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, false)
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_sell_out, false)
    end
    if data.payRechargeConfig.Label then
      for _, lab in ipairs(data.payRechargeConfig.Label) do
        if tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Discount then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_discount, true)
          if data.payRechargeConfig and data.paymentConfig then
            local discount = math.floor(data.paymentConfig.Price / data.payRechargeConfig.ShowOriginalPrice * 100)
            self.uiBinder.lab_discount.text = discount .. "%"
          else
            self.uiBinder.lab_discount.text = ""
          end
        elseif tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Text then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_discount, true)
          self.uiBinder.lab_discount.text = Lang(lab[2])
        elseif tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Time and nowTime <= data.rewardEndTime and nowTime > data.rewardBeginTime then
          self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, true)
          self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(data.rewardEndTime - nowTime)
        end
      end
    end
  else
    self.uiBinder.canvas_bg.alpha = 0.5
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_mask, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_expired, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_open_time, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_sell_out, false)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_symbol, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_symbol, false)
  if data.payRechargeConfig and data.payRechargeConfig.ProductId and data.payRechargeConfig.ProductId[1] == rechargeActivityDefine.ProductIdType.Free then
    self.uiBinder.lab_gold.text = Lang("Free")
  else
    local price = 0
    local currencySymbol = ""
    local currencySymbolCode = ""
    local productInfo = self.parent.UIView.ProductionInfos[data.payServerProductId]
    self.uiBinder.lab_symbol.text = ""
    self.uiBinder.lab_old_symbol.text = ""
    if productInfo and data.paymentConfig then
      if productInfo.DisplayPrice ~= nil then
        self.uiBinder.lab_gold.text = productInfo.DisplayPrice
        price = productInfo.Price
        currencySymbol = productInfo.CurrencySymbol
        currencySymbolCode = productInfo.CurrencyCode
      else
        currencySymbol = productInfo.CurrencySymbol or self.shopVm_.GetShopItemCurrencySymbol()
        self.uiBinder.lab_gold.text = currencySymbol .. data.paymentConfig.Price
        price = data.paymentConfig.Price
      end
    elseif data.paymentConfig then
      currencySymbol = self.shopVm_.GetShopItemCurrencySymbol()
      self.uiBinder.lab_gold.text = currencySymbol .. data.paymentConfig.Price
      price = data.paymentConfig.Price
    else
      self.uiBinder.lab_gold.text = ""
    end
    local curPlatform = Z.SDKLogin.GetPlatform()
    local isShowOldPrice = curPlatform == E.LoginPlatformType.TencentPlatform or curPlatform == E.LoginPlatformType.InnerPlatform
    if isShowOldPrice and price ~= nil and data.payRechargeConfig and data.payRechargeConfig.ShowOriginalPrice and data.payRechargeConfig.ShowOriginalPrice ~= 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_symbol, true)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, true)
      local old_price = self.paymentVM_:GetBeforeDiscountPrice(tonumber(price), data.payRechargeConfig.ShowOriginalPrice, currencySymbol, currencySymbolCode)
      self.uiBinder.lab_old_gold.text = old_price
    else
      self.uiBinder.lab_old_gold.text = ""
    end
  end
end

function ShopGiftLoopItem:OnSelected(isSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
  if self.data_ and self.data_ then
    self.parent.UIView:SelectGift(self.data_)
  end
end

function ShopGiftLoopItem:RefreshTime(nowTime)
  if self.data_.payRechargeConfig.Label then
    for _, lab in ipairs(self.data_.payRechargeConfig.Label) do
      if tonumber(lab[1]) == rechargeActivityDefine.DiscountType.Time and nowTime <= self.data_.rewardEndTime then
        self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(self.data_.rewardEndTime - nowTime)
      end
    end
  end
end

return ShopGiftLoopItem
