local TreasureVM = {}

function TreasureVM:OpenTreasureView()
  Z.UnrealSceneMgr:OpenUnrealScene(Z.ConstValue.UnrealScenePaths.BackdropSeason_01, "treasure_window", function()
    Z.UIMgr:OpenView("treasure_window")
  end)
end

function TreasureVM:CheckOpenTreasureView()
  if self:CheckCanGetTreasure() then
    local gotoFuncVM = Z.VMMgr.GetVM("gotofunc")
    gotoFuncVM.TraceOrSwitchFunc(E.FunctionID.Treasure)
  else
    self:OpenTreasureView()
  end
end

function TreasureVM:CloseTreasureView()
  Z.UIMgr:CloseView("treasure_window")
end

function TreasureVM:CheckGetTreasure()
  return Z.ContainerMgr.CharSerialize.treasure.flag or table.zcount(Z.ContainerMgr.CharSerialize.treasure.historyRows) == 0
end

function TreasureVM:CheckCanGetTreasure()
  for _, treasureItemTarget in pairs(Z.ContainerMgr.CharSerialize.treasure.historyRows) do
    for __, value in pairs(treasureItemTarget.subTargets) do
      if value.reward and #value.reward.items > 0 then
        return Z.ContainerMgr.CharSerialize.treasure.flag == false
      end
    end
  end
  return false
end

function TreasureVM:AsyncGetTreasureReward(tableIndex, cancelToken)
  local worldProxy = require("zproxy.world_proxy")
  local getTreasureInfoRequest = {index = tableIndex}
  local ret = worldProxy.GetTreasureInfo(getTreasureInfoRequest, cancelToken)
  if ret.errCode and ret.errCode ~= 0 then
    Z.TipsVM.ShowTips(ret.errCode)
    return false
  end
  if 0 < #ret.items then
    local itemShowVM = Z.VMMgr.GetVM("item_show")
    itemShowVM.OpenItemShowViewByItems(ret.items)
  end
  return true
end

return TreasureVM
