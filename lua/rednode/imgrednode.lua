local super = require("rednode.rednode")
local ImgRedNode = class("ImgRedNode", super)

function ImgRedNode:ctor(node)
  super.ctor(self, node)
end

function ImgRedNode:Update(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(self.Node.State)
  end
end

function ImgRedNode:Hide(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(false)
  end
end

return ImgRedNode
