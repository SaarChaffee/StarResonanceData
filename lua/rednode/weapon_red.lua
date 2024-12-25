local WeaponRed = {}
local weaponSubRedIdTab = {}

function WeaponRed.AddNewRed(weaponType, id, count)
  local childRedId = string.zconcat(E.RedType.WeaponDevelop, weaponType, id)
  Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponDevelop, weaponType, childRedId)
  Z.RedPointMgr.RefreshServerNodeCount(childRedId, count)
  weaponSubRedIdTab[weaponType .. id] = childRedId
end

function WeaponRed.refresShopRed()
end

function WeaponRed.GetWeaponSubRedIdById(weaponType, id)
  return weaponSubRedIdTab[weaponType .. id]
end

function WeaponRed.RemoveRed(id)
  if weaponSubRedIdTab[id] then
    Z.RedPointMgr.RefreshServerNodeCount(weaponSubRedIdTab[id], 0)
    weaponSubRedIdTab[id] = nil
  end
end

return WeaponRed
