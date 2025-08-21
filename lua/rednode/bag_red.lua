local BagRed = {}
BagRed.package = {}

function BagRed.AddNewRed(pack, itemUuid)
  if E.BackPackItemPackageType.Item ~= pack.type and E.BackPackItemPackageType.Equip ~= pack.type and E.BackPackItemPackageType.Mod ~= pack.type then
    return
  end
  if BagRed.package[pack.type] == nil then
    BagRed.package[pack.type] = {}
  end
  if table.zcontains(BagRed.package[pack.type], itemUuid) then
    return
  end
  table.insert(BagRed.package[pack.type], itemUuid)
  local typeNodeId = BagRed.GetNewTabRedId(pack.type)
  Z.RedPointMgr.AddChildNodeData(E.RedType.Backpack, E.RedType.BagTab, typeNodeId)
  local itemNodeId = BagRed.GetNewItemRedId(pack.type, itemUuid)
  Z.RedPointMgr.AddChildNodeData(typeNodeId, E.RedType.BagItem, itemNodeId)
  Z.RedPointMgr.UpdateNodeCount(itemNodeId, 1)
end

function BagRed.RemoveAllRed()
  for type, value in pairs(BagRed.package) do
    for _, uuid in pairs(value) do
      local nodeId = BagRed.GetNewItemRedId(type, uuid)
      Z.RedPointMgr.UpdateNodeCount(nodeId, 0)
    end
  end
  BagRed.package = {}
end

function BagRed.RemoveRed(itemUuid)
  for key, value in pairs(BagRed.package) do
    if table.zcontains(value, itemUuid) then
      table.zremoveOneByValue(value, itemUuid)
      local nodeId = BagRed.GetNewItemRedId(key, itemUuid)
      Z.RedPointMgr.UpdateNodeCount(nodeId, 0)
    end
  end
end

function BagRed.GetNewTabRedId(packType)
  return string.zconcat(E.RedType.Backpack, "_", packType)
end

function BagRed.GetNewItemRedId(packType, itemUuid)
  return string.zconcat(E.RedType.Backpack, "_", packType, "_", itemUuid)
end

function BagRed.checkResonanceFuncIsOpen()
  local isUnlock = Z.VMMgr.GetVM("switch").CheckFuncSwitch(E.ResonanceFuncId.Create)
  return isUnlock
end

function BagRed.CheckResonanceItemRedDot()
  local itemsVM = Z.VMMgr.GetVM("items")
  local weaponSkillVM = Z.VMMgr.GetVM("weapon_skill")
  local weaponData = Z.DataMgr.Get("weapon_data")
  local skillAoyiItemTableMgr = Z.TableMgr.GetTable("SkillAoyiItemTableMgr")
  local configDatas = skillAoyiItemTableMgr.GetDatas()
  for id, info in pairs(configDatas) do
    local drawId = weaponData:GetResonanceDrawIdByPropId(id)
    if drawId ~= nil then
      local itemConfig = Z.TableMgr.GetRow("ItemTableMgr", drawId)
      if itemConfig ~= nil then
        local typeConfig = Z.TableMgr.GetRow("ItemTypeTableMgr", itemConfig.Type)
        if typeConfig ~= nil then
          local isCanMake = true
          local isActivate = weaponSkillVM:CheckSkillUnlock(info.SkillId)
          if isActivate or itemsVM.GetItemTotalCount(id) > 0 then
            isCanMake = false
          else
            for index, cost in ipairs(info.MakeConsume) do
              local itemId = cost[1]
              local itemNeedNum = cost[2]
              local itemOwnNum = itemsVM.GetItemTotalCount(itemId)
              if itemNeedNum > itemOwnNum then
                isCanMake = false
                break
              end
            end
          end
          local typeNodeId = BagRed.GetResonanceTabRedId(typeConfig.Package)
          Z.RedPointMgr.AddChildNodeData(E.RedType.Backpack, E.RedType.BagTab, typeNodeId, BagRed.checkResonanceFuncIsOpen)
          local subTypeNodeId = BagRed.GetResonanceSubTabRedId(typeConfig.Package, itemConfig.Type)
          Z.RedPointMgr.AddChildNodeData(typeNodeId, E.RedType.BagSecondTab, subTypeNodeId, BagRed.checkResonanceFuncIsOpen)
          local itemNodeId = BagRed.GetResonanceItemRedId(drawId)
          Z.RedPointMgr.AddChildNodeData(subTypeNodeId, E.RedType.BagItem, itemNodeId, BagRed.checkResonanceFuncIsOpen)
          Z.RedPointMgr.UpdateNodeCount(itemNodeId, isCanMake and 1 or 0)
          local makeNodeId = BagRed.GetResonanceMakeRedId(id)
          Z.RedPointMgr.AddChildNodeData(E.RedType.ResonanceMakePropItem, E.RedType.ResonanceMakePropItem, makeNodeId)
          local makeItemNodeId = BagRed.GetResonanceMakeItemRedId(id)
          Z.RedPointMgr.AddChildNodeData(makeNodeId, E.RedType.ResonanceMakePropItem, makeItemNodeId)
          Z.RedPointMgr.UpdateNodeCount(makeItemNodeId, isCanMake and 1 or 0)
        end
      end
    end
  end
end

function BagRed.GetResonanceTabRedId(packType)
  return string.zconcat(E.RedType.Backpack, "_resonance_", packType)
end

function BagRed.GetResonanceSubTabRedId(packType, subType)
  return string.zconcat(E.RedType.Backpack, "_resonance_", packType, "_", subType)
end

function BagRed.GetResonanceItemRedId(itemConfigId)
  return string.zconcat(E.RedType.Backpack, "_resonance_item_", itemConfigId)
end

function BagRed.GetResonanceMakeRedId(itemConfigId)
  return string.zconcat("resonance_make_", itemConfigId)
end

function BagRed.GetResonanceMakeItemRedId(itemConfigId)
  return string.zconcat("resonance_make_item_", itemConfigId)
end

return BagRed
