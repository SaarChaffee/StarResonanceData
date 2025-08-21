local super = require("rednode.core.uistylenode.red_dot_style_base_item")
local NumberRedStyleItem = class("NumberRedStyleItem", super)

function NumberRedStyleItem:ctor(node)
  super.ctor(self, node)
  self.styleType_ = E.RedDotStyleType.Number
end

function NumberRedStyleItem:Update(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(self.Node.State)
    redDotItem.lab_red.TMPLab.text = self.Node.Num
  end
end

function NumberRedStyleItem:Hide(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(false)
  end
end

return NumberRedStyleItem
