local super = require("ui.model.data_base")
local InvestigationMainData = class("InvestigationMainData", super)
E.InvestigationState = {
  EUnLock = 1,
  EComplete = 2,
  EFinish = 3,
  ELock = 4
}
E.InvestigationClueState = {ELock = 1, EUnLock = 2}
E.InvestigationListType = {
  EAll = 1,
  EUnLock = 2,
  EComplete = 3,
  ELock = 4
}

function InvestigationMainData:ctor()
  super.ctor(self)
  self:resetData()
end

function InvestigationMainData:resetData()
  self.investigationMap_ = {}
  self.curInvestigationId_ = 0
  self.curStepIndex_ = 1
  self.curStepMax_ = 1
  self.isInit_ = false
  self.isFirstUpdateServerData_ = true
  self.curStepErrorCount_ = 0
  self.isShowFirstStep_ = false
  self.firstInvestigateId_ = 1001
  self.firstInvestigateStepId_ = 10011
  self.investigationStepClueData_ = {}
  self.isInvestigationStepClueData_ = false
end

function InvestigationMainData:Init()
  self:resetData()
  self.CancelSource = Z.CancelSource.Rent()
  Z.EventMgr:Add(Z.ConstValue.LanguageChange, self.onLanguageChange, self)
end

function InvestigationMainData:Clear()
  self:resetData()
end

function InvestigationMainData:UnInit()
  self.CancelSource:Recycle()
  Z.EventMgr:RemoveObjAll(self)
end

function InvestigationMainData:onLanguageChange()
  self.isInit_ = false
end

function InvestigationMainData:InitInvestigationLocalData()
  if true == self.isInit_ then
    return
  end
  self.isInit_ = true
  self.investigationMap_ = {}
  local investigationsTableDatas = Z.TableMgr.GetTable("InvestigationsTableMgr").GetDatas()
  for tableId, tableData in pairs(investigationsTableDatas) do
    local investigation = {}
    investigation.Id = tableId
    investigation.StepList = {}
    investigation.State = E.InvestigationState.ELock
    investigation.Guarantee = tableData.Guarantee
    for i = 1, #tableData.InvestigationStep do
      local curStepId = tableData.InvestigationStep[i]
      local investigationStepTableRow = Z.TableMgr.GetTable("InvestigationStepTableMgr").GetRow(curStepId)
      if investigationStepTableRow == nil then
        return
      end
      local investigationStep = {}
      investigationStep.StepId = curStepId
      investigationStep.ClueList = {}
      investigationStep.IllationList = {}
      investigationStep.AnswerContentList = {}
      investigationStep.CompleteAnswerList = {}
      investigationStep.IsComplete = false
      for j = 1, #investigationStepTableRow.InferenceStep do
        local inferenceStepId = investigationStepTableRow.InferenceStep[j]
        local illation = {}
        illation.IllationId = inferenceStepId
        illation.AnswerList = {}
        local inferenceStepTable = self:GetInferenceStepTable(inferenceStepId)
        if inferenceStepTable then
          for k = 1, #inferenceStepTable.Answer do
            local answerData = {}
            answerData.AnswerId = inferenceStepTable.Answer[k]
            answerData.IsComplete = false
            illation.AnswerList[#illation.AnswerList + 1] = answerData
          end
        end
        illation.IsComplete = false
        investigationStep.IllationList[#investigationStep.IllationList + 1] = illation
      end
      for j = 1, #investigationStepTableRow.Clue do
        local clueId = investigationStepTableRow.Clue[j]
        local clue = {}
        clue.ClueId = clueId
        clue.ClueContext = ""
        clue.ClueAnswerList = {}
        clue.IsUnlock = false
        clue.IsAnalysis = false
        clue.IsShowUnlockTips = false
        investigationStep.ClueList[#investigationStep.ClueList + 1] = clue
        self:analysisClueAnswer(clue, investigationStep.AnswerContentList)
      end
      investigationStep.IsUnlock = false
      investigation.StepList[#investigation.StepList + 1] = investigationStep
    end
    self.investigationMap_[tableId] = investigation
  end
end

function InvestigationMainData:UpdateInvestigationServerData()
  local isFirstUpdate = self.isFirstUpdateServerData_
  self.isFirstUpdateServerData_ = false
  local serverData = Z.ContainerMgr.CharSerialize.investigateList
  for _, data in pairs(self.investigationMap_) do
    local serverInvestigateData
    local isInvestigationComplete = false
    local lastState = data.State
    for doingId, serverData in pairs(serverData.investigateMap) do
      if doingId == data.Id then
        data.State = E.InvestigationState.EUnLock
        serverInvestigateData = serverData
        break
      end
    end
    if data.State ~= E.InvestigationState.EFinish then
      for completeId, _ in pairs(serverData.compInvestigateMap) do
        if completeId == data.Id then
          data.State = E.InvestigationState.EFinish
          isInvestigationComplete = true
          break
        end
      end
    end
    if data.State ~= E.InvestigationState.EComplete and serverData.compReasoningMap and table.zcontains(serverData.compReasoningMap, data.Id) then
      data.State = E.InvestigationState.EComplete
      isInvestigationComplete = true
    end
    if data.State == E.InvestigationState.EUnLock then
      self:setInvestigationServerData(data, serverInvestigateData, isFirstUpdate)
    elseif (data.State == E.InvestigationState.EComplete or data.State == E.InvestigationState.EFinish) and lastState ~= E.InvestigationState.EComplete and lastState ~= E.InvestigationState.EFinish then
      self:setInvestigationFinishData(data)
    end
  end
end

function InvestigationMainData:setInvestigationFinishData(data)
  for i = 1, #data.StepList do
    local stepData = data.StepList[i]
    stepData.IsComplete = true
    stepData.CompleteAnswerList = {}
    for j = 1, #stepData.IllationList do
      local illationData = stepData.IllationList[j]
      illationData.IsComplete = true
      for k = 1, #illationData.AnswerList do
        local answerData = illationData.AnswerList[k]
        answerData.IsComplete = true
        stepData.CompleteAnswerList[#stepData.CompleteAnswerList + 1] = answerData.AnswerId
      end
    end
    for j = 1, #stepData.ClueList do
      local investigationClue = stepData.ClueList[j]
      investigationClue.IsUnlock = true
      for k = 1, #investigationClue.ClueAnswerList do
        investigationClue.ClueAnswerList[k].IsComplete = true
      end
    end
  end
end

function InvestigationMainData:setInvestigationServerData(localData, serverData, isFirstUpdate)
  if not (localData and serverData) or not serverData.stepIds then
    return
  end
  for i = 1, #localData.StepList do
    local stepData = localData.StepList[i]
    local serverStepData = serverData.stepIds[stepData.StepId]
    if serverStepData then
      local isIllationsOk = self:setIllationServerData(stepData, serverStepData.reasoningMap)
      local isCluesOk = self:setClueServerData(stepData, serverStepData.clues, isFirstUpdate)
      if isIllationsOk and isCluesOk then
        stepData.IsComplete = true
      end
    end
  end
end

function InvestigationMainData:setIllationServerData(stepData, reasoningMap)
  local isIllationsOk = true
  for j = 1, #stepData.IllationList do
    local illationData = stepData.IllationList[j]
    if illationData.IsComplete == false then
      local answersList = reasoningMap[illationData.IllationId]
      if answersList then
        if answersList.answers and #answersList.answers > 0 then
          for i = 1, #answersList.answers do
            stepData.CompleteAnswerList[#stepData.CompleteAnswerList + 1] = answersList.answers[i]
          end
        end
        local allAnswerComplete = true
        for k = 1, #illationData.AnswerList do
          local answerData = illationData.AnswerList[k]
          if answerData.IsComplete == false and table.zcontains(answersList.answers, answerData.AnswerId) then
            answerData.IsComplete = true
          end
          if answerData.IsComplete == false then
            allAnswerComplete = false
          end
        end
        if true == allAnswerComplete then
          illationData.IsComplete = true
        end
      end
    end
    if illationData.IsComplete == false then
      isIllationsOk = false
    end
  end
  return isIllationsOk
end

function InvestigationMainData:setClueServerData(stepData, clues, isFirstUpdate)
  local isCluesOk = true
  for j = 1, #stepData.ClueList do
    local investigationClue = stepData.ClueList[j]
    if false == investigationClue.IsUnlock and clues and table.zcontains(clues, investigationClue.ClueId) then
      investigationClue.IsUnlock = true
      if isFirstUpdate == false then
        investigationClue.IsShowUnlockTips = true
      end
    end
    if false == investigationClue.IsUnlock then
      isCluesOk = false
    end
    for k = 1, #investigationClue.ClueAnswerList do
      if investigationClue.ClueAnswerList[k].IsComplete == false and stepData.CompleteAnswerList and #stepData.CompleteAnswerList > 0 and table.zcontains(stepData.CompleteAnswerList, investigationClue.ClueAnswerList[k].AnswerId) then
        investigationClue.ClueAnswerList[k].IsComplete = true
        if not isFirstUpdate then
          investigationClue.ClueAnswerList[k].IsShowCompleteAnim = true
        end
      end
    end
  end
  return isCluesOk
end

function InvestigationMainData:GetInvestigationState(investigationId)
  if self.investigationMap_[investigationId] == nil then
    return E.InvestigationState.ELock
  end
  return self.investigationMap_[investigationId].State
end

function InvestigationMainData:SetCurInvestigationId(investigationId)
  self.curInvestigationId_ = investigationId
end

function InvestigationMainData:SetCurStepIndex(index)
  self.curStepIndex_ = index
end

function InvestigationMainData:GetCurStepIndex()
  return self.curStepIndex_
end

function InvestigationMainData:GetCurStepIndexMax()
  return self.curStepMax_
end

function InvestigationMainData:RefreshStepIndex()
  if self.isShowFirstStep_ then
    self.isShowFirstStep_ = false
    return
  end
  local investigationData = self:GetCurInvestigationData()
  if not (investigationData and investigationData.StepList) or self.curStepIndex_ > #investigationData.StepList then
    self.curStepIndex_ = 1
    return
  end
  for i = 1, #investigationData.StepList do
    if investigationData.StepList[i].IsComplete == false then
      self.curStepIndex_ = i
      break
    end
  end
end

function InvestigationMainData:RefreshStepMax()
  local investigationData = self:GetCurInvestigationData()
  if not investigationData or not investigationData.StepList then
    return
  end
  self.curStepMax_ = 0
  for i = 1, #investigationData.StepList do
    self.curStepMax_ = self.curStepMax_ + 1
    if investigationData.StepList[i].IsComplete == false then
      break
    end
  end
end

function InvestigationMainData:GetCurInvestigationId()
  return self.curInvestigationId_
end

function InvestigationMainData:GetCurInvestigationData()
  if not self.investigationMap_ then
    return
  end
  return self.investigationMap_[self.curInvestigationId_]
end

function InvestigationMainData:GetInvestigationList(listType)
  local list = {}
  for _, investigationData in pairs(self.investigationMap_) do
    local canAdd = false
    if listType == E.InvestigationListType.EAll then
      canAdd = true
    elseif listType == E.InvestigationListType.EComplete then
      if investigationData.State == E.InvestigationState.EFinish then
        canAdd = true
      end
    elseif listType == E.InvestigationListType.ELock then
      if investigationData.State == E.InvestigationState.ELock then
        canAdd = true
      end
    elseif listType == E.InvestigationListType.EUnLock and (investigationData.State == E.InvestigationState.EUnLock or investigationData.State == E.InvestigationState.EComplete) then
      canAdd = true
    end
    if true == canAdd then
      local listItem = {}
      listItem.InvestigationId = investigationData.Id
      listItem.State = investigationData.State
      list[#list + 1] = listItem
    end
  end
  table.sort(list, function(left, right)
    if left.State == right.State then
      return left.InvestigationId < right.InvestigationId
    else
      return left.State < right.State
    end
  end)
  return list
end

function InvestigationMainData:GetCurInvestigationStepData()
  if not self.investigationMap_[self.curInvestigationId_] then
    return
  end
  local investigationMap = self:GetCurInvestigationData()
  if not investigationMap then
    return
  end
  if not investigationMap.StepList then
    return
  end
  return investigationMap.StepList[self.curStepIndex_]
end

function InvestigationMainData:GetCurInvestigationIllationData()
  local stepData = self:GetCurInvestigationStepData()
  if not stepData then
    return
  end
  for i = 1, #stepData.IllationList do
    if stepData.IllationList[i].IsComplete == false then
      return stepData.IllationList[i]
    end
  end
end

function InvestigationMainData:GetClueData(clueId)
  local stepData = self:GetCurInvestigationStepData()
  if not stepData then
    return
  end
  if not stepData.ClueList then
    return
  end
  for i = 1, #stepData.ClueList do
    if stepData.ClueList[i].ClueId == clueId then
      return stepData.ClueList[i]
    end
  end
end

function InvestigationMainData:analysisClueAnswer(clueData, answerContentList)
  if not clueData then
    return
  end
  local clueBaseData = self:GetClueTable(clueData.ClueId)
  if not clueBaseData then
    return
  end
  clueData.ClueContext = clueBaseData.Clue
  clueData.ClueLockContext = clueBaseData.Tips
  clueData.ClueAnswerList = {}
  local keyIdList = {}
  for keyId in string.gmatch(clueBaseData.Clue, "<tagId=([0-9]*)>") do
    keyIdList[#keyIdList + 1] = keyId
  end
  local answerData = {}
  for i = 1, #clueBaseData.Answer - 1, 2 do
    local answerId = tonumber(clueBaseData.Answer[i])
    local answerContext = clueBaseData.Answer[i + 1]
    if not answerData[answerId] then
      answerData[answerId] = {}
    end
    answerData[answerId].answerContext = answerContext
  end
  for i = 1, #clueBaseData.TapBubble - 1, 2 do
    local answerId = tonumber(clueBaseData.TapBubble[i])
    local bubble = clueBaseData.TapBubble[i + 1]
    answerData[answerId].bubble = bubble
  end
  for i = 1, #keyIdList do
    local answerId = tonumber(keyIdList[i])
    local clueAnswerData = {}
    clueAnswerData.AnswerId = answerId
    local keyAnswerId = string.zconcat("<tagId=", keyIdList[i], ">%*([^%*]+)%*")
    local keyContext = string.gmatch(clueBaseData.Clue, keyAnswerId)
    for context in keyContext, nil, nil do
      clueAnswerData.KeyContext = context
    end
    if answerData[answerId] then
      clueAnswerData.AnswerContext = answerData[answerId].answerContext
      clueAnswerData.TapBubble = answerData[answerId].bubble
      answerContentList[answerId] = answerData[answerId]
    end
    clueAnswerData.IsComplete = false
    clueData.ClueAnswerList[i] = clueAnswerData
  end
end

function InvestigationMainData:GetClueTable(clueId)
  local investigationClueTableRow = Z.TableMgr.GetTable("InvestigationClueTableMgr").GetRow(clueId)
  return investigationClueTableRow
end

function InvestigationMainData:GetInferenceStepTable(illationId)
  local inferenceStepTableRow = Z.TableMgr.GetTable("InferenceStepTableMgr").GetRow(illationId)
  return inferenceStepTableRow
end

function InvestigationMainData:GetInvestigationTable(investigationId)
  local investigationsTableRow = Z.TableMgr.GetTable("InvestigationsTableMgr").GetRow(investigationId)
  return investigationsTableRow
end

function InvestigationMainData:GetInvestigationStepTable(investigationStepId)
  local investigationStepTableRow = Z.TableMgr.GetTable("InvestigationStepTableMgr").GetRow(investigationStepId)
  return investigationStepTableRow
end

function InvestigationMainData:IsHaveAnswer()
  for _, investigation in pairs(self.investigationMap_) do
    if investigation.State == E.InvestigationState.EComplete or investigation.State == E.InvestigationState.EFinish then
      return true
    end
    if investigation.State == E.InvestigationState.EUnLock then
      for _, investigationStep in pairs(investigation.StepList) do
        if #investigationStep.CompleteAnswerList > 0 then
          return true
        end
      end
    end
  end
  return false
end

function InvestigationMainData:InitInvestigationStepClueData()
  if self.isInvestigationStepClueData_ == false then
    self.isInvestigationStepClueData_ = true
    self.investigationStepClueData_ = {}
    local investigationsTableDatas = Z.TableMgr.GetTable("InvestigationsTableMgr").GetDatas()
    local investigationStepTableDatas = Z.TableMgr.GetTable("InvestigationStepTableMgr")
    local clueTableDatas = Z.TableMgr.GetTable("InvestigationClueTableMgr")
    for tableId, tableData in pairs(investigationsTableDatas) do
      local clueIdList = {}
      for i = 1, #tableData.InvestigationStep do
        local curStepId = tableData.InvestigationStep[i]
        local stepClue = {}
        local investigationStepTableRow = investigationStepTableDatas.GetRow(curStepId)
        if investigationStepTableRow == nil then
          return
        end
        for j = 1, #investigationStepTableRow.Clue do
          local clueId = investigationStepTableRow.Clue[j]
          local clueTableRow = clueTableDatas.GetRow(clueId)
          if clueTableRow == nil then
            return
          end
          stepClue[clueId] = {
            state = E.InvestigationClueState.ELock,
            sort = clueTableRow.sort
          }
        end
        clueIdList[curStepId] = stepClue
      end
      self.investigationStepClueData_[tableId] = clueIdList
    end
    self:UpdateInvestigationStepClueData(true)
  end
end

function InvestigationMainData:UpdateInvestigationStepClueData(isFirst)
  for id, data in pairs(Z.ContainerMgr.CharSerialize.investigateList.investigateMap) do
    local stepIds = data.stepIds or {}
    for stepId, stepData in pairs(stepIds) do
      local clues = stepData.clues or {}
      local checkStep = false
      for i = 1, #clues do
        local clueId = clues[i]
        if self.investigationStepClueData_[id][stepId][clueId].state == E.InvestigationClueState.ELock and false == isFirst then
          checkStep = true
          self:addInvestigationNotice(self:getClueMessageId(self.investigationStepClueData_[id][stepId][clueId].sort), id, false)
        end
        self.investigationStepClueData_[id][stepId][clueId].state = E.InvestigationClueState.EUnLock
      end
      if checkStep then
        local isAllClueUnlock = true
        for _, clueData in pairs(self.investigationStepClueData_[id][stepId]) do
          if clueData.state == E.InvestigationClueState.ELock then
            isAllClueUnlock = false
            break
          end
        end
        if isAllClueUnlock then
          if id == self.firstInvestigateId_ and stepId == self.firstInvestigateStepId_ then
            Z.CoroUtil.create_coro_xpcall(function()
              self.isShowFirstStep_ = true
              local investigationClueVm = Z.VMMgr.GetVM("investigationclue")
              investigationClueVm.AsyncSelectReasoning(self.firstInvestigateId_, self.firstInvestigateStepId_, 0, 0, self.CancelSource:CreateToken())
            end)()
          end
          self:addInvestigationNotice(140002, id, true)
        end
      end
    end
  end
end

function InvestigationMainData:addInvestigationNotice(messageId, investigateId, showTips)
  if not messageId then
    return
  end
  local investigate = self:GetInvestigationTable(investigateId)
  if investigate then
    local nameParam = {
      val = investigate.InvestigationTheme
    }
    local investigateName = Lang("investigateTips", nameParam)
    local param = {
      investigation = {
        name = Z.RichTextHelper.ApplyStyleTag(investigateName, E.TextStyleTag.TipsGreen)
      }
    }
    if showTips then
      Z.TipsVM.ShowTips(messageId, param)
    else
      Z.DataMgr.Get("tips_data"):AddSystemTipInfo(E.ESystemTipInfoType.MessageInfo, messageId, nil, param)
    end
  end
end

function InvestigationMainData:getClueMessageId(index)
  if index == 1 then
    return 140001
  elseif index == 2 then
    return 140003
  elseif index == 3 then
    return 140004
  elseif index == 4 then
    return 140005
  elseif index == 5 then
    return 140006
  elseif index == 6 then
    return 140007
  end
end

return InvestigationMainData
