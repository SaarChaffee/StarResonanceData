local CurrencyItem = class("CurrencyItem")

function CurrencyItem:ctor()
  self.currencyVM_ = Z.VMMgr.GetVM("currency")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function CurrencyItem:Init(uiBinder)
  self.uiBinder = uiBinder
  self.uiBinder.btn_item:AddListener(function()
    self:OnItemClick()
  end)
  self.uiBinder.btn_add:AddListener(function()
    self:onAddClick()
  end)
  self.uiBinder.btn_tips:AddListener(function()
    self:onTipsClick()
  end)
  uiBinder.steer:ClearSteerList()
  Z.EventMgr:Add(Z.ConstValue.Backpack.AllChange, self.onItemChange, self)
  Z.EventMgr:Add(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, self.onLifeProfessionPointChanged, self)
end

function CurrencyItem:UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AllChange, self.onItemChange, self)
  Z.EventMgr:Remove(Z.ConstValue.LifeProfession.LifeProfessionPointChanged, self.onLifeProfessionPointChanged, self)
  self.uiBinder.steer:ClearSteerList()
  self:CloseItemTips()
end

function CurrencyItem:onItemChange(item)
  if not self.currencyItemData_ then
    return
  end
  if item.configId == self.currencyItemData_.configId then
    self:RefreshUI(self.currencyItemData_)
  end
end

function CurrencyItem:onLifeProfessionPointChanged()
  if not self.currencyItemData_ then
    return
  end
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  if lifeProfessionVM.CheckIsLifeProfessionPointItem(self.currencyItemData_.configId) then
    self:RefreshUI(self.currencyItemData_)
  end
end

function CurrencyItem:RefreshUI(currencyItemData)
  self.currencyItemData_ = currencyItemData
  self.curItemConfig_ = Z.TableMgr.GetRow("ItemTableMgr", currencyItemData.configId)
  local haveCount = self.itemsVM_.GetItemTotalCount(self.currencyItemData_.configId)
  self.uiBinder.lab_count.text = Z.NumTools.FormatNumberOverTenMillion(haveCount)
  self.uiBinder.img_icon:SetImage(self.itemsVM_.GetItemIcon(self.currencyItemData_.configId))
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_week_get, false)
  Z.GuideMgr:SetSteerIdByComp(self.uiBinder.steer, E.DynamicSteerType.CurrencyItemId, self.currencyItemData_.configId)
  local lifeProfessionVM = Z.VMMgr.GetVM("life_profession")
  if E.CurrencyType.Honour == self.currencyItemData_.configId then
    local counterId
    for k, v in ipairs(Z.Global.ItemGainLimit) do
      local configId = v[1]
      if configId == E.CurrencyType.Honour then
        counterId = v[2]
      end
    end
    if counterId then
      self.uiBinder.Ref:SetVisible(self.uiBinder.node_week_get, true)
      local limitCount = Z.CounterHelper.GetCounterLimitCount(counterId)
      local ownCount = Z.CounterHelper.GetOwnCount(counterId)
      self.uiBinder.lab_tips.text = Lang("WeekGain", {
        val = ownCount .. "/" .. limitCount
      })
    end
  elseif E.CurrencyType.Vitality == self.currencyItemData_.configId then
    local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
    if craftEnergyTableRow then
      local ownCountStr = Z.NumTools.FormatNumberOverTenThousand(haveCount)
      self.uiBinder.lab_count.text = ownCountStr .. "/" .. craftEnergyTableRow.UpLimit
    end
  elseif E.CurrencyType.Friendship == self.currencyItemData_.configId then
    self.uiBinder.Ref:SetVisible(self.uiBinder.node_week_get, true)
    local limitCount = Z.CounterHelper.GetCounterLimitCount(Z.Global.AssitRefresh)
    local currentNum = Z.CounterHelper.GetOwnCount(Z.Global.AssitRefresh)
    local activeCounterId
    for k, v in ipairs(Z.Global.RelaxGainLimit) do
      local configId = v[1]
      if configId == E.CurrencyType.Friendship then
        activeCounterId = v[2]
      end
    end
    if activeCounterId then
      limitCount = limitCount + Z.CounterHelper.GetCounterLimitCount(activeCounterId)
      currentNum = currentNum + Z.CounterHelper.GetOwnCount(activeCounterId)
    end
    self.uiBinder.lab_tips.text = Lang("WeekGain", {
      val = currentNum .. "/" .. limitCount
    })
  elseif lifeProfessionVM.CheckIsLifeProfessionPointItem(self.currencyItemData_.configId) then
    local cnt = lifeProfessionVM.GetSpcItemCnt()
    self.uiBinder.lab_count.text = Z.NumTools.FormatNumberOverTenMillion(cnt)
  end
  local isShowAddBtn = self.currencyVM_.IsShowExchangeBtn(self.currencyItemData_.configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, isShowAddBtn)
end

function CurrencyItem:OnItemClick()
  if Z.SystemItem.Bindingcoin == self.currencyItemData_.configId then
    Z.UIMgr:OpenView("shop_exchange_popup", {
      itemId = self.currencyItemData_.configId
    })
  elseif Z.StallRuleConfig.fakediamondID == self.currencyItemData_.configId or Z.SystemItem.ItemCoin == self.currencyItemData_.configId or Z.SystemItem.ItemDiamond == self.currencyItemData_.configId then
    self:OpenExchangeTips()
  else
    self:OpenItemTips()
  end
end

function CurrencyItem:onAddClick()
  if Z.StallRuleConfig.fakediamondID == self.currencyItemData_.configId or Z.SystemItem.Bindingcoin == self.currencyItemData_.configId then
    Z.UIMgr:OpenView("shop_exchange_popup", {
      itemId = self.currencyItemData_.configId
    })
  else
    self:OpenExchangeTips()
  end
end

function CurrencyItem:onTipsClick()
  self:OpenItemTips()
end

function CurrencyItem:OpenItemTips()
  self:CloseItemTips()
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.currencyItemData_.configId)
end

function CurrencyItem:OpenExchangeTips()
  self:CloseItemTips()
  self.tipsId_ = self.currencyVM_.OpenExChangeCurrencyView(self.currencyItemData_.configId, false, self.uiBinder.Trans)
end

function CurrencyItem:CloseItemTips()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

return CurrencyItem
