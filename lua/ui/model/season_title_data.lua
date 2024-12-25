local super = require("ui.model.data_base")
local SeasonTitleData = class("SeasonTitleData", super)

function SeasonTitleData:ctor()
  super.ctor(self)
  self.curSeasonId_ = -1
  self.rankInfoConfig_ = {}
  self.rankInfoConfigList_ = {}
  self.coreRandInfoConfig_ = {}
  self.armbandInfoConfig_ = {}
  self.finalRankInfoConfigList_ = {}
  self.allRankInfoConfigLists_ = {}
  self.maxRank_ = -1
  self.minRank_ = -1
  self.maxRewardRank_ = -1
  self.minRewardRank_ = -1
end

function SeasonTitleData:Init()
  super.Init(self)
  self.CancelSource = Z.CancelSource.Rent()
end

function SeasonTitleData:Clear()
  super.Clear(self)
end

function SeasonTitleData:UnInit()
  super.UnInit(self)
end

function SeasonTitleData.rankConfigSort(a, b)
  if a.RankId == b.RankId then
    return a.Id < b.Id
  else
    return a.RankId < b.RankId
  end
end

function SeasonTitleData:InitConfig()
  self.rankInfoConfig_ = {}
  self.rankInfoConfigList_ = {}
  self.coreRandInfoConfig_ = {}
  self.armbandInfoConfig_ = {}
  self.allRankInfoConfigLists_ = {}
  local index = 0
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local seasonRankConfigs = seasonRankTableMgr.GetDatas()
  for _, value in pairs(seasonRankConfigs) do
    if value.SeasonId == self.curSeasonId_ then
      index = index + 1
      self.allRankInfoConfigLists_[index] = value
      if self.rankInfoConfig_[value.RankId] == nil then
        self.rankInfoConfig_[value.RankId] = {}
      end
      if value.RewardId ~= 0 then
        table.insert(self.rankInfoConfigList_, value)
      end
      if self.minRank_ == -1 then
        self.minRank_ = value.RankId
      end
      if self.minRewardRank_ == -1 and value.RewardId ~= 0 then
        self.minRewardRank_ = value.RankId
      end
      if self.maxRank_ <= value.RankId then
        self.maxRank_ = value.RankId
      end
      if value.RewardId ~= 0 then
        self.maxRewardRank_ = value.RankId
      end
      table.insert(self.rankInfoConfig_[value.RankId], value)
      if value.CoreRewardId and 0 < #value.CoreRewardId then
        table.insert(self.coreRandInfoConfig_, value)
      end
      if value.ArmbandReward and 0 < value.ArmbandReward then
        table.insert(self.armbandInfoConfig_, value)
      end
      if value.FinalRewardId and 0 < #value.FinalRewardId then
        table.insert(self.finalRankInfoConfigList_, value)
      end
    end
  end
  table.sort(self.rankInfoConfigList_, self.rankConfigSort)
  table.sort(self.coreRandInfoConfig_, self.rankConfigSort)
  table.sort(self.armbandInfoConfig_, self.rankConfigSort)
  table.sort(self.allRankInfoConfigLists_, self.rankConfigSort)
end

function SeasonTitleData:SetCurSeasonId(seasonId)
  self.curSeasonId_ = seasonId
  self:InitConfig()
end

function SeasonTitleData:GetCurSeasonId()
  return self.curSeasonId_
end

function SeasonTitleData:GetCurRankInfo()
  local allSeasonRankLIst = Z.ContainerMgr.CharSerialize.seasonRankList.seasonRankList
  return allSeasonRankLIst[self.curSeasonId_]
end

function SeasonTitleData:GetAllConfigs()
  return self.rankInfoConfig_
end

function SeasonTitleData:GetRankRewardConfigList()
  return self.rankInfoConfigList_
end

function SeasonTitleData:GetRankIdConfig(rankId)
  for _, v in ipairs(self.rankInfoConfigList_) do
    if v.RankId == rankId then
      return v
    end
  end
  return nil
end

function SeasonTitleData:GetMaxRankId()
  return self.maxRank_
end

function SeasonTitleData:GetMinRankId()
  return self.minRank_
end

function SeasonTitleData:GetMaxRewardRankId()
  return self.maxRewardRank_
end

function SeasonTitleData:GetMinRewardRankId()
  return self.minRewardRank_
end

function SeasonTitleData:GetCoreRewardList()
  return self.coreRandInfoConfig_
end

function SeasonTitleData:GetArmbandRewardList()
  return self.armbandInfoConfig_
end

function SeasonTitleData:GetFinalRewardList()
  return self.finalRankInfoConfigList_
end

function SeasonTitleData:GetAllRankConfigList()
  return self.allRankInfoConfigLists_
end

return SeasonTitleData
