local UI = Z.UI
local super = require("ui.ui_view_base")
local Planetmemory_mainView = class("Planetmemory_mainView", super)
local planetmemoryVm = Z.VMMgr.GetVM("planetmemory")
local planetmemoryData = Z.DataMgr.Get("planetmemory_data")
local node_detailsView = require("ui.view.planetmemory.planetmemory_node_details_view")
local helpsysVM = Z.VMMgr.GetVM("helpsys")

function Planetmemory_mainView:ctor()
  self.uiBinder = nil
  super.ctor(self, "planetmemory_main")
  self.clickedPlanememoryNode = nil
end

E.PlanetMemoryCameraAnimType = {
  Enter = "enter",
  Move = "move",
  Wait = "wait"
}

function Planetmemory_mainView:OnActive()
  self:initComp()
  self:startAnimatedShow()
  Z.PlayerInputController.IsCheckZoomClickingUI = false
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, true)
  self:createSubView()
  self:initVariable()
  self:initListener()
  self:refUnrealScene()
  self:loadFogEffect()
  self:setUnrealSceneData()
  Z.AudioMgr:Play("pause_scene_all")
  self.menu_bgm = Z.AudioMgr:Play("bgm_sys_dmg")
end

function Planetmemory_mainView:setUnrealSceneData()
  Z.UnrealSceneMgr:InitSceneCamera()
  Z.UnrealSceneMgr:SetLimitLookAtEnable(true)
  local SceneZoom = Z.PlanetMemorySeasonConfig.SceneZoom
  Z.UnrealSceneMgr:SetUnrealSceneCameraZoomRange(SceneZoom.x, SceneZoom.y)
  Z.UnrealSceneMgr:SetCameraLookAtEnable(true)
end

function Planetmemory_mainView:createSubView()
  self.nodeDetailsView_ = node_detailsView.new(self)
end

function Planetmemory_mainView:deActiveAllSubView()
  self.nodeDetailsView_:DeActive()
end

function Planetmemory_mainView:initVariable()
  self.planetmemoryId_ = -1
  self.planetmemoryCfg_ = {}
  self.planetModels_ = {}
  self.lineModels_ = {}
  self.rewardUnits_ = {}
  self.fogPrefab_ = {}
  self.timePanel = nil
  self.createCount_ = 0
  self.lookAtMinX_ = 0
  self.lookAtMaxX_ = 0
  self.lookAtMaxY_ = 0
  self.lookAtMinY_ = 0
  self.timeUiUnit = nil
  self.zList_ = ZUtil.Pool.Collections.ZList_UnityEngine_Vector3.Rent()
  planetmemoryVm.InitPlanetMenoryState()
  self.PlanetMemoryTableMgr_ = Z.TableMgr.GetTable("PlanetMemoryTableMgr")
  self.PlanetMemoryNodeState_ = planetmemoryData:GetPlanetMemoryState()
  self.planetMemoryFogUnlockedState_ = planetmemoryData:GetPlanetMemoryFogUnlockedState()
end

function Planetmemory_mainView:initComp()
  self.closeAllBtn_ = self.uiBinder.cont_title_return.cont_btn_return.btn
  self.planetmemoryNameLab_ = self.uiBinder.cont_title_return.lab_title
  self.planetmemoryBtn_ = self.uiBinder.btn_planetmemory
  self.unrealsceneTrigger_ = self.uiBinder.rayimg_unrealscene_drag
  self.planetInfoView_ = self.uiBinder.group_content
  self.askBtn_ = self.uiBinder.cont_title_return.btn_ask
  self.node_time_tips = self.uiBinder.node_time_tips
  self.redpoint_node_ = self.uiBinder.node_dot
  self.anim = self.uiBinder.anim_main
end

function Planetmemory_mainView:onCloseBtnClick()
  Z.UIMgr:CloseView("planetmemory_main")
end

function Planetmemory_mainView:onAskBtnClick()
  helpsysVM.OpenFullScreenTipsView(30030)
end

function Planetmemory_mainView:onPlanetMemoryClick()
  Z.UIMgr:OpenView("planetmemory_popup")
end

function Planetmemory_mainView:onUnrealsceneBeginDrag(eventData)
end

function Planetmemory_mainView:onUnrealsceneDrag(eventData)
  Z.UnrealSceneMgr:updateLookAt(eventData.delta * 0.005)
end

function Planetmemory_mainView:onUnrealsceneEndDrag(eventData)
end

function Planetmemory_mainView:initListener()
  self:AddClick(self.closeAllBtn_, function()
    self:onCloseBtnClick()
  end)
  self:AddClick(self.planetmemoryBtn_, function()
    self:onPlanetMemoryClick()
  end)
  self:AddClick(self.unrealsceneTrigger_.onBeginDrag, function(go, eventData)
    self:onUnrealsceneBeginDrag(eventData)
  end)
  self:AddClick(self.unrealsceneTrigger_.onDrag, function(go, eventData)
    self:onUnrealsceneDrag(eventData)
  end)
  self:AddClick(self.unrealsceneTrigger_.onEndDrag, function(go, eventData)
    self:onUnrealsceneEndDrag(eventData)
  end)
  self:AddClick(self.askBtn_, function()
    self:onAskBtnClick()
  end)
end

function Planetmemory_mainView:refMainViewInfo(id, animType)
  self.planetmemoryCfg_ = self.PlanetMemoryTableMgr_.GetRow(id, false)
  if self.planetmemoryCfg_ == nil then
    return
  end
  if self.planetmemoryId_ ~= id then
    self:SetAnimation(animType)
  end
  if animType == E.PlanetMemoryCameraAnimType.Move then
    self.planetmemoryId_ = id
    self:OnClickShowBreakEffect(id)
    local viewData = {}
    viewData.PlanetMemoryId = self.planetmemoryId_
    viewData.PlanetmemoryCfg_ = self.planetmemoryCfg_
    self.nodeDetailsView_:Active(viewData, self.planetInfoView_)
  end
end

function Planetmemory_mainView:OnClickShowBreakEffect(roomId)
  local zPlanetmemoryModelInfo
  if self.clickedPlanememoryNode then
    zPlanetmemoryModelInfo = Panda.ZUi.ZPlanetmemoryModelInfo.GetZPlanetmemoryModelInfoComp(self.planetModels_[self.clickedPlanememoryNode])
    if not zPlanetmemoryModelInfo then
      return
    end
    zPlanetmemoryModelInfo:SetBreakEffectGoActive(false)
  end
  zPlanetmemoryModelInfo = Panda.ZUi.ZPlanetmemoryModelInfo.GetZPlanetmemoryModelInfoComp(self.planetModels_[roomId])
  if not zPlanetmemoryModelInfo then
    return
  end
  zPlanetmemoryModelInfo:SetBreakEffectGoActive(true)
  self.clickedPlanememoryNode = roomId
end

function Planetmemory_mainView:SetAnimation(animType)
  local pos = Vector3.New(self.planetmemoryCfg_.RoomPos[1], self.planetmemoryCfg_.RoomPos[2], self.planetmemoryCfg_.RoomPos[3])
  if self.planetmemoryCfg_.RoomId == 1 then
    pos = pos + Z.PlanetMemorySeasonConfig.FirstRoomCamOffset
  end
  if animType == E.PlanetMemoryCameraAnimType.Wait then
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(animType)
    self.timerMgr:StartTimer(function()
      Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(E.PlanetMemoryCameraAnimType.Enter, pos)
    end, 1.6, 1)
  else
    Z.UnrealSceneMgr:DoCameraAnimLookAtOffset(animType, pos)
  end
end

function Planetmemory_mainView:createPlanetItem(cfg)
  if self.planetModels_[cfg.RoomId] then
    return
  end
  local unLockRooms = cfg.UnlockRoomId
  local model = planetmemoryVm.GetPlanetItemModelId(cfg.RoomId, cfg.RoomType)
  local path = planetmemoryVm.GetPlanetMemoryNodeAssetPath(model)
  local modelCfg = planetmemoryVm.GetModelConfigById(model)
  local seasonConfig = planetmemoryData:GetMonsterIconPath(cfg.RoomType, Z.PlanetMemorySeasonConfig.RoomTypeBallIcon)
  if not (model and path and modelCfg and self.PlanetMemoryNodeState_) or not seasonConfig then
    return
  end
  self.planetModels_[cfg.RoomId] = Z.UnrealSceneMgr:LoadScenePrefab(path, nil, Vector3.New(cfg.RoomPos[1], cfg.RoomPos[2], cfg.RoomPos[3]), self.cancelSource:CreateToken(), function()
    self:onModelLoadFinish()
  end)
  if cfg.RoomPos[1] > self.lookAtMaxX_ then
    self.lookAtMaxX_ = cfg.RoomPos[1]
  end
  if cfg.RoomPos[1] < self.lookAtMinX_ then
    self.lookAtMinX_ = cfg.RoomPos[1]
  end
  if cfg.RoomPos[2] > self.lookAtMaxY_ then
    self.lookAtMaxY_ = cfg.RoomPos[2]
  end
  if cfg.RoomPos[2] < self.lookAtMinY_ then
    self.lookAtMinY_ = cfg.RoomPos[2]
  end
  local zPlanetmemoryModelInfo = Panda.ZUi.ZPlanetmemoryModelInfo.GetZPlanetmemoryModelInfoComp(self.planetModels_[cfg.RoomId])
  if not zPlanetmemoryModelInfo then
    return
  end
  local colliderScale = modelCfg.GoData[1]
  zPlanetmemoryModelInfo:SetInfoId(cfg.RoomId)
  zPlanetmemoryModelInfo:SetGrayWeight(0)
  zPlanetmemoryModelInfo:SetIconColor(Color.New(1.3, 1.3, 1.3, 1))
  zPlanetmemoryModelInfo:SetColliderRadius(colliderScale)
  zPlanetmemoryModelInfo:SetIcon(seasonConfig)
  if self.planetMemoryFogUnlockedState_ and self.planetMemoryFogUnlockedState_[cfg.RoomId] == E.PlanetmemoryFogState.Unlocked then
    zPlanetmemoryModelInfo:OpenFog(true)
    zPlanetmemoryModelInfo:SetVirMaskRange(35)
    zPlanetmemoryModelInfo:AddListener(function(roomId)
      self:planetMemoryNodeClick(roomId)
    end)
  end
  zPlanetmemoryModelInfo:SetTransLocalScaleAnim(Vector3.New(modelCfg.ModelScale, modelCfg.ModelScale, modelCfg.ModelScale), 0)
  if unLockRooms and next(unLockRooms) then
    for _, value in pairs(unLockRooms) do
      local fristItem = self.PlanetMemoryTableMgr_.GetRow(value)
      if not fristItem then
        return
      end
      self:createLineItem(cfg, fristItem)
      self:createPlanetItem(fristItem)
    end
  end
end

function Planetmemory_mainView:onModelLoadFinish()
  self.createCount_ = self.createCount_ + 1
  local planetMemoryTableDatas = self.PlanetMemoryTableMgr_.GetDatas()
  if self.createCount_ >= #planetMemoryTableDatas then
    Z.UIMgr:FadeOut()
  end
end

function Planetmemory_mainView:createLineItem(currentConfig, nextConfig)
  if not currentConfig or not nextConfig then
    return
  end
  local startPos = Z.UnrealSceneMgr:GetTransPos("pos") + Vector3.New(currentConfig.RoomPos[1], currentConfig.RoomPos[2], currentConfig.RoomPos[3])
  local endPos = Z.UnrealSceneMgr:GetTransPos("pos") + Vector3.New(nextConfig.RoomPos[1], nextConfig.RoomPos[2], nextConfig.RoomPos[3])
  local lineModelConfig = currentConfig.LinkModel
  if not (startPos and endPos and self.PlanetMemoryNodeState_ and lineModelConfig) or not next(lineModelConfig) then
    return
  end
  local lineModelID
  local lineRadius = 0.08
  local lineRadiusTable = Z.PlanetMemorySeasonConfig.LinkModelRadius
  if self.PlanetMemoryNodeState_[nextConfig.RoomId] == E.PlanetmemoryState.Pass or self.PlanetMemoryNodeState_[nextConfig.RoomId] == E.PlanetmemoryState.Open then
    lineModelID = lineModelConfig[1]
    lineRadius = lineRadiusTable.x
  else
    lineModelID = lineModelConfig[2]
    lineRadius = lineRadiusTable.y
  end
  local linePath = planetmemoryVm.GetPlanetMemoryNodeAssetPath(lineModelID)
  if not linePath then
    return
  end
  local pattern = "effect/"
  linePath = string.gsub(linePath, pattern, "")
  self.zList_:Clear()
  self.lineModels_[#self.lineModels_ + 1] = Z.UnrealSceneMgr:CreatEffectByMoreParam(linePath, Vector3.zero, Vector3.one, Vector3.zero, -1)
  Z.UnrealSceneMgr:SetEffectVisible(self.lineModels_[#self.lineModels_], true)
  self.zList_:Add(startPos)
  self.zList_:Add(endPos)
  Panda.ZEffect.ZEffectManager.Instance:SetLinePos(self.lineModels_[#self.lineModels_], self.zList_)
  Panda.ZEffect.ZEffectManager.Instance:SetLineRadius(self.lineModels_[#self.lineModels_], lineRadius)
end

function Planetmemory_mainView:loadFogEffect()
  local smokePosition = Z.PlanetMemorySeasonConfig.SmokePosition
  local smokeModelConfig = Z.PlanetMemorySeasonConfig.SmokeModel
  if not smokePosition or not smokeModelConfig then
    return
  end
  local fogPath = planetmemoryVm.GetPlanetMemoryNodeAssetPath(smokeModelConfig)
  if not fogPath then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self.fogPrefab_ = Z.UnrealSceneMgr:LoadScenePrefab(fogPath, nil, smokePosition, self.cancelSource:CreateToken())
  end)()
end

function Planetmemory_mainView:planetMemoryNodeClick(roomId)
  if roomId then
    self:refMainViewInfo(roomId, E.PlanetMemoryCameraAnimType.Move)
  end
end

function Planetmemory_mainView:refUnrealScene()
  local fristItem = self.PlanetMemoryTableMgr_.GetRow(1)
  if not fristItem then
    return
  end
  Z.CoroUtil.create_coro_xpcall(function()
    self:createPlanetItem(fristItem)
    Z.UnrealSceneMgr:SetLookAtLimitBounds(Vector4.New(self.lookAtMinX_, self.lookAtMaxX_, self.lookAtMinY_, self.lookAtMaxY_))
  end)()
end

function Planetmemory_mainView:createTimeUI()
  local unlockRoomId
  for k, v in pairs(self.planetMemoryFogUnlockedState_) do
    if v == E.PlanetmemoryFogState.NotYetUnlocked then
      unlockRoomId = k
      break
    end
  end
  if not unlockRoomId then
    return
  end
  local timeData = planetmemoryVm.GetPlanetMemoryUnlockTime(unlockRoomId)
  if not timeData then
    return
  end
  if self.timeUiUnit then
    self:setTimeData(timeData)
  else
    local path = self:GetPrefabCacheDataNew(self.uiBinder.prefabcache_root, "timeTips")
    Z.CoroUtil.create_coro_xpcall(function()
      local name = string.format("timeUi")
      self.timeUiUnit = self:AsyncLoadUiUnit(path, name, self.node_time_tips, self.cancelSource:CreateToken())
      self:setTimeData(timeData)
    end)()
  end
end

function Planetmemory_mainView:setTimeData(timeData)
  if not self.timeUiUnit or not timeData then
    return
  end
  self.timeUiUnit.lab_time.text = timeData
end

function Planetmemory_mainView:OnDeActive()
  self.zList_:Recycle()
  self.createCount_ = 0
  self.planetMemoryFogUnlockedState_ = nil
  self.PlanetMemoryNodeState_ = nil
  Z.PlayerInputController.IsCheckZoomClickingUI = true
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967293, false)
  Z.UnrealSceneMgr:RestUnrealSceneCameraZoomRange(false)
  Z.UnrealSceneMgr:SetCameraLookAtEnable(false)
  Z.UnrealSceneMgr:SetLimitLookAtEnable(false)
  self:deActiveAllSubView()
  self:ClearAllUnits()
  Z.AudioMgr:Play("resume_scene_all")
  if self.menu_bgm ~= nil and self.menu_bgm ~= 0 then
    Z.AudioMgr:StopPlayingEvent(self.menu_bgm)
  end
end

function Planetmemory_mainView:OnRefresh()
  planetmemoryData:SetPlanetMemoryIsContinue(false)
  local currentInfo = planetmemoryVm.GetLastFinishedPlanetmemoryInfo()
  if not currentInfo then
    return
  end
  self:refMainViewInfo(currentInfo.RoomId, E.PlanetMemoryCameraAnimType.Wait)
  self:createTimeUI()
end

function Planetmemory_mainView:startAnimatedShow()
  self.anim:Restart(Z.DOTweenAnimType.Open)
end

function Planetmemory_mainView:startAnimatedHide()
  local coro = Z.CoroUtil.async_to_sync(self.anim.CoroPlay)
  coro(self.anim, Z.DOTweenAnimType.Close)
end

function Planetmemory_mainView:CustomClose()
end

function Planetmemory_mainView:OnDestory()
  Z.UnrealSceneMgr:CloseUnrealScene("planetmemory_main")
end

return Planetmemory_mainView
