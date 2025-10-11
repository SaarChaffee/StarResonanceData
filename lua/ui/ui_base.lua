local UIBase = class("UIBase")
local UI = Z.UI
local UICompBindLua = UICompBindLua
local UIBinderToLua = UIBinderToLua
local xpcall = xpcall

function UIBase:ctor(viewConfigKey, assetPath, cacheLv, isHavePCUI)
  if Z.IsPCUI and isHavePCUI then
    self.assetPath = string.zconcat(assetPath, "_pc")
  else
    self.assetPath = assetPath
  end
  self.viewConfigKey = viewConfigKey
  self.cacheLv = cacheLv
  self.goObj = nil
  self.panel = nil
  self.uiBinder = nil
  self.cancelSource = nil
  self.timerMgr = Z.TimerMgr.new()
  self.viewData = nil
  self.SceneMaskKey = nil
  self.units = {}
  self.redUnits = {}
  self.cancelTokens = {}
  self.luaEntityAttrWatchers = {}
  self.IsActive = false
  self.IsLoaded = false
  self.IsVisible = false
  self.IsResponseInput = true
  self.baseViewBinder = nil
  self.inputActionDatas = {}
  self.listenersCompDict = {}
  
  function self.OnInputActionTrigger_(inputActionEventData)
    self:triggerInputAction(inputActionEventData)
  end
end

function UIBase:Active(viewData, parentTrans, baseViewBinder)
  self:SetUIMaskState(true)
  self:createCancelSource()
  self:SetViewData(viewData)
  self:SetBaseView(baseViewBinder)
  if self.IsActive then
    if self.IsLoaded then
      self:SetUIMaskState(false)
      self:SetAsLastSibling()
      self:Show()
      self:CallLifeCycleFunc(self.OnRefresh)
    else
    end
  else
    self.IsActive = true
    self.parentTrans = parentTrans
    self:checkSceneMaskCreate()
  end
end

function UIBase:DeActive()
  self:SetUIMaskState(false)
  self:clearCancelSource()
  if not self.IsActive then
    return
  end
  self.IsActive = false
  if not self.IsLoaded then
    return
  end
  self:UnRegisterInputActions(self.inputActionDatas)
  self.timerMgr:Clear()
  self:SetVisible(false)
  self:CallLifeCycleFunc(self.OnHide)
  self:CallLifeCycleFunc(self.OnDeActive)
  self:UnBindAllWatchers()
  self:UnBindAllEvents()
  self:ClearCompListeners()
  self:SetViewData()
  self:SetBaseView()
  self:UnLoad()
end

function UIBase:Destory()
  self:CallLifeCycleFunc(self.OnDestory)
end

function UIBase:checkSceneMaskCreate()
  self.SceneMaskKey = nil
  local sceneMaskType = self:GetCaptureScreenType()
  if sceneMaskType == Z.UI.ESceneMaskType.Normal then
    self.SceneMaskKey = Z.UI.ESceneMaskKey.Default
  elseif sceneMaskType == Z.UI.ESceneMaskType.Overlay then
    self.SceneMaskKey = self.viewConfigKey
  end
  if self.SceneMaskKey then
    local isHideAllUI = not Z.CameraMgr.ShowUIOnly and self.SceneMaskKey == Z.UI.ESceneMaskKey.Default
    Z.SceneMaskMgr:CaptureScreen(self.SceneMaskKey, isHideAllUI, function()
      self:Load()
    end)
  else
    self:Load()
  end
end

function UIBase:checkSceneMaskRelease()
  if self.SceneMaskKey then
    if self.SceneMaskKey == Z.UI.ESceneMaskKey.Default then
      if not Z.UIMgr:IsAnyNormalSceneMaskShow(self.viewConfigKey) then
        Z.SceneMaskMgr:ClearSceneMaskTexture(Z.UI.ESceneMaskKey.Default)
      end
    else
      Z.SceneMaskMgr:ClearSceneMaskTexture(self.SceneMaskKey)
    end
    self.SceneMaskKey = nil
  end
end

function UIBase:Load()
  if not self.IsActive then
    return
  end
  Z.UIMgr:LoadView(self.viewConfigKey, self.assetPath, self.cancelSource:CreateToken(), function(goObj)
    if goObj == nil then
      return
    end
    self.goObj = goObj
    self:LoadFinish()
  end)
end

function UIBase:LoadFinish()
  if not self.IsActive then
    self:UnLoad()
    return
  end
  self.IsLoaded = true
  self.uiBinder = UIBinderToLua(self.goObj)
  if self.uiBinder == nil then
    self.panel = UICompBindLua(self.goObj)
    self.panel:Init()
  end
  self:SetUIMaskState(false)
  self:SetTransParent(self.parentTrans, self.baseViewBinder)
  self:SetVisible(true)
  self:CallLifeCycleFunc(self.OnActive)
  self:CallLifeCycleFunc(self.OnShow)
  self:CallLifeCycleFunc(self.OnRefresh)
  self:registerConfigInputActions()
  Z.EventMgr:Dispatch(Z.ConstValue.UILoadFinish, self.viewConfigKey)
end

function UIBase:UnLoad()
  self:ClearAllUnits()
  if self.panel then
    self.panel:UnInit()
    self.panel = nil
  end
  self.uiBinder = nil
  if self.goObj then
    Z.UIMgr:UnLoadView(self.viewConfigKey, self.goObj)
    self.goObj = nil
  end
  self:checkSceneMaskRelease()
  self.IsLoaded = false
  Z.EventMgr:Dispatch(Z.ConstValue.UIUnLoad, self.viewConfigKey)
end

function UIBase:createCancelSource()
  if self.cancelSource == nil then
    self.cancelSource = Z.CancelSource.Rent()
  end
end

function UIBase:clearCancelSource()
  if self.cancelSource then
    self.cancelSource:Recycle()
    self.cancelSource = nil
  end
end

function UIBase:getBindLuaAttrWatcherParam(attrTypes, func, needToIndex)
  if attrTypes == nil or #attrTypes < 1 then
    return nil, nil
  end
  local f = function()
    func(self)
  end
  if needToIndex then
    local indexs = {}
    for i = 1, #attrTypes do
      indexs[i] = Z.AttrCreator.ToIndex(attrTypes[i])
    end
    return indexs, f
  end
  return attrTypes, f
end

local onCoroClickErr = function(err)
  logError("[UIBase:CoroClick] Coro click failed with err : {0}", err)
end
local onCoroEventErr = function(err)
  logError("[UIBase:CoroEvent] Coro event failed with err : {0}", err)
end
local onLifeCycleFuncErr = function(err)
  logError("[UIBase:CallLifeCycleFunc] Call lifecycle function with err : {0}", err)
end

function UIBase:needCached()
  return self.cacheLv ~= UI.ECacheLv.None
end

function UIBase:CallLifeCycleFunc(func, ...)
  xpcall(func, onLifeCycleFuncErr, self, ...)
end

function UIBase:registerConfigInputActions()
  local inputActionDatas = Z.UIInputActionConfig[self.viewConfigKey]
  if inputActionDatas == nil then
    return
  end
  self:UnRegisterInputActions(self.inputActionDatas)
  self:RegisterInputActions(inputActionDatas)
end

function UIBase:checkViewLayerVisible()
  return true
end

function UIBase:triggerInputAction(inputActionEventData)
  if not self.IsResponseInput then
    return
  end
  if not self:checkViewLayerVisible() then
    return
  end
  if self:checkTriggerOnInputBack(inputActionEventData) then
    self:OnInputBack()
    return
  end
  self:OnTriggerInputAction(inputActionEventData)
end

function UIBase:checkTriggerOnInputBack(inputActionEventData)
  for _, value in ipairs(self.inputActionDatas) do
    if value.ActionId == inputActionEventData.ActionId and value.TriggerType == E.InputTriggerViewActionType.CloseView then
      return true
    end
  end
  return false
end

function UIBase:SetViewData(viewData)
  self.viewData = viewData
end

function UIBase:SetBaseView(baseViewBinder)
  self.baseViewBinder = baseViewBinder
end

function UIBase:BindEntityLuaAttrWatcher(attrTypes, entity, func, needToIndex)
  local indexs, f = self:getBindLuaAttrWatcherParam(attrTypes, func, needToIndex)
  if indexs == nil then
    logError("[UIBase:BindEntityLuaAttrWatcher] Bind fail, attrTypes is nil or count < 1")
    return nil
  end
  if self.luaEntityAttrWatchers == nil then
    self.luaEntityAttrWatchers = {}
  end
  local watcherToken
  if entity then
    watcherToken = Z.EntityMgr:BindEntityLuaAttrWatcher(entity.Uuid, indexs, f)
    self.luaEntityAttrWatchers[watcherToken] = entity.Uuid
  end
  return watcherToken
end

function UIBase:UnBindEntityLuaAttrWatcher(watcherToken)
  if self.luaEntityAttrWatchers == nil or watcherToken == nil or self.luaEntityAttrWatchers[watcherToken] == nil then
    return false
  end
  local uuid = self.luaEntityAttrWatchers[watcherToken]
  Z.EntityMgr:UnbindEntityLuaAttrWater(uuid, watcherToken)
  self.luaEntityAttrWatchers[watcherToken] = nil
end

function UIBase:GetPrefabCacheData(key)
  if self.panel == nil or self.panel.Ref == nil then
    return nil
  end
  return self.panel.Ref.PrefabCacheData:GetString(key)
end

function UIBase:GetPrefabCacheDataNew(pcd, key)
  if pcd == nil then
    return nil
  end
  return pcd:GetString(key)
end

function UIBase:AsyncLoadRedUiUnit(redId, unitAssetPath, uiUnitName, parent, canceltoken)
  if self.redUnits[redId] == nil then
    self.redUnits[redId] = true
  end
  return self:AsyncLoadUiUnit(unitAssetPath, uiUnitName, parent, canceltoken)
end

function UIBase:AsyncLoadUiUnit(unitAssetPath, uiUnitName, parent, canceltoken)
  if self.units[uiUnitName] ~= nil then
    return self.units[uiUnitName]
  end
  if self.cancelSource == nil then
    error(ZUtil.ZCancelSource.CancelException)
    return
  end
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.CreateInstanceAsync)
  if canceltoken == nil then
    canceltoken = self.cancelSource:CreateToken()
  end
  self:RemoveUiUnit(uiUnitName)
  self.cancelTokens[uiUnitName] = canceltoken
  local go = asyncCall(unitAssetPath, canceltoken)
  if go == nil then
    logError("[UIBase:AsyncLoadUiUnit] Load go failed, viewConfigKey={0}, unitAssetPath ={1}", self.viewConfigKey, unitAssetPath)
    self.units[uiUnitName] = nil
    return nil
  end
  local unit = UIBinderToLua(go)
  if unit == nil then
    unit = UICompBindLua(go)
  end
  if unit == nil then
    logError("[UIBase:AsyncLoadUiUnit] Load uiUnit failed, viewConfigKey={0}, unitAssetPath ={1}", self.viewConfigKey, unitAssetPath)
    self.units[uiUnitName] = nil
    return
  end
  unit.Trans.name = uiUnitName
  ZUtil.ZExtensions.SetParent(unit.Trans, parent, true, true)
  self.cancelTokens[uiUnitName] = nil
  self.units[uiUnitName] = unit
  return unit
end

function UIBase:RemoveUiUnit(uiUnitName)
  if self.cancelTokens[uiUnitName] then
    Z.CancelSource.ReleaseToken(self.cancelTokens[uiUnitName])
    self.cancelTokens[uiUnitName] = nil
  end
  local uiUnit = self.units[uiUnitName]
  if uiUnit == nil then
    return
  else
    Z.EventMgr:RemoveObjAll(uiUnit)
    Z.LuaBridge.ReleaseInstance(uiUnit.Go)
  end
  self.units[uiUnitName] = nil
end

function UIBase:AddAsyncClick(btn, clickFunc, onErr, onCancel)
  if onErr == nil then
    onErr = onCoroClickErr
  end
  self:AddAsyncListener(btn, btn.AddListener, clickFunc, onErr, onCancel)
end

function UIBase:EventAddAsyncListener(event, func, onErr, onCancel)
  self:AddAsyncListener(event, event.AddListener, func, onErr, onCancel)
end

function UIBase:AddAsyncListener(subject, registerFunc, func, onErr, onCancel)
  if onErr == nil then
    onErr = onCoroEventErr
  end
  if registerFunc == nil or subject == nil then
    logError("[UIBase:AddAsyncListener] Add fail, registerFunc == nil or subject == nil")
    return
  end
  registerFunc(subject, Z.CoroUtil.create_coro_xpcall(func, function(err)
    if err == Z.CancelException then
      if onCancel then
        onCancel()
      end
      return
    end
    if onErr then
      onErr(err)
    end
  end))
end

function UIBase:AddClick(btn, clickFunc)
  btn:AddListener(clickFunc)
end

function UIBase:Show()
  if self.IsVisible then
    return
  end
  self:SetVisible(true)
  self:CallLifeCycleFunc(self.OnShow)
  Z.EventMgr:Dispatch(Z.ConstValue.UIShow, self.viewConfigKey, true)
end

function UIBase:Hide()
  if not self.IsVisible then
    return
  end
  self:SetVisible(false)
  self:CallLifeCycleFunc(self.OnHide)
  Z.EventMgr:Dispatch(Z.ConstValue.UIHide, self.viewConfigKey, false)
end

function UIBase:SetVisible(visible)
  self.IsVisible = visible
  if self.goObj == nil then
    return
  end
  if self.uiBinder then
    self.uiBinder.Ref.UIComp:SetVisible(visible)
  elseif self.panel then
    self.panel:SetVisible(visible)
  end
  self:UpdateAfterVisibleChanged(visible)
end

function UIBase:SetUIVisible(ui, visible)
  self.uiBinder.Ref:SetVisible(ui, visible)
end

function UIBase:SetAsLastSibling()
  if self.uiBinder and self.uiBinder.Trans then
    self.uiBinder.Trans:SetAsLastSibling()
  elseif self.panel and self.panel.Trans then
    self.panel.Trans:SetAsLastSibling()
  end
end

function UIBase:SetAsFirstSibling()
  if self.uiBinder and self.uiBinder.Trans then
    self.uiBinder.Trans:SetAsFirstSibling()
  elseif self.panel and self.panel.Trans then
    self.panel.Trans:SetAsFirstSibling()
  end
end

function UIBase:SetSiblingIndex(index)
  local trans
  if self.uiBinder and self.uiBinder.Trans then
    trans = self.uiBinder.Trans
  elseif self.panel and self.panel.Trans then
    trans = self.panel.Trans
  end
  if trans then
    local childCount = trans.childCount
    if index < 0 or index >= childCount then
      logError("SetSiblingIndex param error, index={0}, childCount={1}", index, childCount)
      return
    end
    trans:SetSiblingIndex(index)
  end
end

function UIBase:MarkListenerComp(component, isNeedClear)
  if component == nil then
    return
  end
  self.listenersCompDict[component] = isNeedClear
end

function UIBase:ClearAllUnits()
  if self.cancelTokens ~= nil then
    for key, value in pairs(self.cancelTokens) do
      self:RemoveUiUnit(key)
    end
  end
  for redId, value in pairs(self.redUnits) do
    Z.RedPointMgr.RemoveNodeItem(redId, self)
  end
  if self.units ~= nil then
    for key, value in pairs(self.units) do
      self:RemoveUiUnit(key)
    end
  end
  self.cancelTokens = {}
  self.units = {}
  self.redUnits = {}
end

function UIBase:UnBindAllWatchers()
  if self.luaEntityAttrWatchers ~= nil then
    for key, value in pairs(self.luaEntityAttrWatchers) do
      self:UnBindEntityLuaAttrWatcher(key)
    end
  end
  self.luaEntityAttrWatchers = nil
end

function UIBase:UnBindAllEvents()
  Z.EventMgr:RemoveObjAll(self)
end

function UIBase:ClearCompListeners()
  for comp, isNeedClear in pairs(self.listenersCompDict) do
    if isNeedClear and comp ~= nil and comp.RemoveAllListeners then
      comp:RemoveAllListeners()
    end
  end
  self.listenersCompDict = {}
end

function UIBase:RegisterInputActions(inputActionDatas)
  if inputActionDatas == nil or #inputActionDatas < 1 then
    return
  end
  for _, value in ipairs(inputActionDatas) do
    table.insert(self.inputActionDatas, value)
    if value.Params == nil then
      Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.OnInputActionTrigger_, value.InputActionEventType, value.ActionId)
    elseif #value.Params == 1 then
      if type(value.Params[1]) == "number" then
        Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.OnInputActionTrigger_, value.InputActionEventType, value.ActionId, value.Params[1])
      end
    elseif #value.Params == 2 and type(value.Params[1]) == "number" and type(value.Params[2]) == "number" then
      Z.InputLuaBridge:AddInputEventDelegateWithActionId(self.OnInputActionTrigger_, value.InputActionEventType, value.ActionId, value.Params[1], value.Params[2])
    end
  end
end

function UIBase:UnRegisterInputActions(inputActionDatas)
  if inputActionDatas == nil or #inputActionDatas < 1 then
    return
  end
  local datas = table.zclone(inputActionDatas)
  for _, value in ipairs(datas) do
    table.zremoveByValue(self.inputActionDatas, value)
    Z.InputLuaBridge:RemoveInputEventDelegateWithActionId(self.OnInputActionTrigger_, value.InputActionEventType, value.ActionId)
  end
end

function UIBase:SetUIMaskState(state)
end

function UIBase:SetTransParent(parentTran)
end

function UIBase:GetCaptureScreenType()
  return Z.UI.ESceneMaskType.None
end

function UIBase:UpdateAfterVisibleChanged(visible)
end

function UIBase:GetCacheData()
  return self.viewData
end

function UIBase:OnActive()
end

function UIBase:OnDeActive()
end

function UIBase:OnDestory()
end

function UIBase:OnRefresh()
end

function UIBase:OnShow()
end

function UIBase:OnHide()
end

function UIBase:OnInputBack()
end

function UIBase:OnTriggerInputAction(inputActionEventData)
end

return UIBase
