local super = require("rednode.rednode")
local CEffectRednode = class("CEffectRednode", super)

function CEffectRednode:ctor(node)
  super.ctor(self, node)
end

function CEffectRednode:Update(redDotItem)
  if redDotItem and self.Node.EffectPath and self.Node.EffectPath ~= "" then
    if self.Node.State then
      redDotItem.effect.ZEff:CreatEFFGO(self.Node.EffectPath, Vector3.zero)
    else
      redDotItem.effect.ZEff:ReleseEffGo()
    end
  end
end

function CEffectRednode:Hide(redDotItem)
  if redDotItem then
    redDotItem.effect.ZEff:ReleseEffGo()
  end
end

return CEffectRednode
