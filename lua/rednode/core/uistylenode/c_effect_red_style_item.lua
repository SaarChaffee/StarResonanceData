local super = require("rednode.core.uistylenode.red_dot_style_base_item")
local CEffectRedStyleItem = class("CEffectRedStyleItem", super)

function CEffectRedStyleItem:ctor(node)
  super.ctor(self, node)
  self.styleType_ = E.RedDotStyleType.CEffect
end

function CEffectRedStyleItem:Update(redDotItem)
  if redDotItem and self.Node.Arguments and self.Node.Arguments ~= "" then
    if self.Node.State then
      redDotItem.effect.ZEff:CreatEFFGO(self.Node.Arguments, Vector3.zero)
    else
      redDotItem.effect.ZEff:ReleseEffGo()
    end
  end
end

function CEffectRedStyleItem:Hide(redDotItem)
  if redDotItem then
    redDotItem.effect.ZEff:ReleseEffGo()
  end
end

return CEffectRedStyleItem
