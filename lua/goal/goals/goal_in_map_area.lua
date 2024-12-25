local super = require("goal.goal_base")
local GoalInMapArea = class("GoalInMapArea", super)

function GoalInMapArea:ctor(data)
  super.ctor()
  self.configData_ = data
end

function GoalInMapArea:GetGoalKey()
  local data = self.configData_
  return E.GoalType.InMapArea .. data.SceneId .. data.AreaId
end

function GoalInMapArea:GoalInit()
  self:checkGoalFinish()
  Z.EventMgr:Add(Z.ConstValue.MapAreaChange, self.checkGoalFinish, self)
end

function GoalInMapArea:GoalUnInit()
  Z.EventMgr:RemoveObjAll(self)
end

function GoalInMapArea:checkGoalFinish()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId ~= self.configData_.SceneId then
    return
  end
  local mapData = Z.DataMgr.Get("map_data")
  if self.configData_.AreaId == 0 or mapData.CurAreaId == self.configData_.AreaId then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.InMapArea, self.configData_.AreaId)
  end
end

local create = function(strList)
  local data = {}
  data.SceneId = tonumber(strList[3])
  data.AreaId = tonumber(strList[4])
  return GoalInMapArea.new(data)
end
local ret = {Create = create}
return ret
