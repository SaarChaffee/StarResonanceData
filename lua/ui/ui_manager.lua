local UI = Z.UI
local UIManager = class("UIManager")
local MAX_STACK_COUNT = 5
local actionTriggerIngoreViewConfigKey = {
  mainui_funcs_list = true,
  socialize_main = true,
  expression = true
}

function UIManager:ctor()
  self.viewsDict_ = {}
  self.allOpenViewList_ = {}
  self.showMouseView_ = {}
  self.viewStack_ = {}
  self.IgnoreInputViewDict = {}
  self.UIMaskIgnoreViewDict = {}
  Z.EventMgr:Add("InputUIBackKey", self.onInputUIBackKey, self)
end

function UIManager:FadeIn(args)
  args = args or {}
  args.IsOpen = true
  args.TimeOut = args.TimeOut or 60
  self:OpenView("fade_window", args)
end

function UIManager:FadeOut(args)
  args = args or {}
  args.IsOpen = false
  args.TimeOut = args.TimeOut or 60
  self:OpenView("fade_window", args)
end

function UIManager:LoadView(viewConfigKey, assetPath, token, loadedCallback)
  local loadPath = "ui/prefabs/" .. assetPath
  Z.LuaBridge.CreateInstanceAsync(loadPath, token, function(goObj)
    if loadedCallback ~= nil then
      loadedCallback(goObj)
    end
  end, function(exception)
    if exception ~= Z.CancelException then
      logError("[UIManager:LoadView] Load Failed, viewConfigKey={0}, error={1}", viewConfigKey, exception.Message)
      Z.EventMgr:Dispatch(Z.ConstValue.UILoadFail, viewConfigKey, exception)
    end
  end)
end

function UIManager:UnLoadView(viewConfigKey, goObj)
  Z.LuaBridge.ReleaseInstance(goObj)
end

function UIManager:PreloadObject(address, loadedCallback)
  Z.LuaBridge.PreloadObject(address, function()
    if loadedCallback ~= nil then
      loadedCallback()
    end
  end, function(exception)
    if exception ~= Z.CancelException then
      logError("[UIManager]::PreloadObject Failed, address={0}, error={1}", address, exception.Message)
    end
  end)
end

function UIManager:ReleasePreloadObject(address)
  Z.LuaBridge.ReleasePreloadObject(address)
end

function UIManager:PreloadAsset(address, assetType, loadedCallback)
  Z.LuaBridge.PreloadAsset(address, assetType, function()
    if loadedCallback ~= nil then
      loadedCallback()
    end
  end, function(exception)
    if exception ~= Z.CancelException then
      logError("[UIManager]::PreloadAsset Failed, address={0}, error={1}", address, exception.Message)
    end
  end)
end

function UIManager:ReleasePreloadAsset(address)
  Z.LuaBridge.ReleasePreloadAsset(address)
end

function UIManager:OpenView(viewConfigKey, viewData)
  local ui = self:GetView(viewConfigKey)
  if ui == nil then
    local luaFileName = Z.UIConfig[viewConfigKey].LuaFileName
    if Z.IsPCUI and Z.UIConfig[viewConfigKey].PCLuaFileName and Z.UIConfig[viewConfigKey].PCLuaFileName ~= "" then
      luaFileName = Z.UIConfig[viewConfigKey].PCLuaFileName
    end
    ui = require("ui/view/" .. luaFileName).new()
    self.viewsDict_[viewConfigKey] = ui
  end
  local bottomStackInfo = self:GetCurBottomStackInfo()
  local topStackInfo = self:GetCurTopStackInfo()
  local curFocusViewKey = self:GetFocusViewConfigKey()
  if viewConfigKey == Z.ConstValue.MainViewName and bottomStackInfo and bottomStackInfo.view.viewConfigKey == Z.ConstValue.MainViewName then
    if topStackInfo and topStackInfo.view.viewConfigKey == Z.ConstValue.MainViewName then
      bottomStackInfo.view:Active(viewData)
    end
    return
  end
  local destoryUI = false
  table.zremoveByValue(self.allOpenViewList_, viewConfigKey)
  if viewConfigKey == Z.ConstValue.MainViewName and #self.viewStack_ > 0 then
    table.insert(self.allOpenViewList_, 1, viewConfigKey)
    table.insert(self.viewStack_, 1, {view = ui, viewData = viewData})
  else
    table.insert(self.allOpenViewList_, viewConfigKey)
    if ui.uiType == UI.EType.Exclusive and (topStackInfo == nil or topStackInfo.view.viewConfigKey ~= viewConfigKey or topStackInfo.view.viewConfigKey ~= curFocusViewKey) then
      self:PushStack(ui, viewData)
      destoryUI = true
    end
    Z.UICameraHelper.OpenUICamera(ui.ViewConfig.CameraState)
    ui:Active(viewData)
    if destoryUI and topStackInfo and topStackInfo.view.viewConfigKey ~= viewConfigKey then
      topStackInfo.view:Destory()
    end
  end
  Z.ViewStatusSwitchMgr:TrySetStateActive(viewConfigKey, true)
  Z.EventMgr:Dispatch(Z.ConstValue.UIOpen, viewConfigKey)
end

function UIManager:CloseView(viewConfigKey)
  self:checkRemoveStack(viewConfigKey)
  if not self:IsActive(viewConfigKey) then
    return
  end
  local ui = self:GetView(viewConfigKey)
  if ui == nil then
    return
  end
  ui:DeActive()
  ui:CustomClose()
  Z.ViewStatusSwitchMgr:TrySetStateActive(viewConfigKey, false)
  if ui.uiType == UI.EType.Exclusive then
    ui:ClearReShowStandaloneDict()
    self:PopStack(ui)
    local topStackInfo = self:GetCurTopStackInfo()
    if topStackInfo and topStackInfo.view.ViewConfig.CameraState ~= E.CameraState.None then
      Z.UICameraHelper.OpenUICamera(topStackInfo.view.ViewConfig.CameraState)
    else
      Z.UICameraHelper.CloseUICamera()
    end
  end
  table.zremoveByValue(self.allOpenViewList_, viewConfigKey)
  self.viewsDict_[viewConfigKey] = nil
  Z.EventMgr:Dispatch(Z.ConstValue.UIClose, viewConfigKey)
end

function UIManager:UpdateCameraState()
  local isFullScreenShow = false
  local isUnrealSceneShow = false
  local layerVisibleDict = {}
  for i = #self.allOpenViewList_, 1, -1 do
    local view = self:GetView(self.allOpenViewList_[i])
    if view and view.IsActive and view.IsLoaded and view.IsVisible then
      local layer = view.ViewConfig.Layer
      if layerVisibleDict[layer] == nil then
        layerVisibleDict[layer] = Z.UIRoot:GetLayerVisible(layer)
      end
      if layerVisibleDict[layer] then
        if view.ViewConfig.IsFullScreen then
          isFullScreenShow = true
        end
        if view.ViewConfig.IsUnrealScene then
          isUnrealSceneShow = true
        end
      end
    end
    if isFullScreenShow and isUnrealSceneShow then
      break
    end
  end
  Z.CameraMgr:RefreshCameraCullingMask(isFullScreenShow, isUnrealSceneShow)
end

function UIManager:UpdateAudioState()
  for i = #self.allOpenViewList_, 1, -1 do
    local view = self:GetView(self.allOpenViewList_[i])
    if view and view.IsActive and view.IsVisible then
      if view.ViewConfig.Layer == Z.UI.ELayer.UILayerDramaBottom then
        Z.AudioMgr:SetState(E.AudioState.Game, E.AudioGameState.Dialogue)
        return
      elseif view.ViewConfig.Layer == Z.UI.ELayer.UILayerDramaVideo or view.ViewConfig.Layer == Z.UI.ELayer.UILayerDramaTop then
        return
      elseif view.ViewConfig.IsFullScreen or view.ViewConfig.IsUnrealScene then
        Z.AudioMgr:SetState(E.AudioState.Game, E.AudioGameState.Menu)
        return
      end
    end
  end
  if self:IsActive("fade_window") then
    return
  end
  Z.AudioMgr:SetState(E.AudioState.Game, E.AudioGameState.Ingame)
  do return end
  local focusViewConfigKey = self:GetFocusViewConfigKey()
  local view = self:GetView(focusViewConfigKey)
  if view then
    Z.AudioMgr:SetState(E.AudioState.Game, view.ViewConfig.AudioGameState)
  else
    Z.AudioMgr:SetState(E.AudioState.Game, E.AudioGameState.Ingame)
  end
end

function UIManager:IsAnyNormalSceneMaskShow(viewConfigKey)
  for i = #self.allOpenViewList_, 1, -1 do
    local view = self:GetView(self.allOpenViewList_[i])
    if view and view.IsActive and view.IsVisible and view.SceneMaskKey and view.SceneMaskKey == Z.UI.ESceneMaskKey.Default and (not viewConfigKey or view.viewConfigKey ~= viewConfigKey) then
      return true
    end
  end
  return false
end

function UIManager:CloseViewByAnim(viewConfigKey, tweenContainer, animType)
  if tweenContainer:IsPlaying(animType) then
    return
  end
  tweenContainer:CoroPlay(animType, function()
    Z.UIMgr:CloseView(viewConfigKey)
  end, function(err)
    if err and err ~= Z.CancelException then
      Z.UIMgr:CloseView(viewConfigKey)
    end
  end)
end

function UIManager:IsActive(viewConfigKey)
  local view = self:GetView(viewConfigKey)
  if not view then
    return false
  end
  return view.IsActive
end

function UIManager:HideAllActiveViews(filterView)
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    if not filterView or viewConfigKey ~= filterView then
      local view = self:GetView(viewConfigKey)
      if view and view.IsActive and view.uiType ~= UI.EType.Permanent then
        view:Hide()
      end
    end
  end
  Z.UnrealSceneMgr:HideUnrealScene()
end

function UIManager:ShowAllActiveViews(filterView)
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    if not filterView or viewConfigKey ~= filterView then
      local view = self:GetView(viewConfigKey)
      if view and view.IsActive then
        view:Show()
      end
    end
  end
  Z.UnrealSceneMgr:ShowUnrealScene()
end

function UIManager:GetView(viewConfigKey)
  return self.viewsDict_[viewConfigKey]
end

function UIManager:DeActiveAll(isClearAll, ignoreViewKey)
  self.viewStack_ = {}
  Z.EventMgr:Dispatch(Z.ConstValue.BeforeDeactiveAll)
  local waitCloseViewList = {}
  local waitCloseViewCount = 0
  local isNeedCloseUICamera = false
  for i = #self.allOpenViewList_, 1, -1 do
    local viewConfigKey = self.allOpenViewList_[i]
    if ignoreViewKey == nil or ignoreViewKey ~= viewConfigKey then
      local view = self:GetView(self.allOpenViewList_[i])
      if view and (isClearAll or view.uiType ~= UI.EType.Permanent) then
        waitCloseViewCount = waitCloseViewCount + 1
        waitCloseViewList[waitCloseViewCount] = viewConfigKey
        if view.ViewConfig.CameraState ~= E.CameraState.None then
          isNeedCloseUICamera = true
        end
        if view.uiType == UI.EType.Exclusive then
          view:ClearReShowStandaloneDict()
        end
      end
    end
  end
  for i = 1, waitCloseViewCount do
    self:CloseView(waitCloseViewList[i])
  end
  if isNeedCloseUICamera then
    Z.UICameraHelper.CloseUICamera()
  end
  Z.DialogViewDataMgr:ClearAll()
  Z.UnrealSceneMgr:ForceCloseUnrealScene()
end

function UIManager:GotoMainView()
  logYellow("[UIManager] GotoMainView")
  self:DeActiveAll(false, Z.ConstValue.MainViewName)
  Z.UIMgr:OpenView(Z.ConstValue.MainViewName)
end

function UIManager:PushStack(view, viewData)
  local topStackInfo = self:GetCurTopStackInfo()
  if topStackInfo ~= nil then
    self:checkCloseViewOnPushStack(topStackInfo.view.ViewConfigKey)
    if topStackInfo.view.viewConfigKey == Z.ConstValue.MainViewName then
      topStackInfo.view:Hide()
    else
      topStackInfo.viewData = topStackInfo.view:GetCacheData()
      topStackInfo.view:DeActive()
      Z.ViewStatusSwitchMgr:TrySetStateActive(topStackInfo.view.ViewConfigKey, false)
    end
  end
  self:checkRemoveStack(view.ViewConfigKey)
  table.insert(self.viewStack_, {view = view, viewData = viewData})
  local stackCount = 0
  local firstCanRemoveIndex, firstCanRemoveKey
  for i, stackInfo in ipairs(self.viewStack_) do
    if stackInfo.view.ViewConfig.Layer ~= Z.UI.ELayer.UILayerMain then
      if firstCanRemoveIndex == nil then
        firstCanRemoveIndex = i
        firstCanRemoveKey = stackInfo.view.viewConfigKey
      end
      stackCount = stackCount + 1
    end
  end
  if stackCount > MAX_STACK_COUNT and firstCanRemoveIndex then
    local view = self:GetView(firstCanRemoveKey)
    if view then
      view:ClearReShowStandaloneDict()
    end
    table.remove(self.viewStack_, firstCanRemoveIndex)
    table.zremoveByValue(self.allOpenViewList_, firstCanRemoveKey)
    Z.ViewStatusSwitchMgr:TrySetStateActive(firstCanRemoveKey, false)
    self.viewsDict_[firstCanRemoveKey] = nil
  end
end

function UIManager:PopStack(ui)
  local stackCount = #self.viewStack_
  if stackCount == 0 then
    return
  end
  local stackInfo = self.viewStack_[stackCount]
  local view = stackInfo.view
  local viewData = stackInfo.viewData
  if view.ViewConfig.IsUnrealScene then
    Z.UnrealSceneMgr:TryOpenUnrealScene(view.ViewConfigKey, function()
      view:Active(viewData)
      ui:Destory()
    end)
  else
    view:Active(viewData)
    ui:Destory()
  end
  Z.ViewStatusSwitchMgr:TrySetStateActive(stackInfo.view.viewConfigKey, true)
end

local needRecoverStandaloneViewDict = {
  mainui_funcs_list = true,
  bag_selectpack_popup_new = true,
  sys_dialog = true
}

function UIManager:checkCloseViewOnPushStack(viewConfigKey)
  local waitCloseViewList = {}
  local waitCloseViewCount = 0
  for i = #self.allOpenViewList_, 1, -1 do
    local curViewKey = self.allOpenViewList_[i]
    local curView = self:GetView(curViewKey)
    if curView and curViewKey ~= viewConfigKey and curView.uiType == UI.EType.Standalone then
      waitCloseViewCount = waitCloseViewCount + 1
      waitCloseViewList[waitCloseViewCount] = curViewKey
    end
  end
  for i = 1, waitCloseViewCount do
    local key = waitCloseViewList[i]
    if needRecoverStandaloneViewDict[key] then
      local view = self:GetView(viewConfigKey)
      if view then
        view:SetReShowStandaloneView(key)
      else
        self:CloseView(key)
      end
    else
      self:CloseView(key)
    end
  end
end

function UIManager:checkRemoveStack(viewConfigKey)
  if #self.viewStack_ == 0 then
    return
  end
  for i = #self.viewStack_, 1, -1 do
    if self.viewStack_[i].view.ViewConfigKey == viewConfigKey then
      table.remove(self.viewStack_, i)
      break
    end
  end
end

function UIManager:GetViewConfigKyeCacheByLayer(layer)
  local viewConfigKeyList = {}
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    local view = self:GetView(viewConfigKey)
    if view and view.uiLayer == layer then
      table.insert(viewConfigKeyList, viewConfigKey)
    end
  end
  return viewConfigKeyList
end

function UIManager:GetCurTopStackInfo()
  if #self.viewStack_ == 0 then
    return nil
  end
  return self.viewStack_[#self.viewStack_]
end

function UIManager:GetCurBottomStackInfo()
  if #self.viewStack_ == 0 then
    return nil
  end
  return self.viewStack_[1]
end

function UIManager:GetFocusViewConfigKey()
  local topLayerView
  for i = #self.allOpenViewList_, 1, -1 do
    local viewConfigKey = self.allOpenViewList_[i]
    local view = self:GetView(viewConfigKey)
    if view and view.IsActive and view.IsVisible and Z.UI.EFocusLayer[view.uiLayer] and not view.ViewConfig.IgnoreFocus then
      if topLayerView == nil then
        topLayerView = view
      elseif topLayerView.uiLayer < view.uiLayer then
        topLayerView = view
      end
    end
  end
  if topLayerView ~= nil then
    return topLayerView.ViewConfigKey
  else
    return nil
  end
end

function UIManager:onInputUIBackKey()
  if not self:HasFocusView() then
    if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
      return
    end
    local mainuiVm = Z.VMMgr.GetVM("mainui")
    mainuiVm.GotoMainUIFunc(E.FunctionID.MainFuncMenu)
    return
  end
  local focusViewConfigKey = self:GetFocusViewConfigKey()
  local view = self:GetView(focusViewConfigKey)
  if view and not view.ViewConfig.IgnoreBack and view.IsLoaded and view.IsVisible and Z.UIRoot:GetLayerVisible(view.uiLayer) then
    view:OnInputBack()
  end
end

function UIManager:UpdateDepth(eLayer)
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    local view = self:GetView(viewConfigKey)
    if view and view.uiLayer == eLayer then
      view:UpdateDepth()
    end
  end
end

function UIManager:CheckMainUIActionLimit(actionId)
  local mainuiView = self:GetView("mainui")
  if mainuiView == nil then
    return false
  end
  if not mainuiView.IsVisible or not Z.UIRoot:GetLayerVisible(mainuiView.uiLayer) then
    return false
  end
  if Z.IgnoreMgr:IsInputIgnore(Panda.ZGame.EInputMask.UIInteract) then
    return false
  end
  if self:HasFocusView(actionTriggerIngoreViewConfigKey) then
    return false
  end
  if actionId == Z.InputActionIds.ExitUI then
    return false
  end
  return true
end

function UIManager:HasFocusView(ignoreViewConfigKeyDict)
  local focusViewConfigKey = self:GetFocusViewConfigKey()
  if focusViewConfigKey == nil or focusViewConfigKey == Z.ConstValue.MainViewName then
    return false
  end
  if ignoreViewConfigKeyDict and ignoreViewConfigKeyDict[focusViewConfigKey] then
    return false
  end
  return true
end

function UIManager:AddShowMouseView(viewConfigKey)
  if viewConfigKey == nil then
    return
  end
  self.showMouseView_[viewConfigKey] = true
  self:UpdateMouseVisible()
end

function UIManager:RemoveShowMouseView(viewConfigKey)
  self.showMouseView_[viewConfigKey] = nil
  self:UpdateMouseVisible()
end

function UIManager:UpdateMouseVisible()
  if table.zcount(self.showMouseView_) > 0 then
    Z.MouseMgr:SetMouseVisibleSource(Panda.ZInput.EMouseLockSource.UI, true)
    return
  end
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    local view = self:GetView(viewConfigKey)
    if view and view.IsActive and view.IsVisible and view.ViewConfig.ShowMouse then
      Z.MouseMgr:SetMouseVisibleSource(Panda.ZInput.EMouseLockSource.UI, true)
      return
    end
  end
  Z.MouseMgr:SetMouseVisibleSource(Panda.ZInput.EMouseLockSource.UI, false)
end

local Enum_EUIView

function UIManager:SetUIViewInputIgnore(viewConfigKey, maskNum, isIgnore)
  if Enum_EUIView == nil then
    Enum_EUIView = Panda.ZGame.EIgnoreMaskSource.EUIView:ToInt()
  end
  if viewConfigKey == nil then
    logError("[UIManager:SetUIViewInputIgnore] viewConfigKey is nil!")
    return
  end
  local dict = self.IgnoreInputViewDict
  dict[viewConfigKey] = (dict[viewConfigKey] or 0) + (isIgnore and 1 or -1)
  Z.IgnoreMgr:SetInputIgnore(maskNum, isIgnore, Enum_EUIView)
end

function UIManager:GetUIViewInputIgnore(viewConfigKey)
  return self.IgnoreInputViewDict[viewConfigKey] or 0
end

function UIManager:GetAllActiveViewNames()
  local activeViewNames = {}
  for i, viewConfigKey in ipairs(self.allOpenViewList_) do
    local view = self:GetView(viewConfigKey)
    table.insert(activeViewNames, viewConfigKey)
  end
  return table.concat(activeViewNames, "\n")
end

return UIManager
