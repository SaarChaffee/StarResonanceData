local UI = Z.UI
local super = require("ui.ui_view_base")
local Map_lock_mainView = class("Map_lock_mainView", super)
local mapLockSubView = require("ui/view/map_lock_sub_view")

function Map_lock_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "map_lock_main")
  self.mainUiVM_ = Z.VMMgr.GetVM("mainui")
  self.lockSubView_ = mapLockSubView.new(self)
end

function Map_lock_mainView:OnActive()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, true, self.viewConfigKey)
  Z.EventMgr:Add(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  self.mainUiVM_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, true)
  self.lockSubView_:Active(self.viewData, self.uiBinder.node_sub)
end

function Map_lock_mainView:OnDeActive()
  Z.EventMgr:Dispatch(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, false, self.viewConfigKey)
  Z.EventMgr:Remove(Z.ConstValue.HalfScreenView.HalfScreenIsOpen, self.OnHideHalfScreenView, self)
  self.mainUiVM_.HideMainViewArea(E.MainViewHideStyle.Right, self.viewConfigKey, false)
  self.lockSubView_:DeActive()
end

function Map_lock_mainView:OnHideHalfScreenView(isOpen, viewConfigKey)
  if isOpen and self.viewConfigKey ~= viewConfigKey then
    Z.UIMgr:CloseView(self.viewConfigKey)
  end
end

function Map_lock_mainView:OnRefresh()
end

function Map_lock_mainView:CloseRightSubView()
  Z.UIMgr:CloseView(self.viewConfigKey)
end

return Map_lock_mainView
