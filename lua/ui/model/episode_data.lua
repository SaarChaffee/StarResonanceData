local super = require("ui.model.data_base")
local EpisodeData = class("EpisodeData", super)

function EpisodeData:ctor()
  super.ctor(self)
end

function EpisodeData:Init()
  self:Clear()
end

function EpisodeData:Uninit()
  self:Clear()
end

function EpisodeData:Clear()
  self.questCatalogueInfos_ = {}
end

function EpisodeData:SetEpisodeChapterInfos(questType, questInfos)
  self.questCatalogueInfos_[questType] = questInfos
end

function EpisodeData:GetEpisodeQuestInfos(questType)
  return self.questCatalogueInfos_[questType]
end

function EpisodeData:OnReconnect()
end

return EpisodeData
