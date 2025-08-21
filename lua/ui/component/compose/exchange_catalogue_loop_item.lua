local super = require("ui.component.loop_grid_view_item")
local ExchangeCatalogueLoopItem = class("ExchangeCatalogueLoopItem", super)
local item = require("common.item_binder")
local exchangeItemTbl = Z.TableMgr.GetTable("ExchangeItemTableMgr")
local limitDailyColor = Color.New(0.8666666666666667, 0.615686274509804, 0.37254901960784315, 1)
local limitWeekColor = Color.New(0.803921568627451, 0.29411764705882354, 0.29411764705882354, 1)

function ExchangeCatalogueLoopItem:ctor()
end

function ExchangeCatalogueLoopItem:OnInit()
  self.exchangeView_ = self.parent.UIView
  self.itemClass_ = item.new(self.exchangeView_)
  self.cancelSource_ = Z.CancelSource.Rent()
  self.vm_ = Z.VMMgr.GetVM("exchange")
end

function ExchangeCatalogueLoopItem:Refresh(data)
  self.exchangeItemData_ = data
  self.shopId_ = self.exchangeView_.shopId_
  self.cancelSource_:CancelAll()
  local exchangeItemRow = exchangeItemTbl.GetRow(self.exchangeItemData_.goodsId)
  if exchangeItemRow == nil then
    return
  end
  local shopInfo_ = Z.ContainerMgr.CharSerialize.exchangeItems.exchangeInfo[self.shopId_]
  local curExchangeNum = shopInfo_.exchangeData[self.exchangeItemData_.goodsId] and shopInfo_.exchangeData[self.exchangeItemData_.goodsId].curExchangeCount or 0
  local maxNum = exchangeItemRow.RefreshNum
  local limitType = self.vm_.GetExchangeLimitType(exchangeItemRow.Id)
  local str
  if maxNum >= Z.Global.ExchangeLimitHide then
    str = ""
  elseif limitType ~= E.ExchangeLimitType.Not then
    local haveCount = maxNum - curExchangeNum
    str = haveCount .. "/" .. maxNum
  end
  local itemData = {
    uiBinder = self.uiBinder,
    configId = exchangeItemRow.GetItemId,
    lab = str,
    expendCount = maxNum,
    labType = E.ItemLabType.Str,
    isClickOpenTips = false,
    isSquareItem = true
  }
  self.itemClass_:Init(itemData)
  self:setExchangeComplete(exchangeItemRow, curExchangeNum == maxNum)
  self:setExchangeLimit(exchangeItemRow)
  self.itemClass_:SetImgLockState(not self.exchangeItemData_.isUnlock)
  self.itemClass_:SetSelected(self.IsSelected)
  self.uiBinder.Ref:SetVisible(self.uiBinder.img_bind, exchangeItemRow.Bind == 1)
end

function ExchangeCatalogueLoopItem:setExchangeComplete(exchangeItemRow, complete)
  local upperLimmit = self.vm_.IsUpperLimmit(exchangeItemRow.Id)
  local completeText = upperLimmit and Lang("ExchangeItemUpperLimit") or Lang("Redeemed")
  self.itemClass_:SetExchangeComplete(complete or upperLimmit, completeText)
end

function ExchangeCatalogueLoopItem:setExchangeLimit(exchangeItemRow)
  local limitType = self.vm_.GetExchangeLimitType(exchangeItemRow.Id)
  if limitType == E.ExchangeLimitType.Day then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_timer_bg, true)
    self.uiBinder.lab_timer.text = Lang("ExchangeLimitDaily")
    self.uiBinder.img_timer_bg:SetColor(limitDailyColor)
  elseif limitType == E.ExchangeLimitType.Week then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_timer_bg, true)
    self.uiBinder.lab_timer.text = Lang("ExchangeLimitWeek")
    self.uiBinder.img_timer_bg:SetColor(limitWeekColor)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_timer_bg, false)
  end
end

function ExchangeCatalogueLoopItem:OnPointerClick(go, eventData)
  self.cancelSource_:CancelAll()
  self.itemClass_:AsyncPlayClickAnim(self.cancelSource_:CreateToken())
  self.exchangeView_:SelectGoods(self.exchangeItemData_)
  self.exchangeView_:ShowTips()
end

function ExchangeCatalogueLoopItem:OnSelected(isSelected)
  self.itemClass_:SetSelected(isSelected)
end

function ExchangeCatalogueLoopItem:OnUnInit()
  self.itemClass_:UnInit()
  self.cancelSource_:Recycle()
  self.cancelSource_ = nil
end

function ExchangeCatalogueLoopItem:OnReset()
end

return ExchangeCatalogueLoopItem
