local cjson = require("cjson")
local UNREAL_SCENE_CONFIG_PATH = "unrealscene/unrealsceneconfig_take_photo"
local CLOUD_FACE_UNREAL_CONFIG_PATH = "unrealscene/unrealsceneconfig_cloud_face"
local setTopTagIndex = function(index)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  if camerasysData:GetTagIndex().TopTagIndex ~= index then
    camerasysData:SetTopTagIndex(index)
  end
end
local setNodeTagIndex = function(index)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  camerasysData:SetNodeTagIndex(index)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.UpdateSettingView, false)
end
local setDecorate = function(data)
  if data == nil or next(data) == nil then
    return
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.DecorateSet, data)
end
local getRangeValue = function(value, data)
  if data == nil or next(data) == nil then
    return 0
  end
  return value * (data.max - data.min) + data.min
end
local getRangePerc = function(data, isdefine)
  if data == nil or next(data) == nil then
    return 0
  end
  local value
  if isdefine then
    value = data.define
  else
    value = data.value
  end
  return (value - data.min) / (data.max - data.min)
end
local getRangeDefinePerc = function(data)
  if data == nil or next(data) == nil then
    return 0
  end
  return (data.define - data.min) / (data.max - data.min)
end
local getRangePercEX = function(value, data)
  if data == nil or next(data) == nil then
    return 0
  end
  return (value - data.min) / (data.max - data.min)
end
local setShowState = function(index, state, mold, patternType)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  if mold == E.CamerasysContrShowType.Entity then
    camerasysData:SetShowEntityState(index, state, patternType)
  else
    camerasysData:SetShowUIState(index, state)
  end
end
local setHeadLookAt = function(isOn, model, isEyes)
  if not model then
    return
  end
  if isOn then
    local mainCamTrans = Z.CameraMgr.MainCamTrans
    if mainCamTrans then
      if isEyes then
        Z.ModelHelper.SetLookAtTransform(model, mainCamTrans, false, false)
      else
        Z.ModelHelper.SetLookAtIKParam(model, 1)
        model:SetLuaAttrLookAtHeadClose(false)
        Z.ModelHelper.SetLookAtTransform(model, mainCamTrans)
      end
    end
  else
    Z.ModelHelper.ResetLookAtIKParam(model)
    model:SetLuaAttrLookAtHeadClose(true)
    Z.ModelHelper.SetLookAtTransform(model, nil)
  end
end
local setEyesLookAt = function(isOn)
  if Z.EntityMgr.PlayerEnt then
    local playerModel = Z.EntityMgr.PlayerEnt.Model
    playerModel:SetLuaAttrLookAtEyeOpen(isOn)
  end
end
local getTempAlbumNumWithEnd = function(data)
  local number = 0
  local endData, endDKey
  if not data or not next(data) then
    return 0, nil, nil
  end
  for key, value in pairs(data) do
    number = number + 1
    if not endData then
      endData = value
      endDKey = key
    elseif endData.shotTime > value.shotTime then
      endData = value
      endDKey = key
    end
  end
  return number, endData, endDKey
end
local savePhotoToTempAlbum = function(oriId, effecId, thumbId)
  if not oriId or oriId <= 0 then
    return
  end
  local effectPhotoPath = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheEffectPhoto, effecId)
  local oriPhotoPath = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheOriPhoto, oriId)
  if not effectPhotoPath or not oriPhotoPath then
    return
  end
  if not thumbId or thumbId <= 0 then
    return
  end
  local thumbPath = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheThumbPhoto, thumbId)
  if not thumbPath then
    return
  end
  local album_main_data = Z.DataMgr.Get("album_main_data")
  Z.LsqLiteMgr.CreateTable("album_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local photoKey = string.format("%s%s%s", Z.EntityMgr.PlayerUuid, "photoInfo", Z.ServerTime:GetServerTime())
  local cachePhotoData = {}
  cachePhotoData.tempPhoto = effectPhotoPath
  cachePhotoData.tempOriPhoto = oriPhotoPath
  cachePhotoData.tempThumbPhoto = thumbPath
  cachePhotoData.shotTime = Z.ServerTime:GetServerTime()
  cachePhotoData.shotTimeStr = Z.CameraFrameCtrl:GetTextureCreateTime(effectPhotoPath)
  cachePhotoData.shotPlace = tostring(Z.StageMgr.GetCurrentSceneId())
  cachePhotoData.id = photoKey
  local mcData = Z.DataMgr.Get("decorate_add_data"):GetMoviescreenTempData()
  local mcStr = cjson.encode(mcData)
  cachePhotoData.decorateData = mcStr
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    tempPhotoCache = {}
    tempPhotoCache.tempPhotoCacheDict = {}
  end
  local number, endData, endKey = getTempAlbumNumWithEnd(tempPhotoCache.tempPhotoCacheDict)
  if number > album_main_data.TemporaryPhotoMaxNum - 1 then
    if not endData or not next(endData) then
      return
    end
    Z.VMMgr.GetVM("album_main").DeleteLocalPhoto(endData)
    tempPhotoCache.tempPhotoCacheDict[endKey] = nil
  end
  Z.DataMgr.Get("album_main_data"):AddTempPhotoData(photoKey, cachePhotoData)
  tempPhotoCache.tempPhotoCacheDict[photoKey] = cachePhotoData
  Z.LsqLiteMgr.UpdataData("album_info", "zproto.tempPhotoCache", roleKey, tempPhotoCache)
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.SaveLocalPhoto)
end
local saveCloudPhotoToTempAlbum = function(oriId, effectUrl, effectThumbUrl, decorateInfo)
  local oriPhotoPath = Z.CameraFrameCtrl:SaveToCacheAlbum(E.CachePhotoType.CacheOriPhoto, oriId, true)
  if not oriPhotoPath then
    return
  end
  local album_main_data = Z.DataMgr.Get("album_main_data")
  Z.LsqLiteMgr.CreateTable("album_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local photoKey = string.format("%s%s%s", Z.EntityMgr.PlayerUuid, "photoInfo", Z.ServerTime:GetServerTime())
  local cachePhotoData = {}
  cachePhotoData.tempPhoto = effectUrl
  cachePhotoData.tempOriPhoto = oriPhotoPath
  cachePhotoData.tempThumbPhoto = effectThumbUrl
  cachePhotoData.shotTime = Z.ServerTime:GetServerTime()
  cachePhotoData.shotTimeStr = Z.CameraFrameCtrl:GetTextureCreateTime(effectUrl)
  cachePhotoData.shotPlace = tostring(Z.StageMgr.GetCurrentSceneId())
  cachePhotoData.id = photoKey
  cachePhotoData.decorateData = decorateInfo
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    tempPhotoCache = {}
    tempPhotoCache.tempPhotoCacheDict = {}
  end
  local number, endData, endKey = getTempAlbumNumWithEnd(tempPhotoCache.tempPhotoCacheDict)
  if number > album_main_data.TemporaryPhotoMaxNum - 1 then
    if not endData or not next(endData) then
      return
    end
    Z.VMMgr.GetVM("album_main").DeleteLocalPhoto(endData)
    tempPhotoCache.tempPhotoCacheDict[endKey] = nil
  end
  Z.DataMgr.Get("album_main_data"):AddTempPhotoData(photoKey, cachePhotoData)
  tempPhotoCache.tempPhotoCacheDict[photoKey] = cachePhotoData
  Z.LsqLiteMgr.UpdataData("album_info", "zproto.tempPhotoCache", roleKey, tempPhotoCache)
end
local replaceCameraSchemeInfo = function(dataValue)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    cameraSchemeCache = {}
    cameraSchemeCache.cameraSchemeDict = {}
  end
  local curSchemeInfo = dataValue
  cameraSchemeCache.cameraSchemeDict[curSchemeInfo.schemeKey] = curSchemeInfo
  camerasysData:AddSchemeInfoDatas(curSchemeInfo.schemeKey, curSchemeInfo)
  Z.LsqLiteMgr.UpdataData("camera_scheme_info", "zproto.cameraSchemeCache", roleKey, cameraSchemeCache)
end
local saveCameraSchemeInfoEX = function(dataValue)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    cameraSchemeCache = {}
    cameraSchemeCache.cameraSchemeDict = {}
  end
  local curSchemeInfo = dataValue
  curSchemeInfo.schemeName = camerasysData.CameraSchemeSelectInfo.schemeName
  curSchemeInfo.schemeTime = camerasysData.CameraSchemeSelectInfo.schemeTime
  cameraSchemeCache.cameraSchemeDict[camerasysData.CameraSchemeSelectInfo.schemeKey] = nil
  cameraSchemeCache.cameraSchemeDict[curSchemeInfo.schemeKey] = curSchemeInfo
  camerasysData:AddSchemeInfoDatas(camerasysData.CameraSchemeSelectInfo.schemeKey, nil)
  camerasysData:AddSchemeInfoDatas(curSchemeInfo.schemeKey, curSchemeInfo)
  Z.LsqLiteMgr.UpdataData("camera_scheme_info", "zproto.cameraSchemeCache", roleKey, cameraSchemeCache)
  local selectData = {}
  selectData.data = curSchemeInfo
  selectData.index = camerasysData.CameraSchemeSelectIndex
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.RefSchemeList, selectData)
end
local saveCameraSchemeInfo = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    cameraSchemeCache = {}
    cameraSchemeCache.cameraSchemeDict = {}
  end
  local curSchemeInfo = camerasysData:GetCameraSchemeInfo()
  curSchemeInfo.schemeName = camerasysData.CameraSchemeReplaceInfo.data.schemeName
  curSchemeInfo.schemeTime = camerasysData.CameraSchemeReplaceInfo.data.schemeTime
  cameraSchemeCache.cameraSchemeDict[camerasysData.CameraSchemeReplaceInfo.data.schemeKey] = nil
  cameraSchemeCache.cameraSchemeDict[curSchemeInfo.schemeKey] = curSchemeInfo
  camerasysData:AddSchemeInfoDatas(camerasysData.CameraSchemeReplaceInfo.data.schemeKey, nil)
  camerasysData:AddSchemeInfoDatas(curSchemeInfo.schemeKey, curSchemeInfo)
  Z.LsqLiteMgr.UpdataData("camera_scheme_info", "zproto.cameraSchemeCache", roleKey, cameraSchemeCache)
  local selectData = {}
  selectData.data = curSchemeInfo
  selectData.index = camerasysData.CameraSchemeReplaceInfo.index
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.RefSchemeList, selectData)
end
local addCameraSchemeInfo = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    cameraSchemeCache = {}
    cameraSchemeCache.cameraSchemeDict = {}
  end
  local curSchemeInfo = camerasysData:GetCameraSchemeInfo()
  camerasysData.CameraSchemeSelectId = curSchemeInfo.id
  cameraSchemeCache.cameraSchemeDict[curSchemeInfo.schemeKey] = curSchemeInfo
  camerasysData:AddSchemeInfoDatas(curSchemeInfo.schemeKey, curSchemeInfo)
  Z.LsqLiteMgr.UpdataData("camera_scheme_info", "zproto.cameraSchemeCache", roleKey, cameraSchemeCache)
end
local deleteCameraSchemeInfo = function(dataValue)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  Z.LsqLiteMgr.CreateTable("camera_scheme_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local cameraSchemeCache = Z.LsqLiteMgr.GetDataByKey("camera_scheme_info", "zproto.cameraSchemeCache", roleKey)
  if not cameraSchemeCache or not next(cameraSchemeCache) then
    return
  end
  cameraSchemeCache.cameraSchemeDict[dataValue.schemeKey] = nil
  camerasysData:AddSchemeInfoDatas(dataValue.schemeKey, nil)
  Z.LsqLiteMgr.UpdataData("camera_scheme_info", "zproto.cameraSchemeCache", roleKey, cameraSchemeCache)
end
local isEnterSelfPhoto = function()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return false
  end
  local isEnter = false
  local stateId = Z.EntityMgr.PlayerEnt:GetLuaLocalAttrState()
  if Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.EMultiActionState).Value ~= 0 then
    isEnter = false
  elseif Z.EntityMgr.PlayerEnt.IsRiding == true then
    isEnter = Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.ActorStateSelfPhoto)
  elseif stateId == Z.PbEnum("EActorState", "ActorStateDefault") then
    local canSwitchStateList = {
      Z.PbEnum("EMoveType", "MoveIdle"),
      Z.PbEnum("EMoveType", "MoveWalk"),
      Z.PbEnum("EMoveType", "MoveRun"),
      Z.PbEnum("EMoveType", "MoveWalkEnd"),
      Z.PbEnum("EMoveType", "MoveRunEnd"),
      Z.PbEnum("EMoveType", "MoveWalkEndToIdle"),
      Z.PbEnum("EMoveType", "MoveRunEndToIdle")
    }
    local moveType = Z.EntityMgr.PlayerEnt:GetLuaAttrVirtualMoveType()
    for k, v in pairs(canSwitchStateList) do
      if v == moveType then
        isEnter = true
        return isEnter
      end
    end
  elseif stateId == Z.PbEnum("EActorState", "ActorStateSelfPhoto") or stateId == Z.PbEnum("EActorState", "ActorStateAction") then
    isEnter = true
  else
    isEnter = false
  end
  return isEnter
end
local resetEntityVisible = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  for k, v in pairs(camerasysData.CameraEntityVisible) do
    if v == true then
      Z.CameraFrameCtrl:SetEntityShow(k, true)
      setShowState(k, true, E.CamerasysContrShowType.Entity, camerasysData.CameraPatternType)
      v = false
    end
  end
  camerasysData.CameraEntityVisible = {}
end
local isUpdateWeatherByServer = function(isUpdate)
  Z.LuaBridge.SetWeatherIsUpdateFromServer(isUpdate)
end
local setSchemoCameraValue = function(dataValue)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local decorateData = Z.DataMgr.Get("decorate_add_data")
  if camerasysData.IsInitSchemeState then
    camerasysData.IsInitSchemeState = false
    return
  end
  local cameraPatternType = dataValue.cameraPatternType
  if cameraPatternType == E.TakePhotoSate.SelfPhoto and not isEnterSelfPhoto() then
    return false
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Camera.PatternTypeEvent, cameraPatternType)
  if dataValue.horizontal then
    if cameraPatternType == E.TakePhotoSate.SelfPhoto then
      camerasysData.CameraSelfHorizontalRange.value = dataValue.horizontal
    else
      camerasysData.CameraHorizontalRange.value = dataValue.horizontal
    end
    Z.CameraFrameCtrl:SetHorizontal(dataValue.horizontal)
  end
  if dataValue.vertical then
    if cameraPatternType == E.TakePhotoSate.SelfPhoto then
      camerasysData.CameraSelfVerticalRange.value = dataValue.vertical
    else
      camerasysData.CameraVerticalRange.value = dataValue.vertical
    end
    Z.CameraFrameCtrl:SetVertical(dataValue.vertical)
  end
  if dataValue.angle then
    camerasysData.CameraAngleRange.value = dataValue.angle
    Z.CameraFrameCtrl:SetAngle(camerasysData.CameraAngleRange.value)
  end
  camerasysData.MenuContainerShotsetDirty = false
  camerasysData.IsDepthTag = dataValue.depthTag
  camerasysData.IsFocusTag = dataValue.focusTag
  camerasysData.IsHeadFollow = dataValue.isHeadFollow
  camerasysData.IsEyeFollow = dataValue.isEyeFollow
  camerasysData.WorldTime = dataValue.worldTime
  isUpdateWeatherByServer(dataValue.worldTime == -1)
  if dataValue.worldTime ~= -1 then
    Z.LuaBridge.SetCurWeatherTime(dataValue.worldTime)
  end
  setHeadLookAt(dataValue.isHeadFollow)
  setEyesLookAt(dataValue.isEyeFollow)
  Z.CameraFrameCtrl:SetDepthTog(camerasysData.IsDepthTag)
  Z.CameraFrameCtrl:SetFocusTog(camerasysData.IsFocusTag)
  camerasysData.DOFApertureFactorRange.value = dataValue.aperture
  camerasysData.NearBlendRange.value = dataValue.nearBlend
  camerasysData.FarBlendRange.value = dataValue.farBlend
  if camerasysData.IsFocusTag then
    Z.CameraFrameCtrl:SetAperture(camerasysData.DOFApertureFactorRange.value)
    Z.CameraFrameCtrl:SetNearBlend(camerasysData.NearBlendRange.value)
    Z.CameraFrameCtrl:SetFarBlend(camerasysData.FarBlendRange.value)
  end
  Z.CameraFrameCtrl:SetIsFocusTarget(not camerasysData.IsFocusTag)
  camerasysData.DOFFocalLengthRange.value = dataValue.focus
  if dataValue.focusTag then
    Z.CameraFrameCtrl:SetFocus(camerasysData.DOFFocalLengthRange.value)
  end
  camerasysData.MenuContainerMoviescreenDirty = false
  camerasysData.ScreenBrightnessRange.value = dataValue.exposure
  Z.CameraFrameCtrl:SetExposure(camerasysData.ScreenBrightnessRange.value)
  camerasysData.ScreenContrastRange.value = dataValue.contrast
  Z.CameraFrameCtrl:SetContrast(camerasysData.ScreenContrastRange.value)
  camerasysData.ScreenSaturationRange.value = dataValue.saturation
  Z.CameraFrameCtrl:SetSaturation(camerasysData.ScreenSaturationRange.value)
  camerasysData.MenuContainerShowDirty = false
  if dataValue.filterPath == "" then
    Z.CameraFrameCtrl:SetDefineFilterAsync()
  else
    Z.CameraFrameCtrl:SetFilterAsync(dataValue.filterPath)
  end
  camerasysData.FilterPath = dataValue.filterPath
  if not string.zisEmpty(dataValue.filterPath) then
    local filterCfg = camerasysData:GetFilterCfg()
    for k, v in pairs(filterCfg) do
      if v.Res == dataValue.filterPath then
        camerasysData.FilterIndex = k
        break
      end
    end
  end
  local moviescreenData = {}
  moviescreenData.contrast = dataValue.contrast
  moviescreenData.exposure = dataValue.exposure
  moviescreenData.filterData = dataValue.filterPath
  moviescreenData.saturation = dataValue.saturation
  decorateData:SetMoviescreenDataEX(moviescreenData)
  camerasysData.MenuContainerShowDirty = false
  local showEntityDicts = dataValue.showEntityDicts
  for key, value in pairs(showEntityDicts) do
    setShowState(key, value, E.CamerasysContrShowType.Entity, dataValue.cameraPatternType)
    resetEntityVisible()
  end
  local showUIDicts = dataValue.showUIDicts
  for key, value in pairs(showUIDicts) do
    setShowState(key, value, E.CamerasysContrShowType.UI)
    Z.LuaBridge.SetHudSwitch(value)
  end
  camerasysData.FilterPath = dataValue.filterPath
  if not dataValue.filterPath or dataValue.filterPath == "" then
    Z.CameraFrameCtrl:SetDefineFilterAsync()
  else
    Z.CameraFrameCtrl:SetFilterAsync(dataValue.filterPath)
  end
end
local createCameraSchemefName = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local albumMap = camerasysData:GetSchemeInfoDatas()
  local index = 1
  local defName
  for i = 1, 8 do
    index = i
    defName = Lang("CustomScheme") .. index
    local isOk = true
    for key, value in pairs(albumMap) do
      if value.schemeName == defName then
        isOk = false
        break
      end
    end
    if isOk then
      return defName
    end
  end
  return defName
end
local cameraSchemefIsRepeatName = function(valueName)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local albumMap = camerasysData:GetSchemeInfoDatas()
  local isOk = false
  for key, value in pairs(albumMap) do
    if value.schemeName == valueName then
      return true
    end
  end
  return isOk
end
local setCameraPatternShotSet = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local tbDatar_horizontal, tbDatar_vertical
  if camerasysData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    tbDatar_horizontal = camerasysData:GetCameraSelfHorizontalRange()
    tbDatar_vertical = camerasysData:GetCameraSelfVerticalRange()
  else
    tbDatar_horizontal = camerasysData:GetCameraHorizontalRange()
    tbDatar_vertical = camerasysData:GetCameraVerticalRange()
  end
  if camerasysData.CameraPatternType ~= E.TakePhotoSate.UnionTakePhoto then
    Z.CameraFrameCtrl:SetVertical(tbDatar_vertical.value)
    Z.CameraFrameCtrl:SetHorizontal(tbDatar_horizontal.value)
  end
end
local posKeepBounds = function(posX, posY)
  local maxX = Z.UIRoot.CurScreenSize.x / 2
  local maxY = Z.UIRoot.CurScreenSize.y / 2
  local minX = -maxX
  local minY = -maxY
  if posX > maxX then
    posX = maxX
  elseif minX > posX then
    posX = minX
  end
  if posY > maxY then
    posY = maxY
  elseif minY > posY then
    posY = minY
  end
  return posX, posY
end
local unionClipPositionKeepBounds = function(posX, posY, max, min, moveNodeWidth, moveNodeHeight)
  local widthHalf = moveNodeWidth / 2
  local heightHalf = moveNodeHeight / 2
  if posX + widthHalf > max.x then
    posX = max.x - widthHalf
  elseif posX - widthHalf < min.x then
    posX = min.x + widthHalf
  end
  if posY + heightHalf > max.y then
    posY = max.y - heightHalf
  elseif posY - heightHalf < min.y then
    posY = min.y + heightHalf
  end
  return posX, posY
end
local openCameraView = function(taskId)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  if taskId and taskId ~= 0 then
    camerasysData.IsOfficialPhotoTask = true
    camerasysData.PhotoTaskId = taskId
  end
  local viewConfigKey = Z.IsPCUI and "camerasys_main_pc" or "camerasys"
  Z.UIMgr:OpenView(viewConfigKey)
  setShowState(E.CamerasysShowUIType.Name, false, E.CamerasysContrShowType.UI)
end
local openCameraViewByUnrealWithHead = function()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.UnionHeadCamera)
  if not isOn then
    return
  end
  Z.UIMgr:GotoMainView()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  camerasysData.CameraPatternType = E.TakePhotoSate.UnionTakePhoto
  camerasysData.UnrealSceneModeSubType = E.UnionCameraSubType.Head
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "camerasys", function()
        local viewConfigKey = Z.IsPCUI and "camerasys_main_pc" or "camerasys"
        Z.UIMgr:OpenView(viewConfigKey)
      end, UNREAL_SCENE_CONFIG_PATH)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local openCameraViewByUnrealWithIdCard = function()
  local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
  local isOn = gotoFuncVM.CheckFuncCanUse(E.FunctionID.UnionCardCamera)
  if not isOn then
    return
  end
  Z.UIMgr:GotoMainView()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  camerasysData.CameraPatternType = E.TakePhotoSate.UnionTakePhoto
  camerasysData.UnrealSceneModeSubType = E.UnionCameraSubType.Body
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "camerasys", function()
        local viewConfigKey = Z.IsPCUI and "camerasys_main_pc" or "camerasys"
        Z.UIMgr:OpenView(viewConfigKey)
      end, UNREAL_SCENE_CONFIG_PATH)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local gotoMainUIAndopenCameraView = function()
  if Z.StatusSwitchMgr:TrySwitchToState(Z.EStatusSwitch.StatusCamera) then
    Z.UIMgr:GotoMainView()
    local viewConfigKey = Z.IsPCUI and "camerasys_main_pc" or "camerasys"
    Z.UIMgr:OpenView(viewConfigKey)
  end
end
local openCameraViewByUnrealWithFaceData = function(shareCode)
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  camerasysData.CameraPatternType = E.TakePhotoSate.UnionTakePhoto
  camerasysData.UnrealSceneModeSubType = E.UnionCameraSubType.Fashion
  local args = {
    EndCallback = function()
      Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "camerasys", function()
        local viewConfigKey = Z.IsPCUI and "camerasys_main_pc" or "camerasys"
        Z.UIMgr:OpenView(viewConfigKey, shareCode)
      end, CLOUD_FACE_UNREAL_CONFIG_PATH)
    end
  }
  Z.UIMgr:FadeIn(args)
end
local closeCameraViewByPhotoTask = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  if camerasysData.IsOfficialPhotoTask then
    if Z.IsPCUI then
      Z.UIMgr:CloseView("camerasys_main_pc")
    else
      Z.UIMgr:CloseView("camerasys")
    end
  end
end
local openCameraPhotoMain = function(content)
  Z.UIMgr:OpenView("camera_photo_main", content)
end
local closeCameraPhotoMain = function()
  if Z.UIMgr:IsActive("camera_photo_main") then
    Z.UIMgr:CloseView("camera_photo_main")
  end
end
local calculatePercentageValue = function(min, max, percentage)
  local range = max - min
  local offset = range * percentage
  local result = min + offset
  return math.floor(result)
end
local showOrHideNoticePopView = function(isShow)
  local tempTable = {
    "noticetip_pop",
    "team_tips",
    "acquiretip",
    "talent_award_window",
    "tips_unlock_condition",
    "season_achievement_finish_popup",
    "steer_tips_window"
  }
  for k, v in pairs(tempTable) do
    local view = Z.UIMgr:GetView(v)
    if view then
      if isShow then
        view:Show()
      else
        view:Hide()
      end
    end
  end
end
local openIdCardView = function(cancelToken, photoData)
  local idCardVM = Z.VMMgr.GetVM("idcard")
  idCardVM.AsyncGetCardData(Z.ContainerMgr.CharSerialize.charBase.charId, cancelToken, photoData)
end
local openHeadView = function(viewData)
  Z.UIMgr:OpenView("photo_personal_idcard_popup", viewData)
end
local cameraFuncTogIndexToLogicIndex = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local tagIndexTable = camerasysData:GetTagIndex()
  local tagList = camerasysData.funcTbDefault[tagIndexTable.TopTagIndex]
  local selectMemberData = cameraMemberData:GetSelectMemberData()
  if selectMemberData and not selectMemberData.baseData.isSelf and tagIndexTable.TopTagIndex == E.CamerasysTopType.Action then
    tagList = {
      E.CamerasysFuncType.LookAt
    }
  end
  if camerasysData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    tagList = camerasysData.funcTbSelfPhoto[tagIndexTable.TopTagIndex]
  elseif camerasysData.CameraPatternType == E.TakePhotoSate.AR then
    tagList = camerasysData.funcTbAR[tagIndexTable.TopTagIndex]
  elseif camerasysData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    tagList = camerasysData.funcTbUnrealScene[tagIndexTable.TopTagIndex]
  end
  return tagList[tagIndexTable.NodeTagIndex]
end
local getHeadOrBodyPhotoToken = function(textureId, snapType)
  local textureSize = Z.SnapShotMgr:GetTextureSize(textureId)
  if textureSize == 0 then
    return
  end
  local worldProxy = require("zproxy.world_proxy")
  local headSnapshotData = Z.DataMgr.Get("head_snapshot_data")
  local snapTypeName = headSnapshotData.SnapType[snapType]
  headSnapshotData.PictureIdDic[textureId] = snapType
  local req = {}
  req.verifyInfo = {}
  req.verifyInfo.size = textureSize
  req.pictureId = textureId
  req.pictureName = string.zconcat(Z.EntityMgr.PlayerEnt.EntId, snapTypeName, textureSize, ".png")
  req.pictureType = snapType
  worldProxy.GetAvatarToken(req)
end
local getTakePhotoSize = function()
  local normalScreenSize = Z.UIRoot.DESIGNSIZE_WIDTH / Z.UIRoot.DESIGNSIZE_HEIGHT
  local photoWidth = Z.UIRoot.CurScreenSize.x
  local photoHeight = Z.UIRoot.CurScreenSize.y
  local screenSize = photoWidth / photoHeight
  if normalScreenSize <= screenSize then
    photoWidth = math.floor(photoHeight * normalScreenSize)
  else
    photoHeight = math.floor(photoWidth / normalScreenSize)
  end
  return photoWidth, photoHeight
end
local getModelDefaultRotation = function(model)
  local rotationVal = 180
  if not model then
    return
  end
  rotationVal = model:GetAttrGoRotation().eulerAngles.y
  return rotationVal
end
local getRotationSliderValueNormalized = function(defaultOffset, currentVal)
  if currentVal then
    return currentVal - defaultOffset
  end
  return 0
end
local getHeightOffSet = function(currentHeightVal)
  if not currentHeightVal then
    return 0
  end
  local x1 = 1
  local x2 = -1
  local max = 0.07
  local min = -0.08
  local m = (min - max) / (x2 - x1)
  local b = max - m * x1
  return m * currentHeightVal + b
end
local checkIsPcUIAndDefaultCamera = function()
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  return Z.IsPCUI and camerasysData.CameraPatternType == E.E.TakePhotoSate.Default.Default
end
local getPhotoShareRow = function()
  local shareTable = Z.TableMgr.GetTable("PhotoShareTableMgr")
  local channelId = Z.SDKTencent.InstallChannel
  if string.zisEmpty(channelId) then
    return nil
  end
  channelId = tonumber(channelId)
  if channelId == nil then
    return nil
  end
  local shareRow = shareTable.GetRow(channelId, true)
  return shareRow
end
local sendShotTLog = function()
  local WorldProxy = require("zproxy.world_proxy")
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local pos = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
  local posStr = string.format("%.2f=%.2f=%.2f", pos.x, pos.y, pos.z)
  local str = string.zconcat(camerasysData.CameraPatternType, "|", posStr, "|", camerasysData.FilterIndex, "|", camerasysData.FrameIndex)
  WorldProxy.UploadTLogBody("TakePhoto", str)
end
local asyncSetPhotoSchemeName = function(schemeId, schemeName, cancelToken)
  local photographProxy = require("zproxy.photograph_proxy")
  local requestData = {schemeId = schemeId, schemeName = schemeName}
  local ret = photographProxy.SetPhotoSchemeName(requestData, cancelToken)
  if ret == nil or ret.errCode == 0 then
    return ret
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
  return ret
end
local conversionTakePhotoType = function(takePhotoType)
  local cameraType = E.CameraState.Default
  if takePhotoType == E.TakePhotoSate.Default or takePhotoType == E.TakePhotoSate.Battle then
    cameraType = E.CameraState.Default
  elseif takePhotoType == E.TakePhotoSate.SelfPhoto then
    cameraType = E.CameraState.SelfPhoto
  elseif takePhotoType == E.TakePhotoSate.AR then
    cameraType = E.CameraState.AR
  elseif takePhotoType == E.TakePhotoSate.UnionTakePhoto then
    cameraType = E.CameraState.UnrealScene
  end
  return cameraType
end
local banSkill = function()
  if not Z.EntityMgr.PlayerEnt then
    logError("PlayerEnt is nil")
    return false
  end
  local buffDataList = Z.EntityMgr.PlayerEnt:GetLuaAttr(Z.LocalAttr.ENowBuffList)
  local banSkill = false
  if buffDataList then
    buffDataList = buffDataList.Value
    for i = 0, buffDataList.count - 1 do
      if buffDataList[i].BuffBaseId == 681701 then
        banSkill = true
      end
    end
  end
  return banSkill
end
local setShowEntity = function(showData)
  local showEntity = {}
  local camerasysData = Z.DataMgr.Get("camerasys_data")
  local allData = camerasysData.ShowEntityAllCfg
  for key, value in pairs(allData) do
    local temp = {}
    temp.type = value.type
    temp.state = value.state
    showEntity[temp.type] = temp
  end
  for key, value in pairs(showData) do
    if showEntity[value.type] then
      showEntity[value.type].state = value.state
    end
  end
end
local getPlayerPos = function()
  if not Z.EntityMgr.PlayerEnt then
    return nil
  end
  local playerPos_ = Z.EntityMgr.PlayerEnt:GetLocalAttrVirtualPos()
  return playerPos_.x, playerPos_.y, playerPos_.z
end
local initSelfLookAtCamera = function()
  if not Z.EntityMgr.PlayerEnt then
    return
  end
  local cameraMemberData = Z.DataMgr.Get("camerasys_member_data")
  local model = Z.EntityMgr.PlayerEnt.Model
  model:SetLuaAttrLookAtEyeOpen(true)
  setHeadLookAt(true, model)
  setHeadLookAt(true, model, true)
  local myCharId = Z.ContainerMgr.CharSerialize.charId
  local myMemberData = cameraMemberData:GetMemberDataByCharId(myCharId)
  myMemberData.lookAtData.headMode = E.CameraPlayerLookAtType.Camera
  myMemberData.lookAtData.eyesMode = E.CameraPlayerLookAtType.Camera
end
local setCameraFov = function()
  local cameraData = Z.DataMgr.Get("camerasys_data")
  local zoom
  if cameraData.CameraPatternType == E.TakePhotoSate.Default or cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto or cameraData.CameraPatternType == E.TakePhotoSate.Battle then
    zoom = cameraData:GetCameraFOVRange()
  elseif cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    zoom = cameraData:GetCameraFOVSelfRange()
  elseif cameraData.CameraPatternType == E.TakePhotoSate.AR then
    zoom = cameraData:GetCameraFOVARRange()
  end
  local val = getRangePerc(zoom)
  zoom.value = getRangeValue(val, zoom)
  Z.CameraFrameCtrl:SetCameraSize(zoom.value)
end
local checkCurrentModeIsShow = function(photographUiTableData)
  local cameraData = Z.DataMgr.Get("camerasys_data")
  if cameraData.CameraPatternType == E.TakePhotoSate.Default then
    return photographUiTableData.GeneralMode
  elseif cameraData.CameraPatternType == E.TakePhotoSate.SelfPhoto then
    return photographUiTableData.SelfPhotoMode
  elseif cameraData.CameraPatternType == E.TakePhotoSate.AR then
    return photographUiTableData.VrMode
  elseif cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto then
    return photographUiTableData.IdCardMode
  elseif cameraData.CameraPatternType == E.TakePhotoSate.Battle then
    return photographUiTableData.FightMode
  end
end
local getPcFunctionData = function(type)
  local data = {}
  local photographUiTableData = Z.TableMgr.GetTable("PhotographUiTableMgr").GetDatas()
  local platform = Z.IsPCUI and E.CameraSystemPlatform.Pc or E.CameraSystemPlatform.Mobile
  for k, v in pairs(photographUiTableData) do
    local currentModeIsShow = checkCurrentModeIsShow(v)
    if (v.Platform == E.CameraSystemPlatform.General or v.Platform == platform) and v.ParentId == type and currentModeIsShow then
      table.insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.SortId < b.SortId
  end)
  return data
end
local getPcPhotographUiTableRow = function(type)
  local photographUiTableData = Z.TableMgr.GetTable("PhotographUiTableMgr").GetRow(type)
  if not photographUiTableData then
    return
  end
  return photographUiTableData
end
local setCameraActionDisplayExpressionType = function(subFuncType)
  local expressionData = Z.DataMgr.Get("expression_data")
  if subFuncType == E.CameraSystemSubFunctionType.CommonAction then
    expressionData:SetLogicExpressionType(E.ExpressionType.Action)
    expressionData:SetDisplayExpressionType(E.DisplayExpressionType.CommonAction)
  elseif subFuncType == E.CameraSystemSubFunctionType.LoopAction then
    expressionData:SetLogicExpressionType(E.ExpressionType.Action)
    expressionData:SetDisplayExpressionType(E.DisplayExpressionType.LoopAction)
  elseif subFuncType == E.CameraSystemSubFunctionType.Emote then
    expressionData:SetLogicExpressionType(E.ExpressionType.Emote)
    expressionData:SetDisplayExpressionType(E.DisplayExpressionType.Emote)
  end
end
local getFirstLevelTabData = function()
  local tempData = {}
  local photographUiTableData
  local platform = Z.IsPCUI and E.CameraSystemPlatform.Pc or E.CameraSystemPlatform.Mobile
  for k, v in pairs(E.CameraSystemFunctionType) do
    photographUiTableData = Z.TableMgr.GetTable("PhotographUiTableMgr").GetRow(v)
    local currentModeIsShow = checkCurrentModeIsShow(photographUiTableData)
    local functionData = {
      id = v,
      name = photographUiTableData.Name,
      icon = photographUiTableData.Icon,
      sortId = photographUiTableData.SortId,
      isShow = (photographUiTableData.Platform == E.CameraSystemPlatform.General or photographUiTableData.Platform == platform) and currentModeIsShow
    }
    table.insert(tempData, functionData)
  end
  return tempData
end
local setImgAreaClip = function(maskImg, imgNode)
  if not maskImg then
    return
  end
  local imgNodeLocalPos = imgNode.localPosition
  local offset = Vector2.New(Z.UIRoot.CurCanvasSize.x / 2, Z.UIRoot.CurCanvasSize.y / 2)
  local rectLeftPosX = (offset.x - imgNode.rect.width / 2 + imgNodeLocalPos.x) / (offset.x * 2)
  local rectLeftPosY = (offset.y - imgNode.rect.height / 2 + imgNodeLocalPos.y) / (offset.y * 2)
  local rectRightPosX = (offset.x + imgNode.rect.width / 2 + imgNodeLocalPos.x) / (offset.x * 2)
  local rectRightPosY = (offset.y + imgNode.rect.height / 2 + imgNodeLocalPos.y) / (offset.y * 2)
  local area = Vector4.New(rectLeftPosX, rectLeftPosY, rectRightPosX, rectRightPosY)
  maskImg:SetAreaClip(area)
end
local getUnionSelectBoxSize = function(imgSize, rate, isBody)
  local curCanvasSizeY = Z.UIRoot.CurCanvasSize.y
  local curCanvasSizeX = Z.UIRoot.CurCanvasSize.x
  local width = imgSize.x * rate
  local height = imgSize.y * rate
  if curCanvasSizeY < height then
    height = curCanvasSizeY
    if not isBody then
      width = curCanvasSizeY
    end
  end
  if curCanvasSizeX < width then
    width = curCanvasSizeX
    if not isBody then
      height = curCanvasSizeX
    end
  end
  return width, height
end
local checkMobileUiShowState = function(id, isControlByOther)
  local photographUiTableRow = Z.TableMgr.GetTable("PhotographUiTableMgr").GetRow(id)
  if isControlByOther and photographUiTableRow.OthersModel ~= 2 then
    return photographUiTableRow.OthersModel == 1 and true or false
  end
  local currentModeIsShow = checkCurrentModeIsShow(photographUiTableRow)
  return currentModeIsShow
end
local getMobileFunctionData = function(type, isControlByOther)
  local data = {}
  local photographUiTableData = Z.TableMgr.GetTable("PhotographUiTableMgr").GetDatas()
  local platform = Z.IsPCUI and E.CameraSystemPlatform.Pc or E.CameraSystemPlatform.Mobile
  for k, v in pairs(photographUiTableData) do
    local currentModeIsShow = checkMobileUiShowState(v.Id, isControlByOther)
    if (v.Platform == E.CameraSystemPlatform.General or v.Platform == platform) and v.ParentId == type and currentModeIsShow then
      table.insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.SortId < b.SortId
  end)
  return data
end
local checkIsFashionState = function()
  local cameraData = Z.DataMgr.Get("camerasys_data")
  local isFashionState = cameraData.CameraPatternType == E.TakePhotoSate.UnionTakePhoto and cameraData.UnrealSceneModeSubType == E.UnionCameraSubType.Fashion
  return isFashionState
end
local sendCloudFaceData = function(shareCode)
  local externalMessage = {
    eventName = "ugc_play_end"
  }
  local externalMessageSerial = cjson.encode(externalMessage)
  logError("externalMessageSerial = {0}", externalMessageSerial)
  Z.SDKDevices.SendMessageToCloudGameDevice(externalMessageSerial)
  local dataTable = {
    type = "CG_GAME_EVENT_PINCH_FACE_DONE",
    data = {faceContent = shareCode}
  }
  local serial = cjson.encode(dataTable)
  logError("CG_GAME_EVENT_PINCH_FACE_DONE = {0}", serial)
  Z.SDKDevices.SendMessageToCloudGameDevice(serial)
end
local sendCloudFaceCopyData = function(shareCode)
  local dataTable = {
    dataType = "CG_GAME_EVENT_COPY_TEXT",
    copyContent = shareCode
  }
  local serial = cjson.encode(dataTable)
  logError("CG_GAME_EVENT_COPY_TEXT = {0}", serial)
  Z.SDKDevices.SendMessageToCloudGameDevice(serial)
end
local ret = {
  SetTopTagIndex = setTopTagIndex,
  SetNodeTagIndex = setNodeTagIndex,
  SetDecorate = setDecorate,
  GetRangeValue = getRangeValue,
  GetRangePerc = getRangePerc,
  GetRangePercEX = getRangePercEX,
  GetRangeDefinePerc = getRangeDefinePerc,
  SetShowState = setShowState,
  SavePhotoToTempAlbum = savePhotoToTempAlbum,
  SaveCloudPhotoToTempAlbum = saveCloudPhotoToTempAlbum,
  AddCameraSchemeInfo = addCameraSchemeInfo,
  SetSchemoCameraValue = setSchemoCameraValue,
  CreateCameraSchemefName = createCameraSchemefName,
  DeleteCameraSchemeInfo = deleteCameraSchemeInfo,
  SaveCameraSchemeInfoEX = saveCameraSchemeInfoEX,
  SaveCameraSchemeInfo = saveCameraSchemeInfo,
  ReplaceCameraSchemeInfo = replaceCameraSchemeInfo,
  CameraSchemefIsRepeatName = cameraSchemefIsRepeatName,
  IsEnterSelfPhoto = isEnterSelfPhoto,
  SetCameraPatternShotSet = setCameraPatternShotSet,
  PosKeepBounds = posKeepBounds,
  OpenCameraView = openCameraView,
  CloseCameraView = closeCameraViewByPhotoTask,
  OpenCameraPhotoMain = openCameraPhotoMain,
  CloseCameraPhotoMain = closeCameraPhotoMain,
  IsUpdateWeatherByServer = isUpdateWeatherByServer,
  CalculatePercentageValue = calculatePercentageValue,
  SetHeadLookAt = setHeadLookAt,
  SetEyesLookAt = setEyesLookAt,
  ShowOrHideNoticePopView = showOrHideNoticePopView,
  OpenCameraViewByUnrealWithHead = openCameraViewByUnrealWithHead,
  OpenCameraViewByUnrealWithIdCard = openCameraViewByUnrealWithIdCard,
  OpenHeadView = openHeadView,
  CameraFuncTogIndexToLogicIndex = cameraFuncTogIndexToLogicIndex,
  GetHeadOrBodyPhotoToken = getHeadOrBodyPhotoToken,
  OpenIdCardView = openIdCardView,
  GetTakePhotoSize = getTakePhotoSize,
  GetModelDefaultRotation = getModelDefaultRotation,
  GetRotationSliderValueNormalized = getRotationSliderValueNormalized,
  GotoMainUIAndopenCameraView = gotoMainUIAndopenCameraView,
  GetHeightOffSet = getHeightOffSet,
  UnionClipPositionKeepBounds = unionClipPositionKeepBounds,
  ResetEntityVisible = resetEntityVisible,
  CheckIsPcUIAndDefaultCamera = checkIsPcUIAndDefaultCamera,
  GetPhotoShareRow = getPhotoShareRow,
  SendShotTLog = sendShotTLog,
  ConversionTakePhotoType = conversionTakePhotoType,
  BanSkill = banSkill,
  SetShowEntity = setShowEntity,
  GetPlayerPos = getPlayerPos,
  SetCameraFov = setCameraFov,
  GetPcFunctionData = getPcFunctionData,
  GetPcPhotographUiTableRow = getPcPhotographUiTableRow,
  SetCameraActionDisplayExpressionType = setCameraActionDisplayExpressionType,
  GetFirstLevelTabData = getFirstLevelTabData,
  SetImgAreaClip = setImgAreaClip,
  InitSelfLookAtCamera = initSelfLookAtCamera,
  CheckMobileUiShowState = checkMobileUiShowState,
  GetMobileFunctionData = getMobileFunctionData,
  OpenCameraViewByUnrealWithFaceData = openCameraViewByUnrealWithFaceData,
  CheckIsFashionState = checkIsFashionState,
  SendCloudFaceData = sendCloudFaceData,
  GetUnionSelectBoxSize = getUnionSelectBoxSize,
  SendCloudFaceCopyData = sendCloudFaceCopyData,
  AsyncSetPhotoSchemeName = asyncSetPhotoSchemeName
}
return ret
