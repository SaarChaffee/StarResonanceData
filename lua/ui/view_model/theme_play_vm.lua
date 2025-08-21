local ThemePlayVM = {}
local worldProxy = require("zproxy.world_proxy")

function ThemePlayVM:OpenMainView(activityId)
  Z.CoroUtil.create_coro_xpcall(function()
    local themePlayData = Z.DataMgr.Get("theme_play_data")
    Z.VMMgr.GetVM("recommendedplay").AsyncGetRecommendPlayData(themePlayData.CancelSource:CreateToken())
    Z.UIMgr:OpenView("themeact_main", {
      Type = E.ThemeActivitySubType.SeasonActivity,
      ActivityId = activityId
    })
  end)()
end

function ThemePlayVM:GetShowBannerActivityList()
  local resultList = {}
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local themeDataDict = recommendedPlayData:GetServerDataByFunctionType(E.SeasonActFuncType.Theme)
  for id, themeData in pairs(themeDataDict) do
    local config = Z.TableMgr.GetRow("SeasonActTableMgr", id)
    if config.EscBanner and self:CheckActivityFuncCond(config) and self:CheckActivityTimeCond(config) then
      local data = {
        type = E.MenuBannerType.Theme,
        config = config
      }
      table.insert(resultList, data)
    end
  end
  table.sort(resultList, function(a, b)
    if a.config.Sort == b.config.Sort then
      return a.config.Id < b.config.Id
    else
      return a.config.Sort < b.config.Sort
    end
  end)
  return resultList
end

function ThemePlayVM:GetMainActivityList()
  local resultList = {}
  local tempDict = {}
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local themeDataDict = recommendedPlayData:GetServerDataByFunctionType(E.SeasonActFuncType.Theme)
  for id, themeData in pairs(themeDataDict) do
    local config = Z.TableMgr.GetRow("SeasonActTableMgr", id)
    if config.MainActivityId ~= 0 then
      local targetConfig = Z.TableMgr.GetRow("SeasonActTableMgr", config.MainActivityId)
      if targetConfig ~= nil then
        if tempDict[targetConfig.Id] == nil then
          tempDict[targetConfig.Id] = {
            config = targetConfig,
            controlId = config.Id,
            childIdList = {}
          }
        else
          tempDict[targetConfig.Id].controlId = config.Id
        end
      end
    elseif 0 < #config.ParentId then
      if self:CheckActivityFuncCond(config) and self:CheckActivityTimeCond(config) then
        for i, parentId in ipairs(config.ParentId) do
          local parentConfig = Z.TableMgr.GetRow("SeasonActTableMgr", parentId)
          if parentConfig ~= nil then
            if tempDict[parentConfig.Id] == nil then
              tempDict[parentConfig.Id] = {
                config = parentConfig,
                childIdList = {}
              }
            end
            table.insert(tempDict[parentConfig.Id].childIdList, id)
          end
        end
      end
    elseif tempDict[config.Id] == nil then
      tempDict[config.Id] = {
        config = config,
        childIdList = {}
      }
    end
  end
  for id, data in pairs(tempDict) do
    if self:CheckActivityFuncCond(data.config) and self:CheckActivityTimeCond(data.config, data.controlId) then
      table.insert(resultList, data)
    end
  end
  table.sort(resultList, function(a, b)
    if a.config.Sort == b.config.Sort then
      return a.config.Id < b.config.Id
    else
      return a.config.Sort < b.config.Sort
    end
  end)
  return resultList
end

function ThemePlayVM:CheckActivityFuncCond(config)
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  if config and not config.HideActUi and (config.FunctionId == 0 or gotoFuncVM.FuncIsOn(config.FunctionId, true)) then
    if #config.ShowCondition == 0 or Z.ConditionHelper.CheckCondition(config.ShowCondition, false) then
      return true
    else
      return false
    end
  else
    return false
  end
  return false
end

function ThemePlayVM:CheckActivityTimeCond(config, controlId)
  local activityId = controlId or config.Id
  local stage = self:GetActivityTimeStage(activityId)
  return stage == E.SeasonActivityTimeStage.Open
end

function ThemePlayVM:GetActivityTimeStamp(id)
  local recommendedPlayData = Z.DataMgr.Get("recommendedplay_data")
  local serverData = recommendedPlayData:GetServerData(E.SeasonActFuncType.Theme, id)
  if serverData ~= nil then
    local recommendedPlayVM = Z.VMMgr.GetVM("recommendedplay")
    local startTime, endTime = recommendedPlayVM.GetTimeStampByServerData(serverData)
    return startTime, endTime
  else
    return 0, 0
  end
end

function ThemePlayVM:GetActivityTimeStage(id)
  local currentTime = Z.TimeTools.Now() / 1000
  local startTime, endTime = self:GetActivityTimeStamp(id)
  if currentTime < startTime then
    return E.SeasonActivityTimeStage.NotOpen
  elseif currentTime > endTime then
    return E.SeasonActivityTimeStage.Over
  else
    return E.SeasonActivityTimeStage.Open
  end
end

function ThemePlayVM:AsyncGetSignAward(type, day, cancelToken)
  local request = {signType = type, signDays = day}
  local ret = worldProxy.GetSignReward(request, cancelToken)
  if ret ~= nil and ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret ~= nil and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  else
    return true
  end
end

function ThemePlayVM:CheckIsNew(config)
  return not Z.LocalUserDataMgr.GetBoolByLua(E.LocalUserDataType.Character, "THEME_ACTIVITY_NEW_" .. config.Id, false)
end

function ThemePlayVM:SetNewDirty(config)
  Z.LocalUserDataMgr.SetBoolByLua(E.LocalUserDataType.Character, "THEME_ACTIVITY_NEW_" .. config.Id, true)
end

function ThemePlayVM:CheckActivityNewRed()
  local activityList = self:GetMainActivityList()
  for i, data in ipairs(activityList) do
    local timeStage = self:GetActivityTimeStage(data.config.Id)
    if timeStage ~= E.SeasonActivityTimeStage.NotOpen then
      local redDotId = data.config.ShowNewRed
      if redDotId ~= 0 then
        local isNew = self:CheckIsNew(data.config)
        Z.RedPointMgr.UpdateNodeCount(redDotId, isNew and 1 or 0)
      end
      for j, childId in ipairs(data.childIdList) do
        local childConfig = Z.TableMgr.GetRow("SeasonActTableMgr", childId)
        local childRedDotId = childConfig.ShowNewRed
        if childRedDotId ~= 0 then
          local isNew = self:CheckIsNew(childConfig)
          local resultRedDotId = data.config.Id .. "_" .. childRedDotId
          Z.RedPointMgr.AddChildNodeData(childRedDotId, childRedDotId, resultRedDotId)
          Z.RedPointMgr.UpdateNodeCount(resultRedDotId, isNew and 1 or 0)
        end
      end
    end
  end
end

return ThemePlayVM
