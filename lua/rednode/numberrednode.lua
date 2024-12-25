local super = require("rednode.rednode")
local NumberRednode = class("NumberRednode", super)

function NumberRednode:ctor(node)
  super.ctor(self, node)
end

function NumberRednode:Update(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(self.Node.State)
    redDotItem.lab_red.TMPLab.text = self.Node.Num
  end
end

function NumberRednode:Hide(redDotItem)
  if redDotItem then
    redDotItem:SetVisible(false)
  end
end

return NumberRednode
