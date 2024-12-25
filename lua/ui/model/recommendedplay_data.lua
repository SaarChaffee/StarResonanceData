local super = require("ui.model.data_base")
local RecommendedPlayData = class("RecommendedPlayData", super)

function RecommendedPlayData:ctor()
  self.seasonId_ = 0
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
  self.AllRedDots = {}
  self.serverData_ = {}
  self.DefaultSelectId = 1
end

function RecommendedPlayData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function RecommendedPlayData:UnInit()
  self.CancelSource:Recycle()
end

function RecommendedPlayData:InitData()
  if self.seasonId_ == 0 then
    return
  end
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
  local seasonActTableDatas = Z.TableMgr.GetTable("SeasonActTableMgr").GetDatas()
  for _, value in pairs(seasonActTableDatas) do
    if value.SeasonId == self.seasonId_ then
      if self.recommendedPlayFirstTags_[value.Type[1]] == nil then
        self.recommendedPlayFirstTags_[value.Type[1]] = {}
      end
      if value.ParentId and value.ParentId ~= 0 then
        if self.recommendedPlaySecondTags_[value.ParentId] == nil then
          self.recommendedPlaySecondTags_[value.ParentId] = {}
        end
        table.insert(self.recommendedPlaySecondTags_[value.ParentId], value)
      else
        table.insert(self.recommendedPlayFirstTags_[value.Type[1]], value)
      end
      if value.FunctionId and value.FunctionId ~= 0 then
        self.recommendedPlayConfigFunctionIdKey_[value.FunctionId] = value
      end
      if value.RelatedDungeonId and value.RelatedDungeonId ~= 0 then
        self.recommendedPlayConfigDungeonIdKey_[value.RelatedDungeonId] = value
      end
      if value.Type[2] then
        local type = value.Type[2]
        if self.recommendedPlayFirstTags_[type] == nil then
          self.recommendedPlayFirstTags_[type] = {}
        end
        table.insert(self.recommendedPlayFirstTags_[type], value)
      end
    end
  end
  local minType = 1
  for type, firstTags in pairs(self.recommendedPlayFirstTags_) do
    if type < minType then
      minType = type
    end
    table.sort(firstTags, function(a, b)
      return a.Sort < b.Sort
    end)
  end
  for _, secondTags in pairs(self.recommendedPlaySecondTags_) do
    table.sort(secondTags, function(a, b)
      return a.Sort < b.Sort
    end)
  end
  self.DefaultSelectId = self.recommendedPlayFirstTags_[minType][1].Id
  if self.recommendedPlaySecondTags_[self.DefaultSelectId] then
    self.DefaultSelectId = self.recommendedPlaySecondTags_[self.DefaultSelectId][1].Id
  end
end

function RecommendedPlayData:Clear()
  self.seasonId_ = 0
  self.recommendedPlayFirstTags_ = {}
  self.recommendedPlaySecondTags_ = {}
  self.recommendedPlayConfigFunctionIdKey_ = {}
  self.recommendedPlayConfigDungeonIdKey_ = {}
end

function RecommendedPlayData:SetSeasonId(seasonId)
  self.seasonId_ = seasonId
  self:InitData()
end

function RecommendedPlayData:GetAllFirstTags()
  return self.recommendedPlayFirstTags_
end

function RecommendedPlayData:GetSecondTagsByType(type)
  return self.recommendedPlayFirstTags_[type]
end

function RecommendedPlayData:GetThirdTagsById(id)
  local res = {}
  local index = 0
  if self.recommendedPlaySecondTags_[id] then
    local seasonActTableConfig = Z.TableMgr.GetTable("SeasonActTableMgr").GetRow(id)
    if seasonActTableConfig and seasonActTableConfig.FunctionId == E.FunctionID.HeroDungeon then
      for _, thirdTags in ipairs(self.recommendedPlaySecondTags_[id]) do
        if thirdTags.RelatedDungeonId ~= 0 and self:checkDungeonOpen(thirdTags) then
          index = index + 1
          res[index] = thirdTags
        elseif thirdTags.RelatedDungeonId == 0 then
          index = index + 1
          res[index] = thirdTags
        end
      end
    else
      for _, thirdTags in ipairs(self.recommendedPlaySecondTags_[id]) do
        index = index + 1
        res[index] = thirdTags
      end
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

function RecommendedPlayData:SetServerData(serverData)
  self.serverData_ = serverData
end

function RecommendedPlayData:GetSreverData(id)
  return self.serverData_[id]
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

return RecommendedPlayData
