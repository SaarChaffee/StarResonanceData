local CurrencyItemList = class("CurrencyItemList")
local currency_item = require("ui.component.currency.currency_item")

function CurrencyItemList:ctor()
  self.currencyVM_ = Z.VMMgr.GetVM("currency")
  self.itemsVM_ = Z.VMMgr.GetVM("items")
end

function CurrencyItemList:Init(uiBinder, itemList)
  self.currencyList = {
    uiBinder.currency_item_1,
    uiBinder.currency_item_2,
    uiBinder.currency_item_3,
    uiBinder.currency_item_4
  }
  self.uiBinder = uiBinder
  self.itemList = itemList
  if not self.binderList then
    self.binderList = {}
    for i = 1, 4 do
      local currencyItem = currency_item.new()
      currencyItem:Init(self.currencyList[i])
      table.insert(self.binderList, currencyItem)
    end
  end
  self:refreshUI()
end

function CurrencyItemList:UnInit()
  if self.binderList then
    for i = 1, #self.binderList do
      self.binderList[i]:UnInit()
    end
  end
  for i = 1, 4 do
    self.uiBinder.Ref:SetVisible(self.currencyList[i].Trans, false)
  end
end

function CurrencyItemList:refreshUI()
  for i = 1, 4 do
    if i > #self.itemList then
      self.uiBinder.Ref:SetVisible(self.currencyList[i].Trans, false)
    else
      self.uiBinder.Ref:SetVisible(self.currencyList[i].Trans, true)
      local currencyItem = self.binderList[i]
      if not currencyItem then
        return
      end
      currencyItem:RefreshUI({
        configId = self.itemList[i]
      })
    end
  end
end

return CurrencyItemList
