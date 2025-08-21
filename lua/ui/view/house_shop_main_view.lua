local UI = Z.UI
local super = require("ui.ui_view_base")
local House_shop_mainView = class("House_shop_mainView", super)
local houseShopSellSubView = require("ui.view.house_shop_sell_sub_view")
local currency_item_list = require("ui.component.currency.currency_item_list")

function House_shop_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "house_shop_main")
  self.houseVm_ = Z.VMMgr.GetVM("house")
  self.houseData_ = Z.DataMgr.Get("house_data")
  self.homeVm_ = Z.VMMgr.GetVM("home_editor")
end

function House_shop_mainView:OnActive()
  self:bindBtnClick()
  self.currencyItemList_ = currency_item_list.new()
  self.currencyItemList_:Init(self.uiBinder.currency_info, {})
  self.uiBinder.toggle_sell.isOn = true
  if not self.curSellSubView_ then
    self.curSellSubView_ = houseShopSellSubView.new(self)
  end
  self.curSellSubView_:Active({}, self.uiBinder.node_sub_view)
  Z.CoroUtil.create_coro_xpcall(function()
    self.homeVm_.AsyncHomelandFurnitureWarehouseData()
  end)()
end

function House_shop_mainView:RefreshCurrency(currencyList)
  self.currencyItemList_:Init(self.uiBinder.currency_info, currencyList)
end

function House_shop_mainView:bindBtnClick()
  self:AddClick(self.uiBinder.btn_close, function()
    self.houseVm_.CloseHouseSellShopView()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(40002)
  end)
  self.uiBinder.toggle_sell:AddListener(function(isOn)
    if not self.curSellSubView_ then
      self.curSellSubView_ = houseShopSellSubView.new(self)
    end
    self.curSellSubView_:Active({}, self.uiBinder.node_sub_view)
  end, true)
end

function House_shop_mainView:OnDeActive()
  if self.curSellSubView_ then
    self.curSellSubView_:DeActive()
  end
  self.curSellSubView_ = nil
  self.currencyItemList_:UnInit()
end

function House_shop_mainView:OnRefresh()
end

return House_shop_mainView
