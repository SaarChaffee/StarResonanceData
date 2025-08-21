local TencentVM = {}
local SDKDefine = require("ui.model.sdk_define")
local TENCENT_DEFINE = require("ui.model.tencent_define")
local UrlHelper = require("common.url_helper")
local cjson = require("cjson")
local SDKFunctionIds = {
  [E.LoginType.QQ] = {
    E.FunctionID.TencentQQChannel,
    E.FunctionID.TencentQQPrivilege,
    E.FunctionID.TencentQQGift,
    E.FunctionID.TencentQQGameCenter,
    E.FunctionID.TencentSuperVip,
    E.FunctionID.TencentGrowth,
    E.FunctionID.TencentFriends,
    E.FunctionID.TencentQQArk
  },
  [E.LoginType.WeChat] = {
    E.FunctionID.TencentWeChatGift,
    E.FunctionID.TencentWeChatPrivilege,
    E.FunctionID.TencentSuperVip,
    E.FunctionID.TencentGrowth,
    E.FunctionID.TencentFriends
  }
}
local getSuperVipUrl = function(url)
  local plat = ""
  if Z.SDKDevices.RuntimeOS == E.OS.iOS then
    plat = "0"
  elseif Z.SDKDevices.RuntimeOS == E.OS.Android then
    plat = "1"
  end
  local ch = ""
  local appid = ""
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.LoginType == E.LoginType.QQ then
    ch = "1"
    appid = TENCENT_DEFINE.QQAppId
  elseif accountData.LoginType == E.LoginType.WeChat then
    ch = "2"
    appid = TENCENT_DEFINE.WechatAppId
  end
  local ava = Z.DataMgr.Get("sdk_data").DefaultAvator
  if Z.ContainerMgr.CharSerialize.charBase.avatarInfo and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.profile and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.profile.url and Z.ContainerMgr.CharSerialize.charBase.avatarInfo.profile.url ~= "" then
    ava = Z.ContainerMgr.CharSerialize.charBase.avatarInfo.profile.url
  end
  local params = {
    gid = "1488",
    pid = "182",
    reg = "1",
    plat = plat,
    ch = ch,
    area = E.SDKZoneId.TencentProduct,
    part = E.SDKZoneId.TencentProduct,
    openid = tostring(accountData.OpenID),
    appid = appid,
    role = tostring(Z.ContainerMgr.CharSerialize.charBase.charId),
    msdkt = tostring(accountData.Token),
    t = tostring(os.time()),
    r = tostring(math.random(1000, 10000)),
    ava = ava,
    nick = tostring(Z.ContainerMgr.CharSerialize.charBase.name),
    channelid = Z.SDKTencent.InstallChannel
  }
  local res = string.format(url, Z.LuaBridge.EncodeTencentSuperVipCode(cjson.encode(params)))
  return res
end
local isInternal = function()
  if Z.SDKDevices.IsCloudGame then
    return false
  end
  local installChannel = tonumber(Z.SDKTencent.InstallChannel)
  if installChannel then
    local sdkData = Z.DataMgr.Get("sdk_data")
    for _, v in ipairs(sdkData.SDKBlackList) do
      if math.floor(v) == installChannel then
        return false
      end
    end
  end
  return true
end
local dealOpenSchemeWebViewType = function(param)
  if param == nil or param == 0 then
    return SDKDefine.WEBVIEW_ORIENTATION.Auto, false
  end
  local isFullScrren = 0 < param & TENCENT_DEFINE.TencentTokenLinkOrientation.isFullScrren
  if 0 < param & TENCENT_DEFINE.TencentTokenLinkOrientation.Portrait then
    return SDKDefine.WEBVIEW_ORIENTATION.Portrait, isFullScrren
  elseif 0 < param & TENCENT_DEFINE.TencentTokenLinkOrientation.Landscape then
    return SDKDefine.WEBVIEW_ORIENTATION.Landscape, isFullScrren
  else
    return SDKDefine.WEBVIEW_ORIENTATION.Auto, isFullScrren
  end
end
local isTencentFriendCreateAndOnline = function(friend)
  local isCreateChar = false
  if friend.roleInfos then
    for _, roleInfo in ipairs(friend.roleInfos) do
      isCreateChar = true
      local onlineTime = tonumber(roleInfo.onlineTime) or 0
      local offlineTime = tonumber(roleInfo.offlineTime) or 0
      if onlineTime > offlineTime then
        return TENCENT_DEFINE.TencentFriendSort.Online
      end
    end
  end
  if isCreateChar then
    return TENCENT_DEFINE.TencentFriendSort.OffOnline
  end
  return TENCENT_DEFINE.TencentFriendSort.NoChar
end
local tencentFriendsSort = function(a, b)
  local aSort = isTencentFriendCreateAndOnline(a)
  local bSort = isTencentFriendCreateAndOnline(b)
  if aSort == bSort then
    return a.userName < b.userName
  else
    return aSort < bSort
  end
end

function TencentVM.GetURL(urlFunctionType)
  local isSuperVip = false
  local currentPlatform = Z.SDKLogin.GetPlatform()
  local sdkType = Z.SDKLogin.GetSDKType()
  local loginType = Z.DataMgr.Get("account_data").LoginType
  if urlFunctionType == SDKDefine.SDK_URL_FUNCTION_TYPE.SuperVip and currentPlatform == E.LoginPlatformType.TencentPlatform and sdkType == E.LoginSDKType.MSDK and (loginType == E.LoginType.QQ or loginType == E.LoginType.WeChat) then
    isSuperVip = true
  end
  currentPlatform = tostring(currentPlatform)
  sdkType = tostring(sdkType)
  loginType = tostring(loginType)
  urlFunctionType = tostring(urlFunctionType)
  local sdkData = Z.DataMgr.Get("sdk_data")
  local url
  if sdkData.SDKURL[currentPlatform] and sdkData.SDKURL[currentPlatform][sdkType] and sdkData.SDKURL[currentPlatform][sdkType][loginType] and sdkData.SDKURL[currentPlatform][sdkType][loginType][urlFunctionType] then
    url = sdkData.SDKURL[currentPlatform][sdkType][loginType][urlFunctionType]
  end
  if isSuperVip then
    url = getSuperVipUrl(url)
  end
  return url
end

function TencentVM.CheckLaunchPlatformCanShow(launchPlatform)
  if launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformNull then
    return true
  elseif launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq then
    local accountData = Z.DataMgr.Get("account_data")
    return isInternal() and accountData.LoginType == E.LoginType.QQ
  elseif launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin then
    local accountData = Z.DataMgr.Get("account_data")
    return isInternal() and accountData.LoginType == E.LoginType.WeChat
  end
end

function TencentVM.PrivilegeBtnClick(param)
  if not isInternal() then
    return
  end
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.LoginType == E.LoginType.QQ then
    Z.VMMgr.GetVM("sdk").OpenURLByWebView(SDKDefine.SDK_URL_FUNCTION_TYPE.Privilege)
  elseif accountData.LoginType == E.LoginType.WeChat then
    if param == nil then
      Z.UIMgr:OpenView("common_privilege_popup")
    elseif param == Z.EntityMgr.PlayerEnt.EntId then
      Z.TipsVM.ShowTipsLang(100012)
    else
      Z.TipsVM.ShowTipsLang(100013)
    end
  end
end

function TencentVM.IsShowPrivilege()
  if not isInternal() then
    return false
  end
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.LoginType == E.LoginType.QQ then
    local isUnlock = TencentVM.CheckSDKFunctionCanShow(E.FunctionID.TencentQQPrivilege)
    return isUnlock and Z.ContainerMgr.CharSerialize.launchPrivilegeData.isPrivilege and Z.ContainerMgr.CharSerialize.launchPrivilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformQq
  elseif accountData.LoginType == E.LoginType.WeChat then
    local isUnlock = TencentVM.CheckSDKFunctionCanShow(E.FunctionID.TencentWeChatPrivilege)
    return isUnlock and Z.ContainerMgr.CharSerialize.launchPrivilegeData.isPrivilege and Z.ContainerMgr.CharSerialize.launchPrivilegeData.launchPlatform == SDKDefine.LaunchPlatform.LaunchPlatformWeXin
  end
  return false
end

function TencentVM.GetFriendPicURLSuffix(url)
  if not isInternal() then
    return url
  end
  local last_char = string.sub(url, -1)
  if last_char ~= "/" then
    url = url .. "/"
  end
  local accountData = Z.DataMgr.Get("account_data")
  if accountData.LoginType == E.LoginType.QQ then
    return url .. TENCENT_DEFINE.QQFriendPicURLSuffix
  elseif accountData.LoginType == E.LoginType.WeChat then
    return url .. TENCENT_DEFINE.WechatFriendPicURLSuffix
  end
  return url
end

function TencentVM.CheckSDKFunctionCanShow(functionId)
  local previewIsUnLock = false
  if functionId == E.FunctionID.TencentSuperVip then
    if isInternal() and E.SDKZoneId.TencentProduct == tostring(Z.DataMgr.Get("server_data"):GetCurrentZoneId()) then
      previewIsUnLock = true
    end
  elseif functionId == E.FunctionID.TencentGrowth then
    previewIsUnLock = true
  else
    previewIsUnLock = isInternal()
  end
  local accountData = Z.DataMgr.Get("account_data")
  local sdkFunctionIds = SDKFunctionIds[accountData.LoginType]
  if sdkFunctionIds then
    for _, id in ipairs(sdkFunctionIds) do
      if id == functionId then
        return Z.VMMgr.GetVM("gotofunc").CheckFuncCanUse(functionId, true) and previewIsUnLock
      end
    end
  end
  return false
end

function TencentVM.DeserializeWakeUpData(wakeUpData)
  local resLaunchParam = {
    launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformNull,
    uniqueUid = ""
  }
  if wakeUpData == nil then
    return resLaunchParam
  end
  local extraJSON = wakeUpData.Extra
  if extraJSON == nil or extraJSON == "" then
    return resLaunchParam
  end
  xpcall(function()
    if not isInternal() then
      return
    end
    local info = cjson.decode(extraJSON)
    if type(info.params) == "string" then
      if info.params and info.params ~= "" then
        local param = cjson.decode(info.params)
        local openId = param.openid
        local launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformNull
        if Z.SDKDevices.RuntimeOS == E.OS.Android then
          if param.launchfrom ~= nil and param.launchfrom == "sq_gamecenter" then
            launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformQq
          elseif param._wxobject_message_ext ~= nil and param._wxobject_message_ext == "WX_GameCenter" then
            launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformWeXin
          end
        elseif Z.SDKDevices.RuntimeOS == E.OS.iOS and param.launchfrom ~= nil and param.launchfrom == "sq_gamecenter" then
          launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformQq
        end
        resLaunchParam = {launchPlatform = launchPlatform, uniqueUid = openId}
      end
    elseif type(info.params) == "table" then
      local openId = info.params.openId
      local launchPlatform
      if info.params.messageExt ~= nil and info.params.messageExt == "WX_GameCenter" then
        launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformWeXin
      else
        launchPlatform = SDKDefine.LaunchPlatform.LaunchPlatformNull
      end
      resLaunchParam = {launchPlatform = launchPlatform, uniqueUid = openId}
    end
  end, function(err)
    logError("TencentVM.DeserializeWakeUpData error : " .. err)
  end)
  return resLaunchParam
end

function TencentVM.HttpGetTencentFriends(cancelToken, func)
  local accountData = Z.DataMgr.Get("account_data")
  local url = string.format(Z.GameContext.TencentFriendsURL, accountData.LoginType, accountData.OpenID, accountData.Token)
  local request = Z.HttpRequest.Rent()
  request.Url = url
  Z.HttpMgr:Get(request, cancelToken, function(response)
    if response == nil or response.HasError or response.Value == "" then
      if response ~= nil then
        response:Recycle()
      end
      request:Recycle()
      Z.TipsVM.ShowTips(120019)
      return
    end
    local tempTable = cjson.decode(response.Value)
    if tempTable.error and tonumber(tempTable.error) == 0 then
      xpcall(function()
        local sdkFriends = cjson.decode(tempTable.message).friends
        local tempFriends = {}
        for _, friend in ipairs(sdkFriends) do
          if friend.roleInfos ~= nil and #friend.roleInfos > 0 then
            table.insert(tempFriends, friend)
          end
        end
        table.sort(tempFriends, function(a, b)
          return tencentFriendsSort(a, b)
        end)
        Z.DataMgr.Get("sdk_data").SDKFriends = tempFriends
        if func then
          func()
        end
        request:Recycle()
        response:Recycle()
      end, function(err)
        logError("TencentVM.HttpGetTencentFriends error : " .. err)
        request:Recycle()
        response:Recycle()
      end)
    end
  end, function(exception)
    request:Recycle()
  end)
end

function TencentVM.SDKOriginalShare(params)
  local config = Z.TableMgr.GetTable("WeChatShareTableMgr").GetRow(params[1])
  if config == nil then
    return
  end
  local cjson = require("cjson")
  local extraJsonTable = {
    message_action = "",
    game_data = "",
    media_tag_name = "MSG_INVITE",
    isVideo = 0,
    videoDuration = 0,
    shareData = cjson.encode({
      appid = TENCENT_DEFINE.WechatAppId,
      game_launch = {message_ext = ""},
      share_image_tpl = {
        share_img_list = {
          [1] = {
            img_url = config.ReceivingPagePictureURL[1],
            width = config.ReceivingPagePictureData[1][1],
            height = config.ReceivingPagePictureData[1][2]
          }
        },
        user_card = {
          content = config.ReceivingPageDesc
        }
      }
    })
  }
  local extraJson = cjson.encode(extraJsonTable)
  if params[2] then
    Z.GameShareManager:ShareLink(config.CoverTitle, "", Bokura.Plugins.Share.SharePlatform.WeChatMomentGamePage, config.CoverPictureURL, config.CoverDesc, extraJson)
  else
    Z.GameShareManager:ShareLink(config.CoverTitle, "", Bokura.Plugins.Share.SharePlatform.WeChatGamePage, config.CoverPictureURL, config.CoverDesc, extraJson)
  end
end

function TencentVM.IsNeedRegistWakeUpDataDeal()
  if not isInternal() then
    return false
  end
  local accountData = Z.DataMgr.Get("account_data")
  return accountData.LoginType == E.LoginType.QQ or accountData.LoginType == E.LoginType.WeChat
end

function TencentVM.DealOpenScheme(scheme)
  if scheme == nil then
    return
  end
  local res = string.split(scheme, "_")
  if res[2] then
    local schemeType = tonumber(res[2])
    if schemeType == TENCENT_DEFINE.SCHEMETYPE.OpenWebView then
      local orientation, isFullScreen = dealOpenSchemeWebViewType(tonumber(res[4]))
      if res[3] ~= nil and res[3] ~= "" then
        local url = UrlHelper.Decode(res[3])
        local c = UrlHelper.GetUrlMontageQueryStart(url)
        local accountData = Z.DataMgr.Get("account_data")
        local openid = "openid=" .. UrlHelper.Decode(accountData.OpenID)
        local area = "&area=" .. UrlHelper.Decode(E.SDKZoneId.TencentProduct)
        local platid = "&platid=1"
        local partition = "&partition=" .. UrlHelper.Decode(E.SDKZoneId.TencentProduct)
        local roleid = "&roleid=" .. UrlHelper.Decode(tostring(Z.ContainerMgr.CharSerialize.charBase.charId))
        url = string.zconcat(url, c, openid, area, platid, partition, roleid)
        logGreen("TokenLink Url : " .. url)
        Z.SDKWebView.OpenWebView(url, true, nil, orientation, isFullScreen)
      end
    elseif schemeType == TENCENT_DEFINE.SCHEMETYPE.GameFunc and res[3] then
      local param
      if res[4] then
        param = table.unpack(res, 4)
      end
      Z.VMMgr.GetVM("gotofunc").GoToFunc(tonumber(res[3]), param)
    end
  end
end

function TencentVM.OpenTaptapEvaluationPopup()
  if Z.SDKDevices.IsCloudGame then
    return
  end
  if tonumber(Z.SDKTencent.InstallChannel) ~= SDKDefine.SDK_CHANNEL_ID.TapTap then
    return
  end
  local content = Lang("TapTapEvaluationDesc")
  local confirmLabel = Lang("TapTapEvaluationSwitch")
  local dialogViewData = {
    dlgType = E.DlgType.YesNo,
    labDesc = content,
    onConfirm = function()
      Z.SDKTencent.Review()
    end,
    labYes = confirmLabel
  }
  Z.DialogViewDataMgr:OpenDialogView(dialogViewData)
end

function TencentVM.OpenAppleStoreEvaluationPopup()
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
    Z.SDKTencent.Review()
    count = count + 1
    Z.UserDataManager.SetInt(countKey, count)
    Z.UserDataManager.SetLong(timeKey, os.time())
  end
end

return TencentVM
