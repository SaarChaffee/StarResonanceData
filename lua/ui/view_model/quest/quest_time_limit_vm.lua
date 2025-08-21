local isTimeLimitStepByStepId = function(stepId)
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(stepId)
  if stepRow and #stepRow.TimeLimitedStep > 0 then
    return true
  end
  return false
end
local getTrackingQuestInTimeLimitStep = function(isAllState)
  local questData = Z.DataMgr.Get("quest_data")
  local trackingId = questData:GetQuestTrackingId()
  local quest = questData:GetQuestByQuestId(trackingId)
  if quest and isTimeLimitStepByStepId(quest.stepId) then
    if isAllState then
      return quest
    elseif quest.stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepGoing") then
      return quest
    end
  end
end
local getQuestStepTimeLimitInfo = function(quest)
  if quest == nil then
    return nil
  end
  local questData = Z.DataMgr.Get("quest_data")
  local stepRow = questData:GetStepConfigByStepId(quest.stepId)
  if stepRow and #stepRow.TimeLimitedStep > 0 then
    return stepRow.TimeLimitedStep[1]
  end
  return nil
end
local ret = {
  IsTimeLimitStepByStepId = isTimeLimitStepByStepId,
  GetTrackingQuestInTimeLimitStep = getTrackingQuestInTimeLimitStep,
  GetQuestStepTimeLimitInfo = getQuestStepTimeLimitInfo
}
return ret
