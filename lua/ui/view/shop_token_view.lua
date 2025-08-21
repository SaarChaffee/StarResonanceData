local UI = Z.UI
local super = require("ui.ui_view_base")
local Shop_tokenView = class("Shop_tokenView", super)
local loopListView = require("ui.component.loop_list_view")
local tog1_Item = require("ui.component.shop.shop_tog1_loop_item")
local currency_item_list = require("ui.component.currency.currency_item_list")

function Shop_tokenView:ctor()
  self.uiBinder = nil
  super.ctor(self, "shop_token")
  self.shopVm_ = Z.VMMgr.GetVM("shop")
  self.functionCfg_ = Z.TableMgr.GetTable("FunctionTableMgr")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
  self.shopAllView_ = require("ui.view.shop_all_sub_view").new(self)
  self.shopFashionView_ = require("ui.view.shop_fashion_sub_view").new(self)
  self.shopGiftView_ = require("ui.view.shop_gift_sub_view").new(self)
  self.shopViewList_ = {
    [E.EShopViewType.ECommon] = self.shopAllView_,
    [E.EShopViewType.EGift] = self.shopGiftView_,
    [E.EShopViewType.EFashion] = self.shopFashionView_
  }
  self.shopFunctionId_ = {
    [E.EShopType.TokenShop] = E.FunctionID.TokenShop,
    [E.EShopType.CompensateShop] = E.FunctionID.CompensatenShop,
    [E.EShopType.ActivityShop] = E.FunctionID.ActivityShop,
    [E.EShopType.HouseShop] = E.FunctionID.HomeBuyShop
  }
  self.shopTipsId_ = {
    [E.EShopType.TokenShop] = 400009,
    [E.EShopType.CompensateShop] = 400108,
    [E.EShopType.ActivityShop] = 2300,
    [E.EShopType.HouseShop] = 40004
  }
  self.refluxConfigId_ = 101
  
  function self.onInputAction_(inputActionEventData)
    self:OnInputBack()
  end
end

function Shop_tokenView:OnActive()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:onStartAnimShow()
  if self.viewData then
    self.shopType_ = self.viewData.shopType or E.EShopType.TokenShop
  else
    self.shopType_ = E.EShopType.TokenShop
  end
  local nameCfg = self.functionCfg_.GetRow(self.shopFunctionId_[self.shopType_])
  self.uiBinder.lab_title.text = nameCfg and nameCfg.Name or ""
  self.timerCallTable_ = nil
  self:AddClick(self.uiBinder.btn_return, function()
    local shopData = Z.DataMgr.Get("shop_data")
    shopData:InitShopBuyItemInfoList()
    self.shopVm_.CloseTokenShopView()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_service, self.userSupportVM_.CheckValid(E.UserSupportType.Recharge))
  self:AddClick(self.uiBinder.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.Recharge)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self.helpsysVM_.OpenFullScreenTipsView(self.shopTipsId_[self.shopType_])
  end)
  if self.shopType_ == E.EShopType.CompensateShop then
    self:AddClick(self.uiBinder.btn_reflux, function()
      self.helpsysVM_.OpenMulHelpSysView(self.refluxConfigId_)
    end)
  end
  self.firstLoopListView_ = loopListView.new(self, self.uiBinder.loop_first_togs, tog1_Item, "shop_tog_tpl", true)
  self.firstLoopListView_:Init({})
  self:refreshNodeShop()
  local shopData = Z.DataMgr.Get("shop_data")
  shopData:InitShopBuyItemInfoList()
  Z.CoroUtil.create_coro_xpcall(function()
    self:asyncInitFirstLevelTab()
    self:startTimerForCallbacks()
  end)()
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_desc, false)
  Z.EventMgr:Add(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_tokenView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.firstLoopListView_:UnInit()
  if self.currencyItemList_ then
    self.currencyItemList_:UnInit()
    self.currencyItemList_ = nil
  end
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
  self.ESCInputFunction_ = nil
  Z.EventMgr:Remove(Z.ConstValue.Shop.NotifyBuyShopResult, self.buyCallFunc, self)
end

function Shop_tokenView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene(self.ViewConfigKey)
end

function Shop_tokenView:asyncInitFirstLevelTab()
  self.shopData_ = self.shopVm_.AsyncGetShopDataByShopType(self.viewData.shopType, self.cancelSource:CreateToken())
  self.firstShopTabDataList_ = self.shopVm_.GetShopTabTable(self.shopData_, self.viewData.shopType)
  self.firstLoopListView_:ClearAllSelect()
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
  self.firstLoopListView_:RefreshListView(self.firstShopTabDataList_, false)
  self.firstLoopListView_:SetSelected(self.firstIndex_)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shop, true)
end

function Shop_tokenView:GetCacheData()
  return {
    shopType = self.shopType_,
    firstIndex = self.firstIndex_,
    secondIndex = self.secondIndex_,
    threeIndex = self.threeIndex_,
    shopItemIndex = self.shopItemIndex_,
    configId = self.configId_
  }
end

function Shop_tokenView:SetSecondIndex(index)
  self.secondIndex_ = index
end

function Shop_tokenView:SetThreeIndex(index)
  self.threeIndex_ = index
end

function Shop_tokenView:SetShopItemIndex(index)
  self.shopItemIndex_ = index
end

function Shop_tokenView:OnClickFirstShop(shopTabData, index, isClick)
  if self.curShopView_ then
    self.curShopView_:DeActive()
  end
  self:OpenCurrencyView(shopTabData.fristLevelTabData.CurrencyDisplay)
  if isClick then
    self.firstIndex_ = index
    self.secondIndex_ = nil
    self.threeIndex_ = nil
    self.shopItemIndex_ = nil
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
  local viewType = shopTabData.fristLevelTabData.ViewType or E.EShopViewType.ECommon
  viewType = viewType == 0 and E.EShopViewType.ECommon or viewType
  local curView = self.shopViewList_[viewType]
  if curView then
    curView:Active(viewData, self.uiBinder.node_parent)
    self.curShopView_ = curView
  end
end

function Shop_tokenView:initShopItemIndex()
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

function Shop_tokenView:OpenBuyPopup(data, index, tabId)
  self.shopVm_.OpenBuyPopup(data, function(data_, num)
    self.shopVm_.AsyncShopBuyItemList({
      [data_.itemId] = {buyNum = num}
    }, self.cancelSource:CreateToken())
  end, self.currencyArray_)
end

function Shop_tokenView:OpenCurrencyView(array)
  if not array and #array == 0 then
    array = Z.SystemItem.DefaultCurrencyDisplay
  end
  self.currencyArray_ = array
  if not self.currencyItemList_ then
    self.currencyItemList_ = currency_item_list.new()
  end
  self.currencyItemList_:Init(self.uiBinder.currency_info, self.currencyArray_)
end

function Shop_tokenView:buyCallFunc(buyShopItemInfo)
  self.shopVm_.CloseBuyPopup()
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

function Shop_tokenView:handleMallItemCost(mallCfg, itemId)
  for id, num in pairs(mallCfg.Cost) do
    if num == 0 then
      self.shopVm_.SetShopItemRed(itemId, E.EShopType.Shop)
      break
    end
  end
end

function Shop_tokenView:refreshNodeShop()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_token_shop, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_shop, false)
  if self.shopType_ == E.EShopType.CompensateShop then
    local helpLibraryTableRow = Z.TableMgr.GetTable("HelpLibraryTableMgr").GetRow(self.refluxConfigId_)
    if helpLibraryTableRow then
      self.uiBinder.lab_reflux.text = helpLibraryTableRow.Title
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reflux, true)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reflux, false)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_reflux, false)
  end
  local nameCfg = self.functionCfg_.GetRow(E.FunctionID.Shop)
  self.uiBinder.lab_shop_content.text = nameCfg and nameCfg.Name or ""
  self.uiBinder.btn_shop:AddListener(function()
    local shopData = Z.DataMgr.Get("shop_data")
    shopData:InitShopBuyItemInfoList()
    self.shopVm_.OpenShopView()
  end)
end

function Shop_tokenView:SetEscInputFuction(func)
  self.ESCInputFunction_ = func
end

function Shop_tokenView:OnInputBack()
  if self.IsResponseInput then
    if self.ESCInputFunction_ then
      self.ESCInputFunction_()
    else
      local shopData = Z.DataMgr.Get("shop_data")
      shopData:InitShopBuyItemInfoList()
      Z.UIMgr:CloseView(self.ViewConfigKey)
    end
  end
end

function Shop_tokenView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Shop_tokenView:RigestTimerCall(key, func)
  if not self.timerCallTable_ then
    self.timerCallTable_ = {}
  end
  self.timerCallTable_[key] = func
end

function Shop_tokenView:UnrigestTimerCall(key)
  if self.timerCallTable_ then
    self.timerCallTable_[key] = nil
  end
end

function Shop_tokenView:startTimerForCallbacks()
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

return Shop_tokenView
