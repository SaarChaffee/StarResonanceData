local QuestRed = {}

function QuestRed.IsShowQuestRed(questId)
  if Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "BkrQuestRed" .. questId, false) then
    return true
  end
  return false
end

function QuestRed.getQuestRedCount()
  local count = 0
  local questDetailVM = Z.VMMgr.GetVM("questdetail")
  local typeGroupList = questDetailVM.GetQuestTypeGroupList(-1)
  if 0 < #typeGroupList then
    for i = 1, #typeGroupList do
      if 0 < #typeGroupList[i].QuestIdList then
        for j = 1, #typeGroupList[i].QuestIdList do
          if QuestRed.IsShowQuestRed(typeGroupList[i].QuestIdList[j]) then
            count = count + 1
          end
        end
      end
    end
  end
  return count
end

function QuestRed.UpdateQuestRed()
  local count = QuestRed.getQuestRedCount()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.QuestList, count)
end

function QuestRed.CloseQuestRed(questId)
  if QuestRed.IsShowQuestRed(questId) then
    Z.LocalUserDataMgr.RemoveKeyByLua(E.LocalUserDataType.Character, "BkrQuestRed" .. questId)
    QuestRed.UpdateQuestRed()
  end
end

function QuestRed.CloseAllQuestRed()
  local count = QuestRed.getQuestRedCount()
  if count == 0 then
    return
  end
  local questDic = Z.ContainerMgr.CharSerialize.questList.questMap
  if questDic == nil then
    return
  end
  for questId, _ in pairs(questDic) do
    QuestRed.CloseQuestRed(questId)
  end
end

function QuestRed.CheckQuestRed(quest)
  if quest == nil then
    return
  end
  local questId = quest.id
  local questData = Z.DataMgr.Get("quest_data")
  if questData:IsShowInTrackBar(questId) then
    return
  end
  if questData:GetQuestTrackingId() == questId then
    QuestRed.CloseQuestRed(questId)
    return
  end
  local state = quest.state
  if state == Z.PbEnum("EQuestStatusType", "QuestAccept") or state == Z.PbEnum("EQuestStatusType", "QuestFinish") then
    Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "BkrQuestRed" .. questId, true)
    QuestRed.UpdateQuestRed()
  else
    QuestRed.CloseQuestRed(questId)
  end
end

return QuestRed
