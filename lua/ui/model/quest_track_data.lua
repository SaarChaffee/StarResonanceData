local super = require("ui.model.data_base")
local QuestTrackData = class("QuestTrackData", super)

function QuestTrackData:ctor()
  super.ctor(self)
end

function QuestTrackData:Init()
  self.proactiveQuestId = 0
end

function QuestTrackData:Clear()
end

function QuestTrackData:UnInit()
end

function QuestTrackData:SetProactiveQuestId(questId)
  self.proactiveQuestId = questId
end

function QuestTrackData:GetProactiveQuestId()
  return self.proactiveQuestId
end

return QuestTrackData
