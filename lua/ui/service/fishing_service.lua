local super = require("ui.service.service_base")
local FishingService = class("FishingService", super)

function FishingService:OnInit()
end

function FishingService:OnUnInit()
end

function FishingService:OnLogout()
  local fishingData_ = Z.DataMgr.Get("fishing_data")
  fishingData_.HaveInitData = false
end

function FishingService:OnEnterScene(sceneId)
end

function FishingService:OnSyncAllContainerData()
  local fishingRed = require("rednode.fishing_red")
  fishingRed.InitFishIllustratedRed()
  fishingRed.InitLevelRewardRed()
end

return FishingService
