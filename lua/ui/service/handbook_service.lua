local super = require("ui.service.service_base")
local HandbookService = class("HandbookService", super)

function HandbookService:OnInit()
end

function HandbookService:OnUnInit()
end

function HandbookService:OnLogin()
end

function HandbookService:OnLogout()
  Z.DataMgr.Get("handbook_data"):SaveLocalSave()
end

function HandbookService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    Z.DataMgr.Get("handbook_data"):InitLocalSave()
  end
end

return HandbookService
