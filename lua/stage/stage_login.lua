local QualityGradeSetting = Panda.Utility.Quality.QualityGradeSetting
local EQualityPlatform = Panda.Utility.Quality.EQualityPlatform
local super = require("stage.stage_base")
local StageLogin = class("StageLogin", super)

function StageLogin:ctor()
  super.ctor(self, Z.EStageType.Login)
end

function StageLogin:InitSceneUI(sceneId)
  super.InitSceneUI(self, sceneId)
end

function StageLogin:ShowSceneUI()
  super.ShowSceneUI(self)
end

function StageLogin:OnEnterStage(sceneId)
  super.OnEnterStage(self, sceneId)
  if QualityGradeSetting.CurrentPlatform == EQualityPlatform.Standalone then
    Z.GameContext.UseECSModel = true
  end
end

return StageLogin
