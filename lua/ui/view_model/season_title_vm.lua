local SeasonTitleVM = {}
local worldProxy = require("zproxy.world_proxy")

function SeasonTitleVM.OpenSeasonTitleCourseSubView()
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "season_course_sub", function()
    Z.UIMgr:OpenView("season_course_sub")
  end)
end

function SeasonTitleVM.IsHaveRedDot()
  return SeasonTitleVM.CheckIsUpRankStar() or SeasonTitleVM.IsHaveUnReceivedRankReward() or SeasonTitleVM.IsFinalRewardCanQuicklyJump()
end

function SeasonTitleVM.CheckIsUpRankStar()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local curSeasonInfo = seasonTitleData:GetCurRankInfo()
  if curSeasonInfo == nil then
    return false
  end
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local config = seasonRankTableMgr.GetRow(curSeasonInfo.curRanKStar)
  if config == nil then
    return false
  end
  local nextConifg
  if config.BackRankId and config.BackRankId ~= 0 then
    nextConifg = seasonRankTableMgr.GetRow(config.BackRankId)
  end
  if nextConifg == nil then
    return false
  end
  return Z.ConditionHelper.CheckCondition(nextConifg.Conditions, false)
end

function SeasonTitleVM.CheckRankStarProgress(id)
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local config = seasonRankTableMgr.GetRow(id)
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local allConfigs = seasonTitleData:GetAllConfigs()
  local allRankList = allConfigs[config.RankId]
  if allRankList then
    for key, value in ipairs(allRankList) do
      if value.Id == id then
        return (key - 1) / #allRankList
      end
    end
  end
  return 0
end

function SeasonTitleVM.GetUnReceivedRankId()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  if seasonInfo == nil then
    return seasonTitleData:GetMinRewardRankId()
  end
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local seasonRankConfig = seasonRankTableMgr.GetRow(seasonInfo.curRanKStar)
  if seasonRankConfig == nil then
    return seasonTitleData:GetMinRewardRankId()
  end
  local receivedRankStars = {}
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    receivedRankStars[value] = value
  end
  local allConfigs = seasonTitleData:GetRankRewardConfigList()
  for _, config in ipairs(allConfigs) do
    if config.RankId <= seasonRankConfig.RankId and receivedRankStars[config.Id] == nil and config.RewardId ~= 0 then
      return config.RankId
    elseif config.RankId > seasonRankConfig.RankId and config.RewardId ~= 0 then
      return config.RankId
    end
  end
  return seasonTitleData:GetMaxRewardRankId()
end

function SeasonTitleVM.GetCurUnReceivedCoreRewardRankId()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  if seasonInfo == nil then
    return -1, -1
  end
  local receivedRankStars = {}
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    receivedRankStars[value] = value
  end
  local coreRewardList = seasonTitleData:GetCoreRewardList()
  for _, v in ipairs(coreRewardList) do
    if receivedRankStars[v.Id] == nil then
      return v.Id, v.RankId
    end
  end
  if 0 < #coreRewardList then
    return coreRewardList[#coreRewardList].Id, coreRewardList[#coreRewardList].RankId
  end
  return -1, -1
end

function SeasonTitleVM.IsHaveUnReceivedRankReward()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  if seasonInfo == nil then
    return false, -1
  end
  local receivedRankStars = {}
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    receivedRankStars[value] = value
  end
  local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
  local curRankConfig = seasonRankTableMgr.GetRow(seasonInfo.curRanKStar)
  if curRankConfig == nil then
    return false, -1
  end
  local rankRewardList = seasonTitleData:GetRankRewardConfigList()
  for _, value in ipairs(rankRewardList) do
    if value.RankId <= curRankConfig.RankId and receivedRankStars[value.Id] == nil then
      return true, value.Id
    end
  end
  return false, -1
end

function SeasonTitleVM.IsFinalRewardCanQuicklyJump()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  if seasonInfo == nil then
    return false, false
  end
  local receivedRankStars = {}
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    receivedRankStars[value] = value
  end
  local finalRewardList = seasonTitleData:GetFinalRewardList()
  local coreRewardList = seasonTitleData:GetCoreRewardList()
  local allCoreRewardReceived = true
  for _, value in ipairs(coreRewardList) do
    if receivedRankStars[value.Id] == nil then
      allCoreRewardReceived = false
      break
    end
  end
  if not allCoreRewardReceived then
    return false, false
  end
  return false, true
end

function SeasonTitleVM.IsReceivedRankReward(rankId)
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local seasonInfo = seasonTitleData:GetCurRankInfo()
  if seasonInfo == nil then
    return false
  end
  for _, value in ipairs(seasonInfo.receivedRankStar) do
    if value == rankId then
      return true
    end
  end
  return false
end

function SeasonTitleVM.CheckReply(reply)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end

function SeasonTitleVM.AsyncAdvanceSeasonMaxRankStart()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local viewData = {}
  viewData.lastSeasonRankStar = seasonTitleData:GetCurRankInfo().curRanKStar
  local reply = worldProxy.AdvanceSeasonMaxRankStart(seasonTitleData.CancelSource:CreateToken())
  if SeasonTitleVM.CheckReply(reply) then
    local isHaveUnReceivedRankReward = SeasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
    viewData.curSeasonRankStar = seasonTitleData:GetCurRankInfo().curRanKStar
    Z.UIMgr:OpenView("season_starlevel_popup", viewData)
    Z.EventMgr:Dispatch(Z.ConstValue.SeasonTitle.TitleRankStarUpgrade)
    return true
  end
  return false
end

function SeasonTitleVM.AsyncReceiveSeasonRankAward(rankStar)
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local reply = worldProxy.ReceiveSeasonRankAward(rankStar, seasonTitleData.CancelSource:CreateToken())
  if SeasonTitleVM.CheckReply(reply) then
    local isHaveUnReceivedRankReward = SeasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
    local seasonRankTableMgr = Z.TableMgr.GetTable("SeasonRankTableMgr")
    local seasonRankConfig = seasonRankTableMgr.GetRow(rankStar)
    if seasonRankConfig then
      local rewardIds = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(seasonRankConfig.RewardId)
      local data = {}
      for _, value in ipairs(rewardIds) do
        data[#data + 1] = {
          configId = value.awardId,
          count = value.awardNum
        }
      end
      Z.VMMgr.GetVM("item_show").OpenItemShowView(data)
      Z.EventMgr:Dispatch(Z.ConstValue.SeasonTitle.ReceivedRankReward)
    end
    return true
  end
  return false
end

function SeasonTitleVM.AsyncSetSeasonRankShowArmband(rankStar, cancelToken)
  local reply = worldProxy.SetSeasonRankShowArmband(rankStar, cancelToken)
  if SeasonTitleVM.CheckReply(reply) then
    return true
  end
  return false
end

function SeasonTitleVM.GetCurArmbandIndex()
  local seasonTitleData = Z.DataMgr.Get("season_title_data")
  local curRankInfo = seasonTitleData:GetCurRankInfo()
  if curRankInfo.curRanKStar == nil or curRankInfo.curRanKStar == 0 then
    return 1
  end
  local serverConfig = Z.TableMgr.GetRow("SeasonRankTableMgr", curRankInfo.curRanKStar)
  local allArmbandRewardConfigList = seasonTitleData:GetArmbandRewardList()
  local resultIndex = 1
  for i, v in ipairs(allArmbandRewardConfigList) do
    if v.BigRankId <= serverConfig.BigRankId and v.RankId <= serverConfig.RankId and i > resultIndex then
      resultIndex = i
    end
  end
  return resultIndex
end

return SeasonTitleVM
