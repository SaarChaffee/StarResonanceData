local super = require("ui.service.service_base")
local ItemService = class("ItemService", super)

function ItemService:OnInit()
end

function ItemService:OnUnInit()
end

function ItemService:OnLogin()
end

function ItemService:OnLogout()
end

function ItemService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    local quickItemUsageVm = Z.VMMgr.GetVM("quick_item_usage")
    quickItemUsageVm.ShowQuickUseView()
  end
end

return ItemService
