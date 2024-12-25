local super = require("ui.component.loop_list_view_item")
local FishingShopLoopItem = class("FishingShopLoopItem", super)
local propState = {
  none = 0,
  time = 1,
  count = 2,
  level = 3,
  have = 4,
  fishinglevel = 5
}
local labelEnum = {
  none = 0,
  discount = 1,
  cfg = 2
}
local bgImgStr_ = "ui/atlas/season/seasonshop_item_quality_%d"

function FishingShopLoopItem:ctor()
  self.vm = Z.VMMgr.GetVM("season_shop")
end

function FishingShopLoopItem:initBinder()
  self.curTimerId_ = 0
  self.initTag_ = true
  self.quality_img_ = self.uiBinder.img_quality_bg
  self.quality_btn_ = self.uiBinder.btn_quality_bg
  self.name_label_ = self.uiBinder.lab_item_name
  self.new_tag_ = self.uiBinder.img_new
  self.new_tag_label_ = self.uiBinder.lab_new
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
  self.limit_tab_bg_ = {
    self.uiBinder.img_week_bg,
    self.uiBinder.img_day_bg
  }
  self.limit_tab_title = {
    self.uiBinder.lab_week_title,
    self.uiBinder.lab_day_title
  }
  self.lastRedId_ = nil
end

function FishingShopLoopItem:OnInit()
  self:initBinder()
  self.parentUIView = self.parent.UIView
  self.quality_btn_:AddListener(function()
    if not self.parent.UIView.IsFashionShop then
      local d = self:GetCurData()
      if self.curPropState == propState.count then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1000720})
        return
      end
      if self.curPropState == propState.level then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1000725})
        return
      end
      if self.curPropState == propState.fishinglevel then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1500009})
        return
      end
      self.parent.UIView:OpenBuyPopup(d, self.Index)
    else
      self.parent.UIView:SetSelected(self.Index)
    end
  end)
end

function FishingShopLoopItem:OnRefresh(data)
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
  if data == nil then
    return
  end
  if data.shopType == E.EShopType.Shop then
    local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
    if mallItemCfgData then
      local mallCfgData
      for key, cfgData in pairs(Z.TableMgr.GetTable("MallTableMgr").GetDatas()) do
        if cfgData.FunctionId == mallItemCfgData.FunctionId then
          mallCfgData = cfgData
          break
        end
      end
      if mallCfgData then
        if mallCfgData.HasFatherType == 0 then
          self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopOneTab, mallCfgData.Id, E.RedType.ShopItem, data.itemId)
        else
          self.lastRedId_ = string.zconcat(E.RedType.Shop, E.RedType.ShopTwoTab, mallCfgData.Id, E.RedType.ShopItem, data.itemId)
        end
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
  self:showBuyState(data)
  self:showFishingLevelLimit(data.cfg)
  self:showPropState(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, false)
end

function FishingShopLoopItem:Selected(isSelected)
  self:SelectState()
end

function FishingShopLoopItem:OnSelected(isSelected)
  if isSelected then
    self.parent.UIView:OpenBuyPopup(self:GetCurData(), self.Index)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, isSelected)
end

function FishingShopLoopItem:OnUnInit()
  if self.lastRedId_ then
    Z.RedPointMgr.RemoveNodeItem(self.lastRedId_)
    self.lastRedId_ = nil
  end
end

function FishingShopLoopItem:showItem(cfg)
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
  end
end

function FishingShopLoopItem:showCost(cfg)
  local cost = 0
  for id, num in pairs(cfg.Cost) do
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
    end
    break
  end
  if cost == 0 then
    cost = Lang("Free")
  end
  self.price_new_.text = Z.NumTools.FormatNumberWithCommas(cost)
  self:showTag(cfg, cost)
end

function FishingShopLoopItem:showTag(cfg, cost)
  local label = cfg.Label
  if #label <= 0 then
    self.uiBinder.Ref:SetVisible(self.discount_, false)
    self.uiBinder.Ref:SetVisible(self.new_tag_, false)
  else
    local lab = tonumber(label[1])
    if lab == labelEnum.none then
      self.uiBinder.Ref:SetVisible(self.discount_, false)
      self.uiBinder.Ref:SetVisible(self.new_tag_, false)
    elseif lab == labelEnum.discount then
      self.uiBinder.Ref:SetVisible(self.new_tag_, false)
      if not cfg.OriginalPrice or 0 >= #cfg.OriginalPrice then
        self.uiBinder.Ref:SetVisible(self.discount_, false)
      elseif #cfg.OriginalPrice > 2 then
        self.uiBinder.Ref:SetVisible(self.discount_, false)
      else
        self.uiBinder.Ref:SetVisible(self.discount_, true)
        self.discount_label_.text = string.format("%d%%", math.floor(cost / cfg.OriginalPrice[2] * 100))
      end
    elseif lab == labelEnum.cfg then
      self.uiBinder.Ref:SetVisible(self.discount_, false)
      self.uiBinder.Ref:SetVisible(self.new_tag_, true)
      self.new_tag_label_.text = Lang(label[2])
    end
  end
end

function FishingShopLoopItem:showFishingLevelLimit(cfg)
  local fishLevelCondition
  if #cfg.UnlockConditions > 0 then
    for k, v in ipairs(cfg.UnlockConditions) do
      if v[1] == E.ConditionType.FishingLevel then
        fishLevelCondition = v
      end
    end
  end
  if fishLevelCondition then
    local check = Z.ConditionHelper.CheckSingleCondition(fishLevelCondition[1], false, fishLevelCondition[2])
    if check == false then
      local r, _, _, _, _, showPurview = Z.ConditionHelper.GetSingleConditionDesc(fishLevelCondition[1], fishLevelCondition[2])
      if showPurview then
        self.fishingLevelLockDes_ = showPurview
      end
      self.curPropState = propState.fishinglevel
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_unlock_conditions, false)
end

function FishingShopLoopItem:getFishingLevelLimitDes(cfg)
  local desc
  local r = Z.ConditionHelper.GetConditionDescList(cfg.UnlockConditions, true)
  for _, value in ipairs(r) do
    if value.IsUnlock == false then
      desc = value.showPurview
      break
    end
  end
  return desc
end

function FishingShopLoopItem:showCountLimit(data)
  for i = 1, #self.limit_tab_ do
    self.uiBinder.Ref:SetVisible(self.limit_tab_bg_[i], false)
  end
  for i = 1, #self.limit_tab_title do
    self.uiBinder.Ref:SetVisible(self.limit_tab_title[i], false)
  end
  if table.zcount(data.buyCount) == 0 then
    return
  else
    local num, index = 0, 1
    local countTab = {}
    for id, _ in pairs(data.buyCount) do
      if id ~= self.vm.SeasonShopRefreshType.none then
        countTab[#countTab + 1] = id
      end
    end
    table.sort(countTab, function(a, b)
      return a < b
    end)
    local id = 0
    local index = 1
    if data.limitBuyType == 1 then
      id = countTab[1]
      local count = data.buyCount[id]
      num = count.canBuyCount
      local limit_Tab_ = self.limit_tab_[index]
      local limit_title_ = self.limit_tab_title[index]
      local limit_Tab_Bg_ = self.limit_tab_bg_[index]
      self.uiBinder.Ref:SetVisible(limit_title_, true)
      self.uiBinder.Ref:SetVisible(limit_Tab_Bg_, true)
      limit_title_.text = Lang("SeasonShopCanBuyCountTitle")
      limit_Tab_.text = count.canBuyCount .. "/" .. count.purchasedCount + count.canBuyCount
      if self.curPropState == propState.none and num <= 0 then
        self.curPropState = propState.count
      end
      index = index + 1
      limit_Tab_ = self.limit_tab_[index]
      limit_title_ = self.limit_tab_title[index]
      limit_Tab_Bg_ = self.limit_tab_bg_[index]
      local str_ = ""
      if id == self.vm.SeasonShopRefreshType.daily then
        str_ = Lang("SeasonShopDayTitle")
      elseif id == self.vm.SeasonShopRefreshType.week then
        str_ = Lang("SeasonShopWeekTitle")
      end
      self.uiBinder.Ref:SetVisible(limit_Tab_Bg_, true)
      limit_Tab_.text = count.maxBuyCount
      self.uiBinder.Ref:SetVisible(limit_title_, true)
      limit_title_.text = str_
    else
      local length = #countTab
      for i = 1, length do
        index = i
        local str_ = ""
        local count = data.buyCount[countTab[i]]
        num = count.maxBuyCount - count.canBuyCount
        local limit_Tab_ = self.limit_tab_[index]
        local limit_Tab_Bg_ = self.limit_tab_bg_[index]
        local limit_title_ = self.limit_tab_title[index]
        if countTab[i] == self.vm.SeasonShopRefreshType.daily then
          str_ = Lang("SeasonShopDayTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == self.vm.SeasonShopRefreshType.week then
          str_ = Lang("SeasonShopWeekTitle")
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        elseif countTab[i] == self.vm.SeasonShopRefreshType.season then
          num = count.purchasedCount
          if data.shopType == 0 then
            str_ = Lang("ShopSeasonLimitTitle")
          else
            str_ = Lang("SeasonShopSeasonLimitTitle")
          end
          if num == count.maxBuyCount and self.curPropState == propState.none then
            self.curPropState = propState.count
          end
        end
        self.uiBinder.Ref:SetVisible(limit_title_, true)
        self.uiBinder.Ref:SetVisible(limit_Tab_Bg_, true)
        limit_title_.text = str_
        limit_Tab_.text = count.canBuyCount .. "/" .. count.maxBuyCount
        index = index + 1
      end
    end
  end
end

function FishingShopLoopItem:showTimeLimit(data)
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
      self.parent.UIView:RigestTimerCall(data.itemId, function()
        self:updateTime()
      end)
      self:updateTime()
    else
      self.uiBinder.Ref:SetVisible(self.time_lock_, false)
    end
  end
end

function FishingShopLoopItem:showLevelLimit(data)
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

function FishingShopLoopItem:showBuyState(data)
  if self.parent.UIView.IsFashionShop and self.curPropState == propState.none then
    local mallItemCfgData = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(data.itemId)
    if mallItemCfgData then
      local itemTableCfgData = Z.TableMgr.GetTable("ItemTableMgr").GetRow(mallItemCfgData.ItemId)
      if itemTableCfgData then
        local itemTypeTableCfgData = Z.TableMgr.GetTable("ItemTypeTableMgr").GetRow(itemTableCfgData.Type)
        if itemTypeTableCfgData and itemTypeTableCfgData.UpperLlimit > 0 then
          local itemsVm = Z.VMMgr.GetVM("items")
          local count = itemsVm.GetItemTotalCount(mallItemCfgData.ItemId)
          if count >= itemTypeTableCfgData.UpperLlimit then
            self.curPropState = propState.have
          end
        end
      end
    end
  end
end

function FishingShopLoopItem:updateTime()
  self.curTime_ = self.curTime_ - 1
  if self.curTime_ <= 0 then
    self.parent.UIView:UpdateProp()
  else
    self.time_lock_label_.text = Z.TimeTools.FormatToDHMS(self.curTime_)
    if self.curPropState == propState.time then
      self.buy_state_label_.text = self.time_lock_label_.text
    end
  end
end

function FishingShopLoopItem:showPropState(data)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_lock, true)
  if self.curPropState == propState.none then
    self.uiBinder.Ref:SetVisible(self.buy_state_root_, false)
    self.uiBinder.Ref:SetVisible(self.price_root_, true)
  else
    self.uiBinder.Ref:SetVisible(self.buy_state_root_, true)
    self.uiBinder.Ref:SetVisible(self.price_root_, false)
    if self.curPropState == propState.time then
      self.buy_state_label_.text = self.time_lock_label_.text
    elseif self.curPropState == propState.level then
      self.buy_state_label_.text = string.format(Lang("ShowLimitLevel"), self.notLevel_)
    elseif self.curPropState == propState.have then
      self.buy_state_label_.text = Lang("FashionShopHave")
      self.uiBinder.Ref:SetVisible(self.uiBinder.img_icon_lock, false)
    elseif self.curPropState == propState.fishinglevel then
      self.buy_state_label_.text = self.fishingLevelLockDes_
    else
      self.buy_state_label_.text = Lang("SeasonShopSellDone")
    end
  end
end

return FishingShopLoopItem
