local super = require("ui.component.loop_grid_view_item")
local SeasonShopLoopItem = class("SeasonShopLoopItem", super)
local propState = {
  none = 0,
  time = 1,
  count = 2,
  level = 3,
  have = 4,
  lock = 5,
  condition = 6,
  conditionShowPrice = 7
}
local labelEnum = {
  none = 0,
  discount = 1,
  cfg = 2
}
local bgImgStr_ = "ui/atlas/season/seasonshop_item_quality_%d"

function SeasonShopLoopItem:ctor()
  self.fashionVM = Z.VMMgr.GetVM("fashion")
  self.shopData = Z.DataMgr.Get("shop_data")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
  self.shopVM_ = Z.VMMgr.GetVM("shop")
end

function SeasonShopLoopItem:initZWidget()
  self.curTimerId_ = 0
  self.initTag_ = true
  self.quality_img_ = self.uiBinder.img_quality_bg
  self.quality_btn_ = self.uiBinder.btn_quality_bg
  self.name_label_ = self.uiBinder.lab_item_name
  self.new_tag_ = self.uiBinder.img_new
  self.icon_ = self.uiBinder.rimg_item_icon
  self.time_lock_ = self.uiBinder.img_time_bg
  self.time_lock_label_ = self.uiBinder.lab_time
  self.price_icon_ = self.uiBinder.rimg_price_icon
  self.price_old_ = self.uiBinder.lab_old_price
  self.price_new_ = self.uiBinder.lab_price_num
  self.buy_state_root_ = self.uiBinder.img_buy_state_bg
  self.buy_state_label_ = self.uiBinder.lab_lock
  self.discount_ = self.uiBinder.img_discount_bg
  self.discount_label_ = self.uiBinder.lab_discount_num
  self.price_root_ = self.uiBinder.node_price_bg
  self.limit_tab_ = {
    self.uiBinder.lab_week,
    self.uiBinder.lab_day
  }
  self.limit_img_ = {
    self.uiBinder.img_week_bg,
    self.uiBinder.img_day_bg
  }
  self.lastRedId_ = nil
  self.qualityAnim_ = {
    [E.ItemQuality.Yellow] = self.uiBinder.anim_quality
  }
end

function SeasonShopLoopItem:OnInit()
  self:initZWidget()
  self.quality_btn_:AddListener(function()
    if self.parent.UIView.IsFashionShop then
      self.parent.UIView:SetSelected(self.data_, self.Index)
    else
      self:onSelectNormalShopItem()
    end
  end)
end

function SeasonShopLoopItem:onSelectNormalShopItem()
  if self.curPropState == propState.count then
    Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1000720})
    return
  end
  if self.curPropState == propState.level then
    Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1000725})
    return
  end
  if self.curPropState == propState.have then
    Z.TipsVM.ShowTips(1000748)
    return
  end
  if self.curPropState == propState.lock then
    if self.curLockTipId then
      Z.TipsVM.ShowTips(self.curLockTipId)
    end
    return
  end
  self.parent.UIView:OpenBuyPopup(self:GetCurData(), self.Index)
end

function SeasonShopLoopItem:OnRefresh(data)
  self.data_ = data
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
  if data == nil then
    return
  end
  local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
  if mallItemCfgData then
    local mallCfgData = self.shopData.MallTableDatas[mallItemCfgData.FunctionId]
    if mallCfgData then
      if mallCfgData.ShowType == E.EShopType.SeasonShop then
        self.lastRedId_ = string.zconcat(E.RedType.SeasonShop, E.RedType.SeasonShopOneTab, mallCfgData.Id, E.RedType.SeasonShopItem, data.itemId)
      elseif mallCfgData.HasFatherType == 0 then
        self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, mallCfgData.Id, E.RedType.ShopItem, data.itemId)
      else
        self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopTwoTab, mallCfgData.Id, E.RedType.ShopItem, data.itemId)
      end
    end
  end
  if self.lastRedId_ then
    Z.CoroUtil.create_coro_xpcall(function()
      Z.RedPointMgr.LoadRedDotItem(self.lastRedId_, self.parent.UIView, self.price_root_)
    end)()
  end
  self:showItem(data.cfg)
  self:showCost(data.cfg)
  self.curPropState = propState.none
  self:showCountLimit(data)
  self:showTimeLimit(data)
  self:showLevelLimit(data)
  self:showBuyState(data.cfg)
  self:refreshLockState(data.cfg)
  self:showPropState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.parent.UIView.IsFashionShop and self.IsSelected)
end

function SeasonShopLoopItem:OnSelected(isSelected)
  if isSelected then
    if self.parent.UIView.IsFashionShop then
      self.parent.UIView:OpenBuyPopup(self:GetCurData(), self.Index, self.curPropState)
    else
      self:onSelectNormalShopItem()
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.parent.UIView.IsFashionShop and isSelected)
end

function SeasonShopLoopItem:OnUnInit()
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
  self:clearTimerCall()
end

function SeasonShopLoopItem:OnRecycle()
  self:clearTimerCall()
end

function SeasonShopLoopItem:showItem(cfg)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(cfg.ItemId)
  if itemCfg then
    if cfg.Quantity > 1 then
      local param = {}
      param.val = cfg.Quantity
      self.name_label_.text = string.zconcat(itemCfg.Name, " ", Lang("x", param))
    else
      self.name_label_.text = itemCfg.Name
    end
    local itemsVM = Z.VMMgr.GetVM("items")
    self.icon_:SetImage(itemsVM.GetItemIcon(cfg.ItemId))
    self.quality_img_:SetImage(string.format(bgImgStr_, itemCfg.Quality))
    self:onStartAnimShow(itemCfg.Quality)
  end
end

function SeasonShopLoopItem:showCost(cfg)
  local cost = 0
  for id, num in pairs(cfg.Cost) do
    self.currencyId_ = id
    cost = num
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id)
    if itemcfg then
      local itemsVM = Z.VMMgr.GetVM("items")
      self.price_icon_:SetImage(itemsVM.GetItemIcon(id))
    end
    break
  end
  self.uiBinder.Ref:SetVisible(self.price_old_, false)
  for id, num in pairs(cfg.OriginalPrice) do
    if id ~= 0 then
      self.uiBinder.Ref:SetVisible(self.price_old_, true)
      self.price_old_.text = Z.NumTools.FormatNumberWithCommas(num)
      break
    end
  end
  local showPrice = cost
  if self.parent.UIView.IsFashionShop then
    showPrice = self.shopVM_.GetShopMallItemPrice(cfg)
  end
  if showPrice == 0 then
    self.price_new_.text = Lang("Free")
  else
    self.price_new_.text = Z.NumTools.FormatNumberWithCommas(showPrice)
  end
  self:showTag(cfg, cost)
end

function SeasonShopLoopItem:showTag(cfg, cost)
  local label = cfg.Label
  if #label <= 0 then
    self.uiBinder.Ref:SetVisible(self.discount_, false)
  else
    local lab = tonumber(label[1])
    if lab == labelEnum.none then
      self.uiBinder.Ref:SetVisible(self.discount_, false)
    elseif lab == labelEnum.discount then
      if not cfg.OriginalPrice or 0 >= table.zcount(cfg.OriginalPrice) then
        self.uiBinder.Ref:SetVisible(self.discount_, false)
      elseif cfg.OriginalPrice[self.currencyId_] then
        self.uiBinder.Ref:SetVisible(self.discount_, true)
        self.discount_label_.text = string.format("%d%%", -math.floor((cfg.OriginalPrice[self.currencyId_] - cost) / cfg.OriginalPrice[self.currencyId_] * 100))
      else
        self.uiBinder.Ref:SetVisible(self.discount_, false)
      end
    elseif lab == labelEnum.cfg then
      self.uiBinder.Ref:SetVisible(self.discount_, true)
      self.discount_label_.text = Lang(label[2])
    end
  end
  self.uiBinder.Ref:SetVisible(self.new_tag_, false)
end

function SeasonShopLoopItem:showCountLimit(data)
  for i = 1, #self.limit_img_ do
    self.uiBinder.Ref:SetVisible(self.limit_img_[i], false)
  end
  if table.zcount(data.buyCount) == 0 then
    return
  else
    local num, index = 0, 1
    local countTab = {}
    for id, _ in pairs(data.buyCount) do
      if id ~= E.ESeasonShopRefreshType.None then
        countTab[#countTab + 1] = id
      end
    end
    table.sort(countTab, function(a, b)
      return a < b
    end)
    local id = 0
    local index = 1
    local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(data.cfg.ItemId)
    if data.limitBuyType == 1 then
      id = countTab[1]
      local count = data.buyCount[id]
      num = count.canBuyCount
      local limit_Tab_ = self.limit_tab_[index]
      local limit_Img_ = self.limit_img_[index]
      self.uiBinder.Ref:SetVisible(limit_Img_, true)
      self.uiBinder.img_week_bg:SetColor(self.shopData.ShopQualityLab[itemCfg.Quality])
      limit_Tab_.text = Lang("SeasonShopCanBuyCountTitle") .. count.canBuyCount .. "/" .. count.purchasedCount + count.canBuyCount
      if self.curPropState == propState.none and num <= 0 then
        self.curPropState = propState.count
      end
      index = index + 1
      limit_Tab_ = self.limit_tab_[index]
      limit_Img_ = self.limit_img_[index]
      local str_ = ""
      if id == E.ESeasonShopRefreshType.Daily then
        str_ = Lang("SeasonShopDayTitle")
      elseif id == E.ESeasonShopRefreshType.Week then
        str_ = Lang("SeasonShopWeekTitle")
      end
      self.uiBinder.Ref:SetVisible(limit_Img_, true)
      limit_Tab_.text = str_ .. count.maxBuyCount
    else
      local length = #countTab
      for i = 1, length do
        index = i
        local str_ = ""
        local count = data.buyCount[countTab[i]]
        num = count.maxBuyCount - count.canBuyCount
        local limit_Tab_ = self.limit_tab_[index]
        local limit_Img_ = self.limit_img_[index]
        self.uiBinder.img_week_bg:SetColor(self.shopData.ShopQualityLab[itemCfg.Quality])
        if countTab[i] == E.ESeasonShopRefreshType.Daily then
          str_ = Lang("SeasonShopDayTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == E.ESeasonShopRefreshType.Week then
          str_ = Lang("SeasonShopWeekTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == E.ESeasonShopRefreshType.Month then
          str_ = Lang("SeasonShopMonthTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == E.ESeasonShopRefreshType.Season then
          num = count.purchasedCount
          if data.shopType == 0 then
            str_ = Lang("ShopSeasonLimitTitle")
          else
            str_ = Lang("SeasonShopSeasonLimitTitle")
          end
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == E.ESeasonShopRefreshType.Compensate or countTab[i] == E.ESeasonShopRefreshType.Permanent then
          str_ = Lang("ShopSeasonLimitTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        end
        self.uiBinder.Ref:SetVisible(limit_Img_, true)
        limit_Tab_.text = str_ .. count.canBuyCount .. "/" .. count.maxBuyCount
        index = index + 1
      end
    end
  end
end

function SeasonShopLoopItem:showTimeLimit(data)
  if data.startTime == 0 then
    self.uiBinder.Ref:SetVisible(self.time_lock_, false)
  else
    local t = Z.TimeTools.Now() * 0.001
    local checkTime = 0
    if t < self.data_.startTime then
      self.rigestTimerCall_ = true
      checkTime = self.data_.startTime
      if self.curPropState == propState.none then
        self.curPropState = propState.time
      end
    elseif t < self.data_.endTime then
      self.rigestTimerCall_ = true
      checkTime = self.data_.endTime
    else
      self.rigestTimerCall_ = false
    end
    if self.rigestTimerCall_ then
      self.uiBinder.Ref:SetVisible(self.time_lock_, true)
      self.curTime_ = math.floor(checkTime - t)
      self.parent.UIView:RigestTimerCall(self.data_.itemId, function()
        self:updateTime()
      end)
      self:updateTime()
    else
      self.uiBinder.Ref:SetVisible(self.time_lock_, false)
    end
  end
end

function SeasonShopLoopItem:showLevelLimit(data)
  local levelLimit = data.cfg.ShowLimitType
  if not levelLimit[1] or not levelLimit[1][2] then
    return
  end
  local bool = Z.ConditionHelper.CheckCondition(levelLimit)
  if bool == false then
    self.notLevel_ = levelLimit[1][2]
    self.curPropState = propState.level
  end
end

function SeasonShopLoopItem:showBuyState(cfg)
  if self.parent.UIView.IsFashionShop then
    local have = false
    if cfg.GoodsType == E.EShopGoodsType.EFashion then
      if cfg.GoodsGroup and #cfg.GoodsGroup > 0 then
        for i = 1, #cfg.GoodsGroup do
          local mallRow = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(cfg.GoodsGroup[i], true)
          if mallRow and self.shopVM.CheckUnlockCondition(mallRow.UnlockConditions) then
            have = self.fashionVM.GetFashionIsUnlock(mallRow.ItemId)
            if not have then
              break
            end
          end
        end
      else
        have = self.fashionVM.GetFashionIsUnlock(cfg.ItemId)
      end
    elseif cfg.GoodsType == E.EShopGoodsType.EMount then
      have = 0 < self.itemsVM_.GetItemTotalCount(cfg.ItemId)
    end
    if have then
      self.curPropState = propState.have
    end
  else
    local itemTableCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(cfg.ItemId)
    if not itemTableCfgData then
      return
    end
    local itemTypeTableCfgData = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemTableCfgData.Type)
    if not itemTypeTableCfgData then
      return
    end
    if not itemTypeTableCfgData.UpperLlimit or 0 >= itemTypeTableCfgData.UpperLlimit then
      return
    end
    local itemsVm = Z.VMMgr.GetVM("items")
    local count = itemsVm.GetItemTotalCount(cfg.ItemId)
    if count >= itemTypeTableCfgData.UpperLlimit then
      self.curPropState = propState.have
    end
  end
end

function SeasonShopLoopItem:updateTime()
  self.curTime_ = self.curTime_ - 1
  if self.curTime_ <= 0 then
    self.parent.UIView:UpdateProp()
  else
    self.time_lock_label_.text = Z.TimeFormatTools.FormatToDHMS(self.curTime_)
    if self.curPropState == propState.time then
      self.buy_state_label_.text = self.time_lock_label_.text
    end
  end
end

function SeasonShopLoopItem:refreshLockState(cfg)
  local check = Z.ConditionHelper.CheckCondition(cfg.UnlockConditions)
  if check == false then
    local desc, showLock, lockTipId, conditionLimit
    local r = Z.ConditionHelper.GetConditionDescList(cfg.UnlockConditions)
    for _, value in ipairs(r) do
      if value.IsUnlock == false then
        if value.showLock then
          desc = value.showPurview
        else
          desc = value.Desc
        end
        showLock = value.showLock
        lockTipId = value.tipsId
        conditionLimit = true
        break
      end
    end
    if showLock then
      self.curPropState = propState.lock
      self.buy_state_label_.text = desc
      self.uiBinder.lab_unlock_conditions.text = ""
      self.curLockTipId = lockTipId
    else
      self.curPropState = propState.condition
      self.uiBinder.lab_unlock_conditions.text = desc
    end
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlock_conditions, false)
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_condition_no_bg, conditionLimit)
    self.uiBinder.canvas_bg.alpha = conditionLimit and 0.3 or 1
    if conditionLimit and not cfg.NotPurchaseConditionsIsShow then
      self.curPropState = propState.conditionShowPrice
    end
    return
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_condition_no_bg, false)
    self.uiBinder.canvas_bg.alpha = 1
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlock_conditions, false)
end

function SeasonShopLoopItem:showPropState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_lock, true)
  if self.curPropState == propState.none or self.curPropState == propState.conditionShowPrice then
    self.uiBinder.Ref:SetVisible(self.buy_state_root_, false)
    self.uiBinder.Ref:SetVisible(self.price_root_, true)
  elseif self.curPropState == propState.lock then
    self.uiBinder.Ref:SetVisible(self.buy_state_root_, false)
    self.uiBinder.Ref:SetVisible(self.price_root_, false)
  else
    self.uiBinder.Ref:SetVisible(self.buy_state_root_, true)
    self.uiBinder.Ref:SetVisible(self.price_root_, false)
    if self.curPropState == propState.time then
      self.buy_state_label_.text = self.time_lock_label_.text
    elseif self.curPropState == propState.level then
      self.buy_state_label_.text = string.format(Lang("ShowLimitLevel"), self.notLevel_)
    elseif self.curPropState == propState.count then
      self.buy_state_label_.text = Lang("SeasonShopSellDone")
    elseif self.curPropState == propState.have then
      self.buy_state_label_.text = Lang("SeasonShopSellLimit")
    elseif self.curPropState == propState.condition then
      self.buy_state_label_.text = ""
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_lock, false)
    end
  end
end

function SeasonShopLoopItem:onStartAnimShow(quality)
  for index, anim in pairs(self.qualityAnim_) do
    self.uiBinder.Ref:SetVisible(anim, quality == index)
    anim:Stop()
    if index == quality then
      anim:PlayLoop("anim_item_shop_light_tpl")
    end
  end
end

function SeasonShopLoopItem:clearTimerCall()
  if self.rigestTimerCall_ then
    self.parent.UIView:UnrigestTimerCall(self.data_.itemId)
    self.rigestTimerCall_ = false
  end
end

return SeasonShopLoopItem
