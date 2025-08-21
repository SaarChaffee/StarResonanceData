local FashionRed = {}
local FashionAdvancedTableMap = require("table.FashionAdvancedTableMap")
local EFashionRegionType = {
  [E.RedType.FashionClothes] = {
    E.FashionRegion.Suit,
    E.FashionRegion.UpperClothes,
    E.FashionRegion.Pants,
    E.FashionRegion.Gloves,
    E.FashionRegion.Shoes
  },
  [E.RedType.FashionOrnament] = {
    E.FashionRegion.Headwear,
    E.FashionRegion.FaceMask,
    E.FashionRegion.MouthMask,
    E.FashionRegion.Tail,
    E.FashionRegion.Back,
    E.FashionRegion.Earrings,
    E.FashionRegion.Necklace,
    E.FashionRegion.Ring
  }
}

function FashionRed.CheckFashionCollectionPointReward()
  local collectionVM = Z.VMMgr.GetVM("collection")
  local score = collectionVM.GetFashionCollectionPoints()
  local fashionReward = Z.ContainerMgr.CharSerialize.fashion.fashionReward
  for _, row in ipairs(Z.TableMgr.GetTable("FashionCollectTableMgr").GetDatas()) do
    local redNodeName = string.zconcat("FashionCollectionScoreReward", row.Id)
    if fashionReward[row.Id] then
      Z.RedPointMgr.RemoveChildNodeData(E.RedType.FashionCollectionScoreRewardRed, redNodeName)
    elseif score >= row.Score then
      Z.RedPointMgr.AddChildNodeData(E.RedType.FashionCollectionScoreRewardRed, E.RedType.FashionCollectionScoreRewardRed, redNodeName)
      Z.RedPointMgr.UpdateNodeCount(redNodeName, 1)
    end
  end
  Z.RedPointMgr.RefreshRedNodeState(E.RedType.FashionCollectionScoreRewardRed)
end

function FashionRed.CheckFashionBenefitLastRewardRed()
  local collectionVM = Z.VMMgr.GetVM("collection")
  if collectionVM.HasMoonRewardCanGain() then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.FashionCollectionWindowPrivilegeRed, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.FashionCollectionWindowPrivilegeRed, 0)
  end
end

function FashionRed.getFristType(type)
  if table.zcontains(EFashionRegionType[E.RedType.FashionClothes], type) then
    return E.RedType.FashionClothes
  elseif table.zcontains(EFashionRegionType[E.RedType.FashionOrnament], type) then
    return E.RedType.FashionOrnament
  end
end

function FashionRed.changeItem(item)
  if not item then
    return
  end
  if not FashionAdvancedTableMap.FashionAdvancedUnlock then
    return
  end
  if table.zcount(FashionAdvancedTableMap.FashionAdvancedUnlock) == 0 then
    return
  end
  if not FashionAdvancedTableMap.FashionAdvancedUnlock[item.configId] then
    return
  end
  for i = 1, #FashionAdvancedTableMap.FashionAdvancedUnlock[item.configId] do
    local fashionAdvancedId = FashionAdvancedTableMap.FashionAdvancedUnlock[item.configId][i]
    FashionRed.checkFashionCustomCanUnlockRed(fashionAdvancedId)
  end
end

function FashionRed.AddNewFashionRed(fashionId)
  local fashionAdvancedRow = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(fashionId, true)
  if fashionAdvancedRow then
    return
  end
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId, true)
  if not fashionRow then
    return
  end
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local isVisable = fashionVM.CheckStyleVisible(fashionRow)
  if not isVisable then
    return
  end
  local type = FashionRed.getFristType(fashionRow.Type)
  if type then
    local regionRed = string.zconcat(Z.ConstValue.Fashion.FashionRegionRed, fashionRow.Type)
    Z.RedPointMgr.AddChildNodeData(type, type, regionRed)
    local styleItemRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemRed, fashionRow.Id)
    Z.RedPointMgr.AddChildNodeData(regionRed, type, styleItemRed)
    Z.RedPointMgr.UpdateNodeCount(styleItemRed, 1)
    Z.RedPointMgr.RefreshRedNodeState(styleItemRed)
  end
  FashionRed.checkFashionCustomCanUnlockRed(fashionId)
end

function FashionRed.addFashionCustomRed(fashionId, advancedFahionId)
  local type = E.RedType.FashionClothes
  local fashionRow = Z.TableMgr.GetTable("FashionTableMgr").GetRow(fashionId, true)
  if fashionRow then
    type = FashionRed.getFristType(fashionRow.Type)
  end
  local regionRed = string.zconcat(Z.ConstValue.Fashion.FashionRegionRed, 2, fashionRow.Type)
  Z.RedPointMgr.AddChildNodeData(type, type, regionRed)
  local styleItemRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemRed, 2, fashionRow.Id)
  Z.RedPointMgr.AddChildNodeData(regionRed, type, styleItemRed)
  local customRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomRed, fashionId)
  Z.RedPointMgr.AddChildNodeData(styleItemRed, type, customRed)
  local customItemId = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemRed, advancedFahionId)
  Z.RedPointMgr.AddChildNodeData(customRed, type, customItemId)
  local customUnlockRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, advancedFahionId)
  Z.RedPointMgr.AddChildNodeData(customItemId, type, customUnlockRed)
  Z.RedPointMgr.UpdateNodeCount(customUnlockRed, 1)
  Z.RedPointMgr.RefreshRedNodeState(customUnlockRed)
end

function FashionRed.RemoveFashionCustomRed(advancedFahionId)
  local customUnlockRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, advancedFahionId)
  Z.RedPointMgr.UpdateNodeCount(customUnlockRed, 0)
  Z.RedPointMgr.RefreshRedNodeState(customUnlockRed)
end

function FashionRed.InitFashionCustomRed()
  local itemsVM = Z.VMMgr.GetVM("items")
  for itemId, fashionList in pairs(FashionAdvancedTableMap.FashionAdvancedUnlock) do
    local count = itemsVM.GetItemTotalCount(itemId)
    if 0 < count then
      for i = 1, #fashionList do
        FashionRed.checkFashionCustomCanUnlockRed(fashionList[i])
      end
    end
  end
end

function FashionRed.checkFashionCustomCanUnlockRed(fashionId)
  local fashionVM = Z.VMMgr.GetVM("fashion")
  local row = Z.TableMgr.GetTable("FashionAdvancedTableMgr").GetRow(fashionId, true)
  if not row then
    return false
  end
  local baseUnlock = fashionVM.GetFashionIsUnlock(row.FashionId, true)
  if not baseUnlock then
    return
  end
  local unlock = fashionVM.GetFashionAdvancedIsUnlock(row.FashionId, row.Id)
  if unlock then
    FashionRed.RemoveFashionCustomRed(fashionId)
    return
  end
  if not fashionVM.IsFashionAdvancedCanUnlock(row) then
    FashionRed.RemoveFashionCustomRed(fashionId)
    return
  end
  FashionRed.addFashionCustomRed(row.FashionId, fashionId)
end

function FashionRed.AddNewWeaponSkinRed(item)
  if not item then
    return
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local curProfessionId = weaponVm.GetCurWeapon()
  local weaponSkinRow = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetRow(item.configId)
  if weaponSkinRow == nil then
    return
  end
  if weaponSkinRow.ProfessionId ~= curProfessionId then
    if FashionRed.cacheWeaponSkinRed[weaponSkinRow.ProfessionId] == nil then
      FashionRed.cacheWeaponSkinRed[weaponSkinRow.ProfessionId] = {}
    end
    FashionRed.cacheWeaponSkinRed[weaponSkinRow.ProfessionId][item.configId] = true
    return
  end
  local customRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, item.configId)
  Z.RedPointMgr.AddChildNodeData(E.RedType.FashionWeapon, E.RedType.FashionWeapon, customRed)
  Z.RedPointMgr.UpdateNodeCount(customRed, 1)
end

function FashionRed.RemoveWeaponSkinRed(configId)
  local customUnlockRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, configId)
  Z.RedPointMgr.UpdateNodeCount(customUnlockRed, 0)
  Z.RedPointMgr.RefreshRedNodeState(customUnlockRed)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local curProfessionId = weaponVm.GetCurWeapon()
  if FashionRed.cacheWeaponSkinRed[curProfessionId] == nil then
    return
  end
  FashionRed.cacheWeaponSkinRed[curProfessionId][configId] = nil
end

function FashionRed.RefreshWeaponSkinRed()
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local curProfessionId = weaponVm.GetCurWeapon()
  if FashionRed.cacheWeaponSkinRed[curProfessionId] == nil then
    return
  end
  for configId, _ in pairs(FashionRed.cacheWeaponSkinRed[curProfessionId]) do
    local customRed = string.zconcat(Z.ConstValue.Fashion.FashionStyleItemCustomItemUnlock, configId)
    Z.RedPointMgr.AddChildNodeData(E.RedType.FashionWeapon, E.RedType.FashionWeapon, customRed)
    Z.RedPointMgr.UpdateNodeCount(customRed, 1)
  end
end

function FashionRed.Init()
  Z.EventMgr:Add(Z.ConstValue.Collection.FashionCollectionPointChange, FashionRed.CheckFashionCollectionPointReward)
  Z.EventMgr:Add(Z.ConstValue.Backpack.AddItem, FashionRed.changeItem)
  Z.EventMgr:Add(Z.ConstValue.Backpack.DelItem, FashionRed.changeItem)
  Z.EventMgr:Add(Z.ConstValue.Backpack.ItemCountChange, FashionRed.changeItem)
  FashionRed.cacheWeaponSkinRed = {}
end

function FashionRed.UnInit()
  Z.EventMgr:Remove(Z.ConstValue.Collection.FashionCollectionPointChange, FashionRed.CheckFashionCollectionPointReward)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.AddItem, FashionRed.changeItem)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.DelItem, FashionRed.changeItem)
  Z.EventMgr:Remove(Z.ConstValue.Backpack.ItemCountChange, FashionRed.changeItem)
  FashionRed.cacheWeaponSkinRed = {}
end

return FashionRed
