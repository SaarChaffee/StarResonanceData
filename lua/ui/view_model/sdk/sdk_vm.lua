local SDKVM = {}
local SDKDefine = require("ui.model.sdk_define")
local getVM = function()
  local accountData = Z.DataMgr.Get("account_data")
  if not Z.GameContext.IsUnderReview and not Z.GameContext.IsPC and accountData.PlatformType == E.LoginPlatformType.TencentPlatform and accountData.SDKType == E.LoginSDKType.MSDK then
    return Z.VMMgr.GetVM("tencent")
  end
  return nil
end

function SDKVM:OpenTaptapEvaluationPopup()
  local vm = getVM()
  if vm ~= nil and vm.OpenTaptapEvaluationPopup ~= nil then
    vm.OpenTaptapEvaluationPopup()
  end
end

function SDKVM:OpenAppleStoreEvaluationPopup()
  if Z.SDKDevices.IsCloudGame then
    return
  end
  if Z.SDKDevices.RuntimeOS ~= E.OS.iOS then
    return
  end
  local countKey = "AppleStoreEvaluation_Count"
  local timeKey = "AppleStoreEvaluation_Time"
  local count = Z.UserDataManager.GetInt(countKey, 0)
  if count < 3 then
    Z.SDKReview.Review()
    count = count + 1
    Z.UserDataManager.SetInt(countKey, count)
    Z.UserDataManager.SetLong(timeKey, os.time())
  end
end

function SDKVM:OpenGoogleStoreEvaluationPopup()
  if Z.SDKDevices.IsCloudGame then
    return
  end
  if Z.SDKDevices.RuntimeOS ~= E.OS.Android then
    return
  end
  local countKey = "GoogleStoreEvaluation_Count"
  local timeKey = "GoogleStoreEvaluation_Time"
  local count = Z.UserDataManager.GetInt(countKey, 0)
  if count < 3 then
    Z.SDKReview.Review()
    count = count + 1
    Z.UserDataManager.SetInt(countKey, count)
    Z.UserDataManager.SetLong(timeKey, os.time())
  end
end

function SDKVM.GetURL(urlFunctionType)
  local vm = getVM()
  if vm ~= nil and vm.GetURL ~= nil then
    return vm.GetURL(urlFunctionType)
  end
  return nil
end

function SDKVM.OpenURLByWebView(urlFunctionType, orientation, isFullScreen)
  local url = SDKVM.GetURL(urlFunctionType)
  if url == nil or url == "" then
    return
  end
  if orientation == nil then
    orientation = SDKDefine.WEBVIEW_ORIENTATION.Auto
  end
  if isFullScreen == nil then
    isFullScreen = false
  end
  Z.SDKWebView.OpenWebView(url, true, nil, orientation, isFullScreen)
end

function SDKVM.CheckLaunchPlatformCanShow(launchPlatform)
  local vm = getVM()
  if vm ~= nil and vm.CheckLaunchPlatformCanShow ~= nil then
    return vm.CheckLaunchPlatformCanShow(launchPlatform)
  end
  return false
end

function SDKVM.PrivilegeBtnClick(param)
  local vm = getVM()
  if vm ~= nil and vm.PrivilegeBtnClick ~= nil then
    vm.PrivilegeBtnClick(param)
  end
end

function SDKVM.IsShowPrivilege()
  local vm = getVM()
  if vm ~= nil and vm.IsShowPrivilege ~= nil then
    return vm.IsShowPrivilege()
  end
  return false
end

function SDKVM.GetFriendPicURLSuffix(url)
  local vm = getVM()
  if vm ~= nil and vm.GetFriendPicURLSuffix ~= nil then
    return vm.GetFriendPicURLSuffix(url)
  end
  return url
end

function SDKVM.CheckSDKFunctionCanShow(functionId)
  local vm = getVM()
  if vm ~= nil and vm.CheckSDKFunctionCanShow ~= nil then
    return vm.CheckSDKFunctionCanShow(functionId)
  end
  return false
end

function SDKVM.DeserializeWakeUpData(wakeUpData)
  local vm = getVM()
  if vm ~= nil and vm.DeserializeWakeUpData ~= nil then
    return vm.DeserializeWakeUpData(wakeUpData)
  end
end

function SDKVM.HttpGetTencentFriends(cancelToken, func)
  local vm = getVM()
  if vm ~= nil and vm.HttpGetTencentFriends ~= nil then
    return vm.HttpGetTencentFriends(cancelToken, func)
  end
end

function SDKVM.SDKOriginalShare(params)
  local vm = getVM()
  if vm ~= nil and vm.SDKOriginalShare ~= nil then
    vm.SDKOriginalShare(params)
  end
end

function SDKVM.IsNeedRegistWakeUpDataDeal()
  local vm = getVM()
  if vm ~= nil and vm.IsNeedRegistWakeUpDataDeal ~= nil then
    return vm.IsNeedRegistWakeUpDataDeal()
  end
  return false
end

function SDKVM.IsSchemeLegal(scheme)
  local legalSchemePrefix = Z.DataMgr.Get("sdk_data").LegalSchemePrefix
  for _, prefis in pairs(legalSchemePrefix) do
    if string.sub(scheme, 1, #prefis) == prefis then
      return true
    end
  end
  return false
end

function SDKVM.DealOpenScheme(url)
  if url == nil then
    return
  end
  if not Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(E.FunctionID.TokenLink, true) then
    return
  end
  if not SDKVM.IsSchemeLegal(url) then
    return
  end
  local vm = getVM()
  if vm ~= nil and vm.DealOpenScheme ~= nil then
    vm.DealOpenScheme(url)
  end
end

function SDKVM.GetHttpNoticeUrl()
  local sdkType = Z.SDKLogin.GetSDKType()
  local sdkTypeConfig = SDKDefine.SDK_TYPE_CONFIG[sdkType]
  if sdkTypeConfig == nil then
    return ""
  end
  local sdkData = Z.DataMgr.Get("sdk_data")
  local httpNoticeUrlPath = sdkData.HttpNoticeUrl
  if Z.GameContext.IsPreviewEnvironment() then
    httpNoticeUrlPath = sdkData.HttpNoticePreviewUrl
  end
  if httpNoticeUrlPath == nil then
    return ""
  end
  return httpNoticeUrlPath
end

function SDKVM.GetCommunityLabel()
  if not Z.Global.MaintenanceTipsSwitch then
    return ""
  end
  local labelKey = Z.Global.MaintenanceTipsShow
  if Z.LangMgr:IsContainKey(labelKey) then
    return Lang(labelKey, {
      url = Z.Global.MaintenanceTipsURL
    })
  else
    return ""
  end
end

return SDKVM
