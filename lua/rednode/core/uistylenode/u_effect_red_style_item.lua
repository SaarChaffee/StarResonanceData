local super = require("rednode.core.uistylenode.red_dot_style_base_item")
local UEffectRedStyleItem = class("UEffectRedStyleItem", super)

function UEffectRedStyleItem:ctor(node)
  super.ctor(self, node)
  self.styleType_ = E.RedDotStyleType.UEffect
end

function UEffectRedStyleItem:Update(redDotItem)
  if redDotItem and self.Node.Arguments and self.Node.Arguments ~= "" then
    if self.Node.State then
      redDotItem.effect.ZEff:CreatEFFGO(self.Node.Params, Vector3.zero)
    else
      redDotItem.effect.ZEff:ReleseEffGo()
    end
  end
end

function UEffectRedStyleItem:Hide(redDotItem)
  if redDotItem then
    redDotItem.effect.ZEff:ReleseEffGo()
  end
end

return UEffectRedStyleItem
