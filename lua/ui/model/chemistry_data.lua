local super = require("ui.model.data_base")
local ChemistryData = class("ChemistryData", super)

function ChemistryData:ctor()
  super.ctor(self)
  self:ResetData()
end

function ChemistryData:Init()
end

function ChemistryData:UnInit()
end

function ChemistryData:Clear()
end

function ChemistryData:OnReconnect()
end

function ChemistryData:ResetData()
  self.chemistryProductionConfigs_ = {}
  local lifeProductionListDatas = Z.TableMgr.GetTable("LifeProductionListTableMgr").GetDatas()
  for _, data in pairs(lifeProductionListDatas) do
    if data.LifeProId == E.ELifeProfession.Chemistry and data.RandomWeight ~= 0 and data.NeedMaterial and data.NeedMaterial[1] and data.NeedMaterial[1][1] then
      if self.chemistryProductionConfigs_[data.NeedMaterial[1][1]] == nil then
        self.chemistryProductionConfigs_[data.NeedMaterial[1][1]] = {}
      end
      table.insert(self.chemistryProductionConfigs_[data.NeedMaterial[1][1]], data)
    end
  end
  for _, configs in pairs(self.chemistryProductionConfigs_) do
    table.sort(configs, function(a, b)
      if a.Sort == b.Sort then
        return a.Id < b.Id
      else
        return a.Sort < b.Sort
      end
    end)
  end
  self.chemistryMaterialTypeKey_ = {}
  local chemistryMaaterialDatas = Z.TableMgr.GetTable("ChemistryMaterialTableMgr").GetDatas()
  for _, data in pairs(chemistryMaaterialDatas) do
    if data.CanExperiment then
      if self.chemistryMaterialTypeKey_[data.TypeA] == nil then
        self.chemistryMaterialTypeKey_[data.TypeA] = {}
      end
      table.insert(self.chemistryMaterialTypeKey_[data.TypeA], data)
    end
  end
  for _, configs in pairs(self.chemistryMaterialTypeKey_) do
    table.sort(configs, function(a, b)
      if a.Sort == b.Sort then
        return a.Id < b.Id
      else
        return a.Sort < b.Sort
      end
    end)
  end
end

function ChemistryData:GetProductions(materialId)
  if self.chemistryProductionConfigs_[materialId] ~= nil then
    return self.chemistryProductionConfigs_[materialId]
  end
  return {}
end

function ChemistryData:GetMaterialByType(type)
  if self.chemistryMaterialTypeKey_[type] ~= nil then
    return self.chemistryMaterialTypeKey_[type]
  end
  return {}
end

return ChemistryData
