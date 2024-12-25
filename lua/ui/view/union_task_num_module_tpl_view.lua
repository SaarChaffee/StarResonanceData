local UI = Z.UI
local keyPad = require("ui.view.cont_num_keyboard_view")
local super = require("ui.ui_subview_base")
local Union_task_num_module_tplView = class("Union_task_num_module_tplView", super)

function Union_task_num_module_tplView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "union_task_num_module_tpl", "new_com/cont_num_module_tpl_lab_new", UI.ECacheLv.None)
end

function Union_task_num_module_tplView:OnActive()
  self.loaded_ = true
  self:initBinders()
  if self.cacheData_ then
    self:SetModuleParma(self.cacheData_.min, self.cacheData_.max, self.cacheData_.func)
    self:InitCurNum()
    self.cacheData_ = nil
  end
end

function Union_task_num_module_tplView:OnDeActive()
  self.loaded_ = nil
  if self.keypad_ then
    self.keypad_:DeActive()
  end
end

function Union_task_num_module_tplView:OnRefresh()
end

function Union_task_num_module_tplView:initBinders()
  self.keypadRootTrans_ = self.uiBinder.group_keypadroot
  self.buy_num_label_ = self.uiBinder.lab_num
  self.slider_ = self.uiBinder.slider_temp
  self.btn_add_ = self.uiBinder.btn_add
  self.btn_max_ = self.uiBinder.btn_max
  self.btn_reduce_ = self.uiBinder.btn_reduce
  self.lab_num_ = self.uiBinder.lab_num
  self.btn_num = self.uiBinder.btn_num
  self.keypad_ = keyPad.new(self)
  self:AddClick(self.btn_num, function()
    self.keypad_:Active({
      max = self.max_
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

function Union_task_num_module_tplView:SetModuleParma(min, max, func)
  if not self.loaded_ then
    self.cacheData_ = {
      min = min,
      max = max,
      func = func
    }
    return
  end
  self.max_ = max
  self.uiBinder.slider_temp.maxValue = self.max_
  self.min_ = min
  self.uiBinder.slider_temp.minValue = self.min_
  if func then
    self.updateFun_ = func
  end
end

function Union_task_num_module_tplView:AddPressListener(btn, func)
  btn:AddPressListener(func)
end

function Union_task_num_module_tplView:add()
  self:InputNum(self.curNum_ + 1)
end

function Union_task_num_module_tplView:reduce()
  self:InputNum(self.curNum_ - 1, nil, true)
end

function Union_task_num_module_tplView:onMax()
  self:InputNum(self.max_)
end

function Union_task_num_module_tplView:InitCurNum()
  self.curNum_ = 1
  if self.loaded_ then
    self:updateNumData()
  end
end

function Union_task_num_module_tplView:InputNum(num, tipId, force)
  self.curNum_ = num
  if num < self.min_ then
    self.curNum_ = self.min_
  end
  if num < 1 then
    self.curNum_ = 1
  end
  if num > self.max_ then
    if not force then
      if tipId then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({
          configId = self.viewData.tipId
        })
      elseif self.viewData.tipId then
        Z.VMMgr.GetVM("all_tips").OpenMessageView({
          configId = self.viewData.tipId
        })
      end
      self.curNum_ = self.max_
    else
      self.curNum_ = num
    end
  end
  self:updateNumData()
end

function Union_task_num_module_tplView:updateNumData()
  self.slider_:SetValueWithoutNotify(self.curNum_)
  local numStr = string.format("%d", self.curNum_)
  self.buy_num_label_.text = numStr
  if self.updateFun_ then
    self.updateFun_(self.curNum_)
  end
end

return Union_task_num_module_tplView
