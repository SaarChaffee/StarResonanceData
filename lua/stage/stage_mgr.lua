Z.EStageType = {
  Null = 0,
  Login = 1,
  SelectChar = 2,
  City = 3,
  Wild = 4,
  Dungeon = 5,
  MirrorDungeon = 6,
  CommunityDungeon = 7,
  HomelandDungeon = 8,
  UnionDungeon = 9
}
local StageBase = require("stage.stage_base")
local StageLogin = require("stage.stage_login")
local StageSelectChar = require("stage.stage_selectchar")
local StageCity = require("stage.stage_city")
local StageWild = require("stage.stage_wild")
local StageDungeon = require("stage.stage_dungeon")
local StageMirrorDungeon = require("stage.stage_mirror_dungeon")
local StageCommunityDungeon = require("stage.stage_community_dungeon")
local StageHomelandDungeon = require("stage.stage_homeland_dungeon")
local StageUnionDungeon = require("stage.stage_union_dungeon")
local stages = {
  [Z.EStageType.Null] = StageBase.new(Z.EStageType.Null),
  [Z.EStageType.Login] = StageLogin.new(),
  [Z.EStageType.SelectChar] = StageSelectChar.new(),
  [Z.EStageType.City] = StageCity.new(),
  [Z.EStageType.Wild] = StageWild.new(),
  [Z.EStageType.Dungeon] = StageDungeon.new(),
  [Z.EStageType.MirrorDungeon] = StageMirrorDungeon.new(),
  [Z.EStageType.CommunityDungeon] = StageCommunityDungeon.new(),
  [Z.EStageType.HomelandDungeon] = StageHomelandDungeon.new(),
  [Z.EStageType.UnionDungeon] = StageUnionDungeon.new()
}
local current = Z.EStageType.Null
local dungeonId = 0
local getCurrentSceneName = function()
  return stages[current].sceneName
end
local getCurrentDungeonId = function()
  return dungeonId
end
local getCurrentStageType = function()
  return current
end
local getIsInLogin = function()
  return current == Z.EStageType.Login
end
local getIsInDungeon = function()
  return dungeonId ~= 0
end
local getCurrentSceneId = function()
  return stages[current].sceneId
end
local getIsInGameScene = function()
  return current ~= Z.EStageType.Null and current ~= Z.EStageType.Login and current ~= Z.EStageType.SelectChar
end
local getIsInSelectCharScene = function()
  return current == Z.EStageType.SelectChar
end
local isInNewbieScene = function()
  return getCurrentSceneId() == Z.Global.Dungeon000
end
local OnPrepareSwitchScene = function(sceneId)
  stages[current]:OnPrepareSwitchScene(sceneId)
end
local onLeaveScene = function()
  stages[current]:OnLeaveScene()
  local interactionData = Z.DataMgr.Get("interaction_data")
  interactionData:Clear()
  if isInNewbieScene() then
    Z.SDKReport.ReportEvent(Z.SDKReportEvent.TutorialComplete)
  end
end
local onLeaveStage = function()
  stages[current]:OnLeaveStage()
end
local onEnterStage = function(stage, toSceneId, levelId)
  current = stage
  dungeonId = levelId
  stages[current]:OnEnterStage(toSceneId)
end
local OnSceneResLoadFinish = function(sceneId)
  stages[current]:OnSceneResLoadFinish(sceneId)
end
local onEnterScene = function(sceneId)
  stages[current]:OnEnterScene(sceneId)
  Z.EventMgr:Dispatch(Z.ConstValue.SceneActionEvent.EnterScene, sceneId)
  local dungeonTrackVm = Z.VMMgr.GetVM("dungeon_track")
  dungeonTrackVm.OnEnterScene()
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  noticeTipData:ClearNpcData(sceneId)
  local dungeonVm = Z.VMMgr.GetVM("dungeon")
  dungeonVm.UpdateDungeonData(false)
  dungeonVm.UpdateDungeonTimerInfo()
  if isInNewbieScene() then
    Z.SDKReport.ReportEvent(Z.SDKReportEvent.TutorialStart)
  end
end
local isInVisualLayer = function()
  local isIn = false
  if Z.EntityMgr.PlayerEnt then
    local visualLayerId = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.PbAttrEnum("AttrVisualLayerUid")).Value
    if 0 < visualLayerId then
      local visualLayerCfg = Z.TableMgr.GetTable("VisualLayerMgr").GetRow(visualLayerId)
      if visualLayerCfg then
        isIn = true
      end
    end
  end
  return isIn
end
local isDungeonStage = function()
  local isDungeonStage = current == Z.EStageType.Dungeon or current == Z.EStageType.MirrorDungeon
  return isDungeonStage
end
return {
  OnPrepareSwitchScene = OnPrepareSwitchScene,
  OnEnterStage = onEnterStage,
  OnLeaveStage = onLeaveStage,
  OnLeaveScene = onLeaveScene,
  OnSceneResLoadFinish = OnSceneResLoadFinish,
  OnEnterScene = onEnterScene,
  GetCurrentSceneName = getCurrentSceneName,
  GetCurrentSceneId = getCurrentSceneId,
  GetCurrentDungeonId = getCurrentDungeonId,
  GetCurrentStageType = getCurrentStageType,
  GetIsInLogin = getIsInLogin,
  GetIsInDungeon = getIsInDungeon,
  IsInNewbieScene = isInNewbieScene,
  GetIsInGameScene = getIsInGameScene,
  GetIsInSelectCharScene = getIsInSelectCharScene,
  IsInVisualLayer = isInVisualLayer,
  IsDungeonStage = isDungeonStage
}
