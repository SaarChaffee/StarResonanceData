local socialProxy = require("zproxy.world_proxy")
local ret = {}

function ret.AsyncGetSocialData(mask, charId, cancelToken)
  if mask == nil then
    mask = 0
  end
  if charId == nil then
    charId = Z.ContainerMgr.CharSerialize.charId
  end
  local req = {mask = mask, charId = charId}
  if socialProxy then
    local reply = socialProxy.GetSocialData(req, cancelToken)
    if reply.errCode ~= 0 then
      Z.TipsVM.ShowTips(reply.errCode)
    end
    return reply.data
  end
  return nil
end

function ret.AsyncGetSocialDataTypeBasic(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetAvatarInfo(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAvatar, 0)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, mask)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetPersonalZone(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, 0)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetHeadAndHeadFrameInfo(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAvatar, mask)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeWeapon, mask)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, mask)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetHeadAndHeadFrameInfoAndSDKPrivilege(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeBase, 0)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAvatar, mask)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypePersonalZone, mask)
  mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialSDKPrivilege, mask)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetFaceData(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeFace, 0)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetWeaponData(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeWeapon, 0)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.AsyncGetAccountData(charId, cancelToken)
  local mask = ret.GetSocialDataTypeMask(Z.ConstValue.SocialDataType.SocialDataTypeAccount, 0)
  return ret.AsyncGetSocialData(mask, charId, cancelToken)
end

function ret.GetSocialDataTypeMask(type, mask)
  if 64 < type then
    logError("type is too large:{0}", type)
    return mask
  end
  return Z.BitOR(mask, 1 << type)
end

function ret.GetModelId(socialData)
  if socialData == nil or socialData.basicData == nil then
    return 0
  end
  local gender = socialData.basicData.gender
  local bodySize = socialData.basicData.bodySize
  local modelId = Z.ModelManager:GetModelIdByGenderAndSize(gender, bodySize)
  return modelId
end

local deadAllowFuncDict = {
  [E.IdCardFuncId.AddFriend] = true,
  [E.IdCardFuncId.SendMsg] = true,
  [E.IdCardFuncId.BlockPlayer] = true,
  [E.IdCardFuncId.CancelBlock] = true,
  [E.IdCardFuncId.ApplyForRide] = true,
  [E.IdCardFuncId.InviteRide] = true
}

function ret.CheckCanSwitch(idCardFuncId, isIngoreTips)
  local deadVM = Z.VMMgr.GetVM("dead")
  if deadVM.CheckPlayerIsDead() and (idCardFuncId == nil or not deadAllowFuncDict[idCardFuncId]) then
    if not isIngoreTips then
      Z.TipsVM.ShowTipsLang(100126)
    end
    return false
  end
  return true
end

return ret
