local super = require("ui.service.service_base")
local SeasonService = class("SeasonService", super)

function SeasonService:OnInit()
end

function SeasonService:OnUnInit()
end

function SeasonService:OnLogin()
  function self.onSeasonAchievementChange_(container, dirtyKeys)
    local SeasonAchievementVm = Z.VMMgr.GetVM("season_achievement")
    
    local SeasonAchievementData = Z.DataMgr.Get("season_achievement_data")
    local totalCount = 0
    local achievements = SeasonAchievementData:GetAchievementConfigDatas()
    for _, achievement in pairs(achievements) do
      if achievement.SeasonId == SeasonAchievementData.season_ then
        local detail = SeasonAchievementVm.GetAchievementDetail(achievement.Id)
        if detail.state == 1 then
          if not SeasonAchievementData.achievementFinishState_[achievement.Id] then
            SeasonAchievementData.achievementFinishState_[achievement.Id] = true
            Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FinishSeasonAchievement, "season_achievement_finish_popup", achievement.Name)
          end
          totalCount = totalCount + 1
        end
      end
    end
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonAchievement, totalCount)
    Z.EventMgr:Dispatch(Z.ConstValue.SeasonAchievement.OnAchievementDataChange)
    local seasonTitleVM = Z.VMMgr.GetVM("season_title")
    local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
  end
  
  function self.onSeasonTitleChange_(container, dirtyKeys)
    local seasonTitleVM = Z.VMMgr.GetVM("season_title")
    local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
  end
  
  function self.onSeasonActivationChange_(container, dirtyKeys)
    self:RefreshSeasonActivation()
  end
  
  if self.seasonCultivateRed_ == nil then
    self.seasonCultivateRed_ = require("rednode.season_cultivate_red")
  end
  self.seasonCultivateRed_.Init()
  Z.ContainerMgr.CharSerialize.seasonAchievementList.Watcher:RegWatcher(self.onSeasonAchievementChange_)
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:RegWatcher(self.onSeasonTitleChange_)
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:RegWatcher(self.onSeasonActivationChange_)
end

function SeasonService:OnLogout()
  if self.seasonCultivateRed_ then
    self.seasonCultivateRed_.UnInit()
  end
  Z.ContainerMgr.CharSerialize.seasonAchievementList.Watcher:UnregWatcher(self.onSeasonAchievementChange_)
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:UnregWatcher(self.onSeasonTitleChange_)
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:UnregWatcher(self.onSeasonActivationChange_)
  self.onSeasonAchievementChange_ = nil
  self.onSeasonTitleChange_ = nil
  self.openBattlePassLevelWindow_ = nil
  self.onSeasonActivationChange_ = nil
end

function SeasonService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    local seasonTitleVM = Z.VMMgr.GetVM("season_title")
    local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
    self:BattlePassAddRedPoint()
    self:RefreshSeasonActivation()
  end
  self:AddBattlePassRegWatcher()
end

function SeasonService:AddBattlePassRegWatcher()
  function self.openBattlePassLevelWindow_(container, dirtys)
    if dirtys.level then
      self:OpenBattlePassLevelWindow()
      
      self:BattlePassAddRedPoint()
    end
    if dirtys.award then
      self:BattlePassAddRedPoint()
    end
    if dirtys and (dirtys.buyNormalPas or dirtys.buyPrimePass) then
      self:BattlePassAddRedPoint()
    end
  end
  
  local battlePassLevel = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass
  if battlePassLevel then
    battlePassLevel.Watcher:RegWatcher(self.openBattlePassLevelWindow_)
  end
end

function SeasonService:OpenBattlePassLevelWindow()
  local battlePassData = Z.DataMgr.Get("battlepass_data")
  local bpLevel = Z.ContainerMgr.CharSerialize.seasonCenter.battlePass.level
  if battlePassData.BattlePassLevel == bpLevel then
    return
  end
  battlePassData.BattlePassLevel = bpLevel
  local param = {level = bpLevel}
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "battle_pass_level_up", param)
end

function SeasonService:BattlePassAddRedPoint()
  local battlePassVM = Z.VMMgr.GetVM("battlepass")
  local isShowRed = battlePassVM.CheckBPCardIsHasUnclaimedAward()
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.BpCardTab, isShowRed and 1 or 0)
  local seasonTitleVM = Z.VMMgr.GetVM("season_title")
  local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
  Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
end

function SeasonService:RefreshSeasonActivation()
  local stageRewardStatus = Z.ContainerMgr.CharSerialize.seasonActivation.stageRewardStatus
  local isRed = false
  for k, v in pairs(stageRewardStatus) do
    Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonActivationTab, E.RedType.SeasonActivationAward, E.RedType.SeasonActivationAward .. k)
    Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonActivationAward .. k, v == E.DrawState.CanDraw and 1 or 0)
    if v == E.DrawState.CanDraw then
      isRed = true
    end
  end
  if stageRewardStatus == nil or table.zcount(stageRewardStatus) == 0 then
    local seasonActivationVm = Z.VMMgr.GetVM("season_activation")
    local awardData = seasonActivationVm.GetActivationAwards()
    if awardData and next(awardData) then
      for k, v in pairs(awardData) do
        Z.RedPointMgr.RefreshServerNodeCount(E.RedType.SeasonActivationAward .. k, 0)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.SeasonBattlePass, isRed)
end

return SeasonService
