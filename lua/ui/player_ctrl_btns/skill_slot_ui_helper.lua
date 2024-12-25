local SkillSlotUIHelper = {}
local effectGroup, clickEffect, loopEffect, stopEffect, cdEndEffect, longPressTag, continueTag, chargeNum, exInfoPointDown, exInfoPointUp, cdRoot, skillCd, continuousCd
local weaponVm = Z.VMMgr:GetVM("weapon")

function SkillSlotUIHelper.getElementId()
  local weaponId = weaponVm.GetCurWeapon()
  if weaponId == nil then
    return 1
  end
  local weaponCfg = Z.TableMgr:GetTable("ProfessionTableMgr"):GetRow(weaponId)
  if weaponCfg == nil then
    return 1
  end
  return weaponCfg.BindElemental
end

function SkillSlotUIHelper:refreshExInfo()
end

function SkillSlotUIHelper:InitSlot(slotUnit, slotId)
end

function SkillSlotUIHelper.UpdateSlot(slotUnit, slotId)
end

function SkillSlotUIHelper.Update()
end

return SkillSlotUIHelper
