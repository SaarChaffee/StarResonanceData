local RecycleVM = {}
local worldProxy = require("zproxy.world_proxy")

function RecycleVM:CheckItemCanRecycle(configId)
  local recycleData = Z.DataMgr.Get("recycle_data")
  local allRecycleItemDict = recycleData:GetAllRecycleItemDict()
  for funcId, itemDict in pairs(allRecycleItemDict) do
    if itemDict[configId] then
      return true, funcId
    end
  end
  return false, nil
end

function RecycleVM:DoJumpByConfigId(configId)
  local canRecycle, funcId = self:CheckItemCanRecycle(configId)
  if not canRecycle then
    return
  end
  local recycleData = Z.DataMgr.Get("recycle_data")
  local recycleRow = recycleData:GetRecycleRowByFuncId(funcId)
  if recycleRow == nil then
    return
  end
  local quickJumpVm = Z.VMMgr.GetVM("quick_jump")
  quickJumpVm.DoJumpByConfigParam(recycleRow.QuickJumpType, recycleRow.QuickJumpParam)
end

function RecycleVM.OpenRecycleView(recycleId)
  Z.UIMgr:OpenView("recycle_window", recycleId)
end

function RecycleVM:AsyncReqRecycleItem(itemList, cancelToken)
  local ret = worldProxy.RecycleItems(itemList, cancelToken)
  if ret.items ~= nil then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  if ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  else
    return true
  end
end

return RecycleVM
