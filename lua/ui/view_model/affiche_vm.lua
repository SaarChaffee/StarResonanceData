local AfficheVM = {}
local cjson = require("cjson")
local UrlHelper = require("common.url_helper")
local ID_SYMBOL = "#"

function AfficheVM.ReceiveNoticeData(noticeArray, cacheIdStr)
  if noticeArray == nil or noticeArray.Length == 0 then
    logGreen("[AfficheVM] ReceiveNoticeData : noticeArray is nil")
    return
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
  Z.LocalUserDataMgr.SetString(Z.ConstValue.PlayerPrefsKey.Announcement, table.concat(newIdList, ID_SYMBOL), 0, true)
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

function AfficheVM.CheckAfficheAutoShow()
  local cacheIdStr = Z.LocalUserDataMgr.GetString(Z.ConstValue.PlayerPrefsKey.Announcement, "", 0, true)
  AfficheVM.OpenAfficheView(cacheIdStr)
end

return AfficheVM
