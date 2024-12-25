local setBlackFadeIn = function(args)
  if args then
    args.TimeOut = 10
  end
  Z.UIMgr:FadeIn(args)
end
local setBlackFadeOut = function(args)
  if args then
    args.TimeOut = 10
  end
  Z.UIMgr:FadeOut(args)
end
local isQuestExist = function(questId)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  return quest ~= nil
end
local isQuestStepGoing = function(questId, stepId)
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(questId)
  if not quest then
    return false
  end
  if quest.stepId ~= stepId then
    return false
  end
  if quest.stepStatus == Z.PbEnum("EQuestStepStatus", "QuestStepGoing") then
    return true
  end
  return false
end
local setGoalFinishParkourZone = function(uid)
  local uuid = Z.EntityMgr.GetLevelEntityLevelUuId(Z.PbEnum("EEntityType", "EntZone"), uid)
  Z.QuestMgr:RemoveVisibleQuestEntByUuid(uuid)
  local goalVM = Z.VMMgr.GetVM("goal")
  goalVM.SetGoalFinish(Z.PbEnum("ETargetType", "TargetParkourZone"))
end
local isWorldEventExist = function(dailyEventId)
  return Z.ContainerMgr.CharSerialize.worldEventMap.eventMap[dailyEventId] ~= nil
end
local ret = {
  SetBlackFadeIn = setBlackFadeIn,
  SetBlackFadeOut = setBlackFadeOut,
  IsQuestExist = isQuestExist,
  IsQuestStepGoing = isQuestStepGoing,
  SetGoalFinishParkourZone = setGoalFinishParkourZone,
  IsWorldEventExist = isWorldEventExist
}
return ret
