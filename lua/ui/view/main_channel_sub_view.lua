local UI = Z.UI
local super = require("ui.ui_subview_base")
local Main_channel_subView = class("Main_channel_subView", super)
local SDKDefine = require("ui.model.sdk_define")

function Main_channel_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "main_channel_sub", "main/channel/main_channel_sub", UI.ECacheLv.None)
  self.sdkVM_ = Z.VMMgr.GetVM("sdk")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.showBtns_ = {}
end

function Main_channel_subView:OnActive()
  self:initBtn()
  self:initShowBtn()
  self.isShowMore_ = false
  self.showBtns_ = {
    [1] = self.uiBinder.btn_qqprivilege.gameObject,
    [2] = self.uiBinder.btn_wechatprivilege.gameObject,
    [3] = self.uiBinder.btn_qqgift.gameObject,
    [4] = self.uiBinder.btn_qqgamecenter.gameObject,
    [5] = self.uiBinder.btn_supervip.gameObject,
    [6] = self.uiBinder.btn_growth.gameObject,
    [7] = self.uiBinder.btn_arrow.gameObject,
    [8] = self.uiBinder.btn_more.gameObject
  }
  self:refreshMorePanel()
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.initShowBtn, self)
end

function Main_channel_subView:OnDeActive()
  for _, go in ipairs(self.showBtns_) do
    self.uiBinder.group_press_check:RemoveGameObject(go)
  end
  self.uiBinder.group_press_check:StopCheck()
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.initShowBtn, self)
end

function Main_channel_subView:OnRefresh()
end

function Main_channel_subView:initBtn()
  self:AddAsyncClick(self.uiBinder.btn_wechatgift, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Gift)
  end)
  self:AddAsyncClick(self.uiBinder.btn_qqchannel, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Channel)
  end)
  self:AddAsyncClick(self.uiBinder.btn_qqprivilege, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Privilege)
  end)
  self:AddAsyncClick(self.uiBinder.btn_wechatprivilege, function()
    Z.UIMgr:OpenView("common_privilege_popup")
  end)
  self:AddAsyncClick(self.uiBinder.btn_qqgift, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Gift)
  end)
  self:AddAsyncClick(self.uiBinder.btn_qqgamecenter, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.GameCenter)
  end)
  self:AddAsyncClick(self.uiBinder.btn_supervip, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.SuperVip)
  end)
  self:AddAsyncClick(self.uiBinder.btn_growth, function()
    self.sdkVM_.OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Growth, SDKDefine.WEBVIEW_ORIENTATION.Portrait)
  end)
  self:AddAsyncClick(self.uiBinder.btn_arrow, function()
    self.isShowMore_ = false
    self:refreshMorePanel()
  end)
  self:AddAsyncClick(self.uiBinder.btn_more, function()
    self.isShowMore_ = not self.isShowMore_
    self:refreshMorePanel()
  end)
  self:EventAddAsyncListener(self.uiBinder.group_press_check.ContainGoEvent, function(isContain)
    if not isContain then
      self.isShowMore_ = false
      self:refreshMorePanel()
    end
  end, nil, nil)
  self.functionBtns_ = {
    [1] = {
      functionId = E.FunctionID.TencentQQPrivilege,
      btn = self.uiBinder.btn_qqprivilege,
      urlType = SDKDefine.SDK_URL_FUNCTION_TYPE.Privilege
    },
    [2] = {
      functionId = E.FunctionID.TencentWeChatPrivilege,
      btn = self.uiBinder.btn_wechatprivilege
    },
    [3] = {
      functionId = E.FunctionID.TencentQQGift,
      btn = self.uiBinder.btn_qqgift,
      urlType = SDKDefine.SDK_URL_FUNCTION_TYPE.Gift
    },
    [4] = {
      functionId = E.FunctionID.TencentQQGameCenter,
      btn = self.uiBinder.btn_qqgamecenter,
      urlType = SDKDefine.SDK_URL_FUNCTION_TYPE.GameCenter
    },
    [5] = {
      functionId = E.FunctionID.TencentSuperVip,
      btn = self.uiBinder.btn_supervip,
      urlType = SDKDefine.SDK_URL_FUNCTION_TYPE.SuperVip
    },
    [6] = {
      functionId = E.FunctionID.TencentGrowth,
      btn = self.uiBinder.btn_growth,
      urlType = SDKDefine.SDK_URL_FUNCTION_TYPE.Growth
    }
  }
end

function Main_channel_subView:initShowBtn()
  local isShowMoreBtn = false
  local url = self.sdkVM_.GetURL(SDKDefine.SDK_URL_FUNCTION_TYPE.Gift)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_wechatgift, self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatGift) and url ~= nil and url ~= "")
  url = self.sdkVM_.GetURL(SDKDefine.SDK_URL_FUNCTION_TYPE.Channel)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_qqchannel, self.sdkVM_.CheckSDKFunctionCanShow(E.FunctionID.TencentQQChannel) and url ~= nil and url ~= "")
  for _, v in ipairs(self.functionBtns_) do
    local isUrlEmpty = false
    if v.urlType ~= nil then
      url = self.sdkVM_.GetURL(v.urlType)
      if url == nil or url == "" then
        isUrlEmpty = true
      end
    end
    if self.sdkVM_.CheckSDKFunctionCanShow(v.functionId) and not isUrlEmpty then
      self.uiBinder.Ref:SetVisible(v.btn, true)
      isShowMoreBtn = true
    else
      self.uiBinder.Ref:SetVisible(v.btn, false)
    end
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_more, isShowMoreBtn)
end

function Main_channel_subView:refreshMorePanel()
  self.uiBinder.Ref:SetVisible(self.uiBinder.node_more, self.isShowMore_)
  if self.isShowMore_ then
    for _, go in ipairs(self.showBtns_) do
      self.uiBinder.group_press_check:AddGameObject(go)
    end
    self.uiBinder.group_press_check:StartCheck()
  else
    for _, go in ipairs(self.showBtns_) do
      self.uiBinder.group_press_check:RemoveGameObject(go)
    end
    self.uiBinder.group_press_check:StopCheck()
  end
end

return Main_channel_subView
