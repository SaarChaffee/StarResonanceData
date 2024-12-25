local UI = Z.UI
local super = require("ui.ui_subview_base")
local Trading_ring_buy_subView = class("Trading_ring_buy_subView", super)
local loopGridView = require("ui.component.loop_grid_view")
local loopListView = require("ui.component.loop_list_view")
local TradeSellItem = require("ui.component.trade.trade_shop_item")
local FindLab = require("ui.component.trade.trade_find_lab_item")
local itemUibinder = require("common.item_binder")
local itemFilter = require("ui.view.trading_ring_filter_view")
local MAXCOUNTPERPAGE = 8
local keyPad = require("ui.view.cont_num_keyboard_view")

function Trading_ring_buy_subView:ctor(parent)
  self.uiBinder = nil
  local assetPath = "trading_ring/trading_ring_buy_sub"
  if Z.IsPCUI then
    assetPath = "trading_ring/trading_ring_buy_sub_pc"
  end
  super.ctor(self, "trading_ring_buy_sub", assetPath, UI.ECacheLv.None)
end

function Trading_ring_buy_subView:OnActive()
  self.uiBinder.Trans:SetAnchorPosition(0, 0)
  self.uiBinder.Trans:SetSizeDelta(0, 0)
  self.tradeVm_ = Z.VMMgr.GetVM("trade")
  self.itemVm_ = Z.VMMgr.GetVM("items")
  self.equipVm_ = Z.VMMgr.GetVM("equip_system")
  self.tradeData_ = Z.DataMgr.Get("trade_data")
  self.itemsData_ = Z.DataMgr.Get("items_data")
  self.allStallDetails_ = Z.TableMgr.GetTable("StallDetailTableMgr").GetDatas()
  self.selectItemId_ = 0
  self.mainTypeTogs_ = {}
  self.subTypeTogs_ = {}
  self.subTypeTogsNames_ = {}
  self.subTypeTogsName_ = {}
  self.selectCategory_ = 0
  self.selectSubCategory_ = 0
  self.selectSubCategoryIndex_ = 1
  self.onlyInStock_ = false
  self.isNotice_ = self.viewData.isNotice
  if self.isNotice_ then
    self.userDataStringName_ = "BKL_TRADE_SEARCH_1"
  else
    self.userDataStringName_ = "BKL_TRADE_SEARCH_2"
  end
  self.pageIndex_ = 1
  self.selectItemUiBinder = nil
  self.item_unit_names_ = {}
  self.itemClass_ = {}
  self.itemSellTimer_ = {}
  self.filter_ = {}
  self.filterTags_ = {}
  self.isBuyType_ = false
  self.itemFilter_ = itemFilter.new(self)
  self.keypad_ = keyPad.new(self)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_screening, true)
  self.selectExchangeItemData_ = nil
  self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp:AddListener(function()
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.lab_num.text = math.floor(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value)
    local count = self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value
    self.uiBinder.node_purchase_sub.lab_income_num.text = math.floor(count * self.selectExchangeItemData_.price)
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.btn_add, function()
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value + 1
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.btn_reduce, function()
    if self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value == 1 then
      return
    end
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value - 1
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.btn_max, function()
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value = self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.maxValue
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.btn_num, function()
    self.keypad_:Active({
      max = self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.maxValue
    }, self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.group_keypadroot)
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_shelf, function()
    local packageIsFull = self.itemVm_.CheckItemPackageIsFull(self.selectExchangeItemData_.itemInfo.configId)
    if packageIsFull then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("BackPackFull"), function()
        Z.VMMgr.GetVM("backpack").OpenBagView()
        Z.DialogViewDataMgr:CloseDialogView()
      end)
      return
    end
    local count = math.floor(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value)
    if count >= Z.Global.StallBuyMaxTips then
      local stallItemInfo = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectExchangeItemData_.itemInfo.configId)
      if stallItemInfo then
        local desc = Lang("TradingBuySecondCertain", {
          val1 = self.itemVm_.ApplyItemNameWithQualityTag(stallItemInfo.Currency),
          val2 = self.selectExchangeItemData_.price * count,
          val3 = self.itemVm_.ApplyItemNameWithQualityTag(self.selectItemId_),
          val4 = count
        })
        Z.DialogViewDataMgr:OpenNormalDialog(desc, function()
          self.tradeVm_:AsyncExchangeBuyItem(self.selectExchangeItemData_.guid, self.selectItemId_, count, self.selectExchangeItemData_.price, self.cancelSource:CreateToken())
          Z.DialogViewDataMgr:CloseDialogView()
        end)
      end
    else
      self.tradeVm_:AsyncExchangeBuyItem(self.selectExchangeItemData_.guid, self.selectItemId_, count, self.selectExchangeItemData_.price, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_advance, function()
    if self.tradeVm_:CheckPreOrderMaxNum() then
      Z.TipsVM.ShowTips(1000804)
      return
    end
    if not self.tradeVm_:CheckItemIsPreOrder(self.selectItemId_, self.selectExchangeItemData_.guid) then
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("StallPreOrderDialogTips"), function()
        self.tradeVm_:AsyncExchangeNoticeBuyItem(self.selectItemId_, self.selectExchangeItemData_.guid, self.cancelSource:CreateToken())
        Z.DialogViewDataMgr:CloseDialogView()
      end)
    else
      self.tradeVm_:AsyncExchangeNoticeBuyItem(self.selectItemId_, self.selectExchangeItemData_.guid, self.cancelSource:CreateToken())
    end
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_left, function()
    self:onPageChange(false)
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_right, function()
    self:onPageChange(true)
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_return, function()
    self:closeShopSellItem()
    if self.isFoces_ then
      self:refreshFocusItem()
    else
      self:refreshSellItemLoop()
    end
  end)
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.btn_check_wardrobe, function()
    self:onItemCompared(self.selectExchangeItemData_.itemInfo, self.selectItemId_)
  end)
  self:AddAsyncClick(self.uiBinder.node_buy_sub.btn_refresh, function()
    local data
    if self.isNotice_ then
      data = self.tradeData_.ExchangeNoticeRefreshClickCD
    else
      data = self.tradeData_.ExchangeRefreshClickCD
    end
    if data and 0 < data then
      return
    end
    self.tradeData_:SetClickRefreshCD(self.isNotice_)
    self:refreshSellItemLoop()
    self:refreshExchangeItemCd()
  end)
  self:AddAsyncClick(self.uiBinder.btn_screening, function()
    self:openItemFilter()
  end)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_close, false)
  self:AddAsyncClick(self.uiBinder.node_buy_sub.btn_close, function()
    self.uiBinder.node_buy_sub.input_search.text = ""
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_close, false)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_find_bg, false)
    self:refreshSellItemLoop()
  end)
  self:AddAsyncClick(self.uiBinder.node_buy_sub.btn_delect, function()
    Z.LocalUserDataMgr.RemoveKey(self.userDataStringName_)
    self:showSearchHistory()
  end)
  self.uiBinder.node_buy_sub.input_search:RemoveAllListeners()
  self.uiBinder.node_buy_sub.input_search.text = ""
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_find_bg, false)
  self.uiBinder.node_buy_sub.input_search:AddSelectListener(function(isSelect)
    if isSelect then
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_close, true)
      if string.zisEmpty(self.uiBinder.node_buy_sub.input_search.text) then
        self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.lab_no_find, false)
        self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_find_bg, true)
        self:showSearchHistory()
      end
    end
  end)
  self.uiBinder.node_buy_sub.input_search:AddListener(function()
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_find_bg, true)
    if string.zisEmpty(self.uiBinder.node_buy_sub.input_search.text) then
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.lab_no_find, false)
      self:showSearchHistory()
      return
    end
    self:initSearchItem()
  end)
  self.uiBinder.node_buy_sub.tog_show_has:AddListener(function()
    self.onlyInStock_ = self.uiBinder.node_buy_sub.tog_show_has.isOn
    if self.isFoces_ then
      self:refreshFocusItem()
    else
      self:refreshSellItemLoop(self.filterFuncs_, self.filterParams_)
    end
  end)
  self.uiBinder.node_buy_sub.tog_show_has.isOn = self.onlyInStock_
  self:BindEvent()
  self:refreshUI()
end

function Trading_ring_buy_subView:BindEvent()
  local buySuccessRefresh = function(self)
    self:forceGetServerData(true)
  end
  Z.EventMgr:Add(Z.ConstValue.Trade.ExchangeBuyItemSuccess, buySuccessRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.ItemFilterConfirm, self.selectedFilterTags, self)
end

function Trading_ring_buy_subView:InputNum(num)
  if num == 0 then
    return
  end
  self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value = num
end

function Trading_ring_buy_subView:showSearchHistory()
  local nowCacheString = Z.LocalUserDataMgr.GetString(self.userDataStringName_)
  local ids = string.split(nowCacheString, "|")
  local itemRows = {}
  for _, value in ipairs(ids) do
    if not string.zisEmpty(value) then
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(tonumber(value))
      table.insert(itemRows, itemRow)
    end
  end
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_find, 0 < #itemRows)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_search_history, 0 < #itemRows)
  if self.searchLoop_ == nil then
    local path = "trading_ring_find_item_tpl"
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    self.searchLoop_ = loopListView.new(self, self.uiBinder.node_buy_sub.scrollview_find, FindLab, path)
    self.searchLoop_:Init(itemRows)
  else
    self.searchLoop_:ClearAllSelect()
    self.searchLoop_:RefreshListView(itemRows)
  end
end

function Trading_ring_buy_subView:initSearchItem()
  local inputName = self.uiBinder.node_buy_sub.input_search.text
  local itemRows = {}
  for _, value in pairs(self.allStallDetails_) do
    local showInserach = false
    if self.isNotice_ then
      local categoryRow = Z.TableMgr.GetTable("StallCategoryTableMgr").GetRow(value.Subcategory)
      if categoryRow and categoryRow.IsAnnounce == 1 then
        showInserach = true
      end
    else
      showInserach = true
    end
    if showInserach then
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(value.ItemID)
      if itemRow then
        local itemName = itemRow.Name
        local startIndex, endIndex = string.find(itemName, inputName)
        if startIndex and endIndex then
          table.insert(itemRows, itemRow)
        end
      end
    end
  end
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.lab_no_find, #itemRows == 0)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_find, 0 < #itemRows)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_search_history, false)
  if self.searchLoop_ == nil then
    local path = "trading_ring_find_item_tpl"
    if Z.IsPCUI then
      path = path .. "_pc"
    end
    self.searchLoop_ = loopListView.new(self, self.uiBinder.node_buy_sub.scrollview_find, FindLab, path)
    self.searchLoop_:Init(itemRows)
  else
    self.searchLoop_:ClearAllSelect()
    self.searchLoop_:RefreshListView(itemRows)
  end
end

function Trading_ring_buy_subView:OnSearchItem(configId)
  configId = tostring(configId)
  local nowCacheString = Z.LocalUserDataMgr.GetString(self.userDataStringName_)
  local ids = string.split(nowCacheString, "|")
  if table.zcontains(ids, configId) then
    table.zremoveByValue(ids, configId)
    table.insert(ids, 1, configId)
  else
    table.insert(ids, configId)
  end
  local cacheStr = ""
  for _, value in ipairs(ids) do
    if not string.zisEmpty(value) then
      cacheStr = tostring(value) .. "|" .. cacheStr
    end
  end
  Z.LocalUserDataMgr.SetString(self.userDataStringName_, cacheStr)
  Z.CoroUtil.create_coro_xpcall(function()
    local serverData = {}
    if not self.isNotice_ then
      self.tradeVm_:AsyncExchangeItem(configId, {}, false, self.cancelSource:CreateToken())
      serverData = self.tradeData_.ExchangePriceItemList[configId]
    else
      self.tradeVm_:AsyncExchangeNoticeDetail(configId, {}, false, self.cancelSource:CreateToken())
      serverData = self.tradeData_.ExchangeNoticePriceItemList[configId]
    end
    if #serverData == 0 then
      Z.TipsVM.ShowTips(1000802)
      return
    end
    self.uiBinder.node_buy_sub.Ref.UIComp:SetVisible(false)
    self.uiBinder.node_purchase_sub.Ref.UIComp:SetVisible(true)
    self.uiBinder.node_buy_sub.input_search.text = ""
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_close, false)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_find_bg, false)
    self.selectItemId_ = tonumber(configId)
    self:forceGetServerData()
  end)()
end

function Trading_ring_buy_subView:refreshUI()
  self.isFoces_ = self.viewData.isFocus
  if self.isFoces_ then
    self:refreshFocusItem()
    return
  end
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_top, true)
  self.selectCategory_ = self.viewData.selectType
  if self.isNotice_ then
    self.selectCategory_ = self.viewData.selectType
  end
  if self.viewData.selectSubType then
    self.selectSubCategory_ = self.viewData.selectSubType
  end
  local subTypeData = {}
  local tradeCategoryData = Z.TableMgr.GetTable("StallCategoryTableMgr").GetDatas()
  for _, value in pairs(tradeCategoryData) do
    local showCategory = true
    if self.isNotice_ then
      showCategory = showCategory and value.IsAnnounce == 1
    end
    if value.CategoryLevel == self.selectCategory_ and showCategory then
      table.insert(subTypeData, value)
    end
  end
  table.sort(subTypeData, function(a, b)
    if a.Sort == b.Sort then
      return a.ID < b.ID
    else
      return a.Sort < b.Sort
    end
  end)
  self:refreshExchangeItemCd()
  self:initSubType(subTypeData)
end

function Trading_ring_buy_subView:initSubType(data)
  for _, value in ipairs(self.subTypeTogsNames_) do
    self:RemoveUiUnit(value)
  end
  self.subTypeTogsNames_ = {}
  self.uiBinder.node_buy_sub.Ref.UIComp:SetVisible(true)
  if data == nil then
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, false)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, true)
    return
  end
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, true)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, false)
  self.uiBinder.node_purchase_sub.Ref.UIComp:SetVisible(false)
  local path = self.uiBinder.ui_path_cache:GetString("sub_type_tog")
  local root = self.uiBinder.node_buy_sub.sub_type_content
  Z.CoroUtil.create_coro_xpcall(function()
    for index, value in ipairs(data) do
      local tog = self:AsyncLoadUiUnit(path, "sub_tog_" .. index, root)
      tog.tog:RemoveAllListeners()
      self.subTypeTogs_[index] = tog
      self.subTypeTogsNames_[index] = "sub_tog_" .. index
      tog.lab_on.text = value.Name
      tog.lab_off.text = value.Name
      tog.tog.group = self.uiBinder.node_buy_sub.sub_type_toggle_group
      if self.selectSubCategory_ == value.ID then
        self.selectSubCategoryIndex_ = index
      end
      tog.tog:AddListener(function(isOn)
        if isOn then
          self.selectSubCategory_ = value.ID
          self.selectSubCategoryIndex_ = index
          if self.itemFilter_ then
            self.filterTags_ = {}
            self.itemFilter_:DeActive()
          end
          self:refreshSellItemLoop()
        end
      end)
    end
    self.uiBinder.node_buy_sub.sub_type_content:SetAnchorPosition(0, 0)
    if self.subTypeTogs_[self.selectSubCategoryIndex_].tog.isOn then
      self.selectSubCategory_ = data[self.selectSubCategoryIndex_].ID
      self:refreshSellItemLoop()
    else
      self.subTypeTogs_[self.selectSubCategoryIndex_].tog.isOn = true
    end
  end)()
end

function Trading_ring_buy_subView:refreshFocusItem()
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_screening, false)
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_top, false)
  self.uiBinder.node_buy_sub.Ref.UIComp:SetVisible(true)
  self.uiBinder.node_purchase_sub.Ref.UIComp:SetVisible(false)
  Z.CoroUtil.create_coro_xpcall(function()
    local type = E.EExchangeItemType.ExchangeItemTypeShopItem
    if self.isNotice_ then
      type = E.EExchangeItemType.ExchangeItemTypeNoticeShopItem
    end
    local allFocusItem = self.tradeVm_:AsyncExchangeCareList(type, self.cancelSource:CreateToken())
    if allFocusItem == nil then
      return
    end
    local data = {}
    for _, value in ipairs(allFocusItem) do
      local config = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(value.configId)
      local temp = {}
      temp.config = config
      temp.serverData = value
      temp.isFocus = true
      if self.onlyInStock_ then
        if value.num > 0 then
          table.insert(data, temp)
        end
      else
        table.insert(data, temp)
      end
    end
    if #data <= 0 then
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, false)
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, true)
      return
    end
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, true)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, false)
    table.sort(data, function(a, b)
      return a.config.ItemID < b.config.ItemID
    end)
    if self.sellItemLoop_ == nil then
      local path = "trading_ring_item_tpl"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.sellItemLoop_ = loopGridView.new(self, self.uiBinder.node_buy_sub.scrollview_item, TradeSellItem, path)
      self.sellItemLoop_:Init(data)
    else
      self.sellItemLoop_:ClearAllSelect()
      self.sellItemLoop_:RefreshListView(data)
    end
  end)()
end

function Trading_ring_buy_subView:OnShopAttentionItem(itemData)
  Z.CoroUtil.create_coro_xpcall(function()
    local success = false
    local type = E.EExchangeItemType.ExchangeItemTypeShopItem
    local serverData = self.tradeData_.ExchangeItemDict
    if self.isNotice_ then
      type = E.EExchangeItemType.ExchangeItemTypeNoticeShopItem
      serverData = self.tradeData_.ExchangeNoticeItemDict
    end
    if serverData[itemData.config.ItemID] and serverData[itemData.config.ItemID].isCare then
      success = self.tradeVm_:AsyncExchangeCareCancel(type, itemData.config.ItemID, self.cancelSource:CreateToken())
    else
      success = self.tradeVm_:AsyncExchangeCare(type, itemData.config.ItemID, self.cancelSource:CreateToken())
    end
    if success then
      if self.isFoces_ then
        self:refreshFocusItem()
      else
        if serverData[itemData.config.ItemID] then
          serverData[itemData.config.ItemID].isCare = not serverData[itemData.config.ItemID].isCare
        else
          serverData[itemData.config.ItemID] = {}
          serverData[itemData.config.ItemID].isCare = true
        end
        Z.EventMgr:Dispatch(Z.ConstValue.Trade.TradeItemFocusChange, itemData.config.ItemID, serverData[itemData.config.ItemID].isCare)
      end
    end
  end)()
end

function Trading_ring_buy_subView:refreshSellItemLoop(filterFuncs, filterParam)
  if self.selectCategory_ == 0 or self.selectSubCategory_ == 0 then
    return
  end
  local StallCategoryRow = Z.TableMgr.GetTable("StallCategoryTableMgr").GetRow(self.selectSubCategory_)
  if StallCategoryRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_screening, StallCategoryRow.FiiterGroupID ~= 0)
  end
  Z.CoroUtil.create_coro_xpcall(function()
    if self.isNotice_ then
      self.tradeVm_:AsyncExchangeNotice(self.selectCategory_, self.selectSubCategory_, self.cancelSource:CreateToken())
    else
      self.tradeVm_:AsyncExchangeList(self.selectCategory_, self.selectSubCategory_, self.cancelSource:CreateToken())
    end
    local data = {}
    for _, value in pairs(self.allStallDetails_) do
      if value.Category == self.selectCategory_ and value.Subcategory == self.selectSubCategory_ then
        local temp = {}
        temp.config = value
        if self.isNotice_ then
          temp.serverData = self.tradeData_.ExchangeNoticeItemDict[value.ItemID]
        else
          temp.serverData = self.tradeData_.ExchangeItemDict[value.ItemID]
        end
        local passFilter = true
        if filterFuncs and 0 < #filterFuncs then
          passFilter = false
          for index, filterFunc in pairs(filterFuncs) do
            if filterFunc(value.ItemID, filterParam[index]) then
              passFilter = true
            end
          end
        end
        if self.isNotice_ then
          passFilter = passFilter and value.Publicity == 1
        end
        if passFilter then
          if self.onlyInStock_ then
            if temp.serverData then
              table.insert(data, temp)
            end
          else
            table.insert(data, temp)
          end
        end
      end
    end
    if #data <= 0 then
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, false)
      self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, true)
      return
    end
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.scrollview_item, true)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.node_empty_left, false)
    table.sort(data, function(a, b)
      return a.config.ItemID < b.config.ItemID
    end)
    if self.sellItemLoop_ == nil then
      local path = "trading_ring_item_tpl"
      if Z.IsPCUI then
        path = path .. "_pc"
      end
      self.sellItemLoop_ = loopGridView.new(self, self.uiBinder.node_buy_sub.scrollview_item, TradeSellItem, path)
      self.sellItemLoop_:Init(data)
    else
      self.sellItemLoop_:ClearAllSelect()
      self.sellItemLoop_:RefreshListView(data)
    end
    if self.viewData.configId then
      self:trySelectShopItem(self.viewData.configId)
      self.viewData.configId = nil
    end
  end)()
end

function Trading_ring_buy_subView:trySelectShopItem(configId)
  if self.tradeData_.ExchangeNoticeItemDict[configId] == nil then
    Z.TipsVM.ShowTips(1000802)
    return
  end
  local stallDetailRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(configId)
  if stallDetailRow then
    return
  end
  local data = {
    config = stallDetailRow,
    serverData = self.tradeData_.ExchangeNoticeItemDict[configId]
  }
  self:OnShopSellItemSelect(data)
end

function Trading_ring_buy_subView:OnShopSellItemSelect(data)
  if self.itemFilter_ then
    self.filterTags_ = {}
    self.itemFilter_:DeActive()
  end
  self.pageIndex_ = 1
  self.isBuyType_ = true
  self.selectItemId_ = data.config.ItemID
  self.uiBinder.node_buy_sub.Ref.UIComp:SetVisible(false)
  self.uiBinder.node_purchase_sub.Ref.UIComp:SetVisible(true)
  if self.selectCategory_ == nil or self.selectCategory_ == 0 then
    local stallItemInfo = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
    if stallItemInfo then
      self.selectCategory_ = stallItemInfo.Category
      self.selectSubCategory_ = stallItemInfo.Subcategory
    end
  end
  self:forceGetServerData(true)
end

function Trading_ring_buy_subView:closeShopSellItem()
  if self.itemFilter_ then
    self.filterTags_ = {}
    self.itemFilter_:DeActive()
  end
  self.isBuyType_ = false
  self.uiBinder.node_buy_sub.Ref.UIComp:SetVisible(true)
  self.uiBinder.node_purchase_sub.Ref.UIComp:SetVisible(false)
end

function Trading_ring_buy_subView:refreshPurchaseItem(uiBinder, data, index)
  uiBinder.Ref:SetVisible(uiBinder.img_select, false)
  local stallItemInfo = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(data.itemInfo.configId)
  local itemData = {}
  itemData.uiBinder = uiBinder.binder_item
  itemData.configId = data.itemInfo.configId
  if stallItemInfo and data.num > stallItemInfo.OnceLimit then
    itemData.labType = E.ItemLabType.Str
    itemData.lab = stallItemInfo.OnceLimit .. "+"
  else
    itemData.labType = E.ItemLabType.Num
    itemData.lab = data.num
  end
  itemData.isSquareItem = true
  itemData.isClickOpenTips = true
  itemData.itemInfo = data.itemInfo
  local itemClass = self.itemClass_[index]
  if itemClass == nil then
    itemClass = itemUibinder.new(self)
    self.itemClass_[index] = itemClass
  end
  self.itemClass_[index]:Init(itemData)
  uiBinder.Ref:SetVisible(uiBinder.img_select, false)
  local sellItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.itemInfo.configId)
  uiBinder.lab_income_num.text = data.price
  if stallItemInfo then
    local costItemId = stallItemInfo.Currency
    uiBinder.lab_name.text = sellItemRow.Name
    local costItemInfo = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
    if costItemInfo then
      uiBinder.rimg_income_icon:SetImage(self.itemVm_.GetItemIcon(costItemId))
    end
  end
  if self.isNotice_ then
    uiBinder.Ref:SetVisible(uiBinder.img_advance, self.tradeVm_:CheckItemIsPreOrder(data.itemInfo.configId, data.guid))
    if self.itemSellTimer_[index] then
      self.timerMgr:StopTimer(self.itemSellTimer_[index])
      self.itemSellTimer_[index] = nil
    end
    local now = Z.TimeTools.Now() / 1000
    local delta = math.floor(data.noticeTime - now)
    uiBinder.lab_publicity.text = Z.TimeTools.S2HMFormat(delta)
    self.itemSellTimer_[index] = self.timerMgr:StartTimer(function()
      delta = delta - 1
      uiBinder.lab_publicity.text = Z.TimeTools.S2HMFormat(delta)
    end, 1, delta + 1)
  end
  self:AddAsyncClick(uiBinder.btn_select, function()
    if self.selectItemUiBinder then
      self.selectItemUiBinder.Ref:SetVisible(self.selectItemUiBinder.img_select, false)
    end
    self.selectItemUiBinder = uiBinder
    uiBinder.Ref:SetVisible(uiBinder.img_select, true)
    self:OnPurchaseSelect(data)
  end)
  if index == 1 then
    self.selectItemUiBinder = nil
    uiBinder.Ref:SetVisible(uiBinder.img_select, true)
    self.selectItemUiBinder = uiBinder
    self:OnPurchaseSelect(data)
  end
end

function Trading_ring_buy_subView:refreshSellCommodityLoop(configId)
  local serverData = {}
  local root
  local path = ""
  local maxNum = self.tradeData_.CurTradeItemNum
  if not self.isNotice_ then
    serverData = self.tradeData_.ExchangePriceItemList[configId]
    path = self.uiBinder.ui_path_cache:GetString("purchase_item")
    root = self.uiBinder.node_purchase_sub.layout_item
  else
    serverData = self.tradeData_.ExchangeNoticePriceItemList[configId]
    path = self.uiBinder.ui_path_cache:GetString("advance_item")
    root = self.uiBinder.node_purchase_sub.layout_advance
  end
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_right, false)
  if serverData == nil or table.zcount(serverData) == 0 then
    self.uiBinder.node_purchase_sub.Ref:SetVisible(root, false)
    self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_empty_left, true)
    self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_pages, false)
    return
  end
  local maxPage = math.ceil(maxNum / MAXCOUNTPERPAGE)
  self.uiBinder.node_purchase_sub.lab_pages.text = self.pageIndex_ .. "/" .. maxPage
  self.uiBinder.node_purchase_sub.Ref:SetVisible(root, true)
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_pages, true)
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_empty_left, false)
  for _, value in ipairs(self.item_unit_names_) do
    self:RemoveUiUnit(value)
  end
  for _, value in pairs(self.itemSellTimer_) do
    self.timerMgr:StopTimer(value)
  end
  self.itemSellTimer_ = {}
  for i = 1, MAXCOUNTPERPAGE do
    local dataIndex = (self.pageIndex_ - 1) * MAXCOUNTPERPAGE + i
    local data = serverData[dataIndex]
    if data ~= nil then
      local name = "item_unit_" .. i
      local uiBinder = self:AsyncLoadUiUnit(path, name, root)
      self:refreshPurchaseItem(uiBinder, data, i)
      table.insert(self.item_unit_names_, name)
    end
  end
  local categoryDetailRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(configId)
  if categoryDetailRow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_screening, 0 < #categoryDetailRow.FitterId)
  end
end

function Trading_ring_buy_subView:onPageChange(add)
  local maxPage = self.pageIndex_
  if self.isNotice_ then
    maxPage = math.ceil(#self.tradeData_.ExchangeNoticePriceItemList[self.selectItemId_] / MAXCOUNTPERPAGE)
  else
    maxPage = math.ceil(#self.tradeData_.ExchangePriceItemList[self.selectItemId_] / MAXCOUNTPERPAGE)
  end
  if add then
    if maxPage <= self.pageIndex_ then
      return
    end
    self.pageIndex_ = self.pageIndex_ + 1
  else
    if self.pageIndex_ <= 1 then
      return
    end
    self.pageIndex_ = self.pageIndex_ - 1
  end
  self:tryGetServerData()
end

function Trading_ring_buy_subView:tryGetServerData()
  Z.CoroUtil.create_coro_xpcall(function()
    local subTypeRow = Z.TableMgr.GetTable("StallCategoryTableMgr").GetRow(self.selectSubCategory_)
    if subTypeRow and subTypeRow.IsOver == 1 then
      local nextPage = false
      local getNewData = false
      local maxPage = self.pageIndex_
      if self.isNotice_ then
        maxPage = math.ceil(#self.tradeData_.ExchangeNoticePriceItemList[self.selectItemId_] / MAXCOUNTPERPAGE)
      else
        maxPage = math.ceil(#self.tradeData_.ExchangePriceItemList[self.selectItemId_] / MAXCOUNTPERPAGE)
      end
      if self.pageIndex_ > maxPage - 1 then
        nextPage = true
        getNewData = true
      end
      if getNewData then
        if not self.isNotice_ then
          self.tradeVm_:AsyncExchangeItem(self.selectItemId_, self.filter_, nextPage, self.cancelSource:CreateToken())
        else
          self.tradeVm_:AsyncExchangeNoticeDetail(self.selectItemId_, self.filter_, nextPage, self.cancelSource:CreateToken())
          self.tradeVm_:ExchangeNoticePreBuy(self.cancelSource:CreateToken())
        end
      end
      self:refreshSellCommodityLoop(self.selectItemId_)
    else
      self:refreshSellCommodityLoop(self.selectItemId_)
    end
  end)()
end

function Trading_ring_buy_subView:forceGetServerData(isSetMaxNum)
  Z.CoroUtil.create_coro_xpcall(function()
    local nextPage = false
    self.pageIndex_ = 1
    if not self.isNotice_ then
      self.tradeVm_:AsyncExchangeItem(self.selectItemId_, self.filter_, nextPage, self.cancelSource:CreateToken())
    else
      self.tradeVm_:AsyncExchangeNoticeDetail(self.selectItemId_, self.filter_, nextPage, self.cancelSource:CreateToken())
      self.tradeVm_:ExchangeNoticePreBuy(self.cancelSource:CreateToken())
    end
    if isSetMaxNum then
      local subTypeRow = Z.TableMgr.GetTable("StallCategoryTableMgr").GetRow(self.selectSubCategory_)
      local maxNum = 0
      if not self.isNotice_ then
        maxNum = self.tradeData_.ExchangeItemDict[self.selectItemId_].num
        if subTypeRow and subTypeRow.IsOver == 0 then
          maxNum = #self.tradeData_.ExchangePriceItemList[self.selectItemId_]
        end
      else
        maxNum = self.tradeData_.ExchangeNoticeItemDict[self.selectItemId_].num
        if subTypeRow and subTypeRow.IsOver == 0 then
          maxNum = #self.tradeData_.ExchangeNoticePriceItemList[self.selectItemId_]
        end
      end
      self.tradeData_:SetCurTradeNum(maxNum)
    end
    self:refreshSellCommodityLoop(self.selectItemId_)
  end)()
end

function Trading_ring_buy_subView:OnPurchaseSelect(exchangePriceItemData)
  self.selectExchangeItemData_ = exchangePriceItemData
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.node_right, true)
  self:refreshPurchaseSub()
end

function Trading_ring_buy_subView:refreshPurchaseSub()
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.selectItemId_)
  if itemRow == nil then
    return
  end
  local itemSellRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
  if itemSellRow == nil then
    return
  end
  local itemTypeTableRow = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemRow.Type)
  if itemTypeTableRow then
    self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.btn_check_wardrobe, itemTypeTableRow.Package == E.BackPackItemPackageType.Equip)
  end
  self.uiBinder.node_purchase_sub.rimg_icon:SetImage(self.itemVm_.GetItemIcon(self.selectItemId_))
  local itemData_ = self.selectExchangeItemData_.itemInfo
  self:AddAsyncClick(self.uiBinder.node_purchase_sub.rimg_icon_click, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
    end
    local extraParams = {itemInfo = itemData_}
    self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.node_purchase_sub.info_root, itemData_.configId, itemData_.uuid, extraParams)
  end)
  self.uiBinder.node_purchase_sub.lab_name.text = itemRow.Name
  local itemCount = self.itemVm_.GetItemTotalCount(self.selectItemId_)
  self.uiBinder.node_purchase_sub.lab_own_num.text = string.format(Lang("SeasonShopOwn"), itemCount)
  self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value = 1
  local maxNum = self.selectExchangeItemData_.num
  if maxNum > itemSellRow.OnceLimit then
    maxNum = itemSellRow.OnceLimit
  end
  self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.maxValue = maxNum
  if maxNum == 1 then
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.minValue = 0
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.interactable = false
  else
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.minValue = 1
    self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.interactable = true
  end
  self.uiBinder.node_purchase_sub.lab_income_num.text = math.floor(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value * self.selectExchangeItemData_.price)
  self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.lab_num.text = math.floor(self.uiBinder.node_purchase_sub.binder_num_module_tpl_1.slider_temp.value)
  local costItemId = itemSellRow.Currency
  local itemInfo = Z.TableMgr.GetTable("ItemTableMgr").GetRow(costItemId)
  if itemInfo then
    local itemsVM = Z.VMMgr.GetVM("items")
    self.uiBinder.node_purchase_sub.rimg_income_icon:SetImage(itemsVM.GetItemIcon(costItemId))
  end
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.btn_shelf, not self.isNotice_)
  self.uiBinder.node_purchase_sub.Ref:SetVisible(self.uiBinder.node_purchase_sub.btn_advance, self.isNotice_)
end

function Trading_ring_buy_subView:refreshExchangeItemCd()
  local nowcd = 0
  if self.isNotice_ then
    nowcd = self.tradeData_.ExchangeNoticeRefreshClickCD
  else
    nowcd = self.tradeData_.ExchangeRefreshClickCD
  end
  self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_refreshcd, false)
  if 0 < nowcd then
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_refresh, false)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_refreshcd, true)
    self.uiBinder.node_buy_sub.lab_refresh_cd.text = nowcd
    self.uiBinder.node_buy_sub.btn_refresh.IsDisabled = true
    if self.refreshCdTimer_ then
      self.timerMgr:StopTimer(self.refreshCdTimer_)
    end
    self.refreshCdTimer_ = self.timerMgr:StartTimer(function()
      nowcd = nowcd - 1
      self.uiBinder.node_buy_sub.lab_refresh_cd.text = nowcd
      if nowcd < 0 then
        self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_refresh, true)
        self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_refreshcd, false)
        self.uiBinder.node_buy_sub.btn_refresh.IsDisabled = false
      end
    end, 1, nowcd + 1)
  else
    self.uiBinder.node_buy_sub.btn_refresh.IsDisabled = false
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.btn_refresh, true)
    self.uiBinder.node_buy_sub.Ref:SetVisible(self.uiBinder.node_buy_sub.img_refreshcd, false)
  end
end

function Trading_ring_buy_subView:onItemCompared(itemInfo, configId)
  local equipInfo = self.equipVm_.GetSamePartEquipAttr(configId)
  local totalGsState = 0
  if equipInfo and equipInfo.itemUuid ~= 0 and equipInfo.itemUuid ~= itemInfo.itemUuid then
    local putonEquipConfigId = self.itemVm_.GetItemConfigId(equipInfo.itemUuid, E.BackPackItemPackageType.Equip)
    local selectEquipGs = self.equipVm_.GetEquipGsByConfigId(itemInfo.configId)
    local curEquipGs = self.equipVm_.GetEquipGsByConfigId(putonEquipConfigId)
    if selectEquipGs > curEquipGs then
      totalGsState = 1
    elseif selectEquipGs < curEquipGs then
      totalGsState = -1
    end
    local curPutItemTipsData = {}
    curPutItemTipsData.tipsId = self.curPutOnEquipTipsId_
    curPutItemTipsData.configId = putonEquipConfigId
    curPutItemTipsData.itemUuid = equipInfo.itemUuid
    curPutItemTipsData.posType = E.EItemTipsPopType.Parent
    curPutItemTipsData.isShowBg = true
    curPutItemTipsData.parentTrans = self.uiBinder.node_purchase_sub.compare_root
    self.curPutOnEquipTipsId_ = Z.TipsVM.OpenItemTipsView(curPutItemTipsData)
  else
    Z.TipsVM.CloseItemTipsView(self.curPutOnEquipTipsId_)
    self.curPutOnEquipTipsId_ = nil
  end
  local selectItemTipsData = {}
  selectItemTipsData.tipsId = self.selectItemTipsId_
  selectItemTipsData.configId = configId
  selectItemTipsData.itemUuid = itemInfo.itemUuid
  selectItemTipsData.posType = E.EItemTipsPopType.Parent
  selectItemTipsData.isShowBg = true
  selectItemTipsData.parentTrans = self.uiBinder.node_purchase_sub.info_root
  selectItemTipsData.itemInfo = itemInfo
  selectItemTipsData.data = {GsState = totalGsState}
  self.selectItemTipsId_ = Z.TipsVM.OpenItemTipsView(selectItemTipsData)
end

function Trading_ring_buy_subView:openItemFilter()
  local filterType = {}
  if self.isBuyType_ then
    local categoryDetailRow = Z.TableMgr.GetTable("StallDetailTableMgr").GetRow(self.selectItemId_)
    if categoryDetailRow then
      filterType = categoryDetailRow.FitterId
    end
  else
    local categoryRow = Z.TableMgr.GetTable("StallCategoryTableMgr").GetRow(self.selectSubCategory_)
    if categoryRow and categoryRow.FiiterGroupID ~= 0 then
      filterType[1] = categoryRow.FiiterGroupID
    end
  end
  local viewData = {
    parentView = self,
    filterType = filterType,
    existFilterTags = self.filterTags_
  }
  self.itemFilter_:Active(viewData, self.uiBinder.filter_root)
end

function Trading_ring_buy_subView:selectedFilterTags(filterTgas)
  if table.zcount(filterTgas) < 1 then
    self.filter_ = {}
    self.filterTags_ = {}
    self.filterFuncs_ = {}
    self.filterParams_ = {}
  end
  for type, value in pairs(filterTgas) do
    for index, _ in pairs(value) do
      local filter = {}
      filter.type = type
      filter.value = index
      table.insert(self.filter_, filter)
    end
  end
  self.filterTags_ = filterTgas
  if self.isBuyType_ then
    self.pageIndex_ = 1
    self:forceGetServerData()
  else
    self:refreshListLoopByFilter(filterTgas)
  end
end

function Trading_ring_buy_subView:refreshListLoopByFilter(filterTgas)
  local item_filter_factory = Z.VMMgr.GetVM("item_filter_factory")
  if filterTgas and table.zcount(filterTgas) > 0 then
    local filterTypes = {}
    local filterParams = {}
    for filterType, value in ipairs(filterTgas) do
      table.insert(filterTypes, filterType)
      for filterParam, _ in pairs(value) do
        if filterParams[filterType] == nil then
          filterParams[filterType] = {}
        end
        table.insert(filterParams[filterType], filterParam)
      end
    end
    local filterFuncs = item_filter_factory.GetItemFilterFunc(filterTypes)
    self.filterFuncs_ = filterFuncs
    self.filterParams_ = filterParams
    self:refreshSellItemLoop(filterFuncs, filterParams)
  else
    self:refreshSellItemLoop()
  end
end

function Trading_ring_buy_subView:OnDeActive()
  if self.purchaseLoop_ then
    self.purchaseLoop_:UnInit()
    self.purchaseLoop_ = nil
  end
  if self.sellItemLoop_ then
    self.sellItemLoop_:UnInit()
    self.sellItemLoop_ = nil
  end
  if self.searchLoop_ then
    self.searchLoop_:UnInit()
    self.searchLoop_ = nil
  end
  if self.refreshCdTimer_ then
    self.timerMgr:StopTimer(self.refreshCdTimer_)
  end
  for _, value in ipairs(self.itemClass_) do
    value:UnInit()
  end
  for _, value in pairs(self.itemSellTimer_) do
    self.timerMgr:StopTimer(value)
  end
  self.itemSellTimer_ = {}
  self.itemClass_ = {}
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  self.keypad_ = nil
  if self.itemFilter_ then
    self.filterTags_ = {}
    self.itemFilter_:DeActive()
  end
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
  end
  if self.curPutOnEquipTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.curPutOnEquipTipsId_)
    self.curPutOnEquipTipsId_ = nil
  end
  if self.selectItemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.selectItemTipsId_)
    self.selectItemTipsId_ = nil
  end
  self.itemFilter_ = nil
end

function Trading_ring_buy_subView:OnRefresh()
end

return Trading_ring_buy_subView
