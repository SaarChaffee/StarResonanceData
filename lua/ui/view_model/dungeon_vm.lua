local initRedpointTag_ = false
local herodungeonRed = require("rednode.hero_dungeon_red")
local getCurrDungeonType = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return E.DungeonType.None
  end
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if cfgData == nil then
    return E.DungeonType.None
  end
  if cfgData.FunctionID == 300301 then
    return E.DungeonType.Planetmemory
  elseif cfgData.FunctionID == 300100 then
    return E.DungeonType.DungeonCopy
  elseif cfgData.FunctionID == 300100 then
    return E.DungeonType.HeroCopy
  elseif cfgData.FunctionID == 800101 then
    return E.DungeonType.Parkour
  elseif cfgData.FunctionID == 800102 then
    return E.DungeonType.Flux
  elseif cfgData.FunctionID == 800103 then
    return E.DungeonType.ThunderElemental
  elseif cfgData.FunctionID == 500100 then
    return E.DungeonType.Union
  elseif cfgData.FunctionID == E.FunctionID.WeeklyHunt then
    return E.DungeonType.WeeklyTower
  else
    return cfgData.PlayType
  end
end
local getWorldEventDungeonData = function(dungeonInfo)
  local WorldEventDungeonData
  if dungeonInfo then
    local viewType
    if dungeonInfo.state == E.DungeonState.DungeonStatePlaying then
      if getCurrDungeonType() == E.DungeonType.Flux then
        local dungeonData = Z.DataMgr.Get("dungeon_data")
        dungeonData.TrackViewShow = true
        Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateTargetViewVisible)
      end
      viewType = E.WorldEventDungeonViewState.Ranking
    elseif dungeonInfo.state == E.DungeonState.DungeonStateSettlement then
      viewType = E.WorldEventDungeonViewState.EndState
    elseif dungeonInfo.state == E.DungeonState.DungeonStateReady then
      if getCurrDungeonType() == E.DungeonType.Flux then
        local dungeonData = Z.DataMgr.Get("dungeon_data")
        dungeonData.TrackViewShow = false
        Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateTargetViewVisible)
      end
      viewType = E.WorldEventDungeonViewState.Prepare
    elseif dungeonInfo ~= nil and dungeonInfo.state ~= nil then
      logWarning("\230\178\161\230\156\137\228\184\142\229\137\175\230\156\172\231\138\182\230\128\129\229\140\185\233\133\141\231\154\132UI\239\188\129\229\189\147\229\137\141\231\138\182\230\128\129\239\188\154" .. dungeonInfo.state)
    end
    WorldEventDungeonData = {dungeonInfo = dungeonInfo, viewType = viewType}
  end
  return WorldEventDungeonData
end
local setWorldEventDungeonHideTag = function()
  local parkourtips_vm = Z.VMMgr.GetVM("parkourtips")
  parkourtips_vm.SetDungeonHideTag(false)
  local fluxRevolt_tooltip_vm = Z.VMMgr.GetVM("flux_revolt_tooltip")
  fluxRevolt_tooltip_vm.SetDungeonHideTag(false)
  local thunder_elemental_vm = Z.VMMgr.GetVM("thunder_elemental")
  thunder_elemental_vm.SetDungeonHideTag(false)
end
local getDungeonType = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId, true)
  if cfgData then
    return cfgData.PlayType
  end
end
local getCurResultType = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if dungeonId == 0 then
    return E.DungeonResultHudType.None
  end
  local cfgData = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
  if cfgData == nil then
    return E.DungeonResultHudType.None
  end
  return cfgData.ShowResultHudType
end
local getRedPointID = function(dungeonId)
  local cfg = Z.TableMgr.GetTable("MainPlotDungeonTableMgr").GetRow(dungeonId, true)
  if cfg then
    return cfg.RedDotIndex
  end
  return 0
end
local calculateRedpointCount = function(dungeonId)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local pioneerInfo = dungeonData.PioneerInfos[dungeonId]
  local cfgData = dungeonData:GetChestIntroductionById(dungeonId)
  local count = 0
  if cfgData and next(cfgData) then
    local id = getRedPointID(dungeonId)
    for _, data in ipairs(cfgData) do
      if pioneerInfo.progress >= data.preValue and not pioneerInfo.awards[data.rewardId] then
        count = count + 1
      end
    end
  end
  return count
end
local refreshRedpoint = function(dungeonId)
  Z.CoroUtil.create_coro_xpcall(function()
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(dungeonId)
    local id = getRedPointID(dungeonId)
    if 0 < id then
      local count = calculateRedpointCount(dungeonId)
      Z.RedPointMgr.UpdateNodeCount(id, count)
    end
  end)()
end
local refreshRedPointByAward = function(dungeonId)
  Z.CoroUtil.create_coro_xpcall(function()
    Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(dungeonId)
    local id = getRedPointID(dungeonId)
    if 0 < id then
      local count = calculateRedpointCount(dungeonId)
      Z.RedPointMgr.UpdateNodeCount(id, count, true)
      Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.DungeonRed, dungeonId, 0 < count)
    end
  end)()
end
local onPionnerProgressChanged = function()
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  if 0 < dungeonId and getCurrDungeonType(dungeonId) == E.DungeonType.DungeonLiner then
    refreshRedpoint(dungeonId)
  end
end
local initRedpoint = function(dungeons)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  for i = 1, #dungeons do
    local pioneerInfo = dungeonData.PioneerInfos[dungeons[i]]
    local cfgData = dungeonData:GetChestIntroductionById(dungeons[i])
    if cfgData and next(cfgData) then
      for _, data in ipairs(cfgData) do
        if pioneerInfo.progress >= data.preValue and not pioneerInfo.awards[data.rewardId] then
          Z.RedPointMgr.UpdateNodeCount(getRedPointID(dungeons[i]), 1)
          break
        end
      end
    end
  end
  Z.EventMgr:Add("NotifyPoinnersChange", onPionnerProgressChanged, self)
end
local initDungeonRedpoint = function()
  local datas = Z.TableMgr.GetTable("MainPlotDungeonTableMgr").GetDatas()
  local dungeonIdList = {}
  for key, _ in pairs(datas) do
    dungeonIdList[#dungeonIdList + 1] = key
  end
  if initRedpointTag_ then
    return
  end
  initRedpointTag_ = true
  Z.CoroUtil.create_coro_xpcall(function()
    for i = 1, #dungeonIdList do
      Z.VMMgr.GetVM("ui_enterdungeonscene").AsyncGetPioneerInfo(dungeonIdList[i])
    end
    initRedpoint(dungeonIdList)
  end)()
end
local asyncGetSeasonDungeonList = function()
  local cancelSource = Z.CancelSource.Rent()
  local worldProxy = require("zproxy.world_proxy")
  local ret = worldProxy.GetSeasonDungeonList(cancelSource:CreateToken())
  if ret then
    local dungeonData = Z.DataMgr.Get("dungeon_data")
    dungeonData:SetDungeonList(ret.dungeonIdList)
    dungeonData:SetDungeonAffixDic(ret.dungeonAffixes)
  end
  cancelSource:Recycle()
end
local setWorldEventDungeonsData = function(vmName, dataName, dungeonInfo)
  if not (vmName and dataName) or not dungeonInfo then
    return
  end
  local viewVm = Z.VMMgr.GetVM(vmName)
  local viewData = Z.DataMgr.Get(dataName)
  local dungeonData = getWorldEventDungeonData(dungeonInfo)
  if not viewVm or not viewData then
    return
  end
  viewData:SetWorldEventDungeonData(dungeonData)
  viewVm.SetDungeonHideTag(true)
  viewVm.OpenTooltipView()
end
local updateDungeonData = function(exit, dirtyKeys)
  local dungeonType = getCurrDungeonType()
  setWorldEventDungeonHideTag()
  local dungeonSyncData = Z.ContainerMgr.DungeonSyncData
  local flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
  local resultType = getCurResultType()
  local state = flowInfo.state
  if state == E.DungeonState.DungeonStateEnd then
    Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.EndDungeon)
  end
  if resultType == E.DungeonResultHudType.Liner or resultType == E.DungeonResultHudType.HeroCopy then
    if state == E.DungeonState.DungeonStateSettlement then
      if dungeonType == E.DungeonType.UnionHunt then
        if state == E.DungeonState.DungeonStateSettlement then
          local unionVM_ = Z.VMMgr.GetVM("union")
          if flowInfo.result == E.DungeonResult.DungeonResultFailed then
            unionVM_:OpenSettlementFailWindow()
          elseif flowInfo.result == E.DungeonResult.DungeonResultSuccess then
            unionVM_:OpenSettlementSuccessWindow()
          end
        end
      elseif dungeonType == E.DungeonType.MasterChallengeDungeon then
        local heroDungeonCopyVm = Z.VMMgr.GetVM("hero_dungeon_copy_window")
        if flowInfo.result == E.DungeonResult.DungeonResultFailed then
          heroDungeonCopyVm.OpenMasterDungeonFailWindow()
        elseif flowInfo.result == E.DungeonResult.DungeonResultSuccess and exit then
          heroDungeonCopyVm.OpenHeroView()
        end
      else
        Z.UIMgr:CloseView("dead")
        local heroDungeonCopyVm = Z.VMMgr.GetVM("hero_dungeon_copy_window")
        if flowInfo.result == E.DungeonResult.DungeonResultFailed then
          heroDungeonCopyVm.OpenSettlementFailWindow()
        elseif flowInfo.result == E.DungeonResult.DungeonResultSuccess and exit then
          heroDungeonCopyVm.OpenHeroView()
        end
      end
    end
  elseif dungeonType == E.DungeonType.WorldBoss and dungeonSyncData.settlement.worldBossSettlement then
    if state == E.DungeonState.DungeonStateSettlement then
      local bossBattleVM = Z.VMMgr.GetVM("bossbattle")
      bossBattleVM.SetBossUuid(nil)
      bossBattleVM.CloseBossUI()
      local worldBossVM = Z.VMMgr.GetVM("world_boss")
      worldBossVM:OpenWorldBossSettlementView()
    end
  elseif resultType == E.DungeonResultHudType.TrialRoad then
    if state == E.DungeonState.DungeonStateSettlement then
      logGreen("[Dungeon] State " .. flowInfo.state .. " Result " .. flowInfo.result)
      local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
      if flowInfo.result == E.DungeonResult.DungeonResultFailed then
        trialroadVM_.OpenSettlementFailWindow()
      elseif flowInfo.result == E.DungeonResult.DungeonResultSuccess then
        trialroadVM_.OpenSettlementSuccessWindow()
      end
    end
  elseif dungeonType == E.DungeonType.WeeklyTower then
  elseif dungeonType == E.DungeonType.Parkour then
    setWorldEventDungeonsData("parkourtips", "parkour_tooltip_data", flowInfo)
  elseif dungeonType == E.DungeonType.Flux then
    setWorldEventDungeonsData("flux_revolt_tooltip", "flux_revolt_tooltip_data", flowInfo)
  elseif dungeonType == E.DungeonType.ThunderElemental then
    setWorldEventDungeonsData("thunder_elemental", "thunder_elemental_tooltip_data", flowInfo)
  end
end
local getTimerDataByVmAndData = function(vmName)
  local timerType = Z.ContainerMgr.DungeonSyncData.timerInfo.type
  if not vmName or timerType == E.DungeonTimerType.DungeonTimerTypeNull then
    return
  end
  local viewVm = Z.VMMgr.GetVM(vmName)
  if not viewVm then
    return
  end
  return viewVm.GetDungeonTimerData(timerType)
end
local initDungeonTimerData = function()
  local timerData
  local dungeonType = getCurrDungeonType()
  if dungeonType == E.DungeonType.Parkour then
    timerData = getTimerDataByVmAndData("parkourtips")
  elseif dungeonType == E.DungeonType.Flux then
    timerData = getTimerDataByVmAndData("flux_revolt_tooltip")
  elseif dungeonType == E.DungeonType.ThunderElemental then
    timerData = getTimerDataByVmAndData("thunder_elemental")
  elseif dungeonType == E.DungeonType.HeroChallengeDungeon or dungeonType == E.DungeonType.HeroNormalDungeon or dungeonType == E.DungeonType.HeroKeyDungeon then
    timerData = getTimerDataByVmAndData("hero_dungeon_main")
  elseif dungeonType == E.DungeonType.Union then
    timerData = getTimerDataByVmAndData("union")
  elseif dungeonType == E.DungeonType.MasterChallengeDungeon then
    timerData = getTimerDataByVmAndData("hero_dungeon_main")
  end
  return timerData
end
local updateDungeonTimerInfo = function(container, dirtyKeys)
  local dungeonTimerVm = Z.VMMgr.GetVM("dungeon_timer")
  dungeonTimerVm.SetDungeonHideTag(false)
  local timerInfo = Z.ContainerMgr.DungeonSyncData.timerInfo
  if not Z.StageMgr.GetIsInDungeon() or not timerInfo.startTime then
    return
  end
  local timerData = initDungeonTimerData()
  local dungeonTimerData = Z.DataMgr.Get("dungeon_timer_data")
  dungeonTimerVm.SetDungeonHideTag(true)
  dungeonTimerData:setDungeonTimerViewData(timerData)
  dungeonTimerVm.OpenDungeonTimerView()
end
local watcherDungeonFlowInfoChange = function()
  local flowInfo = Z.ContainerMgr.DungeonSyncData.flowInfo
  flowInfo.Watcher:RegWatcher(updateDungeonData)
end
local watcherDungeonTimerInfoChange = function()
  local timerInfo = Z.ContainerMgr.DungeonSyncData.timerInfo
  timerInfo.Watcher:RegWatcher(updateDungeonTimerInfo)
end
local onDungeonvoteChange = function(target, dirtyKeys)
  local votes = dirtyKeys.vote
  local vt = {}
  for key, value in pairs(votes) do
    vt[key] = value:Get()
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateVoteView, vt)
end
local watcherDungeonVoteChange = function()
  local vote = Z.ContainerMgr.DungeonSyncData.vote
  vote.Watcher:RegWatcher(onDungeonvoteChange)
end
local onDungeonherokeyChange = function(target, dirtyKeys)
  if table.zcount(target.keyInfo) > 0 then
    Z.UIMgr:OpenView("hero_dungeon_key")
  end
end
local watcherDungeonKeyInfoChange = function()
  local herokey = Z.ContainerMgr.DungeonSyncData.heroKey
  herokey.Watcher:RegWatcher(onDungeonherokeyChange)
end
local onDungeonWeekTargetChange = function(target, dirtyKeys)
  herodungeonRed.InitRed()
end
local watcherDungeonWeekTargetChange = function()
  herodungeonRed.InitRed()
  local weekTarget = Z.ContainerMgr.CharSerialize.dungeonList.weekTarget
  weekTarget.Watcher:RegWatcher(onDungeonWeekTargetChange)
end
local onDungeonEventDataChange = function(container, dirtyKeys)
  Z.EventMgr:Dispatch(Z.ConstValue.Dungeon.UpdateEvent)
end
local watcherDungeonEventChange = function()
  local target = Z.ContainerMgr.DungeonSyncData.dungeonEvent
  target.Watcher:RegWatcher(onDungeonEventDataChange)
end
local watcherDungeonDataChange = function()
  local dungeonTrackVm = Z.VMMgr.GetVM("dungeon_track")
  dungeonTrackVm.WatcherDungeonTargetChange()
  watcherDungeonEventChange()
  watcherDungeonFlowInfoChange()
  watcherDungeonTimerInfoChange()
  watcherDungeonVoteChange()
  watcherDungeonKeyInfoChange()
  watcherDungeonWeekTargetChange()
end
local onSyncAllContainerData = function()
  watcherDungeonDataChange()
  updateDungeonData(false)
  updateDungeonTimerInfo()
end
local getDungeonIsUnlock = function(dungeonId)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local dungeonList = dungeonData:GetDungeonList()
  for index, id in ipairs(dungeonList) do
    if dungeonId == id then
      return true
    end
  end
  return false
end
local getHerDungeonData = function(id)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local dungeonList = dungeonData:GetDungeonList()
  local dungeonId = dungeonList[id]
  if dungeonId == nil then
    return
  end
  local normalDungeonCfgData = Z.TableMgr.GetTable("NormalHeroDungeonTableMgr").GetRow(dungeonId)
  if normalDungeonCfgData == nil then
    return
  end
  return Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
end
local getDisplayNameOfType = function(playType)
  if playType == E.DungeonType.DungeonNormal then
    return Lang("DungeonNormal")
  elseif playType == E.DungeonType.DungeonLiner then
    return Lang("DungeonLiner")
  elseif playType == E.DungeonType.DungeonPlanetmemory then
    return Lang("DungeonPlanetmemory")
  else
    return Lang("DungeonUnknown")
  end
end
local getScoreLevelTab = function(dungeonId)
  local tab = {
    [1] = 0
  }
  local heroDungeonCfgData = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(dungeonId)
  if not heroDungeonCfgData then
    return tab
  end
  for index, value in ipairs(heroDungeonCfgData.ScoreRank) do
    local level = value[1]
    local score = value[2]
    tab[level] = score
  end
  return tab
end
local getNowLevelByScore = function(nowScore, scoreLeveltab)
  if nowScore == 0 then
    return 0
  end
  if not scoreLeveltab then
    return 0
  end
  local nowLevel = 1
  for level, score in pairs(scoreLeveltab) do
    if score <= nowScore then
      nowLevel = level
    end
  end
  return nowLevel
end
local getScoreIcon = function(index)
  local localLanguageIdx = Z.LocalizationMgr:GetCurrentLanguage()
  local path = ""
  if localLanguageIdx == E.Language.SimplifiedChinese then
    path = Z.ConstValue.Dungeon.ChineseScoreIconPathTable[index]
  else
    path = Z.ConstValue.Dungeon.OtherScoreIconPathTable[index]
  end
  return path
end
local AffixColor = {
  [1] = "#62b3ff",
  [2] = "#fd6c63",
  [3] = "#ffc26d"
}
local checkMonsterAndAffixTipShow = function()
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo then
    local roomId = planetRoomInfo.roomId
    if roomId and roomId ~= 0 then
      local trialroadRow = Z.TableMgr.GetTable("TrialRoadTableMgr").GetRow(roomId)
      if trialroadRow and trialroadRow.TargetMonster and next(trialroadRow.TargetMonster) then
        return true
      end
    end
  end
  local affixArray
  local dungeonId = Z.StageMgr.GetCurrentDungeonId()
  local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  if trialroadVM_.IsTrialRoad() then
    local dungeonsRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
    if dungeonsRow and dungeonsRow.Affix and next(dungeonsRow.Affix) then
      affixArray = dungeonsRow.Affix
    end
  elseif getCurrDungeonType() == E.DungeonType.WeeklyTower then
    local weelklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
    affixArray = weelklyHuntVm_.GetAffixByDungeonId(dungeonId)
  else
    affixArray = Z.DataMgr.Get("hero_dungeon_main_data"):GetAffixArray()
  end
  if affixArray then
    local mgr = Z.TableMgr.GetTable("AffixTableMgr")
    for _, affixId in pairs(affixArray) do
      local affCfgData = mgr.GetRow(affixId)
      if affCfgData and affCfgData.IsShowUI then
        return true
      end
    end
  end
  return false
end
local openMonsterAndAffixTip = function(trans, autoClose)
  local monsterTipsData = {}
  local planetRoomInfo = Z.ContainerMgr.DungeonSyncData.planetRoomInfo
  if planetRoomInfo then
    local roomId = planetRoomInfo.roomId
    if roomId and roomId ~= 0 then
      local trialroadRow = Z.TableMgr.GetTable("TrialRoadTableMgr").GetRow(roomId)
      if trialroadRow then
        for _, monsterId in pairs(trialroadRow.TargetMonster) do
          local data = {}
          data.monsterId = monsterId
          local monsterCfgData = Z.TableMgr.GetTable("MonsterTableMgr").GetRow(monsterId)
          if monsterCfgData then
            data.monsterName = monsterCfgData.Name
          end
          local modelCfg = Z.TableMgr.GetTable("ModelTableMgr").GetRow(monsterCfgData.ModelID)
          if modelCfg then
            data.monsterImgPath = modelCfg.Image
          end
          local param = {
            val = tostring(trialroadRow.GsLimit)
          }
          data.monsterGs = Lang("GSEqual", param)
          table.insert(monsterTipsData, data)
        end
      end
    end
  end
  local affixArray_
  local trialroadVM_ = Z.VMMgr.GetVM("trialroad")
  if trialroadVM_.IsTrialRoad() then
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    if dungeonId then
      local dungeonsRow = Z.TableMgr.GetTable("DungeonsTableMgr").GetRow(dungeonId)
      affixArray_ = dungeonsRow.Affix
    end
  elseif getCurrDungeonType() == E.DungeonType.WeeklyTower then
    local weelklyHuntVm_ = Z.VMMgr.GetVM("weekly_hunt")
    local dungeonId = Z.StageMgr.GetCurrentDungeonId()
    affixArray_ = weelklyHuntVm_.GetAffixByDungeonId(dungeonId)
  else
    affixArray_ = Z.DataMgr.Get("hero_dungeon_main_data"):GetAffixArray()
  end
  local affixDesList = {}
  local mgr = Z.TableMgr.GetTable("AffixTableMgr")
  for _, affixId in pairs(affixArray_) do
    local affCfgData = mgr.GetRow(affixId)
    if affCfgData and affCfgData.IsShowUI then
      local affixName = affCfgData.Name
      local des = affCfgData.Description
      local colorStr = AffixColor[affCfgData.EffectType]
      if colorStr then
        affixName = string.format("<color=%s>%s</color>", colorStr, affixName .. ":")
      end
      table.insert(affixDesList, affixName .. des)
    end
  end
  local extraParams = {}
  if trans then
    extraParams = {
      fixedPos = Vector3.New(trans.position.x + 1, trans.position.y - 0.3, trans.position.z),
      pivotX = 0,
      pivotY = 1
    }
  end
  local viewData = {}
  viewData.monsterList = monsterTipsData
  viewData.affixList = affixDesList
  viewData.extraParams = extraParams
  viewData.AutoClose = autoClose
  Z.UIMgr:OpenView("dungeon_monster_affix_tips", viewData)
end
local closeMonsterAndAffixTip = function()
  Z.UIMgr:CloseView("dungeon_monster_affix_tips")
end
local getDungeonValValue = function(valName)
  if Z.ContainerMgr.DungeonSyncData.dungeonVar.dungeonVarData then
    for k, v in ipairs(Z.ContainerMgr.DungeonSyncData.dungeonVar.dungeonVarData) do
      if v.name == valName then
        return v.value
      end
    end
  end
  return ""
end
local getDungeonPersonValValue = function(charid, valName)
  if Z.ContainerMgr.DungeonSyncData.dungeonVarAll.dungeonVarAllMap then
    local personDungenVar = Z.ContainerMgr.DungeonSyncData.dungeonVarAll.dungeonVarAllMap[charid]
    if personDungenVar == nil then
      logError("getDungeonPersonValValue: personDungenVar is nil, charid: " .. charid)
      return ""
    end
    for k, v in ipairs(personDungenVar.dungeonVarData) do
      if v.name == valName then
        return v.value
      end
    end
  end
  return ""
end
local hasScoreLevel = function(dungeonId)
  local tableCnt = 0
  local heroDungeonCfgData = Z.TableMgr.GetTable("SceneEventDuneonConfigTableMgr").GetRow(dungeonId)
  if not heroDungeonCfgData then
    return false
  end
  for _, _ in ipairs(heroDungeonCfgData.ScoreRank) do
    tableCnt = tableCnt + 1
  end
  return 0 < tableCnt
end
local getScoreProgress = function(nowScore, scoreLeveltab, curLevel)
  if nowScore == 0 then
    return 0
  end
  if not scoreLeveltab then
    return 0
  end
  local maxProgress = 0
  local curProgress = 0
  for level, score in pairs(scoreLeveltab) do
    if level == curLevel then
      curProgress = nowScore - score
      if scoreLeveltab[level + 1] then
        maxProgress = scoreLeveltab[level + 1] - score
      else
        return 0
      end
    end
  end
  if maxProgress == 0 then
    return 0
  end
  local progress = curProgress / maxProgress
  if progress < 0 then
    return 0
  end
  if 1 < progress then
    return 1
  end
  return progress
end
local getHeroDungeonGroup = function(groupId)
  local dungeonsList = Z.TableMgr.GetTable("ChallengeHeroDungeonTableMgr").GetDatas()
  local groupDict = {}
  for _, v in pairs(dungeonsList) do
    if v.DungeonGroup == groupId then
      groupDict[v.StarLevel] = v
    end
  end
  return groupDict
end
local ret = {
  AsyncGetSeasonDungeonList = asyncGetSeasonDungeonList,
  WatcherDungeonDataChange = watcherDungeonDataChange,
  GetHerDungeonData = getHerDungeonData,
  GetCurrDungeonType = getCurrDungeonType,
  GetDisplayNameOfType = getDisplayNameOfType,
  OnSyncAllContainerData = onSyncAllContainerData,
  GetRedPointID = getRedPointID,
  RefreshRedPointByAward = refreshRedPointByAward,
  InitDungeonRedpoint = initDungeonRedpoint,
  SetWorldEventDungeonHideTag = setWorldEventDungeonHideTag,
  UpdateDungeonData = updateDungeonData,
  GetScoreLevelTab = getScoreLevelTab,
  GetNowLevelByScore = getNowLevelByScore,
  UpdateDungeonTimerInfo = updateDungeonTimerInfo,
  GetDungeonType = getDungeonType,
  GetScoreIcon = getScoreIcon,
  OpenMonsterAndAffixTip = openMonsterAndAffixTip,
  CloseMonsterAndAffixTip = closeMonsterAndAffixTip,
  CheckMonsterAndAffixTipShow = checkMonsterAndAffixTipShow,
  GetDungeonValValue = getDungeonValValue,
  HasScoreLevel = hasScoreLevel,
  GetScoreProgress = getScoreProgress,
  GetHeroDungeonGroup = getHeroDungeonGroup,
  GetDungeonIsUnlock = getDungeonIsUnlock,
  GetDungeonPersonValValue = getDungeonPersonValValue
}
return ret
