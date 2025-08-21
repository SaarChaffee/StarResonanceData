local worldProxy = require("zproxy.world_proxy")
local cjson = require("cjson")
local logPbError = function(ret)
  if ret and ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
  end
end
local logErrCode = function(errCode)
  if errCode and errCode ~= 0 then
    Z.TipsVM.ShowTips(errCode)
  end
end
local dispatchEvent = function(eventName, ret)
  if ret and ret.errCode == 0 then
    Z.EventMgr:Dispatch(eventName, ret)
  end
end
local setIsUploadState = function(isUpload)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.IsUpLoadState = isUpload
end
local albumUpLoadErrorCollection = function(errorType, errorData)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local errorDatas = albumMainData.AlbumUploadCountTable.errorDatas
  local data = {}
  data.errorType = errorType
  data.errorData = errorData
  if errorDatas then
    errorDatas[#errorDatas + 1] = data
  end
  albumMainData.AlbumUploadCountTable.errorNum = albumMainData.AlbumUploadCountTable.errorNum + 1
  Z.EventMgr:Dispatch(Z.ConstValue.Album.UpLoadSliderValue)
end
local checkSubTypeIsUnion = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  return albumMainData.ContainerType == E.AlbumMainState.UnionTemporary or albumMainData.ContainerType == E.AlbumMainState.UnionCloud
end
local checkIsShowUnion = function()
  local isUnionFuncOpen = Z.VMMgr.GetVM("switch").CheckFuncSwitch(E.UnionFuncId.Union)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM.GetPlayerUnionId()
  return isUnionFuncOpen and unionId ~= 0
end
local createAlbumDefaultName = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local albumMap = albumMainData:GetAlbumAllData()
  local index = 1
  local textKey = "AddAlbumDefalutName"
  if checkIsShowUnion() and checkSubTypeIsUnion() then
    textKey = "AddUnionAlbumDefalutName"
  end
  local defName = ""
  for i = 1, albumMainData.AlbumMaxNum + 3 do
    index = i
    defName = Lang(textKey, {val = index})
    local isOk = true
    for _, value in pairs(albumMap) do
      if value.name == defName then
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
local deleteLocalPhoto = function(photoData)
  Z.LsqLiteMgr.CreateTable("album_info")
  Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(photoData.tempOriPhoto)
  Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(photoData.tempPhoto)
  Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(photoData.tempThumbPhoto)
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    return
  end
  tempPhotoCache.tempPhotoCacheDict[photoData.id] = nil
  Z.LsqLiteMgr.UpdataData("album_info", "zproto.tempPhotoCache", roleKey, tempPhotoCache)
  Z.EventMgr:Dispatch(Z.ConstValue.Album.LocalPhotoDataUpdate)
end
local asyncDeleteServePhoto = function(selectPhotoInfo, token)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {
    photoId = selectPhotoInfo.id
  }
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("cache_photo_info", "zproto.httpCachePhotoInfo", roleKey)
  if tempPhotoCache and next(tempPhotoCache) and next(tempPhotoCache.httpCachePhotoInfoDict) then
    local oriCache = tempPhotoCache.httpCachePhotoInfoDict[selectPhotoInfo.originalUrl]
    local renderCache = tempPhotoCache.httpCachePhotoInfoDict[selectPhotoInfo.renderedUrl]
    local thumbnailCache = tempPhotoCache.httpCachePhotoInfoDict[selectPhotoInfo.thumbnailUrl]
    if not string.zisEmpty(oriCache) then
      Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(oriCache)
    end
    if not string.zisEmpty(renderCache) then
      Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(renderCache)
    end
    if not string.zisEmpty(thumbnailCache) then
      Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(thumbnailCache)
    end
  end
  local ret = photoGraphProxy.DeletePhoto(requestData, token)
  logPbError(ret)
  dispatchEvent(Z.ConstValue.Album.AlbumPhotoDelete, ret)
  return ret
end
local asyncSetAlbumCover = function(albumId, photoId, token)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {albumId = albumId, coverPhotoId = photoId}
  local ret = photoGraphProxy.SetAlbumCover(requestData, token)
  logPbError(ret)
  return ret
end
local asyncUploadPhotoRequestToken = function(vRequestData, token)
  if not vRequestData then
    return
  end
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local ret = photoGraphProxy.GetPhotoUpToken(vRequestData, token)
  logPbError(ret)
end
local asyncCreateAlbum = function(name, limitsOfAuthority, token, callback)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {name = name, access = limitsOfAuthority}
  local ret = photoGraphProxy.CreateAlbum(requestData, token)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  if ret and ret.errCode == 0 then
    albumMainData:UpdateAlbumAllData(ret.albumInfo)
  elseif callback then
    callback(ret.errCode)
  end
  dispatchEvent(Z.ConstValue.Album.CreateAlbum, ret)
  return ret
end
local asyncDeleteAlbum = function(albumId, token)
  if not albumId or not token then
    return
  end
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {albumId = albumId}
  local ret = photoGraphProxy.DeleteAlbum(requestData, token)
  logPbError(ret)
  return ret
end
local asyncEditAlbumRight = function(albumId, access, token)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {albumId = albumId, access = access}
  local ret = photoGraphProxy.EditAlbumRight(requestData, token)
  logPbError(ret)
  return ret
end
local asyncEditAlbumName = function(albumId, name, token, callback)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {albumId = albumId, name = name}
  local ret = photoGraphProxy.EditAlbumName(requestData, token)
  if ret and ret.errCode ~= 0 and callback then
    callback(ret.errCode)
  end
  dispatchEvent(Z.ConstValue.Album.AlbumDataUpdate, ret)
  return ret
end
local asyncMovePhotoOtherAlbum = function(photoId, albumId, token)
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {photoId = photoId, albumId = albumId}
  local ret = photoGraphProxy.MovePhotoToAlbum(requestData, token)
  logPbError(ret)
  dispatchEvent(Z.ConstValue.Album.CloudAlbumPhotosDataUpdate, ret)
  return ret
end
local asyncGetAllAlbums = function(token)
  local charId = Z.ContainerMgr.CharSerialize.charId
  if not charId then
    return
  end
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {charId = charId}
  local ret = photoGraphProxy.GetAllAlbums(requestData, token)
  logPbError(ret)
  return ret
end
local checkTempAlbumPhotoSafe = function(checkData)
  if not checkData or not next(checkData) then
    return false
  end
  if checkData.decorateData == "" or checkData.tempOriPhoto == "" or checkData.tempPhoto == "" or checkData.shotTime == "" or checkData.tempThumbPhoto == "" or checkData.id == "" or checkData.shotPlace == "" or checkData.shotTimeStr == "" then
    return false
  end
  if not Z.CameraFrameCtrl:CheckPhotoSafe(checkData.tempThumbPhoto) then
    return false
  end
  if not Z.CameraFrameCtrl:CheckPhotoSafe(checkData.tempOriPhoto) then
    return false
  end
  if not Z.CameraFrameCtrl:CheckPhotoSafe(checkData.tempPhoto) then
    return false
  end
  return true
end
local clearUnSafeAlbumPhoto = function(unSafeCheckDatas)
  if not unSafeCheckDatas or not next(unSafeCheckDatas) then
    return
  end
  Z.LsqLiteMgr.CreateTable("album_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    return
  end
  for _, value in pairs(unSafeCheckDatas) do
    Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(value.tempOriPhoto)
    Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(value.tempPhoto)
    Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(value.tempThumbPhoto)
    tempPhotoCache.tempPhotoCacheDict[value.id] = nil
  end
  Z.DataMgr.Get("album_main_data"):DeleteTempPhotoData(tempPhotoCache.id)
  Z.LsqLiteMgr.UpdataData("album_info", "zproto.tempPhotoCache", roleKey, tempPhotoCache)
end
local addHttpCacheAlbumPhoto = function(httpUrl, cachePath)
  Z.LsqLiteMgr.CreateTable("cache_photo_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("cache_photo_info", "zproto.httpCachePhotoInfo", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    tempPhotoCache = {}
    tempPhotoCache.httpCachePhotoInfoDict = {}
  end
  tempPhotoCache.httpCachePhotoInfoDict[httpUrl] = cachePath
  Z.LsqLiteMgr.UpdataData("cache_photo_info", "zproto.httpCachePhotoInfo", roleKey, tempPhotoCache)
end
local httpCheckAlbumPhoto = function(httpPath)
  local isExit = true
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("cache_photo_info", "zproto.httpCachePhotoInfo", roleKey)
  local localPath
  if not (tempPhotoCache and next(tempPhotoCache)) or not tempPhotoCache.httpCachePhotoInfoDict[httpPath] then
    isExit = false
  else
    localPath = tempPhotoCache.httpCachePhotoInfoDict[httpPath]
    if not localPath or string.zisEmpty(localPath) then
      isExit = false
    end
  end
  if isExit then
    return Z.CameraFrameCtrl:CheckPhotoSafe(localPath), localPath
  end
  return false
end
local showPhotoUploadResultTip = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local errorNum = albumMainData.AlbumUploadCountTable.errorNum
  local successNum = albumMainData.AlbumUploadCountTable.currentNum
  local showNum = {val1 = successNum, val2 = errorNum}
  local messageId = 1000034
  if albumMainData.CurrentUploadSourceType == E.PlatformFuncType.UnionPhoto then
    messageId = 1000569
  end
  if successNum == 0 and errorNum == 0 then
    Z.TipsVM.ShowTips(1000050)
  else
    Z.TipsVM.ShowTips(messageId, showNum)
  end
end
local asynHttpCacheToAlbumPhoto = function(httpPath, photoType)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.ReadPhotoToHttp)
  local cancelSource = Z.CancelSource.Rent()
  local photoId = asyncCall(cancelSource:CreateToken(), httpPath)
  cancelSource:Recycle()
  if photoId == -1 then
    return
  end
  local cachePath = Z.CameraFrameCtrl:SaveToCacheAlbum(photoType, photoId, true)
  return cachePath, photoId
end
local asynHttpCachePhoto = function(url)
  local asyncCall = Z.CoroUtil.async_to_sync(Z.LuaBridge.ReadPhotoToHttp)
  local cancelSource = Z.CancelSource.Rent()
  local photoId = asyncCall(cancelSource:CreateToken(), url)
  cancelSource:Recycle()
  if photoId == -1 then
    return
  end
  return photoId
end
local asyncGetHttpAlbumPhoto = function(httpPath, photoType, tag, cancelSource, callback, obj)
  local isExit, localPath = httpCheckAlbumPhoto(httpPath)
  if isExit then
    if callback ~= nil then
      local systemPhotoId = Z.CameraFrameCtrl:ReadTextureToSystemAlbum(localPath, tag)
      if systemPhotoId == 0 then
        return
      end
      if cancelSource == nil then
        Z.LuaBridge.ReleaseScreenShot(systemPhotoId)
        return
      end
      callback(obj, systemPhotoId)
    end
  else
    Z.CoroUtil.create_coro_xpcall(function()
      local cachePath, systemPhotoId = asynHttpCacheToAlbumPhoto(httpPath, photoType)
      addHttpCacheAlbumPhoto(httpPath, cachePath)
      if callback == nil or cancelSource == nil then
        Z.LuaBridge.ReleaseScreenShot(systemPhotoId)
      else
        callback(obj, systemPhotoId)
      end
    end)()
  end
end
local replacePhotoPathToCache = function(photoInfo)
  Z.CoroUtil.create_coro_xpcall(function()
    for k, v in pairs(photoInfo.images) do
      local cachePath, systemPhotoId = asynHttpCacheToAlbumPhoto(v.cosUrl, v.type)
      addHttpCacheAlbumPhoto(v.cosUrl, cachePath)
      Z.LuaBridge.ReleaseScreenShot(systemPhotoId)
    end
    Z.EventMgr:Dispatch(Z.ConstValue.Album.AlbumDataUpdate, photoInfo)
  end)()
end
local deleteTemporaryAlbumData = function(photoGraphShow)
  if not photoGraphShow or not next(photoGraphShow) then
    return
  end
  local photoTempInfoArr = string.split(photoGraphShow.photoDesc, "|")
  if not photoTempInfoArr or #photoTempInfoArr < 4 then
    return
  end
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local delData = albumMainData:GetSelectedAlbumPhoto()
  for _, value in pairs(delData) do
    if value.id == photoTempInfoArr[4] then
      deleteLocalPhoto(value)
      break
    end
  end
  albumMainData:DeleteSelectedAlbumPhoto(photoTempInfoArr[4])
end
local albumUpLoadStart = function(targetNum)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData:InitAlbumUploadCountTable(targetNum)
  albumMainData.UpLoadStateType = E.CameraUpLoadStateType.UpStart
end
local albumUpLoadSliderValue = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.AlbumUploadCountTable.currentNum = albumMainData.AlbumUploadCountTable.currentNum + 1
  Z.EventMgr:Dispatch(Z.ConstValue.Album.UpLoadSliderValue)
end
local albumUpLoadEndToClose = function()
  Z.DataMgr.Get("album_main_data").UpLoadStateType = E.CameraUpLoadStateType.UpLoadSuccess
  setIsUploadState(false)
  Z.UIMgr:CloseView("album_storage_tips")
end
local albumUpLoadEnd = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local errorNum = albumMainData.AlbumUploadCountTable.errorNum
  if 0 < errorNum then
    albumMainData.UpLoadStateType = E.CameraUpLoadStateType.UpLoadFail
    local errorData = {}
    errorData.errorNum = errorNum
    Z.UIMgr:OpenView("album_storage_tips", errorData)
  else
    albumUpLoadEndToClose()
  end
  showPhotoUploadResultTip()
end
local albumUpLoadOverTimeEnd = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.UpLoadStateType = E.CameraUpLoadStateType.UpLoadOverTime
  setIsUploadState(false)
  Z.UIMgr:CloseView("album_storage_tips")
  showPhotoUploadResultTip()
end
local checkImageAuditStatus = function(images)
  local statue = E.PictureReviewType.Success
  for _, val in pairs(images) do
    if val.reviewStartTime == E.PictureReviewType.Fail then
      statue = E.PictureReviewType.Fail
      break
    elseif val.reviewStartTime >= E.PictureReviewType.Reviewing then
      statue = E.PictureReviewType.Reviewing
    else
      statue = E.PictureReviewType.Success
    end
  end
  return statue
end
local parsingPhotoData = function(photoMap, albumId)
  local photos = {}
  if photoMap and photoMap.photoGraphs then
    for _, value in pairs(photoMap.photoGraphs) do
      local photoDesc = string.zsplit(value.photoDesc, "|")
      local photoData = {}
      photoData.albumId = albumId or 0
      photoData.id = value.photoId
      photoData.renderedInfo = value.renderInfo
      photoData.shotTimeTimeStamp = tonumber(photoDesc[1])
      photoData.shotTimeStr = photoDesc[2]
      photoData.shotPlaceStr = photoDesc[3]
      for _, photoValue in pairs(value.images) do
        if photoValue.type == E.PictureType.ECameraOriginal then
          photoData.originalUrl = photoValue.cosUrl
        elseif photoValue.type == E.PictureType.ECameraRender then
          photoData.renderedUrl = photoValue.cosUrl
        elseif photoValue.type == E.PictureType.ECameraThumbnail then
          photoData.thumbnailUrl = photoValue.cosUrl
        else
          logError("\231\155\184\229\134\140\229\155\190\231\137\135\230\178\161\230\156\137\229\175\185\229\186\148\231\154\132\229\155\190\231\137\135\231\177\187\229\158\139\239\188\129")
        end
      end
      photoData.reviewStartTime = checkImageAuditStatus(value.images)
      photos[#photos + 1] = photoData
    end
    table.sort(photos, function(left, right)
      if left.shotTimeTimeStamp > right.shotTimeTimeStamp then
        return true
      end
      return false
    end)
  end
  return photos
end
local asyncGetAlbumPhotos = function(albumId, token)
  local charId = Z.ContainerMgr.CharSerialize.charId
  if not charId or not albumId then
    return
  end
  local photoGraphProxy = require("zproxy.photograph_proxy")
  local requestData = {albumId = albumId, charId = charId}
  local ret = photoGraphProxy.GetAlbumPhotos(requestData, token)
  logPbError(ret)
  return parsingPhotoData(ret, albumId)
end
local checkIsAllUploadError = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local targetNum = albumMainData.AlbumUploadCountTable.targetNum
  local errorNum = albumMainData.AlbumUploadCountTable.errorNum
  return errorNum == targetNum
end
local upLoadResultFunc = function(request, token)
  Z.CoroUtil.create_coro_xpcall(function()
    local photographProxy = require("zproxy.photograph_proxy")
    local ret = photographProxy.UploadPhotoSuccessful(request, token)
    logPbError(ret)
  end)()
end
local upLoadPhotograph = function(token)
  logPbError(token)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local albumVm = Z.VMMgr.GetVM("album_main")
  if token == nil or token.errCode ~= 0 then
    albumVm.AlbumUpLoadErrorCollection(E.CameraUpLoadErrorType.CommonError, nil)
    if checkIsAllUploadError() then
      albumMainData:ResetUploadCount()
      albumVm.AlbumUpLoadEnd()
    end
    return
  end
  albumMainData.CurrentUploadPhotoCount = albumMainData.CurrentUploadPhotoCount + 1
  if albumMainData.CurrentUploadPhotoCount == albumMainData.TargetUploadPhotoCount then
    dispatchEvent(Z.ConstValue.Album.GetUploadPhotographTokenSuccess, token)
    albumMainData:ResetUploadCount()
  end
  local result = token.result
  local cosKeys = token.cosKeys
  if result and cosKeys and next(cosKeys) then
    for k, v in pairs(cosKeys) do
      local file = io.open(v.extraInfo, "rb")
      if not file then
        return nil
      end
      local content = file:read("*a")
      file:close()
      local func = function(isSuccess)
        if isSuccess then
          local ownerId = Z.ContainerMgr.CharSerialize.charBase.charId or 0
          if token.funcType == E.PlatformFuncType.UnionPhoto then
            local unionVM = Z.VMMgr.GetVM("union")
            ownerId = unionVM.GetPlayerUnionId()
          end
          local version = result.version ~= nil and result.version or 0
          local request = {
            charId = Z.ContainerMgr.CharSerialize.charBase.charId,
            pictureId = result.pictureId,
            funcType = token.funcType,
            ownerId = ownerId,
            data = {
              {
                pictureUrl = v.cosKey,
                version = version,
                pictureType = v.type
              }
            }
          }
          upLoadResultFunc(request, albumMainData.CancelSource:CreateToken())
        end
      end
      local uploadParm = Z.UploadParm.New()
      uploadParm.TmpSecretId = result.tmpSecretId
      uploadParm.TmpSecretKey = result.tmpSecretKey
      uploadParm.Region = result.region
      uploadParm.TmpToken = result.tmpToken
      uploadParm.ExpireTime = result.expiredTime
      uploadParm.CallBackFunc = func
      uploadParm.Bucket = result.bucket
      uploadParm.SaveKey = v.cosKey
      Z.UploadMgr:UploadPicture(Z.UploadPlatform.Cos, uploadParm, content)
    end
  end
end
local getAlbumMaxNum = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local maxNum = albumMainData.AlbumPhotoMaxNum
  if checkSubTypeIsUnion() then
    local unionVM = Z.VMMgr.GetVM("union")
    maxNum = unionVM:GetUnionAlbumMaxNum()
  end
  return maxNum
end
local initUploadData = function(photoUploadData)
  local imageInfoList = {}
  if not photoUploadData or not next(photoUploadData) then
    return
  end
  if photoUploadData.uploadType == E.PhotoUpLoadType.FullUpload then
    local originalImageData = {
      name = photoUploadData.originalData.name,
      type = E.PictureType.ECameraOriginal,
      size = photoUploadData.originalData.size,
      extraInfo = photoUploadData.originalData.extraInfo
    }
    table.insert(imageInfoList, originalImageData)
  end
  local effectImageData = {
    name = photoUploadData.effectData.name,
    type = E.PictureType.ECameraRender,
    size = photoUploadData.effectData.size,
    extraInfo = photoUploadData.effectData.extraInfo
  }
  table.insert(imageInfoList, effectImageData)
  local thumbnailImageData = {
    name = photoUploadData.thumbnailData.name,
    type = E.PictureType.ECameraThumbnail,
    size = photoUploadData.thumbnailData.size,
    extraInfo = photoUploadData.thumbnailData.extraInfo
  }
  table.insert(imageInfoList, thumbnailImageData)
  local textVal = ""
  if photoUploadData.renderInfo then
    local renderInfo = cjson.decode(photoUploadData.renderInfo)
    if renderInfo and renderInfo.decorateData and next(renderInfo.decorateData) then
      for k, v in pairs(renderInfo.decorateData) do
        if v.textValue then
          textVal = v.textValue
          break
        end
      end
    end
  end
  local requestData = {
    photoId = photoUploadData.photoId,
    renderInfo = photoUploadData.renderInfo,
    albumId = photoUploadData.albumId,
    imagesInfo = imageInfoList,
    photoDesc = photoUploadData.photoDesc,
    funcType = photoUploadData.funcType,
    ownerId = photoUploadData.ownerId,
    text = textVal
  }
  return requestData
end
local getAlbumShotPlaceName = function(sceneId)
  local placeName = ""
  local sceneRow = Z.TableMgr.GetTable("SceneTableMgr").GetRow(sceneId)
  if sceneRow then
    return sceneRow.Name
  end
  return placeName
end
local getPhoto = function(charId, photoId, cancelToken)
  local request = {charId = charId, photoId = photoId}
  local photographProxy = require("zproxy.photograph_proxy")
  local ret = photographProxy.GetPhoto(request, cancelToken)
  logPbError(ret)
  return ret
end
local checkUnionPlayerPower = function(powerId)
  local unionVM = Z.VMMgr.GetVM("union")
  return unionVM:CheckPlayerPower(powerId)
end
local replacePhotoToTempAlbum = function(originalTextureId, effectUrl, effectThemUrl, decorateInfo)
  Z.LsqLiteMgr.CreateTable("album_info")
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    tempPhotoCache = {}
    tempPhotoCache.tempPhotoCacheDict = {}
  end
  local oriInfo = tempPhotoCache.tempPhotoCacheDict[originalTextureId]
  if not oriInfo then
    return
  end
  Z.CameraFrameCtrl:DeleteTextureToSystemAlbum(oriInfo.tempPhoto)
  oriInfo.tempPhoto = effectUrl
  oriInfo.tempThumbPhoto = effectThemUrl
  oriInfo.shotTime = Z.ServerTime:GetServerTime()
  oriInfo.shotTimeStr = Z.CameraFrameCtrl:GetTextureCreateTime(effectUrl)
  oriInfo.decorateData = decorateInfo
  tempPhotoCache.tempPhotoCacheDict[originalTextureId] = oriInfo
  Z.LsqLiteMgr.UpdataData("album_info", "zproto.tempPhotoCache", roleKey, tempPhotoCache)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local oldData = albumMainData:GetCurrentShowPhotoData()
  if oldData then
    oldData.tempPhoto = oriInfo.tempPhoto
    oldData.tempOriPhoto = oriInfo.tempOriPhoto
    oldData.tempThumbPhoto = oriInfo.tempThumbPhoto
    oldData.shotTime = oriInfo.shotTime
    oldData.shotTimeStr = oriInfo.shotTimeStr
    oldData.decorateData = oriInfo.decorateData
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Album.PhotoEditSuccess)
end
local replacePhotoToCloudAlbum = function(cloudPhotoSecondData)
  if not cloudPhotoSecondData or not next(cloudPhotoSecondData) then
    return
  end
  local effiBaseinfo = Z.CameraFrameCtrl:GetTextureBaseInfo(cloudPhotoSecondData.effectTexturePath)
  local tempThumbPhotoinfo = Z.CameraFrameCtrl:GetTextureBaseInfo(cloudPhotoSecondData.effectTextureThumbPath)
  local oriInfoArr = string.split(effiBaseinfo, "|")
  local ThumbInfoArr = string.split(tempThumbPhotoinfo, "|")
  local shotTime = Z.ServerTime:GetServerTime()
  local shotTimeStr = Z.CameraFrameCtrl:GetTextureCreateTime(cloudPhotoSecondData.effectTexturePath)
  local albumMainVm = Z.VMMgr.GetVM("album_main")
  local effectData = {
    name = oriInfoArr[1],
    size = tonumber(oriInfoArr[2]),
    extraInfo = cloudPhotoSecondData.effectTexturePath
  }
  local thumbnailData = {
    name = ThumbInfoArr[1],
    size = tonumber(ThumbInfoArr[2]),
    extraInfo = cloudPhotoSecondData.effectTextureThumbPath
  }
  local photoDesc = string.format("%s|%s|%s|%s", shotTime, shotTimeStr, cloudPhotoSecondData.shotPlace, cloudPhotoSecondData.photoId)
  local uploadData = {
    uploadType = E.PhotoUpLoadType.ThumbnailAndEffectUpload,
    photoId = cloudPhotoSecondData.photoId,
    originalData = nil,
    effectData = effectData,
    thumbnailData = thumbnailData,
    renderInfo = cloudPhotoSecondData.decorateInfo,
    albumId = cloudPhotoSecondData.albumId,
    photoDesc = photoDesc,
    funcType = E.PlatformFuncType.Photograph,
    ownerId = Z.ContainerMgr.CharSerialize.charBase.charId or 0
  }
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.UploadType = E.PhotoUpLoadType.ThumbnailAndEffectUpload
  albumMainData.CurrentUploadSourceType = E.PlatformFuncType.Photograph
  local requestData = initUploadData(uploadData)
  if requestData and next(requestData) then
    Z.CoroUtil.create_coro_xpcall(function()
      albumMainVm.AsyncUploadPhotoRequestToken(requestData, cloudPhotoSecondData.renderToken)
    end)()
  end
end
local refreshCloudAlbumShowCache = function(uploadPhotoData)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local currentShowData = albumMainData:GetCurrentShowPhotoData()
  if uploadPhotoData and currentShowData and uploadPhotoData.images then
    for _, image in ipairs(uploadPhotoData.images) do
      if image.type == E.PictureType.ECameraRender then
        currentShowData.renderedUrl = image.cosUrl
      elseif image.type == E.PictureType.ECameraThumbnail then
        currentShowData.thumbnailUrl = image.cosUrl
      end
    end
    currentShowData.renderedInfo = uploadPhotoData.renderInfo
  end
end
local initUploadPhotoData = function(photoData, albumId, funcType, ownerId)
  local oriBaseinfo = Z.CameraFrameCtrl:GetTextureBaseInfo(photoData.tempOriPhoto)
  local oriInfoArr = string.split(oriBaseinfo, "|")
  local effiBaseinfo = Z.CameraFrameCtrl:GetTextureBaseInfo(photoData.tempPhoto)
  local effectInfoArr = string.split(effiBaseinfo, "|")
  local tempThumbPhotoinf = Z.CameraFrameCtrl:GetTextureBaseInfo(photoData.tempThumbPhoto)
  local thumbInfoArr = string.split(tempThumbPhotoinf, "|")
  local photoDesc = string.format("%s|%s|%s|%s", photoData.shotTime, photoData.shotTimeStr, photoData.shotPlace, photoData.id)
  if oriInfoArr == nil or #oriInfoArr < 2 or effectInfoArr == nil or #effectInfoArr < 2 or thumbInfoArr == nil or #thumbInfoArr < 2 then
    return
  end
  local originalData = {
    name = oriInfoArr[1],
    size = tonumber(oriInfoArr[2]),
    extraInfo = photoData.tempOriPhoto
  }
  local effectData = {
    name = effectInfoArr[1],
    size = tonumber(effectInfoArr[2]),
    extraInfo = photoData.tempPhoto
  }
  local thumbnailData = {
    name = thumbInfoArr[1],
    size = tonumber(thumbInfoArr[2]),
    extraInfo = photoData.tempThumbPhoto
  }
  local uploadData = {
    uploadType = E.PhotoUpLoadType.FullUpload,
    photoId = 0,
    originalData = originalData,
    effectData = effectData,
    thumbnailData = thumbnailData,
    renderInfo = photoData.decorateData,
    albumId = albumId,
    photoDesc = photoDesc,
    funcType = funcType,
    ownerId = ownerId
  }
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.UploadType = E.PhotoUpLoadType.FullUpload
  local requestData = initUploadData(uploadData)
  return requestData
end
local showMobileAlbumView = function(data)
  Z.UIMgr:OpenView("album_mobile_album", data)
end
local closeMobileAlbumView = function()
  if Z.UIMgr:IsActive("album_mobile_album") then
    Z.UIMgr:CloseView("album_mobile_album")
  end
end
local closeCameraPhotoDetailsView = function()
  if Z.UIMgr:IsActive("camera_photo_details") then
    Z.UIMgr:CloseView("camera_photo_details")
  end
end
local showAlbumCreatePopupView = function(albumPopupType, jurisType, albumId, name, isUnion)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local viewData = {}
  viewData.albumPopupType = albumPopupType
  viewData.jurisType = jurisType and jurisType or E.AlbumJurisdictionType.All
  viewData.albumId = albumId
  viewData.name = name and name ~= "" and name or albumMainData.CloudAlbumName
  viewData.isUnion = isUnion
  Z.UIMgr:OpenView("album_create_popup", viewData)
end
local openCameraPhotoAlbumView = function()
  Z.UIMgr:OpenView("camera_photo_album_window")
end
local openView = function(data)
  if data then
    if type(data) == "number" or type(data) == "string" then
      data = tonumber(data)
    else
      data = tonumber(data.openSource)
      local albumMainData = Z.DataMgr.Get("album_main_data")
      albumMainData.EScreenId = tonumber(data.screenId)
    end
  end
  Z.UIMgr:OpenView("album_main", data)
end
local asyncGetUnionTmpAlbumPhotos = function(token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local request = {unionId = unionId}
  local ret = worldProxy.GetTmpAlbumPhotos(request, token)
  if ret and ret.errCode == 0 then
    return parsingPhotoData(ret)
  end
  logPbError(ret)
  return
end
local asyncGetUnionAllAlbums = function(token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {unionId = unionId}
  local ret = worldProxy.GetUnionAllAlbum(requestData, token)
  logPbError(ret)
  return ret
end
local asyncGetUnionAlbumPhotos = function(albumId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 or not albumId then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {unionId = unionId, albumId = albumId}
  local ret = worldProxy.GetUnionAlbumPhotos(requestData, token)
  logPbError(ret)
  return parsingPhotoData(ret, albumId)
end
local asyncCopySelfPhotoToUnionTmpAlbum = function(photoId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 or not photoId then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {unionId = unionId, photoId = photoId}
  local ret = worldProxy.CopySelfPhotoToUnionTmpAlbum(requestData, token)
  logPbError(ret)
  return ret
end
local asyncSetUnionCoverPhoto = function(token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  if unionId == 0 or not albumMainData.SelectedUnionAlbumPhoto then
    return
  end
  local requestData = {
    unionId = unionId,
    photoId = albumMainData.SelectedUnionAlbumPhoto.id
  }
  local errCode = worldProxy.SetUnionCoverPhoto(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncSetUnionAlbumCover = function(albumId, photoId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 or not photoId then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {
    unionId = unionId,
    photoId = photoId,
    albumId = albumId
  }
  local errCode = worldProxy.SetUnionAlbumCover(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncCreateUnionAlbum = function(name, access, token, callback)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {
    unionId = unionId,
    name = name,
    access = access
  }
  local ret = worldProxy.CreateUnionAlbum(requestData, token)
  if (not ret or ret.errCode ~= 0) and callback then
    callback(ret.errCode)
  end
  dispatchEvent(Z.ConstValue.Album.CreateAlbum, ret)
  return ret
end
local asyncMovePhotoToUnionAlbum = function(photoId, albumId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {
    unionId = unionId,
    photoId = photoId,
    albumId = albumId
  }
  local errCode = worldProxy.MovePhotoToUnionAlbum(requestData, token)
  logErrCode(errCode)
  dispatchEvent(Z.ConstValue.Album.CloudAlbumPhotosDataUpdate, errCode)
  return errCode
end
local asyncDeleteUnionPhoto = function(photoId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {unionId = unionId, photoId = photoId}
  local errCode = worldProxy.DeleteUnionPhoto(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncDeleteUnionAlbum = function(albumId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 or not albumId then
    return
  end
  local requestData = {unionId = unionId, albumId = albumId}
  local errCode = worldProxy.DeleteUnionAlbum(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncMoveTmpPhotoToAlbum = function(photoId, albumId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {
    unionId = unionId,
    tmpPhotoId = photoId,
    albumId = albumId
  }
  local errCode = worldProxy.MoveTmpPhotoToAlbum(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncDeleteUnionTmpPhoto = function(photoId, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {unionId = unionId, photoId = photoId}
  local errCode = worldProxy.DeleteUnionTmpPhoto(requestData, token)
  logErrCode(errCode)
  return errCode
end
local asyncEditUnionAlbumName = function(albumId, name, token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    logGreen("Did not join the guild!")
    return
  end
  local requestData = {
    unionId = unionId,
    albumId = albumId,
    name = name
  }
  local ret = worldProxy.EditUnionAlbumName(requestData, token)
  logPbError(ret)
  dispatchEvent(Z.ConstValue.Album.AlbumDataUpdate, ret)
  return ret
end
local getUnionAllPhotoCount = function(allAlbumData)
  local count = 0
  if allAlbumData and next(allAlbumData) then
    for k, v in pairs(allAlbumData) do
      count = count + table.zcount(v.photoIds)
    end
  end
  return count
end
local setUnionElectronicScreen = function()
end
local checkUnionElectronicScreen = function(photoId)
  local albumMainData = Z.DataMgr.Get("album_main_data")
  for k, v in pairs(albumMainData.SelectedUnionElectronicScreen) do
    if v == photoId then
      return true
    end
  end
  return false
end
local asyncSetUnionElectronicScreenPhoto = function(token, eScreenId)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  if unionId == 0 then
    return
  end
  local tempList = {}
  for k, v in pairs(albumMainData.SelectedUnionElectronicScreen) do
    table.insert(tempList, v)
  end
  local requestData = {
    unionId = unionId,
    eScreenId = eScreenId,
    photoIdList = tempList
  }
  local ret = worldProxy.SetUnionEScreenPhoto(requestData, token)
  logPbError(ret)
  if ret.errCode == 0 then
    albumMainData.EScreenPhotoSetCount.cur = ret.curSetTimes
    albumMainData.EScreenPhotoSetCount.max = ret.maxSetTimes
    Z.EventMgr:Dispatch(Z.ConstValue.Album.UnionSetScreenCountUpdate)
  end
  return ret
end
local asyncGetUnionElectronicScreenPhoto = function(token)
  local unionVM = Z.VMMgr.GetVM("union")
  local unionId = unionVM:GetPlayerUnionId()
  if unionId == 0 then
    return
  end
  local requestData = {unionId = unionId}
  local ret = worldProxy.GetUnionEScreenList(requestData, token)
  logPbError(ret)
  return ret
end
local parserUnionEScreenInfo = function(eScreenInfo, eScreenId)
  if not eScreenInfo then
    return
  end
  local albumMainData = Z.DataMgr.Get("album_main_data")
  albumMainData.EScreenPhotoSetCount.cur = eScreenInfo.curSetTimes
  albumMainData.EScreenPhotoSetCount.max = eScreenInfo.maxSetTimes
  if eScreenInfo.eScreenList and next(eScreenInfo.eScreenList) then
    local unionScreenData = {}
    for k, v in pairs(eScreenInfo.eScreenList) do
      if v.eScreenId == eScreenId then
        unionScreenData = v.photoGraphs
        break
      end
    end
    if next(unionScreenData) then
      for k, v in pairs(unionScreenData) do
        albumMainData:AddUnionElectronicScreenSelectedPhoto(v.photoId)
        albumMainData.CacheUnionElectronicScreen[v.photoId] = v.photoId
      end
    end
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Album.UnionSetScreenCountUpdate)
end
local checkUnionElectronicIsChange = function()
  local albumMainData = Z.DataMgr.Get("album_main_data")
  local isChange = false
  for k, v in pairs(albumMainData.SelectedUnionElectronicScreen) do
    local photoId = albumMainData.CacheUnionElectronicScreen[k]
    if not photoId or photoId ~= v then
      isChange = true
      break
    end
  end
  for k, v in pairs(albumMainData.CacheUnionElectronicScreen) do
    local photoId = albumMainData.SelectedUnionElectronicScreen[k]
    if not photoId or photoId ~= v then
      isChange = true
      break
    end
  end
  return isChange
end
local ret = {
  DeleteLocalPhoto = deleteLocalPhoto,
  AsyncCreateAlbum = asyncCreateAlbum,
  AsyncDeleteAlbum = asyncDeleteAlbum,
  AsyncEditAlbumRight = asyncEditAlbumRight,
  AsyncEditAlbumName = asyncEditAlbumName,
  AsyncMovePhotoOtherAlbum = asyncMovePhotoOtherAlbum,
  AsyncDeleteServePhoto = asyncDeleteServePhoto,
  CreateAlbumDefaultName = createAlbumDefaultName,
  CheckTempAlbumPhotoSafe = checkTempAlbumPhotoSafe,
  ClearUnSafeAlbumPhoto = clearUnSafeAlbumPhoto,
  AsyncGetHttpAlbumPhoto = asyncGetHttpAlbumPhoto,
  AsyncSetAlbumCover = asyncSetAlbumCover,
  AlbumUpLoadSliderValue = albumUpLoadSliderValue,
  AsynHttpCacheToAlbumPhoto = asynHttpCacheToAlbumPhoto,
  AsynHttpCachePhoto = asynHttpCachePhoto,
  AlbumUpLoadStart = albumUpLoadStart,
  AlbumUpLoadEnd = albumUpLoadEnd,
  AlbumUpLoadOverTimeEnd = albumUpLoadOverTimeEnd,
  AlbumUpLoadErrorCollection = albumUpLoadErrorCollection,
  ShowMobileAlbumView = showMobileAlbumView,
  CloseMobileAlbumView = closeMobileAlbumView,
  AsyncGetAllAlbums = asyncGetAllAlbums,
  AsyncGetAlbumPhotos = asyncGetAlbumPhotos,
  AsyncUploadPhotoRequestToken = asyncUploadPhotoRequestToken,
  UpLoadPhotograph = upLoadPhotograph,
  DeleteTemporaryAlbumData = deleteTemporaryAlbumData,
  CloseCameraPhotoDetailsView = closeCameraPhotoDetailsView,
  SetIsUploadState = setIsUploadState,
  GetAlbumShotPlaceName = getAlbumShotPlaceName,
  ShowAlbumCreatePopupView = showAlbumCreatePopupView,
  OpenCameraPhotoAlbumView = openCameraPhotoAlbumView,
  ReplacePhotoToTempAlbum = replacePhotoToTempAlbum,
  ReplacePhotoToCloudAlbum = replacePhotoToCloudAlbum,
  RefreshCloudAlbumShowCache = refreshCloudAlbumShowCache,
  ReplacePhotoPathToCache = replacePhotoPathToCache,
  InitUploadPhotoData = initUploadPhotoData,
  GetPhoto = getPhoto,
  CheckIsShowUnion = checkIsShowUnion,
  CheckUnionPlayerPower = checkUnionPlayerPower,
  CheckSubTypeIsUnion = checkSubTypeIsUnion,
  GetAlbumMaxNum = getAlbumMaxNum,
  OpenView = openView,
  AsyncGetUnionTmpAlbumPhotos = asyncGetUnionTmpAlbumPhotos,
  AsyncGetUnionAllAlbums = asyncGetUnionAllAlbums,
  AsyncGetUnionAlbumPhotos = asyncGetUnionAlbumPhotos,
  AsyncCopySelfPhotoToUnionTmpAlbum = asyncCopySelfPhotoToUnionTmpAlbum,
  AsyncSetUnionCoverPhoto = asyncSetUnionCoverPhoto,
  AsyncSetUnionAlbumCover = asyncSetUnionAlbumCover,
  AsyncCreateUnionAlbum = asyncCreateUnionAlbum,
  AsyncMovePhotoToUnionAlbum = asyncMovePhotoToUnionAlbum,
  AsyncDeleteUnionPhoto = asyncDeleteUnionPhoto,
  AsyncDeleteUnionAlbum = asyncDeleteUnionAlbum,
  AsyncMoveTmpPhotoToAlbum = asyncMoveTmpPhotoToAlbum,
  AsyncDeleteUnionTmpPhoto = asyncDeleteUnionTmpPhoto,
  AsyncEditUnionAlbumName = asyncEditUnionAlbumName,
  CheckUnionElectronicScreen = checkUnionElectronicScreen,
  AsyncSetUnionElectronicScreenPhoto = asyncSetUnionElectronicScreenPhoto,
  AsyncGetUnionElectronicScreenPhoto = asyncGetUnionElectronicScreenPhoto,
  ParserUnionEScreenInfo = parserUnionEScreenInfo,
  CheckUnionElectronicIsChange = checkUnionElectronicIsChange,
  GetUnionAllPhotoCount = getUnionAllPhotoCount
}
return ret
