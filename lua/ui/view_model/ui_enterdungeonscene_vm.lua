local targetVM = Z.VMMgr.GetVM("target")
local tableMerge = function(t1, t2)
  for k, v in pairs(t2) do
    table.insert(t1, v)
  end
  return t1
end
local getPioneerById = function(id, data)
  for key, value in pairs(data) do
    for k2, v2 in pairs(value) do
      if v2.id == id then
        return v2
      end
    end
  end
end

local function setPerPioneerStage(data, value, levelId, pioneerInfo)
  local exploreInfo, targetInfo = targetVM.GetExploreTarget(value)
  if exploreInfo == nil or targetInfo == nil then
    return
  end
  local progress = pioneerInfo.currentTotal
  if exploreInfo.Type == E.DungeonExploreType.MainTarget then
    if pioneerInfo == nil or pioneerInfo.targets[value] == nil or pioneerInfo.targets[value] == 0 then
      table.insert(data.unfinishMain, {
        id = value,
        num = 0,
        levelId = levelId
      })
    elseif pioneerInfo.targets[value] < targetInfo.Num then
      table.insert(data.unfinishMain, {
        id = value,
        num = pioneerInfo.targets[value],
        levelId = levelId
      })
    else
      table.insert(data.finishMain, {
        id = value,
        num = targetInfo.Num,
        levelId = levelId
      })
    end
  elseif exploreInfo.Type == E.DungeonExploreType.VagueTarget then
    if pioneerInfo == nil or pioneerInfo.targets[value] == nil or pioneerInfo.targets[value] == 0 then
      table.insert(data.fuzzy, {
        id = value,
        num = 0,
        levelId = levelId
      })
    elseif pioneerInfo.targets[value] < targetInfo.Num then
      table.insert(data.unfinishFuzzy, {
        id = value,
        num = pioneerInfo.targets[value],
        levelId = levelId
      })
    else
      table.insert(data.finishFuzzy, {
        id = value,
        num = targetInfo.Num,
        levelId = levelId
      })
    end
  else
    local preconditionId = tonumber(exploreInfo.Param)
    local stage = 0
    if preconditionId ~= nil then
      local poinnerData = getPioneerById(preconditionId, data)
      if poinnerData == nil then
        setPerPioneerStage(data, preconditionId, levelId, pioneerInfo)
        poinnerData = getPioneerById(preconditionId, data)
      end
      if poinnerData ~= nil then
        local _, pTargetInfo = targetVM.GetExploreTarget(poinnerData.id)
        if pTargetInfo then
          if poinnerData.num == pTargetInfo.Num then
            stage = 1
          else
            stage = 2
          end
        end
      else
        stage = 3
      end
    else
      stage = 3
    end
    if stage == 1 then
      if pioneerInfo == nil or pioneerInfo.targets[value] == nil or pioneerInfo.targets[value] == 0 then
        table.insert(data.unfinishHides, {
          id = value,
          num = 0,
          levelId = levelId
        })
      elseif pioneerInfo.targets[value] < targetInfo.Num then
        table.insert(data.unfinishHides, {
          id = value,
          num = pioneerInfo.targets[value],
          levelId = levelId
        })
      else
        table.insert(data.finishHides, {
          id = value,
          num = targetInfo.Num,
          levelId = levelId
        })
      end
    elseif stage == 2 then
      table.insert(data.hides, {
        id = value,
        num = 0,
        levelId = levelId
      })
    elseif pioneerInfo == nil or pioneerInfo.targets[value] == nil or pioneerInfo.targets[value] == 0 then
      table.insert(data.hides, {
        id = value,
        num = 0,
        levelId = levelId
      })
    elseif pioneerInfo.targets[value] < targetInfo.Num then
      table.insert(data.unfinishHides, {
        id = value,
        num = pioneerInfo.targets[value],
        levelId = levelId
      })
    else
      table.insert(data.finishHides, {
        id = value,
        num = targetInfo.Num,
        levelId = levelId
      })
    end
  end
  return data
end

local sortPioneerInfo = function(levelId, pioneerInfo)
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(levelId)
  if not dungeonsTable or not next(dungeonsTable) then
    return {}
  end
  local data = {
    unfinishMain = {},
    unfinishFuzzy = {},
    unfinishHides = {},
    fuzzy = {},
    hides = {},
    finishMain = {},
    finishFuzzy = {},
    finishHides = {}
  }
  for index, value in ipairs(dungeonsTable.ExploreConfig) do
    data = setPerPioneerStage(data, value, levelId, pioneerInfo)
  end
  local pioneerData = {}
  tableMerge(pioneerData, data.unfinishMain)
  tableMerge(pioneerData, data.unfinishFuzzy)
  tableMerge(pioneerData, data.unfinishHides)
  tableMerge(pioneerData, data.fuzzy)
  tableMerge(pioneerData, data.hides)
  tableMerge(pioneerData, data.finishMain)
  tableMerge(pioneerData, data.finishFuzzy)
  tableMerge(pioneerData, data.finishHides)
  return pioneerData
end
local isDungeon = function(configId)
  local cfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(configId)
  if not cfg or not next(cfg) then
    return false
  end
  if cfg.FunctionID == Z.ConstValue.DungeonTypeFuncId then
    return true
  end
  return false
end
local getPioneerDataById = function(id, levelId)
  local data = Z.DataMgr.Get("dungeon_data")
  local pioneerData = data.PioneerInfos[levelId].pioneerData
  for key, value in pairs(pioneerData) do
    if value.id == id then
      return value
    end
  end
  return nil
end
local getPioneerExploreTarget = function(id, levelId)
  local data = getPioneerDataById(id, levelId)
  if data ~= nil then
    local _, target = targetVM.GetExploreTarget(data.id)
    return data, target
  end
  return nil, nil
end
local showPioneerTaskSort = function(valueData, dungeonId)
  local dungeonCfg = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if dungeonCfg == nil or dungeonCfg.ExploreConfig == nil or #dungeonCfg.ExploreConfig <= 0 then
    return
  end
  local exploreIdSortTab = {}
  for i = 1, #dungeonCfg.ExploreConfig do
    exploreIdSortTab[dungeonCfg.ExploreConfig[i]] = i
  end
  local sort = 9999
  for _, data in pairs(valueData) do
    local exploreInfo, targetInfo = targetVM.GetExploreTarget(data.id)
    if exploreInfo ~= nil and targetInfo ~= nil then
      if targetInfo.Num ~= data.num then
        sort = 1000
      else
        sort = 2000
      end
      if exploreInfo.Type == E.DungeonExploreType.MainTarget then
        sort = sort + 100
      elseif exploreInfo.Type == E.DungeonExploreType.HideTarget then
        if 0 < data.num then
          sort = sort + 300
        else
          sort = sort + 500
        end
      elseif 0 < data.num then
        sort = sort + 200
      else
        sort = sort + 400
      end
      sort = sort + exploreIdSortTab[data.id] or 99
      data.sort = sort
    end
  end
  table.sort(valueData, function(left, right)
    return left.sort < right.sort
  end)
end
local asyncCreateLevel = function(functionId, dungeonId, cancelToken, affix, roomId, selectType, heroKeyItemUuid)
  local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if dungeonData then
    local isOpen = Z.ConditionHelper.CheckCondition(dungeonData.Condition, true)
    if not isOpen then
      return
    end
  end
  local parm = {
    playType = functionId,
    dungeonId = dungeonId,
    affix = affix,
    roomId = roomId,
    selectType = selectType or 0,
    heroKeyItemUuid = heroKeyItemUuid or 0
  }
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.StartEnterDungeon(parm, cancelToken)
  Z.TipsVM.ShowTips(ret)
  return ret
end
local asyncGetPioneerInfo = function(levelId)
  local ret = Z.ContainerMgr.CharSerialize.pioneerData.infoMap[levelId]
  local dungenData = {}
  if ret == nil then
    dungenData.currentTotal = 0
    dungenData.targets = {}
    dungenData.awards = {}
  else
    dungenData.currentTotal = ret.currentTotal
    dungenData.targets = {}
    for index, value in pairs(ret.targets) do
      dungenData.targets[index] = value
    end
    dungenData.awards = {}
    for index, value in pairs(ret.awards) do
      dungenData.awards[index] = value
    end
  end
  local pioneerData = sortPioneerInfo(levelId, dungenData)
  local data = Z.DataMgr.Get("dungeon_data")
  data:UpdateData("PioneerInfos", {
    [levelId] = {
      progress = dungenData.currentTotal,
      pioneerData = pioneerData,
      awards = dungenData.awards
    }
  })
  local retDat = {
    [levelId] = {
      progress = dungenData.currentTotal,
      pioneerData = pioneerData,
      awards = dungenData.awards
    }
  }
  return retDat
end
local getNowFinishTargets = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local data = Z.DataMgr.Get("dungeon_data")
  local lastData = data.BeginEnterPioneerInfo[dungeonId]
  local lastFinishiData = {}
  if lastData.pioneerData then
    for key, value in pairs(lastData.pioneerData) do
      local targerData = Z.TableMgr.GetTable("TargetTableMgr").GetRow(value.id)
      if targerData and value.num >= targerData.Num then
        lastFinishiData[value.id] = value
      end
    end
  end
  local cancelSource = Z.CancelSource.Rent()
  local nowData = asyncGetPioneerInfo(dungeonId, cancelSource)[dungeonId]
  cancelSource:Recycle()
  local nowFinishiData = {}
  local nowNotFinishiData = {}
  local tab
  if nowData then
    for key, value in pairs(nowData.pioneerData) do
      local targerData = Z.TableMgr.GetTable("TargetTableMgr").GetRow(value.id)
      if targerData then
        if value.num >= targerData.Num then
          if not lastFinishiData[value.id] then
            nowFinishiData[value.id] = value
          end
        elseif value.num > 0 and not lastFinishiData[value.id] and value.num ~= lastFinishiData[value.id].num then
          nowNotFinishiData[value.id] = value
        end
      end
    end
    tab = nowFinishiData
    for key, value in pairs(nowNotFinishiData) do
      table.insert(tab, value)
    end
  end
  return tab
end
local getUnfinishedTasks = function(doneIDTab_)
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local vlaueData = asyncGetPioneerInfo(dungeonId)[dungeonId]
  local dad = {}
  if not vlaueData or not next(vlaueData.pioneerData) then
    return dad
  end
  local tempDatas = {}
  local insert_ = table.insert
  for _, v in pairs(vlaueData.pioneerData) do
    if not doneIDTab_[v.id] then
      insert_(tempDatas, v)
    end
  end
  showPioneerTaskSort(tempDatas, dungeonId)
  for i = 1, #tempDatas do
    dad[#dad + 1] = {
      id = tempDatas[i].id,
      num = tempDatas[i].num
    }
  end
  return dad
end
local getNowFinishTargetsDungeon = function()
  local data = Z.ContainerMgr.DungeonSyncData.DungeonPioneer.completedTargetThisTime[Z.ContainerMgr.CharSerialize.charBase.charId]
  if not data then
    data = {}
  else
    data = data.completedTargetList
  end
  local tab = {}
  local doneIDTab_ = {}
  for id, value in pairs(data) do
    local tagetTab = Z.TableMgr.GetTable("TargetTableMgr").GetRow(id)
    if tagetTab then
      local tempTab = {}
      tempTab.num = tagetTab.Num
      tempTab.id = id
      tempTab.done = true
      tab[#tab + 1] = tempTab
      doneIDTab_[id] = true
    end
  end
  local tb = getUnfinishedTasks(doneIDTab_)
  for id, value in pairs(tb) do
    tab[#tab + 1] = value
  end
  return tab
end
local asyncSendPioneerAward = function(dungeonInfo, awardId, cancelsource)
  if cancelsource == nil then
    return false
  end
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.GetPioneerAward(dungeonInfo, awardId, cancelsource:CreateToken())
  if ret == 0 then
    local awardList = Z.VMMgr.GetVM("awardpreview").GetAllAwardPreListByIds(awardId)
    local materials = {}
    for _, value in pairs(awardList) do
      table.insert(materials, {
        configId = value.awardId,
        count = value.awardNum
      })
    end
    local itemShowVm = Z.VMMgr.GetVM("item_show")
    itemShowVm.OpenItemShowView(materials)
    Z.VMMgr.GetVM("dungeon").RefreshRedPointByAward(dungeonInfo.dungeonID)
    return true
  end
  return false
end
local isFinalFrontTask = function(configId, num)
  local exploreInfo = Z.TableMgr.GetTable("ExploreTableMgr").GetRow(configId)
  if exploreInfo == nil then
    return
  end
  local preconditionId = exploreInfo.Param
  if preconditionId ~= nil then
    local paramData = string.split(exploreInfo.Param, "=")
    local paraType = tonumber(paramData[1])
    local paraValue = tonumber(paramData[2])
    if paraType == 2 then
      local _, paraTargetInfo = targetVM.GetExploreTarget(paraValue)
      if paraTargetInfo ~= nil then
        if num >= paraTargetInfo.Num then
          return true, paraTargetInfo.Num
        else
          return false, paraTargetInfo.Num
        end
      end
    else
      return true, nil
    end
  else
    return true, nil
  end
end
local getrontTask = function(configId, num)
  local exploreInfo = Z.TableMgr.GetTable("ExploreTableMgr").GetRow(configId)
  if exploreInfo == nil then
    return
  end
  local preconditionId = exploreInfo.Param
  if preconditionId ~= nil then
    local paramData = string.split(exploreInfo.Param, "=")
    local paraType = tonumber(paramData[1])
    local paraValue = tonumber(paramData[2])
    return paraValue
  else
    return nil
  end
end
local notifyPoinnersChange = function(targetId, targetNum)
  local levelId = Z.StageMgr.GetCurrentDungeonId()
  if not isDungeon(levelId) then
    return
  end
  local exploreInfo, targetInfo = targetVM.GetExploreTarget(targetId)
  if exploreInfo == nil or targetInfo == nil then
    return
  end
  local data = Z.DataMgr.Get("dungeon_data")
  if data.PioneerInfos == nil or data.PioneerInfos[levelId] == nil then
    sortPioneerInfo(levelId, {
      currentTotal = 0,
      targets = {}
    })
  end
  local progerss = data.PioneerInfos[levelId].progress
  local pioneerData = data.PioneerInfos[levelId].pioneerData
  for key, value in pairs(pioneerData) do
    if value.id == targetId and targetNum == targetInfo.Num then
      progerss = progerss + exploreInfo.Exploration
      data.PioneerInfos[levelId].progress = progerss
      local param = {
        dungeon = {
          target = targetInfo.TargetDes
        }
      }
      Z.TipsVM.ShowTipsLang(110002, param)
      break
    end
    if exploreInfo.Type == E.DungeonExploreType.VagueTarget then
      if value.id == targetId and targetNum == 1 then
        local info = string.format([[
%s%s
%s%s(%s/%s)]], exploreInfo.Param, Lang("DungeonTips2"), Lang("DungeonTips3"), targetInfo.TargetDes, targetNum, targetInfo.Num)
        local param = {
          dungeon = {target = info}
        }
        Z.TipsVM.ShowTipsLang(110003, param)
        break
      end
    elseif exploreInfo.Type == E.DungeonExploreType.HideTarget then
      local isFinal, frontNum = isFinalFrontTask(targetId, targetNum)
      local numInit
      if not frontNum or frontNum == targetNum then
        numInit = true
      else
        numInit = false
      end
      if value.id == targetId and isFinal and numInit then
        local info = string.format([[
%s
%s]], Lang("DungeonTips1"), targetInfo.TargetDes)
        local param = {
          dungeon = {target = info}
        }
        Z.TipsVM.ShowTipsLang(110003, param)
        break
      end
    end
  end
  Z.EventMgr:Dispatch("NotifyPoinnersChange")
end
local openEnterDungeonSceneView = function(levelId)
  Z.UIMgr:OpenView("dungeon_main", levelId)
end
local isPassDungeon = function(configId)
  local dungeonList = Z.ContainerMgr.CharSerialize.dungeonList.completeDungeon
  if not dungeonList[configId] then
    return false
  else
    return true
  end
end
local isEnterDungeon = function(levelId)
  local dungeonsTable = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(tonumber(levelId))
  if dungeonsTable == nil then
    return
  end
  local isEnter = true
  for key, value in pairs(dungeonsTable.Condition) do
    local vdata = value
    local vType = vdata[1]
    local limitValue = vdata[2]
    if vType == E.DungeonPrecondition.CondQuest then
      local finishQuest = Z.ContainerMgr.CharSerialize.questList.finishQuest
      if not finishQuest or not finishQuest[limitValue] then
        isEnter = false
        local questData = Z.TableMgr.GetTable("QuestTableMgr").GetRow(limitValue)
        if questData then
          local param = {
            quest = {
              name = questData.QuestName
            }
          }
          Z.TipsVM.ShowTipsLang(1001503, param)
        end
      end
    elseif vType == E.DungeonPrecondition.CondDungeon then
      local dungeonList = Z.ContainerMgr.CharSerialize.dungeonList.completeDungeon
      if not dungeonList or not dungeonList[limitValue] then
        isEnter = false
        local dungeonData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(limitValue)
        if dungeonData then
          local param = {
            dungeon = {
              name = dungeonData.Name
            }
          }
          Z.TipsVM.ShowTipsLang(1001504, param)
        end
      end
    end
  end
  return isEnter
end
local getPreconditionStage = function(preconditionId, levelId)
  local stage = 2
  local data, pTargetInfo = getPioneerExploreTarget(preconditionId, levelId)
  if data ~= nil and pTargetInfo ~= nil and data.num == pTargetInfo.Num then
    stage = 1
  end
  return stage
end
local getStage = function(preconditionId, levelId)
  local stage = 2
  local data, pTargetInfo = getPioneerExploreTarget(preconditionId, levelId)
  if data ~= nil and pTargetInfo ~= nil then
    if data.num > 0 and data.num ~= pTargetInfo.Num then
      stage = 1
    elseif data.num == pTargetInfo.Num then
      stage = 3
    end
  end
  return stage
end
local ret = {
  AsyncCreateLevel = asyncCreateLevel,
  AsyncGetPioneerInfo = asyncGetPioneerInfo,
  AsyncSendPioneerAward = asyncSendPioneerAward,
  NotifyPoinnersChange = notifyPoinnersChange,
  GetPioneerDataById = getPioneerDataById,
  OpenEnterDungeonSceneView = openEnterDungeonSceneView,
  IsPassDungeon = isPassDungeon,
  IsEnterDungeon = isEnterDungeon,
  SortPioneerInfo = sortPioneerInfo,
  ShowPioneerTaskSort = showPioneerTaskSort,
  GetNowFinishTargets = getNowFinishTargets,
  GetNowFinishTargetsDungeon = getNowFinishTargetsDungeon,
  GetPreconditionStage = getPreconditionStage,
  GetStage = getStage,
  IsDungeon = isDungeon
}
return ret
