local VehicleVM = {}
local worldProxy = require("zproxy.world_proxy")
local vehicleDefine = require("ui.model.vehicle_define")

function VehicleVM.OpenVehicleMain(vehicleId)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if funcVm.CheckFuncCanUse(E.FunctionID.Vehicle) then
    Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, "vehicle_main", function()
      Z.UIMgr:OpenView("vehicle_main", {vehicleId = vehicleId})
    end, Z.ConstValue.UnrealSceneConfigPaths.Vehicle)
  end
end

function VehicleVM.OpenPopView(vehicleId, type)
  Z.UIMgr:OpenView("vehicle_skill_popup", {vehicleId = vehicleId, type = type})
end

function VehicleVM.OpenEquipPopView(vehicleId, type)
  Z.UIMgr:OpenView("vehicle_equip_popup", {vehicleId = vehicleId, type = type})
end

function VehicleVM.TakeRide()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if funcVm.CheckFuncCanUse(E.FunctionID.VehicleRide) then
    Z.CoroUtil.create_coro_xpcall(function()
      local vehicleData = Z.DataMgr.Get("vehicle_data")
      VehicleVM.StartOrStopRide(vehicleData.CancelSource:CreateToken())
    end)()
  end
end

function VehicleVM.IsEquip(id)
  local isEquip = false
  local type
  for key, value in pairs(Z.ContainerMgr.CharSerialize.rideList.rides) do
    if value.rideId == id then
      if type == nil then
        type = key
      else
        type = vehicleDefine.VehicleUseType.landAndWater
      end
      isEquip = true
    end
  end
  return isEquip, type
end

function VehicleVM.IsTypeEquip(type)
  if Z.ContainerMgr.CharSerialize.rideList.rides and Z.ContainerMgr.CharSerialize.rideList.rides[type] then
    return Z.ContainerMgr.CharSerialize.rideList.rides[type].rideId
  end
  return 0
end

function VehicleVM.IsHaveVehicleEquip()
  if Z.ContainerMgr.CharSerialize.rideList.rides then
    for _, value in pairs(Z.ContainerMgr.CharSerialize.rideList.rides) do
      if value.rideId ~= 0 then
        return true
      end
    end
  end
  return false
end

function VehicleVM.StartOrStopRide(cancelToken)
  if Z.EntityMgr.PlayerEnt:GetLuaRidingId() ~= 0 then
    VehicleVM.StopRide()
  else
    VehicleVM.StartRide(vehicleDefine.VehicleUseType.land, cancelToken)
  end
end

function VehicleVM.CheckIsCanRide(status)
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.CheckFuncCanUse(E.FunctionID.Vehicle) then
    return false
  end
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  if vehicleData.IsSendMessage then
    return false
  end
  if Z.EntityMgr.PlayerEnt:GetLuaRideStage() == vehicleDefine.ERideStage.ERideUp or Z.EntityMgr.PlayerEnt:GetLuaRideStage() == vehicleDefine.ERideStage.ERideDown then
    return false
  end
  if status == Z.EStatusSwitch.RideLandStateDefault then
    local resStatus = Z.StatusSwitchMgr:CheckSwitchEnableWithReason(Z.EStatusSwitch.RideLandStateDefault)
    if resStatus ~= -1 then
      if resStatus == Z.EStatusSwitch.ActorStateSwim then
        Z.TipsVM.ShowTipsLang(1000906)
      else
        Z.TipsVM.ShowTipsLang(1000907)
      end
      return false
    end
  elseif not Z.StatusSwitchMgr:CheckSwitchEnable(status) then
    return false
  end
  return true
end

function VehicleVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function VehicleVM.TakeOnRide(ridetype, id, cancelToken)
  local request = {RideType = ridetype, RideId = id}
  local reply = worldProxy.TakeOnRide(request, cancelToken)
  if VehicleVM.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.Vehicle.EquipVehicle)
    return true
  else
    return false
  end
end

function VehicleVM.TakeOffRide(id, cancelToken)
  local request = {RideId = id}
  local reply = worldProxy.TakeOffRide(request, cancelToken)
  if VehicleVM.CheckReply(reply) then
    Z.EventMgr:Dispatch(Z.ConstValue.Vehicle.UnEquipVehicle)
    return true
  else
    return false
  end
end

function VehicleVM.StartRide(type, cancelToken)
  local vehicleId = VehicleVM.IsTypeEquip(type)
  if vehicleId == 0 then
    Z.TipsVM.ShowTipsLang(1000904)
    return false
  else
    if Z.LuaBridge.CheckVehicleCanSummon(vehicleId) == false then
      Z.TipsVM.ShowTipsLang(1000905)
      return false
    end
    if Z.LuaBridge.CheckCanRideUpInWater(vehicleId) == false then
      Z.TipsVM.ShowTipsLang(1000906)
      return false
    end
  end
  if not VehicleVM.CheckIsCanRide(Z.EStatusSwitch.RideLandStateDefault) then
    return false
  end
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  vehicleData.IsSendMessage = true
  Z.StatusSwitchMgr:SetStateActive(Z.EStatusSwitch.RideRequest, true)
  local request = {
    RideType = vehicleDefine.VehicleUseType.land
  }
  xpcall(function()
    local reply = worldProxy.StartRide(request, cancelToken)
    vehicleData.IsSendMessage = false
    if VehicleVM.CheckReply(reply) then
      return true
    else
      return false
    end
  end, function(error)
    logError(error)
    vehicleData.IsSendMessage = false
  end)
end

function VehicleVM.StopRide()
  if not VehicleVM.CheckIsCanRide(Z.EStatusSwitch.ActorStateDefault) then
    return false
  end
  return true
end

function VehicleVM.ApplyToRide(targetId, cancelToken)
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  vehicleData.IsSendMessage = true
  local request = {targetId = targetId}
  xpcall(function()
    local reply = worldProxy.ApplyToRide(request, cancelToken)
    vehicleData.IsSendMessage = false
    if VehicleVM.CheckReply(reply) then
      return true
    else
      return false
    end
  end, function(error)
    logError(error)
    vehicleData.IsSendMessage = false
  end)
end

function VehicleVM.InviteToRide(inviterId, cancelToken)
  local vehicleData = Z.DataMgr.Get("vehicle_data")
  if vehicleData.IsSendMessage then
    return false
  end
  vehicleData.IsSendMessage = true
  local request = {inviterId = inviterId}
  xpcall(function()
    local reply = worldProxy.InviteToRide(request, cancelToken)
    vehicleData.IsSendMessage = false
    if VehicleVM.CheckReply(reply) then
      return true
    else
      return false
    end
  end, function(error)
    logError(error)
    vehicleData.IsSendMessage = false
  end)
end

function VehicleVM.ApplyToRideResult(vOrigId, result, cancelToken)
  local request = {vOrigId = vOrigId, result = result}
  Z.StatusSwitchMgr:SetStateActive(Z.EStatusSwitch.RideRequest, true)
  local reply = worldProxy.ApplyToRideResult(request, cancelToken)
  if VehicleVM.CheckReply(reply) then
    return true
  else
    return false
  end
end

function VehicleVM.RideReconfirm(charId, cancelSource)
  Z.StatusSwitchMgr:SetStateActive(Z.EStatusSwitch.RideRequest, true)
  local reply = worldProxy.RideReconfirm(charId, cancelSource)
  if VehicleVM.CheckReply(reply) then
    return true
  else
    return false
  end
end

return VehicleVM
