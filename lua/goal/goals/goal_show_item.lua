local super = require("goal.goal_base")
local GoalShowItem = class("GoalShowItem", super)

function GoalShowItem:ctor(data)
  super.ctor()
  self.configData_ = data
  self.talkData_ = Z.DataMgr.Get("talk_data")
end

function GoalShowItem:GetGoalKey()
  local data = self.configData_
  return E.GoalType.ShowItem .. data.SceneId .. data.NpcId .. data.FlowId
end

function GoalShowItem:GoalInit()
  self.talkData_:AddFlowShowItem(self.configData_.FlowId, self.configData_.ItemList)
  Z.EventMgr:Add(Z.ConstValue.NpcTalk.TalkShowItemCheck, self.onShowItemCheck, self)
end

function GoalShowItem:GoalUnInit()
  self.talkData_:RemoveFlowShowItem(self.configData_.FlowId)
  Z.EventMgr:RemoveObjAll(self)
end

function GoalShowItem:onShowItemCheck()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  if sceneId ~= self.configData_.SceneId then
    return
  end
  local flowId = self.talkData_:GetTalkCurFlow()
  local npcId = self.talkData_:GetTalkingNpcId()
  if self.configData_.FlowId == flowId and self.configData_.NpcId == npcId then
    local goalVM = Z.VMMgr.GetVM("goal")
    goalVM.SetGoalFinish(E.GoalType.ShowItem, self.configData_.NpcId, self.configData_.FlowId)
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.TalkShowItemSuccess)
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
  return GoalShowItem.new(data)
end
local ret = {Create = create}
return ret
