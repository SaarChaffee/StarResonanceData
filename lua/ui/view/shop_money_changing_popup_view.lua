local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_money_changing_popupView = class("Shop_money_changing_popupView", super)
local ExchangePerMaxLimit = Z.Global.ExchangePerMaxLimit
local MoneyOverflowLimit = Z.Global.MoneyOverflowLimit
local itemClass = require("common.item_binder")
local numMod = require("ui.view.cont_num_module_tpl_view")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Shop_money_changing_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_money_changing_popup")
  self.numMod_ = numMod.new(self)
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Shop_money_changing_popupView:initZWidget()
  self.iconFront_ = self.uiBinder.c_com_base_popup.rimg_icon_front
  self.labNumFront_ = self.uiBinder.c_com_base_popup.lab_num_front
  self.iconBack_ = self.uiBinder.c_com_base_popup.rimg_icon_back
  self.labNumBack_ = self.uiBinder.c_com_base_popup.lab_num_back
  self.btnNo_ = self.uiBinder.c_com_base_popup.btn_no
  self.btnYes_ = self.uiBinder.c_com_base_popup.btn_yes
  self.leftItem_ = self.uiBinder.c_com_base_popup.node_item_left
  self.rightItem_ = self.uiBinder.c_com_base_popup.node_item_right
  self.numModRootTrans_ = self.uiBinder.c_com_base_popup.group_num_Trans
end

function Shop_money_changing_popupView:OnActive()
  self.uiBinder.c_com_base_popup.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.leftItemClass_ = itemClass.new(self)
  self.rightItemClass_ = itemClass.new(self)
  self:initZWidget()
  self:AddClick(self.btnNo_, function()
    self.currencyVm_.CloseExChangeCurrencyView()
  end)
  self:AddClick(self.btnYes_, function()
    local count = self.itemsVm_.GetItemTotalCount(self.exchangeConfigId_)
    if count < self.consumeNum_ * self.nowExchangeNum_ then
      self.currencyVm_.OpenExChangeCurrencyView(self.exchangeConfigId_, true)
    else
      self.shopVm_.AsyncExchangeCurrency(self.viewData.functionId, self.nowExchangeNum_)
    end
  end)
  if self.numMod_ then
    self.numMod_:Active({
      tipId = 1000735,
      cost = {
        moneyId = self.viewData.data[1][1],
        price_single = self.viewData.data[1][2]
      }
    }, self.numModRootTrans_)
  end
  self:refreshData(self.viewData)
  
  function self.onCostItemChanged_()
    if self.numMod_ then
      local hasCount = self.itemsVm_.GetItemTotalCount(self.viewData.data[1][1])
      self.numMod_:ReSetValue(1, self.maxExchangeNum_, Mathf.Floor(hasCount / self.viewData.data[1][2]), function(num)
        self:InputNum(math.floor(num))
      end)
    end
  end
  
  Z.ContainerMgr.CharSerialize.itemPackage.Watcher:RegWatcher(self.onCostItemChanged_)
end

function Shop_money_changing_popupView:refreshData(data)
  if data then
    self:init(data.data)
  end
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {
    self.exchangeConfigId_,
    self.beExchangeConfigId_
  })
  if self.numMod_ then
    local hasCount = self.itemsVm_.GetItemTotalCount(self.viewData.data[1][1])
    self.numMod_:ReSetValue(1, self.maxExchangeNum_, Mathf.Floor(hasCount / self.viewData.data[1][2]), function(num)
      self:InputNum(math.floor(num))
    end)
  end
end

function Shop_money_changing_popupView:init(data)
  if data and data[1] then
    self.exchangeConfigId_ = data[1][1]
    self.consumeNum_ = data[1][2]
  end
  if data and data[2] then
    self.beExchangeConfigId_ = data[2][1]
    self.mayGetNum_ = data[2][2]
  end
  if self.consumeNum_ and self.mayGetNum_ then
    self.rate_ = tonumber(self.mayGetNum_ / self.consumeNum_)
  end
  if not (self.exchangeConfigId_ and self.beExchangeConfigId_) or not self.rate_ then
    return
  end
  local itemTable = Z.TableMgr.GetTable("ItemTableMgr")
  local exchangeCfg = itemTable.GetRow(self.exchangeConfigId_)
  local beExchangeCfg = itemTable.GetRow(self.beExchangeConfigId_)
  if exchangeCfg and beExchangeCfg then
    self.iconFront_:SetImage(self.itemsVm_.GetItemIcon(self.exchangeConfigId_))
    self.iconBack_:SetImage(self.itemsVm_.GetItemIcon(self.beExchangeConfigId_))
  else
    return
  end
  local count = self.itemsVm_.GetItemTotalCount(self.beExchangeConfigId_)
  self.exchangeItemCount_ = self.itemsVm_.GetItemTotalCount(self.exchangeConfigId_)
  self:getMaxExchangeNum(count)
  self.nowExchangeNum_ = 1
  self.leftItemClass_:Init({
    uiBinder = self.leftItem_,
    configId = self.exchangeConfigId_,
    isSquareItem = true,
    lab = self.consumeNum_
  })
  self.rightItemClass_:Init({
    uiBinder = self.rightItem_,
    configId = self.beExchangeConfigId_,
    isSquareItem = true,
    lab = self.mayGetNum_
  })
  self.labNumFront_.text = "x" .. self.consumeNum_ .. "="
  self.labNumBack_.text = "x" .. self.mayGetNum_
  self:setLab()
end

function Shop_money_changing_popupView:getMaxExchangeNum(nowCount)
  self.maxExchangeNum_ = ExchangePerMaxLimit
end

function Shop_money_changing_popupView:setLab()
  local count = self.itemsVm_.GetItemTotalCount(self.exchangeConfigId_)
  local str = Z.RichTextHelper.ApplyStyleTag(self.nowExchangeNum_, E.TextStyleTag.Lab_num_black)
  if count < self.nowExchangeNum_ then
    str = Z.RichTextHelper.ApplyStyleTag(self.nowExchangeNum_, E.TextStyleTag.Lab_num_red)
  end
  self.leftItemClass_:SetLab(str)
  self.rightItemClass_:SetLab(self.nowExchangeNum_ * self.mayGetNum_)
end

function Shop_money_changing_popupView:InputNum(num)
  self.nowExchangeNum_ = num
  self:setLab()
end

function Shop_money_changing_popupView:OnDeActive()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  self.numMod_:DeActive()
  self.exchangeConfigId_ = nil
  self.beExchangeConfigId_ = nil
  self.leftItemClass_:UnInit()
  self.rightItemClass_:UnInit()
  if self.onCostItemChanged_ then
    Z.ContainerMgr.CharSerialize.itemPackage.Watcher:UnregWatcher(self.onCostItemChanged_)
  end
end

function Shop_money_changing_popupView:OnRefresh()
end

return Shop_money_changing_popupView
