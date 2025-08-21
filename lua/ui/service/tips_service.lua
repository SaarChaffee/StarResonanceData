local super = require("ui.service.service_base")
local TipsService = class("TipsService", super)

function TipsService:OnInit()
end

function TipsService:OnUnInit()
end

function TipsService:OnLogin()
  Z.EventMgr:Add(Z.ConstValue.TipsShowNextTopPop, self.OnTipsShowNextTopPop, self)
  Z.EventMgr:Add(Z.ConstValue.UIClose, self.OnUIClose_, self)
end

function TipsService:OnLogout()
  Z.EventMgr:Remove(Z.ConstValue.TipsShowNextTopPop, self.OnTipsShowNextTopPop, self)
  Z.EventMgr:Remove(Z.ConstValue.UIClose, self.OnUIClose_, self)
end

function TipsService:OnEnterScene(sceneId)
end

function TipsService:OnNotifyEnterWorld(sceneId)
  local noticeTipData = Z.DataMgr.Get("noticetip_data")
  noticeTipData:ClearTopPopData()
  noticeTipData.TopPopShowingState = false
end

function TipsService:OnUIClose_(viewConfigKey)
  if viewConfigKey and viewConfigKey == "loading_window" and self.isStoppedByLoading then
    self.isStoppedByLoading = false
    self:OnTipsShowNextTopPop()
  end
end

function TipsService:OnTipsShowNextTopPop()
  if Z.UIMgr:IsActive("loading_window") then
    self.isStoppedByLoading = true
    return
  end
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
