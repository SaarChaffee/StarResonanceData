local cls = {}
local seasonAchievementData = Z.DataMgr.Get("season_achievement_data")

function cls.GetAchievementDetail(id)
  local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(id)
  local detail = {}
  detail.state = 0
  detail.need = 1
  detail.current = 0
  detail.config = config
  if config == nil then
    return detail
  end
  if config.SeasonId ~= seasonAchievementData.season_ then
    logError("achievement {0},is not in current season", id)
    return detail
  end
  detail.need = config.Num
  local current, received = cls.getContainerAchievement(id)
  detail.current = current
  if received then
    detail.state = 2
  else
    detail.state = detail.current >= detail.need and 1 or 0
  end
  if 0 >= detail.need then
    logError("{0} \232\191\153\228\184\170\230\136\144\229\176\177\231\154\132\231\155\174\230\160\135\230\149\176\233\135\143\230\152\175{1}\239\188\140\232\191\153\229\144\136\231\144\134\229\144\151\239\188\159", detail.config.Id, detail.need)
  end
  return detail
end

function cls.GetAchievementDetailByAchievementId(achievementId)
  local configData = seasonAchievementData:GetAchievementLevelConfigData(achievementId)
  local detail
  if configData and table.zcount(configData) > 0 then
    for i = 1, table.zcount(configData) do
      detail = cls.GetAchievementDetail(configData[i].Id)
      if detail.state == 0 or detail.state == 1 then
        break
      end
    end
  end
  return detail, configData
end

function cls.GetClassify()
  local data = {}
  for id, _ in pairs(seasonAchievementData.classify_) do
    local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(id)
    if config then
      table.insert(data, config)
    end
  end
  table.sort(data, function(a, b)
    return a.SortID < b.SortID
  end)
  return data
end

function cls.GetClassifyProgress(id)
  local totalCount = 0
  local finishCount = 0
  local classify = seasonAchievementData.classify_[id]
  if not classify then
    return 0, 0
  end
  for _, configs in pairs(classify) do
    totalCount = totalCount + #configs
    for _, config in pairs(configs) do
      local data = cls.GetAchievementDetail(config.Id)
      if data.state >= 1 then
        finishCount = finishCount + 1
      end
    end
  end
  return finishCount, totalCount
end

function cls.ClassifyHasUnReceivedReward(id)
  local classify = seasonAchievementData.classify_[id]
  if not classify then
    return false
  end
  for _, queue in pairs(classify) do
    for _, achievement in pairs(queue) do
      local data = cls.GetAchievementDetail(achievement.Id)
      if data.state == 1 then
        return true
      end
    end
  end
  return false
end

function cls.GetAchievements(id)
  local classify = seasonAchievementData.classify_[id]
  if not classify then
    return {}
  end
  local ret = {}
  for _, configs in pairs(classify) do
    local len = #configs
    for i, config in pairs(configs) do
      local data = cls.GetAchievementDetail(config.Id)
      if i == len or data.state <= 1 then
        table.insert(ret, config)
        break
      end
    end
  end
  table.sort(ret, function(a, b)
    local detailA = cls.GetAchievementDetail(a.Id)
    local detailB = cls.GetAchievementDetail(b.Id)
    if detailA.state == detailB.state then
      return a.Id < b.Id
    else
      local priorityA = detailA.state == 1 and 3 or detailA.state == 0 and 2 or 1
      local priorityB = detailB.state == 1 and 3 or detailB.state == 0 and 2 or 1
      return priorityA > priorityB
    end
  end)
  return ret
end

function cls.GetNextAchievement(config)
  local achievement = seasonAchievementData.nextAchievements_[config.Id]
  if achievement then
    return achievement
  end
  return config
end

function cls.AsyncGetAchievementReward(id, token)
  local detail = cls.GetAchievementDetail(id)
  if detail.state ~= 1 then
    return
  end
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.ReceiveSeasonAchievementAward(id, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  return ret
end

function cls.getContainerAchievement(id)
  local data = Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList
  local seasonAchievements = data[seasonAchievementData.season_]
  if not seasonAchievements then
    return 0, false
  end
  local achievement = seasonAchievements.seasonAchievement[id]
  if not achievement then
    return 0, false
  end
  return achievement.finishNum, achievement.hasReceived
end

return cls
