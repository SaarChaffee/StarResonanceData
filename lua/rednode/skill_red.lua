local SkillRed = {}
local weaponVm_ = Z.VMMgr.GetVM("weapon")
local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
local professionVm = Z.VMMgr.GetVM("profession")
local SkillRedDotJudgmentlevel = Z.Global.SkillRedDotJudgmentlevel
local SkillRedDotJudgmentStep = Z.Global.SkillRedDotJudgmentStep
local redNodeIds = {}
local skillData
local skillUpCosts = {}
local skillRemouldCosts = {}
local itemEeventConfigIds = {}
local weaponData

function SkillRed.checkUnlockSkill()
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.WeaponSkill, true) then
    return false
  end
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  local itemVm = Z.VMMgr.GetVM("items")
  local professionId = weaponVm.GetCurWeapon()
  local curWeaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
  if curWeaponConfig == nil then
    return false
  end
  for _, skillId in ipairs(curWeaponConfig.NormalSkill) do
    local redNodeName = weaponSkillVm:GetSkillUnlockRedId(skillId)
    redNodeIds[redNodeName] = true
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponSkillDetail, E.RedType.SkillUnlock, redNodeName)
    Z.RedPointMgr.AddChildNodeData(E.RedType.NormalSkillTab, E.RedType.SkillUnlock, redNodeName)
    local showRedot = 0
    local canUnlock = weaponSkillVm:CheckSkillCanUnlock(skillId)
    if canUnlock then
      showRedot = 1
    end
    Z.RedPointMgr.RefreshServerNodeCount(redNodeName, showRedot)
  end
end

function SkillRed.checkUpLevelBySkillId(skillId)
  local curProfessionId = weaponVm_.GetCurWeapon()
  local selectSkillLevel_ = weaponVm_.GetShowSkillLevel(curProfessionId, skillId)
  local unLock = weaponSkillVm:CheckSkillUnlock(skillId)
  if unLock then
    local redNodeName = weaponSkillVm:GetSkillUpRedId(skillId)
    redNodeIds[redNodeName] = true
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponSkillDetail, E.RedType.WeaponSkillUpLevel, redNodeName)
    Z.RedPointMgr.AddChildNodeData(E.RedType.NormalSkillTab, E.RedType.WeaponSkillUpLevel, redNodeName)
    local isEquip = weaponSkillVm:CheckSkillEquip(skillId)
    if not isEquip then
      Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
      return
    end
    if not weaponSkillVm:CheckIsSkillMaxLevel(skillId, selectSkillLevel_, true) then
      if skillUpCosts[skillId] then
        local flag = true
        local itemVm = Z.VMMgr.GetVM("items")
        for itemId, count in pairs(skillUpCosts[skillId]) do
          local totalCount = itemVm.GetItemTotalCount(itemId)
          if count > totalCount then
            flag = false
            break
          end
        end
        if not weaponSkillVm:CheckIsAchievementSkillConditions(skillId, selectSkillLevel_, false) then
          flag = false
        end
        if flag then
          Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 1)
        else
          Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
        end
      end
    else
      Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
    end
  end
end

function SkillRed.checkRemouldBySkillId(skillId)
  local remodelLevel = weaponSkillVm:GetSkillRemodelLevel(skillId)
  local unLock = weaponSkillVm:CheckSkillUnlock(skillId)
  if unLock then
    local redNodeName = weaponSkillVm:GetSkillRemouldRedId(skillId)
    redNodeIds[redNodeName] = true
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponSkillDetail, E.RedType.WeaponSkillRemould, redNodeName)
    Z.RedPointMgr.AddChildNodeData(E.RedType.NormalSkillTab, E.RedType.WeaponSkillRemould, redNodeName)
    local isEquip = weaponSkillVm:CheckSkillEquip(skillId)
    if not isEquip then
      Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
      return
    end
    local isMax = weaponSkillVm:ChechSkillRemodelMax(skillId)
    if not isMax then
      local flag = true
      local itemVm = Z.VMMgr.GetVM("items")
      for itemId, count in pairs(skillRemouldCosts[skillId]) do
        local totalCount = itemVm.GetItemTotalCount(itemId)
        if count > totalCount then
          flag = false
          break
        end
      end
      if flag then
        Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 1)
      else
        Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
      end
    else
      Z.RedPointMgr.RefreshServerNodeCount(redNodeName, 0)
    end
  end
end

local slotSkillDict = {}
local aoyiSkillList = {}
local allEquipSlotList = {
  3,
  4,
  5,
  6,
  7,
  8,
  9
}

function SkillRed.initSlotSkillDict()
  local professionData = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for _, professionRow in pairs(professionData) do
    slotSkillDict[professionRow.ProfessionId] = {}
    for _, value in ipairs(professionRow.NormalSkill) do
      local skillRow = Z.TableMgr.GetTable("SkillTableMgr").GetRow(value)
      if skillRow then
        for __, slotId in ipairs(skillRow.SlotPositionId) do
          if slotSkillDict[professionRow.ProfessionId][slotId] == nil then
            slotSkillDict[professionRow.ProfessionId][slotId] = {}
          end
          table.insert(slotSkillDict[professionRow.ProfessionId][slotId], value)
        end
      end
    end
  end
  local aoyiData = Z.TableMgr.GetTable("SkillAoyiTableMgr").GetDatas()
  for _, value in pairs(aoyiData) do
    table.insert(aoyiSkillList, value.Id)
  end
end

function SkillRed.checkSkillCanEquip()
  local professionId = professionVm:GetCurProfession()
  local slotSkillDictcurProfession
  if slotSkillDict[professionId] == nil then
    SkillRed.initSlotSkillDict()
  end
  slotSkillDictcurProfession = slotSkillDict[professionId]
  local slotRedFlag = {}
  local skillRedFlag = {}
  local canEquipSkillList = {}
  for _, slotId in ipairs(allEquipSlotList) do
    local slotRedNodeName = weaponSkillVm:GetSlotEquipRedId(slotId)
    redNodeIds[slotRedNodeName] = true
    slotRedFlag[slotRedNodeName] = false
    local slotCanEquip = false
    Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponSkillDetail, E.RedType.SkillEquipSlot, slotRedNodeName)
    Z.RedPointMgr.AddChildNodeData(E.RedType.SkillEntranceInEscMenu, E.RedType.SkillEquipSlot, slotRedNodeName)
    local slotConfig = Z.TableMgr.GetRow("SkillSlotPositionTableMgr", slotId)
    local slotUnlock = true
    if slotConfig and slotConfig.UnlockCondition then
      slotUnlock = Z.ConditionHelper.CheckCondition(slotConfig.UnlockCondition)
    end
    local skillType = weaponSkillVm:GetSkillTypeBySlotId(slotId)
    if skillType == E.SkillType.WeaponSkill then
      canEquipSkillList = slotSkillDictcurProfession[slotId] or {}
      Z.RedPointMgr.AddChildNodeData(E.RedType.SkillEquipBtn, E.RedType.SkillEquipSlot, slotRedNodeName)
    elseif skillType == E.SkillType.MysteriesSkill then
      canEquipSkillList = aoyiSkillList
      Z.RedPointMgr.AddChildNodeData(E.RedType.ResonanceSkillEquipBtn, E.RedType.SkillEquipSlot, slotRedNodeName)
    end
    if weaponSkillVm:GetSkillBySlot(slotId) == 0 and slotUnlock then
      slotCanEquip = true
    end
    for _, skillId in ipairs(canEquipSkillList) do
      local skillRedNodeName = weaponSkillVm:GetSkillEquipRedId(skillId)
      redNodeIds[skillRedNodeName] = true
      if skillRedFlag[skillRedNodeName] == nil then
        skillRedFlag[skillRedNodeName] = false
      end
      Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponSkillDetail, E.RedType.SkillEquip, skillRedNodeName)
      if skillType == E.SkillType.WeaponSkill then
        Z.RedPointMgr.AddChildNodeData(E.RedType.NormalSkillTab, E.RedType.SkillEquip, skillRedNodeName)
      elseif skillType == E.SkillType.MysteriesSkill then
        Z.RedPointMgr.AddChildNodeData(E.RedType.WeaponResonanceTab, E.RedType.SkillEquip, skillRedNodeName)
      end
      if weaponSkillVm:CheckSkillUnlock(skillId) and not weaponSkillVm:CheckSkillEquip(skillId) and slotCanEquip then
        skillRedFlag[skillRedNodeName] = true
        slotRedFlag[slotRedNodeName] = true
      end
    end
  end
  for slotRedNodeName, value in pairs(slotRedFlag) do
    if value then
      Z.RedPointMgr.RefreshServerNodeCount(slotRedNodeName, 1)
    else
      Z.RedPointMgr.RefreshServerNodeCount(slotRedNodeName, 0)
    end
  end
  for skillRedNodeName, value in pairs(skillRedFlag) do
    if value then
      Z.RedPointMgr.RefreshServerNodeCount(skillRedNodeName, 1)
    else
      Z.RedPointMgr.RefreshServerNodeCount(skillRedNodeName, 0)
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Weapon.OnSkillEquipRedChange)
end

function SkillRed.changeItem(item)
  if not item then
    return
  end
  for skillId, costs in pairs(skillUpCosts) do
    for costId, count in pairs(costs) do
      if item.configId == costId then
        SkillRed.checkUpLevelBySkillId(skillId)
        SkillRed.checkUnlockSkill()
        break
      end
    end
  end
  for skillId, costs in pairs(skillRemouldCosts) do
    for costId, count in pairs(costs) do
      if item.configId == costId then
        SkillRed.checkRemouldBySkillId(skillId)
        break
      end
    end
  end
end

function SkillRed.unlockSkill(skillId)
  SkillRed.changeSkill(skillId)
  SkillRed.changeSkillRemould(skillId)
  SkillRed.checkUnlockSkill()
  SkillRed.checkSkillCanEquip()
end

function SkillRed.changeSkillRemould(skillId)
  local remodelLevel = weaponSkillVm:GetSkillRemodelLevel(skillId)
  local nextRemodelLevel = remodelLevel + 1
  for _, value in ipairs(SkillRedDotJudgmentStep) do
    if remodelLevel >= value[1] and remodelLevel <= value[2] then
      nextRemodelLevel = remodelLevel + value[3]
      break
    end
  end
  local cost = {}
  for i = remodelLevel + 1, nextRemodelLevel do
    local weaponStarRow = weaponSkillVm:GetSkillRemodelRow(skillId, i)
    if weaponStarRow and weaponStarRow.UpgradeCost then
      for k, value in ipairs(weaponStarRow.UpgradeCost) do
        local itemId = value[1]
        if cost[itemId] == nil then
          cost[itemId] = value[2]
        else
          cost[itemId] = cost[itemId] + value[2]
        end
      end
    end
  end
  skillRemouldCosts[skillId] = cost
  SkillRed.addRemouldItemEvents(skillRemouldCosts[skillId])
  SkillRed.checkRemouldBySkillId(skillId)
end

function SkillRed.changeSkill(skillId)
  if skillUpCosts[skillId] == nil then
    return
  end
  local curProfessionId = weaponVm_.GetCurWeapon()
  local selectSkillLevel_ = weaponVm_.GetShowSkillLevel(curProfessionId, skillId)
  local upgradeId = weaponSkillVm:GetSkillUpgradeId(skillId)
  local nextSkillLevel = selectSkillLevel_ + 1
  for _, value in ipairs(SkillRedDotJudgmentlevel) do
    if selectSkillLevel_ >= value[1] and selectSkillLevel_ <= value[2] then
      nextSkillLevel = selectSkillLevel_ + value[3]
      break
    end
  end
  local upLevlCost = weaponSkillVm:GetSkillUpCost(upgradeId, selectSkillLevel_, nextSkillLevel)
  skillUpCosts[skillId] = upLevlCost
  SkillRed.checkUpLevelBySkillId(skillId)
  SkillRed.checkSkillCanEquip()
  SkillRed.addUpItemEvents(skillUpCosts[skillId])
end

function SkillRed.changeWeapon(curProfessionId)
  skillData = weaponVm_.GetCurWeaponSkills()
  weaponData = weaponVm_.GetWeaponInfo(curProfessionId)
  for redName, v in pairs(redNodeIds) do
    Z.RedPointMgr.RefreshServerNodeCount(redName, 0)
  end
  for k, v in ipairs(skillData) do
    for index, skillId in ipairs(v) do
      skillUpCosts[skillId] = {}
      SkillRed.changeSkill(skillId)
      SkillRed.changeSkillRemould(skillId)
    end
  end
  SkillRed.checkUnlockSkill()
  SkillRed.checkSkillCanEquip()
end

function SkillRed.initWeaponData()
  SkillRed.changeWeapon(weaponVm_.GetCurWeapon())
end

function SkillRed.addRemouldItemEvents(congfigIds)
  if congfigIds == nil then
    return
  end
  for congfigId, v in pairs(congfigIds) do
    if not table.zcontains(itemEeventConfigIds, congfigId) then
      itemEeventConfigIds[#itemEeventConfigIds + 1] = congfigId
      Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, congfigId, SkillRed.changeItem)
    end
  end
end

function SkillRed.addUpItemEvents(congfigIds)
  if congfigIds == nil then
    return
  end
  for congfigId, v in pairs(congfigIds) do
    if not table.zcontains(itemEeventConfigIds, congfigId) then
      itemEeventConfigIds[#itemEeventConfigIds + 1] = congfigId
      Z.ItemEventMgr.RegisterAllChangeEvent(E.ItemAddEventType.ItemId, congfigId, SkillRed.changeItem)
    end
  end
end

function SkillRed.removeItemEvents()
  for _, congfigId in ipairs(itemEeventConfigIds) do
    Z.ItemEventMgr.RemoveObjAllByEvent(E.ItemChangeType.AllChange, E.ItemAddEventType.ItemId, congfigId, SkillRed.changeItem)
  end
end

function SkillRed.Init()
  Z.EventMgr:Add(Z.ConstValue.SyncAllContainerData, SkillRed.initWeaponData)
  Z.EventMgr:Add(Z.ConstValue.Hero.ChangeProfession, SkillRed.changeWeapon)
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, SkillRed.changeSkill)
  Z.EventMgr:Add(Z.ConstValue.RoleLevelUp, SkillRed.initWeaponData)
  Z.EventMgr:Add(Z.ConstValue.Weapon.OnWeaponSkillRemodelSuccess, SkillRed.changeSkillRemould)
  Z.EventMgr:Add(Z.ConstValue.TalentSkill.UnLockSkill, SkillRed.unlockSkill)
  Z.EventMgr:Add(Z.ConstValue.Hero.ResonacneSkillUnlock, SkillRed.checkSkillCanEquip)
  Z.EventMgr:Add(Z.ConstValue.Hero.InstallSkill, SkillRed.unlockSkill)
  Z.EventMgr:Add(Z.ConstValue.Hero.OldInstallSkillId, SkillRed.unlockSkill)
end

function SkillRed.UnInit()
  SkillRed.removeItemEvents()
  Z.EventMgr:Remove(Z.ConstValue.SyncAllContainerData, SkillRed.initWeaponData)
  Z.EventMgr:Remove(Z.ConstValue.Hero.ChangeProfession, SkillRed.changeWeapon)
  Z.EventMgr:Remove(Z.ConstValue.Weapon.OnWeaponSkillLevelUpSuccess, SkillRed.changeSkill)
  Z.EventMgr:Remove(Z.ConstValue.RoleLevelUp, SkillRed.initWeaponData)
  Z.EventMgr:Remove(Z.ConstValue.TalentSkill.UnLockSkill, SkillRed.unlockSkill)
  Z.EventMgr:Remove(Z.ConstValue.Weapon.OnWeaponSkillRemodelSuccess, SkillRed.changeSkillRemould)
  Z.EventMgr:Remove(Z.ConstValue.Hero.InstallSkill, SkillRed.unlockSkill)
  Z.EventMgr:Remove(Z.ConstValue.Hero.OldInstallSkillId, SkillRed.unlockSkill)
  Z.EventMgr:Remove(Z.ConstValue.Hero.ResonacneSkillUnlock, SkillRed.unlockSkill)
end

return SkillRed
