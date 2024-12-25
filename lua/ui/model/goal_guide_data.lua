local super = require("ui.model.data_base")
local GoalGuideData = class("GoalGuideData", super)

function GoalGuideData:ctor()
  super.ctor(self)
  self:Clear()
end

function GoalGuideData:Clear()
  self.guideDict_ = {}
  Z.GoalGuideMgr:ClearAll()
end

function GoalGuideData:GetAllGuideGoalsDict()
  return self.guideDict_
end

function GoalGuideData:GetGuideGoalsBySource(src)
  return self.guideDict_[src]
end

function GoalGuideData:SetGuideGoals(src, goalList)
  self.guideDict_[src] = goalList
end

function GoalGuideData:RemoveGuideGoal(src, goalIndex)
  if self.guideDict_[src] then
    self.guideDict_[src][goalIndex] = nil
  end
end

return GoalGuideData
