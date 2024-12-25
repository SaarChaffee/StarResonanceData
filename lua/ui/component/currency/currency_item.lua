local CurrencyItem = class("CurrencyItem")

function CurrencyItem:ctor()
  self.currencyVM_ = Z.VMMgr.GetVM("currency")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function CurrencyItem:Init(uiBinder, currencyItemData)
  self.uiBinder = uiBinder
  self.currencyItemData_ = currencyItemData
  self.curItemConfig_ = Z.TableMgr.GetRow("ItemTableMgr", currencyItemData.configId)
  self.uiBinder.btn_add:AddListener(function()
    self:onAddClick()
  end)
  self:RegisterWatcher()
  self:RefreshUI()
end

function CurrencyItem:UnInit()
  self:UnregisterWatcher()
  self:CloseItemTips()
end

function CurrencyItem:RegisterWatcher()
  self.curPackageInfo_ = self.currencyVM_.GetItemInfoByConfigId(self.currencyItemData_.configId)
  if self.curPackageInfo_ == nil then
    return
  end
  
  function self.itemChangeFunc_()
    self:RefreshUI()
  end
  
  self.curPackageInfo_.Watcher:RegWatcher(self.itemChangeFunc_)
end

function CurrencyItem:UnregisterWatcher()
  if self.curPackageInfo_ == nil then
    return
  end
  self.curPackageInfo_.Watcher:UnregWatcher(self.itemChangeFunc_)
  self.curPackageInfo_ = nil
  self.itemChangeFunc_ = nil
end

function CurrencyItem:RefreshUI()
  local haveCount = self.itemsVM_.GetItemTotalCount(self.currencyItemData_.configId)
  if self.curPackageInfo_ then
    self.uiBinder.lab_count.text = Z.NumTools.FormatNumberWithCommas(haveCount)
  else
    self.uiBinder.lab_count.text = self.currencyVM_.NumberCurrencyToStr(0)
  end
  self.uiBinder.rimg_icon:SetImage(self.curItemConfig_.Icon)
  local isShowAddBtn = self.currencyVM_.IsShowExchangeBtn(self.currencyItemData_.configId)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_add, isShowAddBtn)
end

function CurrencyItem:onAddClick()
  self:OpenItemTips()
end

function CurrencyItem:OpenItemTips()
  self:CloseItemTips()
  self.tipsId_ = self.currencyVM_.OpenExChangeCurrencyView(self.configId_, false, self.uiBinder.Trans)
end

function CurrencyItem:CloseItemTips()
  if self.tipsId_ then
    Z.TipsVM.CloseItemTipsView(self.tipsId_)
    self.tipsId_ = nil
  end
end

return CurrencyItem
