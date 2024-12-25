local UI = Z.UI
local super = require("ui.ui_view_base")
local Trading_ring_mainView = class("Trading_ring_mainView", super)
local tradeBuyView = require("ui.view.trading_ring_buy_sub_view")
local tradeSellView = require("ui.view.trading_ring_putaway_sub_view")
local tradeNoticeView = require("ui.view.trading_ring_publicity_sub_view")
local tradeRecordView = require("ui.view.trading_ring_buy_sell_sub_view")
local tradeConsignmentRecordView = require("ui.view.trading_ring_consignment_record_sub_view")
local tradeConsignmentView = require("ui.view.trading_ring_consignment_sub_view")
local subViewType = {
  Buy = 1,
  Notice = 2,
  Sell = 3,
  Record = 4,
  Consignment = 5
}

function Trading_ring_mainView:ctor()
  self.uiBinder = nil
  local assetPath
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_main_pc"
  end
  super.ctor(self, "trading_ring_main", assetPath)
end

function Trading_ring_mainView:OnActive()
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  self.subTogs_ = {}
  self:AddAsyncClick(self.uiBinder.btn_close, function()
    self.tradeVm_.CloseTradeMainView()
  end)
  self:AddAsyncClick(self.uiBinder.btn_ask, function()
    local helpsysVM = Z.VMMgr.GetVM("helpsys")
    helpsysVM.CheckAndShowView(80001)
  end)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  local commonVm = Z.VMMgr.GetVM("common")
  commonVm.SetLabText(self.uiBinder.lab_title, {
    E.FunctionID.Trade
  })
  self.tradeBuyView_ = {
    view = tradeBuyView.new(),
    viewIndex = 1
  }
  self.tradeNoticeView = {
    view = tradeNoticeView.new(),
    viewIndex = 2
  }
  self.tradeSellView_ = {
    view = tradeSellView.new(),
    viewIndex = 3
  }
  self.tradeRecordView_ = {
    view = tradeRecordView.new(),
    viewIndex = 4
  }
  self.tradeConsignmentRecordView = {
    view = tradeConsignmentRecordView.new(),
    viewIndex = 5
  }
  self.tradeConsignmentView = {
    view = tradeConsignmentView.new(),
    viewIndex = 6
  }
  self.subIndexToCategoryType = {}
  self.subViews_ = {
    [subViewType.Buy] = {
      defaultView = self.tradeBuyView_
    },
    [subViewType.Notice] = {
      [2] = self.tradeNoticeView,
      defaultView = self.tradeBuyView_
    },
    [subViewType.Sell] = {
      defaultView = self.tradeSellView_
    },
    [subViewType.Record] = {
      [1] = self.tradeRecordView_,
      [2] = self.tradeConsignmentRecordView
    },
    [subViewType.Consignment] = {
      [1] = self.tradeConsignmentView
    }
  }
  self.mainTogUiBinders_ = {
    [subViewType.Buy] = self.uiBinder.binder_buy,
    [subViewType.Notice] = self.uiBinder.binder_list_notice,
    [subViewType.Sell] = self.uiBinder.binder_sell,
    [subViewType.Record] = self.uiBinder.binder_trading_record,
    [subViewType.Consignment] = self.uiBinder.binder_consignment
  }
  self.loadFinish_ = false
  Z.CoroUtil.create_coro_xpcall(function()
    self:firstOpenPage()
    self:generateSubTog(subViewType.Buy)
    self:generateSubTog(subViewType.Notice)
    self:initFunction()
    self:initTog()
    self.loadFinish_ = true
    self:openFirstPage()
  end)()
  local currencyVm = Z.VMMgr.GetVM("currency")
  currencyVm.OpenCurrencyView(Z.SystemItem.DefaultCurrencyDisplay, self.uiBinder.Trans, self)
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
  
  self:RegisterInputActions()
end

function Trading_ring_mainView:openFirstPage()
  if not self.loadFinish_ then
    return
  end
  if self.viewData.configId then
    local selectType
    local subIndex = 1
    if self.subIndexToCategoryType[subViewType.Buy] then
      local stallDetailRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.viewData.configId, true)
      if stallDetailRow then
        selectType = stallDetailRow.Category
      end
      if selectType then
        for index, value in ipairs(self.subIndexToCategoryType[subViewType.Buy]) do
          if value == selectType then
            subIndex = index
          end
        end
      end
    end
    self:onselectMainTog(self.uiBinder.binder_buy, subViewType.Buy, subIndex)
    return
  end
  if self.viewData.type then
    self:onselectMainTog(self.mainTogUiBinders_[self.viewData.type], self.viewData.type)
    return
  end
  if self.hasSellInfo_ then
    self:onselectMainTog(self.uiBinder.binder_sell, subViewType.Sell)
  else
    self:onselectMainTog(self.uiBinder.binder_buy, subViewType.Buy)
  end
end

function Trading_ring_mainView:initFunction()
  for type, value in ipairs(self.mainTogUiBinders_) do
    self:AddAsyncClick(value.node_tog.btn_click, function()
      self:onselectMainTog(value, type)
    end)
    self:MarkListenerComp(value.node_tog.btn_click, true)
  end
  self.subTogs_[subViewType.Record] = {}
  self.subTogs_[subViewType.Record][1] = self.uiBinder.binder_trading_record.trading_tog_item
  self.subTogs_[subViewType.Record][2] = self.uiBinder.binder_trading_record.trading_tog_consignment
  for type, value in pairs(self.subTogs_) do
    for index, value in ipairs(value) do
      self:AddAsyncClick(value.btn_click, function()
        self:onselectSubTog(type, index, value)
      end)
      self:MarkListenerComp(value.btn_click, true)
    end
  end
end

function Trading_ring_mainView:initTog()
  for _, value in ipairs(self.mainTogUiBinders_) do
    value.Ref:SetVisible(value.node_twe_tog, false)
    value.node_tog.Ref:SetVisible(value.node_tog.node_on, false)
    value.node_tog.Ref:SetVisible(value.node_tog.node_off, true)
  end
  local tog = self.uiBinder.binder_trading_record.trading_tog_consignment
  tog.Ref:SetVisible(tog.node_on, false)
  tog.Ref:SetVisible(tog.node_off, true)
  local tog = self.uiBinder.binder_trading_record.trading_tog_item
  tog.Ref:SetVisible(tog.node_on, false)
  tog.Ref:SetVisible(tog.node_off, true)
end

function Trading_ring_mainView:onChangeSubView(type, subIndex)
  local subView
  local parent = self.uiBinder.node_sub
  if self.subViews_[type] == nil then
    return
  end
  if self.subViews_[type][subIndex] then
    subView = self.subViews_[type][subIndex].view
  else
    subView = self.subViews_[type].defaultView.view
  end
  if self.selectView_ then
    self.selectView_:DeActive()
  end
  self.selectView_ = subView
  local selectType, selectSubType
  if self.viewData.configId then
    local stallDetailRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.viewData.configId, true)
    if stallDetailRow then
      selectType = stallDetailRow.Category
      selectSubType = stallDetailRow.Subcategory
    end
  elseif self.viewData.subType then
    selectType = self.viewData.subType
    self.viewData.subType = nil
  elseif self.subIndexToCategoryType[type] then
    selectType = self.subIndexToCategoryType[type][subIndex]
  end
  local viewData = {
    type = type,
    selectType = selectType,
    selectSubType = selectSubType,
    subIndex = subIndex,
    isNotice = type == subViewType.Notice,
    isFocus = (type == subViewType.Buy or type == subViewType.Notice) and subIndex == 1,
    configId = self.viewData.configId,
    itemUuid = self.viewData.itemUuid
  }
  self.selectView_:Active(viewData, parent)
  self.viewData.configId = nil
  self.viewData.itemUuid = nil
end

function Trading_ring_mainView:firstOpenPage()
  self.hasSellInfo_ = false
  self.tradeVm_:AsyncExchangeSellItem(self.cancelSource:CreateToken())
  for _, value in pairs(self.tradeData_.WithDrawItem) do
    if 0 < value then
      self.hasSellInfo_ = true
      return
    end
  end
end

function Trading_ring_mainView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  local currencyVm = Z.VMMgr.GetVM("currency")
  currencyVm.CloseCurrencyView(self)
  if self.selectView_ then
    self.selectView_:DeActive()
  end
  self.selectMainTog_ = nil
  self.selectSubTog_ = nil
  self.selectView_ = nil
  self.hasSellInfo_ = false
  self.defaultBuyTog_ = nil
  self.defaultSellTog_ = nil
  self:UnRegisterInputActions()
  self:unLoadRedDotItem()
end

function Trading_ring_mainView:generateSubTog(type)
  local mainTypeData = {}
  local tradeCategoryData = Z.TableMgr.GetTable("StallCategoryTableMgr").GetDatas()
  for _, value in pairs(tradeCategoryData) do
    if value.CategoryLevel == 0 then
      if type == subViewType.Notice then
        if value.IsAnnounce == 1 then
          table.insert(mainTypeData, value)
          if self.subIndexToCategoryType[type] == nil then
            self.subIndexToCategoryType[type] = {}
          end
          table.insert(self.subIndexToCategoryType[type], value.ID)
        end
      else
        table.insert(mainTypeData, value)
        if self.subIndexToCategoryType[type] == nil then
          self.subIndexToCategoryType[type] = {}
        end
        table.insert(self.subIndexToCategoryType[type], value.ID)
      end
    end
  end
  table.sort(mainTypeData, function(a, b)
    if a.Sort == b.Sort then
      return a.ID < b.ID
    else
      return a.Sort < b.Sort
    end
  end)
  if type == subViewType.Notice then
    table.insert(self.subIndexToCategoryType[type], 1, 0)
    table.insert(mainTypeData, 1, {})
    table.insert(self.subIndexToCategoryType[type], 1, 0)
    table.insert(mainTypeData, 1, {})
  end
  if type == subViewType.Buy then
    table.insert(self.subIndexToCategoryType[type], 1, 0)
    table.insert(mainTypeData, 1, {})
  end
  local path = self.uiBinder.prefab_cache:GetString("sub_tog")
  local root = self.mainTogUiBinders_[type].node_twe_tog
  for index, value in ipairs(mainTypeData) do
    local tog = self:AsyncLoadUiUnit(path, type .. "_tog_" .. index, root)
    if type == subViewType.Buy and index == 1 then
      self.defaultBuyTog_ = tog
    end
    if type == subViewType.Sell and index == 1 then
      self.defaultSellTog_ = tog
    end
    if value.Name then
      tog.lab_on_content.text = value.Name
      tog.lab_off_content.text = value.Name
    elseif type == subViewType.Buy then
      tog.lab_on_content.text = Lang("attention")
      tog.lab_off_content.text = Lang("attention")
    elseif type == subViewType.Notice then
      if index == 1 then
        tog.lab_on_content.text = Lang("attention")
        tog.lab_off_content.text = Lang("attention")
      else
        tog.lab_on_content.text = Lang("already_prebuy")
        tog.lab_off_content.text = Lang("already_prebuy")
      end
    end
    self.mainTogUiBinders_[type].Ref:SetVisible(self.mainTogUiBinders_[type].node_twe_tog, false)
    if self.subTogs_[type] == nil then
      self.subTogs_[type] = {}
    end
    table.insert(self.subTogs_[type], tog)
    tog.Ref:SetVisible(tog.node_on, false)
    tog.Ref:SetVisible(tog.node_off, true)
  end
end

function Trading_ring_mainView:onselectMainTog(tog, type, subIndex)
  if self.selectMainTog_ == tog then
    self.isMainTogIsOpen_ = not self.isMainTogIsOpen_
    self.selectMainTog_.Ref:SetVisible(self.selectMainTog_.node_twe_tog, self.isMainTogIsOpen_)
    self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_on, self.isMainTogIsOpen_)
    self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_off, not self.isMainTogIsOpen_)
    return
  end
  if self.selectMainTog_ then
    self.selectMainTog_.Ref:SetVisible(self.selectMainTog_.node_twe_tog, false)
    self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_on, false)
    self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_off, true)
  end
  self.isMainTogIsOpen_ = true
  self.selectMainTog_ = tog
  self.selectMainTog_.Ref:SetVisible(self.selectMainTog_.node_twe_tog, true)
  self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_on, true)
  self.selectMainTog_.node_tog.Ref:SetVisible(self.selectMainTog_.node_tog.node_off, false)
  local tog
  if subIndex == nil then
    subIndex = 1
  end
  if self.subTogs_[type] then
    tog = self.subTogs_[type][subIndex]
  end
  self:onselectSubTog(type, subIndex, tog)
end

function Trading_ring_mainView:onselectSubTog(type, subIndex, tog)
  if self.selectSubTog_ then
    self.selectSubTog_.Ref:SetVisible(self.selectSubTog_.node_on, false)
    self.selectSubTog_.Ref:SetVisible(self.selectSubTog_.node_off, true)
  end
  if tog then
    self.selectSubTog_ = tog
    self.selectSubTog_.Ref:SetVisible(self.selectSubTog_.node_on, true)
    self.selectSubTog_.Ref:SetVisible(self.selectSubTog_.node_off, false)
  end
  self:onChangeSubView(type, subIndex)
end

function Trading_ring_mainView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Trade_Center)
end

function Trading_ring_mainView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Trade_Center)
end

function Trading_ring_mainView:OnRefresh()
  self:openFirstPage()
  self:loadRedDotItem()
end

function Trading_ring_mainView:loadRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TradeSellType, self, self.uiBinder.binder_sell.node_tog.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TradeItemPreBuy, self, self.uiBinder.binder_trading_record.node_tog.Trans)
end

function Trading_ring_mainView:unLoadRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.TradeSellType, self)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.TradeItemPreBuy, self)
end

return Trading_ring_mainView
