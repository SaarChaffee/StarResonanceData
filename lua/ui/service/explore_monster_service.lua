local super = require("ui.service.service_base")
local ExploreMonsterService = class("ExploreMonsterService", super)
local exploreMonsterRed = require("rednode.explore_monster_red")

function ExploreMonsterService:OnInit()
end

function ExploreMonsterService:OnUnInit()
end

function ExploreMonsterService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
  Z.ContainerMgr.CharSerialize.monsterHuntInfo.Watcher:RegWatcher(self.onMonsterHuntDataChanged)
  Z.ContainerMgr.CharSerialize.monsterExploreList.Watcher:RegWatcher(self.onExploreDataChanged)
end

function ExploreMonsterService:onGoalGuideChange(src, oldGoalList)
  if src == E.GoalGuideSource.MonsterExplore then
    local guideData = Z.DataMgr.Get("goal_guide_data")
    local newGoalList = guideData:GetGuideGoalsBySource(src) or {}
    local exploreMonsterVM_ = Z.VMMgr.GetVM("explore_monster")
    if newGoalList == nil or #newGoalList == 0 then
      for goalIndex, info in ipairs(oldGoalList) do
        local monsterEntityRow_ = Z.TableMgr.GetLevelTableRow(E.LevelTableType.Monster, info.SceneId, info.Uid)
        if monsterEntityRow_ then
          exploreMonsterVM_.CancelTrackMonster(monsterEntityRow_.Id, info.SceneId)
        end
      end
    end
    if newGoalList ~= nil and #newGoalList ~= 0 then
      for _, info in ipairs(newGoalList) do
        local monsterEntityRow_ = Z.TableMgr.GetLevelTableRow(E.LevelTableType.Monster, info.SceneId, info.Uid)
        if monsterEntityRow_ then
          exploreMonsterVM_.TrackMonster(monsterEntityRow_.Id, info.SceneId)
          Z.EventMgr:Dispatch(Z.ConstValue.GoalGuideMonsterSuccess, monsterEntityRow_.Id, info.SceneId)
        end
      end
    end
  end
end

function ExploreMonsterService:onMonsterHuntDataChanged()
  local count = exploreMonsterRed.RefreshTabRedItem(0)
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MonsterHuntTargetReceiveBtn, count)
  local count2 = exploreMonsterRed.RefreshLevelRedItem()
  Z.RedPointMgr.UpdateNodeCount(E.RedType.MonsterHuntLevel, count2)
  exploreMonsterRed.AddNewRed()
end

function ExploreMonsterService:onExploreDataChanged()
  local datas = Z.ContainerMgr.CharSerialize.monsterExploreList.monsterExploreList
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  local exploreCfgs, targetCfgs
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  for id, data in pairs(datas) do
    if dataMgr:GetMarkByID(sceneId, id) then
      exploreCfgs = exploreCfgs or Z.TableMgr.GetTable("MonsterHuntListTableMgr")
      targetCfgs = targetCfgs or Z.TableMgr.GetTable("MonsterHuntTargetTableMgr")
      local cfg = exploreCfgs.GetRow(id)
      if cfg then
        local targetId, done = 0, true
        for i, target in ipairs(cfg.Target) do
          targetId = target[2]
          local targetCfg = targetCfgs.GetRow(targetId)
          if targetCfg and (not data.targetNum[targetId] or data.targetNum[targetId] < targetCfg.Num) then
            done = false
            break
          end
        end
        if done then
          dataMgr:CancelMark(sceneId, id)
        end
      end
    end
  end
  dataMgr:ClearTargetShowContent()
  dataMgr:ClearExploreArrowContent()
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  guideVM.SetGuideGoals(E.GoalGuideSource.MonsterExplore, {})
  local exploreMonsterVM_ = Z.VMMgr.GetVM("explore_monster")
  exploreMonsterVM_.UpdateExploreMonsterRedpoint()
  Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.target)
  Z.EventMgr:Dispatch(Z.ConstValue.Explore_Monster.arrow)
end

function ExploreMonsterService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
  Z.ContainerMgr.CharSerialize.monsterHuntInfo.Watcher:UnregWatcher(self.onMonsterHuntDataChanged)
  Z.ContainerMgr.CharSerialize.monsterExploreList.Watcher:UnregWatcher(self.onExploreDataChanged)
end

function ExploreMonsterService:OnEnterScene(sceneId)
end

return ExploreMonsterService
