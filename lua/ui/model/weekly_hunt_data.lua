local super = require("ui.model.data_base")
local WeeklyHuntData = class("WeeklyHuntData", super)

function WeeklyHuntData:ctor()
  super.ctor(self)
end

function WeeklyHuntData:Init()
  self.ClimbUpLayerDatas = {}
  self.ClimbRuleDatas = {}
  self.DungeonLayers = {}
  self.MemIdMaxClimbId = {}
  self.MaxLaler = {}
  self.ClimbUpRuleTableRow = {}
end

function WeeklyHuntData:Clear()
  self.ClimbUpLayerDatas = {}
end

function WeeklyHuntData:SetClimbUpLayerDatas(data)
  self.ClimbUpLayerDatas = data
end

function WeeklyHuntData:SetMaxLayer(layer)
  self.MaxLaler = layer
end

function WeeklyHuntData:SetClimbUpRuleTableRow(row)
  self.ClimbUpRuleTableRow = row
end

function WeeklyHuntData:SetClimbRuleDatas(data)
  self.ClimbRuleDatas = data
end

function WeeklyHuntData:SetDungeons(dungeons)
  self.DungeonLayers = dungeons
end

function WeeklyHuntData:GetClimbRuleDataBySeason(season)
  return self.ClimbRuleDatas[season]
end

function WeeklyHuntData:GetClimbUpLayerDatasBySeason(season)
  return self.ClimbUpLayerDatas[season]
end

function WeeklyHuntData:UnInit()
  self.ClimbUpLayerDatas = nil
end

return WeeklyHuntData
