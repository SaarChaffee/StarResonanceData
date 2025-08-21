local super = require("ui.model.data_base")
local WorldBossData = class("WorldBossData", super)

function WorldBossData:ctor()
  super.ctor(self)
end

function WorldBossData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.needTips_ = true
  self.recommendRedChecked_ = false
end

function WorldBossData:Clear()
  super.Clear(self)
  self.rankInfo_ = nil
  self.needTips_ = true
  self.bossData_ = nil
  self.recommendRedChecked_ = false
end

function WorldBossData:UnInit()
  self.CancelSource:Recycle()
end

function WorldBossData:SetWorldBossRankInfo(info)
  self.rankInfo_ = info
end

function WorldBossData:GetWorldBossRankInfo()
  return self.rankInfo_
end

function WorldBossData:SetWorldBossInfoData(info)
  self.bossData_ = info
end

function WorldBossData:GetWorldBossInfoData()
  return self.bossData_
end

function WorldBossData:GetWorldBossStageTableDatas()
  local tableMgr = Z.TableMgr.GetTable("WorldBossStageTableMgr")
  if not self.worldBossStageTableDatas then
    self.worldBossStageTableDatas = tableMgr.GetDatas()
  end
  return self.worldBossStageTableDatas
end

function WorldBossData:onLanguageChange()
  local tableMgr = Z.TableMgr.GetTable("WorldBossStageTableMgr")
  self.worldBossStageTableDatas = tableMgr.GetDatas()
end

function WorldBossData:SetRecommendRedChecked(checked)
  self.recommendRedChecked_ = checked
end

function WorldBossData:RecommendRedChecked()
  return self.recommendRedChecked_
end

return WorldBossData
