local AfficheVM = {}
local cjson = require("cjson")
local UrlHelper = require("common.url_helper")
local ID_SYMBOL = "#"

function AfficheVM.ReceiveNoticeData(noticeArray, cacheIdStr)
  if noticeArray == nil or noticeArray.Length == 0 then
    logGreen("[AfficheVM] ReceiveNoticeData : noticeArray is nil")
    return false
  end
  local afficheData = Z.DataMgr.Get("affiche_data")
  afficheData:ClearAfficheData()
  local isShow = cacheIdStr == nil
  local cacheIdList = string.split(cacheIdStr or "", ID_SYMBOL)
  local cacheIdDict = {}
  for i, v in ipairs(cacheIdList) do
    cacheIdDict[v] = true
  end
  local newIdList = {}
  for i = 0, noticeArray.Length - 1 do
    local noticeData = noticeArray[i]
    local imagePath
    if noticeData.ExtraJSON and noticeData.ExtraJSON ~= "" then
      local parameter = cjson.decode(noticeData.ExtraJSON)
      if parameter.image then
        imagePath = UrlHelper.Decode(parameter.image)
      end
    end
    afficheData:AddAfficheData(noticeData.NoticeType, noticeData.Title, noticeData.Title, noticeData.Content, imagePath)
    local strId = tostring(noticeData.ID)
    newIdList[i + 1] = strId
    if not cacheIdDict[strId] then
      isShow = true
    end
  end
  logGreen(string.format("Notice CallBack, result = %s", table.ztostring(afficheData:GetAfficheData(E.NoticeType.Event))))
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, Z.ConstValue.PlayerPrefsKey.Announcement, table.concat(newIdList, ID_SYMBOL))
  Z.LocalUserDataMgr.Save()
  return isShow
end

function AfficheVM.ReceiveHttpNoticeData(noticeList, cacheIdStr)
  if noticeList == nil or next(noticeList) == nil then
    logGreen("[AfficheVM] ReceiveHttpNoticeData : noticeList is nil")
    return false
  end
  local afficheData = Z.DataMgr.Get("affiche_data")
  afficheData:ClearAfficheData()
  local isShow = cacheIdStr == nil
  local cacheIdList = string.split(cacheIdStr or "", ID_SYMBOL)
  local cacheIdDict = {}
  for i, v in ipairs(cacheIdList) do
    cacheIdDict[v] = true
  end
  local newIdList = {}
  for i, noticeData in ipairs(noticeList) do
    local imagePath
    if noticeData.Image and noticeData.Image ~= "" then
      imagePath = UrlHelper.Decode(noticeData.Image)
    end
    afficheData:AddAfficheData(noticeData.NoticeType, noticeData.Title, noticeData.Title, noticeData.Content, imagePath)
    local strId = tostring(noticeData.ID)
    newIdList[i + 1] = strId
    if not cacheIdDict[strId] then
      isShow = true
    end
  end
  logGreen(string.format("Notice CallBack, result = %s", table.ztostring(afficheData:GetAfficheData(E.NoticeType.Event))))
  Z.LocalUserDataMgr.SetStringByLua(E.LocalUserDataType.Device, Z.ConstValue.PlayerPrefsKey.Announcement, table.concat(newIdList, ID_SYMBOL))
  return isShow
end

function AfficheVM.OpenAfficheView(cacheIdStr)
  if cacheIdStr == nil then
    Z.UIMgr:OpenView("login_affiche_popup")
  end
  Z.SDKNotice.LoadNotice(function(code, msg, requestId, result)
    logGreen(string.format("Notice CallBack, code = %s, msg = %s, requestId = %s", code, msg, requestId))
    if code and code == 0 then
      local isShow = AfficheVM.ReceiveNoticeData(result, cacheIdStr)
      if cacheIdStr == nil then
        Z.EventMgr:Dispatch(Z.ConstValue.AfficheRefresh)
      elseif isShow then
        Z.UIMgr:OpenView("login_affiche_popup")
      end
    end
  end)
end

function AfficheVM.OpenHttpAfficheView(cacheIdStr)
  Z.CoroUtil.create_coro_xpcall(function()
    local sdkVM = Z.VMMgr.GetVM("sdk")
    local httpNoticeUrl = sdkVM.GetHttpNoticeUrl()
    if httpNoticeUrl == nil or cacheIdStr == nil then
      Z.UIMgr:OpenView("login_affiche_popup")
    end
    local cancelSource = Z.CancelSource.Rent()
    local request = Z.HttpRequest.Rent()
    request.Url = httpNoticeUrl
    local asyncCall = Z.CoroUtil.async_to_sync(Z.HttpMgr.Get)
    local response = asyncCall(Z.HttpMgr, request, cancelSource:CreateToken())
    if response == nil or response.HasError or response.Value == "" then
      if response ~= nil then
        response:Recycle()
      end
      request:Recycle()
      cancelSource:Recycle()
      return false
    end
    local cjson = require("cjson")
    local noticeList = cjson.decode(response.Value).NoticeList
    local isShow = AfficheVM.ReceiveHttpNoticeData(noticeList, cacheIdStr)
    if cacheIdStr == nil then
      Z.EventMgr:Dispatch(Z.ConstValue.AfficheRefresh)
    elseif isShow then
      Z.UIMgr:OpenView("login_affiche_popup")
    end
    response:Recycle()
    request:Recycle()
    cancelSource:Recycle()
  end, function(err)
    if err ~= nil then
      if err == ZUtil.ZCancelSource.CancelException then
        return
      end
      logError("OpenHttpAfficheView fail, error = {0}", err)
    end
  end)()
end

function AfficheVM.CheckAfficheAutoShow()
  local cacheIdStr = Z.LocalUserDataMgr.GetStringByLua(E.LocalUserDataType.Device, Z.ConstValue.PlayerPrefsKey.Announcement, "")
  AfficheVM.OpenAfficheView(cacheIdStr)
end

return AfficheVM
