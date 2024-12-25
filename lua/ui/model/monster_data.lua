local super = require("ui.model.data_base")
local MonsterData = class("MonsterData", super)

function MonsterData:ctor()
  super.ctor(self)
  self.SelectBossInfo = nil
  self.DangerClassTag = nil
  self.BossList = nil
  self.BossTopUuid = 0
  self.skillCDData = {}
end

function MonsterData:UpdateSkillCDData(skillLevelId, beginTime, duration, validCDTime)
  local cdTime = Z.Global.ImportSkillCountCD * 1000
  if self.skillCDData[skillLevelId] then
    self.skillCDData[skillLevelId].beginTime = beginTime + duration - cdTime
    self.skillCDData[skillLevelId].duration = duration
    self.skillCDData[skillLevelId].validCDTime = validCDTime
  else
    self.skillCDData[skillLevelId] = {}
    self.skillCDData[skillLevelId].beginTime = beginTime + duration - cdTime
    self.skillCDData[skillLevelId].duration = duration
    self.skillCDData[skillLevelId].validCDTime = validCDTime
  end
end

function MonsterData:ClearSkillCDData()
  self.skillCDData = {}
end

function MonsterData:RemoveSkillCDData(uuid)
  if self.skillCDData and next(self.skillCDData) then
    local cdTime = Z.Global.ImportSkillCountCD * 1000
    local keys = {}
    for k, v in pairs(self.skillCDData) do
      local endTime = math.ceil((v.beginTime + cdTime) / 1000)
      local nowTime = math.ceil(Z.ServerTime:GetServerTime() / 1000)
      if endTime <= nowTime then
        table.insert(keys, k)
      end
    end
    for k, v in ipairs(keys) do
      self.skillCDData[v] = nil
    end
  end
end

function MonsterData:GetSkillCDData()
  return self.skillCDData
end

return MonsterData
