local super = require("ui.service.service_base")
local ShopService = class("ShopService", super)
local shopRedClass = require("rednode.shop_red")

function ShopService:OnInit()
end

function ShopService:OnUnInit()
end

function ShopService:OnLogin()
  shopRedClass.Init()
  local shopVm = Z.VMMgr.GetVM("shop")
  shopVm.InitCfgData()
  
  function self.shopDataRefreshListChange_(container, dirty)
    shopRedClass.ShopRefreshListChange()
  end
  
  self.mysteriousId = Z.ContainerMgr.CharSerialize.shopData.Watcher:RegWatcher(self.shopDataRefreshListChange_)
  self.timeInited_ = false
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Add(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
end

function ShopService:OnLeaveScene()
end

function ShopService:OnLogout()
  if self.shopDataRefreshListChange_ then
    Z.ContainerMgr.CharSerialize.shopData.Watcher:RegWatcher(self.shopDataRefreshListChange_)
    self.shopDataRefreshListChange_ = nil
  end
  self.containerSynced = false
  self.timeInited_ = false
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerInited, self.onTimerInited, self)
  Z.EventMgr:Remove(Z.ConstValue.Timer.TimerUnInited, self.onTimerUnInited, self)
end

function ShopService:onTimerInited()
  self.timeInited_ = true
  if self.containerSynced then
    shopRedClass.ShopRefreshListChange()
  end
end

function ShopService:onTimerUnInited()
  self.timeInited_ = false
end

function ShopService:OnEnterScene(sceneId)
end

function ShopService:OnSyncAllContainerData()
  self.containerSynced = true
  if self.timeInited_ then
    shopRedClass.ShopRefreshListChange()
  end
end

return ShopService
