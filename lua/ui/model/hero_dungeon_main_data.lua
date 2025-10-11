local super = require("ui.model.data_base")
local HeroDungeonData = class("HeroDungeonData", super)

function HeroDungeonData:ctor()
  super.ctor(self)
  self.ScenceId = 0
  self.FunctionId = 0
  self.ChallengeScenceIdTab = {}
  self.IsChellange = false
  self.NowLevelGs = 0
  self.RecommendFightValue = 0
  self.PlayerGs = 0
  self.MinCount = 1
  self.MaxCount = 4
  self.IsHaveAward = true
  self.NormalHeroAwardLimitTime = 0
  self.affixValueList = {}
  self.IsBeginSettleTime = false
  self.InstabilityIsTeam = true
  self.keyItemUuid_ = 0
  self.TeamDisplayData = {}
  self.DunegonEndTime = 0
  self.masterDungeonScore = {}
end

function HeroDungeonData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.AffixDic = {}
  self.ExtremeSpaceAffixDict_ = {}
  self.CancelSource = Z.CancelSource.Rent()
  self:InitCfgData()
end

function HeroDungeonData:InitCfgData()
  self.HeroDungeonTargetTableDatas = Z.TableMgr.GetTable("HeroDungeonTargetTableMgr").GetDatas()
end

function HeroDungeonData:OnLanguageChange()
  self:InitCfgData()
end

function HeroDungeonData:UnInit()
  self.CancelSource:Recycle()
end

function HeroDungeonData:Clear()
  self.AffixDic = {}
  self.ExtremeSpaceAffixDict_ = {}
  self.masterDungeonScore = {}
end

function HeroDungeonData:SetBeginCount(min, max)
  self.MinCount = min
  self.MaxCount = max
end

function HeroDungeonData:SetNowGs(gs)
  self.NowLevelGs = gs
end

function HeroDungeonData:SetRecommendFightValue(value)
  self.RecommendFightValue = value
end

function HeroDungeonData:SetPlayerGs(gs)
  self.PlayerGs = gs
end

function HeroDungeonData:SetNowPattern(isflag)
  self.IsChellange = isflag
end

function HeroDungeonData:SetHaveAward(isflag)
  self.IsHaveAward = not isflag
end

function HeroDungeonData:SetDungeonList(dungeonList)
  self.DungeonList = dungeonList
end

function HeroDungeonData:SetChallengeScenceId(tab)
  self.ChallengeScenceIdTab = tab
end

function HeroDungeonData:GetChallengeScenceIdTab()
  return self.ChallengeScenceIdTab
end

function HeroDungeonData:SetScenceId(id)
  self.ScenceId = id
end

function HeroDungeonData:SetFunctionId(id)
  self.FunctionId = id
end

function HeroDungeonData:SetNormalHeroAwardCount(count)
  self.NormalHeroAwardLimitTime = count
end

function HeroDungeonData:GetNormalHeroAwardCount()
  return self.NormalHeroAwardLimitTime
end

function HeroDungeonData:GetAffixArray()
  return Z.ContainerMgr.DungeonSyncData.dungeonAffixData.affixData
end

function HeroDungeonData:GetDungeonKeyInfo()
  return Z.ContainerMgr.DungeonSyncData.heroKey
end

function HeroDungeonData:SetAffixValueList(list)
  self.affixValueList = list
end

function HeroDungeonData:GetAffixValueList()
  return self.affixValueList
end

function HeroDungeonData:SetUseKeyData(itemUuid)
  self.keyItemUuid_ = itemUuid
end

function HeroDungeonData:GetUseKeyData()
  return self.keyItemUuid_
end

function HeroDungeonData:GetMasterDungeonScore(seasonId)
  if seasonId == nil then
    seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  end
  if self.masterDungeonScore[seasonId] == nil then
    self.masterDungeonScore[seasonId] = {}
    local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
    local masterChallengeDungeonTableData = Z.TableMgr.GetTable("MasterChallengeDungeonTableMgr"):GetDatas()
    for _, value in pairs(masterChallengeDungeonTableData) do
      if value.SeasonId == seasonId then
        if self.masterDungeonScore[seasonId][value.DungeonId] == nil then
          self.masterDungeonScore[seasonId][value.DungeonId] = {
            score = 0,
            time = 0,
            diff = 1,
            dungeonId = value.DungeonId,
            masterChallengeDungeonId = value.DungeonId * 100 + 1
          }
        end
        if seasonMasterDungeonInfo then
          local seasonMasterDiffInfo = seasonMasterDungeonInfo.masterModeDiffInfo
          if seasonMasterDiffInfo and seasonMasterDiffInfo[value.DungeonId] and seasonMasterDiffInfo[value.DungeonId].dungeonInfo then
            local dungeonInfo = seasonMasterDiffInfo[value.DungeonId].dungeonInfo[value.Difficulty]
            if dungeonInfo and dungeonInfo.score > self.masterDungeonScore[seasonId][value.DungeonId].score then
              self.masterDungeonScore[seasonId][value.DungeonId].score = dungeonInfo.score
              self.masterDungeonScore[seasonId][value.DungeonId].time = dungeonInfo.passTime
              self.masterDungeonScore[seasonId][value.DungeonId].diff = value.Difficulty
              self.masterDungeonScore[seasonId][value.DungeonId].masterChallengeDungeonId = value.DungeonId * 100 + value.Difficulty
            end
          end
        end
      end
    end
  end
  return self.masterDungeonScore[seasonId]
end

function HeroDungeonData:UpdateMasterDungeonScore(dungeonId)
  local seasonId = Z.VMMgr.GetVM("season").GetCurrentSeasonId()
  if self.masterDungeonScore[seasonId] == nil then
    self:GetMasterDungeonScore(seasonId)
  end
  local seasonMasterDungeonInfo = Z.ContainerMgr.CharSerialize.masterModeDungeonInfo.masterModeDungeonInfo[seasonId]
  if seasonMasterDungeonInfo and seasonMasterDungeonInfo.masterModeDiffInfo and seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId] then
    for diff, dungenData in pairs(seasonMasterDungeonInfo.masterModeDiffInfo[dungeonId].dungeonInfo) do
      if self.masterDungeonScore[seasonId][dungeonId].score < dungenData.score then
        self.masterDungeonScore[seasonId][dungeonId].score = dungenData.score
        self.masterDungeonScore[seasonId][dungeonId].time = dungenData.passTime
        self.masterDungeonScore[seasonId][dungeonId].diff = diff
        self.masterDungeonScore[seasonId][dungeonId].masterChallengeDungeonId = dungeonId * 100 + diff
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateMasterDungeonScore)
end

return HeroDungeonData
