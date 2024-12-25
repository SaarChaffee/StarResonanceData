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
local getQuestTypeGroupList = function()
  local questData = Z.DataMgr.Get("quest_data")
  local typeGroupTbl = Z.TableMgr.GetTable("QuestTypeGroupTableMgr")
  local questTypeTbl = Z.TableMgr.GetTable("QuestTypeTableMgr")
  local questTbl = Z.TableMgr.GetTable("QuestTableMgr")
  local groupDict = {}
  for groupId, typeGroupRow in pairs(typeGroupTbl.GetDatas()) do
    groupDict[groupId] = {
      TblRow = typeGroupRow,
      QuestIdList = {}
    }
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
    if stepRow and #stepRow.StepTargetInfo > 0 then
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
local getQuestDetailCatalogueDatas = function(questtypeGroupList)
  if questtypeGroupList == nil or #questtypeGroupList < 1 then
    return {}
  end
  local dataList = {}
  for _, group in ipairs(questtypeGroupList) do
    local tpl = {
      tblRow = group.TblRow,
      isQuestType = true
    }
    table.insert(dataList, tpl)
    for _, questId in ipairs(group.QuestIdList) do
      local tpl = {questId = questId, isQuestType = false}
      table.insert(dataList, tpl)
    end
  end
  return dataList
end
local getStateIconByQuestId = function(id)
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
  if stepRow and #stepRow.StepTargetInfo == 0 then
    return false
  end
  local questState = quest.state
  if questState ~= E.QuestState.InProgress and questState ~= E.QuestState.Deliverable and questState ~= E.QuestState.NotEnough then
    return false
  end
  return true
end
local sortEpisodeChapterInfos = function(questCatalogInfos)
  if questCatalogInfos == nil then
    return nil
  end
  for index, value in ipairs(questCatalogInfos) do
    table.sort(value.chapterInfos, function(leftRow, rightRow)
      return leftRow.Order < rightRow.Order
    end)
  end
  return questCatalogInfos
end
local getEpisodeChapterCatalogueInfos = function(questType)
  local episodeData = Z.DataMgr.Get("episode_data")
  local chapterCatalogueInfos = episodeData:GetEpisodeQuestInfos(questType)
  if chapterCatalogueInfos then
    return chapterCatalogueInfos
  end
  local questInfoMgr = Z.TableMgr.GetTable("QuestInfoTableMgr")
  local questInfoList = questInfoMgr.GetDatas()
  local questCatalogInfos = {}
  for index, value in pairs(questInfoList) do
    if value.TaskType == questType then
      local episode = value.Episode
      local info = questCatalogInfos[episode]
      if info == nil then
        info = {
          chapterInfos = {},
          episodeId = episode,
          episodeName = value.EpisodeName
        }
        questCatalogInfos[episode] = info
      end
      table.insert(info.chapterInfos, value)
    end
  end
  questCatalogInfos = sortEpisodeChapterInfos(questCatalogInfos)
  episodeData:SetEpisodeChapterInfos(questType, questCatalogInfos)
  return questCatalogInfos
end
local isLockEpisodeChater = function(id)
  local questInfoMgr = Z.TableMgr.GetTable("QuestInfoTableMgr")
  local questInfo = questInfoMgr.GetRow(id)
  if questInfo == nil then
    return false
  end
  local questId = questInfo.Unlock
  local isFinish = Z.ContainerMgr.CharSerialize.questList.finishQuest[questId]
  if isFinish ~= nil then
    return true
  end
  return false
end
local getEpisodeOrderedChapterCatalog = function(questType, episodeList)
  local chapterCatalogInfos = getEpisodeChapterCatalogueInfos(questType)
  local orderedCatalog = {}
  episodeList = episodeList or {1}
  for _, episodeInfo in ipairs(chapterCatalogInfos) do
    local isOpen = table.zcontains(episodeList, episodeInfo.episodeId)
    local episodeData = {
      isEpisode = true,
      episodeId = episodeInfo.episodeId,
      episodeName = episodeInfo.episodeName,
      isOpen = isOpen
    }
    table.insert(orderedCatalog, episodeData)
    local hasUnlockedChapters = false
    for _, chapterInfo in ipairs(episodeInfo.chapterInfos) do
      if isLockEpisodeChater(chapterInfo.Id) then
        if isOpen then
          table.insert(orderedCatalog, {isEpisode = false, chapterInfo = chapterInfo})
        end
        hasUnlockedChapters = true
      end
    end
    if not hasUnlockedChapters then
      table.remove(orderedCatalog, #orderedCatalog)
    end
  end
  return orderedCatalog
end
local getFirstEpisodeChaterIndex = function(orderedCatalog)
  for index, value in ipairs(orderedCatalog) do
    if not value.isEpisode then
      return index
    end
  end
  return -1
end
local ret = {
  OpenDetailView = openDetailView,
  OpenQuestCatalogView = openQuestCatalogView,
  CloseDetailView = closeDetailView,
  CloseQuestCatalogView = closeQuestCatalogView,
  GetQuestTypeGroupList = getQuestTypeGroupList,
  GetStateIconByQuestId = getStateIconByQuestId,
  GetQuestRewardById = getQuestRewardById,
  GetQuestDetailCatalogueDatas = getQuestDetailCatalogueDatas,
  IsValidQuest = isValidQuest,
  GetQuestSeriesRewardById = getQuestSeriesRewardById,
  GetEpisodeChapterCatalogueInfos = getEpisodeChapterCatalogueInfos,
  GetEpisodeOrderedChapterCatalog = getEpisodeOrderedChapterCatalog,
  GetFirstEpisodeChaterIndex = getFirstEpisodeChaterIndex,
  IsLockEpisodeChater = isLockEpisodeChater
}
return ret
