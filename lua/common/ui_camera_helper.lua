local UICameraHelper = {}
local curCameraState
Z.UICameraHelperFadeTime = 0.5

function UICameraHelper.OpenUICamera(cameraState)
  if Z.CameraMgr.CurrentState == cameraState then
    return
  end
  if cameraState == E.CameraState.None then
    return
  end
  if cameraState == E.CameraState.MiscSystem then
    local ids = ZUtil.Pool.Collections.ZList_int.Rent()
    ids:Add(E.ESystemCameraId.WeaponRole)
    if Z.IsPCUI then
      ids:Add(E.ESystemCameraId.WeaponRoleScreen)
    end
    Z.CameraMgr:EnterRoleInfo(ids)
    ZUtil.Pool.Collections.ZList_int.Return(ids)
  else
  end
  curCameraState = cameraState
end

function UICameraHelper.CloseUICamera()
  if curCameraState == E.CameraState.MiscSystem then
    Z.CameraMgr:ExitRoleInfo()
    curCameraState = nil
  else
  end
end

function UICameraHelper.SetCameraFocus(isDepth, focus, aperture)
  if Z.IsPCUI then
    focus = focus or 0
    aperture = aperture or 0
    Z.CameraFrameCtrl:SetUICameraFocus(isDepth, focus, aperture)
  end
end

return UICameraHelper
