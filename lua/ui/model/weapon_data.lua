local super = require("ui.model.data_base")
local WeaponData = class("WeaponData", super)

function WeaponData:ctor()
  self.BattleRes = {}
  self.PlayerInfo = {}
  self.WeaponId = 2
  self.HasSpSkill = true
  self.closeWeaponCamera_ = false
  self.cacheWeaponSkillData_ = nil
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
  self.BattleRes = {}
  self.SkillPanelToggleIsOn = true
  self.drawIdToPropIdDict_ = nil
  self.propIdToDrawIdDict_ = nil
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

function WeaponData:cacheWeaponSkillData()
  self.cacheWeaponSkillData_ = {}
  local weaponVm = Z.VMMgr.GetVM("weapon")
  local weaponConfig = Z.TableMgr.GetTable("ProfessionTableMgr").GetDatas()
  for _, value in ipairs(weaponConfig) do
    local weapon = weaponVm.GetWeaponInfo(value.Id)
    for __, skillId in ipairs(value.WearedSkillIds) do
      if weapon and weapon.skillInfoMap[skillId] then
        self.cacheWeaponSkillData_[skillId] = weapon.skillInfoMap[skillId].level
      else
        self.cacheWeaponSkillData_[skillId] = 0
      end
    end
    local passiveId = value.PassiveId
    if passiveId and passiveId ~= 0 then
      if weapon and weapon.skillInfoMap[passiveId] then
        self.cacheWeaponSkillData_[passiveId] = weapon.skillInfoMap[passiveId].level
      else
        self.cacheWeaponSkillData_[passiveId] = 0
      end
    end
  end
end

function WeaponData:GetWeaponSkillData(skillId)
  if self.cacheWeaponSkillData_ == nil then
    self:cacheWeaponSkillData()
  end
  if self.cacheWeaponSkillData_[skillId] then
    return self.cacheWeaponSkillData_[skillId]
  end
  return 0
end

function WeaponData:UpdateSkillData(skill, skillLevel)
  if self.cacheWeaponSkillData_ == nil then
    self:cacheWeaponSkillData()
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
