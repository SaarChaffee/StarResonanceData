local super = require("ui.component.loop_list_view_item")
local ShopFashionGiftLoopItem = class("ShopFashionGiftLoopItem", super)

function ShopFashionGiftLoopItem:OnInit()
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function ShopFashionGiftLoopItem:OnUnInit()
  self:clearTimerCall()
end

function ShopFashionGiftLoopItem:OnRecycle()
  self:clearTimerCall()
end

function ShopFashionGiftLoopItem:OnRefresh(data)
  self.curPropState_ = 0
  self.data_ = data
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, false)
  self.mallItemTableRow_ = Z.TableMgr.GetTable("MallItemTableMgr").GetRow(self.data_.itemId, true)
  if not self.mallItemTableRow_ then
    return
  end
  self:refreshCost()
  self:refreshItemName()
  self:refreshItemIcon()
  self:refreshCountLimit()
  self:refreshItemState()
  self:refreshTimeLimit()
end

function ShopFashionGiftLoopItem:OnSelected(isSelected, isClick)
  if isSelected then
    self.parent.UIView:OnClickGiftItem(self.data_, self.Index, self.curPropState_)
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_select, self.IsSelected)
end

function ShopFashionGiftLoopItem:refreshCost()
  local gold = 0
  local oldGold = 0
  local currencyId = 0
  for id, num in pairs(self.mallItemTableRow_.Cost) do
    currencyId = id
    gold = num
    local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(id, true)
    if itemcfg then
      self.uiBinder.rimg_gold:SetImage(self.itemsVM_.GetItemIcon(id))
    end
    if gold == 0 then
      self.uiBinder.lab_gold.text = Lang("Free")
      break
    end
    self.uiBinder.lab_gold.text = Z.NumTools.FormatNumberWithCommas(num)
    break
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, false)
  for id, num in pairs(self.mallItemTableRow_.OriginalPrice) do
    if id == currencyId then
      oldGold = num
      self.uiBinder.lab_old_gold.text = Z.NumTools.FormatNumberWithCommas(num)
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_old_gold, true)
      break
    end
  end
  if 0 < oldGold then
    self.uiBinder.lab_discount.text = string.format("%d%%", -math.floor((oldGold - gold) / oldGold * 100))
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_discount, true)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_discount, false)
  end
end

function ShopFashionGiftLoopItem:refreshItemName()
  local itemcfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.mallItemTableRow_.ItemId, true)
  if not itemcfg then
    return
  end
  self.uiBinder.lab_name.text = itemcfg.Name
end

function ShopFashionGiftLoopItem:refreshItemIcon()
  if self.mallItemTableRow_.GoodItemIcon ~= "" then
    self.uiBinder.img_char:SetImage(self.mallItemTableRow_.GoodItemIcon)
  else
    self.uiBinder.img_char:SetImage(self.itemsVM_.GetItemIcon(self.mallItemTableRow_.ItemId))
  end
end

function ShopFashionGiftLoopItem:refreshCountLimit()
  if table.zcount(self.data_.buyCount) == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_limit, false)
    return
  else
    local countType, countData
    for id, data in pairs(self.data_.buyCount) do
      if id ~= E.ESeasonShopRefreshType.None then
        countType = id
        countData = data
        break
      end
    end
    if not countData then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_limit, false)
      return
    end
    if self.data_.limitBuyType == 1 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_limit, true)
      self.uiBinder.lab_limit.text = Lang("SeasonShopCanBuyCountTitle") .. countData.canBuyCount .. "/" .. countData.purchasedCount + countData.canBuyCount
    else
      local str_ = ""
      if countType == E.ESeasonShopRefreshType.Daily then
        str_ = Lang("SeasonShopDayTitle")
      elseif countType == E.ESeasonShopRefreshType.Week then
        str_ = Lang("SeasonShopWeekTitle")
      elseif countType == E.ESeasonShopRefreshType.Month then
        str_ = Lang("SeasonShopMonthTitle")
      elseif countType == E.ESeasonShopRefreshType.Season then
        if self.data_.shopType == 0 then
          str_ = Lang("ShopSeasonLimitTitle")
        else
          str_ = Lang("SeasonShopSeasonLimitTitle")
        end
      elseif countType == E.ESeasonShopRefreshType.Compensate or countType == E.ESeasonShopRefreshType.Permanent then
        str_ = Lang("ShopSeasonLimitTitle")
      end
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_limit, true)
      if countData.canBuyCount == 0 then
        self.uiBinder.lab_limit.text = Lang("SeasonShopSellDone")
      else
        self.uiBinder.lab_limit.text = str_ .. countData.canBuyCount .. "/" .. countData.maxBuyCount
      end
    end
    if countData.canBuyCount == 0 then
      self.curPropState_ = 1
    end
  end
end

function ShopFashionGiftLoopItem:refreshItemState()
  local isShowlock = false
  local descList = Z.ConditionHelper.GetConditionDescList(self.mallItemTableRow_.UnlockConditions)
  for _, value in ipairs(descList) do
    if value.IsUnlock == false then
      isShowlock = true
      self.curPropState_ = 1
      break
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_condition, isShowlock)
  if self.curPropState_ == 0 then
    self.uiBinder.canvas_bg.alpha = 1
  else
    self.uiBinder.canvas_bg.alpha = 0.3
  end
  if isShowlock and self.mallItemTableRow_.NotPurchaseConditionsIsShow then
    self.uiBinder.lab_gold.text = ""
    self.uiBinder.lab_old_gold.text = ""
    self.uiBinder.Ref:SetVisible(self.uiBinder.rimg_gold, false)
  end
end

function ShopFashionGiftLoopItem:refreshTimeLimit()
  if self.data_.startTime == 0 and self.data_.endTime == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, false)
  else
    local t = Z.TimeTools.Now() * 0.001
    if t < self.data_.startTime then
      self.uiBinder.lab_time.text = Z.TimeFormatTools.TicksFormatTime(self.data_.startTime * 1000, E.TimeFormatType.YMDHMS) .. Lang("OnTheShelf")
      self.rigestTimerCall_ = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, true)
    elseif t < self.data_.endTime then
      self.curTime_ = math.floor(self.data_.endTime - t)
      self.parent.UIView:RigestTimerCall(self.data_.itemId, function()
        self:updateTime()
      end)
      self:updateTime()
      self.rigestTimerCall_ = true
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, true)
    else
      self.rigestTimerCall_ = false
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_time, false)
    end
  end
end

function ShopFashionGiftLoopItem:updateTime()
  self.curTime_ = self.curTime_ - 1
  if self.curTime_ <= 0 then
    self.parent.UIView:UpdateProp()
  else
    self.uiBinder.lab_time.text = Z.TimeFormatTools.FormatToDHMS(self.curTime_)
  end
end

function ShopFashionGiftLoopItem:clearTimerCall()
  if self.rigestTimerCall_ then
    self.parent.UIView:UnrigestTimerCall(self.data_.itemId)
    self.rigestTimerCall_ = false
  end
end

return ShopFashionGiftLoopItem
