local super = require("ui.model.data_base")
local SeasonAchievementData = class("SeasonAchievementData", super)

function SeasonAchievementData:ctor()
  super.ctor(self)
  self.tempAchievementDatas_ = Z.TableMgr.GetTable("AchievementDateTableMgr").GetDatas()
end

function SeasonAchievementData:Init()
  super.Init(self)
  self.selectClassify_ = nil
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
  self.achievementSelectColor_ = nil
  self.achievementUnSelectColor_ = nil
end

function SeasonAchievementData:OnReconnect()
  self.selectClassify_ = nil
  super.OnReconnect(self)
end

function SeasonAchievementData:Clear()
  super.Clear(self)
end

function SeasonAchievementData:UnInit()
  super.UnInit(self)
  self.selectClassify_ = nil
  self.achievementSelectColor_ = nil
  self.achievementUnSelectColor_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function SeasonAchievementData:SetSeason(season)
  if self.season_ == season then
    return
  end
  self.season_ = season
  self:resetAchievementLevelConfigData()
  self:resetAchievementData()
  self:resetAchievementFinishState()
end

function SeasonAchievementData:GetAchievementSelectColor()
  if not self.achievementSelectColor_ then
    self.achievementSelectColor_ = Color.New(0.45098039215686275, 0.4117647058823529, 0.30980392156862746, 1)
  end
  return self.achievementSelectColor_
end

function SeasonAchievementData:GetAchievementUnSelectColor()
  if not self.achievementUnSelectColor_ then
    self.achievementUnSelectColor_ = Color.New(0.25098039215686274, 0.22745098039215686, 0.17254901960784313, 1)
  end
  return self.achievementUnSelectColor_
end

function SeasonAchievementData:resetAchievementData()
  self.nextAchievements_ = {}
  for _, config in pairs(self.tempAchievementDatas_) do
    if config.PreAchievement > 0 then
      self.nextAchievements_[config.PreAchievement] = config
    end
  end
  self.classify_ = {}
  local configs = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetDatas()
  for id, config in pairs(configs) do
    self.classify_[id] = {}
    for _, v1 in pairs(config.EntryList) do
      if self.achievementsLevelConfigData_[v1] then
        for _, v2 in pairs(self.achievementsLevelConfigData_[v1]) do
          if v2 and v2.SeasonId == self.season_ and v2.PreAchievement == 0 then
            self.classify_[id][v2.Id] = {}
            table.insert(self.classify_[id][v2.Id], v2)
            local next = self.nextAchievements_[v2.Id]
            while next do
              table.insert(self.classify_[id][v2.Id], next)
              next = self.nextAchievements_[next.Id]
            end
          end
        end
      end
    end
  end
end

function SeasonAchievementData:resetAchievementFinishState()
  self.achievementFinishState_ = {}
  local data = Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList
  local seasonAchievements = data[self.season_]
  if not seasonAchievements then
    return
  end
  for id, achievement in pairs(seasonAchievements.seasonAchievement) do
    local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(id)
    if config then
      self.achievementFinishState_[id] = achievement.finishNum >= config.Num
    end
  end
end

function SeasonAchievementData:resetAchievementLevelConfigData()
  self.achievementsLevelConfigData_ = {}
  for _, config in pairs(self.tempAchievementDatas_) do
    if not self.achievementsLevelConfigData_[config.AchievementId] then
      self.achievementsLevelConfigData_[config.AchievementId] = {}
    end
    self.achievementsLevelConfigData_[config.AchievementId][config.AchievementLevel] = config
  end
end

function SeasonAchievementData:GetAchievementLevelConfigData(achievementId)
  return self.achievementsLevelConfigData_[achievementId]
end

function SeasonAchievementData:onLanguageChange()
  self.tempAchievementDatas_ = Z.TableMgr.GetTable("AchievementDateTableMgr").GetDatas()
  self:resetAchievementLevelConfigData()
  self:resetAchievementData()
end

function SeasonAchievementData:SetSelectClassify(classify)
  self.selectClassify_ = classify
end

function SeasonAchievementData:GetSelectClassify()
  return self.selectClassify_
end

function SeasonAchievementData:GetAchievementConfigDatas()
  return self.tempAchievementDatas_
end

return SeasonAchievementData
