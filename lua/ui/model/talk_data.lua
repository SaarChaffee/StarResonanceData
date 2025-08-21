local super = require("ui.model.data_base")
local TalkData = class("TalkData", super)

function TalkData:ctor()
  super.ctor(self)
  self:Clear()
end

function TalkData:Clear()
  self.IsDelayQuit = false
  self:ClearPlayFlowInfo()
  self.curFlow_ = 0
  self:InitConfrontation()
  self.talkingNpcData_ = nil
  self.isAllowSkip_ = false
  self.flowSubmitItemDict_ = {}
  self.flowShowItemDict_ = {}
  self.npcFlowTalkDict_ = {}
  self.npcChangedTalkFlowDict_ = {}
  self.selectInterrogateDict_ = {}
  Z.QuestMgr:ClearNpcQuestTalkState()
end

function TalkData:GetTalkCurFlow()
  return self.curFlow_
end

function TalkData:SetTalkCurFlow(flowId)
  self.curFlow_ = flowId
  self.selectInterrogateDict_ = {}
end

function TalkData:SetPlayFlowIdData(flowId, state, flowPlaySource, parentFlowId, owner)
  if flowId == nil then
    logError("SetPlayFlowIdData flowId is nil")
    return
  end
  if self.curPlayFlowInfos_ == nil then
    self.curPlayFlowInfos_ = {}
  end
  if state == E.FlowPlayStateEnum.Finish then
    self.curPlayFlowInfos_[flowId] = nil
    return
  end
  local info = self.curPlayFlowInfos_[flowId]
  if info == nil then
    info = {}
    self.curPlayFlowInfos_[flowId] = info
  end
  info.flowId = flowId
  info.state = state
  info.flowPlaySource = flowPlaySource
  info.parentFlowId = parentFlowId
  info.owner = owner
  if parentFlowId ~= nil then
    local parentInfo = self:GetPlayFlowIdInfo(parentFlowId)
    if parentInfo == nil then
      return
    end
    if parentInfo.childFlowIds == nil then
      parentInfo.childFlowIds = {}
    end
    if parentInfo.owner ~= nil then
      info.owner = parentInfo.owner
    end
    table.insert(parentInfo.childFlowIds, flowId)
  end
end

function TalkData:RefreshPlayFlowIdState(flowId, state)
  if self.curPlayFlowInfos_ == nil or flowId == nil then
    return
  end
  local info = self.curPlayFlowInfos_[flowId]
  if info == nil then
    return
  end
  if state == E.FlowPlayStateEnum.Finish then
    self.curPlayFlowInfos_[flowId] = nil
    return
  end
  info.state = state
end

function TalkData:GetPlayFlowIdInfo(flowId)
  if flowId == nil then
    logError("GetPlayFlowIdInfo flowId is nil")
    return nil
  end
  if self.curPlayFlowInfos_ == nil then
    return nil
  end
  return self.curPlayFlowInfos_[flowId]
end

function TalkData:GetFlowIdByOwner(owner)
  if owner == nil or self.curPlayFlowInfos_ == nil then
    logError("GetFlowIdByOwner owner is nil")
    return nil
  end
  for key, value in pairs(self.curPlayFlowInfos_) do
    if value.owner == owner then
      return key
    end
  end
  return nil
end

function TalkData:GetPlayFlowCount()
  if self.curPlayFlowInfos_ == nil then
    return 0
  end
  return table.zcount(self.curPlayFlowInfos_)
end

function TalkData:ClearPlayFlowInfo()
  logGreen("[TalkData] ClearPlayFlowInfo")
  Z.EPFlowBridge.StopAllFlow()
  if self.curPlayFlowInfos_ == nil then
    self.curPlayFlowInfos_ = {}
    return
  end
  local talkVM = Z.VMMgr.GetVM("talk")
  for key, value in pairs(self.curPlayFlowInfos_) do
    logGreen("[TalkData] ClearPlayFlowInfo flowId = " .. key .. " state = " .. tostring(value.state))
    if value.state == E.FlowPlayStateEnum.WaitNpc then
      talkVM.EndTalkState()
    end
  end
  self.curPlayFlowInfos_ = {}
end

function TalkData:GetAllPlayFlow()
  return self.curPlayFlowInfos_
end

function TalkData:InitConfrontation()
  self.TrustValue = 40
  self.TimeValue = 10
  self.NeutralTab = {}
end

function TalkData:GetTalkingNpcId()
  if self.talkingNpcData_ ~= nil then
    return self.talkingNpcData_.npcId
  end
  return 0
end

function TalkData:GetTalkingNpcUuid()
  if self.talkingNpcData_ ~= nil then
    return self.talkingNpcData_.uuid
  end
  return 0
end

function TalkData:GetTalkingNpcData()
  return self.talkingNpcData_
end

function TalkData:SetTalkingNpcData(npcData)
  self.talkingNpcData_ = npcData
end

function TalkData:GetNodeIsAllowSkip()
  return self.isAllowSkip_
end

function TalkData:SetNodeIsAllowSkip(isAllow)
  self.isAllowSkip_ = isAllow
end

function TalkData:GetFlowSubmitItem(flowId)
  return self.flowSubmitItemDict_[flowId] or {}
end

function TalkData:AddFlowSubmitItem(flowId, itemList)
  self.flowSubmitItemDict_[flowId] = itemList
end

function TalkData:RemoveFlowSubmitItem(flowId)
  self.flowSubmitItemDict_[flowId] = nil
end

function TalkData:GetFlowShowItem(flowId)
  return self.flowShowItemDict_[flowId] or {}
end

function TalkData:AddFlowShowItem(flowId, itemList)
  self.flowShowItemDict_[flowId] = itemList
end

function TalkData:RemoveFlowShowItem(flowId)
  self.flowShowItemDict_[flowId] = nil
end

function TalkData:ChangeTrustValue(value)
  self.TrustValue = self.TrustValue + value
end

function TalkData:ChangeTimeValue(value)
  self.TimeValue = self.TimeValue + value
  if self.TimeValue > 10 then
    self.TimeValue = 10
  end
end

function TalkData:GetTrustValue()
  return self.TrustValue
end

function TalkData:GetTimeValue()
  return self.TimeValue
end

function TalkData:InitTimeValue()
  self.TimeValue = 10
end

function TalkData:SelectedNeutral(id, index)
  if not self.NeutralTab[id .. index] then
    self.NeutralTab[id .. index] = 1
  end
end

function TalkData:GetNeutral(id, index)
  return self.NeutralTab[id .. index]
end

function TalkData:SetSelectInterrogateDict(id)
  self.selectInterrogateDict_[id] = true
end

function TalkData:GetSelectInterrogateIsShow(id)
  return not self.selectInterrogateDict_[id]
end

function TalkData:AddQuestFlowTalk(sceneId, npcId, talkId, questId)
  if not self.npcFlowTalkDict_[sceneId] then
    self.npcFlowTalkDict_[sceneId] = {}
  end
  if not self.npcFlowTalkDict_[sceneId][npcId] then
    self.npcFlowTalkDict_[sceneId][npcId] = {}
  end
  self.npcFlowTalkDict_[sceneId][npcId][talkId] = questId
  Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, npcId)
end

function TalkData:RemoveQuestFlowTalk(sceneId, npcId, talkId)
  if self.npcFlowTalkDict_[sceneId] and self.npcFlowTalkDict_[sceneId][npcId] and self.npcFlowTalkDict_[sceneId][npcId][talkId] then
    self.npcFlowTalkDict_[sceneId][npcId][talkId] = nil
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, npcId)
  end
end

function TalkData:GetQuestFlowTalk()
  return self.npcFlowTalkDict_
end

function TalkData:GetQuestTalkFlowDictByNpcAndScene(npcId, targetSceneId)
  local flowDict = {}
  for _, sceneId in ipairs({0, targetSceneId}) do
    if self.npcFlowTalkDict_[sceneId] and self.npcFlowTalkDict_[sceneId][npcId] then
      for talkId, questId in pairs(self.npcFlowTalkDict_[sceneId][npcId]) do
        flowDict[talkId] = questId
      end
    end
  end
  return flowDict
end

function TalkData:GetChangedTalkFlowDictByNpcId(npcId)
  return self.npcChangedTalkFlowDict_[npcId]
end

function TalkData:SetNpcChangedTalkFlow(npcId, questId, flowId)
  if not flowId then
    if self.npcChangedTalkFlowDict_[npcId] then
      self.npcChangedTalkFlowDict_[npcId][questId] = nil
    end
  else
    if not self.npcChangedTalkFlowDict_[npcId] then
      self.npcChangedTalkFlowDict_[npcId] = {}
    end
    self.npcChangedTalkFlowDict_[npcId][questId] = flowId
  end
  Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, npcId)
end

function TalkData:DelNpcChangedTalkFlowByQuestId(questId)
  for npcId, flowDict in pairs(self.npcChangedTalkFlowDict_) do
    flowDict[questId] = nil
    Z.EventMgr:Dispatch(Z.ConstValue.NpcTalk.NpcQuestTalkFlowChange, npcId)
  end
end

return TalkData
