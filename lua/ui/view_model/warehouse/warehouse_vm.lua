local WarehouseVm = {}
local worldProxy = require("zproxy.world_proxy")
local funcVm = Z.VMMgr.GetVM("gotofunc")
local socialVM = Z.VMMgr.GetVM("social")

function WarehouseVm.OpenWareView(param)
  local type = E.WarehouseType.Normal
  if param then
    type = tonumber(param) or E.WarehouseType.Normal
  end
  local functionId = E.FunctionID.Warehouse
  if type == E.WarehouseType.House then
    functionId = E.FunctionID.HomeWarehouse
  end
  if funcVm.CheckFuncCanUse(functionId) then
    Z.UIMgr:OpenView("warehouse_main", type)
  end
end

function WarehouseVm.CloseWareView()
  Z.UIMgr:CloseView("warehouse_main")
end

function WarehouseVm.OpenWareMmberPopupView()
  Z.UIMgr:OpenView("warehouse_popup")
end

function WarehouseVm.CloseWareMmberPopupView()
  Z.UIMgr:CloseView("warehouse_popup")
end

function WarehouseVm.OpenItemPopupView()
end

function WarehouseVm.sortWarehouseType(data)
  if data == nil then
    return
  end
  table.sort(data, function(a, b)
    if a == -1 then
      return true
    end
    if b == -1 then
      return false
    end
    return a < b
  end)
end

function WarehouseVm.GetAllWarehouseCfgData()
  local warehouseItems = {}
  local itemData = Z.DataMgr.Get("items_data")
  for key, itemRow in pairs(itemData.ItemTableDatas) do
    if #itemRow.Warehouse > 0 then
      local type = itemRow.Warehouse[1]
      if warehouseItems[type] == nil then
        warehouseItems[type] = {}
      end
      warehouseItems[type][#warehouseItems[type] + 1] = {
        configId = itemRow.Id
      }
    end
  end
  local tabs = {
    [E.WarehouseType.Normal] = {-1},
    [E.WarehouseType.House] = {-1}
  }
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  for key, value in pairs(warehouseData.WarehouseTableDatas) do
    if value.IsShow then
      if value.DepositCount ~= 0 then
        local data = tabs[E.WarehouseType.Normal]
        data[#data + 1] = value.Id
      end
      if value.HomeDepositCount ~= 0 then
        local data = tabs[E.WarehouseType.House]
        data[#data + 1] = value.Id
      end
    end
  end
  WarehouseVm.sortWarehouseType(tabs[E.WarehouseType.Normal])
  WarehouseVm.sortWarehouseType(tabs[E.WarehouseType.House])
  warehouseData:SetWarehouseType(tabs)
  warehouseData:SetWarehouseCfgData(warehouseItems)
end

function WarehouseVm.CheckItemIsWarehouseType(configId, warehouseItemtype)
  if configId == 0 or configId == nil then
    return false
  end
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemRow and 0 < #itemRow.Warehouse then
    local type = itemRow.Warehouse[1]
    if warehouseItemtype == -1 then
      return true
    end
    if type == warehouseItemtype then
      return true
    end
  end
  return false
end

function WarehouseVm.GetBagItemsByType(itemType)
  local tab = {}
  local itemPackages = {}
  local packages = Z.ContainerMgr.CharSerialize.itemPackage.packages
  local noBindItems = {}
  for packageType, package in pairs(packages) do
    if itemPackages[packageType] == nil then
      itemPackages[packageType] = {}
    end
    if noBindItems[packageType] == nil then
      noBindItems[packageType] = {}
    end
    for _, item in pairs(package.items) do
      local isWarehouseType = WarehouseVm.CheckItemIsWarehouseType(item.configId, itemType)
      if isWarehouseType then
        if item.bindFlag == 1 then
          noBindItems[packageType][#noBindItems[packageType] + 1] = item
        else
          itemPackages[packageType][#itemPackages[packageType] + 1] = item
        end
      end
    end
  end
  for packageType, items in pairs(noBindItems) do
    table.zmerge(tab, WarehouseVm.sortItem(packageType, items))
  end
  for packageType, items in pairs(itemPackages) do
    table.zmerge(tab, WarehouseVm.sortItem(packageType, items))
  end
  return tab
end

function WarehouseVm.sortItem(packageType, items)
  local itemSortVm = Z.VMMgr.GetVM("item_sort_factory")
  local data = {}
  data.equipSortType = E.EquipItemSortType.Quality
  data.isAscending = false
  data.sortType = E.EquipItemSortType.Quality
  local sortFunc = itemSortVm.GetItemSortFunc(packageType, data)
  table.sort(items, function(item1, item2)
    local leftItem = {
      itemUuid = item1.uuid,
      configId = item1.configId
    }
    local rightItem = {
      itemUuid = item2.uuid,
      configId = item2.configId
    }
    return sortFunc(leftItem, rightItem)
  end)
  return items
end

function WarehouseVm.CheckIsWarehouseMember(memIdList, charId)
  if not memIdList or not charId then
    return true
  end
  for index, value in ipairs(memIdList) do
    if value == charId then
      return true
    end
  end
  return false
end

function WarehouseVm.GetWarehouseItemsByType(warehouseItemType, warehouseType)
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local tab = {}
  local warehouseInfo = warehouseData:GetWarehouseInfo(warehouseType)
  if warehouseInfo and warehouseInfo.warehouseGrids then
    local index = 1
    for _, value in pairs(warehouseInfo.warehouseGrids) do
      local isWarehouseType = WarehouseVm.CheckItemIsWarehouseType(value.itemInfo.configId, warehouseItemType)
      if isWarehouseType and WarehouseVm.CheckIsWarehouseMember(warehouseInfo.memIdList, value.ownerCharId) then
        tab[index] = value
        index = index + 1
      end
    end
  end
  local itemSortVm = Z.VMMgr.GetVM("item_sort_factory")
  table.sort(tab, function(item1, item2)
    return itemSortVm.DefaultSendAwardSort(item1.itemInfo.configId, item2.itemInfo.configId)
  end)
  tab = table.zreverse(tab)
  return tab
end

function WarehouseVm.CheckItemIsGotoWarehouse(item)
  if item.bindFlag == 0 then
    return false
  end
  return WarehouseVm.CheckConfigIdIsGotoWarehouse(item.configId)
end

function WarehouseVm.CheckConfigIdIsGotoWarehouse(configId)
  local warehouse = WarehouseVm.GetItemConfigWarehouse(configId)
  if warehouse ~= nil and 0 < #warehouse then
    return true
  end
  return false
end

function WarehouseVm.applyCaptainCall(parm, isAgree)
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  Z.CoroUtil.create_coro_xpcall(function()
    WarehouseVm.AsyncReBeInitiateWarehouse(parm.warehouseId, parm.charId, isAgree, warehouseData.CancelSource:CreateToken())
  end)()
end

function WarehouseVm.NotifyWarehouseInvite(charId, warehouseId)
  local info = {
    charId = charId,
    tipsType = E.InvitationTipsType.Warehouse,
    content = Lang("InviteJoinWarehouse"),
    func = WarehouseVm.applyCaptainCall,
    cd = Z.Global.TeamApplyCaptainLastTime,
    funcParam = {charId = charId, warehouseId = warehouseId},
    isCallFailFunc = true
  }
  Z.EventMgr:Dispatch(Z.ConstValue.InvitationRefreshTips, info)
end

function WarehouseVm.WarehouseNewJoiner(charId)
  Z.CoroUtil.create_coro_xpcall(function()
    local warehouseData = Z.DataMgr.Get("warehouse_data")
    local warehouseInfo = warehouseData:GetWarehouseInfo(E.WarehouseType.Normal)
    if warehouseInfo then
      local socialData = socialVM.AsyncGetSocialData(0, charId, warehouseData.CancelSource:CreateToken())
      if socialData then
        local player = {
          name = socialData.basicData.name
        }
        Z.TipsVM.ShowTips(122007, {player = player})
      end
      table.insert(warehouseInfo.memIdList, charId)
      Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.MemberChange)
    end
  end)()
end

function WarehouseVm.GetItemCountAndCurCountByConfigId(configId)
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local warehouseInfo = warehouseData:GetWarehouseInfo()
  local count = 0
  local curCount = 0
  if warehouseInfo and warehouseInfo.warehouseGrids then
    for index, value in ipairs(warehouseInfo.warehouseGrids) do
      if value.itemInfo.configId == configId then
        count = count + value.itemInfo.count
        if value.ownerCharId == Z.ContainerMgr.CharSerialize.charBase.charId then
          curCount = curCount + value.itemInfo.count
        end
      end
    end
  end
  return count, curCount
end

function WarehouseVm.GetItemConfigWarehouse(configId)
  local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId)
  if itemRow then
    return itemRow.Warehouse
  end
end

function WarehouseVm.ClearWarehouseData()
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  if Z.EntityMgr.PlayerEnt then
    Z.EntityMgr.PlayerEnt:SetLuaLongAttr(Z.LocalAttr.EWarehouseId, 0)
  end
  warehouseData:SetWarehouseInfo({})
end

function WarehouseVm.GetResidueDepositCountByType(type, warehouseType)
  local warehouseTableRow = Z.TableMgr.GetTable("WarehouseTableMgr").GetRow(type)
  if warehouseTableRow then
    if warehouseType == E.WarehouseType.House then
      return Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.HomeDepositCount)
    else
      return Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.DepositCount)
    end
  end
  return 0
end

function WarehouseVm.GetResidueTakeCountByType(type, warehouseType)
  local warehouseTableRow = Z.TableMgr.GetTable("WarehouseTableMgr").GetRow(type)
  if warehouseTableRow then
    if warehouseType == E.WarehouseType.House then
      return Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.HomeTakeCount)
    else
      return Z.CounterHelper.GetResidueLimitCountByCounterId(warehouseTableRow.TakeCount)
    end
  end
  return 0
end

function WarehouseVm.GetWarehouse()
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  Z.CoroUtil.create_coro_xpcall(function()
    WarehouseVm.AsyncGetWarehouse(warehouseData.CancelSource:CreateToken())
  end)()
end

function WarehouseVm.AsyncCreateWarehouse()
  if not funcVm.CheckFuncCanUse(E.FunctionID.Warehouse) then
    return
  end
  local warehouseFoundItem = Z.Global.WarehouseFoundItem
  local itemId = warehouseFoundItem[1]
  local expendCount = warehouseFoundItem[2]
  local itemTableRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(itemId)
  if not itemTableRow then
    return
  end
  local itemsVm = Z.VMMgr.GetVM("items")
  local count = itemsVm.GetItemTotalCount(itemId)
  local item = {
    name = itemTableRow.Name
  }
  local showItemList = {}
  local itemData = {ItemId = itemId, ItemNum = expendCount}
  showItemList[#showItemList + 1] = itemData
  if expendCount > count then
    itemData.LabType = E.ItemLabType.Expend
    Z.DialogViewDataMgr:OpenNormalItemsDialog(Lang("CreateWarehouseItemDeficiency", {item = item}), function()
      Z.TipsVM.ShowTips(100002)
    end, nil, showItemList)
    return
  end
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  itemData.LabType = E.ItemLabType.Num
  Z.DialogViewDataMgr:OpenNormalItemsDialog(Lang("CreateWarehouseTips", {item = item}), function()
    local ret = worldProxy.CreateWarehouse({}, warehouseData.CancelSource:CreateToken())
    if ret.errCode == 0 then
      local warehouseId = ret.warehouse.WarehouseId
      if Z.EntityMgr.PlayerEnt then
        Z.EntityMgr.PlayerEnt:SetLuaLongAttr(Z.LocalAttr.EWarehouseId, warehouseId)
      end
      warehouseData:SetWarehouseInfo(ret.warehouse)
      Z.DialogViewDataMgr:OpenNormalDialog(Lang("CreateWarehouseIsOpenViewTips"), function()
        WarehouseVm.OpenWareView()
      end)
    else
      Z.TipsVM.ShowTips(ret.errCode)
    end
  end, nil, showItemList)
end

function WarehouseVm.AsyncDepositWarehouse(configId, itemUuid, itemNum, token)
  if not WarehouseVm.checkDepositCondition(configId, itemNum) then
    return
  end
  local errCode = worldProxy.DepositWarehouse({itemNum = itemNum, itemUuid = itemUuid}, token)
  if errCode == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.DepositWarehouse)
  else
    Z.TipsVM.ShowTips(errCode)
  end
  return errCode
end

function WarehouseVm.AsyncTakeOutWarehouse(gridPos, itemNum, configId, ownerCharId, token)
  local errCode = worldProxy.TakeOutWarehouse({
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

function WarehouseVm.AsyncExitWarehouse(token)
  local errCode = worldProxy.ExitWarehouse({}, token)
  if errCode == 0 then
    Z.TipsVM.ShowTips(122005)
    WarehouseVm.ClearWarehouseData()
    WarehouseVm.CloseWareView()
    WarehouseVm.CloseWareMmberPopupView()
  else
    Z.TipsVM.ShowTips(errCode)
  end
end

function WarehouseVm.AsyncGetWarehouse(token)
  if not funcVm.CheckFuncCanUse(E.FunctionID.Warehouse, true) then
    return
  end
  local ret = worldProxy.GetWarehouse({}, token)
  local warehouseId = 0
  local warehouse
  if ret.errCode == 0 then
    warehouse = ret.warehouse
    warehouseId = ret.warehouse.WarehouseId
  end
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  warehouseData:SetWarehouseInfo(warehouse)
  if Z.EntityMgr.PlayerEnt then
    Z.EntityMgr.PlayerEnt:SetLuaLongAttr(Z.LocalAttr.EWarehouseId, warehouseId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.RefreshWarehouse)
end

function WarehouseVm.AsyncReBeInitiateWarehouse(warehouseId, presidentId, agree, token)
  local ret = worldProxy.ReBeInitiateWarehouse({
    WarehouseId = warehouseId,
    presidentId = presidentId,
    agree = agree
  }, token)
  if ret.errCode == 0 then
    if agree then
      local warehouseData = Z.DataMgr.Get("warehouse_data")
      warehouseData:SetWarehouseInfo(ret.warehouse)
      if Z.EntityMgr.PlayerEnt then
        Z.EntityMgr.PlayerEnt:SetLuaLongAttr(Z.LocalAttr.EWarehouseId, ret.warehouse.WarehouseId)
      end
      Z.TipsVM.ShowTips(122008)
    end
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function WarehouseVm.AsyncKickOutWarehouse(kickCharId, token)
  local errCode = worldProxy.KickOutWarehouse({kickCharId = kickCharId}, token)
  if errCode == 0 then
    WarehouseVm.GetWarehouse()
  else
    Z.TipsVM.ShowTips(errCode)
  end
end

function WarehouseVm.AsyncDisbandWarehouse(token)
  local errCode = worldProxy.DisbandWarehouse({}, token)
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
  end
end

function WarehouseVm.AsyncInviteToWarehouse(inviteeCharId, token)
  local maxMemberCount = Z.Global.WarehousePopulation
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local warehouseInfo = warehouseData:GetWarehouseInfo(E.WarehouseType.Normal)
  if warehouseInfo and warehouseInfo.memIdList and maxMemberCount <= #warehouseInfo.memIdList then
    Z.TipsVM.ShowTips(7010)
    return
  end
  local errCode = worldProxy.InviteToWarehouse({inviteeCharId = inviteeCharId}, token)
  if errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
  end
end

function WarehouseVm.UpdateWarehouseInfo(changeWarehouseGrid, warehouseType)
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local warehouseInfo = warehouseData:GetWarehouseInfo(warehouseType)
  if warehouseInfo == nil then
    return
  end
  local isNewWarehouseItem = true
  if changeWarehouseGrid.itemInfo.count == 0 then
    isNewWarehouseItem = false
    for index, warehouseGrid in ipairs(warehouseInfo.warehouseGrids) do
      if warehouseGrid.pos == changeWarehouseGrid.pos and changeWarehouseGrid.itemInfo.count == 0 then
        table.remove(warehouseInfo.warehouseGrids, index)
        break
      end
    end
  else
    for index, warehouseGrid in ipairs(warehouseInfo.warehouseGrids) do
      if warehouseGrid.ownerCharId == changeWarehouseGrid.ownerCharId and warehouseGrid.pos == changeWarehouseGrid.pos then
        isNewWarehouseItem = false
        if changeWarehouseGrid.itemInfo.count == 0 then
          table.remove(warehouseInfo.warehouseGrids, index)
          break
        else
          warehouseInfo.warehouseGrids[index] = changeWarehouseGrid
          break
        end
      end
    end
  end
  if isNewWarehouseItem then
    table.insert(warehouseInfo.warehouseGrids, changeWarehouseGrid)
  end
  return isNewWarehouseItem
end

function WarehouseVm.WarehouseItemChange(gridChangeRequest)
  local changeWarehouseGrid = gridChangeRequest.warehouseGrid
  WarehouseVm.UpdateWarehouseInfo(changeWarehouseGrid, E.WarehouseType.Normal)
  if changeWarehouseGrid.itemInfo.count == 0 then
    Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.RemoveWarehouseItme, changeWarehouseGrid.pos, gridChangeRequest.takeOutCharId)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Warehouse.OnWarehouseItemChange)
end

function WarehouseVm.GetWarehouseItemCount(type)
  local count = 0
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local warehouseInfo = warehouseData:GetWarehouseInfo(type)
  if warehouseInfo and warehouseInfo.warehouseGrids then
    for key, value in pairs(warehouseInfo.warehouseGrids) do
      if 0 < value.itemInfo.count then
        count = count + 1
      end
    end
  end
  return count
end

function WarehouseVm.checkDepositCondition(configId, count)
  local itemRow = Z.TableMgr.GetRow("ItemTableMgr", configId)
  if not itemRow then
    return false
  end
  local curCount = WarehouseVm.GetWarehouseItemCount(E.WarehouseType.Normal)
  if curCount < Z.Global.WarehouseCapacity then
    return true
  end
  local warehouseData = Z.DataMgr.Get("warehouse_data")
  local warehouseInfo = warehouseData:GetWarehouseInfo()
  if warehouseInfo == nil then
    return
  end
  local charId = Z.ContainerMgr.CharSerialize.charId
  for key, value in pairs(warehouseInfo.warehouseGrids) do
    if configId == value.itemInfo.configId and value.itemInfo.count > 0 and value.ownerCharId == charId and (itemRow.Overlap == -1 or value.itemInfo.count + count <= itemRow.Overlap) then
      return true
    end
  end
  Z.TipsVM.ShowTips(7011)
  return false
end

return WarehouseVm
