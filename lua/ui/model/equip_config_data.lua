local super = require("ui.model.data_base")
local EquipCfgData = class("EquipCfgData", super)
local equipMap = require("table.EquipTableMap")

function EquipCfgData:ctor()
  super.ctor(self)
end

function EquipCfgData:Init()
  self.RefineTableData = {}
  self.RefineBlessingTableData = {}
  self.RecastMaxLevelTab = {}
  self.RecastPerfectTab = {}
  self.EnchantTableData = {}
  self.EnchantItemTableData = {}
  self.EquipRareMap = {}
  self.EquipCreateTableRows = {}
  self.EquipBreakIdLevelMap = {}
  self.EquipBreakConfigIdMap = {}
  self.EquipAttrIdMap = {}
  self.EquipAttrSchoolMap = {}
  self.EquipSchoolFirstAttrIdMap = {}
  self.EquipSuitMap = {}
  self.TalentSchoolMap = {}
end

function EquipCfgData:OnLanguageChange()
  self:InitRefineData()
  self:InitEquipEnchantCfg()
  self:InitRecastConfig()
end

function EquipCfgData:InitTalentSchoolMap()
  self.TalentSchoolMap = {}
  local talentSchoolRows = Z.TableMgr.GetTable("TalentSchoolTableMgr").GetDatas()
  for index, value in pairs(talentSchoolRows) do
    for index, stageId in ipairs(value.TalentStage) do
      self.TalentSchoolMap[stageId] = value.Id
    end
  end
end

function EquipCfgData:InitEquipSuitMap()
  self.EquipSuitMap = {}
  local rows = Z.TableMgr.GetTable("EquipSuitTableMgr").GetDatas()
  for key, value in pairs(rows) do
    if self.EquipSuitMap[value.SuitId] == nil then
      self.EquipSuitMap[value.SuitId] = {}
    end
    self.EquipSuitMap[value.SuitId][value.LimitNum] = value.Id
  end
end

function EquipCfgData:GetTalentSchoolIdsByAttrLibIds(attrLibIds)
  local schoolIds = {}
  for index, attrLibId in pairs(attrLibIds) do
    if self.EquipAttrSchoolMap[attrLibId] then
      for talentSchoolId, value in pairs(self.EquipAttrSchoolMap[attrLibId]) do
        schoolIds[talentSchoolId] = talentSchoolId
      end
    end
  end
  return table.zvalues(schoolIds)
end

function EquipCfgData:InitEquipSchoolMap()
  self.EquipAttrSchoolMap = {}
  self.EquipSchoolFirstAttrIdMap = {}
  local rows = Z.TableMgr.GetTable("EquipAttrSchoolLibTableMgr").GetDatas()
  table.sort(rows, function(left, right)
    return left.Id < right.Id
  end)
  for _, value in pairs(rows) do
    if self.EquipAttrSchoolMap[value.AttrLibId] == nil then
      self.EquipAttrSchoolMap[value.AttrLibId] = {}
    end
    for k, talentSchoolId in ipairs(value.TalentSchoolId) do
      if self.EquipAttrSchoolMap[value.AttrLibId][talentSchoolId] == nil then
        self.EquipAttrSchoolMap[value.AttrLibId][talentSchoolId] = {}
      end
      self.EquipAttrSchoolMap[value.AttrLibId][talentSchoolId][value.SchoolNumber] = value.Id
    end
    if self.EquipSchoolFirstAttrIdMap[value.AttrLibId] == nil then
      self.EquipSchoolFirstAttrIdMap[value.AttrLibId] = value.Id
    end
  end
end

function EquipCfgData:InitCreateCfg()
  self.EquipCreateTableRows = {}
  local rows = Z.TableMgr.GetTable("EquipCreateTableMgr").GetDatas()
  local index = 1
  for _, value in pairs(rows) do
    self.EquipCreateTableRows[index] = value
    index = index + 1
  end
end

function EquipCfgData:InitEquipBreakCfg()
  if equipMap and equipMap.EquipIdBreakThroughTimeMap then
    self.EquipBreakIdLevelMap = equipMap.EquipIdBreakThroughTimeMap
    for configId, value in pairs(self.EquipBreakIdLevelMap) do
      self.EquipBreakConfigIdMap[configId] = configId
    end
  end
end

function EquipCfgData:InitEquipEnchantCfg()
  local datas = Z.TableMgr.GetTable("EquipEnchantItemTableMgr").GetDatas()
  local tb = {}
  for key, value in pairs(datas) do
    if tb[value.EnchantItemTypeId] == nil then
      tb[value.EnchantItemTypeId] = {}
    end
    tb[value.EnchantItemTypeId][value.EnchantItemLevel] = value
  end
  self.EnchantItemTableData = tb
  local datas = Z.TableMgr.GetTable("EquipEnchantTableMgr").GetDatas()
  local tab = {}
  for key, value in pairs(datas) do
    if tab[value.EnchantId] == nil then
      tab[value.EnchantId] = {}
    end
    tab[value.EnchantId][value.EnchantType] = value
  end
  self.EnchantTableData = tab
end

function EquipCfgData:InitRefineData()
  local equipRefineMgr = Z.TableMgr.GetTable("EquipRefineTableMgr").GetDatas()
  local tab = {}
  for k, v in pairs(equipRefineMgr) do
    if tab[v.RefineId] == nil then
      tab[v.RefineId] = {}
    end
    tab[v.RefineId][v.RefineLevel] = v
  end
  self.RefineTableData = tab
  local equipRefineBlessingMgr = Z.TableMgr.GetTable("EquipRefineBlessingTableMgr").GetDatas()
  local tab2 = {}
  for _, v in pairs(equipRefineBlessingMgr) do
    for __, v2 in ipairs(v.FitPart) do
      if tab2[v2] == nil then
        tab2[v2] = {}
      end
      tab2[v2][#tab2[v2] + 1] = v.Id
    end
  end
  self.RefineBlessingTableData = tab2
end

function EquipCfgData:InitRecastConfig()
  local equipPerfectLibRow = Z.TableMgr.GetTable("EquipPerfectLibTableMgr").GetDatas()
  local tab = {}
  local perfectTab = {}
  for index, value in pairs(equipPerfectLibRow) do
    if tab[value.PerfectLibId] == nil then
      tab[value.PerfectLibId] = value.PartLevel
    elseif tab[value.PerfectLibId] < value.PartLevel then
      tab[value.PerfectLibId] = value.PartLevel
    end
    if perfectTab[value.PerfectLibId] == nil then
      perfectTab[value.PerfectLibId] = {}
    end
    perfectTab[value.PerfectLibId][value.PartLevel] = value
  end
  if equipMap and equipMap.QualityGroup then
    for groupId, configIds in pairs(equipMap.QualityGroup) do
      self.EquipRareMap[groupId] = {}
      for index, configId in ipairs(configIds) do
        self.EquipRareMap[groupId][configId] = 1
      end
    end
  end
  self.RecastMaxLevelTab = tab
  self.RecastPerfectTab = perfectTab
end

function EquipCfgData:Clear()
end

function EquipCfgData:UnInit()
end

return EquipCfgData
