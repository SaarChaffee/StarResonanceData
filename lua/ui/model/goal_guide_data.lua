local super = require("ui.model.data_base")
local GoalGuideData = class("GoalGuideData", super)

function GoalGuideData:ctor()
  super.ctor(self)
  self:Clear()
end

function GoalGuideData:Clear()
  self.guideDict_ = {}
  self.lastGuideData_ = nil
  Z.GoalGuideMgr:ClearAll()
end

function GoalGuideData:GetAllGuideGoalsDict()
  return self.guideDict_
end

function GoalGuideData:GetGuideGoalsBySource(src)
  return self.guideDict_[src]
end

function GoalGuideData:SetGuideGoals(src, goalList, sourceGoalList)
  self.guideDict_[src] = goalList
  if goalList and 0 < #goalList then
    self:SetLastGuideData(src, goalList[1], sourceGoalList)
  else
    self:SetLastGuideData(src, nil, sourceGoalList)
  end
end

function GoalGuideData:RemoveGuideGoal(src, goalIndex)
  if self.guideDict_[src] then
    local sourceGoalInfo = self.guideDict_[src][goalIndex]
    if sourceGoalInfo then
      if sourceGoalInfo == self:GetLastGuideData() then
        self:SetLastGuideData(src, nil)
      end
      self.guideDict_[src][goalIndex] = nil
    end
  end
end

function GoalGuideData:SetLastGuideData(src, goalPosInfo, sourceGoalList)
  local resultGoalInfo = goalPosInfo
  if sourceGoalList and next(sourceGoalList) then
    resultGoalInfo = sourceGoalList[1]
  end
  if resultGoalInfo == nil then
    if self.lastGuideData_ and self.lastGuideData_.src == src then
      self.lastGuideData_ = nil
      if src ~= E.GoalGuideSource.Quest then
        local questGoalGuideVM = Z.VMMgr.GetVM("quest_goal_guide")
        questGoalGuideVM.UpdateSceneGuideGoal()
      end
    end
  else
    self.lastGuideData_ = {src = src, goalPosInfo = resultGoalInfo}
  end
end

function GoalGuideData:GetLastGuideData()
  if self.lastGuideData_ then
    return self.lastGuideData_.goalPosInfo
  end
end

return GoalGuideData
