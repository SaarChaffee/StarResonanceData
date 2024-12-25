local super = require("ui.model.data_base")
local AlbumMainData = class("AlbumMainData", super)

function AlbumMainData:ctor()
  super.ctor(self)
  self.selectedAlbumPhoto_ = {}
  self.selectedAlbumNumber_ = 0
  self.temporaryAlbumPhoto_ = {}
  self.temporaryAlbumPhotoUnSafa_ = {}
  self.cloudAlbumPhoto_ = {}
  self.cloudAlbumPhotosData_ = {}
  self.cloudAlbumPhotoUnSafa_ = {}
  self.IsMoveAlbum = false
  self.SelectType = E.AlbumSelectType.Normal
  self.AlbumSelectType = E.AlbumSelectType.Normal
  self.TemporaryPhotoMaxNum = Z.Global.PhotoAlbum_MaxTempPhotoNum
  self.AlbumPhotoMaxNum = Z.Global.PhotoAlbum_MaxCloudPhotoNum
  self.AlbumMaxNum = Z.Global.PhotoAlbum_MaxAlbumNum
  self.CloudAlbumName = Lang("CouldAlbum")
  self.MaxAlbumNameLength = Z.Global.PhotoAlbum_MaxAlbumNameLength
  self.MaxCouldPhotoNum = Z.Global.PhotoAlbum_MaxCloudPhotoNum
  self.UpLoadStateType = E.CameraUpLoadStateType.DefaultState
  self.AlbumUploadCountTable = {}
  self.CurrentUploadPhotoCount = 0
  self.TargetUploadPhotoCount = 0
  self.CurrentUploadSourceType = E.PlatformFuncType.Photograph
  self.IsUpLoadState = false
  self.currentShowPhotoData_ = nil
  self.AlbumOpenSource = E.AlbumOpenSource.Album
  self.ContainerType = E.AlbumMainState.Temporary
  self.SelectedUnionAlbumPhoto = nil
  self.SelectedUnionElectronicScreen = {}
  self.CacheUnionElectronicScreen = {}
  self.EScreenId = -1
  self.EScreenPhotoSetCount = {cur = 0, max = 0}
  self.albumDefaultTab_ = nil
  self.UploadType = E.PhotoUpLoadType.FullUpload
end

function AlbumMainData:Init()
  self.CancelSource = Z.CancelSource.Rent()
end

function AlbumMainData:UnInit()
  self.CancelSource:Recycle()
end

function AlbumMainData:InitAlbumUploadCountTable(targetNum)
  self.AlbumUploadCountTable = {}
  self.AlbumUploadCountTable.targetNum = targetNum
  self.AlbumUploadCountTable.albumId = -1
  self.AlbumUploadCountTable.currentNum = 0
  self.AlbumUploadCountTable.errorNum = 0
  self.AlbumUploadCountTable.errorDatas = {}
end

function AlbumMainData:AddSelectedAlbumPhoto(item)
  self.selectedAlbumPhoto_[item.id] = item
end

function AlbumMainData:DeleteSelectedAlbumPhoto(photoId)
  self.selectedAlbumPhoto_[photoId] = nil
end

function AlbumMainData:GetSelectedAlbumPhoto()
  return self.selectedAlbumPhoto_
end

function AlbumMainData:GetSelectedAlbumNumber()
  self.selectedAlbumNumber_ = table.zcount(self.selectedAlbumPhoto_)
  return self.selectedAlbumNumber_
end

function AlbumMainData:ClearSelectedAlbumPhoto()
  self.selectedAlbumPhoto_ = {}
  self.selectedAlbumNumber_ = 0
  self.UploadType = E.PhotoUpLoadType.FullUpload
end

function AlbumMainData:GetTemporaryAlbumPhoto()
  local roleKey = string.format("%s", Z.EntityMgr.PlayerUuid)
  local tempPhotoCache = Z.LsqLiteMgr.GetDataByKey("album_info", "zproto.tempPhotoCache", roleKey)
  if not tempPhotoCache or not next(tempPhotoCache) then
    tempPhotoCache = {}
    tempPhotoCache.tempPhotoCacheDict = {}
  end
  self.temporaryAlbumPhoto_ = tempPhotoCache.tempPhotoCacheDict
  local vm = Z.VMMgr.GetVM("album_main")
  local temp = {}
  for _, value in pairs(self.temporaryAlbumPhoto_) do
    local isSafa = vm.CheckTempAlbumPhotoSafe(value)
    if isSafa then
      temp[#temp + 1] = value
    else
      self.temporaryAlbumPhotoUnSafa_[#self.temporaryAlbumPhotoUnSafa_ + 1] = value
    end
  end
  vm.ClearUnSafeAlbumPhoto(self.temporaryAlbumPhotoUnSafa_)
  return temp
end

function AlbumMainData:AddTempPhotoData(key, value)
  self.temporaryAlbumPhoto_[key] = value
end

function AlbumMainData:DeleteTempPhotoData(key)
  if not self.temporaryAlbumPhoto_[key] then
    return
  end
  self.temporaryAlbumPhoto_[key] = nil
end

function AlbumMainData:GetCloudAlbumPhoto()
  return self.cloudAlbumPhoto_
end

function AlbumMainData:GetAlbumCover(albumId)
  local albumInfo = self:GetAlbumAllDataById(albumId)
  if not albumInfo or #albumInfo.photoIds <= 0 or albumInfo.coverPhotoId == 0 then
    return nil
  end
  return albumInfo.coverThumbnailInfo
end

function AlbumMainData:SetAlbumAllData(albumData)
  self:ClearAlbumAllData()
  if albumData and 0 < #albumData then
    for _, value in pairs(albumData) do
      self.cloudAlbumPhoto_[#self.cloudAlbumPhoto_ + 1] = value
    end
    table.sort(self.cloudAlbumPhoto_, function(left, right)
      if left.albumId < right.albumId then
        return true
      end
      return false
    end)
  end
  return self.cloudAlbumPhoto_
end

function AlbumMainData:UpdateAlbumAllData(albumData)
  if not albumData then
    return
  end
  local isHave = false
  for _, value in pairs(self.cloudAlbumPhoto_) do
    if value.albumId == albumData.albumId then
      value = albumData
      isHave = true
      break
    end
  end
  if not isHave then
    self.cloudAlbumPhoto_[#self.cloudAlbumPhoto_ + 1] = albumData
    table.sort(self.cloudAlbumPhoto_, function(left, right)
      if left.albumId < right.albumId then
        return true
      end
      return false
    end)
  end
  return self.cloudAlbumPhoto_
end

function AlbumMainData:GetAlbumAllDataById(albumId)
  if not next(self.cloudAlbumPhoto_) then
    return nil
  end
  for _, value in pairs(self.cloudAlbumPhoto_) do
    if value.albumId == albumId then
      return value
    end
  end
  return nil
end

function AlbumMainData:GetAlbumAllData()
  return self.cloudAlbumPhoto_
end

function AlbumMainData:Clear()
  self:ClearAlbumAllData()
  self:ClearCurrentAlbumPhotosData()
  self:ResetUploadCount()
  self.CurrentUploadSourceType = E.PlatformFuncType.Photograph
  self.IsUpLoadState = false
  self.currentShowPhotoData_ = nil
  self.SelectedUnionAlbumPhoto = nil
  self.SelectedUnionElectronicScreen = {}
  self.CacheUnionElectronicScreen = {}
  self.EScreenId = -1
  self.EScreenPhotoSetCount = {cur = 0, max = 0}
end

function AlbumMainData:ResetUploadCount()
  self.CurrentUploadPhotoCount = 0
  self.TargetUploadPhotoCount = 0
end

function AlbumMainData:ClearAlbumAllData()
  self.cloudAlbumPhoto_ = {}
end

function AlbumMainData:ClearCurrentAlbumPhotosData()
  self.cloudAlbumPhotosData_ = {}
end

function AlbumMainData:GetCurrentAlbumAllPhotosData()
  return self.cloudAlbumPhotosData_
end

function AlbumMainData:GetCurrentAlbumPhotosDataById(photoId)
  if photoId then
    for _, v in pairs(self.cloudAlbumPhotosData_) do
      if v.id == photoId then
        return v
      end
    end
  end
  return nil
end

function AlbumMainData:SetCurrentAlbumPhotosData(allPhotoData)
  if allPhotoData then
    self.cloudAlbumPhotosData_ = allPhotoData
  end
end

function AlbumMainData:GetPhotoAllNumber()
  local count = 0
  for k, v in pairs(self.cloudAlbumPhoto_) do
    for i, j in pairs(v.photoIds) do
      count = count + 1
    end
  end
  return count
end

function AlbumMainData:SetCurrentShowPhotoData(showPhotoData)
  self.currentShowPhotoData_ = showPhotoData
end

function AlbumMainData:GetCurrentShowPhotoData()
  return self.currentShowPhotoData_
end

function AlbumMainData:AddUnionElectronicScreenSelectedPhoto(photoId)
  self.SelectedUnionElectronicScreen[photoId] = photoId
end

function AlbumMainData:DeleteUnionElectronicScreenSelectedPhoto(photoId)
  self.SelectedUnionElectronicScreen[photoId] = nil
end

function AlbumMainData:GetAlbumDefaultTab()
  return self.albumDefaultTab_
end

function AlbumMainData:SetAlbumDefaultTab(albumTab)
  self.albumDefaultTab_ = albumTab
end

return AlbumMainData
