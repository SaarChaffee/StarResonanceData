local UI = Z.UI
local super = require("ui.ui_subview_base")
local Cont_num_keyboardView = class("Cont_num_keyboardView", super)

function Cont_num_keyboardView:ctor(parent)
  self.panel = nil
  super.ctor(self, "cont_num_keyboard", "c_common/cont_num_keyboard_tpl", UI.ECacheLv.None)
  self.parentView_ = parent
end

function Cont_num_keyboardView:initWidget()
  self.btns_ = {}
  self.delBtn_ = self.panel.btn_del
  self.press_ = self.panel.node_press
  self.okBtn_ = self.panel.btn_ok
  for i = 0, 9 do
    self.btns_[i + 1] = self.panel["btn_" .. i]
  end
end

function Cont_num_keyboardView:OnActive()
  self:initWidget()
  self.nowInputNum_ = 0
  for index, btn in ipairs(self.btns_) do
    self:AddClick(btn.Btn, function()
      local value = self.nowInputNum_ * 10 + index - 1
      if self.viewData.max and value > self.viewData.max then
        value = self.viewData.max
      end
      if self.viewData.min and value < self.viewData.min then
        value = self.viewData.min
      end
      self.nowInputNum_ = value
      self.parentView_:InputNum(self.nowInputNum_, nil, true)
    end)
  end
  self:AddClick(self.okBtn_.Btn, function()
    self:DeActive()
  end)
  self:AddClick(self.delBtn_.Btn, function()
    self.nowInputNum_ = 0
    if self.viewData.min then
      self.parentView_:InputNum(self.viewData.min)
    else
      self.parentView_:InputNum(self.nowInputNum_)
    end
  end)
  self:AddClick(self.press_.PressCheck.ContainGoEvent, function(isCheck)
    if not isCheck then
      self:DeActive()
    end
  end)
  self.press_.PressCheck:StartCheck()
end

function Cont_num_keyboardView:OnDeActive()
  self.press_.PressCheck:StopCheck()
end

function Cont_num_keyboardView:OnRefresh()
end

return Cont_num_keyboardView
