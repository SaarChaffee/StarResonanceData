local QuestLimitVM = {}

function QuestLimitVM.ParseLimitConfig(questTableRow)
  if questTableRow == nil then
    return nil
  end
  local continueLimit = questTableRow.ContinueLimit
  local ret = {}
  if continueLimit ~= nil then
    for i = 1, #continueLimit do
      local limitData = continueLimit[i]
      if ret[tonumber(limitData[1])] == nil then
        ret[tonumber(limitData[1])] = {}
      end
      table.insert(ret[tonumber(limitData[1])], limitData)
    end
  end
  return ret
end

function QuestLimitVM.CheckItemCount(countLimit)
  local itemsVM = Z.VMMgr.GetVM("items")
  local ret = {}
  if countLimit ~= nil then
    for i = 1, #countLimit do
      local limitData = countLimit[i]
      local configId = tonumber(limitData[2])
      local minNum = tonumber(limitData[3])
      local ownNum = itemsVM.GetItemTotalCount(configId)
      ret[i] = {
        state = minNum <= ownNum and E.QuestLimitState.Met or E.QuestLimitState.NotMet,
        params = {
          configId,
          minNum,
          ownNum
        }
      }
    end
  end
  return ret
end

function QuestLimitVM.CheckDateTime(dateTimeLimit)
  local serverTime = Z.ServerTime:GetServerTime() / 1000
  local ret = {}
  if dateTimeLimit ~= nil then
    for i = 1, #dateTimeLimit do
      local limitData = dateTimeLimit[i]
      local dateStr = limitData[2]
      local configTime = Z.TimeTools.TimeString2Stamp(dateStr) / 1000
      local dateSce = math.floor(configTime - serverTime)
      ret[i] = {
        state = dateSce <= 0 and E.QuestLimitState.Met or E.QuestLimitState.NotMet,
        params = {dateSce}
      }
    end
  end
  return ret
end

function QuestLimitVM.CheckRoleLv(roleLimit)
  local ret = {}
  if roleLimit ~= nil then
    for i = 1, #roleLimit do
      local limitData = roleLimit[i]
      local lvLimit = tonumber(limitData[2])
      local pLv = Z.ContainerMgr.CharSerialize.roleLevel.level
      ret[i] = {
        state = lvLimit <= pLv and E.QuestLimitState.Met or E.QuestLimitState.NotMet,
        params = {lvLimit}
      }
    end
  end
  return ret
end

function QuestLimitVM.CheckQuestStep(questStepLimit)
  local questVM = Z.VMMgr.GetVM("quest")
  local ret = {}
  if questStepLimit ~= nil then
    for i = 1, #questStepLimit do
      local limitData = questStepLimit[i]
      local questId = tonumber(limitData[2])
      local questStep = tonumber(limitData[3])
      local isFinish = questVM.IsQuestStepFinish(questId, questStep)
      ret[i] = {
        state = isFinish and E.QuestLimitState.Met or E.QuestLimitState.NotMet,
        params = {questId}
      }
    end
  end
  return ret
end

function QuestLimitVM.CheckTimer(timerLimit)
  local ret = {}
  if timerLimit ~= nil then
    for i = 1, #timerLimit do
      local limitData = timerLimit[i]
      local timerId = tonumber(limitData[2])
      local hasend, startTime, endTime = Z.TimeTools.GetCycleStartEndTimeByTimeId(timerId)
      local serverTime = Z.ServerTime:GetServerTime() / 1000
      if not hasend and startTime < serverTime then
        ret[i] = {
          state = E.QuestLimitState.Met,
          params = {
            startTime = startTime,
            hasend = hasend,
            endTime = endTime
          }
        }
      else
        ret[i] = {
          state = E.QuestLimitState.NotMet,
          params = {
            startTime = startTime,
            hasend = hasend,
            endTime = endTime
          }
        }
      end
    end
  end
  return ret
end

function QuestLimitVM.IsQuestCanBeAdvance(questId)
  if questId == nil or questId <= 0 then
    return false
  end
  local questTableMgr = Z.TableMgr.GetTable("QuestTableMgr")
  local questTableRow = questTableMgr.GetRow(questId)
  if questTableRow == nil then
    return false
  end
  local limitConfigGroup = QuestLimitVM.ParseLimitConfig(questTableRow)
  if limitConfigGroup == nil or not next(limitConfigGroup) then
    return true
  end
  local countLimit = limitConfigGroup[E.EQuestLimitType.ItemCount]
  local itemCountLimit = QuestLimitVM.CheckItemCount(countLimit)
  if next(itemCountLimit) then
    return false
  end
  local dateTimeLimit = limitConfigGroup[E.EQuestLimitType.DateTime]
  local dateTimeLimitCheck = QuestLimitVM.CheckDateTime(dateTimeLimit)
  if next(dateTimeLimitCheck) then
    return false
  end
  local roleLimit = limitConfigGroup[E.EQuestLimitType.RoleLv]
  local roleLvLimitCheck = QuestLimitVM.CheckRoleLv(roleLimit)
  if next(roleLvLimitCheck) then
    return false
  end
  local questStepLimit = limitConfigGroup[E.EQuestLimitType.QuestStep]
  local questStepLimitCheck = QuestLimitVM.CheckQuestStep(questStepLimit)
  if next(questStepLimitCheck) then
    return false
  end
  local timerLimit = limitConfigGroup[E.EQuestLimitType.Timer]
  local timerLimitCheck = QuestLimitVM.CheckTimer(timerLimit)
  if next(timerLimitCheck) then
    return false
  end
  return true
end

return QuestLimitVM
