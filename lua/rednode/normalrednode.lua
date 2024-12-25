local super = require("rednode.rednode")
local NormalRedNode = class("NormalRedNode", super)

function NormalRedNode:ctor(node)
  super.ctor(self, node)
end

function NormalRedNode:Update(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(self.Node.State)
  end
end

function NormalRedNode:Hide(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(false)
  end
end

return NormalRedNode
