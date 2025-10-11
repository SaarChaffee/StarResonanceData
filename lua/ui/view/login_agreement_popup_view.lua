local UI = Z.UI
local super = require("ui.ui_view_base")
local Login_agreement_popupView = class("Login_agreement_popupView", super)
local SDKHelper = require("common.sdk_helper")

function Login_agreement_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "login_agreement_popup")
end

function Login_agreement_popupView:OnActive()
  self:AddClick(self.uiBinder.btn_confirm, function()
    Z.UIMgr:CloseView("login_agreement_popup")
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.GameContext.QuitGame()
  end)
  self.uiBinder.lab_info:AddListener(function(linkName)
    if linkName and linkName == "contract" then
      Z.SDKWebView.OpenWebView(SDKHelper.GetContractUrlPath(self.viewData.PlatformType), false)
    elseif linkName and linkName == "privacy_guide" then
      Z.SDKWebView.OpenWebView(SDKHelper.GetPrivacyGuideUrlPath(self.viewData.PlatformType), false)
    elseif linkName and linkName == "children_privacy" then
      Z.SDKWebView.OpenWebView(SDKHelper.GetChildrenPrivacyUrlPath(self.viewData.PlatformType), false)
    elseif linkName and linkName == "third_info_share" then
      Z.SDKWebView.OpenWebView(SDKHelper.GetThirdInfoShareUrlPath(self.viewData.PlatformType), false)
    end
  end)
  self.uiBinder.lab_info.text = Lang("AgreementContent")
end

function Login_agreement_popupView:OnDeActive()
  if self.viewData.CloseCallback then
    self.viewData.CloseCallback()
  end
end

function Login_agreement_popupView:OnRefresh()
end

return Login_agreement_popupView
