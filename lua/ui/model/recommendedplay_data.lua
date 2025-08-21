local super = require("ui.model.data_base")
local RecommendedPlayData = class("RecommendedPlayData", super)
local cjson = require("cjson")

function RecommendedPlayData:ctor()
  self.seasonId_ = 0
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
  self.recommendedPlayConfigQuestIdKey_ = {}
  self.recommendedPlayAllFunctionIds_ = {}
  self.AllRedDots = {}
  self.serverData_ = {}
  self.LeisureActivitiesTips = {}
  self.TimerMgr = Z.TimerMgr.new()
end

function RecommendedPlayData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function RecommendedPlayData:UnInit()
  self.CancelSource:Recycle()
end

function RecommendedPlayData:OnLanguageChange()
  self:InitData()
end

function RecommendedPlayData:InitData()
  if self.seasonId_ == 0 then
    return
  end
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
  self.recommendedPlayConfigQuestIdKey_ = {}
  local seasonActTableDatas = Z.TableMgr.GetTable("SeasonActTableMgr").GetDatas()
  for _, value in pairs(seasonActTableDatas) do
    if value.SeasonId == self.seasonId_ and value.FunctionType == E.SeasonActFuncType.Recommend and not value.HideActUi then
      if self.recommendedPlayFirstTags_[value.Type[1]] == nil then
        self.recommendedPlayFirstTags_[value.Type[1]] = {}
      end
      if value.ParentId and 0 < #value.ParentId then
        for i, parentId in ipairs(value.ParentId) do
          if self.recommendedPlaySecondTags_[parentId] == nil then
            self.recommendedPlaySecondTags_[parentId] = {}
          end
          table.insert(self.recommendedPlaySecondTags_[parentId], value)
        end
      else
        table.insert(self.recommendedPlayFirstTags_[value.Type[1]], value)
      end
      if value.FunctionId and value.FunctionId ~= 0 then
        self.recommendedPlayConfigFunctionIdKey_[value.FunctionId] = value
      end
      if value.RelatedDungeonId and value.RelatedDungeonId ~= 0 then
        self.recommendedPlayConfigDungeonIdKey_[value.RelatedDungeonId] = value
      end
      if value.RelatedQuest and value.RelatedQuest ~= 0 then
        self.recommendedPlayConfigQuestIdKey_[value.RelatedQuest] = value
      end
    end
    if value.SeasonId == self.seasonId_ and not value.HideActUi and value.FunctionId and value.FunctionId ~= 0 then
      table.insert(self.recommendedPlayAllFunctionIds_, value.FunctionId)
    end
  end
  for _, firstTags in pairs(self.recommendedPlayFirstTags_) do
    table.sort(firstTags, function(a, b)
      return a.Sort < b.Sort
    end)
  end
  for _, secondTags in pairs(self.recommendedPlaySecondTags_) do
    table.sort(secondTags, function(a, b)
      return a.Sort < b.Sort
    end)
  end
end

function RecommendedPlayData:Clear()
  self.seasonId_ = 0
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
  self.recommendedPlayConfigQuestIdKey_ = {}
end

function RecommendedPlayData:SetSeasonId(seasonId)
  self.seasonId_ = seasonId
  self:InitData()
end

function RecommendedPlayData:GetDefaultSelect()
  local defaultSelectId
  local types = {}
  for type, _ in pairs(self.recommendedPlayFirstTags_) do
    table.insert(types, type)
  end
  table.sort(types, function(a, b)
    return a < b
  end)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  for _, type in ipairs(types) do
    for _, firstTag in ipairs(self.recommendedPlayFirstTags_[type]) do
      if firstTag.FunctionId == nil or firstTag.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(firstTag.FunctionId, true) then
        if self.recommendedPlaySecondTags_[firstTag.Id] then
          for _, secondTag in ipairs(self.recommendedPlaySecondTags_[firstTag.Id]) do
            if secondTag.FunctionId == nil or secondTag.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(secondTag.FunctionId, true) then
              return secondTag.Id
            end
          end
        else
          return firstTag.Id
        end
      end
    end
  end
  return nil
end

function RecommendedPlayData:GetAllFirstTags()
  local res = {}
  for type, _ in pairs(self.recommendedPlayFirstTags_) do
    local temp = self:GetSecondTagsByType(type)
    if 0 < #temp then
      table.insert(res, type)
    end
  end
  return res
end

function RecommendedPlayData:GetSecondTagsByType(type)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local res = {}
  for _, firstTag in ipairs(self.recommendedPlayFirstTags_[type]) do
    if firstTag.FunctionId == nil or firstTag.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(firstTag.FunctionId, true) then
      if self.recommendedPlaySecondTags_[firstTag.Id] then
        local canShow = false
        for _, secondTag in ipairs(self.recommendedPlaySecondTags_[firstTag.Id]) do
          if secondTag.FunctionId == nil or secondTag.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(secondTag.FunctionId, true) then
            canShow = true
            break
          end
        end
        if canShow then
          table.insert(res, firstTag)
        end
      else
        table.insert(res, firstTag)
      end
    end
  end
  return res
end

function RecommendedPlayData:GetThirdTagsById(id)
  local res = {}
  local index = 0
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if self.recommendedPlaySecondTags_[id] then
    local seasonActTableConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
    if seasonActTableConfig and seasonActTableConfig.FunctionId == E.FunctionID.HeroDungeon and gotoFuncVM.CheckFuncCanUse(E.FunctionID.HeroDungeon, true) then
      for _, thirdTags in ipairs(self.recommendedPlaySecondTags_[id]) do
        if thirdTags.FunctionId == nil or thirdTags.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(thirdTags.FunctionId, true) then
          if thirdTags.RelatedDungeonId ~= 0 and self:checkDungeonOpen(thirdTags) then
            index = index + 1
            res[index] = thirdTags
          elseif thirdTags.RelatedDungeonId == 0 then
            index = index + 1
            res[index] = thirdTags
          end
        end
      end
    else
      for _, thirdTags in ipairs(self.recommendedPlaySecondTags_[id]) do
        if thirdTags.FunctionId == nil or thirdTags.FunctionId == 0 or gotoFuncVM.CheckFuncCanUse(thirdTags.FunctionId, true) then
          index = index + 1
          res[index] = thirdTags
        end
      end
    end
    if seasonActTableConfig.FunctionId == E.FunctionID.LeisureActivities then
      local recommendedPlayVM = Z.VMMgr.GetVM("recommendedplay")
      table.sort(res, function(a, b)
        local aState = recommendedPlayVM.GetActivityState(a.Id)
        local bState = recommendedPlayVM.GetActivityState(b.Id)
        if aState == bState then
          return a.Sort < b.Sort
        else
          return aState < bState
        end
      end)
    end
  end
  if index == 0 then
    return nil
  else
    return res
  end
end

function RecommendedPlayData:GetRecommendedPlayConfigByFunctionId(functionId)
  return self.recommendedPlayConfigFunctionIdKey_[functionId]
end

function RecommendedPlayData:GetRecommendedPlayConfigByDungeonId(dungeonId)
  return self.recommendedPlayConfigDungeonIdKey_[dungeonId]
end

function RecommendedPlayData:GetRecommendedPlayConfigByQuest()
  return self.recommendedPlayConfigQuestIdKey_
end

function RecommendedPlayData:SetServerData(serverData)
  self.serverData_ = {}
  for id, data in pairs(serverData) do
    local config = Z.TableMgr.GetRow("SeasonActTableMgr", id)
    if config ~= nil then
      local funcType = config.FunctionType
      if config.MainActivityId ~= 0 then
        local targetConfig = Z.TableMgr.GetRow("SeasonActTableMgr", config.MainActivityId)
        if targetConfig ~= nil then
          funcType = targetConfig.FunctionType
        end
      end
      if self.serverData_[funcType] == nil then
        self.serverData_[funcType] = {}
      end
      self.serverData_[funcType][id] = data
    end
  end
  local themePlayVM = Z.VMMgr.GetVM("theme_play")
  themePlayVM:CheckActivityNewRed()
end

function RecommendedPlayData:GetServerDataByFunctionType(funcType)
  return self.serverData_[funcType] or {}
end

function RecommendedPlayData:GetServerData(funcType, id)
  local data = self:GetServerDataByFunctionType(funcType)
  return data[id]
end

function RecommendedPlayData:checkDungeonOpen(seasonActRow)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local dungeonList = dungeonData:GetDungeonList()
  for _, v in ipairs(dungeonList) do
    if v == seasonActRow.RelatedDungeonId then
      return true
    end
  end
  return false
end

function RecommendedPlayData:CheckFunctionOpenNeedRequestServerData(functionId)
  if functionId == E.FunctionID.SeasonActivity then
    return true
  end
  for _, v in ipairs(self.recommendedPlayAllFunctionIds_) do
    if v == functionId then
      return true
    end
  end
end

function RecommendedPlayData:GetActivityStartAndEndTime(funcType, id)
  local serverTimeData = self:GetServerData(funcType, id)
  if serverTimeData == nil then
    return nil, nil
  else
    local startTime, endTime = Z.VMMgr.GetVM("recommendedplay").GetTimeStampByServerData(serverTimeData)
    return startTime, endTime
  end
end

function RecommendedPlayData:InitLocalSave()
  if Z.LocalUserDataMgr.ContainsByLua(E.LocalUserDataType.Character, "LeisureActivitiesTips") then
    self.LeisureActivitiesTips = cjson.decode(Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Character, "LeisureActivitiesTips"))
  else
    self.LeisureActivitiesTips = {}
  end
end

function RecommendedPlayData:GetLocalSave(id)
  local key = "RecommendedPlay_" .. id
  if self.LeisureActivitiesTips[key] == nil then
    return true
  end
  return self.LeisureActivitiesTips[key]
end

function RecommendedPlayData:SaveLocalSave(id, isShowTips)
  local key = "RecommendedPlay_" .. id
  self.LeisureActivitiesTips[key] = isShowTips
  if isShowTips then
    Z.TipsVM.ShowTipsLang(16010011)
    local curTime = Z.TimeTools.Now() / 1000
    local startTime, endTime = self:GetActivityStartAndEndTime(E.SeasonActFuncType.Recommend, id)
    if startTime ~= nil and endTime ~= nil and curTime >= startTime and curTime <= endTime then
      local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
      if config then
        Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, config.FunctionId, true)
      end
    end
  else
    Z.TipsVM.ShowTipsLang(16010012)
    local config = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
    if config then
      Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, config.FunctionId, false)
    end
  end
  local json = cjson.encode(self.LeisureActivitiesTips)
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Character, "LeisureActivitiesTips", json)
  Z.LocalUserDataMgr.Save()
end

return RecommendedPlayData
