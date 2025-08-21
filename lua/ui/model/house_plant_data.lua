local super = require("ui.model.data_base")
local HousePlantData = class("HousePlantData", super)

function HousePlantData:ctor()
  super.ctor(self)
end

function HousePlantData:Init()
  self.SeedTypeMap = {}
  self.PollenMap = {}
  self:InitCfg()
end

function HousePlantData:InitCfg()
  local seedTable = Z.TableMgr.GetTable("HomeSeedTableMgr").GetDatas()
  local index = 1
  for key, value in pairs(seedTable) do
    if self.SeedTypeMap[value.Type] == nil then
      self.SeedTypeMap[value.Type] = {}
    end
    local list = self.SeedTypeMap[value.Type]
    list[#list + 1] = value
    index = index + 1
  end
  local pollenTable = Z.TableMgr.GetTable("HomePollenTableMgr").GetDatas()
  for key, value in pairs(pollenTable) do
    if self.PollenMap[value.Type] == nil then
      self.PollenMap[value.Type] = {}
    end
    self.PollenMap[value.Type][#self.PollenMap[value.Type] + 1] = value
  end
end

function HousePlantData:UnInit()
end

function HousePlantData:GetSeedListByTypes(types)
  local list = {}
  for k, type in ipairs(types) do
    if self.SeedTypeMap[type] then
      table.zmerge(list, self.SeedTypeMap[type])
    end
  end
  return list
end

function HousePlantData:Clear()
end

function HousePlantData:OnLanguageChange()
  self:InitCfg()
end

return HousePlantData
