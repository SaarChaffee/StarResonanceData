local super = require("ui.service.service_base")
local PandoraService = class("PandoraService", super)
local cjson = require("cjson")
local ZPandora = Panda.SDK.ZPandora
local PANDORA_DEFINE = require("ui.model.pandora_define")
local PIXUI_SCHEMA = "pixui://"
local PIXUI_ICON_MATCH = "pixui://method:game/icon/(%d+)"

function PandoraService:OnInit()
  self.pandoraData_ = Z.DataMgr.Get("pandora_data")
  self.sendOpenPandora_ = false
  ZPandora.RegistOnCreateView(function(go, args)
    self:onPandoraCreateView(go, args)
  end)
  ZPandora.RegistOnCloseView(function(go, args)
    self:onPandoraCloseView(go, args)
  end)
  ZPandora.RegistOnMessage(function(message)
    self:onPandoraMessage(message)
  end)
  ZPandora.RegistOnGetUserData(function()
    self:setPandoraUserdata()
  end)
  ZPandora.RegistOnImageLoading(function(url)
    return self:checkCustomImage(url)
  end, function(url, callback)
    self:customLoadImage(url, callback)
  end, function(texture)
    self:customUnloadImage(texture)
  end)
end

function PandoraService:OnLateInit()
end

function PandoraService:OnUnInit()
  self.sendOpenPandora_ = false
end

function PandoraService:OnLogin()
  if self.hadSetFont_ == nil then
    self.hadSetFont_ = true
    Z.LuaBridge.SetPandoraFont()
  end
  Z.EventMgr:Add(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
  Z.EventMgr:Add(Z.ConstValue.UIShow, self.onUIShow, self)
end

function PandoraService:OnLogout()
  if self.sendOpenPandora_ then
    self.sendOpenPandora_ = false
    ZPandora.Close()
  end
  Z.EventMgr:Remove(Z.ConstValue.SwitchFunctionChange, self.onFuncDataChange, self)
  Z.EventMgr:Remove(Z.ConstValue.UIShow, self.onUIShow, self)
end

function PandoraService:OnEnterScene(sceneId)
  if self.sendOpenPandora_ then
    return
  end
  local currentPlatform = Z.SDKLogin.GetPlatform()
  if currentPlatform == E.LoginPlatformType.TencentPlatform then
    local sceneTable = Z.TableMgr.GetRow("SceneTableMgr", sceneId)
    local subType = sceneTable.SceneSubType
    if subType ~= E.SceneSubType.Login and subType ~= E.SceneSubType.Select then
      xpcall(function()
        local userData = self.pandoraData_:GetPandoraUserdata()
        ZPandora.OpenByLua(userData)
        self.sendOpenPandora_ = true
      end, function(err)
        logError("OpenByLua error : " .. err)
      end)
    end
  end
end

function PandoraService:OnLeaveScene()
end

function PandoraService:OnReconnect()
end

function PandoraService:OnEnterStage(stage, toSceneId, dungeonId)
end

function PandoraService:OnSyncAllContainerData()
end

function PandoraService:OnVisualLayerChange()
end

function PandoraService:OnResurrectionEnd()
end

function PandoraService:onPandoraCreateView(go, args)
  if go == nil then
    return
  end
  if args == nil or args == "" then
    return
  end
  xpcall(function()
    local viewInfo = cjson.decode(args)
    local appId = viewInfo.appId
    if type(appId) == "number" then
      appId = tostring(math.floor(appId))
    end
    local extraInfo
    if viewInfo.extraInfo ~= nil and viewInfo.extraInfo ~= "" then
      extraInfo = cjson.decode(viewInfo.extraInfo)
    end
    self.pandoraData_:SetAppResource(appId, go)
    local config = PANDORA_DEFINE.APP_CONFIG[appId]
    if config and not config.IsSubView then
      local layer = config.Layer or Z.UI.ELayer.UILayerSDK
      local viewData = {AppId = appId, Layer = layer}
      Z.QueueTipManager:AddQueueTipData(E.EQueueTipType.Activities, "pandora_common_popup", viewData)
    end
    Z.EventMgr:Dispatch(PANDORA_DEFINE.EventName.ViewCreate, appId, extraInfo)
  end, function(msg)
    logError("onPandoraCreateView error : " .. msg)
  end)
end

function PandoraService:onPandoraCloseView(go, args)
  if args == nil or args == "" then
    return
  end
  xpcall(function()
    local viewInfo = cjson.decode(args)
    local appId = viewInfo.appId
    if type(appId) == "number" then
      appId = tostring(math.floor(appId))
    end
    self.pandoraData_:SetAppResource(appId, nil)
    local config = PANDORA_DEFINE.APP_CONFIG[appId]
    if config and not config.IsSubView then
      Z.UIMgr:CloseView("pandora_common_popup")
    end
    local pandoraVM = Z.VMMgr.GetVM("pandora")
    pandoraVM:CloseItemTips()
    Z.EventMgr:Dispatch(PANDORA_DEFINE.EventName.ViewDestroy, appId)
    self:checkUnShowPopupOnActivityClose()
  end, function(msg)
    logError("onPandoraCloseView error : " .. msg)
  end)
end

function PandoraService:onPandoraMessage(message)
  logGreen("onPandoraMessage, message = {0}", message)
  xpcall(function()
    local messageInfo = cjson.decode(message)
    local messageType = messageInfo.type
    local messageFunc = PandoraService[messageType]
    if messageFunc then
      messageFunc(self, messageInfo)
    end
  end, function(msg)
    logError("onPandoraMessage error : " .. msg)
  end)
end

function PandoraService:onPandoraGetUserData()
  local userData = self.pandoraData_:GetPandoraUserdata()
  return userData
end

function PandoraService:setPandoraUserdata()
  local userData = self.pandoraData_:GetPandoraUserdata()
  ZPandora.SetUserData(userData)
end

function PandoraService:getItemIconPathByUrl(url)
  if string.sub(url, 1, #PIXUI_SCHEMA) == PIXUI_SCHEMA then
    local itemIdContent = string.match(url, PIXUI_ICON_MATCH)
    if itemIdContent and itemIdContent ~= "" then
      local itemId = tonumber(itemIdContent)
      if itemId then
        local itemVm = Z.VMMgr.GetVM("items")
        return itemVm.GetItemIcon(itemId)
      end
    end
  end
end

function PandoraService:checkCustomImage(url)
  if url:match("^" .. PIXUI_SCHEMA) == PIXUI_SCHEMA then
    return true
  else
    return false
  end
end

function PandoraService:customLoadImage(url, callback)
  local itemIconPath = self:getItemIconPathByUrl(url)
  if itemIconPath == nil then
    return
  end
  Z.LuaBridge.LoadImage(itemIconPath, callback)
end

function PandoraService:customUnloadImage(texture)
  Z.LuaBridge.ReleaseImage(texture)
end

function PandoraService:pandoraShowEntrance(messageInfo)
  if messageInfo.appId == nil or messageInfo.appId == "" then
    return
  end
  if messageInfo.appName == nil or messageInfo.appName == "" then
    return
  end
  self.pandoraData_:SetAppNameByAppId(messageInfo.appId, messageInfo.appName)
  self.pandoraData_:SetResourceReady(messageInfo.appName, true)
  if messageInfo.appId == PANDORA_DEFINE.APP_ID.Popup then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    if gotoFuncVM.FuncIsOn(E.FunctionID.PandoraPopup, true) then
      local pandoraVM = Z.VMMgr.GetVM("pandora")
      pandoraVM:OpenPandoraAppByAppId(messageInfo.appId)
      self.pandoraData_.PopupQueryTag = true
    else
      self.pandoraData_.PopupOpenTag = true
    end
  end
  Z.EventMgr:Dispatch(PANDORA_DEFINE.EventName.ResourceReady, messageInfo.appName)
end

function PandoraService:pandoraShowRedpoint(messageInfo)
  if messageInfo.appId == nil or messageInfo.appId == "" then
    return
  end
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  local config = PANDORA_DEFINE.APP_CONFIG[messageInfo.appId]
  if config ~= nil and config.RedDotId ~= nil then
    local count = tonumber(messageInfo.content)
    Z.RedPointMgr.UpdateNodeCount(config.RedDotId, count)
  end
end

function PandoraService:pandoraShowTextTip(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  Z.TipsVM.ShowTips(100011, {
    val = messageInfo.content
  })
end

function PandoraService:pandoraShowLoading(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  local isLoading = messageInfo.content == "1"
  Z.NetWaitHelper.SetPandoraWaitingTag(isLoading)
end

function PandoraService:pandoraShowReceivedItem(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  local resultList = {}
  local paramSplit = string.split(messageInfo.content, ",")
  if #paramSplit == 0 then
    return
  end
  for i, v in ipairs(paramSplit) do
    local infoSplit = string.split(v, "|")
    local itemId = tonumber(infoSplit[1])
    local itemNum = tonumber(infoSplit[2])
    resultList[i] = {configId = itemId, count = itemNum}
  end
  local itemShowVm = Z.VMMgr.GetVM("item_show")
  itemShowVm.OpenItemShowView(resultList)
end

function PandoraService:pandoraShowItemTip(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  local paramSplit = string.split(messageInfo.content, ",")
  if #paramSplit == 0 then
    return
  end
  local itemId = tonumber(paramSplit[1])
  local posX = tonumber(paramSplit[2] or 0)
  local posY = tonumber(paramSplit[3] or 0)
  local screenPosition = Vector3.New(posX, posY, 0)
  local pandoraVM = Z.VMMgr.GetVM("pandora")
  pandoraVM:OpenItemTips(itemId, screenPosition)
end

function PandoraService:pandoraOpenUrl(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  Z.SDKWebView.OpenWebView(messageInfo.content, true)
end

function PandoraService:pandoraGoSystem(messageInfo)
  if messageInfo.content == nil or messageInfo.content == "" then
    return
  end
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local paramSplit = string.split(messageInfo.content, ",")
  local funcId = tonumber(paramSplit[1])
  if 1 < #paramSplit then
    local funcArgs = {}
    for i = 2, #paramSplit do
      table.insert(funcArgs, paramSplit[i])
    end
    gotoFuncVM.GoToFunc(funcId, table.unpack(funcArgs))
  else
    gotoFuncVM.GoToFunc(funcId)
  end
end

function PandoraService:pandoraGoPandora(messageInfo)
  if messageInfo.targetAppId == nil or messageInfo.targetAppId == "" then
    return
  end
  local paramReceived = {}
  if messageInfo.targetAppPage ~= nil and messageInfo.targetAppPage ~= "" then
    paramReceived.appPage = messageInfo.targetAppPage
  end
  if messageInfo.jumpParams ~= nil and messageInfo.jumpParams ~= "" then
    paramReceived.jumpParams = messageInfo.jumpParams
  end
  local jsonSend = cjson.encode(paramReceived)
  ZPandora.OpenApp(messageInfo.targetAppId, jsonSend)
end

function PandoraService:pandoraOpenMiniApp(messageInfo)
  if messageInfo.miniAppId == nil or messageInfo.miniAppId == "" then
    return
  end
end

function PandoraService:pandoraCloseApp(messageInfo)
  if messageInfo.targetAppId == nil or messageInfo.targetAppId == "" then
    return
  end
  ZPandora.CloseApp(messageInfo.targetAppId)
end

function PandoraService:pandoraGetUserInfo(messageInfo)
  do return end
  if messageInfo.appId == nil then
    return
  end
  local sendParam = {}
  sendParam.type = PANDORA_DEFINE.MessageType.GetUserInfoResult
  sendParam.content = messageInfo.openIds
  sendParam.source = messageInfo.source
  if messageInfo.openIds ~= nil and messageInfo.openIds ~= "" then
    local tempContent = ""
    local paramSplit = string.split(messageInfo.openIds, ",")
    for i, v in ipairs(paramSplit) do
      local infoSplit = string.split(v, "#")
      local key = infoSplit[1]
      local value = infoSplit[2]
      if tempContent == "" then
        tempContent = string.zconcat(key, "#", value)
      else
        tempContent = string.zconcat(tempContent, ",", key, "#", value)
      end
    end
  end
  local jsonSend = cjson.encode(sendParam)
  ZPandora.SendMessageToApp(messageInfo.appId, jsonSend)
end

function PandoraService:panameraCheckUnShowDataResult(messageInfo)
  if messageInfo.appId == nil then
    return
  end
  if messageInfo.appId == PANDORA_DEFINE.APP_ID.Popup then
    local unShowCount = tonumber(messageInfo.unshowCount or 0)
    self.pandoraData_.PopupQueryTag = 1 < unShowCount
    if 0 < unShowCount then
      local pandoraVM = Z.VMMgr.GetVM("pandora")
      pandoraVM:OpenPandoraAppByAppId(messageInfo.appId)
    end
  end
end

function PandoraService:pandoraGetNotchHeight(messageInfo)
  if messageInfo.appId == nil then
    return
  end
  local pandoraVM = Z.VMMgr.GetVM("pandora")
  pandoraVM:SendNotchHeight(messageInfo.appId)
end

function PandoraService:onUIShow(viewConfigKey)
  if viewConfigKey and viewConfigKey == Z.ConstValue.MainViewName then
    self:checkUnShowPopupOnBackMainView()
  end
end

function PandoraService:checkUnShowPopupOnBackMainView()
  if self.pandoraData_.PopupQueryTag then
    self.pandoraData_.PopupQueryTag = false
    local pandoraVM = Z.VMMgr.GetVM("pandora")
    pandoraVM:CheckUnShowPopup()
  end
end

function PandoraService:checkUnShowPopupOnActivityClose()
  if self.pandoraData_.PopupQueryTagOnClose then
    self.pandoraData_.PopupQueryTagOnClose = false
    local pandoraVM = Z.VMMgr.GetVM("pandora")
    pandoraVM:CheckUnShowPopup()
  end
end

function PandoraService:onFuncDataChange(funcData)
  for functionId, isUnlock in pairs(funcData) do
    if functionId == E.FunctionID.PandoraPopup and isUnlock and self.pandoraData_.PopupOpenTag then
      local pandoraVM = Z.VMMgr.GetVM("pandora")
      pandoraVM:OpenPandoraAppByAppId(PANDORA_DEFINE.APP_ID.Popup)
      self.pandoraData_.PopupQueryTag = true
      self.pandoraData_.PopupOpenTag = false
      break
    end
  end
end

return PandoraService
