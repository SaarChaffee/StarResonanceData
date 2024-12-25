local UIBase = class("UIBase")
local UI = Z.UI
local UICompBindLua = UICompBindLua
local UIBinderToLua = UIBinderToLua

function UIBase:ctor(viewConfigKey, assetPath, cacheLv)
  self.assetPath = assetPath
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
  self.listenersCompDict_ = {}
end

function UIBase:Active(viewData, parentTrans, baseViewBinder)
  self:createCancelSource()
  self:SetViewData(viewData)
  self:SetBaseView(baseViewBinder)
  if self.IsActive then
    if self.IsLoaded then
      self:SetAsLastSibling()
      self:Show()
      self:OnRefresh()
    else
    end
  else
    self.IsActive = true
    self.parentTrans = parentTrans
    self:checkSceneMaskCreate()
  end
end

function UIBase:DeActive()
  self:clearCancelSource()
  if not self.IsActive then
    return
  end
  self.IsActive = false
  if not self.IsLoaded then
    return
  end
  self.timerMgr:Clear()
  self:SetVisible(false)
  self:OnHide()
  self:OnDeActive()
  self:UnBindAllWatchers()
  self:UnBindAllEvents()
  self:ClearCompListeners()
  self:SetViewData()
  self:SetBaseView()
  self:UnLoad()
end

function UIBase:Destory()
  self:OnDestory()
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
  self:SetTransParent(self.parentTrans, self.baseViewBinder)
  self:SetVisible(true)
  self:OnActive()
  self:OnShow()
  self:OnRefresh()
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

function UIBase:needCached()
  return self.cacheLv ~= UI.ECacheLv.None
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
  self:OnShow()
  Z.EventMgr:Dispatch(Z.ConstValue.UIShow, self.viewConfigKey, true)
end

function UIBase:Hide()
  if not self.IsVisible then
    return
  end
  self:SetVisible(false)
  self:OnHide()
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

function UIBase:MarkListenerComp(component, isNeedClear)
  if component == nil then
    return
  end
  self.listenersCompDict_[component] = isNeedClear
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
  for comp, isNeedClear in pairs(self.listenersCompDict_) do
    if isNeedClear and comp ~= nil and comp.RemoveAllListeners then
      comp:RemoveAllListeners()
    end
  end
  self.listenersCompDict_ = {}
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

return UIBase
