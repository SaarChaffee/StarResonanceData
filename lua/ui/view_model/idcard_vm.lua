local socialVm = Z.VMMgr.GetVM("social")
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
local getGetReviewAvatarInfo = function(charId, token)
  if not charId then
    return
  end
  local photoProxy = require("zproxy.photograph_proxy")
  local ret = photoProxy.GetReviewAvatarInfo({charId = charId}, token)
  if ret.errCode == 0 and ret.avatarInfo and ret.avatarInfo.halfBody then
    local tab = {}
    local snapshotVm = Z.VMMgr.GetVM("snapshot")
    tab.textureId = snapshotVm.AsyncDownLoadPictureByUrl(ret.avatarInfo.halfBody.url)
    tab.auditing = ret.avatarInfo.halfBody.verify.ReviewStartTime
    return tab
  end
  return nil
end
local ret = {
  CloseIdCardView = closeIdCardView,
  GetFuncList = getFuncList,
  AsyncGetCardData = asyncGetCardData,
  GetGetReviewAvatarInfo = getGetReviewAvatarInfo
}
return ret
