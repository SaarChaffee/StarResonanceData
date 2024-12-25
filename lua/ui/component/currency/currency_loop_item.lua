local dataMgr = require("ui.model.data_manager")
local super = require("ui.component.loop_list_view_item")
local CurrencyLoopItem = class("CurrencyLoopItem", super)

function CurrencyLoopItem:ctor()
  self.uiBinder = nil
  self.currencyVm_ = Z.VMMgr.GetVM("currency")
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function CurrencyLoopItem:OnInit()
  self:AddAsyncListener(self.uiBinder.btn_add, function()
    self:onAddClick()
  end)
end

function CurrencyLoopItem:OnRefresh(data)
  self.configId_ = data
  local currencyVm = Z.VMMgr.GetVM("currency")
  self.packageIInfo_ = currencyVm.GetItemInfoByConfigId(self.configId_)
  if self.packageIInfo_ then
    self:addItemInfoRegWatcher(self.packageIInfo_)
    self:setUI()
  else
    self:setUI()
  end
end

function CurrencyLoopItem:itemInfoRegWatcher(watcherFun)
  self.itemInfoWatcherFun = watcherFun
  self.itemInfo_.Watcher:RegWatcher(watcherFun)
end

function CurrencyLoopItem:addItemInfoRegWatcher(itemData)
  self.itemInfo_ = itemData
  self:setUI()
  self:itemInfoRegWatcher(function(container, dirtys)
    self:setUI()
  end)
end

function CurrencyLoopItem:setUI()
  if not self.configId_ then
    return
  end
  local itemTablMgr = Z.TableMgr.GetTable("ItemTableMgr")
  local itemTableData = itemTablMgr.GetRow(self.configId_)
  local count = self.itemsVm_.GetItemTotalCount(self.configId_)
  if self.itemInfo_ then
    self.uiBinder.lab_count.text = Z.NumTools.FormatNumberWithCommas(count)
  else
    self.uiBinder.lab_count.text = self.currencyVm_.NumberCurrencyToStr(0)
  end
  if itemTableData == nil then
    return
  end
  self.uiBinder.rimg_icon:SetImage(self.itemsVm_.GetItemIcon(self.configId_))
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_week_get, false)
  if E.CurrencyType.Honour == self.configId_ then
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
  elseif E.CurrencyType.Vitality == self.configId_ then
    local craftEnergyTableRow = Z.TableMgr.GetRow("CraftEnergyTableMgr", E.CurrencyType.Vitality)
    if craftEnergyTableRow then
      self.uiBinder.lab_count.text = Z.NumTools.FormatNumberWithCommas(count) .. "/" .. Z.NumTools.FormatNumberWithCommas(craftEnergyTableRow.UpLimit)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, self.currencyVm_.IsShowExchangeBtn(self.configId_))
end

function CurrencyLoopItem:OnPointerClick(go, eventData)
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  self.tipsId_ = Z.TipsVM.ShowItemTipsView(self.uiBinder.Trans, self.configId_)
end

function CurrencyLoopItem:OnSelected(isSelected, isClick)
end

function CurrencyLoopItem:onAddClick()
  self.tipsId_ = self.currencyVm_.OpenExChangeCurrencyView(self.configId_, false, self.uiBinder.Trans)
end

function CurrencyLoopItem:OnUnInit()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
  if self.itemInfo_ then
    self.itemInfo_.Watcher:UnregWatcher(self.itemInfoWatcherFun)
  end
  self.itemInfo_ = nil
  self.configId_ = nil
end

return CurrencyLoopItem
