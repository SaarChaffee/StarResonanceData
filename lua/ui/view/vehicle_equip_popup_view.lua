local UI = Z.UI
local super = require("ui.ui_view_base")
local Vehicle_equip_popupView = class("Vehicle_equip_popupView", super)
local vehicleDefine = require("ui.model.vehicle_define")

function Vehicle_equip_popupView:ctor()
  self.uiBinder = nil
  super.ctor(self, "vehicle_equip_popup")
  self.vehicleVM_ = Z.VMMgr.GetVM("vehicle")
end

function Vehicle_equip_popupView:OnActive()
  self.uiBinder.scenemask:SetSceneMaskByKey(self.SceneMaskKey)
  self:AddAsyncClick(self.uiBinder.btn_cancel, function()
    Z.UIMgr:CloseView(self.ViewConfigKey)
  end)
  self:AddAsyncClick(self.uiBinder.btn_verify, function()
    local isEquip, useType = self.vehicleVM_.IsEquip(self.viewData.vehicleId)
    if isEquip and (useType == vehicleDefine.VehicleUseType.landAndWater or useType == self.selectUseType_) then
      return
    end
    if self.config_.PropertyId[2] == vehicleDefine.VehicleUseType.landAndWater or self.config_.PropertyId[2] == self.selectUseType_ then
      self.vehicleVM_.AsyncTakeOnRide(self.selectUseType_, self.viewData.vehicleId, self.cancelSource:CreateToken())
      Z.UIMgr:CloseView(self.ViewConfigKey)
    else
    end
  end)
  self:AddAsyncClick(self.uiBinder.btn_terrene, function()
    self.selectUseType_ = vehicleDefine.VehicleUseType.land
  end)
  self:AddAsyncClick(self.uiBinder.btn_water, function()
    self.selectUseType_ = vehicleDefine.VehicleUseType.water
  end)
  self.selectUseType_ = vehicleDefine.VehicleUseType.land
  self.config_ = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(self.viewData.vehicleId)
  if self.config_ then
    self.selectUseType_ = self.config_.PropertyId[2]
  end
  local terreneId = self.vehicleVM_.IsTypeEquip(vehicleDefine.VehicleUseType.land)
  if terreneId == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_vehicle_terrene, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_vehicle_terrene, true)
    local tempConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(terreneId)
    self.uiBinder.img_vehicle_terrene:SetImage(tempConfig.Icon)
  end
  local waterId = self.vehicleVM_.IsTypeEquip(vehicleDefine.VehicleUseType.water)
  if waterId == 0 then
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_vehicle_water, false)
  else
    self.uiBinder.Ref:SetVisible(self.uiBinder.img_vehicle_water, true)
    local tempConfig = Z.TableMgr.GetTable("VehicleBaseTableMgr").GetRow(waterId)
    self.uiBinder.img_vehicle_water:SetImage(tempConfig.Icon)
  end
end

function Vehicle_equip_popupView:OnDeActive()
end

function Vehicle_equip_popupView:OnRefresh()
end

return Vehicle_equip_popupView
