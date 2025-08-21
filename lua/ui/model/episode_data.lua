local super = require("ui.model.data_base")
local EpisodeData = class("EpisodeData", super)

function EpisodeData:ctor()
  super.ctor(self)
end

function EpisodeData:Init()
  self:Clear()
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function EpisodeData:Uninit()
  Z.EventMgr:RemoveObjAll(self)
  self:Clear()
end

function EpisodeData:Clear()
  self.questChapterInfos_ = {}
end

function EpisodeData:GetChapterInfos(questType)
  return self.questChapterInfos_[questType]
end

function EpisodeData:SetChapterInfos(questType, questChapterInfos)
  self.questChapterInfos_[questType] = questChapterInfos
end

function EpisodeData:onLanguageChange()
  self:Clear()
end

function EpisodeData:OnReconnect()
end

return EpisodeData
