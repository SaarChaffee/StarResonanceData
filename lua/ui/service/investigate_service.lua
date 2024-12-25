local super = require("ui.service.service_base")
local InvestigateService = class("InvestigateService", super)

function InvestigateService:OnInit()
end

function InvestigateService:OnUnInit()
end

function InvestigateService:OnLogin()
end

function InvestigateService:OnLogout()
end

local onInvestigateChange = function(investigateList, dirtyKeys)
  local investigationMainData = Z.DataMgr.Get("investigationclue_data")
  investigationMainData:UpdateInvestigationStepClueData(false)
end

function InvestigateService:OnEnterScene()
  if Z.StageMgr.GetIsInGameScene() then
    local investigationMainData = Z.DataMgr.Get("investigationclue_data")
    investigationMainData:InitInvestigationStepClueData()
    Z.ContainerMgr.CharSerialize.investigateList.Watcher:RegWatcher(onInvestigateChange)
  end
end

function InvestigateService:OnLeaveScene()
  Z.ContainerMgr.CharSerialize.investigateList.Watcher:UnregWatcher(onInvestigateChange)
end

return InvestigateService
