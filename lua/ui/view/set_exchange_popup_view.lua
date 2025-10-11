local UI = Z.UI
local super = require("ui.ui_view_base")
local Set_exchange_popupView = class("Set_exchange_popupView", super)
local charactorProxy = require("zproxy.grpc_charactor_proxy")

function Set_exchange_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "set_exchange_popup")
end

function Set_exchange_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_certain, function()
    if self.strCode_ == nil or self.strCode_ == "" then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_error, true)
      self.uiBinder.lab_error.text = Lang("CdKeyInputEmpty")
      return
    end
    local curTime = Z.TimeTools.Now()
    if self.cdTime_ ~= nil and curTime <= self.cdTime_ then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_error, true)
      self.uiBinder.lab_error.text = Lang("CdKeyCdRequest")
      return
    end
    self.cdTime_ = curTime + Z.Global.CdKeyButtonRequestCd * 1000
    self.uiBinder.Ref:SetVisible(self.uiBinder.lab_error, false)
    local request = {
      cdKey = self.strCode_
    }
    local ret = charactorProxy.TakeAwardByCdKey(request, self.cancelSource:CreateToken())
    if ret ~= 0 then
      self.uiBinder.Ref:SetVisible(self.uiBinder.lab_error, true)
      self.uiBinder.lab_error.text = Lang(Z.PbErrName(ret))
      return
    end
    Z.UIMgr:CloseView(self.ViewConfigKey)
    Z.DialogViewDataMgr:OpenOKDialog(Lang("CdkeySuccess"))
  end)
  self:AddClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_delete, function()
    self.uiBinder.input.text = ""
  end)
  self:AddClick(self.uiBinder.btn_tips, function()
    Z.CommonTipsVM.ShowTipsContent(self.uiBinder.rect_tips, Lang("CdkeyInformationNote"))
  end)
  self.uiBinder.input:AddListener(function(str)
    self.strCode_ = str
    if self.strCode_ == nil or self.strCode_ == "" then
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, false)
    else
      self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, true)
    end
  end)
  self.strCode_ = nil
  self.cdTime_ = nil
  self.uiBinder.input.text = ""
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_delete, false)
  self.uiBinder.Ref:SetVisible(self.uiBinder.lab_error, false)
end

function Set_exchange_popupView:OnDeActive()
  Z.CommonTipsVM.CloseTipsContent()
end

function Set_exchange_popupView:OnRefresh()
end

return Set_exchange_popupView
