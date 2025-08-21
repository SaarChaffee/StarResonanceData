local QuestIconVM = {}

function QuestIconVM.GetStateIconByQuestId(id)
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questCfgData = questTbl.GetRow(id)
  if questCfgData == nil then
    return ""
  end
  local questTypeTbl = Z.TableMgr.GetTable("QuestTypeTableMgr")
  local questType = questCfgData.QuestType
  local questTypeRow = questTypeTbl.GetRow(questType)
  if questTypeRow == nil then
    return ""
  end
  local imgPath = questTypeRow.QuestTypeUI
  if imgPath and imgPath ~= "" then
    return imgPath
  end
  local questData = Z.DataMgr.Get("quest_data")
  local state
  if questData:IsCanAcceptQuest(id) then
    state = Z.PbEnum("EQuestStatusType", "QuestCanAccept")
  else
    local quest = questData:GetQuestByQuestId(id)
    if quest then
      state = quest.state
    else
      return ""
    end
  end
  local state2str = {
    [Z.PbEnum("EQuestStatusType", "QuestCanAccept")] = "not",
    [Z.PbEnum("EQuestStatusType", "QuestAccept")] = "underway",
    [Z.PbEnum("EQuestStatusType", "QuestFinish")] = "underway",
    [Z.PbEnum("EQuestStatusType", "QuestNotEnough")] = "underway"
  }
  local part1 = state2str[state]
  if not part1 then
    return ""
  end
  local typeGroupId = questTypeRow.QuestTypeGroupID
  local questTypeGroupTbl = Z.TableMgr.GetTable("QuestTypeGroupTableMgr")
  local questTypeData = questTypeGroupTbl.GetRow(typeGroupId)
  if questTypeData == nil then
    return
  end
  local part2 = questTypeData.TypeGroupUIColor
  return string.format("ui/atlas/hud/quest_state/quest_icon_state_%s_%s", part1, part2)
end

function QuestIconVM.GetQuestIconInScene(questId)
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local questRow = questTbl.GetRow(questId)
  if not questRow then
    return ""
  end
  local questData = Z.DataMgr.Get("quest_data")
  local questType = questRow.QuestType
  local questTypeTbl = Z.TableMgr.GetTable("QuestTypeTableMgr")
  local questTypeRow = questTypeTbl.GetRow(questType)
  if not questTypeRow or not questTypeRow.ShowQuestUI then
    return ""
  end
  if questData:IsCanAcceptQuest(questId) then
    return QuestIconVM.GetStateIconByQuestId(questId)
  else
    local quest = questData:GetQuestByQuestId(questId)
    if quest and quest.state ~= E.QuestState.End and quest.state ~= E.QuestState.NotEnough then
      return QuestIconVM.GetStateIconByQuestId(questId)
    else
      return ""
    end
  end
end

function QuestIconVM.UpdateNpcHudQuest(npcId)
  local questData = Z.DataMgr.Get("quest_data")
  local questVm = Z.VMMgr.GetVM("quest")
  local idSet = questData:GetNpcHudQuestSet(npcId) or {}
  local trackingId = questData:GetQuestTrackingId()
  local hudQuest
  if 0 < trackingId and idSet[trackingId] then
    hudQuest = trackingId
  else
    local idList = {}
    for questId, _ in pairs(idSet) do
      table.insert(idList, questId)
    end
    table.sort(idList, questVm.CompareQuestIdOrder)
    hudQuest = idList[1]
  end
  local iconPath = hudQuest and QuestIconVM.GetQuestIconInScene(hudQuest) or ""
  Z.QuestMgr:SetNpcQuestIcon(npcId, iconPath)
end

function QuestIconVM.UpdateAllNpcHudQuest()
  local questData = Z.DataMgr.Get("quest_data")
  local npcList = questData:GetAllNpcWithHudQuest()
  for _, npcId in ipairs(npcList) do
    QuestIconVM.UpdateNpcHudQuest(npcId)
  end
end

return QuestIconVM
