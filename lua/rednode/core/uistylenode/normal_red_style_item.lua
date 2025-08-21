local super = require("rednode.core.uistylenode.red_dot_style_base_item")
local NormalRedStyleItem = class("NormalRedStyleItem", super)

function NormalRedStyleItem:ctor(node)
  super.ctor(self, node)
  self.styleType_ = E.RedDotStyleType.Normal
end

function NormalRedStyleItem:Update(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(self.Node.State)
  end
end

function NormalRedStyleItem:Hide(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(false)
  end
end

return NormalRedStyleItem
