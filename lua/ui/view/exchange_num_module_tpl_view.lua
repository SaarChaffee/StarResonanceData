local UI = Z.UI
local super = require("ui.ui_subview_base")
local Exchange_num_module_tplView = class("Exchange_num_module_tplView", super)
local keyPad = require("ui.view.cont_num_keyboard_view")

function Exchange_num_module_tplView:ctor(parent, styleName)
  self.uiBinder = nil
  super.ctor(self, "exchange_num_module_tpl", "new_com/cont_num_module_tpl_new", UI.ECacheLv.None)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Exchange_num_module_tplView:OnActive()
  self.loaded_ = true
  self.overLapNum_ = self.overLapNum_ == nil and -1 or self.overLapNum_
  if self.viewData and self.viewData.itemId then
    local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(self.viewData.itemId)
    if not itemCfg then
      return
    elseif itemCfg.Overlap == 1 then
      self.overLapNum_ = Z.Global.BuyPerNoOverlapMaxLimit
    elseif itemCfg.Overlap > 1 then
      self.overLapNum_ = Z.Global.BuyPerOverlapMaxLimit
    end
  end
  if self.cacheData_ then
    self:ReSetValue(self.cacheData_.min, self.cacheData_.maxCanBuyCount, self.cacheData_.balanceCanBuyCount, self.cacheData_.updateFun)
    self.cacheData_ = nil
  end
  self.keypad_ = keyPad.new(self)
  self:AddClick(self.uiBinder.btn_num, function()
    if self.hide_ then
      return
    end
    self.keypad_:Active({
      max = self.maxCanBuyCount_
    }, self.uiBinder.group_keypadroot)
  end)
  self:AddClick(self.uiBinder.btn_add, function()
    self:add()
  end)
  self:AddClick(self.uiBinder.btn_max, function()
    self:onMax()
  end)
  self:AddClick(self.uiBinder.btn_reduce, function()
    self:reduce()
  end)
  if self.uiBinder.slider_temp then
    self.uiBinder.slider_temp.value = 1
    self.uiBinder.slider_temp:AddListener(function()
      self.curNum_ = self.uiBinder.slider_temp.value
      self:updateNumData()
    end)
  end
  self:AddPressListener(self.uiBinder.btn_add, function()
    self:add()
  end)
  self:AddPressListener(self.uiBinder.btn_reduce, function()
    self:reduce()
  end)
  if self.viewData and self.viewData.SetWidth then
    self.uiBinder.Trans:SetWidth(self.viewData.SetWidth)
  end
end

function Exchange_num_module_tplView:OnDeActive()
  self.loaded_ = nil
  if self.keypad_ then
    self.keypad_:DeActive()
  end
  self.uiBinder.slider_temp:RemoveAllListeners()
  self.cacheData_ = nil
end

function Exchange_num_module_tplView:OnRefresh()
end

function Exchange_num_module_tplView:LoadFinish()
  super.LoadFinish(self)
  if self.viewData and self.viewData.scale then
    local scale = self.viewData.scale
    self.uiBinder.btn_group_ref:SetScale(scale.x, scale.y)
  else
    self.uiBinder.btn_group_ref:SetScale(1, 1)
  end
end

function Exchange_num_module_tplView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function Exchange_num_module_tplView:ReSetValue(min, maxCanBuyCount, balanceCanBuyCount, updateFun)
  if not self.loaded_ then
    self.cacheData_ = {
      min = min,
      maxCanBuyCount = maxCanBuyCount,
      balanceCanBuyCount = balanceCanBuyCount,
      updateFun = updateFun
    }
    return
  end
  if min == 0 then
    min = 1
  end
  if balanceCanBuyCount <= 0 then
    balanceCanBuyCount = 1
  end
  self.min_ = min
  if self.overLapNum_ ~= -1 and maxCanBuyCount > self.overLapNum_ then
    maxCanBuyCount = self.overLapNum_
  end
  self.maxCanBuyCount_ = maxCanBuyCount
  self.max_ = Mathf.Min(maxCanBuyCount, balanceCanBuyCount)
  self.curNum_ = min
  if 1 > self.curNum_ then
    self.curNum_ = 1
  end
  self.updateFun_ = updateFun
  if self.min_ > self.max_ then
    self.min_ = self.max_
  end
  if self.curNum_ > self.max_ then
    self.curNum_ = self.max_
  end
  if self.curNum_ < self.min_ then
    self.curNum_ = self.min_
  end
  self.hide_ = self.min_ == 1 and self.max_ == 1
  local state = not self.hide_
  self.uiBinder.btn_add.IsDisabled = self.hide_
  self.uiBinder.btn_max.IsDisabled = self.hide_
  self.uiBinder.btn_reduce.IsDisabled = self.hide_
  self.uiBinder.slider_temp.interactable = state
  if self.hide_ then
    self.min_ = 0
    self.curNum_ = 1
  end
  self.uiBinder.slider_temp.minValue = self.min_
  self.uiBinder.slider_temp.maxValue = Mathf.Min(self.max_, self.maxCanBuyCount_)
  self:updateNumData()
end

function Exchange_num_module_tplView:add()
  self:InputNum(self.curNum_ + 1)
end

function Exchange_num_module_tplView:reduce()
  self:InputNum(self.curNum_ - 1, nil, true)
end

function Exchange_num_module_tplView:onMax()
  self:InputNum(self.max_)
end

function Exchange_num_module_tplView:changeExchangeItem(itemId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
  if not itemCfg then
    return
  elseif itemCfg.Overlap == 1 then
    self.overLapNum_ = Z.Global.BuyPerNoOverlapMaxLimit
  elseif itemCfg.Overlap > 1 then
    self.overLapNum_ = Z.Global.BuyPerOverlapMaxLimit
  end
end

function Exchange_num_module_tplView:SetMoneyId(id, price)
  if not self.viewData then
    self.viewData = {}
  end
  if not self.viewData.cost then
    self.viewData.cost = {}
  end
  self.viewData.cost.moneyId = id
  self.viewData.cost.price_single = price
end

function Exchange_num_module_tplView:updateNumData()
  local numStr = string.format("%d", self.curNum_)
  self.uiBinder.lab_num.text = numStr
  self.uiBinder.slider_temp:SetValueWithoutNotify(self.curNum_)
  if self.updateFun_ then
    self.updateFun_(self.curNum_)
  end
end

function Exchange_num_module_tplView:InputNum(num, tipId, force)
  self.curNum_ = num
  if num < self.min_ then
    self.curNum_ = self.min_
  end
  if num < 1 then
    self.curNum_ = self.min_
  end
  if num > self.max_ then
    local tipsId = self.viewData.tipsId or 1000721
    Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = tipsId})
    self.curNum_ = self.max_
  end
  self:updateNumData()
end

return Exchange_num_module_tplView
