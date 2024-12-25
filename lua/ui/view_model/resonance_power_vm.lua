local openResonancePowerCreate = function(itemUuid, configId)
  local viewData = {}
  if configId then
    viewData.startCreateData = {configId = configId, count = 1}
  else
    viewData.startCreateData = {configId = -1, count = 1}
  end
  viewData.createMode = true
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "weapon_develop_intensify_window", function()
    Z.UIMgr:OpenView("weapon_develop_intensify_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
end
local openResonancePowerDecompose = function(itemUuid, configId)
  local viewData = {}
  viewData.startDecomposeData = {itemUuid = itemUuid, configId = configId}
  viewData.createMode = false
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.Backdrop_Explore_03, "weapon_develop_intensify_window", function()
    Z.UIMgr:OpenView("weapon_develop_intensify_window", viewData)
  end, Z.ConstValue.UnrealSceneConfigPaths.Backdrop_Explore)
end
local reqCreateResonancePower = function(itemId, count, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.itemId = itemId
  request.count = count
  local reply = worldProxy.AoYiItemFusion(request, cancelToken)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end
local reqDecomposeResonancePower = function(uuids, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local request = {}
  request.uuids = uuids
  local reply = worldProxy.AoYiItemDecompose(request, cancelToken)
  if reply and reply ~= 0 then
    Z.TipsVM.ShowTips(reply)
    return false
  else
    return true
  end
end
local closeResonancePowerView = function()
  Z.UIMgr:CloseView("weapon_develop_intensify_window")
end
local getDecomposeGetAward = function(consumeList)
  local awardPreviewVm = Z.VMMgr.GetVM("awardpreview")
  local awardIds = {}
  for _, consume in ipairs(consumeList) do
    local dataRow_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(consume.configId)
    if dataRow_ then
      for _, awardPackageId in ipairs(dataRow_.DecomposeAwardPackID) do
        table.insert(awardIds, awardPackageId[1])
      end
    end
  end
  return awardPreviewVm.GetAllAwardPreListByIds(awardIds)
end
local getCreateConsumeAward = function(configId, count)
  local awardIds = {}
  local dataRow_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  for k, v in pairs(dataRow_.MakeConsume) do
    awardIds[v[1]] = v[2] * count
  end
  return awardIds
end
local openDecomposeAcquireView = function(viewData)
  Z.UIMgr:OpenView("resonacne_power_decompose_acquire", viewData)
end
local closeDecomposeAcquireView = function()
  Z.UIMgr:CloseView("resonacne_power_decompose_acquire")
end
local getMaxCreateCount = function(configId)
  local maxCount_ = 999999999
  local canCreate = true
  local notEnoughItems_ = {}
  local aoyiItemCfg_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(aoyiItemCfg_.MakeConsume) do
    local configId_ = v[1]
    local needCount = v[2]
    local haveCount = itemVM.GetItemTotalCount(configId_)
    local count_ = math.floor(haveCount / needCount)
    if maxCount_ > count_ then
      maxCount_ = count_
    end
    if count_ < 1 then
      table.insert(notEnoughItems_, configId_)
    end
  end
  if maxCount_ < 1 then
    maxCount_ = 1
    canCreate = false
  else
    canCreate = true
  end
  local notEnoughItem_
  if 0 < #notEnoughItems_ then
    table.sort(notEnoughItems_)
    notEnoughItem_ = notEnoughItems_[1]
  end
  return maxCount_, canCreate, notEnoughItem_
end
local getNotEnoughItemByCount = function(configId, count)
  local notEnoughItems_ = {}
  local aoyiItemCfg_ = Z.TableMgr.GetTable("SkillAoyiItemTableMgr").GetRow(configId)
  local itemVM = Z.VMMgr.GetVM("items")
  for _, v in ipairs(aoyiItemCfg_.MakeConsume) do
    local configId_ = v[1]
    local needCount = v[2] * count
    local haveCount = itemVM.GetItemTotalCount(configId_)
    if needCount > haveCount then
      table.insert(notEnoughItems_, configId_)
    end
  end
  local notEnoughItem_
  if 0 < #notEnoughItems_ then
    table.sort(notEnoughItems_)
    notEnoughItem_ = notEnoughItems_[1]
  end
  return notEnoughItem_
end
local ret = {
  OpenResonancePowerCreate = openResonancePowerCreate,
  OpenResonancePowerDecompose = openResonancePowerDecompose,
  CloseResonancePowerView = closeResonancePowerView,
  GetDecomposeGetAward = getDecomposeGetAward,
  ReqCreateResonancePower = reqCreateResonancePower,
  ReqDecomposeResonancePower = reqDecomposeResonancePower,
  OpenDecomposeAcquireView = openDecomposeAcquireView,
  CloseDecomposeAcquireView = closeDecomposeAcquireView,
  GetMaxCreateCount = getMaxCreateCount,
  GetCreateConsumeAward = getCreateConsumeAward,
  GetNotEnoughItemByCount = getNotEnoughItemByCount
}
return ret
