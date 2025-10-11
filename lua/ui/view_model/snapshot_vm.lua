local headSnapshotData = Z.DataMgr.Get("head_snapshot_data")
local socialVM = Z.VMMgr.GetVM("social")
local switch_vm = Z.VMMgr.GetVM("switch")
local downloadVm = Z.VMMgr.GetVM("download")
local gapTime = Z.Global.PostSnapshotToHttpGap
local getServerTime = function(time)
  if gapTime == nil or gapTime <= 0 then
    gapTime = 60
  end
  local nowTime = math.floor(Z.ServerTime:GetServerTime() / 1000)
  if time == 0 or time == nil then
    return nowTime
  else
    local diffTime = Z.TimeTools.DiffTime(nowTime, time)
    if diffTime > gapTime then
      return nowTime
    else
      return 0
    end
  end
end
local getFilePathTextureId = function(folderName, fileName, size)
  return Z.SnapShotMgr:GetFilePathTextureId(folderName, fileName, size, E.NativeTextureCallToken.CommonPlayerPortraitItem)
end
local saveTextureToLocal = function(folderName, fileName, textureId)
  Z.SnapShotMgr:SavePortraitToLoacl(folderName, fileName, textureId)
end
local removeOldTexture = function(headInfoData)
  if headInfoData == nil then
    return
  end
  Z.SnapShotMgr:RemoveTexture(headInfoData.textureId)
end
local asyncGetProfileInfo = function(charId)
  if headSnapshotData.IsOpenSnapshot == false then
    return nil
  end
  local cancelSource = Z.SnapShotMgr:GetCancelSource()
  return socialVM.AsyncGetAvatarInfo(charId, cancelSource:CreateToken())
end
local upLoadResultFunc = function(request, token)
  Z.CoroUtil.create_coro_xpcall(function()
    local photographProxy = require("zproxy.photograph_proxy")
    local ret = photographProxy.UploadPhotoSuccessful(request, token)
    Z.TipsVM.ShowTips(ret.errCode)
  end)()
end
local upLoad = function(token)
  if token == nil then
    return
  end
  local result = token.result
  if result then
    local func = function(isSuccess)
      if isSuccess then
        local ownerId = Z.ContainerMgr.CharSerialize.charBase.charId or 0
        local request = {
          charId = Z.ContainerMgr.CharSerialize.charBase.charId,
          pictureId = result.pictureId,
          funcType = E.HttpTokenType.HeadProfile,
          ownerId = ownerId,
          data = {
            {
              pictureUrl = result.objectKey,
              version = result.version,
              pictureType = headSnapshotData.PictureIdDic[result.pictureId] or E.PictureType.EProfileSnapShot
            }
          }
        }
        upLoadResultFunc(request, headSnapshotData.CancelSource:CreateToken())
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
    uploadParm.SaveKey = result.objectKey
    Z.SnapShotMgr:PostBytes(uploadParm, result.pictureId)
  end
end
local asyncDownLoadUrlData = function(url, charId, socialData, type, callFunc)
  local cancelSource = Z.CancelSource.Rent()
  local name = downloadVm:GetFileName(charId, socialData.avatarInfo.profile.verify.version, type)
  downloadVm:GetPicture(name, url, cancelSource:CreateToken(), callFunc, type)
end
local asyncDownLoadPictureByUrl = function(url)
  local request = Z.HttpRequest.Rent()
  request.Url = url
  request.DataType = Panda.ZGame.EHttpGetDataType.ETexture
  local asyncCall = Z.CoroUtil.async_to_sync(Z.SnapShotMgr.Get)
  local nextureId = asyncCall(Z.SnapShotMgr, request)
  request:Recycle()
  return nextureId
end
local getModelHeadPortrait = function(modelId)
  local config = Z.TableMgr.GetTable("ModelTableMgr").GetRow(modelId)
  if config == nil then
    return
  end
  return config.Image
end
local openHttpPort = function()
  headSnapshotData.IsOpenSnapshot = true
end
local changeSwitchCenceState = function(state)
  headSnapshotData:SetIsSwitchScence(state)
end
local getModelHalfPortrait = function(modelId)
  local modelTableRow = Z.TableMgr.GetTable("ModelTableMgr").GetRow(modelId)
  if modelTableRow == nil then
    return
  end
  return modelTableRow.Bust
end
local getInternalHalfPortrait = function(charId, modelId)
  local halfId = headSnapshotData:GetHalfDataInfo(charId)
  if not halfId then
    return getModelHalfPortrait(modelId)
  end
  return halfId.textureId
end
local getHttpHalfPortraitId = function(charId, callback)
  if not switch_vm.CheckFuncSwitch(E.FunctionID.DisplayCustomHalfBody) then
    callback(nil)
    return
  end
  local oldTime = headSnapshotData:GetLastGetHalfTime(charId)
  local newTime = getServerTime(oldTime)
  if newTime ~= 0 then
    local socialData = asyncGetProfileInfo(charId)
    if socialData == nil or socialData.avatarInfo == nil or socialData.avatarInfo.halfBody == nil then
      callback(nil)
    end
    local halfProfile = socialData.avatarInfo.halfBody
    local url = halfProfile.url
    local size = halfProfile.verify.size
    local version = halfProfile.verify.version
    if url == "" then
      callback(nil)
      return
    end
    local matchURL = string.match(url, "^https?://[%w-_%.%?%.:/%+=&]+%.png$")
    if matchURL then
      asyncDownLoadUrlData(url, charId, socialData, E.HttpPictureDownFoldType.HalfBody, function(nativeTextureId)
        if nativeTextureId ~= nil and nativeTextureId ~= -1 then
          removeOldTexture(headSnapshotData:GetHalfDataInfo(charId))
          headSnapshotData:SetHalfTime(charId, newTime)
          headSnapshotData:SetHalfDataInfo(charId, nativeTextureId, version)
          callback(nativeTextureId)
        else
          callback(nil)
        end
      end)
      return
    end
    callback(nil)
    return
  end
  callback(nil)
end
local asyncGetHttpHalfPortraitId = function(charId, callback)
  getHttpHalfPortraitId(charId, callback)
end
local getInternalHeadPortrait = function(charId, modelId)
  local headInfoData = headSnapshotData:GetHeadDataInfo(charId)
  if not headInfoData then
    return getModelHeadPortrait(modelId)
  end
  return headInfoData.textureId
end
local getConfigHeadProtrait = function(headId)
  local config = Z.TableMgr.GetTable("ProfileImageTableMgr").GetRow(headId)
  if config ~= nil then
    return config.Image
  end
end
local getTime = function(charId)
  local newTime = 0
  local oldTime = headSnapshotData:GetLastGetHeadTime(charId)
  if oldTime ~= nil then
    newTime = getServerTime(oldTime)
  end
  return newTime
end
local getTextureId = function(charId, socialData, newTime, func)
  if not switch_vm.CheckFuncSwitch(E.FunctionID.DisplayCustomHeadPhoto) then
    func(charId, 0)
    return nil
  end
  headSnapshotData:SetHeadTime(charId, newTime)
  if socialData == nil or socialData.avatarInfo == nil or socialData.avatarInfo.profile == nil then
    func(charId, 0)
    return nil
  end
  local headProfile = socialData.avatarInfo.profile
  local url = headProfile.url
  local size = headProfile.verify.size
  local version = headProfile.verify.version
  if url == "" then
    headSnapshotData:SetHeadTime(charId, 0)
    func(charId, 0)
    return nil
  end
  headSnapshotData:SetHeadTime(charId, newTime)
  local fun = function(natvieTextureId)
    if natvieTextureId ~= nil and natvieTextureId ~= -1 then
      removeOldTexture(headSnapshotData:GetHeadDataInfo(charId))
      headSnapshotData:SetHeadDataInfo(charId, natvieTextureId)
    end
    func(charId, natvieTextureId)
  end
  asyncDownLoadUrlData(url, charId, socialData, E.HttpPictureDownFoldType.Head, fun)
end
local asyncGetHttpPortraitIdByAvatarInfo = function(charId, socialData, callBackFunc)
  local newTime = getTime(charId)
  if newTime ~= 0 then
    getTextureId(charId, socialData, newTime, callBackFunc)
  else
    callBackFunc(charId, 0)
  end
end
local asyncGetHttpPortraitId = function(charId, callBackFunc)
  local newTime = getTime(charId)
  if newTime ~= 0 then
    local socialData = asyncGetProfileInfo(charId)
    if socialData and charId == Z.ContainerMgr.CharSerialize.charId then
      headSnapshotData:SetSelfSocialData(socialData)
    end
    getTextureId(charId, socialData, newTime, callBackFunc)
  else
    callBackFunc(charId, 0)
  end
end
local asyncGetAvatarAuditData = function(charId, token, callback)
  local pahoto = require("zproxy.photograph_proxy")
  local ret = pahoto.GetReviewAvatarInfo({charId = charId}, token)
  if ret.errCode == 0 and ret.avatarInfo and ret.avatarInfo.profile then
    local tab = {}
    tab.auditing = ret.avatarInfo.profile.verify.ReviewStartTime
    asyncDownLoadUrlData(ret.avatarInfo.profile.url, charId, ret, E.HttpPictureDownFoldType.Head, function(nativeTextureId)
      tab.textureId = nativeTextureId
      callback(tab)
    end)
    return
  end
  callback(nil)
end
local ret = {
  AsyncGetHttpPortraitId = asyncGetHttpPortraitId,
  AsyncGetHttpPortraitIdByAvatarInfo = asyncGetHttpPortraitIdByAvatarInfo,
  AsyncGetHttpHalfPortraitId = asyncGetHttpHalfPortraitId,
  OpenHttpPort = openHttpPort,
  GetModelHeadPortrait = getModelHeadPortrait,
  GetModelHalfPortrait = getModelHalfPortrait,
  ChangeSwitchCenceState = changeSwitchCenceState,
  GetConfigHeadProtrait = getConfigHeadProtrait,
  GetInternalHeadPortrait = getInternalHeadPortrait,
  GetInternalHalfPortrait = getInternalHalfPortrait,
  GetServerTime = getServerTime,
  AsyncGetAvatarAuditData = asyncGetAvatarAuditData,
  UpLoad = upLoad,
  AsyncDownLoadPictureByUrl = asyncDownLoadPictureByUrl
}
return ret
