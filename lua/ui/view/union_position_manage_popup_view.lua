local UI = Z.UI
local super = require("ui.ui_view_base")
local Union_position_manage_popupView = class("Union_position_manage_popupView", super)
local positionEditSubView = require("ui.view.union_position_edit_tpl_view")
local memberAppointSubView = require("ui.view.union_member_appoint_tpl_view")
local powerEditSubView = require("ui.view.union_power_edit_tpl_view")

function Union_position_manage_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "union_position_manage_popup")
end

function Union_position_manage_popupView:initComponent()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self.unionSubBinderDict_ = {
    [E.UnionPositionPopupType.PositionEdit] = self.uiBinder.binder_tab_position,
    [E.UnionPositionPopupType.MemberAppoint] = self.uiBinder.binder_tab_appoint,
    [E.UnionPositionPopupType.PowerEdit] = self.uiBinder.binder_tab_power
  }
  self.unionSubViewDict_ = {
    [E.UnionPositionPopupType.PositionEdit] = positionEditSubView.new(self),
    [E.UnionPositionPopupType.MemberAppoint] = memberAppointSubView.new(self),
    [E.UnionPositionPopupType.PowerEdit] = powerEditSubView.new(self)
  }
  self:AddClick(self.uiBinder.btn_close, function()
    self:onCloseBtnClick()
  end)
  self:initToggle()
end

function Union_position_manage_popupView:initData()
  self.curSubType_ = nil
end

function Union_position_manage_popupView:initToggle()
  for k, v in pairs(self.unionSubBinderDict_) do
    v.tog_item.group = self.uiBinder.tog_group_tab
    v.tog_item:AddListener(function(isOn)
      if isOn then
        self:switchSubView(k)
      end
    end)
  end
end

function Union_position_manage_popupView:switchOnOpen()
  local subType = E.UnionPositionPopupType.PositionEdit
  local binder = self.unionSubBinderDict_[subType]
  if binder.tog_item.isOn then
    self:switchSubView(subType)
  else
    binder.tog_item.isOn = true
  end
end

function Union_position_manage_popupView:switchSubView(subType)
  if self.curSubType_ and self.curSubType_ == subType then
    return
  end
  self.curSubType_ = subType
  if self.curSubView_ then
    self.curSubView_:DeActive()
  end
  self.curSubView_ = self.unionSubViewDict_[subType]
  if self.curSubView_ then
    self.curSubView_:Active(nil, self.uiBinder.trans_sub_view_root)
  end
end

function Union_position_manage_popupView:onCloseBtnClick()
  Z.UIMgr:CloseView("union_position_manage_popup")
end

function Union_position_manage_popupView:OnActive()
  self:startAnimatedShow()
  self:initData()
  self:initComponent()
  self:switchOnOpen()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
end

function Union_position_manage_popupView:OnDeActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  if self.curSubView_ then
    self.curSubView_:DeActive()
    self.curSubView_ = nil
  end
  self.curSubType_ = nil
  self.unionSubBinderDict_ = nil
  self.unionSubViewDict_ = nil
end

function Union_position_manage_popupView:startAnimatedShow()
  self.uiBinder.tween_main:Restart(Z.DOTweenAnimType.Open)
end

function Union_position_manage_popupView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.uiBinder.tween_main.CoroPlay)
  coro(self.uiBinder.tween_main, Z.DOTweenAnimType.Close)
end

return Union_position_manage_popupView
