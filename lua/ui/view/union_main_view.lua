local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_mainView = class("Union_mainView", super)
local homeSubView = require("ui.view.union_homepage_sub_view")
local memberSubView = require("ui.view.union_member_sub_view")
local buildSubView = require("ui.view.union_set_sub_view")
local activeSubView = require("ui.view.union_active_sub_view")
local huntSubView = require("ui.view.union_hunt_sub_view")

function Union_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_main")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.commonVM_ = Z.VMMgr.GetVM("common")
  self.helpsysVM_ = Z.VMMgr.GetVM("helpsys")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.unionTabFunctionIdDict_ = {
    [E.UnionMainTab.Home] = E.UnionFuncId.Main,
    [E.UnionMainTab.Member] = E.UnionFuncId.Member,
    [E.UnionMainTab.Build] = E.UnionFuncId.Build,
    [E.UnionMainTab.Active] = E.UnionFuncId.Active,
    [E.UnionMainTab.Hunt] = E.UnionFuncId.Hunt
  }
  self.unionHelpIdDict_ = {
    [E.UnionMainTab.Home] = 30003,
    [E.UnionMainTab.Member] = 30003,
    [E.UnionMainTab.Build] = E.UnionFuncId.Build,
    [E.UnionMainTab.Active] = E.UnionFuncId.Active,
    [E.UnionMainTab.Hunt] = E.UnionFuncId.Hunt
  }
end

function Union_mainView:initComponent()
  self.unionSubBinderDict_ = {
    [E.UnionMainTab.Home] = self.uiBinder.binder_tab_home,
    [E.UnionMainTab.Member] = self.uiBinder.binder_tab_member,
    [E.UnionMainTab.Build] = self.uiBinder.binder_tab_build,
    [E.UnionMainTab.Active] = self.uiBinder.binder_tab_activity,
    [E.UnionMainTab.Hunt] = self.uiBinder.binder_tab_hunt
  }
  self.unionSubViewDict_ = {
    [E.UnionMainTab.Home] = homeSubView.new(self),
    [E.UnionMainTab.Member] = memberSubView.new(self),
    [E.UnionMainTab.Build] = buildSubView.new(self),
    [E.UnionMainTab.Active] = activeSubView.new(self),
    [E.UnionMainTab.Hunt] = huntSubView.new(self)
  }
  self.unionSubTitleDict_ = {
    [E.UnionMainTab.Home] = self.commonVM_.GetTitleByConfig({
      E.UnionFuncId.Union,
      E.UnionFuncId.Main
    }),
    [E.UnionMainTab.Member] = self.commonVM_.GetTitleByConfig({
      E.UnionFuncId.Union,
      E.UnionFuncId.Member
    }),
    [E.UnionMainTab.Build] = self.commonVM_.GetTitleByConfig({
      E.UnionFuncId.Union,
      E.UnionFuncId.Build
    }),
    [E.UnionMainTab.Active] = self.commonVM_.GetTitleByConfig({
      E.UnionFuncId.Union,
      E.UnionFuncId.Active
    }),
    [E.UnionMainTab.Hunt] = self.commonVM_.GetTitleByConfig({
      E.UnionFuncId.Union,
      E.UnionFuncId.Hunt
    })
  }
  self:AddClick(self.uiBinder.btn_close, function()
    self:OnReturnBtnClick()
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    self:onHelpBtnClick()
  end)
  self:initToggle()
  self:loadUnionRedDotItem()
end

function Union_mainView:initToggle()
  for k, v in pairs(self.unionSubBinderDict_) do
    v.tog_tab_select.group = self.uiBinder.tog_group_tab
    v.tog_tab_select:AddListener(function(isOn)
      if isOn then
        self.commonVM_.CommonPlayTogAnim(v.anim_tog, self.cancelSource:CreateToken())
        local subViewData
        if self.viewData and self.viewData.SubViewData then
          subViewData = self.viewData.SubViewData
        end
        self:switchSubView(k, subViewData)
      end
    end)
    v.tog_tab_select.OnPointClickEvent:AddListener(function()
      local subFuncId = self.unionTabFunctionIdDict_[k]
      local isFuncOpen = self.funcVM_.CheckFuncCanUse(subFuncId)
      v.tog_tab_select.IsToggleCanSwitch = isFuncOpen
    end)
  end
end

function Union_mainView:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Add(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_mainView:unBindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Chat.OpenPrivateChat, self.onOpenPrivateChat, self)
  Z.EventMgr:Remove(Z.ConstValue.Idcard.InviteAction, self.onOpenPrivateChat, self)
end

function Union_mainView:switchOnOpen()
  local subType = E.UnionMainTab.Home
  local subViewData
  if self.viewData and self.viewData.Type then
    subType = self.viewData.Type
    subViewData = self.viewData.SubViewData
  end
  local binder = self.unionSubBinderDict_[subType]
  if binder.tog_tab_select.isOn then
    self:switchSubView(subType, subViewData)
  else
    binder.tog_tab_select.isOn = true
  end
end

function Union_mainView:switchSubView(subType, subViewData)
  if self.curSubType_ and self.curSubType_ == subType then
    return
  end
  self.curSubType_ = subType
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.unionSubViewDict_[subType]
  local subFuncId = self.unionTabFunctionIdDict_[subType]
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig({
    E.UnionFuncId.Union,
    subFuncId
  })
  if self.curSubView_ then
    self.curSubView_:Active(subViewData, self.uiBinder.trans_sub_view_root)
  end
  self.viewData = nil
end

function Union_mainView:OnReturnBtnClick()
  self.unionVM_:CloseUnionMainView()
end

function Union_mainView:onHelpBtnClick()
  if self.curSubType_ == nil then
    return
  end
  local helpId = self.unionHelpIdDict_[self.curSubType_]
  self.helpsysVM_.OpenFullScreenTipsView(helpId)
end

function Union_mainView:onOpenPrivateChat()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

function Union_mainView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self:startAnimatedShow()
  self:initComponent()
  self:bindEvents()
end

function Union_mainView:OnDeActive()
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubType_ = nil
  for k, v in pairs(self.unionSubBinderDict_) do
    v.tog_tab_select:RemoveAllListeners()
  end
  self.unionSubBinderDict_ = nil
  self.unionSubViewDict_ = nil
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self:unBindEvents()
  self:unLoadUnionRedDotItem()
end

function Union_mainView:OnRefresh()
  self:switchOnOpen()
end

function Union_mainView:GetCacheData()
  local viewData = {}
  viewData.Type = self.curSubType_
  return viewData
end

function Union_mainView:startAnimatedShow()
  self.uiBinder.anim_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_mainView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.anim_main.CoroPlay)
  coro(self.uiBinder.anim_main, Z.DOTweenAnimType.Close)
end

function Union_mainView:loadUnionRedDotItem()
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionSceneUnlockRed, self, self.uiBinder.binder_tab_home.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionMemberTab, self, self.uiBinder.binder_tab_member.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionActiveTab, self, self.uiBinder.binder_tab_activity.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionBuildTab, self, self.uiBinder.binder_tab_build.Trans)
  Z.RedPointMgr.LoadRedDotItem(E.RedType.UnionActivity, self, self.uiBinder.binder_tab_hunt.Trans)
end

function Union_mainView:unLoadUnionRedDotItem()
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionSceneUnlockRed)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionMemberTab)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionActiveTab)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionBuildTab)
  Z.RedPointMgr.RemoveNodeItem(E.RedType.UnionActivity)
end

return Union_mainView
