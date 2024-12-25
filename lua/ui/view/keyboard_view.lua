local UI = Z.UI
local super = require("ui.ui_subview_base")
local KeyboardView = class("KeyboardView", super)

function KeyboardView:ctor(parent)
  self.panel = nil
  super.ctor(self, "keyboard", "commonui/keyboard", UI.ECacheLv.None)
  self.numberCall_ = nil
  self.okCall_ = nil
  self.delCall_ = nil
end

function KeyboardView:OnActive()
  self.numBtns_ = {
    self.panel.btn_num0,
    self.panel.btn_num1,
    self.panel.btn_num2,
    self.panel.btn_num3,
    self.panel.btn_num4,
    self.panel.btn_num5,
    self.panel.btn_num6,
    self.panel.btn_num7,
    self.panel.btn_num8,
    self.panel.btn_num9
  }
  for number, btn_num in pairs(self.numBtns_) do
    self:AddClick(btn_num.Btn, function()
      local num = number - 1
      if self.numberCall_ and next(self.numberCall_) then
        self.numberCall_(num)
      end
    end)
  end
  self:AddClick(self.panel.btn_del.Btn, function()
    if self.okCall_ and next(self.okCall_) then
      self.okCall_(num)
    end
  end)
  self:AddClick(self.panel.btn_ok.Btn, function()
    if self.delCall_ and next(self.delCall_) then
      self.delCall_(num)
    end
  end)
end

function KeyboardView:OnDeActive()
  self.numberCall_ = nil
  self.okCall_ = nil
  self.delCall_ = nil
end

function KeyboardView:OnRefresh()
end

return KeyboardView
