local super = require("ui.service.service_base")
local RedService = class("RedService", super)

function RedService:OnInit()
  self.bossRed_ = require("rednode.world_boss_red")
  self.expressionRed_ = require("rednode.expression_red")
end

function RedService:OnUnInit()
end

function RedService:OnLogin()
  self.cancelSource = Z.CancelSource.Rent()
  self.worldBossVM_ = Z.VMMgr.GetVM("world_boss")
  self.funcVM_ = Z.VMMgr.GetVM("gotofunc")
  self.bossRed_.Init()
  self.expressionRed_.Init()
  
  function self.onContainerDataChange_(container, dirtyKeys)
    if dirtyKeys.redDotCount then
      for id, _ in pairs(dirtyKeys.redDotCount) do
        local count = Z.ContainerMgr.CharSerialize.redDot.redDotCount[id]
        if count == nil then
          count = 0
        end
        Z.RedPointMgr.UpdateNodeCount(id, count)
        if id == E.RedType.UnionHuntPorgress then
          local isRed = Z.RedPointMgr.GetRedState(E.RedType.UnionHuntTab)
          Z.EventMgr:Dispatch(Z.ConstValue.Recommendedplay.FunctionRed, E.UnionFuncId.Hunt, isRed)
        end
      end
    end
  end
  
  Z.ContainerMgr.CharSerialize.redDot.Watcher:RegWatcher(self.onContainerDataChange_)
end

function RedService:OnLogout()
  self.bossRed_.UnInit()
  self.expressionRed_.UnInit()
  if self.cancelSource then
    self.cancelSource:Recycle()
    self.cancelSource = nil
  end
  Z.ContainerMgr.CharSerialize.redDot.Watcher:UnregWatcher(self.onContainerDataChange_)
  self.onContainerDataChange_ = nil
end

function RedService:OnEnterScene(sceneId)
  if Z.StageMgr.GetIsInGameScene() then
    Z.CoroUtil.create_coro_xpcall(function()
      if self.funcVM_.FuncIsOn(E.FunctionID.WorldBoss, true) then
        self.bossRed_.CheckRed()
        self.worldBossVM_:AsyncGetWorldBossInfo(self.cancelSource:CreateToken())
      end
    end)()
  end
end

function RedService:OnSyncAllContainerData()
  for id, value in pairs(Z.ContainerMgr.CharSerialize.redDot.redDotCount) do
    Z.RedPointMgr.UpdateNodeCount(id, value)
  end
end

return RedService
