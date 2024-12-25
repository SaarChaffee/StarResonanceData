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
    Panda.Core.GameContext.UseECSModel = true
  end
  local needShowMark = Z.ScreenMark
  if needShowMark then
    local loginVm = Z.VMMgr.GetVM("login")
    local deviceInfo = loginVm:GetDeviceInfo()
    Z.UIMgr:OpenView("mark_main", {
      key = deviceInfo.deviceId
    })
  end
end

return StageLogin
