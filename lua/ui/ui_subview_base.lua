local super = require("ui.ui_base")
local UISubViewBase = class("UISubViewBase", super)

function UISubViewBase:ctor(viewConfigKey, assetPath, cacheLv)
  super.ctor(self, viewConfigKey, assetPath, cacheLv)
end

function UISubViewBase:SetTransParent(parentTran, baseViewBinder)
  if parentTran == nil or self.goObj == nil then
    return
  end
  Z.UIRoot:ResetSubViewTrans(self.goObj, parentTran)
  if self.uiBinder then
    if baseViewBinder then
      self.uiBinder.Ref.UIComp.UIDepth:RegisterToParentDepthByTransfrom(baseViewBinder.Trans)
    else
      self.uiBinder.Ref.UIComp.UIDepth:RegisterToParentDepthByTransfrom(parentTran)
    end
  elseif self.panel then
    self.panel.Ref.ZUIDepth:RegisterToParentDepthByTransfrom(self.parentTrans)
  end
end

function UISubViewBase:UnLoad()
  if self.uiBinder then
    self.uiBinder.Ref.UIComp.UIDepth:UnRegisterFromParentDepth()
  elseif self.panel then
    self.panel.Ref.ZUIDepth:UnRegisterFromParentDepth()
  end
  super.UnLoad(self)
end

return UISubViewBase
