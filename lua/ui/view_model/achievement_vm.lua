local cls = {}
local AchievementDefine = require("ui.model.achievement_define")
local AchievementClassTableMap = require("table.AchievementClassTableMap")
local AchievementDataTableMap = require("table.AchievementDateTableMap")

function cls.OpenAchievementMainView()
  Z.UIMgr:OpenView("achievement_window")
end

function cls.GetRedNodeId(id)
  return E.RedType.Achievement .. "_" .. id
end

function cls.CheckRed(achievementId)
  local gotoFunc = Z.VMMgr.GetVM("gotofunc")
  local seasonAchievementFuncIsOpen = gotoFunc.CheckFuncCanUse(E.FunctionID.SeasonAchievement, true)
  local achievementFuncIsOpen = gotoFunc.CheckFuncCanUse(E.FunctionID.Achievement, true)
  if achievementId then
    local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(achievementId)
    local achievement = cls.GetServerAchievement(achievementId)
    if config then
      local nodeName = cls.GetRedNodeId(achievementId)
      if achievement then
        if achievement.hasReceived then
          Z.RedPointMgr.UpdateNodeCount(nodeName, 0)
        elseif achievement.finishNum >= config.Num then
          Z.RedPointMgr.UpdateNodeCount(nodeName, 1)
          local special = false
          if config.SeasonId == nil or config.SeasonId == AchievementDefine.PermanentAchievementType then
            special = true
          end
          if special and achievementFuncIsOpen then
            Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FinishSeasonAchievement, "season_achievement_finish_popup", {
              name = config.Name,
              special = special,
              achievementId = achievementId
            })
          elseif not special and seasonAchievementFuncIsOpen then
            Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FinishSeasonAchievement, "season_achievement_finish_popup", {
              name = config.Name,
              special = special,
              achievementId = achievementId
            })
          end
        else
          Z.RedPointMgr.UpdateNodeCount(nodeName, 0)
        end
      else
        Z.RedPointMgr.UpdateNodeCount(nodeName, 0)
      end
    end
  else
    local achievementClassMgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
    local achievementDateMgr = Z.TableMgr.GetTable("AchievementDateTableMgr")
    local achievementClass = AchievementClassTableMap.Classes
    local curSeasonId = Z.DataMgr.Get("season_data").CurSeasonId
    for key, value in pairs(achievementClass) do
      if key == AchievementDefine.PermanentAchievementType or key == curSeasonId then
        for _, class in ipairs(value) do
          local config = achievementClassMgr.GetRow(class)
          if config and config.EntryList then
            for _, entry in ipairs(config.EntryList) do
              local datas = AchievementDataTableMap.Dates[entry]
              if datas then
                for _, data in ipairs(datas) do
                  local dataConfig = achievementDateMgr.GetRow(data)
                  local achievement = cls.GetServerAchievement(data)
                  local nodeName = cls.GetRedNodeId(data)
                  if dataConfig and achievement and not achievement.hasReceived and achievement.finishNum >= dataConfig.Num then
                    Z.RedPointMgr.UpdateNodeCount(nodeName, 1)
                  else
                    Z.RedPointMgr.UpdateNodeCount(nodeName, 0)
                  end
                end
              end
            end
          end
        end
      end
    end
  end
  local seasonTitleVM = Z.VMMgr.GetVM("season_title")
  local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
end

function cls.achievementWatcher(container, dirtyKeys)
  if dirtyKeys.seasonAchievement then
    local mgr = Z.TableMgr.GetTable("AchievementDateTableMgr")
    for key, _ in pairs(dirtyKeys.seasonAchievement) do
      cls.CheckRed(key)
      local config = mgr.GetRow(key)
      if config and config.Platform then
        Z.SDKAPJ.UnlockAchievement(tostring(key))
      end
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Achievement.OnAchievementDataChange)
  end
end

function cls.RegWatcher()
  local achievementList = Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList
  for _, v in pairs(achievementList) do
    v.Watcher:RegWatcher(cls.achievementWatcher)
  end
end

function cls.UnregWatcher()
  local achievementList = Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList
  for _, v in pairs(achievementList) do
    v.Watcher:UnregWatcher(cls.achievementWatcher)
  end
end

function cls.GetServerAchievement(id)
  local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(id)
  if config then
    local achievementEntries = {}
    local seasonId = AchievementDefine.PermanentAchievementType
    if config.SeasonId and config.SeasonId ~= 0 then
      seasonId = config.SeasonId
    end
    if Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList and Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList[seasonId] then
      achievementEntries = Z.ContainerMgr.CharSerialize.seasonAchievementList.seasonAchievementList[seasonId].seasonAchievement
    end
    return achievementEntries[id]
  end
  return nil
end

function cls.GetClassFinishCountAndTotalCount(id)
  local finishCount = 0
  local totalCount = 0
  local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(id)
  if config == nil or config.EntryList == nil then
    return finishCount, totalCount
  end
  for _, entry in ipairs(config.EntryList) do
    local temp1, temp2 = cls.GetSmallClassFinishCountAndTotalCount(entry)
    finishCount = finishCount + temp1
    totalCount = totalCount + temp2
  end
  return finishCount, totalCount
end

function cls.GetSmallClassFinishCountAndTotalCount(class)
  local achievementIds = AchievementDataTableMap.Dates[class]
  local finishCount = 0
  local totalCount = #achievementIds
  if achievementIds then
    local mgr = Z.TableMgr.GetTable("AchievementDateTableMgr")
    for _, achievementId in ipairs(achievementIds) do
      local achievement = cls.GetServerAchievement(achievementId)
      local config = mgr.GetRow(achievementId)
      finishCount = config and achievement and achievement.finishNum >= config.Num and finishCount + 1 or finishCount
    end
  end
  return finishCount, totalCount
end

function cls.GetClassShowCount(id)
  local showCount = 0
  local config = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr").GetRow(id)
  if config == nil or config.EntryList == nil then
    return showCount
  end
  for _, entry in ipairs(config.EntryList) do
    showCount = showCount + cls.GetSmallClassShowCount(entry)
  end
  return showCount
end

function cls.GetSmallClassShowCount(class)
  local showCount = 0
  local achievementIds = AchievementDataTableMap.Dates[class]
  if achievementIds then
    local mgr = Z.TableMgr.GetTable("AchievementDateTableMgr")
    for _, achievementId in ipairs(achievementIds) do
      local config = mgr.GetRow(achievementId)
      if config then
        if config.TypeIcon == AchievementDefine.AchievementType.Normal then
          showCount = showCount + 1
        elseif config.TypeIcon == AchievementDefine.AchievementType.Hide then
          local achievement = cls.GetServerAchievement(achievementId)
          if achievement and achievement.finishNum >= config.Num then
            showCount = showCount + 1
          end
        end
      end
    end
  end
  return showCount
end

function cls.GetAchievementState(id)
  local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(id)
  if config then
    local achievement = cls.GetServerAchievement(id)
    if achievement == nil then
      return AchievementDefine.AchievementState.UnFinish
    elseif achievement.hasReceived then
      return AchievementDefine.AchievementState.IsReceived
    elseif achievement.finishNum >= config.Num then
      return AchievementDefine.AchievementState.Finish
    else
      return AchievementDefine.AchievementState.UnFinish
    end
  else
    return AchievementDefine.AchievementState.UnFinish
  end
end

function cls.GetAndSortAchievementClass(season)
  local datas = {}
  local dataCount = 0
  local classes = AchievementClassTableMap.Classes[season]
  if classes then
    for _, class in ipairs(classes) do
      if 0 < cls.GetClassShowCount(class) then
        dataCount = dataCount + 1
        datas[dataCount] = class
      end
    end
    local mgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
    table.sort(datas, function(a, b)
      local aConfig = mgr.GetRow(a)
      local bConfig = mgr.GetRow(b)
      if aConfig and aConfig.SortID and bConfig and bConfig.SortID then
        return aConfig.SortID < bConfig.SortID
      else
        return a < b
      end
    end)
  end
  return datas
end

local search = function(config, searchStr)
  if searchStr == nil or searchStr == "" then
    return true
  end
  if string.find(config.Name, searchStr) ~= nil then
    return true
  end
  local achievement = cls.GetServerAchievement(config.Id)
  if achievement then
    local finishNum = math.min(achievement.finishNum, config.Num)
    local progress = Lang("season_achievement_progress", {
      val1 = finishNum,
      val2 = config.Num
    })
    local content = Z.Placeholder.Placeholder(config.Des, {val = progress})
    if string.find(content, searchStr) ~= nil then
      return true
    end
  end
  local achievementId = AchievementDataTableMap.Dates[config.AchievementId]
  if achievementId and achievementId[1] then
    local classConfig = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(achievementId[1])
    if classConfig and string.find(classConfig.Sma11ClassName, searchStr) ~= nil then
      return true
    end
  end
  return false
end

function cls.GetSearchAchievements(season, searchStr)
  local res = {}
  local classes = AchievementClassTableMap.Classes[season]
  local mgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
  local dateMgr = Z.TableMgr.GetTable("AchievementDateTableMgr")
  for _, class in ipairs(classes) do
    local classConfig = mgr.GetRow(class)
    if classConfig and classConfig.EntryList then
      for _, entry in ipairs(classConfig.EntryList) do
        local achievementIds = AchievementDataTableMap.Dates[entry]
        if achievementIds then
          for _, achievementId in ipairs(achievementIds) do
            local achievementConfig = dateMgr.GetRow(achievementId)
            if achievementConfig then
              local isCanShow = false
              if achievementConfig.TypeIcon == AchievementDefine.AchievementType.Normal then
                isCanShow = true
              elseif achievementConfig.TypeIcon == AchievementDefine.AchievementType.Hide then
                local achievement = cls.GetServerAchievement(achievementId)
                if achievement and achievement.finishNum >= achievementConfig.Num then
                  isCanShow = true
                end
              end
              if isCanShow and search(achievementConfig, searchStr) then
                if res[class] == nil then
                  res[class] = {}
                end
                if res[class][entry] == nil then
                  res[class][entry] = {}
                end
                table.insert(res[class][entry], achievementConfig)
              end
            end
          end
        end
      end
    end
  end
  return res
end

function cls.GetAchievementInClassConfig(achievementId)
  local config = Z.TableMgr.GetTable("AchievementDateTableMgr").GetRow(achievementId)
  if config then
    local seasonId = AchievementDefine.PermanentAchievementType
    if config.SeasonId and config.SeasonId ~= 0 then
      seasonId = config.SeasonId
    end
    local mgr = Z.TableMgr.GetTable("AchievementSeasonClassTableMgr")
    if AchievementClassTableMap.Classes[seasonId] then
      for _, v in ipairs(AchievementClassTableMap.Classes[seasonId]) do
        local classConfig = mgr.GetRow(v)
        if classConfig and classConfig.EntryList and 0 < #classConfig.EntryList then
          for _, entry in ipairs(classConfig.EntryList) do
            if entry == config.AchievementId then
              return classConfig
            end
          end
        end
      end
    end
  end
  return nil
end

function cls.AsyncGetAchievementReward(id, token)
  local state = cls.GetAchievementState(id)
  if state ~= AchievementDefine.AchievementState.Finish then
    return
  end
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.ReceiveSeasonAchievementAward(id, token)
  if ret ~= 0 then
    Z.TipsVM.ShowTips(ret)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Achievement.OnAchievementDataChange)
  return ret
end

return cls
