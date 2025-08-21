local UserCenterVM = {}
local SDK_DEFINE = require("ui.model.sdk_define")

function UserCenterVM.GetUserCenterUrl(userSupportType)
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDK_DEFINE.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig == nil then
    return ""
  end
  local userCenterConfig = sdkTypeConfig.UserCenterUrlPathDict
  if userCenterConfig == nil then
    return ""
  end
  local url = userCenterConfig[userSupportType]
  if url == nil then
    return ""
  end
  return url
end

function UserCenterVM.GetUserCenterFunctionId()
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDK_DEFINE.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig then
    return sdkTypeConfig.UserCenterFunctionId
  end
  return nil
end

function UserCenterVM.GetUserCenterIcon(userSupportType)
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDK_DEFINE.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig == nil then
    return ""
  end
  local userSupportConfig = sdkTypeConfig.UserSupportIconPathDict
  if userSupportConfig == nil then
    return ""
  end
  local iconPath = userSupportConfig[userSupportType]
  if iconPath == nil then
    return ""
  end
  return iconPath
end

function UserCenterVM.IsFunctionOpen(isIgnoreTips)
  local functionId = UserCenterVM.GetUserCenterFunctionId()
  if functionId == nil then
    return false
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  return funcVm.CheckFuncCanUse(functionId, isIgnoreTips)
end

function UserCenterVM.CheckValid(userSupportType)
  if Z.GameContext.IsPreviewEnvironment() then
    return false
  end
  local url = UserCenterVM.GetUserCenterUrl(userSupportType)
  local isOpen = UserCenterVM.IsFunctionOpen(true)
  return url ~= "" and isOpen
end

function UserCenterVM.OpenUserCenter(userSupportType)
  local url = UserCenterVM.GetUserCenterUrl(userSupportType)
  if url == "" then
    return
  end
  Z.SDKLogin.UserCenter()
end

return UserCenterVM
