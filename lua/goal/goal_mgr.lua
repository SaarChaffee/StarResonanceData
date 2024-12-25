local goalCreator = require("goal.goal_creator")
local LuaGoalMgr = {}
LuaGoalMgr.goalDict_ = {}

function LuaGoalMgr:AddGoal(strList)
  local goal = goalCreator.CreateGoal(strList)
  if goal then
    local key = goal:GetGoalKey()
    if not self.goalDict_[key] then
      self.goalDict_[key] = goal
      goal:GoalInit()
      return key
    end
  end
end

function LuaGoalMgr:RemoveGoal(key)
  if not key then
    return
  end
  local goal = self.goalDict_[key]
  if goal then
    goal:GoalUnInit()
    self.goalDict_[key] = nil
  end
end

return LuaGoalMgr
