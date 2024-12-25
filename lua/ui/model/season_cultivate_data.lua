local super = require("ui.model.data_base")
local SeasonCultivateData = class("SeasonCultivateData", super)

function SeasonCultivateData:ctor()
  super.ctor(self)
end

function SeasonCultivateData:Init()
  super.Init(self)
  self.season_ = 0
  self.seasonHoles_ = {}
  self.seasonAttributes_ = {}
  self.seasonHoleMaxLevel_ = {}
  self.seasonHoleExp_ = {}
end

function SeasonCultivateData:OnReconnect()
  super.OnReconnect(self)
end

function SeasonCultivateData:Clear()
  super.Clear(self)
  self.season_ = nil
  self.seasonHoles_ = nil
  self.seasonAttributes_ = nil
  self.seasonHoleMaxLevel_ = nil
  self.seasonHoleExp_ = nil
end

function SeasonCultivateData:UnInit()
  super.UnInit(self)
  self.season_ = nil
  self.seasonHoles_ = nil
  self.seasonAttributes_ = nil
  self.seasonHoleMaxLevel_ = nil
  self.seasonHoleExp_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function SeasonCultivateData:SetSeason(season)
  if self.season_ == season then
    return
  end
  self.season_ = season
  self:resetCultivateData()
end

function SeasonCultivateData:onLanguageChange()
  self:resetCultivateData()
end

function SeasonCultivateData:resetCultivateData()
  self.seasonHoles_ = {}
  self.seasonHoleMaxLevel_ = {}
  self.seasonHoleExp_ = {}
  local seasonNodeTable = Z.TableMgr.GetTable("SeasonNodeTableMgr")
  for _, nodeConfig in pairs(seasonNodeTable.GetDatas()) do
    if nodeConfig.SeasonId == self.season_ then
      local holeId = nodeConfig.HoleId
      local level = nodeConfig.HoleLevel
      if not self.seasonHoles_[holeId] then
        self.seasonHoles_[holeId] = {}
        self.seasonHoleMaxLevel_[holeId] = level
        self.seasonHoleExp_[holeId] = {}
      end
      if level > self.seasonHoleMaxLevel_[holeId] then
        self.seasonHoleMaxLevel_[holeId] = level
      end
      self.seasonHoles_[holeId][level] = nodeConfig
      self.seasonHoleExp_[holeId][level] = nodeConfig.ProgressValue
    end
  end
  self.seasonAttributes_ = {}
  local seasonNodeDataTable = Z.TableMgr.GetTable("SeasonNodeDataTableMgr")
  for _, nodeDataConfig in pairs(seasonNodeDataTable.GetDatas()) do
    local nodeId = nodeDataConfig.NodeId
    local level = nodeDataConfig.NodeLevel
    if not self.seasonAttributes_[nodeId] then
      self.seasonAttributes_[nodeId] = {}
    end
    self.seasonAttributes_[nodeId][level] = nodeDataConfig
  end
end

return SeasonCultivateData
