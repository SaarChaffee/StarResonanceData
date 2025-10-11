local super = require("ui.player_ctrl_btns.player_ctrl_btn_base")
local RideCtrlBtn = class("RideCtrlBtn", super)

function RideCtrlBtn:ctor(key, panel)
  self.uiBinder = nil
  super.ctor(self, key, panel)
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.mainUiVm_ = Z.VMMgr.GetVM("mainui")
end

function RideCtrlBtn:GetUIUnitPath()
  local path = "ui/prefabs/controller/controller_ride_ctrl_btn_tpl"
  return path
end

function RideCtrlBtn:OnActive()
  self.uiBinder.touch_area.onDown:AddListener(function()
    self.uiBinder.effect_click:SetEffectGoVisible(false)
    self.uiBinder.effect_click:SetEffectGoVisible(true)
    self.funcVM_.GoToFunc(E.FunctionID.VehicleRide)
  end)
  self:refreshRidingBtn()
  self:bindEvents()
  self:checkRideUnlock()
end

function RideCtrlBtn:checkRideUnlock()
  local isFuncOpen = self.funcVM_.FuncIsOn(E.FunctionID.VehicleRide, true)
  local isFuncShow = self.mainUiVm_.CheckFunctionCanShowInScene(E.FunctionID.VehicleRide)
  if not isFuncOpen or not isFuncShow then
    self.uiBinder.Ref.UIComp:SetVisible(false)
    return
  end
  self.uiBinder.Ref.UIComp:SetVisible(true)
end

function RideCtrlBtn:bindEvents()
  Z.EventMgr:Add(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtn, self)
  Z.EventMgr:Add(Z.ConstValue.OnAttrIsCantRideChange, self.refreshRidingBtn, self)
  Z.EventMgr:Add(Z.ConstValue.RefreshFunctionBtnState, self.checkRideUnlock, self)
  Z.EventMgr:Add(Z.ConstValue.VisualLayerChange, self.checkRideUnlock, self)
  self.playerStateWatcher = Z.DIServiceMgr.PlayerAttrStateComponentWatcherService:OnLocalAttrStateChanged(function()
    self:refreshRidingBtn()
  end)
end

function RideCtrlBtn:refreshRidingBtn()
  local rideId = 0
  if Z.EntityMgr.PlayerEnt then
    rideId = Z.EntityMgr.PlayerEnt:GetLuaRidingId()
  end
  if rideId ~= 0 then
    self.uiBinder.btn_icon:SetImage(Z.ConstValue.MainUI.DownVehicleIcon)
  else
    self.uiBinder.btn_icon:SetImage(Z.ConstValue.MainUI.UpVehicleIcon)
  end
end

function RideCtrlBtn:OnDeActive()
  self.uiBinder.touch_area.onDown:RemoveAllListeners()
  self.uiBinder.effect_click:SetEffectGoVisible(false)
  self:unbindEvents()
end

function RideCtrlBtn:unbindEvents()
  Z.EventMgr:Remove(Z.ConstValue.Vehicle.UpdateRiding, self.refreshRidingBtn, self)
  Z.EventMgr:Remove(Z.ConstValue.OnAttrIsCantRideChange, self.refreshRidingBtn, self)
  Z.EventMgr:Remove(Z.ConstValue.RefreshFunctionBtnState, self.checkRideUnlock, self)
  Z.EventMgr:Remove(Z.ConstValue.VisualLayerChange, self.checkRideUnlock, self)
  if self.playerStateWatcher ~= nil then
    self.playerStateWatcher:Dispose()
    self.playerStateWatcher = nil
  end
end

return RideCtrlBtn
