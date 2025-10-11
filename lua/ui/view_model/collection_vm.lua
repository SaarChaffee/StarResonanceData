local ret = {}
local worldProxy = require("zproxy.world_proxy")

function ret.AsyncGetFashionCollectionAward(idList, token)
  local ret = worldProxy.GetCollectionReward(idList, token)
  if ret and ret.errCode == 0 then
    return ret
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function ret.AsyncGetFashionBenefitReward(index, token)
  local ret = worldProxy.GetFashionBenefitReward(index, token)
  if ret and ret.errCode == 0 then
    local itemShowVm = Z.VMMgr.GetVM("item_show")
    itemShowVm.OpenItemShowView(ret.rewards)
  else
    Z.TipsVM.ShowTips(ret.errCode)
  end
end

function ret.GetFashionCollectionPoints(socialData)
  if socialData then
    local fashionCollectPoint = 0
    if socialData.personalZone then
      if socialData.personalZone.fashionCollectPoint ~= nil then
        fashionCollectPoint = fashionCollectPoint + socialData.personalZone.fashionCollectPoint
      end
      if socialData.personalZone.rideCollectPoint ~= nil then
        fashionCollectPoint = fashionCollectPoint + socialData.personalZone.rideCollectPoint
      end
      if socialData.personalZone.weaponSkinCollectPoint ~= nil then
        fashionCollectPoint = fashionCollectPoint + socialData.personalZone.weaponSkinCollectPoint
      end
    end
    return fashionCollectPoint
  else
    local data = Z.ContainerMgr.CharSerialize.personalZone
    if data ~= nil then
      local fashionPoint = data.fashionCollectPoint or 0
      local ridePoint = data.rideCollectPoint or 0
      local weaponSkillPoint = data.weaponSkinCollectPoint or 0
      return fashionPoint + ridePoint + weaponSkillPoint
    end
  end
  return 0
end

function ret.GetMoonGiftRewardState(id)
  local curLevel = Z.CollectionScoreHelper.GetCollectionCurLevel()
  local fashionPrivilegeRow = Z.TableMgr.GetTable("FashionPrivilegeTableMgr").GetRow(id)
  if fashionPrivilegeRow.Type == E.FashionPrivilegeType.MoonGift then
    local _, level = ret.GetFashionLevelNameByPrivilegeId(id)
    if curLevel < level then
      return E.ReceiveRewardStatus.NotReceive
    end
    if not Z.ContainerMgr.CharSerialize.fashionBenefit.lastRewardIds or not table.zcontains(Z.ContainerMgr.CharSerialize.fashionBenefit.lastRewardIds, id) then
      return E.ReceiveRewardStatus.CanReceive
    end
  end
  return E.ReceiveRewardStatus.Received
end

function ret.HasMoonRewardCanGain()
  local fashionData = Z.DataMgr.Get("fashion_data")
  for _, row in pairs(fashionData:GetAllFashionPrivilegeRows()) do
    if row.Type == E.FashionPrivilegeType.MoonGift and ret.GetMoonGiftRewardState(row.Id) == E.ReceiveRewardStatus.CanReceive then
      return true
    end
  end
  return false
end

function ret.GetFashionLevelNameByPrivilegeId(id)
  local fashionData = Z.DataMgr.Get("fashion_data")
  for _, row in ipairs(fashionData:GetAllFashionLevelRows()) do
    for i = 1, #row.Privilege do
      if row.Privilege[i] == id then
        return row.Name, row.Id
      end
    end
  end
end

return ret
