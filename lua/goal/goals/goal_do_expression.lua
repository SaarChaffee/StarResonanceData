local super = require("goal.goal_base")
local GoalDoExpression = class("GoalDoExpression", super)

function GoalDoExpression:ctor(data)
  super.ctor()
  self.configData_ = data
end

function GoalDoExpression:GetGoalKey()
  local data = self.configData_
  return E.GoalType.DoExpression .. data.SceneId .. data.ZoneUid .. data.ActionId .. data.EmotionId
end

function GoalDoExpression:GoalInit()
  Z.EventMgr:Add(Z.ConstValue.Expression.ClickAction, self.checkAction, self)
  Z.EventMgr:Add(Z.ConstValue.Expression.ClickEmotion, self.checkEmotion, self)
end

function GoalDoExpression:GoalUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function GoalDoExpression:checkAction(actionId)
  if self:checkZone() and self.configData_.ActionId == actionId then
    self:setGoalFinish()
  end
end

function GoalDoExpression:checkEmotion(emotionId)
  if self:checkZone() and self.configData_.EmotionId == emotionId then
    self:setGoalFinish()
  end
end

function GoalDoExpression:checkZone()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId ~= self.configData_.SceneId then
    return false
  end
  return Z.LuaBridge.IsPlayerInZone(self.configData_.ZoneUid)
end

function GoalDoExpression:setGoalFinish()
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(E.GoalType.DoExpression, self.configData_.ZoneUid, self.configData_.ActionId, self.configData_.EmotionId)
end

local create = function(strList)
  local data = {}
  data.SceneId = tonumber(strList[3])
  data.ZoneUid = tonumber(strList[4])
  data.ActionId = tonumber(strList[5])
  data.EmotionId = tonumber(strList[6])
  return GoalDoExpression.new(data)
end
local ret = {Create = create}
return ret
