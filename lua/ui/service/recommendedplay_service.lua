local super = require("ui.service.service_base")
local RecommendedPlayService = class("RecommendedPlayService", super)

function RecommendedPlayService:OnInit()
  self.recommendedPlayData_ = Z.DataMgr.Get("recommendedplay_data")
  self.recommendedPlayVM_ = Z.VMMgr.GetVM("recommendedplay")
  self.enterDungeonSceneVM_ = Z.VMMgr.GetVM("ui_enterdungeonscene")
  self.gotoFuncVM_ = Z.VMMgr.GetVM("gotofunc")
  self.heroChallengeRedCheckFuncId_ = {
    E.FunctionID.HeroChallengeDungeon,
    E.FunctionID.HeroChallengeJuTaYiJi,
    E.FunctionID.HeroChallengeJuLongZhuaHen,
    E.FunctionID.HeroChallengeKaNiMan
  }
  
  function self.onFuncDataChange_(functionTabs)
    local needRequestServerData = false
    for functionId, isUnlock in pairs(functionTabs) do
      if self.recommendedPlayData_:CheckFunctionOpenNeedRequestServerData(functionId) then
        if isUnlock then
          needRequestServerData = true
        else
          Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, functionId, false)
        end
      end
    end
    if needRequestServerData then
      Z.CoroUtil.create_coro_xpcall(function()
        self.recommendedPlayVM_.AsyncGetRecommendPlayData(self.recommendedPlayData_.CancelSource:CreateToken())
      end)()
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
  
  function self.onFuncCloseChange_(functionTabs)
    for _, functionId in pairs(functionTabs) do
      if self.recommendedPlayData_:CheckFunctionOpenNeedRequestServerData(functionId) then
        Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, functionId, false)
      end
    end
  end
  
  Z.EventMgr:Add(Z.ConstValue.UserCloseFunction, self.onFuncCloseChange_)
  Z.EventMgr:Add(Z.ConstValue.ServerCloseFunction, self.onFuncCloseChange_)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.FunctionRed, self.functionRed, self)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.DungeonRed, self.dungeonIdRed, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.CreateUnion, self.unionRedRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.unionRedRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Union.UnionSignRedRefresh, self.unionRedRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Recommendedplay.TreasureRedRefresh, self.treasureRedRefresh, self)
  Z.EventMgr:Add(Z.ConstValue.Hero.MasterScoreAward, self.masterScoreRedRefresh, self)
end

function RecommendedPlayService:OnUnInit()
  if self.onFuncDataChange_ ~= nil then
    Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange_)
    self.onFuncDataChange_ = nil
  end
  if self.onFuncCloseChange_ ~= nil then
    Z.EventMgr:Remove(Z.ConstValue.UserCloseFunction, self.onFuncCloseChange_)
    Z.EventMgr:Remove(Z.ConstValue.ServerCloseFunction, self.onFuncCloseChange_)
    self.onFuncCloseChange_ = nil
  end
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.FunctionRed, self.functionRed, self)
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.DungeonRed, self.dungeonIdRed, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.CreateUnion, self.unionRedRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.UnionActionEvt.UpdateUnionInfo, self.unionRedRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Union.UnionSignRedRefresh, self.unionRedRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Recommendedplay.TreasureRedRefresh, self.treasureRedRefresh, self)
  Z.EventMgr:Remove(Z.ConstValue.Hero.MasterScoreAward, self.masterScoreRedRefresh, self)
end

function RecommendedPlayService:OnLogin()
  function self.onContainerDataChange_(dirty)
    if dirty and dirty.dungeonTargetAward then
      self:checkHeroChallengeRedDot()
      
      self:refreshRedState()
    end
  end
  
  Z.ContainerMgr.CharSerialize.challengeDungeonInfo.Watcher:RegWatcher(self.onContainerDataChange_)
  
  function self.onQuestListChange_(dirty)
    if dirty and dirty.finishQuest then
      self:checkQuestRed()
      self:refreshRedState()
    end
  end
  
  Z.ContainerMgr.CharSerialize.questList.Watcher:RegWatcher(self.onQuestListChange_)
end

function RecommendedPlayService:OnLogout()
  Z.ContainerMgr.CharSerialize.challengeDungeonInfo.Watcher:UnregWatcher(self.onContainerDataChange_)
  Z.ContainerMgr.CharSerialize.questList.Watcher:UnregWatcher(self.onQuestListChange_)
  self.recommendedPlayData_.TimerMgr:Clear()
end

function RecommendedPlayService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self.recommendedPlayData_:InitLocalSave()
    if self.gotoFuncVM_.CheckFuncCanUse(E.FunctionID.SeasonActivity, true) then
      Z.CoroUtil.create_coro_xpcall(function()
        self.recommendedPlayVM_.AsyncGetRecommendPlayData(self.recommendedPlayData_.CancelSource:CreateToken())
      end)()
    end
    self:checkRedDot()
  end
end

function RecommendedPlayService:checkRedDot()
  Z.CoroUtil.create_coro_xpcall(function()
    local config1 = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.EntranceDiNa)
    if config1 then
      self:asynRefreshPioneerInfoRed(config1)
    end
    local config2 = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.EntranceJuTaYiJi)
    if config2 then
      self:asynRefreshPioneerInfoRed(config2)
    end
    self:checkHeroChallengeRedDot()
    self:checkQuestRed()
    self:treasureRedRefresh()
    self:masterScoreRedRefresh()
    self:refreshRedState()
  end)()
end

function RecommendedPlayService:refreshRedState()
  local redDots = false
  for _, seconds in pairs(self.recommendedPlayData_.AllRedDots) do
    for _, thirds in pairs(seconds) do
      if thirds.isRed then
        redDots = true
        break
      else
        for _, isRed in pairs(thirds.childRed) do
          if isRed then
            redDots = true
            break
          end
        end
      end
    end
  end
  if redDots then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.RecommendedPlayRed, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.RecommendedPlayRed, 0)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.ViewRedRefresh)
end

function RecommendedPlayService:setRedDotByConfig(config, isRed)
  if config == nil then
    return
  end
  local type = config.Type[1]
  if config.ParentId and #config.ParentId > 0 then
    for i, parentId in ipairs(config.ParentId) do
      if self.recommendedPlayData_.AllRedDots[type] == nil then
        self.recommendedPlayData_.AllRedDots[type] = {}
      end
      if self.recommendedPlayData_.AllRedDots[type][parentId] == nil then
        self.recommendedPlayData_.AllRedDots[type][parentId] = {}
      end
      self.recommendedPlayData_.AllRedDots[type][parentId].isRed = isRed
      if self.recommendedPlayData_.AllRedDots[type][parentId].childRed == nil then
        self.recommendedPlayData_.AllRedDots[type][parentId].childRed = {}
      end
      self.recommendedPlayData_.AllRedDots[type][parentId].childRed[config.Id] = isRed
    end
  else
    if self.recommendedPlayData_.AllRedDots[type] == nil then
      self.recommendedPlayData_.AllRedDots[type] = {}
    end
    if self.recommendedPlayData_.AllRedDots[type][config.Id] == nil then
      self.recommendedPlayData_.AllRedDots[type][config.Id] = {}
    end
    self.recommendedPlayData_.AllRedDots[type][config.Id].isRed = isRed
    if self.recommendedPlayData_.AllRedDots[type][config.Id].childRed == nil then
      self.recommendedPlayData_.AllRedDots[type][config.Id].childRed = {}
    end
  end
end

function RecommendedPlayService:asynRefreshPioneerInfoRed(config)
  self.enterDungeonSceneVM_.AsyncGetPioneerInfo(config.RelatedDungeonId)
  local dungeonData = Z.DataMgr.Get("dungeon_data")
  local pioneerInfo = dungeonData.PioneerInfos[config.RelatedDungeonId]
  local cfgData = dungeonData:GetChestIntroductionById(config.RelatedDungeonId)
  for index, data in ipairs(cfgData) do
    local chestStateTpe = E.ChestStateTpe.NotOpen
    if pioneerInfo.progress >= data.preValue then
      chestStateTpe = E.ChestStateTpe.CanOpen
    end
    if pioneerInfo.awards[data.rewardId] then
      chestStateTpe = E.ChestStateTpe.AlreadyOpen
    end
    if chestStateTpe == E.ChestStateTpe.CanOpen then
      self:setRedDotByConfig(config, true)
      return
    end
  end
  self:setRedDotByConfig(config, false)
end

function RecommendedPlayService:functionRed(functionId, isRed)
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(functionId)
  if config then
    self:setRedDotByConfig(config, isRed)
    self:refreshRedState()
  end
end

function RecommendedPlayService:dungeonIdRed(dungeonId, isRed)
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByDungeonId(dungeonId)
  self:setRedDotByConfig(config, isRed)
  self:refreshRedState()
end

function RecommendedPlayService:checkQuestRed()
  local questVM = Z.VMMgr.GetVM("quest")
  local configs = self.recommendedPlayData_:GetRecommendedPlayConfigByQuest()
  for _, config in pairs(configs) do
    local unionData_ = Z.DataMgr.Get("union_data")
    local signChecked = unionData_:SignRecommendRedChecked()
    if signChecked then
      self:setRedDotByConfig(config, false)
      return
    end
    local isFinish = questVM.IsQuestFinish(config.RelatedQuest)
    if isFinish then
      self:setRedDotByConfig(config, false)
    else
      local red = true
      if config.FunctionId == E.FunctionID.UnionDailySign then
        local unionVm = Z.VMMgr.GetVM("union")
        local unlock, _, _ = unionVm:GetUnionSceneIsUnlock()
        red = unionVm:GetPlayerUnionId() ~= 0 and unlock
      end
      self:setRedDotByConfig(config, red)
    end
  end
end

function RecommendedPlayService:checkHeroChallengeRedDot()
  for _, functionid in ipairs(self.heroChallengeRedCheckFuncId_) do
    local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(functionid)
    if config then
      local red = self:checkHeroChallengeWeekRed(config.RelatedDungeonId)
      self:setRedDotByConfig(config, red)
    end
  end
end

function RecommendedPlayService:checkHeroChallengeWeekRed(dungeonId)
  local showRed = false
  local targetList, groupId = Z.VMMgr.GetVM("hero_dungeon_main").GetChallengeHeroDungeonTarget(dungeonId)
  local dungeonInfo = Z.ContainerMgr.CharSerialize.challengeDungeonInfo.dungeonTargetAward[groupId]
  for k, v in ipairs(targetList) do
    if dungeonInfo and dungeonInfo.dungeonTargetProgress[v.targetId] and dungeonInfo.dungeonTargetProgress[v.targetId].awardState == E.DrawState.CanDraw then
      showRed = true
      break
    end
  end
  return showRed
end

function RecommendedPlayService:unionRedRefresh()
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.UnionDailySign)
  local unionVm = Z.VMMgr.GetVM("union")
  local questVM = Z.VMMgr.GetVM("quest")
  if config then
    local unionData_ = Z.DataMgr.Get("union_data")
    local signChecked = unionData_:SignRecommendRedChecked()
    if signChecked then
      self:setRedDotByConfig(config, false)
      self:refreshRedState()
      return
    end
    local isFinish = questVM.IsQuestFinish(config.RelatedQuest)
    if isFinish then
      self:setRedDotByConfig(config, false)
    else
      local unlock, _, _ = unionVm:GetUnionSceneIsUnlock()
      local red = unionVm:GetPlayerUnionId() ~= 0 and unlock
      self:setRedDotByConfig(config, red)
    end
    self:refreshRedState()
  end
end

function RecommendedPlayService:treasureRedRefresh()
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.ExtremeSpace)
  self:setRedDotByConfig(config, Z.RedPointMgr.GetRedState(E.RedType.Treasure))
  self:refreshRedState()
end

function RecommendedPlayService:masterScoreRedRefresh()
  local config = self.recommendedPlayData_:GetRecommendedPlayConfigByFunctionId(E.FunctionID.ExtremeSpace)
  self:setRedDotByConfig(config, Z.RedPointMgr.GetRedState(E.RedType.MasterScore))
  self:refreshRedState()
end

return RecommendedPlayService
