local super = require("ui.model.data_base")
local CollectionScoreData = class("CollectionScoreData", super)

function CollectionScoreData:ctor()
  super.ctor(self)
end

function CollectionScoreData:Init()
end

function CollectionScoreData:OnReconnect()
end

function CollectionScoreData:Clear()
end

function CollectionScoreData:UnInit()
end

return CollectionScoreData
