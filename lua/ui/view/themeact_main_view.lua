local UI = Z.UI
local super = require("ui.ui_view_base")
local Themeact_mainView = class("Themeact_mainView", super)
local themeact_sub_view = require("ui.view.themeact_sub_view")
local pandora_activity_sub_view = require("ui.view.pandora_activity_sub_view")
local PANDORA_DEFINE = require("ui.model.pandora_define")

function Themeact_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "themeact_main")
end

function Themeact_mainView:OnActive()
  self:bindEvents()
  self:initData()
  self:initComponent()
  self:switchOnOpen()
end

function Themeact_mainView:OnDeActive()
  self:unBindEvents()
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubType_ = nil
  for k, v in pairs(self.themeBinderDict_) do
    v.tog_item:RemoveAllListeners()
    Z.RedPointMgr.RemoveNodeItem(self.themeRedDotDict_[k])
  end
  self.themeBinderDict_ = nil
  self.themeSubViewDict_ = nil
end

function Themeact_mainView:OnRefresh()
end

function Themeact_mainView:initData()
  self.pandoraData_ = Z.DataMgr.Get("pandora_data")
  self.pandoraVM_ = Z.VMMgr.GetVM("pandora")
  self.commonVM_ = Z.VMMgr.GetVM("common")
end

function Themeact_mainView:initComponent()
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddClick(self.uiBinder.btn_ask, function()
    if self.curSubView_ and self.curSubView_.OnAskBtnClick then
      self.curSubView_:OnAskBtnClick()
    end
  end)
  self.themeSubViewDict_ = {
    [E.ThemeActivitySubType.SeasonActivity] = themeact_sub_view.new(self),
    [E.ThemeActivitySubType.PandoraActivity] = pandora_activity_sub_view.new(self)
  }
  self.themeBinderDict_ = {
    [E.ThemeActivitySubType.SeasonActivity] = self.uiBinder.binder_activity,
    [E.ThemeActivitySubType.PandoraActivity] = self.uiBinder.binder_recommend
  }
  self.themeRedDotDict_ = {
    [E.ThemeActivitySubType.SeasonActivity] = E.RedType.ThemePlayActivity,
    [E.ThemeActivitySubType.PandoraActivity] = E.RedType.ThemePlayPandora
  }
  self:initToggle()
  self:ShowOrHideAskBtn(false)
  self.uiBinder.lab_title.text = self.commonVM_.GetTitleByConfig(E.FunctionID.ThemePlay)
end

function Themeact_mainView:initToggle()
  for k, v in pairs(self.themeBinderDict_) do
    v.tog_item.group = self.uiBinder.tog_group
    v.tog_item:AddListener(function(isOn)
      if isOn then
        self:switchSubView(k, self.viewData)
      end
    end)
    Z.RedPointMgr.LoadRedDotItem(self.themeRedDotDict_[k], self, v.Trans)
  end
  self:refreshPandoraTog()
end

function Themeact_mainView:refreshPandoraTog()
  local appName = self.pandoraData_:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Activity)
  local isShow = self.pandoraData_:IsResourceReady(appName)
  local binder = self.themeBinderDict_[E.ThemeActivitySubType.PandoraActivity]
  self:SetUIVisible(binder.Ref, isShow)
end

function Themeact_mainView:bindEvents()
  Z.EventMgr:Add(PANDORA_DEFINE.EventName.ResourceReady, self.onPandoraResourceReady, self)
end

function Themeact_mainView:unBindEvents()
  Z.EventMgr:Remove(PANDORA_DEFINE.EventName.ResourceReady, self.onPandoraResourceReady, self)
end

function Themeact_mainView:switchOnOpen()
  local subType = E.ThemeActivitySubType.SeasonActivity
  if self.viewData ~= nil and self.viewData.Type ~= nil then
    subType = self.viewData.Type
  end
  local binder = self.themeBinderDict_[subType]
  if binder.tog_item.isOn then
    self:switchSubView(subType, self.viewData)
  else
    binder.tog_item.isOn = true
  end
end

function Themeact_mainView:switchSubView(subType, subViewData)
  if self.curSubType_ and self.curSubType_ == subType then
    return
  end
  self.curSubType_ = subType
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self:ShowOrHideAskBtn(false)
  end
  self.curSubView_ = self.themeSubViewDict_[subType]
  if self.curSubView_ then
    self.curSubView_:Active(subViewData, self.uiBinder.node_sub)
  end
  self.viewData = nil
end

function Themeact_mainView:onPandoraResourceReady(appName)
  local activityAppName = self.pandoraData_:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Activity)
  if appName and appName == activityAppName then
    self:refreshPandoraTog()
  end
end

function Themeact_mainView:ShowOrHideAskBtn(visible)
  self:SetUIVisible(self.uiBinder.btn_ask, visible)
end

function Themeact_mainView:GetCacheData()
  return {
    Type = self.curSubType_,
    ActivityId = self.curSubView_:GetActivityId()
  }
end

return Themeact_mainView
