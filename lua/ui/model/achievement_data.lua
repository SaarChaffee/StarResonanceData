local super = require("ui.model.data_base")
local AchievementData = class("AchievementData", super)
local AchievementDefine = require("ui.model.achievement_define")
local AchievementClassTableMap = require("table.AchievementClassTableMap")
local AchievementDataTableMap = require("table.AchievementDateTableMap")

function AchievementData:ctor()
  super.ctor(self)
end

function AchievementData:Init()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function AchievementData:OnReconnect()
end

function AchievementData:Clear()
end

function AchievementData:UnInit()
end

function AchievementData:SetSeason(season)
  local achievementClassMgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
  local achievementClass = AchievementClassTableMap.Classes
  for key, value in pairs(achievementClass) do
    if key == AchievementDefine.PermanentAchievementType then
      for _, class in ipairs(value) do
        local classNodeName = self.achievementVM_.GetRedNodeId(class)
        Z.RedPointMgr.AddChildNodeData(E.RedType.Achievement, E.RedType.Achievement, classNodeName)
        local config = achievementClassMgr.GetRow(class)
        if config and config.EntryList then
          for _, entry in ipairs(config.EntryList) do
            local entryNodeName = self.achievementVM_.GetRedNodeId(entry)
            Z.RedPointMgr.AddChildNodeData(classNodeName, E.RedType.Achievement, entryNodeName)
            local datas = AchievementDataTableMap.Dates[entry]
            if datas then
              for _, data in ipairs(datas) do
                local dataNodeName = self.achievementVM_.GetRedNodeId(data)
                Z.RedPointMgr.AddChildNodeData(entryNodeName, E.RedType.Achievement, dataNodeName)
              end
            end
          end
        end
      end
    elseif key == season then
      for _, class in ipairs(value) do
        local classNodeName = self.achievementVM_.GetRedNodeId(class)
        Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonAchievement, E.RedType.SeasonAchievement, classNodeName)
        local config = achievementClassMgr.GetRow(class)
        if config and config.EntryList then
          for _, entry in ipairs(config.EntryList) do
            local entryNodeName = self.achievementVM_.GetRedNodeId(entry)
            Z.RedPointMgr.AddChildNodeData(classNodeName, E.RedType.SeasonAchievement, entryNodeName)
            local datas = AchievementDataTableMap.Dates[entry]
            if datas then
              for _, data in ipairs(datas) do
                local dataNodeName = self.achievementVM_.GetRedNodeId(data)
                Z.RedPointMgr.AddChildNodeData(entryNodeName, E.RedType.SeasonAchievement, dataNodeName)
              end
            end
          end
        end
      end
    end
  end
end

return AchievementData
