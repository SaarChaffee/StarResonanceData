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

return HeroDungeonData
