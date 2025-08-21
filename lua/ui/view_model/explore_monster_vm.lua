local MonsterHuntListTableMgr_ = Z.TableMgr.GetTable("MonsterHuntListTableMgr")
local monsterTableMgr_ = Z.TableMgr.GetTable("MonsterTableMgr")
local monsterExploreTargetTableMgr_ = Z.TableMgr.GetTable("MonsterHuntTargetTableMgr")
local monsterHuntLevelTableMgr_ = Z.TableMgr.GetTable("MonsterHuntLevelTableMgr")
local proxy = require("zproxy.world_proxy")
local exploreMonsterRed = require("rednode.explore_monster_red")
E.MonsterHuntTargetAwardState = {
  Null = 0,
  Get = 1,
  Receive = 2
}
local checkExploreMonsterShow = function(sceneId)
  local dataMgr_ = Z.DataMgr.Get("explore_monster_data")
  for _, cfg in pairs(dataMgr_.MonsterHuntListTableDatas) do
    if cfg.Scene == sceneId then
      return true
    end
  end
  return false
end
local getExploreMonsterList = function(sceneId)
  local data = {}
  sceneId = sceneId or Z.VMMgr.GetVM("map").GetMapShowSceneId()
  local dataMgr_ = Z.DataMgr.Get("explore_monster_data")
  for _, cfg in pairs(dataMgr_.MonsterHuntListTableDatas) do
    if cfg.Scene == sceneId then
      data[#data + 1] = cfg
    end
  end
  table.sort(data, function(a, b)
    return a.Sort < b.Sort
  end)
  return data
end
local getExploreMonsterListByFilter = function(sceneId, rank, monsterName)
  local data = {}
  local filterCount_ = 0
  if sceneId then
    for _, _ in pairs(sceneId) do
      filterCount_ = filterCount_ + 1
    end
  end
  local rankFilter_ = 0 < rank
  local needFilterName_ = 0 < string.len(monsterName)
  local result_
  local dataMgr_ = Z.DataMgr.Get("explore_monster_data")
  for _, cfg in pairs(dataMgr_.MonsterHuntListTableDatas) do
    local sceneFilter_ = true
    if 0 < filterCount_ then
      sceneFilter_ = sceneId[cfg.Scene] ~= nil
    end
    local rank_ = true
    if rankFilter_ then
      rank_ = rank == cfg.Type
    end
    local monsterData_ = monsterTableMgr_.GetRow(cfg.MonsterId)
    result_ = {}
    result_.ExploreData = cfg
    result_.MonsterData = monsterData_
    if sceneFilter_ and rank_ then
      if needFilterName_ == true then
        local tableName_ = monsterData_.Name
        if string.match(tableName_, monsterName) then
          data[#data + 1] = result_
        end
      else
        data[#data + 1] = result_
      end
    end
  end
  table.sort(data, function(a, b)
    return a.ExploreData.Sort < b.ExploreData.Sort
  end)
  return data
end
local getMonsterCameraTarget = function()
  local cameraTarget = {}
  local curSceneId = Z.StageMgr.GetCurrentSceneId()
  local monsterList = getExploreMonsterListByFilter({}, 0, "")
  for _, v in ipairs(monsterList) do
    local vm = Z.VMMgr.GetVM("explore_monster")
    local data = vm.GetExploreMonsterTargetInfoList(v.MonsterData.Id)
    for index, t in pairs(v.ExploreData.Target) do
      local curData = data and data[index] or nil
      local targetcfg = Z.TableMgr.GetTable("MonsterHuntTargetTableMgr").GetRow(t[2])
      local isFinish = false
      if curData and targetcfg then
        isFinish = curData.targetNum > targetcfg.Num
      end
      if targetcfg and targetcfg.TargetType == E.GoalType.TargetPhotoByTableId and targetcfg.SceneId == curSceneId and not isFinish then
        local entityType = targetcfg.Param[1]
        local configId = targetcfg.Param[2]
        table.insert(cameraTarget, {
          monsterId = v.MonsterData.Id,
          targetId = t[2],
          entityType = entityType,
          configId = configId
        })
      end
    end
  end
  local tb = {}
  for _, value in ipairs(cameraTarget) do
    if value then
      local key = value.monsterId .. "_" .. value.targetId
      tb[key] = {}
      tb[key].data = value
      tb[key].func = function()
        local goalVm = Z.VMMgr.GetVM("goal")
        goalVm.SetGoalFinish(E.GoalType.TargetPhotoByTableId, value.entityType, value.configId)
        Z.TipsVM.ShowTipsLang(140101)
      end
    end
  end
  return tb
end
local getInsightFlagReal = function()
  return Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrInsightFlag")).Value == 1
end
local getMonsterLevel = function(monsterRow)
  local r_ = 0
  local attrId_ = monsterRow.AttributeId
  local entityAttributeTable_ = Z.TableMgr.GetTable("EntityAttributeTableMgr")
  local row_ = entityAttributeTable_.GetRow(attrId_)
  if row_ then
    r_ = row_.Level
  end
  return r_
end
local getExploreMonsterDataById = function(Id)
  return Z.ContainerMgr.CharSerialize.monsterHuntInfo.monsterHuntList[Id]
end
local getExploreMonsterTargetInfoList = function(Id)
  local result_
  local info_ = getExploreMonsterDataById(Id)
  if info_ ~= nil then
    result_ = info_.targetInfoList
  end
  return result_
end
local checkTargetList = function(targetList)
  local getAwardNum_ = 0
  for _, value in pairs(targetList) do
    local info_ = value
    if info_.awardFlag == E.MonsterHuntTargetAwardState.Receive then
      getAwardNum_ = getAwardNum_ + 1
    end
  end
  return getAwardNum_
end
local getExploreMonsterTargetFinishNumById = function(Id)
  local info_ = getExploreMonsterTargetInfoList(Id)
  local result_ = 0
  if info_ then
    result_ = checkTargetList(info_)
  end
  return result_
end
local initMarkMonsterData = function()
  local datas = Z.ContainerMgr.CharSerialize.monsterExploreList.monsterExploreList
  local cfgs = MonsterHuntListTableMgr_
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  local markFlag = false
  for key, data in pairs(datas) do
    if data.isFlag then
      local cfg = cfgs.GetRow(key)
      if cfg then
        dataMgr:SetMark(cfg.Scene, key)
        markFlag = true
      end
    end
  end
  if markFlag then
    dataMgr:SetExploreTimeStamp(Z.TimeTools.Now() - dataMgr:GetExploreIntervalTime())
  end
end
local monsterExploreUnlock = function(Id, callback, cancelToken)
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  local proxy = require("zproxy.world_proxy")
  local ret = proxy.MonsterExploreUnlock({
    objectId = dataMgr:GetMonsterUUid(Id)
  }, cancelToken)
  if 0 < ret then
  end
  dataMgr:SetCheckInsightId(Id, nil)
end
local getMonsterHuntLevel = function()
  local level_ = Z.ContainerMgr.CharSerialize.monsterHuntInfo.curLevel
  return level_
end
local getMonsterHuntLevelExp = function()
  local exp_ = Z.ContainerMgr.CharSerialize.monsterHuntInfo.curExp
  return exp_
end
local getHuntLevelAwardReceiveState = function()
  return Z.ContainerMgr.CharSerialize.monsterHuntInfo
end
local getMonsterHuntMaxLevel = function()
  local data = monsterHuntLevelTableMgr_.GetDatas()
  return table.zcount(data)
end
local getMonsterHuntLevelMaxExp = function(curLevel)
  local maxExp_ = 1
  local levelData_ = monsterHuntLevelTableMgr_.GetRow(curLevel)
  if levelData_ ~= nil then
    maxExp_ = levelData_.LevelUpExp
  end
  return maxExp_
end
local getAllMonsterHuntLevelData = function()
  local r_ = {}
  local dataMgr_ = Z.DataMgr.Get("explore_monster_data")
  for _, value in ipairs(dataMgr_.MonsterHuntLevelTableDatas) do
    if value.Level > 1 then
      r_[#r_ + 1] = value
    end
  end
  return r_
end
local openExploreMonsterWindow = function(sceneId, pageType, monsterId)
  if sceneId ~= nil and type(sceneId) == "string" then
    sceneId = tonumber(sceneId)
  end
  if pageType ~= nil and type(pageType) == "string" then
    pageType = tonumber(pageType)
  end
  if monsterId ~= nil and type(monsterId) == "string" then
    monsterId = tonumber(monsterId)
  end
  local viewData = {
    sceneId = sceneId or 0,
    pageType = pageType,
    monsterId = monsterId
  }
  Z.UnrealSceneMgr:OpenUnrealScene(Z.DataMgr.Get("explore_monster_data"):GetUnrealScene(), "explore_monster_window", function()
    Z.UIMgr:OpenView("explore_monster_window", viewData)
  end)
end
local jumpExploreMonsterWindow = function(monsterId)
  local monsterHuntListTableRow = Z.TableMgr.GetTable("MonsterHuntListTableMgr").GetRow(monsterId, true)
  local sceneId, pageType
  if monsterHuntListTableRow then
    sceneId = monsterHuntListTableRow.Scene
    pageType = monsterHuntListTableRow.Type
  end
  openExploreMonsterWindow(sceneId, pageType, monsterId)
end
local closeExploreMonsterWindow = function()
  Z.UIMgr:CloseView("explore_monster_window")
end
local openExploreMonsterGradeWindow = function()
  Z.UIMgr:OpenView("explore_monster_grade_popup")
end
local closeExploreMonsterGradeWindow = function()
  Z.UIMgr:CloseView("explore_monster_grade_popup")
end
local openExploreMonsterLevelUpWindow = function()
  Z.UIMgr:OpenView("explore_monster_level_popup")
end
local closeExploreMonsterLevelUpWindow = function()
  Z.UIMgr:CloseView("explore_monster_level_popup")
end
local openExploreMonsterDepleteWindow = function(viewData)
  Z.UIMgr:OpenView("explore_monster_deplete_popup", viewData)
end
local closeExploreMonsterDepleteWindow = function()
  Z.UIMgr:CloseView("explore_monster_deplete_popup")
end
local updateExploreMonsterRedpoint = function()
  local list = Z.ContainerMgr.CharSerialize.monsterExploreList.monsterExploreList
  local cfgs = MonsterHuntListTableMgr_
  local exploreCfgs = monsterExploreTargetTableMgr_
  local isDone = true
  local targetId = 0
  local count = 0
  for id, info in pairs(list) do
    if info.isUnlock and info.awardFlag == 0 then
      local cfg = cfgs.GetRow(id)
      if cfg then
        targetId = 0
        isDone = true
        for i = 1, #cfg.Target do
          targetId = cfg.Target[i][2]
          local exploreCfg = exploreCfgs.GetRow(targetId)
          if exploreCfg and (not info.targetNum[targetId] or info.targetNum[targetId] < exploreCfg.Num) then
            isDone = false
            break
          end
        end
        if isDone then
          count = count + 1
        end
      end
    end
  end
  if 0 < count then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.MonsterExplore, count)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.MonsterExplore, count, true)
  end
end
local getTabRedDotId = function(tabId)
  local id = exploreMonsterRed.GetTabRedDotID(tabId)
  return id
end
local initExploreMonster = function()
  initMarkMonsterData()
  updateExploreMonsterRedpoint()
end
local checkMonsterIsMark = function(sceneId, monsterId)
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  return dataMgr:GetMarkByID(sceneId, monsterId)
end
local trackMonster = function(Id, sceneId, callback, cancelToken)
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  dataMgr:SetMark(sceneId, Id)
end
local cancelTrackMonster = function(Id, sceneId, callback, cancelToken)
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  dataMgr:CancelMark(sceneId, Id)
end
local checkInsightStates = function(dataMgr)
  if not getInsightFlagReal() then
    if not dataMgr:GetInsightFlag() then
      return
    else
      dataMgr:SetInsightFlag(false)
      local showTargets = dataMgr:GetTargetShowContent()
      if showTargets and table.zcount(showTargets) > 0 then
        dataMgr:ClearTargetShowContent()
        Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target)
      end
      local showArrows = dataMgr:GetExploreArrowContent()
      if showArrows and table.zcount(showArrows) > 0 then
        dataMgr:ClearExploreArrowContent()
        Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
      end
    end
    return false
  end
  return true
end
local checkExploreTargets = function(dataMgr)
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local targets = dataMgr:GetMarkByScene(sceneId)
  if not targets or table.zcount(targets) <= 0 then
    local showTargets = dataMgr:GetTargetShowContent()
    if showTargets and table.zcount(showTargets) > 0 then
      dataMgr:ClearTargetShowContent()
      Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target)
    end
    local showArrows = dataMgr:GetExploreArrowContent()
    if showArrows and table.zcount(showArrows) > 0 then
      dataMgr:ClearExploreArrowContent()
      Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
    end
    return false
  end
  return true
end
local checkTargetInRangeById = function(id, dataMgr, playerEnt)
  if not playerEnt then
    logError("checkTargetInRangeById playerEnt is nil")
    return false
  end
  local uuid = dataMgr:GetMonsterUUid(id)
  if not uuid or uuid <= 0 then
    return false
  end
  local entity = Z.EntityMgr:GetEntity(uuid)
  if not entity then
    dataMgr:SetMonsterUUid(id, 0)
    dataMgr:SetExploreTimeStamp(Z.TimeTools.Now())
    return false
  end
  local state = entity:GetLuaAttrState()
  if state == Z.PbEnum("EActorState", "ActorStateDead") then
    return false
  end
  local distance = Z.World:CalculateDistanceSquareByEntity(playerEnt, entity)
  dataMgr:SetMonsterDis(id, distance)
  if distance <= dataMgr:GetExploreDis() then
    return true
  end
  return false
end
local checkTargetInRange = function(dataMgr)
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local targets = dataMgr:GetMarkByScene(sceneId)
  local tab
  local playerEnt = Z.EntityMgr.PlayerEnt
  for id, _ in pairs(targets) do
    if checkTargetInRangeById(id, dataMgr, playerEnt) then
      tab = tab or {}
      tab[#tab + 1] = id
    end
  end
  if not tab then
    local showTargets = dataMgr:GetTargetShowContent()
    if showTargets and table.zcount(showTargets) > 0 then
      dataMgr:ClearTargetShowContent()
      Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target, true)
    end
    local showArrows = dataMgr:GetExploreArrowContent()
    if showArrows and table.zcount(showArrows) > 0 then
      dataMgr:ClearExploreArrowContent()
      Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
    end
  end
  return tab
end
local checkTargetInInsightRangeById = function(id, dataMgr, playerEnt)
  local isUnlock_ = 0 < getExploreMonsterTargetFinishNumById(id)
  if isUnlock_ then
    dataMgr = dataMgr or Z.DataMgr.Get("explore_monster_data")
    playerEnt = playerEnt or Z.EntityMgr.PlayerEnt
    local uuid = dataMgr:GetMonsterUUid(id)
    if uuid and 0 < uuid then
      local entity = Z.EntityMgr:GetEntity(uuid)
      if not entity then
        dataMgr:SetMonsterUUid(id, 0)
        dataMgr:SetExploreTimeStamp(Z.TimeTools.Now())
        return false
      end
      local distance = Z.World:CalculateDistanceSquareByEntity(playerEnt, entity)
      dataMgr:SetMonsterDis(id, distance)
      if distance <= dataMgr:GetExploreInsightDis() then
        return true
      end
    end
  end
  return false
end
local getTargetShowContentById = function(id)
  local data = getExploreMonsterTargetInfoList(id)
  if not data then
    return nil
  end
  local cfg = MonsterHuntListTableMgr_.GetRow(id)
  local tab = {}
  local exploreCfgs = monsterExploreTargetTableMgr_
  if cfg then
    local targetId
    for i = 1, #cfg.Target do
      targetId = cfg.Target[i][2]
      local exploreCfg = exploreCfgs.GetRow(targetId)
      if exploreCfg then
        local targetNum_ = 0
        local d_ = data[targetId]
        if d_ then
          targetNum_ = d_.value.targetNum
        end
        if targetNum_ < exploreCfg.Num then
          if cfg.Target[i][3] == 0 then
            tab[#tab + 1] = i
          else
            targetId = cfg.Target[cfg.Target[i][3]][2]
            local exploreCfg = exploreCfgs.GetRow(targetId)
            if exploreCfg and targetNum_ >= exploreCfg.Num then
              tab[#tab + 1] = i
            end
          end
        end
      end
    end
  end
  return tab
end
local checkTargetWithoutContent = function(dataMgr, tab)
  local content = dataMgr:GetTargetShowContent()
  local arrowContent = dataMgr:GetExploreArrowContent()
  local playerEnt = Z.EntityMgr.PlayerEnt
  local updateTarget = false
  local updateArrow = false
  local targetInRange = {}
  for _, id in ipairs(tab) do
    if checkTargetInRangeById(id, dataMgr, playerEnt) then
      table.insert(targetInRange, id)
      local isUnlock_ = 0 < getExploreMonsterTargetFinishNumById(id)
      if not content or not content[id] then
        if isUnlock_ then
          local tab2 = getTargetShowContentById(id)
          for _, index in ipairs(tab2) do
            dataMgr:SetTargetShowContent(id, index)
          end
        else
          dataMgr:SetTargetShowContent(id, 0)
        end
        updateTarget = true
      elseif content and content[id] and content[id][1] and content[id][1] == 0 and data and data.isUnlock then
        local tab2 = getTargetShowContentById(id)
        dataMgr:ClearTargetShowContentById(id)
        for _, index in ipairs(tab2) do
          dataMgr:SetTargetShowContent(id, index)
        end
        updateTarget = true
      end
      if not arrowContent or not arrowContent[id] then
        updateArrow = true
        dataMgr:SetExploreArrowContent(id)
      end
    end
  end
  if updateTarget then
    for _, id in ipairs(targetInRange) do
      local uuid = dataMgr:GetMonsterUUid(id)
      local dataList = {}
      if uuid and 0 < uuid then
        local entity = Z.EntityMgr:GetEntity(uuid)
        if entity then
          local info = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.MonsterExplore, Z.StageMgr.GetCurrentSceneId(), entity.EntId, Z.GoalPosType.Monster)
          table.insert(dataList, info)
        end
      end
      local guideVM = Z.VMMgr.GetVM("goal_guide")
      guideVM.SetGuideGoals(E.GoalGuideSource.MonsterExplore, dataList)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target)
  end
  if updateArrow then
    Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
  end
end
local checkTargetInContent = function(dataMgr)
  local content = dataMgr:GetTargetShowContent()
  local arrowContent = dataMgr:GetExploreArrowContent()
  local playerEnt = Z.EntityMgr.PlayerEnt
  local updateTarget = false
  local updateArrow = false
  for id, _ in pairs(content) do
    if not checkTargetInRangeById(id, dataMgr, playerEnt) then
      dataMgr:ClearTargetShowContentById(id)
      updateTarget = true
    elseif not dataMgr:GetCheckInsightById(id) then
      local isUnlock_ = 0 < getExploreMonsterTargetFinishNumById(id)
      if isUnlock_ and checkTargetInInsightRangeById(id, dataMgr, playerEnt) then
        dataMgr:SetCheckInsightId(id, true)
        Z.CoroUtil.create_coro_xpcall(function()
          monsterExploreUnlock(id, nil, dataMgr:GetCancelToken())
        end)()
      end
    end
  end
  for id, _ in pairs(arrowContent) do
    if not checkTargetInRangeById(id, dataMgr, playerEnt) then
      dataMgr:ClearExploreArrowContnetById(id)
      updateArrow = true
    end
  end
  if updateTarget then
    Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target, true)
  end
  if updateArrow then
    Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
  end
end
local checkTargetMarkStates = function(dataMgr, tab)
  checkTargetWithoutContent(dataMgr, tab)
  checkTargetInContent(dataMgr)
end
local checkMonsterRefreshTimer = function(dataMgr)
  local t = dataMgr:GetExploreTimeStamp()
  if 0 < t and Z.TimeTools.Now() - t >= dataMgr:GetExploreIntervalTime() then
    local all = true
    local tab = dataMgr:GetMarkByScene(Z.StageMgr.GetCurrentSceneId())
    for id, _ in pairs(tab) do
      if dataMgr:GetMonsterUUid(id) == 0 then
        local entity = Z.EntityMgr:GetEntityByConfigId(Z.PbEnum("EEntityType", "EntMonster"), id)
        if entity then
          dataMgr:SetMonsterUUid(id, entity.Uuid)
        else
          all = false
        end
      end
    end
    if all then
      dataMgr:SetExploreTimeStamp(0)
    else
      dataMgr:SetExploreTimeStamp(Z.TimeTools.Now())
    end
  end
end
local checkExploreMonsterTimerCall = function()
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  local state
  if Z.EntityMgr.PlayerEnt then
    state = Z.EntityMgr.PlayerEnt:GetLuaAttrState()
  end
  if state and state.Value and state.Value == Z.PbEnum("EActorState", "ActorStateDead") then
    dataMgr:ClearTargetShowContent()
    dataMgr:ClearExploreArrowContent()
  end
  if not checkExploreTargets(dataMgr) then
    return
  end
  checkMonsterRefreshTimer(dataMgr)
  local tab = checkTargetInRange(dataMgr)
  if not tab then
    return
  end
  checkTargetMarkStates(dataMgr, tab)
end
local getExploreMonsterAward = function(Id, callback, cancelToken)
  local ret = proxy.GetAward({monsterId = Id}, cancelToken)
  if 0 < ret then
  end
  if callback then
    callback(ret == 0)
  end
end
local getHuntLevelAward = function(Id, callback, cancelToken)
  local param_ = {level = Id}
  local ret = proxy.GetMonsterHuntLevelAward(param_, cancelToken)
  if 0 < ret then
  end
  if callback then
    callback(ret == 0)
  end
end
local getHuntTargetAward = function(Id, targetTableId, callback, cancelToken)
  local param_ = {monsterId = Id, stageId = targetTableId}
  local ret = proxy.GetMonsterAward(param_, cancelToken)
  if 0 < ret then
  end
  if callback then
    callback(ret == 0)
  end
end
local ret = {
  JumpExploreMonsterWindow = jumpExploreMonsterWindow,
  CheckExploreMonsterShow = checkExploreMonsterShow,
  TrackMonster = trackMonster,
  CancelTrackMonster = cancelTrackMonster,
  InitExploreMonster = initExploreMonster,
  OpenExploreMonsterWindow = openExploreMonsterWindow,
  CloseExploreMonsterWindow = closeExploreMonsterWindow,
  GetExploreMonsterList = getExploreMonsterList,
  GetExploreMonsterDataById = getExploreMonsterDataById,
  GetExploreMonsterAward = getExploreMonsterAward,
  CheckExploreMonsterTimerCall = checkExploreMonsterTimerCall,
  GetTargetShowContentById = getTargetShowContentById,
  GetExploreMonsterListByFilter = getExploreMonsterListByFilter,
  GetHuntLevelAward = getHuntLevelAward,
  GetHuntTargetAward = getHuntTargetAward,
  OpenExploreMonsterGradeWindow = openExploreMonsterGradeWindow,
  CloseExploreMonsterGradeWindow = closeExploreMonsterGradeWindow,
  GetExploreMonsterTargetFinishNumById = getExploreMonsterTargetFinishNumById,
  GetExploreMonsterTargetInfoList = getExploreMonsterTargetInfoList,
  CheckTargetList = checkTargetList,
  GetMonsterHuntLevel = getMonsterHuntLevel,
  GetMonsterHuntLevelExp = getMonsterHuntLevelExp,
  GetMonsterHuntLevelMaxExp = getMonsterHuntLevelMaxExp,
  GetMonsterHuntMaxLevel = getMonsterHuntMaxLevel,
  GetAllMonsterHuntLevelData = getAllMonsterHuntLevelData,
  GetHuntLevelAwardReceiveState = getHuntLevelAwardReceiveState,
  OpenExploreMonsterDepleteWindow = openExploreMonsterDepleteWindow,
  CloseExploreMonsterDepleteWindow = closeExploreMonsterDepleteWindow,
  GetMonsterLevel = getMonsterLevel,
  MonsterExploreUnlock = monsterExploreUnlock,
  CheckMonsterIsMark = checkMonsterIsMark,
  OpenExploreMonsterLevelUpWindow = openExploreMonsterLevelUpWindow,
  CloseExploreMonsterLevelUpWindow = closeExploreMonsterLevelUpWindow,
  GetTabRedDotId = getTabRedDotId,
  GetMonsterCameraTarget = getMonsterCameraTarget,
  UpdateExploreMonsterRedpoint = updateExploreMonsterRedpoint
}
return ret
