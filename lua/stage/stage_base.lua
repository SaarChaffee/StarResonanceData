local StageBase = class("StageBase")

function StageBase:ctor(stageEnum)
  self.stage = stageEnum
  self.sceneId = 0
  self.toSceneId = 0
  self.sceneName = ""
  self.sceneUis = {}
end

function StageBase:OnPrepareSwitchScene(sceneId)
  logGreen("[StageBase:OnPrepareSwitchScene]stage={0}, sceneId={1}", self.stage, sceneId)
  self.toSceneId = sceneId
end

function StageBase:OnLeaveScene()
  Z.UIMgr:DeActiveAll()
  logGreen("[StageBase:OnLeaveScene]stage={0}, sceneId={1}", self.stage, self.sceneId)
end

function StageBase:OnLeaveStage()
  logGreen("[StageBase:OnLeaveStage]stage={0}, sceneId={1}", self.stage, self.sceneId)
end

function StageBase:OnEnterStage(sceneId)
  logGreen("[StageBase:OnEnterStage]stage={0}, sceneId={1}", self.stage, sceneId)
  self:InitSceneUI(sceneId)
  self.sceneId = sceneId
  if not self:IsClient() then
    Z.MiniMapManager:ChangeTerrAnim(sceneId)
  end
end

function StageBase:OnSceneResLoadFinish(sceneId)
  logGreen("[StageBase:OnSceneResLoadFinish]stage={0}, sceneId={1}", self.stage, sceneId)
  self.sceneId = sceneId
end

function StageBase:OnEnterScene(sceneId)
  logGreen("[StageBase:OnEnterScene]stage={0}, sceneId={1}", self.stage, sceneId)
  self.toSceneId = 0
  self:ShowSceneUI()
end

function StageBase:IsClient()
  return self.stage == Z.EStageType.Null or self.stage == Z.EStageType.Login or self.stage == Z.EStageType.SelectChar
end

function StageBase:InitSceneUI(sceneId)
  self.sceneUis = {}
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow == nil then
    return
  end
  self.sceneName = sceneRow.Name
  self.sceneUis = sceneRow.SceneUi
end

function StageBase:ShowSceneUI()
  for i, v in ipairs(self.sceneUis) do
    Z.UIMgr:OpenView(v)
  end
end

return StageBase
