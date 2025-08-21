local openDetailView = function()
  Z.UIMgr:OpenView("quest_detail")
end
local openQuestCatalogView = function()
  Z.UIMgr:OpenView("quest_book_window")
end
local closeQuestCatalogView = function()
  Z.UIMgr:CloseView("quest_book_window")
end
local closeDetailView = function()
  Z.UIMgr:CloseView("quest_detail")
end
local getQuestTypeGroupIds = function()
  local questData = Z.DataMgr.Get("quest_data")
  local questTypeGroupInfos = questData:GetQuestTypeGroupInfos()
  if questTypeGroupInfos ~= nil then
    return questTypeGroupInfos
  end
  local typeGroupTbl = Z.TableMgr.GetTable("QuestTypeGroupTableMgr")
  local infos = {}
  table.insert(infos, -1)
  for _, row in pairs(typeGroupTbl.GetDatas()) do
    table.insert(infos, row.QuestTypeGroupId)
  end
  table.sort(infos, function(leftId, rightId)
    if leftId == -1 then
      return true
    end
    if rightId == -1 then
      return false
    end
    local left = typeGroupTbl.GetRow(leftId)
    local right = typeGroupTbl.GetRow(rightId)
    if left == nil or right == nil then
      return false
    end
    return left.DisplayOrder < right.DisplayOrder
  end)
  questData:SetQuestTypeGroupInfos(infos)
  return infos
end
local getQuestTypeGroupList = function(groupTabId)
  local questData = Z.DataMgr.Get("quest_data")
  local typeGroupTbl = Z.TableMgr.GetTable("QuestTypeGroupTableMgr")
  local questTypeTbl = Z.TableMgr.GetTable("QuestTypeTableMgr")
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local groupDict = {}
  for groupId, typeGroupRow in pairs(typeGroupTbl.GetDatas()) do
    if groupId == groupTabId or groupTabId == -1 then
      groupDict[groupId] = {
        TblRow = typeGroupRow,
        QuestIdList = {}
      }
    end
  end
  local isValidQuest = function(quest)
    local questState = quest.state
    return (questState == E.QuestState.InProgress or questState == E.QuestState.Deliverable or questState == E.QuestState.NotEnough) and not questData:IsQuestAccessNotEnough(quest)
  end
  local handleQuest = function(questId, quest)
    local questRow = questTbl.GetRow(questId)
    if not questRow then
      return
    end
    local typeId = questRow.QuestType
    local questTypeRow = questTypeTbl.GetRow(typeId)
    if not (questTypeRow and questTypeRow.ShowQuestUI) or questTypeRow.QuestListHide then
      return
    end
    local stepRow = questData:GetStepConfigByStepId(quest.stepId)
    if stepRow and (#stepRow.StepTargetInfo > 0 or stepRow.StepMainTitle ~= "") then
      local data = groupDict[questTypeRow.QuestTypeGroupID]
      if data then
        table.insert(data.QuestIdList, questId)
      end
    end
  end
  for questId, quest in pairs(questData:GetAllQuestDict()) do
    if isValidQuest(quest) then
      handleQuest(questId, quest)
    end
  end
  local sortQuestIdList = function(groupType, data)
    if groupType == E.QuestTypeGroup.WorldEvent then
      table.sort(data.QuestIdList, function(a, b)
        local aq = questTbl.GetRow(a)
        local bq = questTbl.GetRow(b)
        return aq.QuestType < bq.QuestType
      end)
    else
      table.sort(data.QuestIdList)
    end
  end
  local groupList = {}
  for groupType, data in pairs(groupDict) do
    if #data.QuestIdList > 0 then
      sortQuestIdList(groupType, data)
      table.insert(groupList, data)
    end
  end
  table.sort(groupList, function(left, right)
    return left.TblRow.DisplayOrder < right.TblRow.DisplayOrder
  end)
  return groupList
end
local getQuestDetailCatalogueDatas = function(questtypeGroupList, groupTabId)
  if questtypeGroupList == nil or #questtypeGroupList < 1 then
    return {}
  end
  local dataList = {}
  for _, group in ipairs(questtypeGroupList) do
    if groupTabId == -1 then
      local tpl = {
        tblRow = group.TblRow,
        isQuestType = true
      }
      table.insert(dataList, tpl)
    end
    for _, questId in ipairs(group.QuestIdList) do
      local tpl = {questId = questId, isQuestType = false}
      table.insert(dataList, tpl)
    end
  end
  return dataList
end
local getQuestRewardById = function(id)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(id)
  if not questRow then
    return {}
  end
  local awardList = {}
  local awardVM = Z.VMMgr.GetVM("awardpreview")
  local awardId = questRow.AwardId
  if 0 < awardId then
    awardList = awardVM.GetAllAwardPreListByIds(awardId)
  end
  return awardList
end
local getQuestSeriesRewardById = function(id)
  local questRow = Z.TableMgr.GetTable("QuestTableMgr").GetRow(id)
  if not questRow then
    return {}
  end
  return questRow.AwardPreview
end
local isValidQuest = function(id)
  if id <= 0 then
    return false
  end
  local questData = Z.DataMgr.Get("quest_data")
  local quest = questData:GetQuestByQuestId(id)
  if not quest then
    return false
  end
  local stepRow = questData:GetStepConfigByStepId(quest.stepId)
  if stepRow and #stepRow.StepTargetInfo == 0 and stepRow.StepMainTitle == "" then
    return false
  end
  local questState = quest.state
  if questState ~= E.QuestState.InProgress and questState ~= E.QuestState.Deliverable and questState ~= E.QuestState.NotEnough then
    return false
  end
  return true
end
local ret = {
  OpenDetailView = openDetailView,
  OpenQuestCatalogView = openQuestCatalogView,
  CloseDetailView = closeDetailView,
  CloseQuestCatalogView = closeQuestCatalogView,
  GetQuestTypeGroupIds = getQuestTypeGroupIds,
  GetQuestTypeGroupList = getQuestTypeGroupList,
  GetQuestRewardById = getQuestRewardById,
  GetQuestDetailCatalogueDatas = getQuestDetailCatalogueDatas,
  IsValidQuest = isValidQuest,
  GetQuestSeriesRewardById = getQuestSeriesRewardById
}
return ret
