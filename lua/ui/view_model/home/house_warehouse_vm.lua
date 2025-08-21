local HouseWarehouseVm = {}
local funcVm = Z.VMMgr.GetVM("gotofunc")
local worldProxy = require("zproxy.world_proxy")

function HouseWarehouseVm.GetWarehouse()
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  Z.CoroUtil.create_coro_xpcall(function()
    HouseWarehouseVm.AsyncGetWarehouse(warehouseData.CancelSource:CreateToken())
  end)()
end

function HouseWarehouseVm.AsyncGetWarehouse(token)
  if not funcVm.CheckFuncCanUse(E.FunctionID.HomeWarehouse, true) then
    return
  end
  local ret = worldProxy.GetHomelandWarehouseInfo({}, token)
  local warehouse
  if ret.errCode == 0 then
    warehouse = ret.warehouse
  end
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  warehouseData:SetWarehouseInfo({
    warehouseGrids = table.zvalues(warehouse.warehouseGrids)
  }, E.WarehouseType.House)
  Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.RefreshWarehouse)
end

function HouseWarehouseVm.AsyncDepositWarehouse(itemUuid, itemNum, token)
  local request = {
    [itemUuid] = itemNum
  }
  local errCode = worldProxy.HomelandWarehouseStore({items = request}, token)
  if errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.DepositWarehouse)
  else
    Z.TipsVM.ShowTips(errCode)
  end
  return errCode
end

function HouseWarehouseVm.AsyncTakeOutWarehouse(gridPos, itemNum, configId, ownerCharId, token)
  local houseData = Z.DataMgr.Get("house_data")
  if not houseData:GetHomeLimit(E.HouseLimitType.WareHouse) and Z.ContainerMgr.CharSerialize.charId ~= ownerCharId then
    Z.TipsVM.ShowTips(1044015)
    return
  end
  local errCode = worldProxy.HomelandWarehouseTakeOut({
    gridPos = gridPos,
    itemNum = itemNum,
    itemCfgId = configId,
    ownerCharId = ownerCharId
  }, token)
  if errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.TakeOutWarehouse)
  else
    Z.TipsVM.ShowTips(errCode)
  end
  return errCode
end

return HouseWarehouseVm
