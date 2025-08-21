local UserSupportVM = {}
local SDK_DEFINE = require("ui.model.sdk_define")

function UserSupportVM.GetUserSupportUrl(userSupportType)
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDK_DEFINE.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig == nil then
    return ""
  end
  local userSupportConfig = sdkTypeConfig.UserSupportUrlPathDict
  if userSupportConfig == nil then
    return ""
  end
  local url = userSupportConfig[userSupportType]
  if url == nil then
    return ""
  end
  return url
end

function UserSupportVM.GetUserSupportFunctionId()
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDK_DEFINE.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig then
    return sdkTypeConfig.UserSupportFunctionId
  end
  return nil
end

function UserSupportVM.GetUserSupportIcon(userSupportType)
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

function UserSupportVM.IsFunctionOpen(isIgnoreTips)
  local functionId = UserSupportVM.GetUserSupportFunctionId()
  if functionId == nil then
    return false
  end
  local funcVm = Z.VMMgr.GetVM("gotofunc")
  return funcVm.CheckFuncCanUse(functionId, isIgnoreTips)
end

function UserSupportVM.CheckValid(userSupportType)
  if Z.GameContext.IsPreviewEnvironment() then
    return false
  end
  local url = UserSupportVM.GetUserSupportUrl(userSupportType)
  local isOpen = UserSupportVM.IsFunctionOpen(true)
  return url ~= "" and isOpen
end

function UserSupportVM.OpenUserSupportWebView(userSupportType)
  local url = UserSupportVM.GetUserSupportUrl(userSupportType)
  if url == "" then
    return
  end
  local charId = "0"
  local charName = ""
  if Z.ContainerMgr.CharSerialize ~= nil and Z.ContainerMgr.CharSerialize.charBase.charId then
    charId = tostring(Z.ContainerMgr.CharSerialize.charBase.charId)
  end
  if Z.ContainerMgr.CharSerialize ~= nil and Z.ContainerMgr.CharSerialize.charBase.name then
    charName = Z.ContainerMgr.CharSerialize.charBase.name
  end
  Z.SDKLogin.OpenCustomSerivce("", charName, charId, url)
end

return UserSupportVM
