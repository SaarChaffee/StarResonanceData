local super = require("ui.service.service_base")
local RecommendFightValueService = class("RecommendFightValueService", super)

function RecommendFightValueService:OnInit()
end

function RecommendFightValueService:OnUnInit()
end

function RecommendFightValueService:OnLogin()
end

function RecommendFightValueService:OnLogout()
end

function RecommendFightValueService:OnEnterScene(sceneId)
end

function RecommendFightValueService:OnSyncAllContainerData()
  Z.VMMgr.GetVM("recommend_fightvalue").UploadFightValueTLog()
end

return RecommendFightValueService
