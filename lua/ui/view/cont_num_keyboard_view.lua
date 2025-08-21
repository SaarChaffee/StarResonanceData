local UI = Z.UI
local super = require("ui.ui_subview_base")
local Cont_num_keyboardView = class("Cont_num_keyboardView", super)

function Cont_num_keyboardView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "cont_num_keyboard", "c_common/cont_num_keyboard_tpl", UI.ECacheLv.None)
  self.parentView_ = parent
end

function Cont_num_keyboardView:initComp()
  self.btns_ = {}
  for i = 0, 9 do
    self.btns_[i + 1] = self.uiBinder["btn_" .. i]
  end
end

function Cont_num_keyboardView:refreshUIScale()
  if self.viewData.scale then
    self.uiBinder.Trans.localScale = Vector3.one * self.viewData.scale
  else
    self.uiBinder.Trans.localScale = Vector3.one
  end
end

function Cont_num_keyboardView:OnActive()
  self:initComp()
  self:refreshUIScale()
  self.nowInputNum_ = 0
  for index, btn in ipairs(self.btns_) do
    self:AddClick(btn, function()
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
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    if self.viewData.onInputOk then
      self.viewData.onInputOk(self.nowInputNum_)
    end
    self:DeActive()
  end)
  self:AddClick(self.uiBinder.btn_del, function()
    self.nowInputNum_ = 0
    if self.viewData.min then
      self.parentView_:InputNum(self.viewData.min)
    else
      self.parentView_:InputNum(self.nowInputNum_)
    end
  end)
  self:AddClick(self.uiBinder.press_check.ContainGoEvent, function(isCheck)
    if not isCheck then
      self:DeActive()
    end
  end)
  self.uiBinder.press_check:StartCheck()
end

function Cont_num_keyboardView:OnDeActive()
  if self.viewData.onKeyPadClose then
    self.viewData.onKeyPadClose()
  end
  self.uiBinder.press_check:StopCheck()
end

function Cont_num_keyboardView:OnRefresh()
end

return Cont_num_keyboardView
