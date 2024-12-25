local super = require("ui.model.data_base")
local Proficiency = class("Proficiency", super)

function Proficiency:ctor()
  super.ctor(self)
end

function Proficiency:Init()
  self.ProficiencyNewItem = {}
  self.ShowProficiencyData = {}
  self:InitCfgData()
end

function Proficiency:InitCfgData()
  self.PlayerLevelSkillTableDatas = Z.TableMgr.GetTable("PlayerLevelSkillTableMgr").GetDatas()
end

function Proficiency:OnLanguageChange()
  self:InitCfgData()
end

function Proficiency:InitProficiency()
  self.NowSelectProficiencyTab = {}
  self.ProficiencyActivationTab = {}
  for key, value in pairs(Z.ContainerMgr.CharSerialize.roleLevel.proficiencyInfo.usingProficiencyMap) do
    if value ~= 0 then
      self.ProficiencyActivationTab[key] = value
    end
  end
  self.IsFrist = true
  self.IsChange = false
end

function Proficiency:ActivationLevel(level, buffId)
  self.ProficiencyActivationTab[level] = buffId
  self.NowSelectProficiencyTab[level] = buffId
end

function Proficiency:NotActivationLevel(level)
  self.ProficiencyActivationTab[level] = nil
  self.NowSelectProficiencyTab[level] = nil
end

function Proficiency:NotActvationAll()
  for level, buffId in pairs(self.ProficiencyActivationTab) do
    local playerLevelSkillRow = Z.TableMgr.GetTable("PlayerLevelSkillTableMgr").GetRow(buffId)
    if playerLevelSkillRow and not playerLevelSkillRow.Deactive then
      self.ProficiencyActivationTab[level] = nil
    end
  end
  self.NowSelectProficiencyTab = {}
  self.IsFrist = true
end

function Proficiency:GetPotentialTab()
  return self.ProficiencyActivationTab
end

function Proficiency:GetLevelActivationId(level)
  return self.ProficiencyActivationTab[level]
end

function Proficiency:GetIsRefresh()
  for level, buffId in pairs(self.ProficiencyActivationTab) do
    local playerLevelSkillRow = Z.TableMgr.GetTable("PlayerLevelSkillTableMgr").GetRow(buffId)
    if playerLevelSkillRow and not playerLevelSkillRow.Deactive then
      return true
    end
  end
  return false
end

function Proficiency:ChangeState(state)
  self.IsChange = state
end

function Proficiency:Clear()
  self.ProficiencyActivationTab = {}
  self.ProficiencyNewItem = {}
  self.ShowProficiencyData = {}
end

return Proficiency
