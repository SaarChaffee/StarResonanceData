local SDKHelper = {}
local SDK_DEFINE = require("ui.model.sdk_define")

function SDKHelper.IsShowTipsView(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].IsShowAgreementTips
  end
  return false
end

function SDKHelper.GetContractUrlPath(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].ContractUrlPath
  end
  return ""
end

function SDKHelper.GetPrivacyGuideUrlPath(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].PrivacyGuideUrlPath
  end
  return ""
end

function SDKHelper.GetChildrenPrivacyUrlPath(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].ChildrenPrivacyUrlPath
  end
  return ""
end

function SDKHelper.GetThirdInfoShareUrlPath(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].ThirdInfoShareUrlPath
  end
  return ""
end

function SDKHelper.GetCollectedInfoListUrlPath(platformType)
  if SDK_DEFINE.CONFIG[platformType] then
    return SDK_DEFINE.CONFIG[platformType].CollectedInfoListUrlPath
  end
  return ""
end

return SDKHelper
