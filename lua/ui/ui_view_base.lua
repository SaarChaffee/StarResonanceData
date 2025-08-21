local super = require("ui.ui_base")
local UIViewBase = class("UIViewBase", super)

function UIViewBase:ctor(viewConfigKey, assetPath, isHavePCUI)
  self.ViewConfigKey = viewConfigKey
  self.ViewConfig = Z.UIConfig[viewConfigKey]
  assetPath = assetPath or self.ViewConfig.PrefabPath
  isHavePCUI = isHavePCUI or self.ViewConfig.IsHavePCUI
  super.ctor(self, viewConfigKey, assetPath, self.ViewConfig.CacheLv, isHavePCUI)
  self.uiLayer = self.ViewConfig.Layer
  self.uiType = self.ViewConfig.ViewType
end

function UIViewBase:SetTransParent()
  Z.UIRoot:SetLayerTrans(self.goObj, self.uiLayer)
  Z.UIRoot:ResetViewTrans(self.goObj)
  Z.UIMgr:UpdateDepth(self.uiLayer)
end

function UIViewBase:GetCaptureScreenType()
  return self.ViewConfig.SceneMaskType
end

function UIViewBase:UpdateAfterVisibleChanged(visible)
  Z.UIMgr:UpdateCameraState()
  Z.UIMgr:UpdateAudioState()
  Z.UIMgr:UpdateMouseVisible()
  if visible then
    Z.GuideEventMgr:onOpenViewEvent(self.ViewConfigKey)
    self:CheckReShowStandaloneView()
  else
    Z.GuideEventMgr:onCloseViewEvent(self.ViewConfigKey)
  end
end

function UIViewBase:SetUIMaskState(state)
  if self.ViewConfig.IsFullScreen or self.ViewConfig.IsUnrealScene or self.ViewConfig.ViewType == Z.UI.EType.Exclusive then
    local dict = Z.UIMgr.UIMaskIgnoreViewDict
    dict[self.viewConfigKey] = state and 1 or 0
    local isShowMask = false
    for key, value in pairs(dict) do
      if 0 < value then
        isShowMask = true
        break
      end
    end
    Z.UIRoot:SetUIMaskState(isShowMask)
  end
end

function UIViewBase:UnLoad()
  super.UnLoad(self)
  Z.UIMgr:UpdateDepth(self.uiLayer)
end

function UIViewBase:SetAsLastSibling()
  super.SetAsLastSibling(self)
  Z.UIMgr:UpdateDepth(self.uiLayer)
end

function UIViewBase:SetAsFirstSibling()
  super.SetAsFirstSibling(self)
  Z.UIMgr:UpdateDepth(self.uiLayer)
end

function UIViewBase:UpdateDepth()
  if not self.IsActive then
    return
  end
  if self.uiBinder then
    local uiDepth = self.uiBinder.Ref.UIComp:GetUIDepth()
    if uiDepth then
      uiDepth:UpdateViewDepth(self.uiLayer)
    end
  elseif self.panel then
    self.panel.Ref.ZUIDepth:UpdateViewDepth(self.uiLayer)
  end
end

function UIViewBase:CustomClose()
end

function UIViewBase:OnInputBack()
  if self.IsResponseInput then
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end
end

function UIViewBase:SetReShowStandaloneView(viewConfigKey)
  if self.uiType ~= Z.UI.EType.Exclusive then
    return
  end
  local view = Z.UIMgr:GetView(viewConfigKey)
  if view and view.uiType == Z.UI.EType.Standalone then
    if view.IsVisible then
      view:Hide()
      if self.waitReShowStandaloneViewDict_ == nil then
        self.waitReShowStandaloneViewDict_ = {}
      end
      self.waitReShowStandaloneViewDict_[viewConfigKey] = true
    end
  else
    Z.UIMgr:CloseView(viewConfigKey)
  end
end

function UIViewBase:CheckReShowStandaloneView()
  if self.uiType ~= Z.UI.EType.Exclusive then
    return
  end
  if self.waitReShowStandaloneViewDict_ == nil then
    return
  end
  for viewConfigKey, _ in pairs(self.waitReShowStandaloneViewDict_) do
    local view = Z.UIMgr:GetView(viewConfigKey)
    if view then
      view:SetAsLastSibling()
      view:Show()
    end
    self.waitReShowStandaloneViewDict_[viewConfigKey] = nil
  end
end

function UIViewBase:ClearReShowStandaloneDict()
  if self.uiType ~= Z.UI.EType.Exclusive then
    return
  end
  if self.waitReShowStandaloneViewDict_ then
    for viewConfigKey, _ in pairs(self.waitReShowStandaloneViewDict_) do
      Z.UIMgr:CloseView(viewConfigKey)
    end
  end
  self.waitReShowStandaloneViewDict_ = nil
end

function UIViewBase:checkViewLayerVisible()
  return Z.UIRoot:GetLayerVisible(self.uiLayer)
end

return UIViewBase
