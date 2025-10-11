local UI = Z.UI
local super = require("ui.ui_view_base")
local Pandora_common_popupView = class("Pandora_common_popupView", super)

function Pandora_common_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "pandora_common_popup")
  self.pandoraVM_ = Z.VMMgr.GetVM("pandora")
  self.pandoraData_ = Z.DataMgr.Get("pandora_data")
end

function Pandora_common_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.curAppId_ = self.viewData.AppId
  self.uiLayer = self.viewData.Layer
  self:SetPopupLayer()
  self:SetSDKLayer()
end

function Pandora_common_popupView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curAppId_ ~= nil and self.curAppId_ ~= "" then
    self.pandoraVM_:ClosePandoraAppByAppId(self.curAppId_)
  end
end

function Pandora_common_popupView:OnRefresh()
end

function Pandora_common_popupView:SetPopupLayer()
  self:SetTransParent()
end

function Pandora_common_popupView:SetSDKLayer()
  local goSDK = self.pandoraData_:GetAppResource(self.curAppId_)
  if goSDK == nil then
    return
  end
  Z.UIRoot:SetLayerTrans(goSDK, self.uiLayer)
  Panda.Utility.ZLayerUtils.SetLayerRecursive(goSDK.transform, Panda.Utility.ZLayerUtils.LAYER_UI)
  Z.UIRoot:ResetSubViewTrans(goSDK, self.uiBinder.Trans)
end

function Pandora_common_popupView:OnInputBack()
  self.pandoraData_.PopupQueryTagOnClose = true
  Z.UIMgr:CloseView(self.ViewConfigKey)
end

return Pandora_common_popupView
