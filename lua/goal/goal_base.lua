local GoalBase = class("GoalBase")

function GoalBase:ctor()
end

function GoalBase:GetGoalKey()
  error("func must be override!")
end

function GoalBase:GoalInit()
end

function GoalBase:GoalUnInit()
end

return GoalBase
