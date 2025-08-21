local SeasonShopItemTplHelper = class("SeasonShopItemTplHelper")
local propState = {
  none = 0,
  time = 1,
  count = 2,
  level = 3,
  have = 4,
  lock = 5
}
local labelEnum = {
  none = 0,
  discount = 1,
  cfg = 2
}
local qualityAnim = {
  [5] = Z.DOTweenAnimType.Open,
  [4] = Z.DOTweenAnimType.Tween_1,
  [3] = Z.DOTweenAnimType.Tween_2
}
local bgImgStr_ = "ui/atlas/season/seasonshop_item_quality_%d"

function SeasonShopItemTplHelper:ctor(uibinder)
  self.uiBinder = uibinder
  self:initZWidget()
  self.fashionVM = Z.VMMgr.GetVM("fashion")
  self.shopData = Z.DataMgr.Get("shop_data")
  self.shopVM_ = Z.VMMgr.GetVM("shop")
end

function SeasonShopItemTplHelper:initZWidget()
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
end

function SeasonShopItemTplHelper:Refresh(data)
  self.data_ = data
  if data == nil then
    return
  end
  self:showItem(data.cfg)
  self:showCost(data.cfg)
  self:showCountLimit(data)
  self:showTimeLimit(data)
  self:showLevelLimit(data)
  self:showBuyState(data.cfg)
  self:refreshLockState(data.cfg)
  self:showPropState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function SeasonShopItemTplHelper:showItem(cfg)
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

function SeasonShopItemTplHelper:showCost(cfg)
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
  local showPrice = self.shopVM_.GetShopMallItemPrice(cfg)
  if showPrice == 0 then
    self.price_new_.text = Lang("Free")
  else
    self.price_new_.text = Z.NumTools.FormatNumberWithCommas(showPrice)
  end
  self:showTag(cfg, cost)
end

function SeasonShopItemTplHelper:showTag(cfg, cost)
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
        self.discount_label_.text = string.format("%d%%", math.floor(cost / cfg.OriginalPrice[self.currencyId_] * 100))
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

function SeasonShopItemTplHelper:showCountLimit(data)
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

function SeasonShopItemTplHelper:showTimeLimit(data)
  if data.startTime == 0 then
    self.uiBinder.Ref:SetVisible(self.time_lock_, false)
  else
    local t = Z.TimeTools.Now()
    if t < data.startTime then
      self.uiBinder.Ref:SetVisible(self.time_lock_, true)
      if self.curPropState == propState.none then
        self.curPropState = propState.time
      end
      self.curTime_ = math.floor((data.startTime - Z.TimeTools.Now()) / 1000)
      self:updateTime()
    else
      self.uiBinder.Ref:SetVisible(self.time_lock_, false)
    end
  end
end

function SeasonShopItemTplHelper:showLevelLimit(data)
  local levelLimit = data.cfg.ShowLimitType
  if not levelLimit[1] and not levelLimit[1][2] then
    return
  end
  local bool = Z.ConditionHelper.CheckCondition(levelLimit)
  if bool == false then
    self.notLevel_ = levelLimit[1][2]
    self.curPropState = propState.level
  end
end

function SeasonShopItemTplHelper:showBuyState(cfg)
  local have = false
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
  if have then
    self.curPropState = propState.have
  end
end

function SeasonShopItemTplHelper:updateTime()
  self.time_lock_label_.text = Z.TimeFormatTools.FormatToDHMS(self.curTime_)
  if self.curPropState == propState.time then
    self.buy_state_label_.text = self.time_lock_label_.text
  end
end

function SeasonShopItemTplHelper:refreshLockState(cfg)
  local check = Z.ConditionHelper.CheckCondition(cfg.UnlockConditions)
  if check == false then
    local desc
    local r = Z.ConditionHelper.GetConditionDescList(cfg.UnlockConditions)
    for _, value in ipairs(r) do
      if value.IsUnlock == false then
        desc = value.showPurview
        break
      end
    end
    self.curPropState = propState.lock
    self.uiBinder.lab_unlock_conditions.text = desc
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlock_conditions, true)
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlock_conditions, false)
end

function SeasonShopItemTplHelper:showPropState()
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_lock, true)
  self.uiBinder.Ref:SetVisible(self.buy_state_root_, false)
  self.uiBinder.Ref:SetVisible(self.price_root_, true)
end

function SeasonShopItemTplHelper:onStartAnimShow(index)
  if self.uiBinder.node_light_red then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_light_red, index == 5)
  end
  if self.uiBinder.node_light_yellow then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_light_yellow, index == 4)
  end
  if self.uiBinder.node_light_purple then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_light_purple, index == 3)
  end
  if 3 <= index then
    self.uiBinder.anim:Restart(qualityAnim[index])
  end
end

return SeasonShopItemTplHelper
