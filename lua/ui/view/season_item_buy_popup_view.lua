local UI = Z.UI
local super = require("ui.ui_view_base")
local Season_item_buy_popupView = class("Season_item_buy_popupView", super)
local loopListView = require("ui/component/loop_list_view")
local awardPopupLoopItem = require("ui/component/season/season_buy_popup_loop_item")
local iClass = require("common.item")
local numMod = require("ui.view.cont_num_module_tpl_view")

function Season_item_buy_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "season_item_buy_popup")
  self.vm = Z.VMMgr.GetVM("season_shop")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
  self.awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.cookVm_ = Z.VMMgr.GetVM("cook")
  self.numMod_ = numMod.new(self, "black")
end

function Season_item_buy_popupView:OnActive()
  self:initwidgets()
  self.sceneMask_:SetSceneMaskByKey(self.SceneMaskKey)
  if self.viewData and self.viewData.currencyArray then
    self.currencyVm_.OpenCurrencyView(self.viewData.currencyArray, self.uiBinder.Trans, self)
  end
  self:AddClick(self.cancelBnt_, function()
    Z.UIMgr:CloseView("season_item_buy_popup")
  end)
  self:AddClick(self.closeBtn_, function()
    Z.UIMgr:CloseView("season_item_buy_popup")
  end)
  self:AddAsyncClick(self.buyBtn_, function()
    if self.viewData.data and self.viewData.data.cfg and self.viewData.data.cfg.UnlockConditions and #self.viewData.data.cfg.UnlockConditions > 0 then
      local isUnLock = Z.ConditionHelper.CheckCondition(self.viewData.data.cfg.UnlockConditions, true)
      if not isUnLock then
        return
      end
    end
    if self.curNum_ > self.realMaxNum then
      self.currencyVm_.OpenExChangeCurrencyView(self.moneyId_, false)
      Z.UIMgr:CloseView("season_item_buy_popup")
      local costItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.moneyId_)
      if costItemRow then
        Z.TipsVM.ShowTips(100010, {
          item = {
            name = costItemRow.Name
          }
        })
      else
        Z.TipsVM.ShowTips(4801)
      end
      return
    end
    if self.curNum_ >= Z.Global.BuyMaxTips then
      local costItemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.moneyId_)
      local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.data.cfg.ItemId)
      if costItemRow == nil or itemRow == nil then
        return
      end
      local itemName = Z.RichTextHelper.ApplyStyleTag(itemRow.Name, "ItemQuality_" .. itemRow.Quality)
      local costItemName = Z.RichTextHelper.ApplyStyleTag(costItemRow.Name, "ItemQuality_" .. costItemRow.Quality)
      Z.DialogViewDataMgr:OpenNormalDialog(string.format(Lang("BuyItemMaxTip"), costItemName, math.floor(self.curNum_ * self.price_single_), itemName, math.floor(self.curNum_)), function()
        self.viewData.buyFunc(self.viewData.data, self.curNum_)
        Z.DialogViewDataMgr:CloseDialogView()
      end)
      return
    end
    self.viewData.buyFunc(self.viewData.data, self.curNum_)
  end)
  self:AddClick(self.iconBtn_, function()
    if self.tipsId_ then
      Z.TipsVM.CloseItemTipsView(self.tipsId_)
      self.tipsId_ = nil
    end
    local itemData = {}
    itemData.configId = self.viewData.data.cfg.ItemId
    itemData.parentTrans = self.iconBtn_.transform
    itemData.posType = E.EItemTipsPopType.Bounds
    itemData.isShowBg = true
    self.tipsId_ = Z.TipsVM.OpenItemTipsView(itemData)
  end)
  self.canBuyCount_ = 9999999
  self:show()
  if self.numMod_ then
    self.numMod_:Active({
      itemId = self.viewData.data.cfg.ItemId,
      tipId = 1000734,
      cost = {
        moneyId = self.moneyId_,
        price_single = self.price_single_
      }
    }, self.numModRootTrans_)
    local has = self.itemsVm_.GetItemTotalCount(self.moneyId_)
    self.numMod_:ReSetValue(self.minNum_, self.canBuyCount_, Mathf.Floor(has / self.price_single_), function(num)
      local hasCount = self.itemsVm_.GetItemTotalCount(self.moneyId_)
      local price = math.floor(num * self.price_single_)
      local str = ""
      if hasCount < price then
        price = Z.NumTools.FormatNumberWithCommas(price)
        str = Z.RichTextHelper.ApplyStyleTag(price, E.TextStyleTag.Lab_num_red)
      else
        price = Z.NumTools.FormatNumberWithCommas(price)
        str = Z.RichTextHelper.ApplyStyleTag(price, E.TextStyleTag.Lab_num_black)
      end
      self.lab_total_price_num_.text = str
      self.curNum_ = num
    end)
  end
  self:setPreview()
end

function Season_item_buy_popupView:OnRefresh()
end

function Season_item_buy_popupView:initwidgets()
  self.cont_base_popup = self.uiBinder.cont_base_popup
  self.img_quality_ = self.cont_base_popup.img_name_quality
  self.rimg_icon_ = self.cont_base_popup.rimg_icon
  self.iconBtn_ = self.cont_base_popup.btn_icon
  self.lab_name_ = self.cont_base_popup.lab_item_name
  self.lab_current_ = self.cont_base_popup.lab_current
  self.node_day_ = self.cont_base_popup.node_day
  self.lab_day_ = self.cont_base_popup.lab_day
  self.numModRootTrans_ = self.cont_base_popup.num_group
  self.lab_unit_price_num_ = self.cont_base_popup.lab_unit_price_num
  self.lab_total_price_num_ = self.cont_base_popup.lab_total_price_num
  self.currency_icon1_ = self.cont_base_popup.rimg_unit_icon
  self.currency_icon2_ = self.cont_base_popup.rimg_total_icon
  self.sceneMask_ = self.cont_base_popup.scenemask
  self.closeBtn_ = self.cont_base_popup.closeBtn
  self.node_item_show_ = self.cont_base_popup.node_item_show
  self.loopitem_ = self.cont_base_popup.loopitem
  self.btn_check_ = self.cont_base_popup.btn_check
  self.labInfo_ = self.cont_base_popup.lab_info_prompt
  self.labInfo2_ = self.cont_base_popup.lab_info_prompt2
  self.buyBtn_ = self.cont_base_popup.btn_yes
  self.cancelBnt_ = self.cont_base_popup.btn_no
end

function Season_item_buy_popupView:getCanBuyCount(prop)
  local limit_Label_ = self.lab_day_
  self.cont_base_popup.Ref:SetVisible(self.node_day_, false)
  for id, count in pairs(prop.buyCount) do
    if id == self.vm.SeasonShopRefreshType.daily then
      self.cont_base_popup.Ref:SetVisible(self.node_day_, true)
      self.canBuyCount_ = count.canBuyCount
      if prop.limitBuyType == 1 then
        limit_Label_.text = string.format(Lang("SeasonShopCanBuyCount"), count.canBuyCount, count.canBuyCount + count.purchasedCount)
        break
      end
      limit_Label_.text = string.format(Lang("SeasonShopDayLimit"), count.canBuyCount, count.canBuyCount + count.purchasedCount)
      break
    elseif id == self.vm.SeasonShopRefreshType.week then
      self.cont_base_popup.Ref:SetVisible(limit_Label_, true)
      self.canBuyCount_ = count.canBuyCount
      if prop.limitBuyType == 1 then
        limit_Label_.text = string.format(Lang("SeasonShopCanBuyCount"), count.canBuyCount, count.canBuyCount + count.purchasedCount)
      else
        limit_Label_.text = string.format(Lang("SeasonShopWeekLimit"), count.canBuyCount, count.canBuyCount + count.purchasedCount)
      end
    elseif id == self.vm.SeasonShopRefreshType.season then
      self.cont_base_popup.Ref:SetVisible(limit_Label_, true)
      self.canBuyCount_ = count.canBuyCount
      if prop.shopType == 0 then
        limit_Label_.text = string.format(Lang("ShopSeasonLimit"), count.canBuyCount, count.maxBuyCount)
      else
        limit_Label_.text = string.format(Lang("SeasonShopSeasonLimit"), count.canBuyCount, count.canBuyCount + count.purchasedCount)
      end
    elseif id == self.vm.SeasonShopRefreshType.month then
      self.cont_base_popup.Ref:SetVisible(limit_Label_, true)
      limit_Label_.text = string.zconcat(count.canBuyCount, "/", count.canBuyCount + count.purchasedCount)
      self.canBuyCount_ = count.canBuyCount
    end
  end
end

function Season_item_buy_popupView:show()
  local prop = self.viewData.data
  self:getCanBuyCount(prop)
  self:calculateNum(prop)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(prop.cfg.ItemId)
  if not itemCfg then
    return
  end
  if prop.cfg.Quantity > 1 then
    local param = {}
    param.val = prop.cfg.Quantity
    self.lab_name_.text = string.zconcat(itemCfg.Name, " ", Lang("x", param))
  else
    self.lab_name_.text = itemCfg.Name
  end
  local buffDes = self.cookVm_.GetBuffDesById(prop.cfg.ItemId)
  if buffDes == "" then
    self.labInfo_.text = itemCfg.Description
  else
    Z.RichTextHelper.SetTmpLabTextWithCommonLinkNew(self.labInfo_, string.zconcat(itemCfg.Description, "\n", buffDes))
  end
  self.labInfo2_.text = itemCfg.Description2
  self.lab_current_.text = string.format(Lang("SeasonShopOwn"), self.itemsVm_.GetItemTotalCount(prop.cfg.ItemId))
  if self.itemClass_ == nil then
    self.itemClass_ = iClass.new(self)
  end
  self.rimg_icon_:SetImage(self.itemsVm_.GetItemIcon(prop.cfg.ItemId))
  self.img_quality_:SetImage(Z.ConstValue.Item.ItemQualityBackGroundImage .. itemCfg.Quality)
  local itemfunctionCfg = Z.TableMgr.GetTable("ItemFunctionTableMgr").GetRow(prop.cfg.ItemId, true)
  if not itemfunctionCfg then
    self.cont_base_popup.Ref:SetVisible(self.node_item_show_, false)
    self.cont_base_popup.Ref:SetVisible(self.btn_check_, false)
    return
  end
  if itemfunctionCfg.Type ~= 2 then
    self.cont_base_popup.Ref:SetVisible(self.node_item_show_, false)
    self.cont_base_popup.Ref:SetVisible(self.btn_check_, false)
    return
  end
  self.cont_base_popup.Ref:SetVisible(self.node_item_show_, true)
  self.cont_base_popup.Ref:SetVisible(self.btn_check_, true)
  self.awardList_ = self.awardPreviewVm.GetAllAwardPreListByIds(tonumber(itemfunctionCfg.Parameter[1]))
  self:AddClick(self.btn_check_, function()
    local definitelyList = self.awardPreviewVm.GetAllAwardPreListByIds(tonumber(itemfunctionCfg.Parameter[1]))
    self.awardPreviewVm.OpenRewardDetailViewByListData(definitelyList)
  end)
  self.awardLoopScroll_ = loopListView.new(self, self.loopitem_, awardPopupLoopItem, "com_item_square_8")
  self.awardLoopScroll_:Init(self.awardList_)
end

function Season_item_buy_popupView:calculateNum(prop)
  local cost = prop.cfg.Cost
  self.minNum_ = 1
  self.curNum_ = 1
  self.maxNum_ = 0
  self.moneyId_ = 0
  local GetItemTotalCount = self.itemsVm_.GetItemTotalCount
  for id, num in pairs(cost) do
    local itemNum = GetItemTotalCount(id)
    self.moneyId_ = id
    if num == 0 then
      self.maxNum_ = self.canBuyCount_
      self.price_single_ = num
    else
      itemNum = math.floor(itemNum / num)
      if self.maxNum_ == 0 or itemNum < self.maxNum_ then
        self.maxNum_ = itemNum
        self.price_single_ = num
      end
    end
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      local itemsVM = Z.VMMgr.GetVM("items")
      self.currency_icon1_:SetImage(itemcfg.Icon)
      self.currency_icon2_:SetImage(itemcfg.Icon)
    end
  end
  for id, count in pairs(prop.buyCount) do
    if id ~= self.vm.SeasonShopRefreshType.none and self.maxNum_ > count.canBuyCount then
      self.maxNum_ = count.canBuyCount
    end
  end
  local showOriginal = false
  for id, num in pairs(prop.cfg.OriginalPrice) do
    if id ~= 0 then
      self.uiBinder.cont_base_popup.lab_unit_original_num.text = string.zconcat("<s>", Z.NumTools.FormatNumberWithCommas(num), "</s>")
      showOriginal = true
    end
    break
  end
  self.realMaxNum = self.maxNum_
  if self.maxNum_ < self.minNum_ then
    self.maxNum_ = self.minNum_
  end
  if showOriginal then
    self.lab_unit_price_num_.text = Z.NumTools.FormatNumberWithCommas(self.price_single_)
  else
    self.uiBinder.cont_base_popup.lab_unit_original_num.text = Z.NumTools.FormatNumberWithCommas(self.price_single_)
    self.lab_unit_price_num_.text = ""
  end
end

function Season_item_buy_popupView:GetAwardItemData(index)
  return self.awardList_[index]
end

function Season_item_buy_popupView:OnDeActive()
  if self.awardLoopScroll_ then
    self.awardLoopScroll_:ClearAllSelect()
    self.awardLoopScroll_:UnInit()
    self.awardLoopScroll_ = nil
  end
  self.currencyVm_.CloseCurrencyView(self)
  if self.numMod_ then
    self.numMod_:DeActive()
  end
  Z.CommonTipsVM.CloseRichText()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

function Season_item_buy_popupView:GetPrefabCacheData(key)
  if self.uiBinder.prefabcache_root == nil then
    return nil
  end
  self.uiBinder.prefabcache_root:GetString(key)
end

function Season_item_buy_popupView:onStartAnimShow()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function Season_item_buy_popupView:setPreview()
  local isShowPreview = false
  local fashionVm = Z.VMMgr.GetVM("fashion")
  if fashionVm.CheckIsFashion(self.viewData.data.cfg.ItemId) then
    isShowPreview = true
    self:AddClick(self.uiBinder.cont_base_popup.btn_preview, function()
      fashionVm.GotoFashionView(self.viewData.data.cfg.ItemId)
    end)
  end
  self.uiBinder.cont_base_popup.Ref:SetVisible(self.uiBinder.cont_base_popup.btn_preview, isShowPreview)
end

return Season_item_buy_popupView
