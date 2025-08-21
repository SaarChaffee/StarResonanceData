local super = require("ui.service.service_base")
local FishingService = class("FishingService", super)

function FishingService:OnInit()
  self.fishingData_ = Z.DataMgr.Get("fishing_data")
  Z.EventMgr:Add(Z.ConstValue.BeforeDeactiveAll, self.BeforeDeactiveAll, self)
end

function FishingService:OnUnInit()
  Z.EventMgr:Remove(Z.ConstValue.BeforeDeactiveAll, self.BeforeDeactiveAll, self)
end

function FishingService:BeforeDeactiveAll()
  if self.fishingData_.FishingStage ~= E.FishingStage.Quit then
    local fishingVM_ = Z.VMMgr.GetVM("fishing")
    fishingVM_.AsyncQuitFishingState(self.fishingData_.CancelSource:CreateToken())
  end
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
  local fishingVM = Z.VMMgr.GetVM("fishing")
  fishingVM.InitFishData()
end

return FishingService
