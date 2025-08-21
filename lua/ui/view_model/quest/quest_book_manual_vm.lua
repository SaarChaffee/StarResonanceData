local QuestBookManualVM = {}

function QuestBookManualVM.GetQuestChapterInfos(questType)
  local episodeData = Z.DataMgr.Get("episode_data")
  local questChaterInfos = episodeData:GetChapterInfos(questType)
  if questChaterInfos then
    return questChaterInfos
  end
  local questInfoTitleTableMgr = Z.TableMgr.GetTable("QuestInfoTitleTableMgr")
  local questInfoList = questInfoTitleTableMgr.GetDatas()
  local questChapterInfos = {}
  for index, value in pairs(questInfoList) do
    if value.TaskType == questType then
      table.insert(questChapterInfos, value)
    end
  end
  table.sort(questChapterInfos, function(leftRow, rightRow)
    return leftRow.Order < rightRow.Order
  end)
  episodeData:SetChapterInfos(questType, questChapterInfos)
  return questChapterInfos
end

function QuestBookManualVM.GetUnlockedChapters(questType)
  local chapterInfos = QuestBookManualVM.GetQuestChapterInfos(questType)
  local unlockedChapters = {}
  for _, chapterInfo in ipairs(chapterInfos) do
    local unlockedPhases = QuestBookManualVM.GetChapterUnLockedPhaseIds(chapterInfo)
    if unlockedPhases ~= nil and 0 < #unlockedPhases then
      table.insert(unlockedChapters, {questInfoTitleTableRow = chapterInfo, unlockedPhaseIds = unlockedPhases})
    end
  end
  return unlockedChapters
end

function QuestBookManualVM.GetChapterUnLockedPhaseIds(questInfoTitleTableRow)
  if questInfoTitleTableRow == nil then
    return false
  end
  local episodeInfos = questInfoTitleTableRow.EpisodeInfo
  if episodeInfos == nil or #episodeInfos < 1 then
    logError("episodeInfos is nil")
    return false
  end
  local unlockedPhaseIds = {}
  for _, phaseId in ipairs(episodeInfos) do
    local isUnlock = QuestBookManualVM.IsPhaseUnlocked(phaseId)
    if isUnlock then
      table.insert(unlockedPhaseIds, phaseId)
    else
      return unlockedPhaseIds
    end
  end
  return unlockedPhaseIds
end

function QuestBookManualVM.IsPhaseUnlocked(configId)
  if configId == nil then
    return false
  end
  local questInfoMgr = Z.TableMgr.GetTable("QuestInfoTableMgr")
  local questInfo = questInfoMgr.GetRow(configId)
  if questInfo == nil then
    return false
  end
  local questId = questInfo.Unlock
  local questVm = Z.VMMgr.GetVM("quest")
  local isFinish = questVm.IsQuestFinish(questId)
  return isFinish
end

function QuestBookManualVM.GetChapterEpisodeAndPhases(unlockedPhaseIds)
  local questInfoMgr = Z.TableMgr.GetTable("QuestInfoTableMgr")
  local ret = {}
  local indexMap = {}
  for _, phaseId in ipairs(unlockedPhaseIds) do
    local questInfo = questInfoMgr.GetRow(phaseId)
    if questInfo ~= nil then
      local index = indexMap[questInfo.TitleOrder]
      if index == nil then
        index = #ret + 1
        indexMap[questInfo.TitleOrder] = index
        table.insert(ret, {
          episodeId = questInfo.TitleOrder,
          episodeName = questInfo.TitleName,
          phases = {}
        })
      end
      local episonData = ret[index]
      table.insert(episonData.phases, questInfo)
    end
  end
  return ret
end

function QuestBookManualVM.GetBookShowEpisodeAnPhaseDatas(episodeDatas, fadeOutEpisodeIds)
  if episodeDatas == nil then
    return {}
  end
  local ret = {}
  for _, episodeData in ipairs(episodeDatas) do
    local episodeId = episodeData.episodeId
    local episodeName = episodeData.episodeName
    local phaseDatas = episodeData.phases
    local isFadeOut = table.zcontains(fadeOutEpisodeIds, episodeId)
    table.insert(ret, {
      isEpisode = true,
      episodeId = episodeId,
      episodeName = episodeName,
      isFadeOut = isFadeOut
    })
    if isFadeOut then
      for _, phaseInfo in ipairs(phaseDatas) do
        table.insert(ret, {isEpisode = false, phaseInfo = phaseInfo})
      end
    end
  end
  return ret
end

return QuestBookManualVM
