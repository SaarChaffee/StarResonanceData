local super = require("ui.service.service_base")
local SeasonService = class("SeasonService", super)

function SeasonService:OnInit()
end

function SeasonService:OnUnInit()
end

function SeasonService:OnLogin()
  function self.onSeasonTitleChange_(container, dirtyKeys)
    local seasonTitleVM = Z.VMMgr.GetVM("season_title")
    
    local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
  end
  
  function self.onSeasonActivationChange_(container, dirtyKeys)
    self:RefreshSeasonActivation()
  end
  
  if self.seasonCultivateRed_ == nil then
    self.seasonCultivateRed_ = require("rednode.season_cultivate_red")
  end
  self.seasonCultivateRed_.Init()
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:RegWatcher(self.onSeasonTitleChange_)
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:RegWatcher(self.onSeasonActivationChange_)
end

function SeasonService:OnLogout()
  if self.seasonCultivateRed_ then
    self.seasonCultivateRed_.UnInit()
  end
  Z.ContainerMgr.CharSerialize.seasonRankList.Watcher:UnregWatcher(self.onSeasonTitleChange_)
  Z.ContainerMgr.CharSerialize.seasonActivation.Watcher:UnregWatcher(self.onSeasonActivationChange_)
  Z.EventMgr:Remove(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
  self.onSeasonTitleChange_ = nil
  self.onSeasonActivationChange_ = nil
end

function SeasonService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    local seasonTitleVM = Z.VMMgr.GetVM("season_title")
    local isHaveUnReceivedRankReward = seasonTitleVM.IsHaveRedDot()
    Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonTitle, isHaveUnReceivedRankReward and 1 or 0)
    self:BattlePassAddRedPoint()
    self:RefreshSeasonActivation()
  end
  self:AddBattlePassRegWatcher()
end

function SeasonService:AddBattlePassRegWatcher()
  self.battlePassVM_ = Z.VMMgr.GetVM("battlepass")
  self.battlePassData_ = Z.DataMgr.Get("battlepass_data")
  Z.EventMgr:Add(Z.ConstValue.BattlePassDataUpdate, self.onBattlePassDataUpDateFunc, self)
end

function SeasonService:onBattlePassDataUpDateFunc(dirtyTable)
  if not dirtyTable or next(dirtyTable) == nil then
    return
  end
  if dirtyTable.level and not dirtyTable.id then
    self:OpenBattlePassLevelWindow()
    self:BattlePassAddRedPoint()
  end
  if dirtyTable.award then
    self:BattlePassAddRedPoint()
  end
  if dirtyTable.buyNormalPas or dirtyTable.buyPrimePass then
    self:BattlePassAddRedPoint()
  end
end

function SeasonService:OpenBattlePassLevelWindow()
  local curBpCardData = self.battlePassVM_.GetCurrentBattlePassContainer()
  if not curBpCardData then
    return
  end
  if self.battlePassData_.BattlePassLevel == curBpCardData.level then
    return
  end
  self.battlePassData_.BattlePassLevel = curBpCardData.level
  local param = {
    level = curBpCardData.level
  }
  Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.FunctionOpen, "battle_pass_level_up", param)
end

function SeasonService:BattlePassAddRedPoint()
  local battlePassVM = Z.VMMgr.GetVM("battlepass")
  local isShowRed = battlePassVM.CheckBPCardIsHasUnclaimedAward()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.BpCardTab, isShowRed and 1 or 0)
end

function SeasonService:RefreshSeasonActivation()
  local stageRewardStatus = Z.ContainerMgr.CharSerialize.seasonActivation.stageRewardStatus
  local isRed = false
  for k, v in pairs(stageRewardStatus) do
    Z.RedPointMgr.AddChildNodeData(E.RedType.SeasonActivationTab, E.RedType.SeasonActivationAward, E.RedType.SeasonActivationAward .. k)
    Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonActivationAward .. k, v == E.DrawState.CanDraw and 1 or 0)
    if v == E.DrawState.CanDraw then
      isRed = true
    end
  end
  if stageRewardStatus == nil or table.zcount(stageRewardStatus) == 0 then
    local seasonActivationVm = Z.VMMgr.GetVM("season_activation")
    local awardData = seasonActivationVm.GetActivationAwards()
    if awardData and next(awardData) then
      for k, v in pairs(awardData) do
        Z.RedPointMgr.UpdateNodeCount(E.RedType.SeasonActivationAward .. k, 0)
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.FunctionID.SeasonBattlePass, isRed)
end

return SeasonService
