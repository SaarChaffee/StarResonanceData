local super = require("rednode.rednode")
local UEffectRednode = class("UEffectRednode", super)

function UEffectRednode:ctor(node)
  super.ctor(self, node)
end

function UEffectRednode:Update(redDotItem)
  if redDotItem and self.Node.EffectPath and self.Node.EffectPath ~= "" then
    if self.Node.State then
      redDotItem.effect.ZEff:CreatEFFGO(self.Node.EffectPath, Vector3.zero)
    else
      redDotItem.effect.ZEff:ReleseEffGo()
    end
  end
end

function UEffectRednode:Hide(redDotItem)
  if redDotItem then
    redDotItem.effect.ZEff:ReleseEffGo()
  end
end

return UEffectRednode
