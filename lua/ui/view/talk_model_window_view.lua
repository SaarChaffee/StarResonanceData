local UI = Z.UI
local super = require("ui.ui_view_base")
local Talk_model_windowView = class("Talk_model_windowView", super)
local ESpeakerPos = {
  Left = 0,
  MiddleLeft = 1,
  Right = 2,
  MiddleRight = 3,
  Focus = 10
}
local ELookAtType = {Character = 0, Position = 1}
local ECameraChangeType = {
  Keep = 0,
  Default = 1,
  Change = 2
}
local EModelDialogueType = {
  ChangeAll = 0,
  HoldAll = 1,
  ChangeSpeaker = 2,
  ChangeLookAt = 3
}

function Talk_model_windowView:ctor()
  self.uiBinder = nil
  super.ctor(self, "talk_model_window")
  self.talkVM_ = Z.VMMgr.GetVM("talk")
  self.talkData_ = Z.DataMgr.Get("talk_data")
  self.settingVM_ = Z.VMMgr.GetVM("setting")
  self.talkOptionVM_ = Z.VMMgr.GetVM("talk_option")
end

function Talk_model_windowView:IsTalkAllowClick()
  return self.isShowFinished_
end

function Talk_model_windowView:OnActive()
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, true)
  self.modelDict_ = {}
  self.curSpeakerPosDict_ = {}
  self.lastSpeakerPosDict_ = {}
  self.isInit_ = false
  self.changeType_ = self.viewData.DialogChangeType
  self.isShowFinished_ = false
  local hairMagnification = Z.Global.TalkModelOutlineMagnificationHair
  local headMagnification = Z.Global.TalkModelOutlineMagnificationHead
  local bodyMagnification = Z.Global.TalkModelOutlineMagnificationBody
  self.modelOutlineMagnificationHair_ = Z.IsPCUI and hairMagnification[2] or hairMagnification[1]
  self.modelOutlineMagnificationHead_ = Z.IsPCUI and headMagnification[2] or headMagnification[1]
  self.modelOutlineMagnificationBody_ = Z.IsPCUI and bodyMagnification[2] or bodyMagnification[1]
  self.modelTalkComp_ = self.uiBinder.node_model
end

function Talk_model_windowView:OnRefresh()
  self.changeType_ = self.viewData.DialogChangeType
  self.isShowFinished_ = false
  if self:isChangeSpeaker() then
    self.curSpeakerPosDict_ = {}
    for _, data in ipairs(self.viewData.SpeakerList) do
      self.curSpeakerPosDict_[data.SpeakerPosId] = data.SpeakerId
    end
  end
  Z.CoroUtil.create_coro_xpcall(function()
    if not self.isInit_ then
      self:asyncInit()
    end
    self:loadSpeakerModel()
    if not self.IsActive then
      return
    end
    local isNeedWaitExit = self:oldSpeakerExit()
    if isNeedWaitExit then
      local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
      local fadeTime = tonumber(self:GetPrefabCacheData("FadeOutTime")) or 0
      coro(fadeTime, self.cancelSource:CreateToken())
    end
    self:refreshCameraTrans()
    self:disableModelDynamicBone()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.LastUpdate, self.cancelSource:CreateToken())
    self:refreshSpeakerModelBeforeEnter()
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.LastUpdate, self.cancelSource:CreateToken())
    local isNeedWaitEnter = self:newSpeakerEnter()
    if isNeedWaitEnter then
      local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayForLua)
      local fadeTime = tonumber(self:GetPrefabCacheData("FadeInTime")) or 0
      coro(fadeTime, self.cancelSource:CreateToken())
    end
    self:refreshSpeakerModelAfterEnter()
    local dialogData = self.viewData.DialogData
    dialogData.ParentView = self
    self.talkVM_.OpenCommonTalkDialog(dialogData)
    self:refreshLipAnim(dialogData)
    self.lastSpeakerPosDict_ = table.zclone(self.curSpeakerPosDict_)
    self.isShowFinished_ = true
  end)()
end

function Talk_model_windowView:OnDeActive()
  Z.SceneMaskMgr:ClearSceneMaskTexture(self.viewConfigKey)
  Z.UIMgr:SetUIViewInputIgnore(self.viewConfigKey, 4294967295, false)
  self.lastSpeakerPosDict_ = nil
  for _, model in pairs(self.modelDict_) do
    model.RenderComp:SetGlobalOutLineMagnification(1, Z.ModelRenderMask.Hair)
    model.RenderComp:SetGlobalOutLineMagnification(1, Z.ModelRenderMask.HEAD)
    model.RenderComp:SetGlobalOutLineMagnification(1, Z.ModelRenderMask.BODY)
  end
  self.modelDict_ = nil
  self.isInit_ = nil
  self.isShowFinished_ = nil
  self.changeType_ = nil
  self.modelOutlineMagnificationHair_ = nil
  self.modelOutlineMagnificationHead_ = nil
  self.modelOutlineMagnificationBody_ = nil
  Z.EventMgr:RemoveObjAll(self)
  self.modelTalkComp_:UnInit()
end

function Talk_model_windowView:asyncInit()
  self.modelTalkComp_:Init()
  local coro = Z.CoroUtil.async_to_sync(self.modelTalkComp_.AsyncInit)
  coro(self.modelTalkComp_)
  self:loadSpeakerModel()
  self:asyncCaptureScreen()
  self.isInit_ = true
end

function Talk_model_windowView:disableModelDynamicBone()
  local isChangeSpeaker = self:isChangeSpeaker()
  for _, data in ipairs(self.viewData.SpeakerList) do
    local speakerId = self.curSpeakerPosDict_[data.SpeakerPosId]
    local model = self.modelDict_[speakerId]
    if model then
      if isChangeSpeaker then
        model:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, false)
      end
      self:setModelAction(model, data.ActionList, speakerId == 0)
      self:setModelIdleAnim(model, data.IdleAnimation)
      self:setModelEmotion(model, data.NewEmotionId)
    end
  end
end

function Talk_model_windowView:refreshSpeakerModelBeforeEnter()
  local isChangeSpeaker = self:isChangeSpeaker()
  for _, data in ipairs(self.viewData.SpeakerList) do
    local speakerId = self.curSpeakerPosDict_[data.SpeakerPosId]
    local model = self.modelDict_[speakerId]
    if model then
      if isChangeSpeaker then
        self:setModelStencil(model, data)
        self:setModelPos(model, data)
        self:setModelRotation(model, data)
      end
      self:setModelLookAt(model, data)
    end
  end
end

function Talk_model_windowView:refreshSpeakerModelAfterEnter()
  local isChangeSpeaker = self:isChangeSpeaker()
  for _, data in ipairs(self.viewData.SpeakerList) do
    local speakerId = self.curSpeakerPosDict_[data.SpeakerPosId]
    local model = self.modelDict_[speakerId]
    if model and isChangeSpeaker then
      model:SetLuaAttr(Z.ModelAttr.EModelDynamicBoneEnabled, true)
    end
  end
end

function Talk_model_windowView:setModelStencil(model, data)
  local posType = data.SpeakerPosId
  local refValue
  local tagValue = data.SpeakerPosId
  if posType == ESpeakerPos.MiddleLeft or posType == ESpeakerPos.MiddleRight then
    refValue = 9
  else
    refValue = 10
  end
  model:SetLuaAttr(Z.ModelAttr.EModelMatStencil, Vector3.New(refValue, 7, tagValue))
end

function Talk_model_windowView:setModelPos(model, data)
  self.modelTalkComp_:SetModelPos(model, data.SpeakerPosId, Vector3.New(data.SpeakerPosOffset, data.SpeakerHeightOffset, 0), data.SpeakerPosFade, self.cancelSource:CreateToken())
end

function Talk_model_windowView:setModelRotation(model, data)
  self.modelTalkComp_:SetModelRotation(model, data.SpeakerPosId)
end

function Talk_model_windowView:setModelLookAt(model, data)
  if self.changeType_ ~= EModelDialogueType.ChangeAll and self.changeType_ ~= EModelDialogueType.ChangeLookAt then
    return
  end
  local lookAtType = data.LookAtType
  if lookAtType == ELookAtType.Character then
    local targetData = self.viewData.SpeakerList[data.LookAtSpeakerIndex]
    if targetData then
      local index = 0
      if targetData.SpeakerPosId > data.SpeakerPosId then
        index = 3 * data.SpeakerPosId + targetData.SpeakerPosId - 1
      else
        index = 3 * data.SpeakerPosId + targetData.SpeakerPosId
      end
      model:SetLuaIntAttr(Z.ModelAttr.EModelDialogueLookAtPos, index)
      local targetSpeakerId = self.curSpeakerPosDict_[targetData.SpeakerPosId]
      local targetModel = self.modelDict_[targetSpeakerId]
      Z.ModelHelper.SetLookAtModel(model, targetModel.ModelUuid, data.LookAtPointName)
    end
  elseif lookAtType == ELookAtType.Position then
    local pos = data.LookAtPos
    Z.ModelHelper.SetLookAtPos(model, Vector3.New(-pos.x, pos.y, pos.z))
  end
end

function Talk_model_windowView:setModelAction(model, actionList, isPlayer)
  if 0 < #actionList then
    local clipNames = ZUtil.Pool.Collections.ZList_string.Rent()
    for _, name in ipairs(actionList) do
      clipNames:Add(name)
    end
    model:SetLuaAnimBase(Z.AnimBaseData.Rent(clipNames, 0.2, -1, nil, true, isPlayer))
    clipNames:Recycle()
  else
    model:SetLuaAnimBase(Z.AnimBaseData.Rent(Panda.ZAnim.EAnimBase.EIdle))
  end
end

function Talk_model_windowView:setModelIdleAnim(model, anim)
  if anim and anim ~= "" then
    local clip = anim
    local data = Z.AnimBaseData.Rent(clip, Panda.ZAnim.EAnimBase.EIdle)
    model:SetLuaAttr(Z.ModelAttr.EModelAnimOverrideByName, data)
  end
end

function Talk_model_windowView:setModelEmotion(model, emotionId)
  if 0 < emotionId then
    model:SetLuaAttrEmoteInfo(emotionId, -1, true, false, 0, false, true)
  else
    model:SetLuaAttrEmoteInfo(0)
  end
end

function Talk_model_windowView:loadSpeakerModel()
  if not self:isChangeSpeaker() then
    return
  end
  for _, data in ipairs(self.viewData.SpeakerList) do
    local speakerId = data.SpeakerId
    local model = self.modelDict_[speakerId]
    if not model then
      local preFunc = function(model)
        model:SetLuaAttr(Z.ModelAttr.EInModelTalk, true)
        self:setModelIdleAnim(model, data.IdleAnimation)
      end
      if speakerId == 0 then
        local coro = Z.CoroUtil.async_to_sync(self.modelTalkComp_.CloneModelByLua)
        model = coro(self.modelTalkComp_, Z.EntityMgr.PlayerEnt.Model, preFunc)
        if not self.IsActive then
          return
        end
        if model then
          model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponL, "")
          model:SetLuaAttr(Z.ModelAttr.EModelCMountWeaponR, "")
        end
      else
        local npcRow = Z.TableMgr.GetTable("NpcTableMgr").GetRow(speakerId)
        if npcRow then
          local coro = Z.CoroUtil.async_to_sync(self.modelTalkComp_.GenModelByLua)
          model = coro(self.modelTalkComp_, npcRow.ModelID, preFunc)
          if not self.IsActive then
            return
          end
        end
      end
      if model then
        Z.ModelHelper.SetAlpha(model, Z.ModelRenderMask.All, 0, Panda.ZGame.EModelAlphaSourceType.EDisappear, false)
        if model.RenderComp then
          model.RenderComp:SetGlobalOutLineMagnification(self.modelOutlineMagnificationHair_, Z.ModelRenderMask.Hair)
          model.RenderComp:SetGlobalOutLineMagnification(self.modelOutlineMagnificationHead_, Z.ModelRenderMask.HEAD)
          model.RenderComp:SetGlobalOutLineMagnification(self.modelOutlineMagnificationBody_, Z.ModelRenderMask.BODY)
        end
        self.modelDict_[speakerId] = model
      end
    end
  end
end

function Talk_model_windowView:oldSpeakerExit()
  if not self:isChangeSpeaker() then
    return false
  end
  local isNeedWaitExit = false
  for posId, speakerId in pairs(self.lastSpeakerPosDict_) do
    local isPosChanged = true
    for _, data in ipairs(self.viewData.SpeakerList) do
      if data.SpeakerId == speakerId and data.SpeakerPosId == posId then
        isPosChanged = false
        break
      end
    end
    if isPosChanged then
      local isInstant = posId >= ESpeakerPos.Focus
      self:setModelFadeOut(self.modelDict_[speakerId], isInstant)
      if not isInstant then
        isNeedWaitExit = true
      end
    end
  end
  return isNeedWaitExit
end

function Talk_model_windowView:newSpeakerEnter()
  if not self:isChangeSpeaker() then
    return false
  end
  local isNeedWaitEnter = false
  for _, data in ipairs(self.viewData.SpeakerList) do
    local isEnter = false
    local oldSpeaker = self.lastSpeakerPosDict_[data.SpeakerPosId]
    if oldSpeaker then
      if oldSpeaker ~= data.SpeakerId then
        isEnter = true
      end
    else
      isEnter = true
    end
    if isEnter then
      local model = self.modelDict_[data.SpeakerId]
      if data.SpeakerPosId < ESpeakerPos.Focus then
        self:setModelFadeIn(model)
        isNeedWaitEnter = true
      else
        self:setModelFadeIn(model, true)
      end
    end
  end
  return isNeedWaitEnter
end

function Talk_model_windowView:setModelFadeIn(model, isInstant)
  if not model then
    return
  end
  local startValue = 1
  local targetValue = 0
  local duration
  if isInstant then
    duration = 0
  else
    duration = tonumber(self:GetPrefabCacheData("FadeInTime")) or 0
  end
  model:SetLuaUIntAttr(Z.ModelAttr.EDisappearType, 1)
  model:SetLuaAttr(Z.ModelAttr.EModelDisappearData, Panda.ZGame.ModelDisappearData.New(startValue, targetValue, duration))
end

function Talk_model_windowView:setModelFadeOut(model, isInstant)
  if not model then
    return
  end
  local startValue = 0
  local targetValue = 1
  local duration
  if isInstant then
    duration = 0
  else
    duration = tonumber(self:GetPrefabCacheData("FadeOutTime")) or 0
  end
  model:SetLuaUIntAttr(Z.ModelAttr.EDisappearType, 1)
  model:SetLuaAttr(Z.ModelAttr.EModelDisappearData, Panda.ZGame.ModelDisappearData.New(startValue, targetValue, duration))
end

function Talk_model_windowView:refreshLipAnim(dialogData)
  for _, model in pairs(self.modelDict_) do
    model:SetLuaAttrLipData()
  end
  if dialogData.IsDisableLip then
    return
  end
  local temp = {}
  for _, npcId in pairs(dialogData.NpcIdList) do
    local model = self.modelDict_[npcId]
    if model and not temp[npcId] then
      temp[npcId] = true
      local audioPath = dialogData.AudioPath
      if audioPath and audioPath ~= "" then
        model:SetLuaAttrLipData(0, audioPath)
      else
        local content = self:getContentStr(dialogData.Content)
        local time = math.max(string.zlenNormalize(content) / 20, 0.5) * 2
        model:SetLuaAttrLipData(time)
      end
    end
  end
end

function Talk_model_windowView:getContentStr(content)
  local mContent = self.talkVM_.HandlePlaceholderStr(content)
  local noRichStr = string.gsub(mContent, "%b<>", "")
  return noRichStr
end

function Talk_model_windowView:refreshCameraTrans()
  local changeType = self.viewData.CameraChangeType
  if changeType == ECameraChangeType.Keep then
    return
  end
  if changeType == ECameraChangeType.Default then
    self.modelTalkComp_:ResetCameraTrans()
  elseif changeType == ECameraChangeType.Change then
    self.modelTalkComp_:SetCameraTrans(self.viewData.CameraPos, Quaternion.Euler(self.viewData.CameraRotEuler))
  else
    logError("[ModelTalk] \230\156\170\230\148\175\230\140\129\231\154\132CameraChangeType = {0}", changeType)
  end
  Z.SceneMaskMgr:ClearSceneMaskTexture(self.viewConfigKey)
  self:asyncCaptureScreen()
end

function Talk_model_windowView:asyncCaptureScreen()
  self.modelTalkComp_:SetTalkCameraParamActive(false)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
  coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
  self.modelTalkComp_:SetTalkCullingMaskActive(false)
  Z.CameraMgr:RefreshCameraCullingMask(false, false)
  self.isCaptureScreenCompleted_ = false
  self.uiBinder.scenemask:CustomCaptureScreen(self.viewConfigKey, true, function(texture)
    self:onCaptureScreenCompleted()
  end)
  while not self.isCaptureScreenCompleted_ do
    if not self.IsActive then
      logError("[ModelTalk] \230\136\170\229\155\190\230\151\182\229\133\179\233\151\173\231\149\140\233\157\162")
      return
    end
    local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
    coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
  end
  Z.UIMgr:UpdateCameraState()
  self.modelTalkComp_:SetTalkCullingMaskActive(true)
  self.modelTalkComp_:SetTalkCameraParamActive(true)
  local coro = Z.CoroUtil.async_to_sync(Z.ZTaskUtils.DelayFrameForLua)
  coro(1, Z.PlayerLoopTiming.Update, self.cancelSource:CreateToken())
end

function Talk_model_windowView:onCaptureScreenCompleted()
  self.isCaptureScreenCompleted_ = true
end

function Talk_model_windowView:isChangeSpeaker()
  return self.changeType_ == EModelDialogueType.ChangeAll or self.changeType_ == EModelDialogueType.ChangeSpeaker
end

return Talk_model_windowView
