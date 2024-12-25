local super = require("goal.goal_base")
local GoalSubmitItem = class("GoalSubmitItem", super)

function GoalSubmitItem:ctor(data)
  super.ctor()
  self.configData_ = data
  self.talkData_ = Z.DataMgr.Get("talk_data")
end

function GoalSubmitItem:GetGoalKey()
  local data = self.configData_
  return E.GoalType.SubmitItem .. data.SceneId .. data.NpcId .. data.FlowId
end

function GoalSubmitItem:GoalInit()
  self.talkData_:AddFlowSubmitItem(self.configData_.FlowId, self.configData_.ItemList)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkSubmitItemCheck, self.onSubmitItemCheck, self)
end

function GoalSubmitItem:GoalUnInit()
  self.talkData_:RemoveFlowSubmitItem(self.configData_.FlowId)
  Z.EventMgr:RemoveObjAll(self)
end

function GoalSubmitItem:onSubmitItemCheck()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId ~= self.configData_.SceneId then
    return
  end
  local flowId = self.talkData_:GetTalkCurFlow()
  local npcId = self.talkData_:GetTalkingNpcId()
  if self.configData_.FlowId == flowId and self.configData_.NpcId == npcId then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.SubmitItem, self.configData_.NpcId, self.configData_.FlowId)
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.TalkSubmitItemSuccess)
  end
end

local create = function(strList)
  local data = {}
  data.SceneId = tonumber(strList[3])
  data.NpcId = tonumber(strList[4])
  data.FlowId = tonumber(strList[5])
  local itemList = {}
  for i = 6, #strList - 1, 2 do
    local configId = tonumber(strList[i])
    local num = tonumber(strList[i + 1])
    table.insert(itemList, {ConfigId = configId, Num = num})
  end
  data.ItemList = itemList
  return GoalSubmitItem.new(data)
end
local ret = {Create = create}
return ret
