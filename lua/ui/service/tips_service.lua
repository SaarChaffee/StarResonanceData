local super = require("ui.service.service_base")
local TipsService = class("TipsService", super)

function TipsService:OnInit()
end

function TipsService:OnUnInit()
end

function TipsService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.TipsShowNextTopPop, self.OnTipsShowNextTopPop, self)
end

function TipsService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.TipsShowNextTopPop, self.OnTipsShowNextTopPop, self)
end

function TipsService:OnEnterScene(sceneId)
end

function TipsService:OnTipsShowNextTopPop()
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  noticeTipData.TopPopShowingState = false
  local msgCount = noticeTipData:GetTopPopDataCount()
  if msgCount == 0 then
    return
  end
  local msgItem = noticeTipData:DequeueTopPopData()
  Z.TipsVM.ShowTopPopTips(msgItem)
end

return TipsService
