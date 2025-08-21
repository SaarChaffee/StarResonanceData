local TreasureRed = {}

function TreasureRed:checkTreasureReddot()
  local treasureVm = Z.VMMgr.GetVM("treasure")
  if treasureVm:CheckCanGetTreasure() then
    Z.RedPointMgr.UpdateNodeCount(E.RedType.Treasure, 1)
  else
    Z.RedPointMgr.UpdateNodeCount(E.RedType.Treasure, 0)
  end
  Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.TreasureRedRefresh)
end

function TreasureRed:Init()
  self:checkTreasureReddot()
  
  function self.onflagChangeFunc(container, dirtyKeys)
    if dirtyKeys.flag or dirtyKeys.historyRows then
      self:checkTreasureReddot()
    end
  end
  
  Z.ContainerMgr.CharSerialize.treasure.Watcher:RegWatcher(self.onflagChangeFunc)
end

function TreasureRed:UnInit()
  Z.ContainerMgr.CharSerialize.treasure.Watcher:UnregWatcher(self.onflagChangeFunc)
end

return TreasureRed
