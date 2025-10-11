local socialVm = Z.VMMgr.GetVM("social")
local downloadVm = Z.VMMgr.GetVM("download")
local asyncGetCardData = function(charId, cancelToken, photoData, isShowInviteAction, rideId)
  local socialData = socialVm.AsyncGetSocialData(0, charId, cancelToken)
  if socialData then
    Z.UIMgr:OpenView("idcard", {
      cardId = charId,
      cardData = socialData,
      photoData = photoData,
      isShowInviteAction = isShowInviteAction,
      rideId = rideId
    })
  end
end
local closeIdCardView = function()
  Z.UIMgr:CloseView("idcard")
end
local getFuncList = function()
  local funcList = Z.TableMgr.GetTable("RoleCardTableMgr").GetDatas()
  table.sort(funcList, function(a, b)
    if a.Sort < b.Sort then
      return a
    end
  end)
  return funcList
end
local getGetReviewAvatarInfo = function(charId, cancelSource, callbackFunc)
  if not charId or not cancelSource then
    return
  end
  local photoProxy = require("zproxy.photograph_proxy")
  local ret = photoProxy.GetReviewAvatarInfo({charId = charId}, cancelSource:CreateToken())
  if ret.errCode == 0 and ret.avatarInfo and ret.avatarInfo.halfBody then
    local tempFunc = function(nativeTextureId)
      local tab = {}
      tab.textureId = nativeTextureId
      tab.auditing = ret.avatarInfo.halfBody.verify.ReviewStartTime
      callbackFunc(tab)
    end
    local name = downloadVm:GetFileName(charId, ret.avatarInfo.halfBody.verify.version, E.HttpPictureDownFoldType.HalfBody)
    downloadVm:GetPicture(name, ret.avatarInfo.halfBody.url, cancelSource:CreateToken(), tempFunc, E.HttpPictureDownFoldType.HalfBody)
    return
  end
  callbackFunc(nil)
end
local ret = {
  CloseIdCardView = closeIdCardView,
  GetFuncList = getFuncList,
  AsyncGetCardData = asyncGetCardData,
  GetGetReviewAvatarInfo = getGetReviewAvatarInfo
}
return ret
