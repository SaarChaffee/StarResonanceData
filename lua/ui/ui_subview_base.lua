local super = require("ui.ui_base")
local UISubViewBase = class("UISubViewBase", super)

function UISubViewBase:ctor(viewConfigKey, assetPath, cacheLv, isHavePCUI)
  super.ctor(self, viewConfigKey, assetPath, cacheLv, isHavePCUI)
end

function UISubViewBase:SetTransParent(parentTran, baseViewBinder)
  if parentTran == nil or self.goObj == nil then
    return
  end
  Z.UIRoot:ResetSubViewTrans(self.goObj, parentTran)
  if self.uiBinder then
    local uiDepth = self.uiBinder.Ref.UIComp:GetUIDepth()
    if uiDepth then
      if baseViewBinder then
        uiDepth:RegisterToParentDepthByTransfrom(baseViewBinder.Trans)
      else
        uiDepth:RegisterToParentDepthByTransfrom(parentTran)
      end
    end
  elseif self.panel then
    self.panel.Ref.ZUIDepth:RegisterToParentDepthByTransfrom(self.parentTrans)
  end
end

function UISubViewBase:UnLoad()
  if self.uiBinder then
    local uiDepth = self.uiBinder.Ref.UIComp:GetUIDepth()
    if uiDepth then
      uiDepth:UnRegisterFromParentDepth()
    end
  elseif self.panel then
    self.panel.Ref.ZUIDepth:UnRegisterFromParentDepth()
  end
  super.UnLoad(self)
end

function UISubViewBase:checkViewLayerVisible()
  return true
end

return UISubViewBase
