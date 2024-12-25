local super = require("ui.service.service_base")
local ExploreMonsterService = class("ExploreMonsterService", super)

function ExploreMonsterService:OnInit()
end

function ExploreMonsterService:OnUnInit()
end

function ExploreMonsterService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
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

function ExploreMonsterService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.GoalGuideChange, self.onGoalGuideChange, self)
end

function ExploreMonsterService:OnEnterScene(sceneId)
end

return ExploreMonsterService
