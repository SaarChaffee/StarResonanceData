local super = require("ui.service.service_base")
local AchievementService = class("AchievementService", super)

function AchievementService:OnInit()
  self.achievementVM_ = Z.VMMgr.GetVM("achievement")
end

function AchievementService:OnUnInit()
end

function AchievementService:OnLogin()
end

function AchievementService:OnLogout()
  self.achievementVM_.UnregWatcher()
end

function AchievementService:OnSyncAllContainerData()
  self.achievementVM_.RegWatcher()
end

function AchievementService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    self.achievementVM_.CheckRed()
  end
end

function AchievementService:Refresh()
end

return AchievementService
