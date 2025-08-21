local EquipRed = {}
EquipRed.ItemRed = {}
local equipGs = {}
local equipQuality = {}
local lockPartTab = {}
local wearConditionTab = {}
local refineItemEventConfigIds = {}
local forgeItemEventConfigIds = {}
local refineItemDic = {}
local funcVM_ = Z.VMMgr.GetVM("gotofunc")
local equipRefineVm = Z.VMMgr.GetVM("equip_refine")

function EquipRed.getEquipQuality(configId)
  local quality = 0
  if equipQuality[configId] then
    quality = equipQuality[configId]
  else
    local itemRow = Z.TableMgr.GetTable("ItemTableMgr").GetRow(configId, true)
    if itemRow then
      equipQuality[configId] = itemRow.Quality
      quality = itemRow.Quality
    end
  end
  return quality
end

function EquipRed.getEquipGs(configId)
  local gs = 0
  if equipGs[configId] then
    gs = equipGs[configId]
  else
    local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(configId, true)
    if equipData then
      equipGs[configId] = equipData.EquipGs
      wearConditionTab[configId] = equipData.WearCondition
      gs = equipData.EquipGs
    end
  end
  return gs
end

function EquipRed.changePartIsShowRed(partId)
  if lockPartTab[partId] then
    return
  end
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  local equipData = equipList[partId]
  local equipPackage = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if equipPackage == nil then
    return
  end
  local equipVm = Z.VMMgr.GetVM("equip_system")
  local partEquipList = equipVm.GetAllEquipByPartId(partId)
  if #partEquipList == 0 then
    return
  end
  local maxPerfactValue = 0
  local redCount = 0
  local equips = 0
  local maxGs = 0
  local maxQuality = 0
  if not equipData or equipData.itemUuid == 0 then
    maxGs, equips, maxQuality = equipVm.GetEquipMaxGsAndProfessionEquips(partEquipList, partId)
    for index, value in ipairs(partEquipList) do
      if equips[value.item.uuid] then
        local gs = EquipRed.getEquipGs(value.item.configId)
        local quality = EquipRed.getEquipQuality(value.item.configId)
        if quality == maxQuality and gs == maxGs and maxPerfactValue < value.item.equipAttr.perfectionValue then
          maxPerfactValue = value.item.equipAttr.perfectionValue
        end
      end
    end
    redCount = 1
    if equipData and equipPackage.items[equipData.itemUuid] then
      local configId = equipPackage.items[equipData.itemUuid].configId
      local gs = EquipRed.getEquipGs(configId)
      local quality = EquipRed.getEquipQuality(configId)
      if maxQuality < quality and maxGs < gs or equips[equipData.itemUuid] and gs == maxGs and quality == maxQuality and maxPerfactValue <= equipPackage.items[equipData.itemUuid].equipAttr.perfectionValue then
        redCount = 0
      end
    end
  end
  local parentNodeId = equipVm.GetEquipPartTabRed(partId)
  for index, value in ipairs(partEquipList) do
    local nodeId = parentNodeId .. value.item.uuid
    Z.RedPointMgr.AddChildNodeData(parentNodeId, E.RedType.EquipItem, nodeId)
    if redCount == 0 or maxGs == 0 then
      Z.RedPointMgr.UpdateNodeCount(nodeId, 0)
    elseif E.EquipPart.Weapon == partId and not equipVm.CheckEquipIsCurProfession(value.item.configId) then
      Z.RedPointMgr.UpdateNodeCount(nodeId, 0)
    else
      local gs = EquipRed.getEquipGs(value.item.configId)
      local quality = EquipRed.getEquipQuality(value.item.configId)
      local isUnlock = Z.ConditionHelper.CheckCondition(wearConditionTab[value.item.configId] or {})
      if equips[value.item.uuid] and quality == maxQuality and gs == maxGs and isUnlock and value.item.equipAttr.perfectionValue == maxPerfactValue then
        Z.RedPointMgr.UpdateNodeCount(nodeId, redCount)
      else
        Z.RedPointMgr.UpdateNodeCount(nodeId, 0)
      end
    end
  end
end

function EquipRed.changeEquip(container, dirtys)
  if dirtys.equipList then
    for partId, value in pairs(dirtys.equipList) do
      EquipRed.changePartIsShowRed(partId)
      EquipRed.refinePart(partId)
    end
  end
end

function EquipRed.recastEquip(uuid)
  local equipPackage = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if equipPackage then
    local item = equipPackage.items[uuid]
    if item then
      local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(item.configId, true)
      if equipData then
        EquipRed.changePartIsShowRed(equipData.EquipPart)
      end
    end
  end
end

function EquipRed.InitEquipNode()
  local equipVm = Z.VMMgr.GetVM("equip_system")
  for key, partId in pairs(E.EquipPart) do
    local parentNodeId = E.RedType.RoleMain .. partId
    Z.RedPointMgr.AddChildNodeData(E.RedType.RoleMain, E.RedType.RoleEquipPart, parentNodeId)
    local partRedId = equipVm.GetEquipPartTabRed(partId)
    Z.RedPointMgr.AddChildNodeData(parentNodeId, E.RedType.EquipPart, partRedId)
    Z.RedPointMgr.AddChildNodeData(E.RedType.Equip, E.RedType.EquipPart, partRedId)
    local equipPartRow = Z.TableMgr.GetTable("EquipPartTableMgr").GetRow(partId)
    if equipPartRow then
      local isUnLock = Z.ConditionHelper.CheckCondition(equipPartRow.UnlockCondition)
      if isUnLock then
        EquipRed.changePartIsShowRed(partId)
      else
        lockPartTab[partId] = equipPartRow.UnlockCondition
      end
    end
  end
end

function EquipRed.refreshAllPart()
  for key, partId in pairs(E.EquipPart) do
    EquipRed.RefreshPartEquipRed(partId)
  end
end

function EquipRed.RefreshPartEquipRed(partId)
  EquipRed.changePartIsShowRed(partId)
end

function EquipRed.ChangeEquip(item)
  local equipPackage = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if equipPackage == nil then
    return
  end
  local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(item.configId, true)
  if equipData then
    local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
    local nowPutEquipInfo = equipList[equipData.EquipPart]
    if nowPutEquipInfo and nowPutEquipInfo.itemUuid ~= 0 then
      local nowPutItem = equipPackage.items[nowPutEquipInfo.itemUuid]
      if nowPutItem then
        local nowPutEquipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(nowPutItem.configId)
        if nowPutEquipData and nowPutEquipData.EquipGs >= equipData.EquipGs then
          return
        end
      end
    end
    EquipRed.RefreshPartEquipRed(equipData.EquipPart)
  end
end

function EquipRed.DelEquip(item)
  local equipData = Z.TableMgr.GetTable("EquipTableMgr").GetRow(item.configId, true)
  if equipData then
    local partId = equipData.EquipPart
    local equipVm = Z.VMMgr.GetVM("equip_system")
    local parentNodeId = equipVm.GetEquipPartTabRed(partId)
    Z.RedPointMgr.UpdateNodeCount(parentNodeId .. item.uuid, 0)
  end
end

function EquipRed.LoadItemRed(itemRedId, view, trans)
  Z.RedPointMgr.LoadRedDotItem(itemRedId, view, trans)
  if not EquipRed.ItemRed[itemRedId] then
    EquipRed.ItemRed[itemRedId] = true
  end
end

function EquipRed.RemoveAllItemRed(view)
  for removeId, value in pairs(EquipRed.ItemRed) do
    Z.RedPointMgr.RemoveNodeItem(removeId, view)
  end
  EquipRed.ItemRed = {}
end

function EquipRed.RoleLevelUp()
  for partId, condition in pairs(lockPartTab) do
    local isUnLock = Z.ConditionHelper.CheckCondition(condition)
    if isUnLock then
      lockPartTab[partId] = nil
      EquipRed.changePartIsShowRed(partId)
    end
  end
end

function EquipRed.refinePart(part)
  if not funcVM_.CheckFuncCanUse(E.EquipFuncId.EquipRefine, true) then
    return
  end
  local refinePartRedName = equipRefineVm.GetRefinePartRedName(part)
  Z.RedPointMgr.AddChildNodeData(E.RedType.EquipRefineRed, E.RedType.EquipRefinePartRed, refinePartRedName)
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local itemsVM = Z.VMMgr.GetVM("items")
  local equipData = Z.ContainerMgr.CharSerialize.equip.equipList[part]
  local oldPartUuid = refineItemDic[part]
  if not equipData or equipData.itemUuid == 0 then
    if oldPartUuid then
      Z.RedPointMgr.UpdateNodeCount(equipRefineVm.GetRefineItemRedName(oldPartUuid), 0)
      refineItemDic[part] = nil
    end
    Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
    return
  end
  if oldPartUuid and oldPartUuid ~= equipData.itemUuid then
    local refineItemRedName = equipRefineVm.GetRefineItemRedName(oldPartUuid)
    Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
  end
  local equipSystemVm = Z.VMMgr.GetVM("equip_system")
  local parentNodeId = equipSystemVm.GetEquipPartTabRed(part)
  local refineItemRedName = equipRefineVm.GetRefineItemRedName(equipData.itemUuid)
  refineItemDic[part] = equipData.itemUuid
  Z.RedPointMgr.AddChildNodeData(parentNodeId, E.RedType.EquipItem, refineItemRedName)
  local currentProfessionId = Z.ContainerMgr.CharSerialize.professionList.curProfessionId
  local currentLevelRefineId = equipRefineVm.GetCurRefineIdByPart(part, currentProfessionId)
  if currentLevelRefineId == nil then
    Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
    Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
    return
  end
  local data = equipCfgData.RefineTableData[currentLevelRefineId]
  if data then
    local level = Z.ContainerMgr.CharSerialize.equip.equipList[part].equipSlotRefineLevel or 0
    if Z.Global.EquipRefineReddotLevelLimit and level >= Z.Global.EquipRefineReddotLevelLimit then
      Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
      Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
      return
    end
    local nextRefineRow = data[level + 1]
    if not nextRefineRow then
      Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
      Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
      return
    end
    local descList = Z.ConditionHelper.GetConditionDescList(nextRefineRow.Condition)
    for i, v in ipairs(descList) do
      if not v.IsUnlock then
        Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
        Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
        return
      end
    end
    if nextRefineRow and nextRefineRow.SuccessRate / 100 < Z.Global.EquipRefineRedProbabilityLimit then
      Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
      Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
      return
    end
    if nextRefineRow and Z.ConditionHelper.CheckCondition(nextRefineRow.Condition) then
      local isShow = true
      local rate = 1
      if Z.ContainerMgr.CharSerialize.equip.equipList[part] then
        for index, value in ipairs(Z.Global.EquipRefineRedLevelLimit) do
          if level >= value[1] and level <= value[2] then
            rate = value[3]
            break
          end
        end
      end
      for k, v in ipairs(nextRefineRow.RefineConsume) do
        EquipRed.addRefineItemEvent(v[1])
        local totalCount = itemsVM.GetItemTotalCount(v[1])
        if totalCount < v[2] * rate then
          isShow = false
          break
        end
      end
      if isShow == false then
        Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
        Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
        return
      end
    else
      Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 0)
      Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 0)
      return
    end
  end
  Z.RedPointMgr.UpdateNodeCount(refineItemRedName, 1)
  Z.RedPointMgr.UpdateNodeCount(refinePartRedName, 1)
end

function EquipRed.refineCheckAllPart()
  for key, partId in pairs(E.EquipPart) do
    EquipRed.refinePart(partId)
  end
end

function EquipRed.refineItemChange(item)
  EquipRed.refineCheckAllPart()
end

function EquipRed.addRefineItemEvent(congfigId)
  if congfigId == nil then
    return
  end
  if not table.zcontains(refineItemEventConfigIds, congfigId) then
    refineItemEventConfigIds[#refineItemEventConfigIds + 1] = congfigId
    Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, congfigId, EquipRed.refineItemChange)
  end
end

function EquipRed.addRefineItemEvents(congfigIds)
  if congfigIds == nil then
    return
  end
  for congfigId, v in pairs(congfigIds) do
    if not table.zcontains(refineItemEventConfigIds, congfigId) then
      refineItemEventConfigIds[#refineItemEventConfigIds + 1] = congfigId
      Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, congfigId, EquipRed.refineItemChange)
    end
  end
end

function EquipRed.removeItemEvents()
  for _, congfigId in ipairs(refineItemEventConfigIds) do
    Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, congfigId, EquipRed.refineItemChange)
  end
  for _, congfigId in ipairs(forgeItemEventConfigIds) do
    Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, congfigId, EquipRed.refineForgeItemChange)
  end
end

function EquipRed.checkBreak()
  local equipPackage = Z.ContainerMgr.CharSerialize.itemPackage.packages[E.BackPackItemPackageType.Equip]
  if equipPackage == nil then
    return
  end
  local equipList = Z.ContainerMgr.CharSerialize.equip.equipList
  local equipVm = Z.VMMgr.GetVM("equip_system")
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local itemsVM = Z.VMMgr.GetVM("items")
  for key, equipData in pairs(equipList) do
    local item = equipPackage.items[equipData.itemUuid]
    if item and equipVm.CheckIsFocusEquip(item.configId) then
      local isCanBreak = true
      local curBreakCount = item.equipAttr.breakThroughTime
      local levels = equipCfgData.EquipBreakIdLevelMap[item.configId] or {}
      local rowId = levels[curBreakCount + 1]
      if rowId then
        local breakThroughRow = Z.TableMgr.GetRow("EquipBreakThroughTableMgr", rowId)
        if breakThroughRow then
          local consume = breakThroughRow.Consume
          local isCan = true
          for index, value in ipairs(consume) do
            EquipRed.addForgeItemEvent(value[1])
            if itemsVM.GetItemTotalCount(value[1]) < value[2] then
              isCanBreak = false
              break
            end
          end
        end
      else
        isCanBreak = false
      end
      local redNum = isCanBreak and 1 or 0
    end
  end
end

function EquipRed.checkMake()
  local equipCfgData = Z.DataMgr.Get("equip_config_data")
  local equipVm = Z.VMMgr.GetVM("equip_system")
  local itemsVM = Z.VMMgr.GetVM("items")
  for index, value in ipairs(equipCfgData.EquipCreateTableRows) do
    local isCanCreate = true
    if not equipVm.CheckIsHaveEquipByConfigId(value.Id) then
      for index, value in ipairs(value.ConsumableItems) do
        EquipRed.addForgeItemEvent(value[1])
        if itemsVM.GetItemTotalCount(value[1]) < value[2] then
          isCanCreate = false
          break
        end
      end
    else
      isCanCreate = false
    end
    local redNum = isCanCreate and 1 or 0
  end
end

function EquipRed.refineForgeItemChange()
end

function EquipRed.addForgeItemEvent(congfigId)
  if congfigId == nil then
    return
  end
  if not table.zcontains(forgeItemEventConfigIds, congfigId) then
    forgeItemEventConfigIds[#forgeItemEventConfigIds + 1] = congfigId
    Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, congfigId, EquipRed.refineForgeItemChange)
  end
end

function EquipRed.Init()
  function EquipRed.equipListChangeFunc(container, dirtys)
    EquipRed.changeEquip(container, dirtys)
  end
  
  function EquipRed.professionChangeFunc()
    EquipRed.refreshAllPart()
  end
  
  function EquipRed.roleLevelUpFunc()
    EquipRed.RoleLevelUp()
  end
  
  function EquipRed.refinePartFunc(part)
    EquipRed.refinePart(part)
  end
  
  function EquipRed.initContainerDataFunc()
    EquipRed.refineCheckAllPart()
  end
  
  function EquipRed.recastEquipFunc(uuid)
    EquipRed.recastEquip(uuid)
  end
  
  function EquipRed.switchFunctionChange(functionTab)
    for functionId, isUnlock in pairs(functionTab) do
      if E.EquipFuncId.EquipRefine == functionId and isUnlock then
        EquipRed.refineCheckAllPart()
      end
    end
  end
  
  function EquipRed.upLevleFunc(level)
    EquipRed.refineCheckAllPart()
  end
  
  Z.EventMgr:Add(Z.ConstValue.Equip.EquipRecastSuccess, EquipRed.recastEquipFunc)
  Z.EventMgr:Add(Z.ConstValue.Equip.RefinePartSuccess, EquipRed.refinePartFunc)
  Z.EventMgr:Add(Z.ConstValue.SyncAllContainerData, EquipRed.initContainerDataFunc)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, EquipRed.roleLevelUpFunc)
  Z.EventMgr:Add(Z.ConstValue.Hero.ChangeProfession, EquipRed.refreshAllPart)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, EquipRed.upLevleFunc)
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, EquipRed.switchFunctionChange)
  Z.ContainerMgr.CharSerialize.equip.Watcher:RegWatcher(EquipRed.equipListChangeFunc)
end

function EquipRed.UnInit()
  EquipRed.removeItemEvents()
  if EquipRed.equipListChangeFunc then
    Z.ContainerMgr.CharSerialize.equip.Watcher:UnregWatcher(EquipRed.equipListChangeFunc)
    EquipRed.equipListChangeFunc = nil
  end
  if EquipRed.professionChangeFunc then
    Z.EventMgr:Remove(Z.ConstValue.Hero.ChangeProfession, EquipRed.refreshAllPart)
    EquipRed.professionChangeFunc = nil
  end
  if EquipRed.roleLevelUpFunc then
    Z.EventMgr:Remove(Z.ConstValue.RoleLevelUp, EquipRed.roleLevelUpFunc)
    EquipRed.roleLevelUpFunc = nil
  end
  if EquipRed.refinePartFunc then
    Z.EventMgr:Remove(Z.ConstValue.Equip.RefinePartSuccess, EquipRed.refinePartFunc)
    EquipRed.refinePartFunc = nil
  end
  if EquipRed.recastEquipFunc then
    Z.EventMgr:Remove(Z.ConstValue.Equip.EquipRecastSuccess, EquipRed.recastEquipFunc)
    EquipRed.recastEquipFunc = nil
  end
  if EquipRed.initContainerDataFunc then
    Z.EventMgr:Remove(Z.ConstValue.SyncAllContainerData, EquipRed.initContainerDataFunc)
    EquipRed.initContainerDataFunc = nil
  end
  if EquipRed.switchFunctionChange then
    Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, EquipRed.switchFunctionChange)
    EquipRed.switchFunctionChange = nil
  end
  if EquipRed.upLevleFunc then
    Z.EventMgr:Remove(Z.ConstValue.RoleLevelUp, EquipRed.upLevleFunc)
    EquipRed.upLevleFunc = nil
  end
end

return EquipRed
