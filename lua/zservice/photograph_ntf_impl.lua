local pb = require("pb2")
local PhotographNtfStubImpl = {}

function PhotographNtfStubImpl:OnCreateStub()
end

function PhotographNtfStubImpl:GetPhotoTokenNtf(call, vRequest)
  local albumMainVm = Z.VMMgr.GetVM("album_main")
  albumMainVm.UpLoadPhotograph(vRequest)
end

function PhotographNtfStubImpl:UploadPhotoResultNtf(call, vRequest)
  local albumVm = Z.VMMgr.GetVM("album_main")
  if vRequest.errCode == 0 then
    if vRequest.funcType == E.PlatformFuncType.Photograph then
      local albumMainData = Z.DataMgr.Get("album_main_data")
      if albumMainData.UploadType == E.PhotoUpLoadType.ThumbnailAndEffectUpload then
        albumVm.ReplacePhotoPathToCache(vRequest.photoInfo)
      end
    end
    albumVm.DeleteTemporaryAlbumData(vRequest.photoInfo)
    albumVm.AlbumUpLoadSliderValue()
  else
    albumVm.AlbumUpLoadErrorCollection(E.CameraUpLoadErrorType.CommonError, nil)
  end
end

function PhotographNtfStubImpl:UploadPictureResultNtf(call, vRequest)
  if vRequest.errCode == 0 then
    Z.TipsVM.ShowTips(1000033)
    Z.EventMgr:Dispatch(Z.ConstValue.Camera.HeadUpLoadSuccess)
  else
    Z.TipsVM.ShowTips(vRequest.errCode)
  end
end

function PhotographNtfStubImpl:RetAvatarToken(call, vRequest)
  if vRequest.errCode == 0 then
    local snpshotVm = Z.VMMgr.GetVM("snapshot")
    snpshotVm.UpLoad(vRequest)
  else
    Z.TipsVM.ShowTips(vRequest.errCode)
  end
end

function PhotographNtfStubImpl:ReviewAvatarInfoNtf(call, vRequest)
  logGreen(table.ztostring(vRequest))
end

return PhotographNtfStubImpl
