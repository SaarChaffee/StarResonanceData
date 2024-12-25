local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_windowView = class("Shop_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local tog1_Item = require("ui.component.shop.shop_tog1_loop_item")
E.MallType = {
  EMysterious = 6,
  EFashion = 7,
  ERecharge = 13
}

function Shop_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_window")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.seasonVm_ = Z.VMMgr.GetVM("season_shop")
  self.itemShowVm_ = Z.VMMgr.GetVM("item_show")
  self.functionCfg_ = Z.TableMgr.GetTable("FunctionTableMgr")
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.shopAllView_ = require("ui.view.shop_all_sub_view").new(self)
  self.shopEnghView_ = require("ui.view.shop_charge_sub_view").new(self)
  self.shopFashionView_ = require("ui.view.shop_fashion_sub_view").new(self)
  self.shopMysteriousView_ = require("ui.view.shop_mysterious_sub_view").new(self)
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Shop_windowView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  self:onStartAnimShow()
  local nameCfg = self.functionCfg_.GetRow(800800)
  self.uiBinder.lab_title.text = nameCfg and nameCfg.Name or ""
  self.timerCallTable_ = nil
  self:AddClick(self.uiBinder.btn_return, function()
    self.shopVm_.CloseShopView()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(800800)
  end)
  self.firstLoopListView_ = loopListView.new(self, self.uiBinder.loop_first_togs, tog1_Item, "shop_tog_tpl")
  self.firstLoopListView_:Init({})
  self:RegisterInputActions()
end

function Shop_windowView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitProps()
    self:initFirstLevelTab()
  end)()
end

function Shop_windowView:OnDeActive()
  self.firstLoopListView_:UnInit()
  self:UnRegisterInputActions()
  self.showData_ = nil
  self.currencyVm_.CloseCurrencyView(self)
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
end

function Shop_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Shop_windowView:asyncInitProps()
  self.shopData_ = self.seasonVm_.AsyncGetShopData(self.cancelSource, 0)
  self:startTimerForCallbacks()
  local nextUpdateTime = self:calculateNextUpdateTime()
  if 0 < nextUpdateTime then
    self:startUpdateTimer(nextUpdateTime)
  end
end

function Shop_windowView:startTimerForCallbacks()
  self.timerMgr:Clear()
  self.timerMgr:StartTimer(function()
    if self.timerCallTable_ then
      for _, func in pairs(self.timerCallTable_) do
        if func then
          func()
        end
      end
    end
  end, 1, -1)
end

function Shop_windowView:calculateNextUpdateTime()
  local t = 0
  local curT = Z.TimeTools.Now()
  for _, page in ipairs(self.shopData_) do
    for _, item in ipairs(page.items) do
      if 0 < item.endTime and curT < item.endTime then
        local remainingTime = item.endTime - curT
        if t == 0 or t > remainingTime then
          t = remainingTime
        end
      end
    end
  end
  t = math.floor(t / 1000)
  return 0 < t and t or 1
end

function Shop_windowView:startUpdateTimer(nextUpdateTime)
  self.timerMgr:StartTimer(function()
    self:UpdateProp()
  end, nextUpdateTime, 1)
end

function Shop_windowView:UpdateProp()
  self.timerCallTable_ = {}
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitProps()
    if self.curShopView_ then
      self.curShopView_.viewData.shopData = self.shopData_
      self.curShopView_:refreshData(true)
    end
  end)()
end

function Shop_windowView:initFirstLevelTab()
  self.shopTabDataList_ = self.shopVm_.GetShopTabTable(self.shopData_)
  self.firstLevelIndex_ = 1
  if self.viewData and self.viewData.funcId1 then
    self.firstLevelIndex_ = self.shopVm_.GetShopTabIndexByFunctionId(tonumber(self.viewData.funcId1), self.shopTabDataList_) or 1
  end
  self.firstLoopListView_:ClearAllSelect()
  self.firstLoopListView_:RefreshListView(self.shopTabDataList_, false)
  if not self.firstLevelIndex_ then
    self.firstLevelIndex_ = 1
  end
  self.firstLoopListView_:SetSelected(self.firstLevelIndex_)
end

function Shop_windowView:Tog1Click(shopTabData)
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
  self:OpenCurrencyView(shopTabData.fristLevelTabData.CurrencyDisplay)
  local viewData = {}
  viewData.shopData = self.shopData_
  viewData.parentView = self
  for _, shopData in ipairs(self.shopTabDataList_) do
    if shopData.fristLevelTabData.FunctionId == shopTabData.fristLevelTabData.FunctionId then
      viewData.shopTabData = shopData
    end
  end
  self.curShopId_ = shopTabData.fristLevelTabData.Id
  if shopTabData.fristLevelTabData.Id == E.MallType.ERecharge then
    self.shopEnghView_:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = self.shopEnghView_
  elseif shopTabData.fristLevelTabData.Id == E.MallType.EFashion then
    self.shopFashionView_:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = self.shopFashionView_
  elseif shopTabData.fristLevelTabData.ShowCountDown == 1 then
    self.shopMysteriousView_:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = self.shopMysteriousView_
  else
    self.shopAllView_:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = self.shopAllView_
  end
end

function Shop_windowView:OpenBuyPopup(data, index, tabId)
  self.seasonVm_.OpenBuyPopup(data, function(data_, num)
    self.seasonVm_.AsyncBuyShopItem(0, data_, num, function(req)
      if req.errorCode == 0 then
        self:buyCallFunc(req)
      end
    end, self.cancelSource, tabId)
  end, self.currencyArray_)
end

function Shop_windowView:buyCallFunc(req)
  self.seasonVm_.CloseBuyPopup()
  self:UpdateProp()
  local mallCfg = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(req.itemId)
  if mallCfg then
    self:handleMallItemCost(mallCfg, req.itemId)
    self:handleMallItemDelivery(mallCfg, req.buyCount)
  end
  if self.curShopId_ == E.MallType.EFashion and self.curShopView_ then
    self.curShopView_:refreshData()
  end
end

function Shop_windowView:handleMallItemCost(mallCfg, itemId)
  Z.CoroUtil.create_coro_xpcall(function()
    for id, num in pairs(mallCfg.Cost) do
      if num == 0 then
        self.shopVm_.AsyncSetShopItemRed(itemId, E.EShopType.Shop)
        break
      end
    end
  end)()
end

function Shop_windowView:handleMallItemDelivery(mallCfg, buyCount)
  if mallCfg.DeliverWay and mallCfg.DeliverWay[1] and mallCfg.DeliverWay[1][1] == 0 then
    local itemTableRow = Z.TableMgr.GetRow("ItemTableMgr", mallCfg.ItemId)
    if itemTableRow and itemTableRow.SpecialDisplayType == 0 then
      local awardTab = self:generateAwardTab(mallCfg, buyCount)
      self.itemShowVm_.OpenItemShowView(awardTab)
    end
  else
    Z.TipsVM.ShowTipsLang(1000722)
  end
end

function Shop_windowView:generateAwardTab(mallCfg, buyCount)
  local awardTab = {}
  local equipTabCfg = Z.TableMgr.GetTable("EquipTableMgr").GetRow(mallCfg.ItemId, true)
  if equipTabCfg then
    for i = 1, buyCount do
      table.insert(awardTab, {
        configId = mallCfg.ItemId,
        lab = 1
      })
    end
  else
    table.insert(awardTab, {
      configId = mallCfg.ItemId,
      count = buyCount
    })
  end
  return awardTab
end

function Shop_windowView:RigestTimerCall(key, func)
  if not self.timerCallTable_ then
    self.timerCallTable_ = {}
  end
  self.timerCallTable_[key] = func
end

function Shop_windowView:UnrigestTimerCall(key)
  if self.timerCallTable_ then
    self.timerCallTable_[key] = nil
  end
end

function Shop_windowView:RegisterInputActions()
  Z.InputMgr:AddInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Shop)
end

function Shop_windowView:UnRegisterInputActions()
  Z.InputMgr:RemoveInputEventDelegate(self.onInputAction_, Z.InputActionEventType.ButtonJustPressed, Z.RewiredActionsConst.Shop)
end

function Shop_windowView:OpenCurrencyView(array)
  if not array and #array == 0 then
    array = Z.SystemItem.DefaultCurrencyDisplay
  end
  self.currencyArray_ = array
  self.currencyVm_.OpenCurrencyView(array, self.uiBinder.Trans, self)
end

function Shop_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

return Shop_windowView
