local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_putaway_subView = class("Trading_ring_putaway_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local TradeSellItem = require("ui.component.trade.trade_sell_item")
local LoopListView = require("ui.component.loop_list_view")
local ShelvesItem = require("ui.component.trade.shelves_item")
local keyPad = require("ui.view.cont_num_keyboard_view")
local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
local item = require("common.item_binder")

function Trading_ring_putaway_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "trading_ring/trading_ring_putaway_sub"
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_putaway_sub_pc"
  end
  super.ctor(self, "trading_ring_putaway_sub", assetPath, UI.ECacheLv.None)
end

function Trading_ring_putaway_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.isPutOnType_ = false
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.itemSortFactoryVm_ = Z.VMMgr.GetVM("item_sort_factory")
  self.monthlyRewardCardVm_ = Z.VMMgr.GetVM("monthly_reward_card")
  self.monthlyCardData_ = Z.DataMgr.Get("monthly_reward_card_data")
  self.itemBinders_ = {}
  self.tradeCount_ = 0
  self:AddAsyncClick(self.uiBinder.btn_shelf, function()
    if #self.tradeData_.ExchangeSellItemList >= self.tradeCount_ then
      Z.TipsVM.ShowTips(6455)
      return
    end
    local num = self.uiBinder.binder_num_module_tpl_1.slider_temp.value
    local step = self.uiBinder.binder_num_module_tpl_2.slider_temp.value
    local itemSellrow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
    if itemSellrow then
      if itemSellrow.Publicity == 1 then
        local onConfirm = function()
          self.tradeVm_:AsyncExchangePutItem(self.selectItemUuid_, math.floor(num), math.floor(step) * itemSellrow.EachPercentage, true, self.cancelSource:CreateToken())
        end
        Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("StallPublicityDialogTips"), onConfirm, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.StallPublicityDialogTips)
      else
        if self.monthlyRewardCardVm_:GetIsBuyCurrentMonthCard() then
          self.tradeVm_:AsyncExchangePutItem(self.selectItemUuid_, math.floor(num), math.floor(step) * itemSellrow.EachPercentage, false, self.cancelSource:CreateToken())
          return
        end
        local onConfirm = function()
          self.tradeVm_:AsyncExchangePutItem(self.selectItemUuid_, math.floor(num), math.floor(step) * itemSellrow.EachPercentage, false, self.cancelSource:CreateToken())
        end
        Z.DialogViewDataMgr:CheckAndOpenPreferencesDialog(Lang("StallDialogTips"), onConfirm, nil, E.DlgPreferencesType.Login, E.DlgPreferencesKeyType.StallNormalDialogTips)
      end
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_one_click_extraction, function()
    local success = self.tradeVm_:AsyncExchangeWithdraw(self.cancelSource:CreateToken())
    if success then
      Z.RedPointMgr.AsyncCancelRedDot(E.RedType.TradeItemSell)
      Z.RedPointMgr.UpdateNodeCount(E.RedType.TradeItemSell, 0)
      if not self.tradeVm_:CheckAnySellItemTimeOut() then
        Z.RedPointMgr.AsyncCancelRedDot(E.RedType.TradeItemTimeout)
        Z.RedPointMgr.UpdateNodeCount(E.RedType.TradeItemTimeout, 0)
      end
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_return, function()
    self:closeShelves()
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_1.btn_add, function()
    if self.uiBinder.binder_num_module_tpl_1.slider_temp.value >= self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue then
      return
    end
    self.uiBinder.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.binder_num_module_tpl_1.slider_temp.value + 1
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_1.btn_reduce, function()
    if self.uiBinder.binder_num_module_tpl_1.slider_temp.value <= 1 then
      return
    end
    self.uiBinder.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.binder_num_module_tpl_1.slider_temp.value - 1
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_1.btn_max, function()
    if self.uiBinder.binder_num_module_tpl_1.slider_temp.value >= self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue then
      return
    end
    self.uiBinder.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_1.btn_num, function()
    self.keypad_:Active({
      max = self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue
    }, self.uiBinder.binder_num_module_tpl_1.group_keypadroot)
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_2.btn_add, function()
    self.uiBinder.binder_num_module_tpl_2.slider_temp.value = self.uiBinder.binder_num_module_tpl_2.slider_temp.value + 1
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_2.btn_reduce, function()
    self.uiBinder.binder_num_module_tpl_2.slider_temp.value = self.uiBinder.binder_num_module_tpl_2.slider_temp.value - 1
  end)
  self:AddAsyncClick(self.uiBinder.binder_num_module_tpl_2.btn_max, function()
    self.uiBinder.binder_num_module_tpl_2.slider_temp.value = self.uiBinder.binder_num_module_tpl_2.slider_temp.maxValue
  end)
  self:AddAsyncClick(self.uiBinder.btn_privilege_arrow, function()
    Z.VMMgr.GetVM("gotofunc").GoToFunc(E.ShopFuncID.MonthlyCard)
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_shelf, true)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.tradeData_.DefaultItem)
  if itemRow then
    self.uiBinder.rimg_deposit_icon:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
    self.uiBinder.rimg_income_icon:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
    self.uiBinder.rimg_service_charge_icon:SetImage(self.itemVm_.GetItemIcon(self.tradeData_.DefaultItem))
  end
  self.keypad_ = keyPad.new(self)
  self:refreshLoop()
  Z.CoroUtil.create_coro_xpcall(function()
    self.tradeVm_:AsyncExchangeSellItem(self.cancelSource:CreateToken())
    self:refreshShelvesInfo()
    self:refreshIncome()
  end)()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.TradeItemSell, self, self.uiBinder.btn_one_click_extraction.transform)
  self:BindEvent()
  self:refreshShelfMonthlyCardTips()
end

function Trading_ring_putaway_subView:InputNum(num)
  if num > self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue then
    num = self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue
  end
  if num < 1 then
    num = 1
  end
  self.uiBinder.binder_num_module_tpl_1.slider_temp.value = num
end

function Trading_ring_putaway_subView:BindEvent()
  local refreshShelvesInfoNewServerData = function()
    Z.CoroUtil.create_coro_xpcall(function()
      self.tradeVm_:AsyncExchangeSellItem(self.cancelSource:CreateToken())
      self:refreshLoop()
      self:closeShelves()
      self:refreshShelvesInfo()
      self:refreshIncome()
    end)()
  end
  Z.EventMgr:Add(Z.ConstValue.Trade.ExchangeWithdrawSuccess, refreshShelvesInfoNewServerData, self)
  Z.EventMgr:Add(Z.ConstValue.Trade.ExchangePutItemSuccess, refreshShelvesInfoNewServerData, self)
  Z.EventMgr:Add(Z.ConstValue.Trade.ExchangeTakeItemSuccess, refreshShelvesInfoNewServerData, self)
end

function Trading_ring_putaway_subView:refreshLoop()
  local tradeItemDatas = Z.TableMgr.GetTable("StallDetailTableMgr").GetDatas()
  local data = {}
  local selectIndex
  for _, value in pairs(tradeItemDatas) do
    local package = self.itemVm_.GetPackageInfobyItemId(value.ItemID)
    local itemUuids = self.itemsData_:GetItemUuidsByConfigId(value.ItemID)
    if itemUuids and 1 <= #itemUuids then
      for _, itemUuid in ipairs(itemUuids) do
        local item = package.items[itemUuid]
        if item and item.bindFlag == 1 then
          table.insert(data, {
            itemUuid = item.uuid,
            configId = item.configId
          })
        end
      end
    end
  end
  if 0 < #data then
    local itemSortfunc = self.itemSortFactoryVm_.GetTradeSellItemSortFunc()
    table.sort(data, itemSortfunc)
    for index, value in ipairs(data) do
      if value.itemUuid == self.viewData.itemUuid then
        selectIndex = index
      end
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, true)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, false)
    if self.loopItemView_ == nil then
      local path = "com_item_long_1"
      if Z.IsPCUI then
        path = "com_item_long_2_8"
      end
      self.loopItemView_ = loopGridView.new(self, self.uiBinder.scrollview_item, TradeSellItem, path)
      self.loopItemView_:Init(data)
    else
      self.loopItemView_:ClearAllSelect()
      self.loopItemView_:RefreshListView(data)
    end
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.scrollview_item, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_empty_left, true)
  end
  self:closeShelves()
  if selectIndex then
    self.loopItemView_:MovePanelToItemIndex(selectIndex)
    self.loopItemView_:SetSelected(selectIndex)
  end
  self.viewData.itemUuid = nil
end

function Trading_ring_putaway_subView:refreshShelvesInfo()
  local data = {}
  local index = 1
  local isSelect = false
  self.tradeCount_ = self.tradeData_.InitialStallNum
  if self.monthlyRewardCardVm_:GetIsBuyCurrentMonthCard() then
    self.tradeCount_ = self.tradeCount_ + Z.StallRuleConfig.MonthCardSaleStallNum
  end
  for i = 1, self.tradeCount_, 2 do
    data[index] = {}
    local isEmpty = self.tradeData_.ExchangeSellItemList[i] == nil
    if isEmpty then
      data[index][1] = {
        isSelect = isEmpty and not isSelect,
        data = {}
      }
      isSelect = true
    else
      data[index][1] = {
        isSelect = false,
        data = self.tradeData_.ExchangeSellItemList[i]
      }
    end
    local isEmpty = self.tradeData_.ExchangeSellItemList[i + 1] == nil
    if isEmpty then
      data[index][2] = {
        isSelect = isEmpty and not isSelect,
        data = {}
      }
      isSelect = true
    else
      data[index][2] = {
        isSelect = false,
        data = self.tradeData_.ExchangeSellItemList[i + 1]
      }
    end
    index = index + 1
  end
  if self.loopShelvesView_ == nil then
    local path = "trading_ring_shelf_item_list_tpl"
    if Z.IsPCUI then
      path = "trading_ring_shelf_item_list_tpl_pc"
    end
    self.loopShelvesView_ = LoopListView.new(self, self.uiBinder.scrollview_shelf, ShelvesItem, path)
    self.loopShelvesView_:Init(data)
  else
    self.loopShelvesView_:ClearAllSelect()
    self.loopShelvesView_:RefreshListView(data)
  end
end

function Trading_ring_putaway_subView:refreshIncome()
  local incomeInfos = {
    [1] = {
      icon = self.uiBinder.rimg_extract_icon_2,
      num = self.uiBinder.lab_extract_2
    },
    [2] = {
      icon = self.uiBinder.rimg_extract_icon_1,
      num = self.uiBinder.lab_extract_1
    }
  }
  local index = 1
  for id, num in pairs(self.tradeData_.WithDrawItem) do
    self.uiBinder.Ref:SetVisible(incomeInfos[index].icon, true)
    self.uiBinder.Ref:SetVisible(incomeInfos[index].num, true)
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemRow then
      incomeInfos[index].icon:SetImage(self.itemVm_.GetItemIcon(id))
      incomeInfos[index].num.text = num
      index = index + 1
    end
  end
  for i = index, #incomeInfos do
    self.uiBinder.Ref:SetVisible(incomeInfos[i].icon, false)
    self.uiBinder.Ref:SetVisible(incomeInfos[i].num, false)
  end
end

function Trading_ring_putaway_subView:onClickSellItem(configId, itemUuid)
  self.selectItemId_ = configId
  self.selectItemUuid_ = itemUuid
  Z.CoroUtil.create_coro_xpcall(function()
    self:putOnShelves()
  end)()
end

function Trading_ring_putaway_subView:closeShelves()
  self.selectItemId_ = nil
  self.selectItemUuid_ = nil
  self.isPutOnType_ = false
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_shelf, true)
  if self.loopItemView_ then
    self.loopItemView_:ClearAllSelect()
  end
end

function Trading_ring_putaway_subView:putOnShelves()
  local _, price = self.tradeVm_:AsyncExchangeLowestPrice(self.selectItemId_, self.cancelSource:CreateToken())
  if price == 0 then
    self.uiBinder.lab_cur_sell_lowest_price.text = Lang("no_sell_items_yet")
  else
    self.uiBinder.lab_cur_sell_lowest_price.text = Lang("cur_sell_lowest_price") .. price
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bg, true)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_shelf, false)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.selectItemId_)
  if itemRow == nil then
    return
  end
  local itemSellrow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
  if itemSellrow == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(self.itemVm_.GetItemIcon(self.selectItemId_))
  self:AddAsyncClick(self.uiBinder.rimg_icon_click, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
    end
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.item_info_root, self.selectItemId_, self.selectItemUuid_)
  end)
  self.uiBinder.lab_name.text = itemRow.Name
  local package = self.itemVm_.GetPackageInfobyItemId(self.selectItemId_)
  self.itemData_ = package.items[self.selectItemUuid_]
  local itemCount = self.itemData_.count
  self.uiBinder.lab_own_num.text = string.format(Lang("SeasonShopOwn"), itemCount)
  local maxNum = itemCount
  if itemCount > itemSellrow.OnceSaleLimit then
    maxNum = itemSellrow.OnceSaleLimit
  end
  self.uiBinder.binder_num_module_tpl_1.slider_temp:RemoveAllListeners()
  if maxNum == 1 then
    self.uiBinder.binder_num_module_tpl_1.slider_temp.minValue = 0
    self.uiBinder.binder_num_module_tpl_1.slider_temp.interactable = false
  else
    self.uiBinder.binder_num_module_tpl_1.slider_temp.minValue = 1
    self.uiBinder.binder_num_module_tpl_1.slider_temp.interactable = true
  end
  self.uiBinder.binder_num_module_tpl_1.slider_temp.maxValue = maxNum
  self.uiBinder.binder_num_module_tpl_1.slider_temp.value = 1
  self.uiBinder.binder_num_module_tpl_1.lab_num.text = 1
  self.uiBinder.binder_num_module_tpl_1.slider_temp:AddListener(function()
    self.uiBinder.binder_num_module_tpl_1.lab_num.text = math.floor(self.uiBinder.binder_num_module_tpl_1.slider_temp.value)
    self:refreshPrice()
  end)
  local nowRecommendedPrice = math.floor(itemSellrow.RecommendedPrice * (self.tradeData_.ServerRate / self.tradeData_.DefalutDiamondTax) + 0.5)
  if nowRecommendedPrice < itemSellrow.Minimum then
    nowRecommendedPrice = itemSellrow.Minimum
  end
  if nowRecommendedPrice > itemSellrow.Maximum then
    nowRecommendedPrice = itemSellrow.Maximum
  end
  local nowMinPrice = math.floor(nowRecommendedPrice * (100 - itemSellrow.MinPercentage) / 100 + 0.5)
  local nowMaxPrice = math.floor(nowRecommendedPrice * (100 + itemSellrow.MaxPercentage) / 100 + 0.5)
  if nowMaxPrice <= itemSellrow.Minimum then
    self.uiBinder.binder_num_module_tpl_2.slider_temp.minValue = 0
    self.uiBinder.binder_num_module_tpl_2.slider_temp.maxValue = 0
    nowRecommendedPrice = itemSellrow.Minimum
  elseif nowMaxPrice <= itemSellrow.Maximum then
    self.uiBinder.binder_num_module_tpl_2.slider_temp.maxValue = itemSellrow.MaxPercentage / itemSellrow.EachPercentage
  else
    local step = (itemSellrow.Maximum - nowRecommendedPrice) / (nowRecommendedPrice * itemSellrow.EachPercentage / 100)
    self.uiBinder.binder_num_module_tpl_2.slider_temp.maxValue = step
  end
  if nowMinPrice >= itemSellrow.Maximum then
    self.uiBinder.binder_num_module_tpl_2.slider_temp.minValue = 0
    self.uiBinder.binder_num_module_tpl_2.slider_temp.maxValue = 0
    nowRecommendedPrice = itemSellrow.Maximum
  elseif nowMinPrice >= itemSellrow.Minimum then
    self.uiBinder.binder_num_module_tpl_2.slider_temp.minValue = -itemSellrow.MinPercentage / itemSellrow.EachPercentage
  else
    local step = (itemSellrow.Minimum - nowRecommendedPrice) / (nowRecommendedPrice * itemSellrow.EachPercentage / 100)
    self.uiBinder.binder_num_module_tpl_2.slider_temp.minValue = step
  end
  self.uiBinder.binder_num_module_tpl_2.slider_temp:RemoveAllListeners()
  self.uiBinder.binder_num_module_tpl_2.slider_temp.value = 0
  self.uiBinder.binder_num_module_tpl_2.lab_num.text = tostring(nowRecommendedPrice)
  self.uiBinder.binder_num_module_tpl_2.slider_temp:AddListener(function()
    local step = self.uiBinder.binder_num_module_tpl_2.slider_temp.value
    self.unitPrice_ = tostring(nowRecommendedPrice * ((100 + step * itemSellrow.EachPercentage) / 100))
    if 0 < step then
      self.unitPrice_ = math.floor(tonumber(self.unitPrice_))
    else
      self.unitPrice_ = math.ceil(tonumber(self.unitPrice_))
    end
    self.uiBinder.binder_num_module_tpl_2.lab_num.text = self.unitPrice_
    local lab = ""
    if 0 < step then
      lab = Lang("recommend") .. "+" .. math.floor(step * itemSellrow.EachPercentage) .. "%"
    else
      lab = Lang("recommend") .. math.floor(step * itemSellrow.EachPercentage) .. "%"
    end
    self.uiBinder.binder_num_module_tpl_2.lab_recommend_num.text = lab
    self:refreshPrice()
  end)
  self.unitPrice_ = nowRecommendedPrice
  self:refreshPrice()
end

function Trading_ring_putaway_subView:refreshPrice()
  if self.selectItemId_ == nil then
    return
  end
  local itemSellrow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
  if itemSellrow == nil then
    return
  end
  local hasMonthlyCard = self.monthlyRewardCardVm_:GetIsBuyCurrentMonthCard()
  local totalPrice = self.unitPrice_ * self.uiBinder.binder_num_module_tpl_1.slider_temp.value
  local deposit, servicePrice = self.tradeVm_:GetCosts(totalPrice, itemSellrow.TaxPercentage, itemSellrow.DepositPercentage)
  local income = math.floor(totalPrice - servicePrice)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_service_charge_num, not hasMonthlyCard)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_lab_service, hasMonthlyCard)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_deposit_num, not hasMonthlyCard)
  self.uiBinder.Ref:SetVisible(self.uiBinder.layout_lab_deposit, hasMonthlyCard)
  if hasMonthlyCard then
    local newDeposit, newServicePrice = self.tradeVm_:GetCosts(totalPrice, itemSellrow.MonthCardTaxPercentage, itemSellrow.MonthCardDepositPercentage, true)
    income = math.floor(totalPrice - newServicePrice)
    self.uiBinder.lab_service_charge_num_new.text = newServicePrice
    self.uiBinder.lab_deposit_num_new.text = newDeposit
  end
  self.uiBinder.lab_service_charge_num.text = servicePrice
  self.uiBinder.lab_deposit_num.text = deposit
  self.uiBinder.lab_deposit_num_ori.text = deposit
  self.uiBinder.lab_service_charge_num_ori.text = servicePrice
  self.uiBinder.lab_income_num.text = income
end

function Trading_ring_putaway_subView:OnDeActive()
  if self.loopItemView_ then
    self.loopItemView_:UnInit()
    self.loopItemView_ = nil
  end
  if self.loopShelvesView_ then
    self.loopShelvesView_:UnInit()
    self.loopShelvesView_ = nil
  end
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  self.keypad_ = nil
  self.selectItemId_ = nil
  self.selectShelvesUnit_ = nil
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  for index, value in ipairs(self.itemBinders_) do
    value:UnInit()
  end
  self.uiBinder.binder_num_module_tpl_1.slider_temp:RemoveAllListeners()
  self.uiBinder.binder_num_module_tpl_2.slider_temp:RemoveAllListeners()
end

function Trading_ring_putaway_subView:OnRefresh()
end

function Trading_ring_putaway_subView:refreshShelfMonthlyCardTips()
  local monthCardPrivilegeDesTableRow = self.monthlyRewardCardVm_:MonthCardPrivilegeDesTableRow(E.MonthCardPrivilegeLabType.TradingRing)
  if not gotoFuncVM.FuncIsOn(E.FunctionID.MonthlyCard, true) or monthCardPrivilegeDesTableRow.IsHide then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_privilege, false)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_privilege, true)
  local hasMonthlyCard = self.monthlyRewardCardVm_:GetIsBuyCurrentMonthCard()
  local monthlyCardKey = self.monthlyRewardCardVm_:GetActiveMonthlyCardKey()
  if monthlyCardKey == 0 then
    monthlyCardKey = self.monthlyRewardCardVm_:GetCurrentMonthlyCardKey()
  end
  local monthlyCardData = self.monthlyCardData_:GetCardInfo(monthlyCardKey)
  if not monthlyCardData then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_privilege, false)
    return
  end
  local labPrivilegeTitle = hasMonthlyCard and Lang("MonthlyCardPrivilegesIsOn") or Lang("MonthlyCardPrivileges")
  self.uiBinder.lab_privilege_title.text = labPrivilegeTitle
  if monthlyCardData then
    local itemVm = Z.VMMgr.GetVM("items")
    self.uiBinder.rimg_privilege_card:SetImage(itemVm.GetItemIcon(monthlyCardData.ItemConfig.Id))
  else
    hasMonthlyCard = false
  end
  if monthCardPrivilegeDesTableRow then
    self.uiBinder.lab_privilege_content.text = monthCardPrivilegeDesTableRow.PrivilegeDes
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_privilege_arrow, not hasMonthlyCard)
end

return Trading_ring_putaway_subView
