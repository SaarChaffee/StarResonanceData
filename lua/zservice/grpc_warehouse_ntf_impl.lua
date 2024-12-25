local pb = require("pb2")
local GrpcWarehouseNtfStubImpl = {}

function GrpcWarehouseNtfStubImpl:OnCreateStub()
end

function GrpcWarehouseNtfStubImpl:NotifyWarehouseInvite(call, request)
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  warehouseVm.NotifyWarehouseInvite(request.charId, request.warehouseId)
end

function GrpcWarehouseNtfStubImpl:NotifyWarehouseGridChange(call, request)
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  warehouseVm.WarehouseItemChange(request)
end

function GrpcWarehouseNtfStubImpl:NotifyWarehousePassiveExist(call, request)
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  if request.exitType == Z.PbEnum("WarehouseExitType", "WarehouseExitTypeDisband") then
    Z.TipsVM.ShowTips(122006)
    warehouseVm.ClearWarehouseData()
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.WarehouseExistDisband)
    return
  end
  if request.exitType == Z.PbEnum("WarehouseExitType", "WarehouseExitTypeBeKickOut") then
    if request.charId == Z.ContainerMgr.CharSerialize.charBase.charId then
      Z.TipsVM.ShowTips(122005)
      warehouseVm.ClearWarehouseData()
      Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.WarehouseExistBeKickOut)
    else
      warehouseVm.GetWarehouse()
      Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.MemberChange)
    end
  elseif request.charId ~= Z.ContainerMgr.CharSerialize.charBase.charId then
    warehouseVm.GetWarehouse()
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.MemberChange)
  end
end

function GrpcWarehouseNtfStubImpl:NotifyWarehouseNewJoiner(call, request)
  local warehouseVm = Z.VMMgr.GetVM("warehouse")
  warehouseVm.WarehouseNewJoiner(request.joinCharId)
end

function GrpcWarehouseNtfStubImpl:NotifyWarehouseRefuseToJoin(call, request)
  Z.TipsVM.ShowTips(122009)
end

return GrpcWarehouseNtfStubImpl
