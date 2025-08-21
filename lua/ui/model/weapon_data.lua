local super = require("ui.model.data_base")
local WeaponData = class("WeaponData", super)

function WeaponData:ctor()
  self.BattleRes = {}
  self.PlayerInfo = {}
  self.WeaponId = 2
  self.HasSpSkill = true
  self.closeWeaponCamera_ = false
  self.cacheWeaponSkillData_ = nil
  self.cacheSlotSkillInfoMap = nil
  self.cacheWeaponObtains_ = {}
  self.SkillPanelToggleIsOn = true
  self.timerMgr_ = Z.TimerMgr.new()
end

function WeaponData:Init()
  self:cacheWeaponAttrs()
end

function WeaponData:UpdateBattleRes(k, v)
  self:UpdateData("BattleRes", {
    [k] = v
  })
end

function WeaponData:ClearBattleRes(...)
  self.BattleRes = {}
end

function WeaponData:Clear()
  self.timerMgr_:Clear()
  self.closeWeaponCamera_ = {}
  self.cacheWeaponSkillData_ = nil
  self.cacheWeaponAttrData_ = nil
  self.BattleRes = {}
  self.SkillPanelToggleIsOn = true
  self.drawIdToPropIdDict_ = nil
  self.propIdToDrawIdDict_ = nil
  self.cacheSlotSkillInfoMap = nil
end

function WeaponData:ClearBattleRes()
  self.BattleRes = {}
end

function WeaponData:createSkillObj(slotId, skillId, skillLevel)
  local skillObj = {
    slotId = slotId,
    skillId = skillId,
    skillLevel = skillLevel
  }
  return skillObj
end

function WeaponData:cacheWeaponAttrs()
  self.cacheWeaponAttrData_ = {}
  local tbl = Z.TableMgr.GetTable("WeaponAttrTableMgr")
  if not tbl then
    return
  end
  local config = tbl.GetDatas()
  for _, value in pairs(config) do
    if self.cacheWeaponAttrData_[value.WeaponID] == nil then
      self.cacheWeaponAttrData_[value.WeaponID] = {}
    end
    self.cacheWeaponAttrData_[value.WeaponID][value.Level] = value
  end
end

function WeaponData:GetWeaponAttrTableRow(weaponId, weaponLevel)
  if self.cacheWeaponAttrData_ == nil then
    self:cacheWeaponAttrs()
  end
  local weaponLevelAttrs = self.cacheWeaponAttrData_[weaponId]
  if weaponLevelAttrs == nil then
    return nil
  end
  if weaponLevel < 1 then
    weaponLevel = 1
  elseif weaponLevel > #weaponLevelAttrs then
    weaponLevel = #weaponLevelAttrs
  end
  return weaponLevelAttrs[weaponLevel]
end

function WeaponData:cacheAllWeaponSkillData()
  self.cacheWeaponSkillData_ = {}
  local weaponConfig = Z.TableMgr.GetTable("ProfessionSystemTableMgr").GetDatas()
  for _, value in ipairs(weaponConfig) do
    for __, skillId in ipairs(value.NormalSkill) do
      self:cacheWeaponSkillData(value.Id, skillId)
    end
    for __, skillId in ipairs(value.NormalAttackSkill) do
      self:cacheWeaponSkillData(value.Id, skillId)
    end
    for __, skillId in ipairs(value.SpecialSkill) do
      self:cacheWeaponSkillData(value.Id, skillId)
    end
    for __, skillId in ipairs(value.UltimateSkill) do
      self:cacheWeaponSkillData(value.Id, skillId)
    end
  end
end

function WeaponData:cacheWeaponSkillData(professionId, skillId)
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weapon = weaponVm.GetWeaponInfo(professionId)
  if weapon and weapon.skillInfoMap[skillId] then
    self.cacheWeaponSkillData_[skillId] = weapon.skillInfoMap[skillId].level
  else
    self.cacheWeaponSkillData_[skillId] = 0
  end
end

function WeaponData:GetWeaponSkillData(skillId)
  if self.cacheWeaponSkillData_ == nil then
    self:cacheAllWeaponSkillData()
  end
  if self.cacheWeaponSkillData_[skillId] then
    return self.cacheWeaponSkillData_[skillId]
  end
  return 0
end

function WeaponData:UpdateSkillData(skill, skillLevel)
  if self.cacheWeaponSkillData_ == nil then
    self:cacheAllWeaponSkillData()
  end
  self.cacheWeaponSkillData_[skill] = skillLevel
end

function WeaponData:CacheWeaponObtain(weaponId)
  table.insert(self.cacheWeaponObtains_, weaponId)
end

function WeaponData:GetObtainWeaponId()
  if #self.cacheWeaponObtains_ > 0 then
    return table.remove(self.cacheWeaponObtains_, 1)
  end
  return nil
end

function WeaponData:GetWeaponObtain()
  return self.cacheWeaponObtains_
end

function WeaponData:ClearWeaponObtain()
  self.cacheWeaponObtains_ = {}
end

function WeaponData:InitSlotSkill()
  self.cacheSlotSkillInfoMap = {}
  for id, professionInfo in pairs(Z.ContainerMgr.CharSerialize.professionList.professionList) do
    self.cacheSlotSkillInfoMap[id] = {}
    for slotId, skillId in pairs(professionInfo.slotSkillInfoMap) do
      self.cacheSlotSkillInfoMap[id][slotId] = skillId
    end
  end
end

function WeaponData:UpdateSlotSkill(slotId, skillId)
  local professionVm = Z.VMMgr.GetVM("profession")
  local professionId = professionVm:GetContainerProfession()
  self.cacheSlotSkillInfoMap[professionId][slotId] = skillId
end

function WeaponData:GetWeaponSlotSkill(slotId)
  local professionVm = Z.VMMgr.GetVM("profession")
  local professionId = professionVm:GetContainerProfession()
  return self.cacheSlotSkillInfoMap[professionId][slotId] or 0
end

function WeaponData:GetResonancePropIdByDrawId(drawId)
  if self.drawIdToPropIdDict_ == nil then
    self.drawIdToPropIdDict_ = {}
    local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
    local datas = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetDatas()
    for _, v in pairs(datas) do
      for _, info in ipairs(v.MakeConsume) do
        local itemId = info[1]
        local itemRow = itemTableMgr.GetRow(itemId)
        if itemRow and itemRow.Type == E.ResonanceSkillItemType.Material then
          self.drawIdToPropIdDict_[itemId] = v.Id
          break
        end
      end
    end
  end
  return self.drawIdToPropIdDict_[drawId]
end

function WeaponData:GetResonanceDrawIdByPropId(propId)
  if self.propIdToDrawIdDict_ == nil then
    self.propIdToDrawIdDict_ = {}
    local itemTableMgr = Z.TableMgr.GetTable("ItemTableMgr")
    local datas = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetDatas()
    for _, v in pairs(datas) do
      for _, info in ipairs(v.MakeConsume) do
        local itemId = info[1]
        local itemRow = itemTableMgr.GetRow(itemId)
        if itemRow and itemRow.Type == E.ResonanceSkillItemType.Material then
          self.propIdToDrawIdDict_[v.Id] = itemId
          break
        end
      end
    end
  end
  return self.propIdToDrawIdDict_[propId]
end

return WeaponData
