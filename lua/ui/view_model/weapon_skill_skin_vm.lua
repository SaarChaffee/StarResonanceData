local WeaponSkillSkinVM = {}

function WeaponSkillSkinVM:OpenSkillSkinView(skillId, professionId)
  local viewData = {professionId = professionId, skillId = skillId}
  local viewConfigKey = "fashion_weapon_skill_window"
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Creation_01, viewConfigKey, function()
    Z.UIMgr:OpenView(viewConfigKey, viewData)
  end)
end

function WeaponSkillSkinVM:CloseSkillSkinView()
  Z.UIMgr:CloseView("fashion_weapon_skill_window")
end

function WeaponSkillSkinVM:CheckSkillHasSkin(skillId)
  local skillSkinData = Z.TableMgr.GetTable("SkillSkinTableMgr").GetDatas()
  for index, value in pairs(skillSkinData) do
    if value.SkillId[1] == skillId then
      return true
    end
  end
  return false
end

function WeaponSkillSkinVM:CheckSkillSkinUnlock(skillId, skillSkinId, professionId)
  if skillSkinId == skillId then
    return true
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  if professionId == nil then
    professionId = weaponVm.GetCurWeapon()
  end
  local weaponInfo = weaponVm.GetWeaponInfo(professionId)
  if weaponInfo and weaponInfo.skillInfoMap and weaponInfo.skillInfoMap[skillId] and weaponInfo.skillInfoMap[skillId].activeSkillSkins then
    for skinId, _ in pairs(weaponInfo.skillInfoMap[skillId].activeSkillSkins) do
      if skinId == skillSkinId then
        return true
      end
    end
  end
  return false
end

local skillSkinList = {}

function WeaponSkillSkinVM:GetSkillSkinData(professionId)
  if skillSkinList[professionId] == nil then
    skillSkinList[professionId] = {}
    local skillSkinData = Z.TableMgr.GetTable("SkillSkinTableMgr").GetDatas()
    for _, value in pairs(skillSkinData) do
      if value.ProfessionId == professionId then
        table.insert(skillSkinList[professionId], value)
      end
    end
  end
  return skillSkinList[professionId]
end

function WeaponSkillSkinVM:CheckSkillSkinEquip(skillId, skillSkinId, professionId)
  if skillSkinId == skillId then
    skillSkinId = 0
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  if professionId == nil then
    professionId = weaponVm.GetCurWeapon()
  end
  local weaponInfo = weaponVm.GetWeaponInfo(professionId)
  if weaponInfo and weaponInfo.skillInfoMap and weaponInfo.skillInfoMap[skillId] then
    return weaponInfo.skillInfoMap[skillId].curSkillSkin == skillSkinId
  end
  return true
end

function WeaponSkillSkinVM:GetWeaponSkinId(professionId)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  if professionId == nil then
    professionId = weaponVm.GetCurWeapon()
  end
  if Z.ContainerMgr.CharSerialize.professionList.professionList[professionId] then
    return Z.ContainerMgr.CharSerialize.professionList.professionList[professionId].UseSkinId
  end
  return 0
end

function WeaponSkillSkinVM:GetWeaponOriginSkinId(professionId)
  local equipVm = Z.VMMgr.GetVM("equip_system")
  local item = equipVm.GetItemByPartId(E.EquipPart.Weapon)
  if item then
    local equipWeaponRow = Z.TableMgr.GetRow("EquipWeaponTableMgr", item.configId, true)
    if equipWeaponRow and equipWeaponRow.WeaponSkinId ~= 0 then
      return equipWeaponRow.WeaponSkinId
    end
  end
  local professionRow = Z.TableMgr.GetRow("ProfessionSystemTableMgr", professionId, true)
  if professionRow then
    return professionRow.WeaponSkinId
  end
  local weaponData = Z.TableMgr.GetTable("WeaponSkinTableMgr").GetDatas()
  for _, value in pairs(weaponData) do
    if value.ProfessionId == professionId and value.Original == 1 then
      return value.Id
    end
  end
  return 0
end

function WeaponSkillSkinVM:GetSkillSkinId(skillId, professionId)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  if professionId == nil then
    professionId = weaponVm.GetCurWeapon()
  end
  local weaponInfo = weaponVm.GetWeaponInfo(professionId)
  if weaponInfo and weaponInfo.skillInfoMap and weaponInfo.skillInfoMap[skillId] then
    return weaponInfo.skillInfoMap[skillId].curSkillSkin
  end
  return skillId
end

function WeaponSkillSkinVM:GetSkillSkinUnlockRedId(skillId)
  return "SkillSkinUnlockRed" .. skillId
end

function WeaponSkillSkinVM:AsyncActivateProfessionSkillSkin(professionId, skillId, skinId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local activateProfessionSkillSkinRequest = {
    professionId = professionId,
    skillId = skillId,
    skinId = skinId
  }
  local ret = worldProxy.ActivateProfessionSkillSkin(activateProfessionSkillSkinRequest, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.TipsVM.ShowTips(150024)
  return true
end

function WeaponSkillSkinVM:AsyncUseProfessionSkillSkin(professionId, skillId, skinId, cancelToken)
  if skillId == skinId then
    skinId = 0
  end
  local worldProxy = require("zproxy.world_proxy")
  local useProfessionSkillSkinRequest = {
    professionId = professionId,
    skillId = skillId,
    skinId = skinId
  }
  local ret = worldProxy.UseProfessionSkillSkin(useProfessionSkillSkinRequest, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.TipsVM.ShowTips(150025)
  return true
end

function WeaponSkillSkinVM:AsyncUseProfessionSkin(professionId, skinId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  if skinId == 0 then
    skinId = self:GetWeaponOriginSkinId(professionId)
  end
  local useProfessionSkinInfo = {professionId = professionId, skinId = skinId}
  local ret = worldProxy.UseProfessionSkin(useProfessionSkinInfo, cancelToken)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnWeaponSkinChange)
  Z.TipsVM.ShowTipsLang(150023)
  return true
end

return WeaponSkillSkinVM
