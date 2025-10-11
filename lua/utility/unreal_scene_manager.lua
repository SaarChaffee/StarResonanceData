local UnrealSceneMgr = class("UnrealSceneMgr")
local unrealScene = Panda.ZUi.ZUnrealSceneMgr.Instance

function UnrealSceneMgr:ctor()
  self.isExist_ = false
  self.initConfig_ = false
  self.resetCameraConfig_ = true
  self.isActive_ = false
  self.finishCallBack_ = nil
  self.isLoading_ = false
  self.loadedUnrealScene_ = false
  self.loadedUnrealSceneConfig_ = false
  self.cacheModelDict_ = {}
  self.totalLoadCount_ = 3
  self.nowLoadCount_ = 0
  self.timerMgr_ = Z.TimerMgr.new()
  self.configDict_ = {}
end

function UnrealSceneMgr:IsActive()
  return self.isActive_
end

function UnrealSceneMgr:OpenUnrealScene(path, viewConfigKey, finishCallBack, configPath, async, resetCameraConfig, isWhite)
  if self.isLoading_ then
    return
  end
  self.nowLoadCount_ = 0
  self.loadedUnrealScene_ = false
  self.loadedUnrealSceneConfig_ = false
  self.initConfig_ = false
  self.resetCameraConfig_ = true
  if resetCameraConfig ~= nil then
    self.resetCameraConfig_ = resetCameraConfig
  end
  self.isExist_ = true
  if configPath == nil then
    configPath = "unrealscene/unrealsceneconfig_yzh"
  end
  if self.configDict_[viewConfigKey] == nil then
    self.configDict_[viewConfigKey] = {}
    self.configDict_[viewConfigKey].configPath = configPath
    self.configDict_[viewConfigKey].path = path
    self.configDict_[viewConfigKey].refCount = 1
  elseif not Z.UIMgr:IsActive(viewConfigKey) then
    self.configDict_[viewConfigKey].refCount = self.configDict_[viewConfigKey].refCount + 1
  end
  Z.UIMgr:FadeIn({IsInstant = true, IsWhite = isWhite})
  if async then
    if finishCallBack then
      finishCallBack()
    end
    self:loadUnrealSceneAsync(path, configPath)
  else
    self.finishCallBack_ = finishCallBack
    self.isLoading_ = true
    self:loadUnrealSceneSync(path, configPath)
  end
  self.isActive_ = true
end

function UnrealSceneMgr:TryOpenUnrealScene(viewConfigKey, callback)
  Z.UIMgr:FadeIn({IsInstant = true})
  self.finishCallBack_ = callback
  if self.configDict_[viewConfigKey] == nil then
    if callback then
      callback()
    end
    return
  end
  local path = self.configDict_[viewConfigKey].path
  local configPath = self.configDict_[viewConfigKey].configPath
  if not Z.UIMgr:IsActive(viewConfigKey) then
    self.configDict_[viewConfigKey].refCount = self.configDict_[viewConfigKey].refCount + 1
  end
  self.nowLoadCount_ = 0
  self.loadedUnrealScene_ = false
  self.loadedUnrealSceneConfig_ = false
  self.isExist_ = true
  self.initConfig_ = false
  self.resetCameraConfig_ = true
  self:loadUnrealSceneSync(path, configPath)
  self.isActive_ = true
end

function UnrealSceneMgr:loadUnrealSceneAsync(path, configPath)
  if not self.isActive_ then
    unrealScene:Active()
  end
  unrealScene:AsyncLoadUnrealScene(path, function()
    self.loadedUnrealScene_ = true
    self:updateLoadProgress()
  end, function()
  end)
  unrealScene:AsyncLoadUnrealSceneConfig(configPath, function()
    self.loadedUnrealSceneConfig_ = true
    self:updateLoadProgress()
  end, function()
  end)
end

function UnrealSceneMgr:loadUnrealSceneSync(path, configPath)
  if not self.isActive_ then
    unrealScene:Active()
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:TryResetTexture()
    local asyncCall = Z.CoroUtil.async_to_sync(unrealScene.AsyncLoadUnrealScene)
    asyncCall(unrealScene, path)
    self.loadedUnrealScene_ = true
    self:updateLoadProgress()
  end, function(err)
    logError("unrealscene err:{0}", err)
    Z.UIMgr:FadeOut({IsInstant = true})
  end)()
  Z.CoroUtil.create_coro_xpcall(function()
    local asyncCallConfig = Z.CoroUtil.async_to_sync(unrealScene.AsyncLoadUnrealSceneConfig)
    asyncCallConfig(unrealScene, configPath)
    self.loadedUnrealSceneConfig_ = true
    self:updateLoadProgress()
  end, function(err)
    logError("unrealscene err:{0}", err)
    Z.UIMgr:FadeOut({IsInstant = true})
  end)()
end

function UnrealSceneMgr:clearAll()
  Z.UIMgr:FadeOut({IsInstant = true})
  self:TryResetTexture()
  unrealScene:DeActive()
  self.isLoading_ = false
  self.isExist_ = false
  self.isActive_ = false
  self.initConfig_ = false
  self.resetCameraConfig_ = true
  self.cacheModelDict_ = {}
  self.timerMgr_:Clear()
end

function UnrealSceneMgr:CloseUnrealScene(viewConfigKey)
  if self.configDict_[viewConfigKey] == nil then
    return
  end
  self.configDict_[viewConfigKey].refCount = self.configDict_[viewConfigKey].refCount - 1
  local closeUnrealScene = true
  for viewConfigKey, value in pairs(self.configDict_) do
    if value.refCount > 0 then
      closeUnrealScene = false
    end
  end
  if closeUnrealScene then
    self:clearAll()
  end
end

function UnrealSceneMgr:ForceCloseUnrealScene()
  if not self.isExist_ then
    return
  end
  self.configDict_ = {}
  self:clearAll()
end

function UnrealSceneMgr:updateLoadProgress()
  self.nowLoadCount_ = self.nowLoadCount_ + 1
  if self.nowLoadCount_ >= self.totalLoadCount_ then
    Z.EventMgr:Dispatch(Z.ConstValue.UnrealSceneLoadFinish)
  end
  if self.loadedUnrealScene_ and self.loadedUnrealSceneConfig_ then
    if self.finishCallBack_ then
      self.finishCallBack_()
      self.finishCallBack_ = nil
    end
    self.isLoading_ = false
  end
end

function UnrealSceneMgr:SetVisibleByLayer(layer, visible)
  if not Z.StageMgr.GetIsInGameScene() then
    return
  end
  local viewConfigKeyList = Z.UIMgr:GetViewConfigKyeCacheByLayer(layer)
  for _, viewConfigKey in ipairs(viewConfigKeyList) do
    if Z.UIConfig[viewConfigKey].IsUnrealScene and self.isExist_ then
      unrealScene:SetVisible(visible)
      return
    end
  end
end

function UnrealSceneMgr:HideUnrealScene()
  if self.isExist_ then
    unrealScene:SetVisible(false)
  end
end

function UnrealSceneMgr:ShowUnrealScene()
  if self.isExist_ then
    unrealScene:SetVisible(true)
  end
end

function UnrealSceneMgr:InitSceneCamera(ingoreFadeOut, isWhite, isInstant)
  unrealScene:InitSceneCamera(self.resetCameraConfig_)
  if ingoreFadeOut then
    return
  end
  Z.UIMgr:FadeOut({IsWhite = isWhite, IsInstant = isInstant})
end

function UnrealSceneMgr:AsyncSetBackGround(texPath)
  unrealScene:AsyncSetBackGround(texPath)
end

function UnrealSceneMgr:HideCachePlayerModel()
  return unrealScene:HideCachePlayerModel()
end

function UnrealSceneMgr:GetCachePlayerModel(preCreateFunc, onLoaded)
  return unrealScene:GetCachePlayerModel(preCreateFunc, onLoaded)
end

function UnrealSceneMgr:CloneModelByLua(oldModel, srcModel, preloadFunc, modelName, onLoaded, clipName)
  if not self.isExist_ then
    return
  end
  local model = unrealScene:CloneModelByLua(oldModel, srcModel, preloadFunc, onLoaded, clipName)
  self:SetCacheModel(modelName, model)
  return model
end

function UnrealSceneMgr:GenModelByLua(oldModel, modelId, preloadFunc, modelName, onLoaded, clipName, ignoreAnimTemplate)
  if not self.isExist_ then
    return
  end
  if ignoreAnimTemplate == nil then
    ignoreAnimTemplate = true
  end
  local model = unrealScene:GenModelByLua(oldModel, modelId, preloadFunc, onLoaded, clipName, ignoreAnimTemplate)
  self:SetCacheModel(modelName, model)
  return model
end

function UnrealSceneMgr:GenAiModelByLua(oldModel, botAiId, preloadFunc, modelName, onLoaded, clipName)
  if not self.isExist_ then
    return
  end
  local model = unrealScene:GenAiModelByLua(oldModel, botAiId, preloadFunc, onLoaded, clipName)
  self:SetCacheModel(modelName, model)
  return model
end

function UnrealSceneMgr:GenModelByLuaSocialData(appearanceDatas, modelName, preloadFunc, onLoaded, clipName)
  if not self.isExist_ then
    return
  end
  local model = unrealScene:GenModelByLuaSocialData(appearanceDatas, preloadFunc, onLoaded, clipName)
  self:SetCacheModel(modelName, model)
  return model
end

function UnrealSceneMgr:SetCacheModel(modelName, model)
  if modelName then
    self.cacheModelDict_[modelName] = model
  end
end

function UnrealSceneMgr:GetCacheModel(modelName)
  return self.cacheModelDict_[modelName]
end

function UnrealSceneMgr:SetModelRot(model, posName, keyName)
  unrealScene:SetModelRot(model, posName, keyName)
end

function UnrealSceneMgr:SetParentByName(model, transName)
  unrealScene:SetParentByName(model, transName)
end

function UnrealSceneMgr:GetTransByName(transName)
  return unrealScene:GetTransByName(transName)
end

function UnrealSceneMgr:GetGOByBinderName(transName)
  return unrealScene:GetGOByBinderName(transName)
end

function UnrealSceneMgr:GetGOScreenPos(transName, rect)
  local x, y = unrealScene:GetGOScreenPos(transName, rect, nil, nil)
  return x, y
end

function UnrealSceneMgr:SetNodeActiveByName(transName, isActive)
  return unrealScene:SetNodeActiveByName(transName, isActive)
end

function UnrealSceneMgr:SetNodeScale(transName, x, y, z)
  return unrealScene:SetNodeScale(transName, x, y, z)
end

function UnrealSceneMgr:SetNodeLocalPosition(transName, x, y, z)
  return unrealScene:SetNodeLocalPosition(transName, x, y, z)
end

function UnrealSceneMgr:SetNodeRenderColorByName(transName, isBlack)
  return unrealScene:SetNodeRenderColorByName(transName, isBlack)
end

function UnrealSceneMgr:LoadScenePrefab(path, parent, pos, token, onLoad)
  local asyncCall = Z.CoroUtil.async_to_sync(unrealScene.AsyncLoadUnrealScenePrefab)
  local Go = asyncCall(unrealScene, path, parent, pos, token)
  if onLoad then
    onLoad()
  end
  return Go
end

function UnrealSceneMgr:ClearModel(oldModel)
  if not self.isExist_ then
    return
  end
  for modelName, model in pairs(self.cacheModelDict_) do
    if model == oldModel then
      self.cacheModelDict_[modelName] = nil
    end
  end
  unrealScene:ClearModel(oldModel)
end

function UnrealSceneMgr:ChangeLoadPrefabRotation(prefab, x, y, z)
  unrealScene:ChangeLoadPrefabRotation(prefab, x, y, z)
end

function UnrealSceneMgr:ChangeLoadPrefabTexture(prefab, index, name, path, cancelToken)
  local asyncCall = Z.CoroUtil.async_to_sync(unrealScene.ChangeLoadPrefabTexture)
  asyncCall(unrealScene, prefab, index, name, path, cancelToken)
end

function UnrealSceneMgr:ChangeBinderGOTexture(goName, index, name, path, cancelToken)
  local asyncCall = Z.CoroUtil.async_to_sync(unrealScene.ChangeBinderGOTexture)
  asyncCall(unrealScene, goName, index, name, path, cancelToken)
end

function UnrealSceneMgr:SetCacheTextureName(goName, index, name, path)
  if self.cacheTextureDict_ == nil then
    self.cacheTextureDict_ = {}
  end
  local data = {
    goName = goName,
    index = index,
    name = name,
    path = path
  }
  table.insert(self.cacheTextureDict_, data)
  unrealScene:SetCacheTexture(goName, name, path)
end

function UnrealSceneMgr:TryResetTexture()
  if self.cacheTextureDict_ == nil then
    return
  end
  for _, value in pairs(self.cacheTextureDict_) do
    local goName = value.goName
    local index = value.index
    local name = value.name
    local path = value.path
    unrealScene:ResetTextureByCache(goName, index, name, path)
  end
  self.cacheTextureDict_ = {}
end

function UnrealSceneMgr:ChangeBinderGOTextureById(goName, index, name, textureId)
  unrealScene:ChangeBinderGOTextureById(goName, index, name, textureId)
end

function UnrealSceneMgr:ReleaseBinderGOTextureById(textureId)
  unrealScene:ReleaseBinderGOTextureById(textureId)
end

function UnrealSceneMgr:ClearBlock()
  unrealScene:ClearBlock()
end

function UnrealSceneMgr:ChangeLoadPrefabScale(prefab, x, y, z)
  unrealScene:ChangeLoadPrefabScale(prefab, x, y, z)
end

function UnrealSceneMgr:AddVirtEntityListener(name, func)
  unrealScene:AddVirtEntityListener(name, func)
end

function UnrealSceneMgr:ClearModelByName(modelName)
  if not self.isExist_ then
    return
  end
  if self.cacheModelDict_ == nil then
    return
  end
  if self.cacheModelDict_[modelName] then
    local model = self.cacheModelDict_[modelName]
    unrealScene:ClearModel(model)
    self.cacheModelDict_[modelName] = nil
  end
end

function UnrealSceneMgr:GetTransPos(transName)
  if not self.isExist_ then
    return Vector3.zero
  end
  return unrealScene:GetTransPos(transName)
end

function UnrealSceneMgr:ClearLoadPrefab(prefab)
  unrealScene:ClearLoadPrefab(prefab)
end

function UnrealSceneMgr:SwicthVirtualStyle(targetId)
  unrealScene:SwicthVirtualStyle(targetId)
end

function UnrealSceneMgr:SwitchGroupReflection(enable)
  unrealScene:SwitchGroupReflection(enable)
end

function UnrealSceneMgr:ChangeWaterSSprHeight(height)
  if not self.isExist_ then
    return
  end
  unrealScene:ChangeWaterSSprHeight(height)
end

function UnrealSceneMgr:SetNodeScale(transName, x, y, z)
  unrealScene:SetNodeScale(transName, x, y, z)
end

function UnrealSceneMgr:SetNodeLocalPosition(transName, x, y, z)
  unrealScene:SetNodeLocalPosition(transName, x, y, z)
end

function UnrealSceneMgr:SetLimitLookAtEnable(enable)
  unrealScene:SetLimitLookAtEnable(enable)
end

function UnrealSceneMgr:SetLookAtLimitBounds(bounds)
  unrealScene:SetLookAtLimitBounds(bounds)
end

function UnrealSceneMgr:updateLookAt(offset)
  unrealScene:UpdateLookAt(offset)
end

function UnrealSceneMgr:DoCameraAnim(keyName, offsetKey, callback)
  offsetKey = offsetKey or 0
  unrealScene:DoCameraAnim(keyName, offsetKey, callback)
end

function UnrealSceneMgr:DoCameraAnimLookAtOffset(keyName, offset, callback)
  offset = offset or Vector3.zero
  unrealScene:DoCameraAnimLookAtOffset(keyName, offset, callback)
end

function UnrealSceneMgr:ResetCameraParam(keyName, offsetKey)
  offsetKey = offsetKey or 0
  unrealScene:ResetCameraParam(keyName, offsetKey)
end

function UnrealSceneMgr:SetUnrealSceneCameraZoomRange(minZoom, maxZoom)
  unrealScene:SetUnrealSceneCameraZoomRange(minZoom, maxZoom)
end

function UnrealSceneMgr:RestUnrealSceneCameraZoomRange()
  unrealScene:RestUnrealSceneCameraZoomRange()
end

function UnrealSceneMgr:SetUnrealCameraScreenXY(offset)
  unrealScene:SetUnrealCameraScreenXY(offset)
end

function UnrealSceneMgr:GetLookAtOffsetByModelId(modelId)
  return unrealScene:GetLookAtOffsetByModelId(modelId)
end

function UnrealSceneMgr:SetCameraLookAtEnable(enable)
  unrealScene:SetCameraLookAtEnable(enable)
end

function UnrealSceneMgr:SetAutoChangeLook(enable)
  unrealScene:SetAutoChangeLook(enable)
end

function UnrealSceneMgr:SetZoomAutoChangeLookAt(maxLookatHeight, minLookatHeight, maxZoom, minZoom)
  maxZoom = maxZoom or 1.2
  minZoom = minZoom or 0.2
  unrealScene:SetZoomAutoChangeLookAt(maxLookatHeight, minLookatHeight, maxZoom, minZoom)
end

function UnrealSceneMgr:SetZoomAutoChangeLookAtByOffset(maxOffset, minOffset)
  unrealScene:SetZoomAutoChangeLookAtByOffset(maxOffset, minOffset)
end

function UnrealSceneMgr:SetZoomAutoChangeConfigIndex(index)
  unrealScene:SetZoomAutoChangeConfigIndex(index)
end

function UnrealSceneMgr:SetZoomAutoChangeLookAtZoomRange(maxZoom, minZoom)
  unrealScene:SetZoomAutoChangeLookAtZoomRange(maxZoom, minZoom)
end

function UnrealSceneMgr:GetZoomAutoChangeLookAtOffsetByModelId(modelId)
  return unrealScene:GetZoomAutoChangeLookAtOffsetByModelId(modelId)
end

function UnrealSceneMgr:CreatEffect(path, keyName)
  return unrealScene:CreatEffect(path, keyName)
end

function UnrealSceneMgr:NewCreatEffect(path, keyName)
  return unrealScene:NewCreatEffect(path, keyName)
end

function UnrealSceneMgr:CreatEffectByMoreParam(path, pos, scale, rot, time)
  return unrealScene:CreatEffect(path, pos, scale, rot, time)
end

function UnrealSceneMgr:CreateEffectOnModelPoint(model, path, point, pos, rot, scale, isVisible, time)
  return unrealScene:CreateEffectOnModelPoint(model, path, point, pos, rot, scale, isVisible, time)
end

function UnrealSceneMgr:AsyncSetArmHandEffect(model, effectPath, cancelToken, onLoad, onException)
  return unrealScene:AsyncSetArmHandEffect(model, effectPath, cancelToken, onLoad, onException)
end

function UnrealSceneMgr:SetEffectInfo(uuid, keyName)
  if uuid == nil or keyName == nil then
    return
  end
  unrealScene:SetEffectInfo(uuid, keyName)
end

function UnrealSceneMgr:ClearEffect(uuid)
  if uuid == nil then
    return
  end
  unrealScene:ClearEffect(uuid)
end

function UnrealSceneMgr:SetEffectVisible(uuid, visibel)
  if uuid == nil then
    return
  end
  unrealScene:SetEffectVisible(uuid, visibel)
end

function UnrealSceneMgr:SetEffectParent(uuid, parent)
  if uuid == nil then
    return
  end
  unrealScene:SetEffectParent(uuid, parent)
end

function UnrealSceneMgr:SetEffectPosition(uuid, x, y, z)
  if uuid == nil then
    return
  end
  unrealScene:SetEffectPosition(uuid, x, y, z)
end

function UnrealSceneMgr:SetEffectRotate(uuid, x, y, z)
  if uuid == nil then
    return
  end
  unrealScene:SetEffectRotate(uuid, x, y, z)
end

function UnrealSceneMgr:SetModelCustomShadow(model, open)
  if model == nil then
    return
  end
  unrealScene:SetModelCustomShadow(model, open)
end

return UnrealSceneMgr
