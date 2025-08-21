local QuestStep = class("QuestStep")

function QuestStep:ctor(questId, stepId)
  self.questId_ = questId
  self.stepId_ = stepId
  self.questData_ = Z.DataMgr.Get("quest_data")
  self.questGoalVM_ = Z.VMMgr.GetVM("quest_goal")
end

function QuestStep:StepInit()
  self.goalDict_ = {}
  self.blackDataCache_ = {
    flow = {},
    cutscene = {}
  }
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(self.questId_)
  if questRow and questRow.StepFlowPath ~= "" then
    self.stepNode_ = Z.QuestFlowMgr:GetStepNode(self.questId_, self.stepId_)
    self.nodeRes_ = self.stepNode_ and self.stepNode_.stepRes
  end
  self:addGoalData()
  self:setTpLimit(true)
  self:updateQuestHud()
  local questTalkVM = Z.VMMgr.GetVM("quest_talk")
  questTalkVM.AddGoalTalkDataByQuestId(self.questId_, true)
  if self.stepNode_ then
    self.stepNode_:OnEnter()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.StepStart, self.stepId_)
end

function QuestStep:StepUnInit()
  if self.stepNode_ then
    self.stepNode_:OnLeave()
  end
  self:clearGoalData()
  self:setTpLimit(false)
  self:updateQuestHud(true)
  local questTalkVM = Z.VMMgr.GetVM("quest_talk")
  questTalkVM.RemoveGoalTalkDataByStepId(self.stepId_)
  self.goalDict_ = nil
  self.blackDataCache_ = nil
  self.stepNode_ = nil
  self.nodeRes_ = nil
  Z.EventMgr:RemoveObjAll(self)
end

function QuestStep:StepFinish()
  if self.stepNode_ then
    self.stepNode_:OnCompleted()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.StepFinish, self.stepId_)
end

function QuestStep:GetStepId()
  return self.stepId_
end

function QuestStep:SetGoalCompleted(goalIndex)
  self:unregisterGoal(goalIndex)
  self:RemoveNeedTrackNpcData(goalIndex)
  Z.EventMgr:Dispatch(Z.ConstValue.Quest.GoalComplete, self.questId_, goalIndex)
  self:updateQuestHud()
end

function QuestStep:ResetGoal(goalIndex)
  self:unregisterGoal(goalIndex)
  local stepId = self.stepId_
  local stepRow = self.questData_:GetStepConfigByStepId(stepId)
  if not stepRow then
    return
  end
  local paramArrays = stepRow.StepParam
  if paramArrays[goalIndex] then
    local token = Z.LuaGoalMgr:AddGoal(paramArrays[goalIndex])
    self.goalDict_[goalIndex] = token
  end
  self:AddNeedTrackNpcData(goalIndex)
  self:updateQuestHud()
end

function QuestStep:StepOnQuestStateChange(oldState, newState)
  local questTalkVM = Z.VMMgr.GetVM("quest_talk")
  if newState == E.QuestState.NotEnough then
    questTalkVM.RemoveGoalTalkDataByStepId(self.stepId_)
  elseif oldState == E.QuestState.NotEnough then
    questTalkVM.AddGoalTalkDataByQuestId(self.questId_, true)
  end
  self:updateQuestHud()
end

function QuestStep:addGoalData()
  local stepId = self.stepId_
  local stepRow = self.questData_:GetStepConfigByStepId(stepId)
  if not stepRow then
    return
  end
  local paramArrays = stepRow.StepParam
  local goalNum = #paramArrays
  for goalIndex = 1, goalNum do
    local goalParamList = paramArrays[goalIndex]
    local toSceneId = tonumber(goalParamList[3])
    if toSceneId <= 0 then
      toSceneId = stepRow.StepTrackedSceneId[goalIndex] or 0
    end
    local goalPosArray = stepRow.StepTargetPos[goalIndex]
    if goalPosArray then
      self:addGoalTrackData(stepId, goalIndex, toSceneId, goalPosArray)
    end
    self:addGoalBlackMaskData(goalParamList)
    local token = Z.LuaGoalMgr:AddGoal(goalParamList)
    self.goalDict_[goalIndex] = token
    self:AddNeedTrackNpcData(goalIndex)
  end
end

function QuestStep:addGoalTrackData(stepId, goalIndex, toSceneId, posParamList)
  local posType = Z.GoalPosType.IntToEnum(tonumber(posParamList[1]))
  if posType == Z.GoalPosType.None then
    return
  end
  local uid = tonumber(posParamList[2]) or 0
  local pos = self:getEntityPos(toSceneId, posType, uid)
  self.questData_:SetGoalTrackData(stepId, {
    goalIndex = goalIndex,
    uid = uid,
    pos = pos,
    posType = posType,
    toSceneId = toSceneId
  })
end

function QuestStep:getEntityPos(sceneId, posType, uid)
  if sceneId == Z.StageMgr.GetCurrentSceneId() then
    local guideVM = Z.VMMgr.GetVM("goal_guide")
    local tbl = guideVM.GetLevelTableByPosType(posType)
    if tbl then
      local row = tbl.GetRow(uid)
      if row then
        local posArray = row.Position
        local pos = {
          x = posArray[1],
          y = posArray[2],
          z = posArray[3]
        }
        return pos
      end
    end
  else
    local mapVM = Z.VMMgr.GetVM("map")
    local globalConfig = mapVM.GetGlobalInfo(sceneId, posType, uid)
    if globalConfig and globalConfig.Position then
      local pos = {
        x = globalConfig.Position[1],
        y = globalConfig.Position[2],
        z = globalConfig.Position[3]
      }
      return pos
    end
  end
end

function QuestStep:addGoalBlackMaskData(goalParamList)
  local goalType = tonumber(goalParamList[1])
  if goalType == E.GoalType.AutoPlayFlow then
    local maskType = Panda.ZGame.BlackMaskType.IntToEnum(tonumber(goalParamList[5]))
    if maskType ~= Panda.ZGame.BlackMaskType.None then
      local flowId = tonumber(goalParamList[4])
      local args = {}
      args.IsInstant = true
      args.MaskType = maskType
      args.WaitId = tonumber(goalParamList[6])
      args.IsWhite = false
      if goalParamList[7] == "True" then
        args.IsWhite = true
      end
      self.questData_.FlowBlackMaskArgsDict[flowId] = args
      table.insert(self.blackDataCache_.flow, flowId)
    end
  elseif goalType == E.GoalType.AutoPlayCutscene or goalType == E.GoalType.ServerPlayCutscene then
    local maskType = Panda.ZGame.BlackMaskType.IntToEnum(tonumber(goalParamList[5]))
    if maskType ~= Panda.ZGame.BlackMaskType.None then
      local cutsceneId = tonumber(goalParamList[4])
      local args = {}
      args.IsInstant = true
      args.MaskType = maskType
      args.WaitId = tonumber(goalParamList[6])
      args.IsWhite = false
      if goalParamList[7] == "True" then
        args.IsWhite = true
      end
      self.questData_.CutsceneBlackMaskArgsDict[cutsceneId] = args
      table.insert(self.blackDataCache_.cutscene, cutsceneId)
    end
  end
end

function QuestStep:clearGoalData()
  for _, token in pairs(self.goalDict_) do
    Z.LuaGoalMgr:RemoveGoal(token)
  end
  for _, flowId in ipairs(self.blackDataCache_.flow) do
    self.questData_.FlowBlackMaskArgsDict[flowId] = nil
  end
  for _, cutsceneId in ipairs(self.blackDataCache_.cutscene) do
    self.questData_.CutsceneBlackMaskArgsDict[cutsceneId] = nil
  end
  self.questData_:SetGoalTrackData(self.stepId_, nil)
end

function QuestStep:setTpLimit(isAdd)
  local stepRow = self.questData_:GetStepConfigByStepId(self.stepId_)
  if stepRow and stepRow.DisableTransport == 1 then
    for _, goalArray in ipairs(stepRow.StepParam) do
      local sceneId = tonumber(goalArray[E.GoalParam.SceneLimit])
      if isAdd then
        self.questData_:AddTpLimitQuest(self.questId_, sceneId)
      else
        self.questData_:DelTpLimitQuest(self.questId_, sceneId)
      end
    end
  end
end

function QuestStep:updateQuestHud(isOld)
  local questId = self.questId_
  local questIconVM = Z.VMMgr.GetVM("quest_icon")
  local npcDict = self:getBindNpcDict()
  for goalIndex, npcId in pairs(npcDict) do
    local isDel
    if isOld then
      isDel = true
    else
      isDel = self.questGoalVM_.IsGoalCompleted(questId, goalIndex)
    end
    if not isDel then
      self.questData_:AddNpcHudQuest(npcId, questId)
    else
      self.questData_:RemoveNpcHudQuest(npcId, questId)
    end
    local stage = self.questData_.QuestMgrStage
    if stage >= E.QuestMgrStage.InitEnd and stage < E.QuestMgrStage.BeginUnInit then
      questIconVM.UpdateNpcHudQuest(npcId)
    end
  end
end

function QuestStep:getBindNpcDict()
  local stepRow = self.questData_:GetStepConfigByStepId(self.stepId_)
  if not stepRow then
    return {}
  end
  local talkVM = Z.VMMgr.GetVM("talk")
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local stepParam = stepRow.StepParam
  local bindNpcDict = {}
  for goalIdx = 1, #stepParam do
    local stepParamArray = stepParam[goalIdx]
    local toSceneId = tonumber(stepParamArray[3])
    local goalType = tonumber(stepParamArray[1])
    if sceneId == toSceneId then
      if talkVM.IsAddTalkGoal(goalType) then
        local npcId = tonumber(stepParamArray[4])
        bindNpcDict[goalIdx] = npcId
      elseif goalType == E.GoalType.FinishOperate and tonumber(stepParamArray[4]) == Z.PbEnum("EEntityType", "EntNpc") then
        local uid = tonumber(stepParamArray[5])
        local row = Z.TableMgr.GetTable("NpcEntityTableMgr").GetRow(uid)
        if row then
          bindNpcDict[goalIdx] = row.Id
        end
      end
    end
  end
  return bindNpcDict
end

function QuestStep:unregisterGoal(goalIndex)
  local token = self.goalDict_[goalIndex]
  if token then
    Z.LuaGoalMgr:RemoveGoal(token)
  end
end

function QuestStep:AddNeedTrackNpcData(goalIndex)
  local isCompleted = self.questGoalVM_.IsGoalCompleted(self.questId_, goalIndex)
  if isCompleted then
    return
  end
  local stepRow = self.questData_:GetStepConfigByStepId(self.stepId_)
  local goalPosArray = stepRow.StepTargetPos[goalIndex]
  local paramArrays = stepRow.StepParam
  local goalParamList = paramArrays[goalIndex]
  local toSceneId = tonumber(goalParamList[3])
  if toSceneId ~= Z.StageMgr.GetCurrentSceneId() then
    return
  end
  local posType = Z.GoalPosType.IntToEnum(tonumber(goalPosArray[1]))
  if posType ~= Z.GoalPosType.Npc then
    return
  end
  local uid = tonumber(goalPosArray[2]) or 0
  if uid <= 0 then
    return
  end
  Z.QuestMgr:GetQuestTrackEffectComp():AddNeedTrackNpcEnt(self.questId_, uid)
end

function QuestStep:RemoveNeedTrackNpcData(goalIndex)
  local stepRow = self.questData_:GetStepConfigByStepId(self.stepId_)
  local goalPosArray = stepRow.StepTargetPos[goalIndex]
  local posType = Z.GoalPosType.IntToEnum(tonumber(goalPosArray[1]))
  if posType ~= Z.GoalPosType.Npc then
    return
  end
  local uid = tonumber(goalPosArray[2]) or 0
  if uid <= 0 then
    return
  end
  Z.QuestMgr:GetQuestTrackEffectComp():RemoveNeedTrackNpcEnt(self.questId_, uid)
end

return QuestStep
