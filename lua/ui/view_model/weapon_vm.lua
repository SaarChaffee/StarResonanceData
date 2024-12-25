local opneWeaponRoleView = function()
  if Z.StatusSwitchMgr:CheckSwitchEnable(Z.EStatusSwitch.StatusEquipMenu) then
    Z.UIMgr:OpenView("weapon_role_main")
  end
end
local closeWeaponRoleView = function()
  Z.UIMgr:CloseView("weapon_role_main")
end
local openUpgradeView = function(viewData)
  Z.UIMgr:OpenView("weaponhero_upgrade_popup", viewData)
end
local closeUpGradeView = function()
  Z.UIMgr:CloseView("weaponhero_upgrade_popup")
end
local openSkillLevelUpGradePreview = function(viewData)
  Z.UIMgr:OpenView("weaponhero_skill_upgrade_popup", viewData)
end
local closeSkillLevelUpGradePreview = function()
  Z.UIMgr:CloseView("weaponhero_skill_upgrade_popup")
end
local getCurWeapon = function()
  return Z.ContainerMgr.CharSerialize.professionList.curProfessionId
end
local getCurWeaponSkills = function()
  local curProfessionId = getCurWeapon()
  local professionRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(curProfessionId)
  local lockSkill = {}
  local data = {}
  for _, value in ipairs(professionRow.NormalAttackSkill) do
    table.insert(lockSkill, value)
  end
  for _, value in ipairs(professionRow.SpecialSkill) do
    table.insert(lockSkill, value)
  end
  for _, value in ipairs(professionRow.UltimateSkill) do
    table.insert(lockSkill, value)
  end
  table.insert(data, lockSkill)
  table.insert(data, professionRow.NormalSkill)
  return data
end
local getWeaponInfo = function(professionId)
  local professionList = Z.ContainerMgr.CharSerialize.professionList.professionList
  return professionList[professionId]
end
local getWeaponShowSkill = function(professionId, equip)
  local skillIds = {}
  if not equip then
    local weaponSysRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(professionId)
    if weaponSysRow == nil then
      return
    end
    return weaponSysRow.ShowSkill
  else
    local weaponInfo = getWeaponInfo(professionId)
    if weaponInfo and weaponInfo.slotSkillInfoMap then
      for slotId, skillId in ipairs(weaponInfo.slotSkillInfoMap) do
        table.insert(skillIds, skillId)
      end
    end
  end
  return skillIds
end
local checkWeaponUnlock = function(professionId)
  return Z.ContainerMgr.CharSerialize.professionList.professionList[professionId] ~= nil
end
local checkWeaponEquip = function(professionId)
  local equipWeaponId = getCurWeapon()
  if equipWeaponId == 0 then
    return false
  end
  return professionId == equipWeaponId
end
local checkWeaponSupport = function(professionId)
  local supportInfo = Z.ContainerMgr.CharSerialize.professionList.curAssistProfessions
  if supportInfo then
    for _, value in ipairs(supportInfo) do
      if value == professionId then
        return true
      end
    end
  end
  return false
end
local collectFightAttr = function(fightAttrs, attrs)
  if fightAttrs == nil then
    return
  end
  for _, value in ipairs(fightAttrs) do
    local attrId = value[1]
    if attrs[attrId] == nil then
      attrs[attrId] = 0
    end
    attrs[attrId] = attrs[attrId] + value[2]
  end
end
local getMysteriesSkillConfig = function(skillId)
  return Z.TableMgr.GetTable("SkillAoyiTableMgr").GetRow(skillId)
end
local getAttrPreview = function(weaponId, weaponLevel, order)
  if weaponId == nil or weaponLevel == nil then
    return {}
  end
  local weaponData = Z.DataMgr.Get("weapon_data")
  local TableRow = weaponData:GetWeaponAttrTableRow(weaponId, weaponLevel)
  if TableRow == nil then
    return {}
  end
  local attr = {}
  collectFightAttr(TableRow.BaseAttr, attr)
  collectFightAttr(TableRow.ExtraAttr, attr)
  if order then
    local sortAttr = {}
    local i = 1
    for _, value in ipairs(TableRow.BaseAttr) do
      if attr[value[1]] then
        sortAttr[i] = {}
        sortAttr[i].attrId = value[1]
        sortAttr[i].number = attr[value[1]]
        i = i + 1
      end
    end
    for _, value in ipairs(TableRow.ExtraAttr) do
      if attr[value[1]] then
        sortAttr[i] = {}
        sortAttr[i].attrId = value[1]
        sortAttr[i].number = attr[value[1]]
        i = i + 1
      end
    end
    return sortAttr
  end
  return attr
end
local getShowSkillLevel = function(professionId, skillId)
  if professionId == nil then
    professionId = getCurWeapon()
  end
  local weaponData = getWeaponInfo(professionId)
  if weaponData == nil then
    return 1
  end
  local weaaponSkillVm = Z.VMMgr.GetVM("weapon_skill")
  skillId = weaaponSkillVm:GetOriginSkillId(skillId)
  if weaponData.skillInfoMap[skillId] then
    return weaponData.skillInfoMap[skillId].level
  end
  local aoyiSkillList = Z.ContainerMgr.CharSerialize.professionList.aoyiSkillInfoMap
  if aoyiSkillList[skillId] then
    return aoyiSkillList[skillId].level
  end
  return 1
end
local getWeaponUpLevelShowRed = function(weaponLevel)
  for i = 1, #Z.Global.TalentRedDotFrequency do
    if weaponLevel >= Z.Global.TalentRedDotFrequency[i][1] and weaponLevel <= Z.Global.TalentRedDotFrequency[i][2] then
      return Z.Global.TalentRedDotFrequency[i][3]
    end
  end
  return 1
end
local checkWeaponUp = function(weaponId)
  local weaponData = getWeaponInfo(weaponId)
  if weaponData == nil then
    return false
  end
  local maxLv_ = table.zcount(Z.TableMgr.GetTable("WeaponLevelTableMgr").GetDatas())
  if maxLv_ <= weaponData.level then
    return false
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  if not funcVm.FuncIsOn(E.FunctionID.Talent, true) then
    return false
  end
  local itemVm_ = Z.VMMgr.GetVM("items")
  local levelConfig_ = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(weaponData.level)
  if levelConfig_.Broke and weaponData.experience >= levelConfig_.Exp then
    local professionTableRow = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetRow(weaponId)
    if professionTableRow == nil then
      return false
    end
    if not Z.ConditionHelper.CheckCondition(levelConfig_.Conditions) then
      return false
    end
    local costMat = {}
    for _, value in pairs(levelConfig_.ItemPrice) do
      local temp = {}
      temp.itemID = value[1]
      temp.itemCount = value[2]
      table.insert(costMat, temp)
    end
    for _, value in pairs(levelConfig_.ExtrCost) do
      local temp = {}
      temp.itemID = professionTableRow.ProfessionBrokeExtraItem[1][value[1]]
      temp.itemCount = value[2]
      table.insert(costMat, temp)
    end
    for _, value in ipairs(costMat) do
      local totalCount = itemVm_.GetItemTotalCount(value.itemID)
      if totalCount < value.itemCount then
        return false
      end
    end
    return true
  else
    if not Z.ConditionHelper.CheckCondition(levelConfig_.Conditions) then
      return false
    end
    local materials = Z.Global.WeaponLevelUpItem
    local levelItem = {}
    for _, info in ipairs(materials) do
      local item = {}
      item.itemID = info[1]
      item.effect = info[2]
      item.costItemID = info[3]
      item.costItemCnt = info[4]
      table.insert(levelItem, item)
    end
    local needCoin = {}
    local showRedNeedUpLevel = getWeaponUpLevelShowRed(weaponData.level)
    local needExp = -weaponData.experience
    for i = 0, showRedNeedUpLevel - 1 do
      local tempConfig = Z.TableMgr.GetTable("WeaponLevelTableMgr").GetRow(weaponData.level + i)
      needExp = needExp + tempConfig.Exp
    end
    for _, value in ipairs(levelItem) do
      local itemCount = itemVm_.GetItemTotalCount(value.itemID)
      local costItemCount = itemVm_.GetItemTotalCount(value.costItemID)
      local needItemCount = math.ceil(needExp / value.effect)
      if itemCount < needItemCount then
        needItemCount = itemCount
      end
      if needCoin[value.costItemID] == nil then
        needCoin[value.costItemID] = 0
      end
      needCoin[value.costItemID] = needCoin[value.costItemID] + value.costItemCnt * needItemCount
      if costItemCount < needCoin[value.costItemID] then
        return false
      end
      needExp = needExp - needItemCount * value.effect
      if needExp <= 0 then
        return true
      end
    end
    return false
  end
end
local switchEntityShow = function(show)
  if show then
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:OpenCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.LuaBridge.SetHudSwitch(true)
  else
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_CHARACTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_MONSTER)
    Z.CameraMgr:CloseCullingMask(Panda.Utility.ZLayerUtils.LAYER_MASK_BOSS)
    Z.LuaBridge.SetHudSwitch(false)
  end
end
local showError = function(ret)
  if ret and ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
    return false
  end
  return true
end
local asyncWeaponLevelUp = function(professionId, material, cancelToken)
  local materialsMap = {}
  materialsMap.materialsMap = material
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ProfessionUpgrade(professionId, materialsMap, cancelToken)
  return showError(ret)
end
local asyncWeaponOverStep = function(professionId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.ProfessionBreakthrough(professionId, cancelToken)
  return showError(ret)
end
local asyncUseWeaponSkin = function(professionId, skinId, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local useWeaponSkinInfo = {}
  useWeaponSkinInfo.professionId = professionId
  useWeaponSkinInfo.skinId = skinId
  local ret = worldProxy.UseProfessionSkin(useWeaponSkinInfo, cancelToken)
  return showError(ret)
end
local ret = {
  OpneWeaponRoleView = opneWeaponRoleView,
  CloseWeaponRoleView = closeWeaponRoleView,
  OpenUpgradeView = openUpgradeView,
  CloseUpGradeView = closeUpGradeView,
  CheckWeaponUp = checkWeaponUp,
  GetWeaponUpLevelShowRed = getWeaponUpLevelShowRed,
  GetCurWeapon = getCurWeapon,
  GetWeaponInfo = getWeaponInfo,
  GetWeaponShowSkill = getWeaponShowSkill,
  CheckWeaponEquip = checkWeaponEquip,
  SwitchEntityShow = switchEntityShow,
  GetAttrPreview = getAttrPreview,
  CheckWeaponUnlock = checkWeaponUnlock,
  GetShowSkillLevel = getShowSkillLevel,
  GetMysteriesSkillConfig = getMysteriesSkillConfig,
  CheckWeaponSupport = checkWeaponSupport,
  GetCurWeaponSkills = getCurWeaponSkills,
  AsyncWeaponLevelUp = asyncWeaponLevelUp,
  AsyncWeaponOverStep = asyncWeaponOverStep,
  AsyncUseWeaponSkin = asyncUseWeaponSkin
}
return ret
