local UI = Z.UI
local super = require("ui.ui_view_base")
local SettingView = class("SettingView", super)

function SettingView:ctor()
  self.uiBinder = nil
  super.ctor(self, "setting")
  self.controlView_ = require("ui/view/set_control_sub_view").new()
  self.baseModuleView = require("ui/view/basemodule_view").new()
  self.accountModuleView = require("ui/view/accountmodule_view").new()
  self.qualityView_ = require("ui/view/set_definition_sub_view").new()
  self.viewDict_ = {
    [E.SetFuncId.SettingControl] = self.controlView_,
    [E.SetFuncId.SettingBasic] = self.baseModuleView,
    [E.SetFuncId.SettingAccount] = self.accountModuleView,
    [E.SetFuncId.SettingFrame] = self.qualityView_
  }
  if Z.IsPCUI then
    self.keyView_ = require("ui/view/set_key_sub_view").new(self)
    self.viewDict_[E.SetFuncId.SettingKey] = self.keyView_
  end
  self.vm = Z.VMMgr.GetVM("setting")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.switchVm_ = Z.VMMgr.GetVM("switch")
  self.userSupportVM_ = Z.VMMgr.GetVM("user_support")
  self:CheckFuncSwitch()
end

function SettingView:CheckFuncSwitch()
  for funcId, _ in pairs(self.viewDict_) do
    if not self.switchVm_.CheckFuncSwitch(funcId) then
      self.viewDict_[funcId] = nil
    end
  end
end

function SettingView:OnActive()
  self:startAnimatedShow()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:AddClick(self.uiBinder.cont_title_return.btn, function()
    self.vm.CloseSettingView()
  end)
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_service, self.userSupportVM_.CheckValid(E.UserSupportType.Setting))
  local serviceIcon = self.userSupportVM_.GetUserSupportIcon(E.UserSupportType.Setting)
  if serviceIcon and serviceIcon ~= "" then
    self.uiBinder.img_service:SetImage(serviceIcon)
  end
  self:AddClick(self.uiBinder.btn_service, function()
    self.userSupportVM_.OpenUserSupportWebView(E.UserSupportType.Setting)
  end)
  
  function self.onLanguageChange_()
    self:onLanguageChange()
  end
  
  self:initTitleDict()
  self:initTab()
  self:BindEvents()
end

function SettingView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubViewFuncId_ then
    self.viewDict_[self.curSubViewFuncId_]:DeActive()
  end
  self.uiBinder.Ref.UIComp.UIDepth:RemoveChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(false)
  self.titleDict_ = nil
  self.togDict_ = nil
  Z.LocalUserDataMgr.Save()
end

function SettingView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange_, self)
end

function SettingView:initTitleDict()
  self.titleDict_ = {}
  for funcId, _ in pairs(self.viewDict_) do
    self.titleDict_[funcId] = self.commonVM_.GetTitleByConfig({
      E.SetFuncId.Setting,
      funcId
    })
  end
end

function SettingView:initTab()
  self.togDict_ = {
    [E.SetFuncId.SettingControl] = self.uiBinder.cont_tab.binder_tab_control,
    [E.SetFuncId.SettingFrame] = self.uiBinder.cont_tab.binder_tab_frame,
    [E.SetFuncId.SettingBasic] = self.uiBinder.cont_tab.binder_tab_basic,
    [E.SetFuncId.SettingAccount] = self.uiBinder.cont_tab.binder_tab_account,
    [E.SetFuncId.SettingKey] = self.uiBinder.cont_tab.binder_tab_key
  }
  for funcId, _ in pairs(self.togDict_) do
    if self.viewDict_[funcId] == nil then
      self.uiBinder.cont_tab.Ref:SetVisible(self.togDict_[funcId].Ref, false)
      self.togDict_[funcId] = nil
    end
  end
  if self.viewData and self.viewData.showFuncs ~= nil then
    for funcId, _ in pairs(self.togDict_) do
      if not table.zcontains(self.viewData.showFuncs, funcId) then
        self.uiBinder.cont_tab.Ref:SetVisible(self.togDict_[funcId].Ref, false)
        self.togDict_[funcId] = nil
      end
    end
  end
  for funcId, item in pairs(self.togDict_) do
    item.tog_tab_select.group = self.uiBinder.cont_tab.layout_tab
    self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(item.eff_root)
    item.tog_tab_select:AddListener(function(isOn)
      self.commonVM_.CommonPlayTogAnim(item.anim_tog, self.cancelSource:CreateToken())
      if isOn then
        self:onChangeSubView(funcId)
        self:onPlayAnim()
      end
    end)
  end
  local firstSub = -1
  if self.viewData and self.viewData.firstFunc then
    firstSub = self.viewData.firstFunc
  else
    for key, _ in pairs(self.togDict_) do
      if firstSub == -1 or key < firstSub then
        firstSub = key
      end
    end
  end
  self.togDict_[firstSub].tog_tab_select.isOn = false
  self.togDict_[firstSub].tog_tab_select.isOn = true
end

function SettingView:onChangeSubView(funcId)
  if self.curSubViewFuncId_ then
    self.viewDict_[self.curSubViewFuncId_]:DeActive()
  end
  self.curSubViewFuncId_ = funcId
  local view = self.viewDict_[funcId]
  if view then
    self.uiBinder.cont_title_return.lab_title.text = self.titleDict_[funcId]
    view:Active({
      parentView = self,
      isLogin = self.viewData and self.viewData.showFuncs ~= nil
    }, self.uiBinder.node_subview)
  end
end

function SettingView:onLanguageChange()
  self:initTitleDict()
  self.uiBinder.cont_title_return.lab_title.text = self.titleDict_[self.curSubViewFuncId_]
end

function SettingView:RefreshSubView(type)
  self:onChangeSubView(type)
end

function SettingView:onPlayAnim()
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Tween_0)
end

function SettingView:startAnimatedShow()
  self.uiBinder.Ref.UIComp.UIDepth:AddChildDepth(self.uiBinder.node_loop_eff)
  self.uiBinder.node_loop_eff:SetEffectGoVisible(true)
  self.uiBinder.anim:Restart(Z.DOTweenAnimType.Open)
end

function SettingView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim.CoroPlay)
  coro(self.uiBinder.anim.TweenContainer, Panda.ZUi.DOTweenAnimType.Close)
end

return SettingView
