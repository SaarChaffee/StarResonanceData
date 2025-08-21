local UI = Z.UI
local super = require("ui.ui_subview_base")
local Explore_monster_arrow_subView = class("Explore_monster_arrow_subView", super)

function Explore_monster_arrow_subView:ctor(parent)
  self.uiBinder = nil
  super.ctor(self, "explore_monster_arrow_sub", "explore_monster/explore_monster_positioning_tpl", UI.ECacheLv.None)
  self.vm = Z.VMMgr.GetVM("explore_monster")
end

function Explore_monster_arrow_subView:OnActive()
  Z.EventMgr:Add(Z.ConstValue.Explore_Monster.arrow, self.updateArrow, self)
end

function Explore_monster_arrow_subView:OnRefresh()
  self:updateArrow()
end

function Explore_monster_arrow_subView:OnDeActive()
  Z.EventMgr:Remove(Z.ConstValue.Explore_Monster.arrow, self.updateArrow, self)
end

function Explore_monster_arrow_subView:updateArrow()
  local dataMgr = Z.DataMgr.Get("explore_monster_data")
  local monsters = dataMgr:GetExploreArrowContent()
  local sceneId = Z.StageMgr.GetCurrentSceneId()
  local uuid
  local guideData = Z.DataMgr.Get("goal_guide_data")
  local oldGoalList = guideData:GetGuideGoalsBySource(E.GoalGuideSource.MonsterExplore) or {}
  local guideVM = Z.VMMgr.GetVM("goal_guide")
  for id, _ in pairs(monsters) do
    uuid = dataMgr:GetMonsterUUid(id)
    if uuid and 0 < uuid then
      local entity = Z.EntityMgr:GetEntity(uuid)
      if entity then
        self:addTrackGuideGoals(oldGoalList, entity.EntId, sceneId)
      end
    end
  end
  guideVM.SetGuideGoals(E.GoalGuideSource.MonsterExplore, oldGoalList)
end

function Explore_monster_arrow_subView:addTrackGuideGoals(oldGoalList, entId, sceneId)
  for index, value in ipairs(oldGoalList) do
    if value.SceneId == sceneId and value.Uid == entId then
      return
    end
  end
  local info = Panda.ZGame.GoalPosInfo.New(E.GoalGuideSource.MonsterExplore, sceneId, entId, Z.GoalPosType.Monster)
  table.insert(oldGoalList, info)
end

return Explore_monster_arrow_subView
