local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_set_popupView = class("Union_set_popupView", super)
local nameSubView = require("ui.view.union_set_name_tpl_view")
local iconSubView = require("ui.view.union_set_icon_tpl_view")
local tagSubView = require("ui.view.union_set_label_tpl_view")
local announceSubView = require("ui.view.union_set_bulletin_tpl_view")
local Disabled_Enum = {
  None = 0,
  NoPower = 1,
  NotModify = 2
}

function Union_set_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_set_popup")
  self.unionVM_ = Z.VMMgr.GetVM("union")
  self.unionData_ = Z.DataMgr.Get("union_data")
end

function Union_set_popupView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddClick(self.uiBinder.btn_close, function()
    Z.UIMgr:CloseView(self.viewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_ok, function()
    self:onClickConfirm()
  end)
  self.setSubViewInfoDict_ = {
    [E.UnionSettingSubType.Name] = {
      binder = self.uiBinder.binder_name,
      view = nameSubView.new(self),
      power = E.UnionPowerDef.ModifyName
    },
    [E.UnionSettingSubType.Icon] = {
      binder = self.uiBinder.binder_icon,
      view = iconSubView.new(self),
      power = E.UnionPowerDef.ModifyIcon
    },
    [E.UnionSettingSubType.Tag] = {
      binder = self.uiBinder.binder_tag,
      view = tagSubView.new(self),
      power = E.UnionPowerDef.ModifyTag
    },
    [E.UnionSettingSubType.Picture] = {
      binder = self.uiBinder.binder_picture,
      view = nil,
      power = E.UnionPowerDef.EditAlbum
    },
    [E.UnionSettingSubType.Announce] = {
      binder = self.uiBinder.binder_announce,
      view = announceSubView.new(self),
      power = E.UnionPowerDef.ModifyManifesto
    }
  }
  self:initToggle()
  self:switchOnOpen()
end

function Union_set_popupView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubType_ = nil
  self.setSubViewInfoDict_ = nil
end

function Union_set_popupView:OnRefresh()
end

function Union_set_popupView:initToggle()
  for k, v in pairs(self.setSubViewInfoDict_) do
    v.binder.tog_item.group = self.uiBinder.tog_group_left
    v.binder.tog_item:AddListener(function(isOn)
      if isOn then
        self:switchSubView(k)
      end
    end)
  end
end

function Union_set_popupView:switchOnOpen()
  local subType = E.UnionSettingSubType.Name
  if self.viewData and self.viewData.Type then
    subType = self.viewData.Type
  end
  local binder = self.setSubViewInfoDict_[subType].binder
  if binder.tog_item.isOn then
    self:switchSubView(subType)
  else
    binder.tog_item.isOn = true
  end
end

function Union_set_popupView:switchSubView(subType)
  if self.curSubType_ and self.curSubType_ == subType then
    return
  end
  self.curSubType_ = subType
  self.disableBit_ = Disabled_Enum.None
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.setSubViewInfoDict_[subType].view
  if self.curSubView_ then
    self.curSubView_:Active(nil, self.uiBinder.trans_sub_view_root)
  end
  local power = self.setSubViewInfoDict_[self.curSubType_].power
  self:EnableOrDisableByPower(power)
end

function Union_set_popupView:EnableOrDisableByPower(power)
  local isEnable = self.unionVM_:CheckPlayerPower(power)
  if isEnable then
    self.disableBit_ = self.disableBit_ & ~Disabled_Enum.NoPower
  else
    self.disableBit_ = self.disableBit_ | Disabled_Enum.NoPower
  end
  self.uiBinder.btn_ok.IsDisabled = self.disableBit_ ~= Disabled_Enum.None
end

function Union_set_popupView:EnableOrDisableByModify(isEnable)
  if isEnable then
    self.disableBit_ = self.disableBit_ & ~Disabled_Enum.NotModify
  else
    self.disableBit_ = self.disableBit_ | Disabled_Enum.NotModify
  end
  self.uiBinder.btn_ok.IsDisabled = self.disableBit_ ~= Disabled_Enum.None
end

function Union_set_popupView:onClickConfirm()
  if self.curSubView_ and self.curSubView_.IsActive and self.curSubView_.IsLoaded then
    if self.disableBit_ & Disabled_Enum.NoPower > 0 then
      Z.TipsVM.ShowTipsLang(1000527)
    elseif 0 < self.disableBit_ & Disabled_Enum.NotModify then
      Z.TipsVM.ShowTipsLang(1000548)
    else
      self.curSubView_:onClickConfirm()
    end
  end
end

return Union_set_popupView
