local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_consignment_subView = class("Trading_ring_consignment_subView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")
local loopListView = require("ui.component.loop_list_view")
local TradeSellItemInfo = require("ui.component.trade.trade_sell_info_item")
local pageType = {sell = 1, buy = 2}
local keyPadInputType = {
  buyNum = 1,
  buyRate = 2,
  SellNum = 3,
  SellRate = 4
}

function Trading_ring_consignment_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "trading_ring/trading_ring_consignment_sub"
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_consignment_sub_pc"
  end
  super.ctor(self, "trading_ring_consignment_sub", assetPath, UI.ECacheLv.None)
end

function Trading_ring_consignment_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.keypad_ = keyPad.new(self)
  self.selectIndex_ = self.viewData.selectType or pageType.sell
  self.sellRate_ = 0
  self.useElseRate_ = false
  self.costItemEnough_ = true
  self.buyNum_ = 1
  local togs = {
    [pageType.sell] = self.uiBinder.tog_diamond_consignment,
    [pageType.buy] = self.uiBinder.tog_binding_drill_buy
  }
  self.ranking = {
    [1] = self.uiBinder.img_ranking_1,
    [2] = self.uiBinder.img_ranking_2,
    [3] = self.uiBinder.img_ranking_3
  }
  for index, value in ipairs(togs) do
    value.group = self.uiBinder.togs_tab_1
    value:AddListener(function(isOn)
      if isOn then
        self:onChangePage(index)
      end
    end)
  end
  self:initBuyPage()
  self:initSellPage()
  self:bindEvent()
  self:refresConsignmentNumRank()
  Z.CoroUtil.create_coro_xpcall(function()
    self.tradeVm_:AsyncExchangeSaleData(self.cancelSource:CreateToken())
    self:refershSelfConsignmentInfo()
    if togs[self.selectIndex_].isOn then
      self:onChangePage(self.selectIndex_)
    else
      togs[self.selectIndex_].isOn = true
    end
  end)()
end

function Trading_ring_consignment_subView:bindEvent()
  local ConsignmentSuccessRefresh = function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.tradeVm_:AsyncExchangeSaleData(self.cancelSource:CreateToken())
      self:refershSelfConsignmentInfo()
      self:onChangePage(self.selectIndex_)
      self:refershMaxSellNum()
    end)()
    self:refresConsignmentNumRank()
  end
  Z.EventMgr:Add(Z.ConstValue.Trade.ConsignmentPutItemSuccess, ConsignmentSuccessRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Trade.ConsignmentTakeItemSuccess, ConsignmentSuccessRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Trade.ConsignmentBuyItemSuccess, ConsignmentSuccessRefresh, self)
end

function Trading_ring_consignment_subView:initBuyPage()
  self:AddAsyncClick(self.uiBinder.node_binding_drill_buy.btn_buy, function()
    local elseRate = self.elseRate_
    if not self.useElseRate_ then
      elseRate = 0
    end
    if not self.costItemEnough_ then
      Z.TipsVM.ShowTips(6467)
      return
    end
    self.tradeVm_:AsyncExchangeSaleBuy(self.tradeData_.ConsignmentMinRate, self.buyNum_, elseRate, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_add, function()
    if self.buyNum_ >= self.canBuyMax_ then
      self.buyNum_ = self.canBuyMax_
      return
    end
    self.buyNum_ = self.buyNum_ + 1
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_add.IsDisabled = self.buyNum_ >= self.canBuyMax_
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_reduce.IsDisabled = false
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
    self:refreshBuyCost()
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_reduce, function()
    if self.buyNum_ <= 1 then
      return
    end
    self.buyNum_ = self.buyNum_ - 1
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.buyNum_ <= 1
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_add.IsDisabled = false
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
    self:refreshBuyCost()
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_max, function()
    self.buyNum_ = self.canBuyMax_
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
    self:refreshBuyCost()
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_num, function()
    self.keyPadInputType_ = keyPadInputType.buyNum
    self.keypad_:Active({
      min = 1,
      max = self.canBuyMax_
    }, self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.group_keypadroot)
  end)
  self.uiBinder.node_binding_drill_buy.tog_show_has:AddListener(function(isOn)
    if not isOn then
      self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2_canvas.alpha = 0.3
    else
      self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2_canvas.alpha = 1
    end
    self.useElseRate_ = isOn
    self:refreshBuyCost()
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_add, function()
    if self.elseRate_ >= self.tradeData_.MaxDiamondTax then
      return
    end
    self.elseRate_ = self.elseRate_ + 1
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_add.IsDisabled = self.elseRate_ >= self.tradeData_.MaxDiamondTax
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_reduce.IsDisabled = false
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.lab_num.text = self.elseRate_
    self:refreshBuyCost()
  end)
  self:AddClick(self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_reduce, function()
    if self.elseRate_ <= self.tradeData_.ConsignmentMinRate then
      return
    end
    self.elseRate_ = self.elseRate_ - 1
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_reduce.IsDisabled = self.elseRate_ <= self.tradeData_.ConsignmentMinRate
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_add.IsDisabled = false
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.lab_num.text = self.elseRate_
    self:refreshBuyCost()
  end)
end

function Trading_ring_consignment_subView:initSellPage()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.tradeData_.DiamondItem)
  if itemRow then
    self.uiBinder.node_diamond_consignment.rimg_recharge_icon:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DiamondItem))
  end
  self:AddAsyncClick(self.uiBinder.node_diamond_consignment.btn_recharge, function()
    local shopVm = Z.VMMgr.GetVM("shop")
    shopVm.OpenShopView(E.FunctionID.PayFunction)
  end)
  self:AddAsyncClick(self.uiBinder.node_diamond_consignment.btn_consignment, function()
    self.tradeVm_:AsyncExchangeSale(self.sellNum_, self.sellRate_, self.cancelSource:CreateToken())
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_add, function()
    if self.sellRate_ >= self.tradeData_.MaxDiamondTax then
      return
    end
    self.sellRate_ = self.sellRate_ + 1
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellRate_ >= self.tradeData_.MaxDiamondTax
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.sellRate_ <= self.tradeData_.MinDiamondTax
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.lab_num.text = self.sellRate_
    self:refreshSellGet()
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_reduce, function()
    if self.sellRate_ <= self.tradeData_.MinDiamondTax then
      return
    end
    self.sellRate_ = self.sellRate_ - 1
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.sellRate_ <= self.tradeData_.MinDiamondTax
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellRate_ >= self.tradeData_.MaxDiamondTax
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.lab_num.text = self.sellRate_
    self:refreshSellGet()
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_add, function()
    if self.sellNum_ >= self.canSellMax_ then
      return
    end
    self.sellNum_ = self.sellNum_ + 1
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_reduce.IsDisabled = false
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellNum_ >= self.canSellMax_
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.lab_num.text = self.sellNum_
    self:refreshSellGet()
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_reduce, function()
    if self.sellNum_ <= 1 then
      return
    end
    if self.sellNum_ <= Z.StallRuleConfig.SaleNumMin then
      return
    end
    self.sellNum_ = self.sellNum_ - 1
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.sellNum_ <= Z.StallRuleConfig.SaleNumMin
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_add.IsDisabled = false
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.lab_num.text = self.sellNum_
    self:refreshSellGet()
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_max, function()
    if self.canSellMax_ == 0 then
      return
    end
    self.sellNum_ = self.canSellMax_
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_reduce.IsDisabled = false
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellNum_ >= self.canSellMax_
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.lab_num.text = self.sellNum_
    self:refreshSellGet()
  end)
  self:AddClick(self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_num, function()
    self.keyPadInputType_ = keyPadInputType.SellNum
    local min = 1
    if self.canSellMax_ == 0 then
      min = 0
    end
    self.keypad_:Active({
      min = min,
      max = self.canSellMax_
    }, self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.group_keypadroot)
  end)
end

function Trading_ring_consignment_subView:InputNum(num)
  if self.keyPadInputType_ == keyPadInputType.buyNum then
    self.buyNum_ = num
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
    self:refreshBuyCost()
  elseif self.keyPadInputType_ == keyPadInputType.buyRate then
    self.elseRate_ = num
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.lab_num.text = self.elseRate_
    self:refreshBuyCost()
  elseif self.keyPadInputType_ == keyPadInputType.SellRate then
    self.sellRate_ = num
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.lab_num.text = self.sellRate_
    self:refreshSellGet()
  elseif self.keyPadInputType_ == keyPadInputType.SellNum then
    self.sellNum_ = num
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.lab_num.text = self.sellNum_
    self:refreshSellGet()
  end
end

function Trading_ring_consignment_subView:refresConsignmentNumRank()
  Z.CoroUtil.create_coro_xpcall(function()
    self.tradeVm_:AsyncExchangeSaleRank(self.cancelSource:CreateToken())
    for index, uiBinder in ipairs(self.ranking) do
      for _, value in ipairs(self.tradeData_.ConsignmentDataRankList) do
        if index == value.rankIdx then
          uiBinder.Ref.UIComp:SetVisible(true)
          uiBinder.lab_num.text = value.rankIdx
          uiBinder.lab_exchange_rate_num.text = value.rate
        end
      end
    end
    for index = #self.tradeData_.ConsignmentDataRankList + 1, #self.ranking do
      local uiBinder = self.ranking[index]
      uiBinder.Ref.UIComp:SetVisible(false)
    end
  end)()
end

function Trading_ring_consignment_subView:refershSelfConsignmentInfo()
  local data = self.tradeData_.ConsignmentItemDataList
  if self.loopListView_ == nil then
    local path = "trading_ring_sell_info_item_tpl"
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    self.loopListView_ = loopListView.new(self, self.uiBinder.scrollview, TradeSellItemInfo, path)
    self.loopListView_:Init(data)
  else
    self.loopListView_:ClearAllSelect()
    self.loopListView_:RefreshListView(data)
  end
end

function Trading_ring_consignment_subView:onChangePage(type)
  if type == pageType.sell then
    self:refreshSell()
  else
    self:refreshBuy()
  end
  self.selectIndex_ = type
end

function Trading_ring_consignment_subView:refreshSell()
  self.uiBinder.node_binding_drill_buy.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_diamond_consignment.Ref.UIComp:SetVisible(true)
  if self.itemVm_.GetItemTotalCount(self.tradeData_.DiamondItem) == 0 then
    self.sellNum_ = 0
  else
    self.sellNum_ = Z.StallRuleConfig.SaleNumMin
  end
  self.sellRate_ = self.tradeData_.ConsignmentMinRate - 1
  if self.sellRate_ < self.tradeData_.MinDiamondTax then
    self.sellRate_ = self.tradeData_.MinDiamondTax
  end
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.lab_num.text = self.sellNum_
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.lab_num.text = self.sellRate_
  self.uiBinder.node_diamond_consignment.lab_minimum_exchange.text = Lang("min_rare_in_sell") .. self.tradeData_.ConsignmentMinRate
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local diamondRow = itemTableMgr.GetRow(self.tradeData_.DiamondItem)
  if diamondRow then
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.rimg_gold_sell:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DiamondItem))
  end
  local costItemRow = itemTableMgr.GetRow(self.tradeData_.DefaultItem)
  if costItemRow then
    self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.rimg_gold_cost:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
    self.uiBinder.node_diamond_consignment.rimg_gold:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
  end
  self:refershMaxSellNum()
  self:refreshSellGet()
  self.uiBinder.node_diamond_consignment.btn_consignment.IsDisabled = self.sellNum_ == 0
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellRate_ >= self.tradeData_.MaxDiamondTax
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_1.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.sellRate_ <= self.tradeData_.MinDiamondTax
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_add.IsDisabled = self.sellNum_ >= self.canSellMax_
  self.uiBinder.node_diamond_consignment.binder_diamond_consignment_2.binder_num_module_tpl_1.btn_reduce.IsDisabled = self.sellNum_ <= Z.StallRuleConfig.SaleNumMin
end

function Trading_ring_consignment_subView:refershMaxSellNum()
  self.canSellMax_ = self.itemVm_.GetItemTotalCount(self.tradeData_.DiamondItem)
  if self.canSellMax_ < 0 then
    self.canSellMax_ = 0
  end
  self.uiBinder.node_diamond_consignment.lab_shelf_num.text = self.canSellMax_
  if self.canSellMax_ >= Z.StallRuleConfig.SaleNumMax then
    self.canSellMax_ = Z.StallRuleConfig.SaleNumMax
  end
end

function Trading_ring_consignment_subView:refreshSellGet()
  self.uiBinder.node_diamond_consignment.lab_digit.text = math.floor(self.sellNum_ * self.sellRate_ * ((100 - self.tradeData_.SaleDiamondTax) / 100))
end

function Trading_ring_consignment_subView:refreshBuy()
  self.uiBinder.node_binding_drill_buy.Ref.UIComp:SetVisible(true)
  self.uiBinder.node_diamond_consignment.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_0.lab_num.text = 1
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_0.lab_exchange_num.text = self.tradeData_.ConsignmentMinRate
  local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local fakeDiamondRow = itemTableMgr.GetRow(self.tradeData_.FakeDiamondItem)
  if fakeDiamondRow then
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_0.rimg_gold_buy:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.FakeDiamondItem))
  end
  local costItemRow = itemTableMgr.GetRow(self.tradeData_.DefaultItem)
  if costItemRow then
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_0.rimg_gold_cost:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
    self.uiBinder.node_binding_drill_buy.rimg_gold:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
  end
  self.elseRate_ = self.tradeData_.ConsignmentMinRate
  self.buyNum_ = 1
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.lab_num.text = self.elseRate_
  self.uiBinder.node_binding_drill_buy.tog_show_has.isOn = self.useElseRate_
  local fakeDiamondCount = self.itemVm_.GetItemTotalCount(self.tradeData_.FakeDiamondItem)
  self.uiBinder.node_binding_drill_buy.lab_already_have_num.text = Lang("already_have") .. fakeDiamondCount
  self:refreshBuyCost()
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_add.IsDisabled = self.buyNum_ >= self.canBuyMax_
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.btn_reduce.IsDisabled = 1 >= self.buyNum_
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_add.IsDisabled = self.elseRate_ >= self.tradeData_.MaxDiamondTax
  self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_2.btn_reduce.IsDisabled = self.elseRate_ <= self.tradeData_.ConsignmentMinRate
end

function Trading_ring_consignment_subView:checkMaxCanBuy()
  local costItemNum = self.itemVm_.GetItemTotalCount(self.tradeData_.DefaultItem)
  local rate = self.tradeData_.ConsignmentMinRate
  if self.useElseRate_ then
    rate = self.elseRate_
  end
  self.canBuyMax_ = math.floor(costItemNum / rate)
  if self.buyNum_ >= self.canBuyMax_ then
    self.buyNum_ = self.canBuyMax_
    if self.buyNum_ == 0 then
      self.buyNum_ = 1
    end
    self.uiBinder.node_binding_drill_buy.binder_num_module_tpl_1.lab_num.text = self.buyNum_
    return
  end
end

function Trading_ring_consignment_subView:refreshBuyCost()
  self:checkMaxCanBuy()
  local costItemNum = self.itemVm_.GetItemTotalCount(self.tradeData_.DefaultItem)
  self.costItemEnough_ = true
  if self.useElseRate_ and self.elseRate_ ~= self.tradeData_.ConsignmentMinRate then
    local minPrice = 0
    local maxPrice = 0
    if self.elseRate_ < self.tradeData_.ConsignmentMinRate then
      minPrice = self.buyNum_ * self.elseRate_
      maxPrice = self.buyNum_ * self.tradeData_.ConsignmentMinRate
    else
      minPrice = self.buyNum_ * self.tradeData_.ConsignmentMinRate
      maxPrice = self.buyNum_ * self.elseRate_
    end
    self.uiBinder.node_binding_drill_buy.lab_digit.text = minPrice .. "~" .. maxPrice
    self.costItemEnough_ = costItemNum >= minPrice
  else
    self.uiBinder.node_binding_drill_buy.lab_digit.text = self.buyNum_ * self.tradeData_.ConsignmentMinRate
    self.costItemEnough_ = costItemNum >= self.buyNum_ * self.tradeData_.ConsignmentMinRate
  end
end

function Trading_ring_consignment_subView:OnDeActive()
  if self.loopListView_ then
    self.loopListView_:UnInit()
    self.loopListView_ = nil
  end
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  self.keypad_ = nil
end

function Trading_ring_consignment_subView:OnRefresh()
end

return Trading_ring_consignment_subView
