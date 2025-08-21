local UI = Z.UI
local super = require("ui.ui_subview_base")
local keyPad = require("ui.view.cont_num_keyboard_view")
local Cont_num_module_tplView = class("Cont_num_module_tplView", super)

function Cont_num_module_tplView:ctor(parent, styleName)
  self.uiBinder = nil
  super.ctor(self, "cont_num_module_tpl", "new_com/cont_num_module_tpl_lab_new", UI.ECacheLv.None)
  self.itemsVm_ = Z.VMMgr.GetVM("items")
end

function Cont_num_module_tplView:OnActive()
  self.loaded_ = true
  self:initwidgets()
  self.overLapNum_ = -1
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
  if self.cacheVisible_ ~= nil then
    self:SetVisible(self.cacheVisible_)
    self.cacheVisible_ = nil
  end
  self.keypad_ = keyPad.new(self)
  self:AddClick(self.uiBinder.btn_num, function()
    self.keypad_:Active({
      max = self.maxCanBuyCount_
    }, self.keypadRootTrans_)
  end)
  self:AddClick(self.btn_add_, function()
    self:add()
  end)
  self:AddClick(self.btn_max_, function()
    self:onMax()
  end)
  self:AddClick(self.btn_reduce_, function()
    self:reduce()
  end)
  if self.slider_ then
    self.slider_.value = 1
    self.slider_:AddListener(function()
      self.curNum_ = self.slider_.value
      self:updateNumData()
    end)
  end
  self:AddPressListener(self.btn_add_, function()
    self:add()
  end)
  self:AddPressListener(self.btn_reduce_, function()
    self:reduce()
  end)
end

function Cont_num_module_tplView:OnDeActive()
  self.loaded_ = nil
  if self.keypad_ then
    self.keypad_:DeActive()
  end
end

function Cont_num_module_tplView:LoadFinish()
  super.LoadFinish(self)
  if self.viewData and self.viewData.scale then
    local scale = self.viewData.scale
    self.uiBinder.btn_group_ref:SetScale(scale.x, scale.y)
  else
    self.uiBinder.btn_group_ref:SetScale(1, 1)
  end
end

function Cont_num_module_tplView:initwidgets()
  self.keypadRootTrans_ = self.uiBinder.group_keypadroot
  self.buy_num_label_ = self.uiBinder.lab_num
  self.slider_ = self.uiBinder.slider_temp
  self.btn_add_ = self.uiBinder.btn_add
  self.btn_max_ = self.uiBinder.btn_max
  self.btn_reduce_ = self.uiBinder.btn_reduce
  self.lab_number_ = self.uiBinder.lab_number
end

function Cont_num_module_tplView:OnRefresh()
end

function Cont_num_module_tplView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function Cont_num_module_tplView:SetVisible(vis)
  if not self.loaded_ then
    self.cacheVisible_ = vis
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(vis)
end

function Cont_num_module_tplView:ReSetValue(min, maxCanBuyCount, balanceCanBuyCount, updateFun)
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
  self.btn_add_.IsDisabled = self.hide_
  self.btn_max_.IsDisabled = self.hide_
  self.btn_reduce_.IsDisabled = self.hide_
  self.btn_add_.interactable = state
  self.btn_max_.interactable = state
  self.btn_reduce_.interactable = state
  self.slider_.enabled = state
  if self.hide_ then
    self.min_ = 0
    self.curNum_ = 1
  end
  self.slider_.minValue = self.min_
  self.slider_.maxValue = Mathf.Min(self.max_, self.maxCanBuyCount_)
  self:updateNumData()
end

function Cont_num_module_tplView:add()
  self:InputNum(self.curNum_ + 1)
end

function Cont_num_module_tplView:reduce()
  self:InputNum(self.curNum_ - 1)
end

function Cont_num_module_tplView:onMax()
  self:InputNum(self.max_)
end

function Cont_num_module_tplView:changeExchangeItem(itemId)
  local itemCfg = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
  if not itemCfg then
    return
  elseif itemCfg.Overlap == 1 then
    self.overLapNum_ = Z.Global.BuyPerNoOverlapMaxLimit
  elseif itemCfg.Overlap > 1 then
    self.overLapNum_ = Z.Global.BuyPerOverlapMaxLimit
  end
end

function Cont_num_module_tplView:SetMoneyId(id, price)
  if not self.viewData then
    self.viewData = {}
  end
  if not self.viewData.cost then
    self.viewData.cost = {}
  end
  self.viewData.cost.moneyId = id
  self.viewData.cost.price_single = price
end

function Cont_num_module_tplView:updateNumData()
  local numStr = string.format("%d", self.curNum_)
  self.buy_num_label_.text = numStr
  self.slider_:SetValueWithoutNotify(self.curNum_)
  if self.updateFun_ then
    self.updateFun_(self.curNum_)
  end
end

function Cont_num_module_tplView:InputNum(num)
  if num > self.max_ or self.max_ == 0 then
    if self.viewData.tipId then
      Z.VMMgr.GetVM("all_tips").OpenMessageView({
        configId = self.viewData.tipId
      })
    else
      Z.VMMgr.GetVM("all_tips").OpenMessageView({configId = 1000721})
    end
  end
  num = math.max(num, self.min_)
  num = math.min(num, self.max_)
  self.curNum_ = num
  self:updateNumData()
end

return Cont_num_module_tplView
