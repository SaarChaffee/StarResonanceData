local super = require("ui.model.data_base")
local WorldBossData = class("WorldBossData", super)

function WorldBossData:ctor()
  super.ctor(self)
  self.matchVm_ = Z.VMMgr.GetVM("match")
end

function WorldBossData:Init()
  self.CancelSource = Z.CancelSource.Rent()
  self.needTips_ = true
  self.matchTimespan_ = 0
  self.hasPrepared_ = false
  self.recommendRedChecked_ = false
end

function WorldBossData:Clear()
  super.Clear(self)
  self.rankInfo_ = nil
  self.needTips_ = true
  self.matchStates_ = nil
  self.bossData_ = nil
  self.matchTimespan_ = 0
  self.matchStateType_ = nil
  self.hasPrepared_ = false
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

function WorldBossData:GetReadyMemberCount()
  local num = 0
  if self.matchStates_ then
    for _, value in pairs(self.matchStates_) do
      if value.readyStatus == E.RedayType.Ready then
        num = num + 1
      end
    end
  end
  return num
end

function WorldBossData:SetWorldBossMatchTime(time)
  self.matchTimespan_ = time
end

function WorldBossData:GetWorldBossMatchTime()
  return self.matchTimespan_
end

function WorldBossData:GetWorldBossMatchSuccessTime()
  return self.matchSuccessTimespan_
end

function WorldBossData:SetWorldBossMatchSuccessTime(time)
  self.matchSuccessTimespan_ = time
end

function WorldBossData:SetWorldBossMatchStateInfo(state)
  self.matchStateType_ = state
end

function WorldBossData:GetWorldBossMatchStateInfo()
  return self.matchStateType_
end

function WorldBossData:SetWorldBossPrepared(prepared)
  self.hasPrepared_ = prepared
end

function WorldBossData:GetWorldBossPrepared()
  return self.hasPrepared_
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
