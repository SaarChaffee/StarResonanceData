local PandoraVM = {}
local cjson = require("cjson")
local ZPandora = Panda.SDK.ZPandora
local PANDORA_DEFINE = require("ui.model.pandora_define")

function PandoraVM:IsResourceReady()
  local pandoraData = Z.DataMgr.Get("pandora_data")
  local appName = pandoraData:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Announce)
  return pandoraData:IsResourceReady(appName)
end

function PandoraVM:OpenPandoraAnnounce()
  if PANDORA_DEFINE.APP_ID.Announce == "" then
    return
  end
  Panda.SDK.ZPandora.OpenApp(PANDORA_DEFINE.APP_ID.Announce, "")
end

function PandoraVM:ClosePandoraAnnounce()
  if PANDORA_DEFINE.APP_ID.Announce == "" then
    return
  end
  Panda.SDK.ZPandora.CloseApp(PANDORA_DEFINE.APP_ID.Announce)
end

function PandoraVM:ShowPandoraAnnounce()
  if PANDORA_DEFINE.APP_ID.Announce == "" then
    return
  end
  local pandoraData = Z.DataMgr.Get("pandora_data")
  local paramSend = {
    type = PANDORA_DEFINE.MessageType.ShowAnnounce,
    appId = PANDORA_DEFINE.APP_ID.Announce,
    appName = pandoraData:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Announce)
  }
  local jsonSend = cjson.encode(paramSend)
  ZPandora.SendMessageToApp(PANDORA_DEFINE.APP_ID.Announce, jsonSend)
end

function PandoraVM:HidePandoraAnnounce()
  if PANDORA_DEFINE.APP_ID.Announce == "" then
    return
  end
  local pandoraData = Z.DataMgr.Get("pandora_data")
  local paramSend = {
    type = PANDORA_DEFINE.MessageType.HideAnnounce,
    appId = PANDORA_DEFINE.APP_ID.Announce,
    appName = pandoraData:GetAppNameByAppId(PANDORA_DEFINE.APP_ID.Announce)
  }
  local jsonSend = cjson.encode(paramSend)
  ZPandora.SendMessageToApp(PANDORA_DEFINE.APP_ID.Announce, jsonSend)
end

function PandoraVM:RefreshPandoraAnnounce(isForce, labels)
  if PANDORA_DEFINE.APP_ID.Announce == "" then
    return
  end
  local paramSend = {
    type = PANDORA_DEFINE.MessageType.RefreshAnnounce,
    isForce = isForce,
    newLabels = labels
  }
  local jsonSend = cjson.encode(paramSend)
  ZPandora.SendMessageToApp(PANDORA_DEFINE.APP_ID.Announce, jsonSend)
end

function PandoraVM:OpenItemTips(configId, screenPosition)
  self:CloseItemTips()
  local extraParams = {
    posType = E.EItemTipsPopType.ScreenPosition,
    screenPosition = screenPosition
  }
  self.pandoraItemTipsId_ = Z.TipsVM.ShowItemTipsView(nil, configId, nil, extraParams)
end

function PandoraVM:CloseItemTips()
  if self.pandoraItemTipsId_ then
    Z.TipsVM.CloseItemTipsView(self.pandoraItemTipsId_)
    self.pandoraItemTipsId_ = nil
  end
end

function PandoraVM:OpenPandoraAppByAppId(appId)
  if appId == nil or appId == "" then
    return
  end
  Panda.SDK.ZPandora.OpenApp(appId, "")
end

function PandoraVM:ClosePandoraAppByAppId(appId)
  if appId == nil or appId == "" then
    return
  end
  Panda.SDK.ZPandora.CloseApp(appId)
end

function PandoraVM:CheckUnShowPopup()
  local appId = PANDORA_DEFINE.APP_ID.Popup
  if appId == "" then
    return
  end
  local paramSend = {
    type = PANDORA_DEFINE.MessageType.panameraCheckUnShowData,
    appId = appId
  }
  local jsonSend = cjson.encode(paramSend)
  ZPandora.SendMessageToApp(appId, jsonSend)
end

return PandoraVM
