local UI = Z.UI
local super = require("ui.ui_view_base")
local Gm_mainView = class("Gm_mainView", super)
local mainuiVm_ = Z.VMMgr.GetVM("mainui")

function Gm_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "gm_main")
end

function Gm_mainView:OnActive()
  if Z.IsBlockGM then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gm, false)
  elseif Z.IsHideGM then
    self.uiBinder.btn_gm_canvas.alpha = 0
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gm, true)
  end
  if Z.IsBlockBUGReport then
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_bugreport, false)
  elseif Z.IsHideBUGReport then
    self.uiBinder.btn_bugreport_canvas.alpha = 0
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.btn_bugreport, true)
  end
  self:AddAsyncClick(self.uiBinder.btn_bugreport, function()
    if not self.dragGmBugBtn_ then
      mainuiVm_.OpenBugReport()
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_gm, function()
    if not self.dragbtn_gm_ then
      local isActive = Z.UIMgr:IsActive("gm")
      if isActive then
        Z.UIMgr:CloseView("gm")
      else
        mainuiVm_.OpenGmView()
      end
    end
  end)
  self.uiBinder.btn_gm_event.onDrag:AddListener(function(go, pointerData)
    self.dragbtn_gm_ = true
    local pos = self.uiBinder.btn_gm_ref.localPosition
    self.uiBinder.btn_gm_ref:SetLocalPos(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
  end)
  self.uiBinder.btn_gm_event.onEndDrag:AddListener(function(go, pointerData)
    self.dragbtn_gm_ = false
  end)
  self.uiBinder.btn_bugreport_event.onEndDrag:AddListener(function(go, pointerData)
    self.dragGmBugBtn_ = false
  end)
  self.uiBinder.btn_bugreport_event.onDrag:AddListener(function(go, pointerData)
    self.dragGmBugBtn_ = true
    local pos = self.uiBinder.btn_bugreport_ref.localPosition
    self.uiBinder.btn_bugreport_ref:SetLocalPos(pos.x + pointerData.delta.x, pos.y + pointerData.delta.y)
  end)
  self:BindEvents()
end

function Gm_mainView:OnDeActive()
end

function Gm_mainView:isOpenBug(isOpen)
  if Z.IsBlockGM or Z.IsHideGM then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_bugreport, isOpen)
end

function Gm_mainView:isOpenGm(isOpen)
  if Z.IsBlockBUGReport or Z.IsHideBUGReport then
    return
  end
  self.uiBinder.Ref:SetVisible(self.uiBinder.btn_gm, isOpen)
end

function Gm_mainView:BindEvents()
  Z.EventMgr:Add(Z.ConstValue.GM.IsOpenGm, self.isOpenGm, self)
  Z.EventMgr:Add(Z.ConstValue.GM.IsOpenBug, self.isOpenBug, self)
end

function Gm_mainView:OnRefresh()
end

return Gm_mainView
