local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_windowView = class("Shop_windowView", super)
local loopListView = require("ui.component.loop_list_view")
local tog1_Item = require("ui.component.shop.shop_tog1_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Shop_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_window")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.functionCfg_ = Z.TableMgr.GetTable("FunctionTableMgr")
  self.fashionVM_ = Z.VMMgr.GetVM("fashion")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
  self.shopAllView_ = require("ui.view.shop_all_sub_view").new(self)
  self.shopPayView_ = require("ui.view.shop_pay_sub_view").new(self)
  self.shopFashionView_ = require("ui.view.shop_fashion_sub_view").new(self)
  self.shopMysteriousView_ = require("ui.view.shop_mysterious_sub_view").new(self)
  self.monthlyCardView_ = require("ui.view.monthly_reward_card_sub_view").new(self)
  self.shopGiftView_ = require("ui.view.shop_gift_sub_view").new(self)
  self.shopViewList_ = {
    [E.EShopViewType.ECommon] = self.shopAllView_,
    [E.EShopViewType.EGift] = self.shopGiftView_,
    [E.EShopViewType.ERewardCard] = self.monthlyCardView_,
    [E.EShopViewType.EFashion] = self.shopFashionView_,
    [E.EShopViewType.EMysterious] = self.shopMysteriousView_,
    [E.EShopViewType.EPay] = self.shopPayView_
  }
end

function Shop_windowView:OnActive()
  Z.AudioMgr:Play("UI_Event_ShopWindowEnter")
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:onStartAnimShow()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_desc, true)
  local nameCfg = self.functionCfg_.GetRow(E.FunctionID.Shop)
  self.uiBinder.lab_title.text = nameCfg and nameCfg.Name or ""
  self.timerCallTable_ = nil
  self:AddClick(self.uiBinder.btn_return, function()
    local shopData = Z.DataMgr.Get("shop_data")
    shopData:InitShopBuyItemInfoList()
    self.shopVm_.CloseShopView()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_service, self.userSupportVM_.CheckValid(E.UserSupportType.Recharge))
  self:AddClick(self.uiBinder.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.Recharge)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(E.FunctionID.Shop)
  end)
  self.firstLoopListView_ = loopListView.new(self, self.uiBinder.loop_first_togs, tog1_Item, "shop_tog_tpl", true)
  self.firstLoopListView_:Init({})
  self:HideBanner()
  self:refreshNodeShop()
  Z.EventMgr:Add(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_windowView:OnRefresh()
  Z.CoroUtil.create_coro_xpcall(function()
    Z.VMMgr.GetVM("payment"):AsyncQueryBalance()
    if Z.DataMgr.Get("payment_data"):GetProductName() == nil then
      Z.VMMgr.GetVM("payment"):AysncQueryProduct()
    end
    self:asyncInitProps()
    self:initFirstLevelTab()
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_token_shop, true)
  end)()
end

function Shop_windowView:OnDeActive()
  self:HideBanner()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.firstLoopListView_:UnInit()
  self.showData_ = nil
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
  self.secondIndex_ = nil
  self.threeIndex_ = nil
  self.shopItemIndex_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_windowView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Shop_windowView:asyncInitProps()
  self.shopData_ = self.shopVm_.AsyncGetShopDataByShopType(E.EShopType.Shop, self.cancelSource:CreateToken())
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
  return t
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
    if self.curShopView_ and self.curShopView_.viewData and self.curShopView_.viewData.shopData then
      self.curShopView_.viewData.shopData = self.shopData_
      self.curShopView_:RefreshData(true)
    end
  end)()
end

function Shop_windowView:initFirstLevelTab()
  self.firstShopTabDataList_ = self.shopVm_.GetShopTabTable(self.shopData_, E.EShopType.Shop)
  self:initShopItemIndex()
  if self.viewData and not self.firstIndex_ and self.viewData.firstIndex then
    self.firstIndex_ = self.viewData.firstIndex
  end
  if self.viewData and not self.secondIndex_ and self.viewData.secondIndex then
    self.secondIndex_ = self.viewData.secondIndex
  end
  self.firstIndex_ = self.firstIndex_ or 1
  self.secondIndex_ = self.secondIndex_ or 1
  if self.viewData then
    self.threeIndex_ = self.viewData.threeIndex
    self.shopItemIndex_ = self.viewData.shopItemIndex
    self.configId_ = self.viewData.configId
  end
  self.firstLoopListView_:ClearAllSelect()
  self.firstLoopListView_:RefreshListView(self.firstShopTabDataList_, false)
  self.firstLoopListView_:SetSelected(self.firstIndex_)
end

function Shop_windowView:initShopItemIndex()
  self.firstIndex_ = nil
  self.secondIndex_ = nil
  if not self.viewData or not self.viewData.funcId then
    return
  end
  local firstIndex, secondIndex = self.shopVm_.GetShopTabIndexByFunctionId(self.viewData.funcId, self.firstShopTabDataList_)
  if firstIndex then
    self.firstIndex_ = firstIndex
  end
  if secondIndex then
    self.secondIndex_ = secondIndex
  end
end

function Shop_windowView:GetCacheData()
  return {
    firstIndex = self.firstIndex_,
    secondIndex = self.secondIndex_,
    threeIndex = self.threeIndex_,
    shopItemIndex = self.shopItemIndex_,
    configId = self.configId_
  }
end

function Shop_windowView:SetSecondIndex(index)
  self.secondIndex_ = index
end

function Shop_windowView:SetThreeIndex(index)
  self.threeIndex_ = index
end

function Shop_windowView:SetShopItemIndex(index)
  self.shopItemIndex_ = index
end

function Shop_windowView:OnClickFirstShop(shopTabData, index, isClick)
  self:HideBanner()
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
  self:OpenCurrencyView(shopTabData.fristLevelTabData.CurrencyDisplay)
  if isClick then
    self.firstIndex_ = index
    self.secondIndex_ = nil
    self.threeIndex_ = nil
    self.shopItemIndex_ = nil
    self.configId_ = nil
  end
  local viewData = {
    shopData = self.shopData_,
    parentView = self,
    shopTabData = shopTabData,
    secondIndex = self.secondIndex_,
    threeIndex = self.threeIndex_,
    shopItemIndex = self.shopItemIndex_,
    configId = self.configId_,
    isClick = isClick
  }
  self.configId_ = nil
  self.curShopId_ = shopTabData.fristLevelTabData.FunctionId
  local viewType = shopTabData.fristLevelTabData.ViewType or E.EShopViewType.ECommon
  local curView = self.shopViewList_[viewType]
  if curView then
    curView:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = curView
  end
end

function Shop_windowView:OpenBuyPopup(data, index, tabId)
  self.shopVm_.OpenBuyPopup(data, function(data_, num)
    self.shopVm_.CloseBuyPopup()
    self.shopVm_.AsyncShopBuyItemList({
      [data_.itemId] = {buyNum = num}
    }, self.cancelSource:CreateToken())
  end, self.currencyArray_)
end

function Shop_windowView:buyCallFunc(buyShopItemInfo)
  local isSuccess = false
  local updataShopIdList = {}
  if buyShopItemInfo then
    for _, data in pairs(buyShopItemInfo) do
      if data.errCode == 0 then
        local mallCfg = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
        if mallCfg then
          self:handleMallItemCost(mallCfg, data.itemId)
          self.shopVm_.ShowBuyResultItemTips(mallCfg, data.buyNum * mallCfg.Quantity)
        end
        isSuccess = true
        if not table.zcontains(updataShopIdList, data.shopId) then
          updataShopIdList[#updataShopIdList + 1] = data.shopId
        end
      else
        Z.TipsVM.ShowTips(data.errCode)
      end
    end
  end
  if not isSuccess or not self.curShopView_ then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    local shopData = self.shopVm_.AsyncGetShopData(updataShopIdList, self.cancelSource:CreateToken())
    self.shopVm_.UpdataAllShopItemData(shopData, self.shopData_)
    if self.curShopView_.viewData and self.curShopView_.viewData.shopData then
      self.curShopView_.viewData.shopData = self.shopData_
      self.curShopView_:RefreshData(true)
    end
  end)()
end

function Shop_windowView:handleMallItemCost(mallCfg, itemId)
  for id, num in pairs(mallCfg.Cost) do
    if num == 0 then
      self.shopVm_.SetShopItemRed(itemId, E.EShopType.Shop)
      break
    end
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

function Shop_windowView:OpenCurrencyView(array)
  if not array and #array == 0 then
    array = Z.SystemItem.DefaultCurrencyDisplay
  end
  self.currencyArray_ = array
  if not self.currencyItemList_ then
    self.currencyItemList_ = currency_item_list.new()
  end
  self.currencyItemList_:Init(self.uiBinder.currency_info, self.currencyArray_)
end

function Shop_windowView:refreshNodeShop()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_token_shop, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shop, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reflux, false)
  self.uiBinder.lab_token_content.text = Lang("VipShopShortName")
  self.uiBinder.btn_token_shop:AddListener(function()
    local shopData = Z.DataMgr.Get("shop_data")
    shopData:InitShopBuyItemInfoList()
    self.shopVm_.OpenTokenShopView()
  end)
end

function Shop_windowView:SetEscInputFuction(func)
  self.ESCInputFunction_ = func
end

function Shop_windowView:OnInputBack()
  if self.IsResponseInput then
    if self.ESCInputFunction_ then
      self.ESCInputFunction_()
    else
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end
end

function Shop_windowView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Shop_windowView:ShowBanner(imgPath, iconPath)
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_banner, true)
  self.uiBinder.rimg_banner:SetImage(imgPath)
  self.uiBinder.rimg_bannericon:SetImage(iconPath)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function Shop_windowView:HideBanner()
  self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_banner, false)
end

return Shop_windowView
