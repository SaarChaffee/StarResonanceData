local GoalSubmitItem = require("goal.goals.goal_submit_item")
local GoalShowItem = require("goal.goals.goal_show_item")
local GoalInMapArea = require("goal.goals.goal_in_map_area")
local GoalDoExpression = require("goal.goals.goal_do_expression")
local createGoal = function(strList)
  local goalType = tonumber(strList[1])
  if goalType == E.GoalType.SubmitItem then
    return GoalSubmitItem.Create(strList)
  elseif goalType == E.GoalType.ShowItem then
    return GoalShowItem.Create(strList)
  elseif goalType == E.GoalType.InMapArea then
    return GoalInMapArea.Create(strList)
  elseif goalType == E.GoalType.DoExpression then
    return GoalDoExpression.Create(strList)
  end
end
local ret = {CreateGoal = createGoal}
return ret
